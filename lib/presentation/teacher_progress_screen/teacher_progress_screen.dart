import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/user_model.dart';
import '../../models/course_model.dart';
import '../../widgets/custom_icon_widget.dart';
import '../../services/ar_service.dart';
import '../../models/ar_experiment_model.dart';
import '../../data/dummy_ar_experiments.dart';
import '../../models/activity_model.dart';


import '../../core/app_export.dart';
import 'package:provider/provider.dart';
import '../../services/auth_service.dart';
// ── Data models ───────────────────────────────────────────────────────────────

class MissedQuiz {
  final String quizTitle;
  final String courseTitle;
  final String dueDate;

  const MissedQuiz({
    required this.quizTitle,
    required this.courseTitle,
    required this.dueDate,
  });
}

class StudentProgress {
  final String name;
  final String section;
  final List<QuizResult> quizResults;
  final List<MissedQuiz> missedQuizzes;
  final List<ArLabRecord> arLabRecords;
  final String? studentNumber;

  const StudentProgress({
    required this.name,
    required this.section,
    required this.quizResults,
    required this.missedQuizzes,
    required this.arLabRecords,
    this.studentNumber,
  });
}

class QuizResult {
  final String quizTitle;
  final int score;
  final int total;
  final String date;

  const QuizResult({
    required this.quizTitle,
    required this.score,
    required this.total,
    required this.date,
  });

  double get percentage => total > 0 ? score / total : 0;
}

class ArLabRecord {
  final String experimentName;
  final int attempts;
  final double rubricScore; // out of 100
  final String lastAttemptDate;

  const ArLabRecord({
    required this.experimentName,
    required this.attempts,
    required this.rubricScore,
    required this.lastAttemptDate,
  });
}

// ── Screen ────────────────────────────────────────────────────────────────────

class TeacherProgressScreen extends StatefulWidget {
  const TeacherProgressScreen({super.key});

  @override
  State<TeacherProgressScreen> createState() => _TeacherProgressScreenState();
}

class _TeacherProgressScreenState extends State<TeacherProgressScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<String> _teacherSections = [];
  String _selectedSection = 'All Sections';
  List<StudentProgress> _allStudents = [];
  bool _loading = true;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  String _formatDate(DateTime? dt) {
    if (dt == null) return '';
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    String pad(int n) => n.toString().padLeft(2, '0');
    final hour = dt.hour > 12 ? dt.hour - 12 : (dt.hour == 0 ? 12 : dt.hour);
    final ampm = dt.hour >= 12 ? 'PM' : 'AM';
    return '${months[dt.month - 1]} ${dt.day}, ${dt.year} at ${pad(hour)}:${pad(dt.minute)} $ampm';
  }

  Future<void> _loadData() async {
    final sections = context.read<AuthService>().currentUser?.sections ?? [];
    setState(() {
      _teacherSections = sections;
      _loading = true;
    });

    try {
      final db = FirebaseFirestore.instance;

      // 1. Fetch real students
      final studentsSnap = await db
          .collection('users')
          .where('role', whereIn: [UserRole.grade9.id, UserRole.grade10.id])
          .where('status', isEqualTo: VerificationStatus.approved.id)
          .get();
          
      final users = studentsSnap.docs.map((d) => AppUser.fromMap(d.id, d.data())).toList();

      // 2. Fetch all quiz attempts
      final attemptsSnap = await db.collection('quiz_attempts').get();
      final allAttempts = attemptsSnap.docs.map((d) => QuizAttempt.fromMap(d.id, d.data())).toList();

      // 2.5 Fetch all courses to check for missed quizzes
      final coursesSnap = await db.collection('courses').get();
      final allCourses = coursesSnap.docs.map((d) => Course.fromMap(d.id, d.data())).toList();

      // 3. Fetch AR experiments to map IDs to titles (with fallback if permission denied)
      List<ArExperimentModel> arExps = [];
      try {
        final arSnap = await db.collection('ar_experiments').get();
        arExps = arSnap.docs.map((d) => ArExperimentModel.fromMap(d.id, d.data())).toList();
      } catch (e) {
        print('Using fallback AR experiments due to error: $e');
        arExps = dummyArExperiments;
      }
      final arExpMap = { for (var e in arExps) e.id : e.title };

      // 4. Build StudentProgress objects
      List<StudentProgress> dynamicStudents = [];
      for (var u in users) {
         // get quiz results for u.id
         final uAttempts = allAttempts.where((a) => a.studentId == u.id).toList();
         final quizResults = uAttempts.map((a) => QuizResult(
           quizTitle: a.quizTitle,
           score: a.score,
           total: a.totalQuestions,
           date: _formatDate(a.submittedAt),
         )).toList();

         // get AR records for u.id
         List<ArLabRecord> uArRecords = [];
         try {
           final uArSnap = await db.collection('users').doc(u.id).collection('experiment_activity').get();
           uArRecords = uArSnap.docs.map((d) {
             final expId = d.id;
             final act = ExperimentActivity.fromMap(expId, d.data());
             return ArLabRecord(
               experimentName: arExpMap[expId] ?? 'Unknown Experiment',
               attempts: 1, 
               rubricScore: act.completed ? 100.0 : 0.0,
               lastAttemptDate: _formatDate(act.completedAt ?? act.launchedAt),
             );
           }).toList();
         } catch (e) {
           print('Permission denied or error fetching AR records for ${u.id}: $e');
         }

         final section = u.sections.isNotEmpty ? u.sections.first : 'No Section';

         List<MissedQuiz> uMissedQuizzes = [];
         for (var course in allCourses) {
           if (course.sections.contains(section)) {
             for (var quiz in course.quizzes) {
               final hasAttempted = uAttempts.any((a) => a.quizId == quiz.id);
               if (!hasAttempted && quiz.dueDate != null && quiz.dueDate!.isBefore(DateTime.now())) {
                 uMissedQuizzes.add(MissedQuiz(
                   quizTitle: quiz.title,
                   courseTitle: course.title,
                   dueDate: _formatDate(quiz.dueDate),
                 ));
               }
             }
           }
         }

         dynamicStudents.add(StudentProgress(
           name: u.name,
           section: section,
           quizResults: quizResults,
           missedQuizzes: uMissedQuizzes,
           arLabRecords: uArRecords,
           studentNumber: u.studentNumber,
         ));
      }

      setState(() {
        _allStudents = dynamicStudents;
        _loading = false;
      });
    } catch (e) {
      print('Error loading dynamic progress: $e');
      setState(() { _loading = false; });
    }
  }

  List<String> get _sectionOptions {
    final opts = <String>['All Sections'];
    opts.addAll(
      _teacherSections.isNotEmpty
          ? _teacherSections
          : ['9-Rizal', '9-Bonifacio', '10-Luna'],
    );
    return opts;
  }

  List<StudentProgress> get _filteredStudents {
    List<StudentProgress> students;
    if (_selectedSection == 'All Sections') {
      students = _allStudents;
    } else {
      students = _allStudents
          .where((s) => s.section == _selectedSection)
          .toList();
    }
    if (_searchQuery.isNotEmpty) {
      final q = _searchQuery.toLowerCase();
      students = students
          .where(
            (s) => s.name.toLowerCase().contains(q) || 
                   (s.studentNumber ?? '').toLowerCase().contains(q),
          )
          .toList();
    }
    return students;
  }

  Color _scoreColor(double score) {
    if (score >= 90) return const Color(0xFF00FF88);
    if (score >= 75) return const Color(0xFF00D4FF);
    if (score >= 60) return const Color(0xFFFFB800);
    return const Color(0xFFFF4757);
  }

  String _scoreLabel(double score) {
    if (score >= 90) return 'Excellent';
    if (score >= 75) return 'Good';
    if (score >= 60) return 'Satisfactory';
    return 'Needs Improvement';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final cardColor = isDark ? const Color(0xFF142240) : Colors.white;
    final borderColor = isDark ? const Color(0xFF1E3A5F) : Colors.grey.shade200;
    final subTextColor = isDark
        ? const Color(0xFF8BA3C0)
        : Colors.grey.shade600;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        bottom: false,
        child: _loading
            ? const Center(
                child: CircularProgressIndicator(color: Color(0xFF00D4FF)),
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Header ──────────────────────────────────────────────
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                    child: Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: Theme.of(context).brightness == Brightness.dark ? const Color(0xFF1A2E1A) : const Color(0xFFE8F5E9),
                            borderRadius: BorderRadius.circular(12.0),
                            border: Border.all(color: Theme.of(context).brightness == Brightness.dark ? const Color(0x3300FF88) : const Color(0xFF00FF88).withOpacity(0.3), width: 1),
                          ),
                          child: Center(
                            child: CustomIconWidget(
                              iconName: 'insights',
                              color: Color(0xFF00FF88),
                              size: 20,
                            ),
                          ),
                        ),
                        SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Student Progress',
                                style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.w700,
                                  color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black87,
                                ),
                              ),
                              Text(
                                'Teacher Dashboard',
                                style: TextStyle(fontSize: 12, color: Color(0xFF00FF88)),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: Theme.of(context).brightness == Brightness.dark ? const Color(0x2200FF88) : const Color(0xFF00FF88).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(50.0),
                            border: Border.all(color: Theme.of(context).brightness == Brightness.dark ? const Color(0x5500FF88) : const Color(0xFF00FF88).withOpacity(0.3), width: 1),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              CustomIconWidget(
                                iconName: 'verified',
                                color: Color(0xFF00FF88),
                                size: 13,
                              ),
                              SizedBox(width: 4),
                              Text(
                                'Teacher',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF00FF88),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // ── Section Dropdown ─────────────────────────────────────
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: cardColor,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: borderColor),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: _selectedSection,
                          isExpanded: true,
                          dropdownColor: isDark
                              ? const Color(0xFF142240)
                              : Colors.white,
                          icon: const CustomIconWidget(
                            iconName: 'keyboard_arrow_down',
                            color: Color(0xFF00D4FF),
                            size: 20,
                          ),
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                          items: _sectionOptions.map((s) {
                            return DropdownMenuItem(
                              value: s,
                              child: Row(
                                children: [
                                  CustomIconWidget(
                                    iconName: s == 'All Sections'
                                        ? 'groups'
                                        : 'class_',
                                    color: const Color(0xFF00D4FF),
                                    size: 16,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(s),
                                ],
                              ),
                            );
                          }).toList(),
                          onChanged: (val) {
                            if (val != null) {
                              setState(() => _selectedSection = val);
                            }
                          },
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 14),

                  // ── Search Bar ───────────────────────────────────────────
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Container(
                      decoration: BoxDecoration(
                        color: cardColor,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: borderColor),
                      ),
                      child: TextField(
                        controller: _searchController,
                        onChanged: (val) => setState(() => _searchQuery = val),
                        style: theme.textTheme.bodyMedium,
                        decoration: InputDecoration(
                          hintText: 'Search student by name...',
                          hintStyle: theme.textTheme.bodyMedium?.copyWith(
                            color: subTextColor,
                          ),
                          prefixIcon: const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 12),
                            child: CustomIconWidget(
                              iconName: 'search',
                              color: Color(0xFF00D4FF),
                              size: 20,
                            ),
                          ),
                          prefixIconConstraints: const BoxConstraints(
                            minWidth: 44,
                            minHeight: 44,
                          ),
                          suffixIcon: _searchQuery.isNotEmpty
                              ? GestureDetector(
                                  onTap: () {
                                    _searchController.clear();
                                    setState(() => _searchQuery = '');
                                  },
                                  child: const Padding(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 12,
                                    ),
                                    child: CustomIconWidget(
                                      iconName: 'close',
                                      color: Color(0xFF8BA3C0),
                                      size: 18,
                                    ),
                                  ),
                                )
                              : null,
                          suffixIconConstraints: const BoxConstraints(
                            minWidth: 44,
                            minHeight: 44,
                          ),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 12,
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 14),

                  // ── Tab Bar ──────────────────────────────────────────────
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Container(
                      height: 40,
                      decoration: BoxDecoration(
                        color: isDark
                            ? const Color(0xFF0D1F3C)
                            : Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: TabBar(
                        controller: _tabController,
                        indicator: BoxDecoration(
                          color: const Color(0xFF00D4FF),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        indicatorSize: TabBarIndicatorSize.tab,
                        labelColor: const Color(0xFF0A1628),
                        unselectedLabelColor: subTextColor,
                        labelStyle: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                        unselectedLabelStyle: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                        dividerColor: Colors.transparent,
                        tabs: const [
                          Tab(text: 'Quiz Results'),
                          Tab(text: 'AR Lab Records'),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  // ── Tab Views ────────────────────────────────────────────
                  Expanded(
                    child: TabBarView(
                      controller: _tabController,
                      children: [
                        _QuizResultsTab(
                          students: _filteredStudents,
                          cardColor: cardColor,
                          borderColor: borderColor,
                          subTextColor: subTextColor,
                          scoreColor: _scoreColor,
                          isDark: isDark,
                          theme: theme,
                        ),
                        _ArLabTab(
                          students: _filteredStudents,
                          cardColor: cardColor,
                          borderColor: borderColor,
                          subTextColor: subTextColor,
                          scoreColor: _scoreColor,
                          scoreLabel: _scoreLabel,
                          isDark: isDark,
                          theme: theme,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

// ── Quiz Results Tab ──────────────────────────────────────────────────────────

class _QuizResultsTab extends StatelessWidget {
  final List<StudentProgress> students;
  final Color cardColor;
  final Color borderColor;
  final Color subTextColor;
  final Color Function(double) scoreColor;
  final bool isDark;
  final ThemeData theme;

  const _QuizResultsTab({
    required this.students,
    required this.cardColor,
    required this.borderColor,
    required this.subTextColor,
    required this.scoreColor,
    required this.isDark,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    if (students.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CustomIconWidget(
              iconName: 'quiz',
              color: isDark ? const Color(0xFF8BA3C0) : Colors.grey.shade400,
              size: 48,
            ),
            const SizedBox(height: 12),
            Text(
              'No students in this section',
              style: theme.textTheme.bodyMedium?.copyWith(color: subTextColor),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
      itemCount: students.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, i) {
        final student = students[i];
        final displayedQuizzes = student.quizResults.take(3).toList();
        final hasMore = student.quizResults.length > 3;

        return GestureDetector(
          onTap: () => _showQuizDialog(context, student),
          child: Container(
            decoration: BoxDecoration(
              color: cardColor,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: borderColor),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Student header
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
                  child: Row(
                    children: [
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0x2200D4FF) : const Color(0xFF00D4FF).withOpacity(0.1),
                          shape: BoxShape.circle,
                          border: Border.all(color: isDark ? const Color(0x5500D4FF) : const Color(0xFF00D4FF).withOpacity(0.3)),
                        ),
                        child: Center(
                          child: Text(
                            student.name.isNotEmpty ? student.name[0] : '?',
                            style: const TextStyle(
                              color: Color(0xFF00D4FF),
                              fontWeight: FontWeight.w700,
                              fontSize: 15,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              student.name,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                            if (student.studentNumber != null && student.studentNumber!.isNotEmpty)
                              Text(
                                '#${student.studentNumber}',
                                style: theme.textTheme.labelSmall?.copyWith(
                                  color: isDark ? const Color(0xFF00D4FF) : const Color(0xFF00A0D4),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            Text(
                              student.section,
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: subTextColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: isDark ? const Color(0x22FFB800) : const Color(0xFFFFB800).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: isDark ? const Color(0x55FFB800) : const Color(0xFFFFB800).withOpacity(0.3)),
                            ),
                            child: Text(
                              '${student.quizResults.length} Quiz${student.quizResults.length != 1 ? 'zes' : ''}',
                              style: const TextStyle(
                                color: Color(0xFFFFB800),
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          if (student.missedQuizzes.isNotEmpty) ...[
                            const SizedBox(height: 4),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 3,
                              ),
                              decoration: BoxDecoration(
                                color: isDark ? const Color(0x22FF4757) : const Color(0xFFFF4757).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: isDark ? const Color(0x55FF4757) : const Color(0xFFFF4757).withOpacity(0.3)),
                              ),
                              child: Text(
                                '${student.missedQuizzes.length} Missed',
                                style: const TextStyle(
                                  color: Color(0xFFFF4757),
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showQuizDialog(BuildContext context, StudentProgress student) {
    if (student.quizResults.isEmpty && student.missedQuizzes.isEmpty) return;
    showDialog(
      context: context,
      builder: (context) {
        final scrollController = ScrollController();
        int currentPage = 0;
        const int itemsPerPage = 6;
        final allItems = [
          ...student.quizResults,
          ...student.missedQuizzes,
        ];
        final totalItems = allItems.length;

        return StatefulBuilder(
          builder: (context, setState) {
            final startIndex = currentPage * itemsPerPage;
            final endIndex = (startIndex + itemsPerPage < totalItems) ? startIndex + itemsPerPage : totalItems;
            final currentItems = allItems.sublist(startIndex, endIndex);

            return Dialog(
              backgroundColor: cardColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: BorderSide(color: borderColor),
              ),
              insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 48),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            '${student.name}\'s Quizzes',
                            style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        IconButton(
                          icon: Icon(Icons.close, color: subTextColor),
                          onPressed: () => Navigator.pop(context),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                      ],
                    ),
                  ),
                  Divider(height: 1, color: borderColor),
                  Flexible(
                    child: RawScrollbar(
                      controller: scrollController,
                      thumbColor: Colors.white.withOpacity(0.8),
                      radius: const Radius.circular(4),
                      thickness: 4,
                      thumbVisibility: true,
                      child: ListView.separated(
                        controller: scrollController,
                        shrinkWrap: true,
                        padding: const EdgeInsets.all(16),
                        itemCount: currentItems.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          final item = currentItems[index];
                          if (item is QuizResult) {
                            return _QuizResultRow(
                              quiz: item,
                              subTextColor: subTextColor,
                              scoreColor: scoreColor,
                              isDark: isDark,
                              theme: theme,
                              borderColor: borderColor,
                            );
                          } else if (item is MissedQuiz) {
                            return _MissedQuizRow(
                              quiz: item,
                              subTextColor: subTextColor,
                              isDark: isDark,
                              theme: theme,
                            );
                          }
                          return const SizedBox();
                        },
                      ),
                    ),
                  ),
                  if (totalItems > itemsPerPage) ...[
                    Divider(height: 1, color: borderColor),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Visibility(
                            visible: currentPage > 0,
                            maintainSize: true,
                            maintainAnimation: true,
                            maintainState: true,
                            child: TextButton(
                              onPressed: () => setState(() {
                                currentPage--;
                                scrollController.jumpTo(0);
                              }),
                              child: Text('Previous', style: TextStyle(color: subTextColor)),
                            ),
                          ),
                          Text(
                            'Page ${currentPage + 1} of ${(totalItems / itemsPerPage).ceil()}',
                            style: TextStyle(color: subTextColor, fontSize: 12),
                          ),
                          Visibility(
                            visible: endIndex < totalItems,
                            maintainSize: true,
                            maintainAnimation: true,
                            maintainState: true,
                            child: TextButton(
                              onPressed: () => setState(() {
                                currentPage++;
                                scrollController.jumpTo(0);
                              }),
                              child: Text('Next', style: TextStyle(color: isDark ? const Color(0xFF00FF88) : Colors.green)),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            );
          },
        );
      },
    );
  }
}

class _QuizResultRow extends StatelessWidget {
  final QuizResult quiz;
  final Color subTextColor;
  final Color Function(double) scoreColor;
  final bool isDark;
  final ThemeData theme;
  final Color borderColor;

  const _QuizResultRow({
    required this.quiz,
    required this.subTextColor,
    required this.scoreColor,
    required this.isDark,
    required this.theme,
    required this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    final pct = quiz.percentage;
    final color = scoreColor(pct * 100);

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  quiz.quizTitle,
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 2,
                ),
                const SizedBox(height: 3),
                Text(
                  quiz.date,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: subTextColor,
                  ),
                ),
                const SizedBox(height: 6),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: pct,
                    backgroundColor: isDark
                        ? const Color(0xFF1E3A5F)
                        : Colors.grey.shade200,
                    valueColor: AlwaysStoppedAnimation<Color>(color),
                    minHeight: 5,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 14),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                'Score: ${quiz.score}/${quiz.total}',
                style: theme.textTheme.titleMedium?.copyWith(
                  color: color,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text(
                '${(pct * 100).toStringAsFixed(0)}%',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: subTextColor,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── AR Lab Tab ────────────────────────────────────────────────────────────────

class _ArLabTab extends StatelessWidget {
  final List<StudentProgress> students;
  final Color cardColor;
  final Color borderColor;
  final Color subTextColor;
  final Color Function(double) scoreColor;
  final String Function(double) scoreLabel;
  final bool isDark;
  final ThemeData theme;

  const _ArLabTab({
    required this.students,
    required this.cardColor,
    required this.borderColor,
    required this.subTextColor,
    required this.scoreColor,
    required this.scoreLabel,
    required this.isDark,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    if (students.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CustomIconWidget(
              iconName: 'view_in_ar',
              color: isDark ? const Color(0xFF8BA3C0) : Colors.grey.shade400,
              size: 48,
            ),
            const SizedBox(height: 12),
            Text(
              'No students in this section',
              style: theme.textTheme.bodyMedium?.copyWith(color: subTextColor),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
      itemCount: students.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, i) {
        final student = students[i];
        final displayedRecords = student.arLabRecords.take(3).toList();
        final hasMore = student.arLabRecords.length > 3;

        return GestureDetector(
          onTap: () => _showArLabDialog(context, student),
          child: Container(
            decoration: BoxDecoration(
              color: cardColor,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: borderColor),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Student header
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
                  child: Row(
                    children: [
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0x2200FF88) : const Color(0xFF00FF88).withOpacity(0.1),
                          shape: BoxShape.circle,
                          border: Border.all(color: isDark ? const Color(0x5500FF88) : const Color(0xFF00FF88).withOpacity(0.3)),
                        ),
                        child: Center(
                          child: Text(
                            student.name.isNotEmpty ? student.name[0] : '?',
                            style: const TextStyle(
                              color: Color(0xFF00FF88),
                              fontWeight: FontWeight.w700,
                              fontSize: 15,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              student.name,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                            if (student.studentNumber != null && student.studentNumber!.isNotEmpty)
                              Text(
                                '#${student.studentNumber}',
                                style: theme.textTheme.labelSmall?.copyWith(
                                  color: isDark ? const Color(0xFF00FF88) : const Color(0xFF00A050),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            Text(
                              student.section,
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: subTextColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0x2200FF88) : const Color(0xFF00FF88).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: isDark ? const Color(0x5500FF88) : const Color(0xFF00FF88).withOpacity(0.3)),
                        ),
                        child: Text(
                          '${student.arLabRecords.length} Experiment${student.arLabRecords.length != 1 ? 's' : ''}',
                          style: const TextStyle(
                            color: Color(0xFF00FF88),
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showArLabDialog(BuildContext context, StudentProgress student) {
    if (student.arLabRecords.isEmpty) return;
    showDialog(
      context: context,
      builder: (context) {
        final scrollController = ScrollController();
        int currentPage = 0;
        const int itemsPerPage = 6;
        final totalItems = student.arLabRecords.length;

        return StatefulBuilder(
          builder: (context, setState) {
            final startIndex = currentPage * itemsPerPage;
            final endIndex = (startIndex + itemsPerPage < totalItems) ? startIndex + itemsPerPage : totalItems;
            final currentItems = student.arLabRecords.sublist(startIndex, endIndex);

            return Dialog(
              backgroundColor: cardColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: BorderSide(color: borderColor),
              ),
              insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 48),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            '${student.name}\'s Records',
                            style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        IconButton(
                          icon: Icon(Icons.close, color: subTextColor),
                          onPressed: () => Navigator.pop(context),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                      ],
                    ),
                  ),
                  Divider(height: 1, color: borderColor),
                  Flexible(
                    child: RawScrollbar(
                      controller: scrollController,
                      thumbColor: Colors.white.withOpacity(0.8),
                      radius: const Radius.circular(4),
                      thickness: 4,
                      thumbVisibility: true,
                      child: ListView.separated(
                        controller: scrollController,
                        shrinkWrap: true,
                        padding: const EdgeInsets.all(16),
                        itemCount: currentItems.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          return _ArLabRecordRow(
                            record: currentItems[index],
                            subTextColor: subTextColor,
                            scoreColor: scoreColor,
                            scoreLabel: scoreLabel,
                            isDark: isDark,
                            theme: theme,
                            borderColor: borderColor,
                          );
                        },
                      ),
                    ),
                  ),
                  if (totalItems > itemsPerPage) ...[
                    Divider(height: 1, color: borderColor),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Visibility(
                            visible: currentPage > 0,
                            maintainSize: true,
                            maintainAnimation: true,
                            maintainState: true,
                            child: TextButton(
                              onPressed: () => setState(() {
                                currentPage--;
                                scrollController.jumpTo(0);
                              }),
                              child: Text('Previous', style: TextStyle(color: subTextColor)),
                            ),
                          ),
                          Text(
                            'Page ${currentPage + 1} of ${(totalItems / itemsPerPage).ceil()}',
                            style: TextStyle(color: subTextColor, fontSize: 12),
                          ),
                          Visibility(
                            visible: endIndex < totalItems,
                            maintainSize: true,
                            maintainAnimation: true,
                            maintainState: true,
                            child: TextButton(
                              onPressed: () => setState(() {
                                currentPage++;
                                scrollController.jumpTo(0);
                              }),
                              child: Text('Next', style: TextStyle(color: isDark ? const Color(0xFF00FF88) : Colors.green)),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            );
          },
        );
      },
    );
  }
}

class _ArLabRecordRow extends StatelessWidget {
  final ArLabRecord record;
  final Color subTextColor;
  final Color Function(double) scoreColor;
  final String Function(double) scoreLabel;
  final bool isDark;
  final ThemeData theme;
  final Color borderColor;

  const _ArLabRecordRow({
    required this.record,
    required this.subTextColor,
    required this.scoreColor,
    required this.scoreLabel,
    required this.isDark,
    required this.theme,
    required this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    final color = scoreColor(record.rubricScore);
    final label = scoreLabel(record.rubricScore);

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0x2200D4FF) : const Color(0xFF00D4FF).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const CustomIconWidget(
                  iconName: 'view_in_ar',
                  color: Color(0xFF00D4FF),
                  size: 14,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  record.experimentName,
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              // Rubric score badge
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: color.withAlpha(40),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: color.withAlpha(100)),
                ),
                child: Text(
                  record.rubricScore.toStringAsFixed(1),
                  style: TextStyle(
                    color: color,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              // Attempts chip
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: isDark
                      ? const Color(0xFF1E3A5F)
                      : Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CustomIconWidget(
                      iconName: 'replay',
                      color: subTextColor,
                      size: 12,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${record.attempts} attempt${record.attempts != 1 ? 's' : ''}',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: subTextColor,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              // Score label chip
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: color.withAlpha(30),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  label,
                  style: TextStyle(
                    color: color,
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  record.lastAttemptDate,
                  textAlign: TextAlign.right,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: subTextColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          // Rubric score bar
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: record.rubricScore / 100,
              backgroundColor: isDark
                  ? const Color(0xFF1E3A5F)
                  : Colors.grey.shade200,
              valueColor: AlwaysStoppedAnimation<Color>(color),
              minHeight: 5,
            ),
          ),
        ],
      ),
    );
  }
}



class _MissedQuizRow extends StatelessWidget {
  final MissedQuiz quiz;
  final Color subTextColor;
  final bool isDark;
  final ThemeData theme;

  const _MissedQuizRow({
    required this.quiz,
    required this.subTextColor,
    required this.isDark,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  quiz.quizTitle,
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 2,
                ),
                const SizedBox(height: 3),
                Text(
                  quiz.courseTitle,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: subTextColor,
                  ),
                ),
                if (quiz.dueDate.isNotEmpty) ...[
                  const SizedBox(height: 3),
                  Text(
                    'Due: ${quiz.dueDate}',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: const Color(0xFFFF4757),
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 14),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Missed',
                style: theme.textTheme.titleMedium?.copyWith(
                  color: const Color(0xFFFF4757),
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(width: 6),
              const CustomIconWidget(
                iconName: 'warning',
                color: Color(0xFFFF4757),
                size: 20,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
