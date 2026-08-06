import 'package:shared_preferences/shared_preferences.dart';

import '../../core/app_export.dart';

// ── Data models ───────────────────────────────────────────────────────────────

class StudentProgress {
  final String name;
  final String section;
  final List<QuizResult> quizResults;
  final List<ArLabRecord> arLabRecords;

  const StudentProgress({
    required this.name,
    required this.section,
    required this.quizResults,
    required this.arLabRecords,
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

// ── Mock data ─────────────────────────────────────────────────────────────────

List<StudentProgress> _buildMockData(List<String> sections) {
  final sectionList = sections.isNotEmpty
      ? sections
      : ['9-Rizal', '9-Bonifacio', '10-Luna'];

  return [
    StudentProgress(
      name: 'Maria Santos',
      section: sectionList[0],
      quizResults: const [
        QuizResult(
          quizTitle: 'Quiz 1: Carbon Bonding',
          score: 9,
          total: 10,
          date: 'Jul 15, 2025',
        ),
        QuizResult(
          quizTitle: 'Quiz 2: Periodic Trends',
          score: 7,
          total: 10,
          date: 'Jul 22, 2025',
        ),
      ],
      arLabRecords: const [
        ArLabRecord(
          experimentName: 'Acid-Base Titration',
          attempts: 3,
          rubricScore: 88.0,
          lastAttemptDate: 'Jul 20, 2025',
        ),
        ArLabRecord(
          experimentName: 'Molecular Bonding',
          attempts: 2,
          rubricScore: 92.0,
          lastAttemptDate: 'Jul 24, 2025',
        ),
      ],
    ),
    StudentProgress(
      name: 'Juan dela Cruz',
      section: sectionList[0],
      quizResults: const [
        QuizResult(
          quizTitle: 'Quiz 1: Carbon Bonding',
          score: 6,
          total: 10,
          date: 'Jul 15, 2025',
        ),
        QuizResult(
          quizTitle: 'Quiz 2: Periodic Trends',
          score: 8,
          total: 10,
          date: 'Jul 22, 2025',
        ),
      ],
      arLabRecords: const [
        ArLabRecord(
          experimentName: 'Acid-Base Titration',
          attempts: 5,
          rubricScore: 74.0,
          lastAttemptDate: 'Jul 21, 2025',
        ),
        ArLabRecord(
          experimentName: 'Molecular Bonding',
          attempts: 1,
          rubricScore: 80.0,
          lastAttemptDate: 'Jul 25, 2025',
        ),
      ],
    ),
    StudentProgress(
      name: 'Ana Reyes',
      section: sectionList.length > 1 ? sectionList[1] : sectionList[0],
      quizResults: const [
        QuizResult(
          quizTitle: 'Quiz 1: Carbon Bonding',
          score: 10,
          total: 10,
          date: 'Jul 15, 2025',
        ),
      ],
      arLabRecords: const [
        ArLabRecord(
          experimentName: 'Acid-Base Titration',
          attempts: 2,
          rubricScore: 95.0,
          lastAttemptDate: 'Jul 19, 2025',
        ),
        ArLabRecord(
          experimentName: 'Photosynthesis AR',
          attempts: 4,
          rubricScore: 87.5,
          lastAttemptDate: 'Jul 26, 2025',
        ),
      ],
    ),
    StudentProgress(
      name: 'Carlos Mendoza',
      section: sectionList.length > 1 ? sectionList[1] : sectionList[0],
      quizResults: const [
        QuizResult(
          quizTitle: 'Quiz 1: Carbon Bonding',
          score: 5,
          total: 10,
          date: 'Jul 15, 2025',
        ),
        QuizResult(
          quizTitle: 'Quiz 2: Periodic Trends',
          score: 4,
          total: 10,
          date: 'Jul 22, 2025',
        ),
      ],
      arLabRecords: const [
        ArLabRecord(
          experimentName: 'Molecular Bonding',
          attempts: 6,
          rubricScore: 65.0,
          lastAttemptDate: 'Jul 23, 2025',
        ),
      ],
    ),
    StudentProgress(
      name: 'Liza Flores',
      section: sectionList.length > 2 ? sectionList[2] : sectionList[0],
      quizResults: const [
        QuizResult(
          quizTitle: 'Quiz 2: Periodic Trends',
          score: 9,
          total: 10,
          date: 'Jul 22, 2025',
        ),
      ],
      arLabRecords: const [
        ArLabRecord(
          experimentName: 'Acid-Base Titration',
          attempts: 1,
          rubricScore: 90.0,
          lastAttemptDate: 'Jul 18, 2025',
        ),
        ArLabRecord(
          experimentName: 'Photosynthesis AR',
          attempts: 3,
          rubricScore: 83.0,
          lastAttemptDate: 'Jul 27, 2025',
        ),
      ],
    ),
    StudentProgress(
      name: 'Ramon Villanueva',
      section: sectionList.length > 2 ? sectionList[2] : sectionList[0],
      quizResults: const [
        QuizResult(
          quizTitle: 'Quiz 1: Carbon Bonding',
          score: 7,
          total: 10,
          date: 'Jul 15, 2025',
        ),
        QuizResult(
          quizTitle: 'Quiz 2: Periodic Trends',
          score: 6,
          total: 10,
          date: 'Jul 22, 2025',
        ),
      ],
      arLabRecords: const [
        ArLabRecord(
          experimentName: 'Molecular Bonding',
          attempts: 2,
          rubricScore: 78.0,
          lastAttemptDate: 'Jul 24, 2025',
        ),
        ArLabRecord(
          experimentName: 'Photosynthesis AR',
          attempts: 2,
          rubricScore: 82.0,
          lastAttemptDate: 'Jul 26, 2025',
        ),
      ],
    ),
  ];
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

  Future<void> _loadData() async {
    final prefs = await SharedPreferences.getInstance();
    final sections = prefs.getStringList('teacher_sections') ?? [];
    setState(() {
      _teacherSections = sections;
      _allStudents = _buildMockData(sections);
      _loading = false;
    });
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
      students = students
          .where(
            (s) => s.name.toLowerCase().contains(_searchQuery.toLowerCase()),
          )
          .toList();
    }
    return students;
  }

  Color _scoreColor(double score) {
    if (score >= 90) { return const Color(0xFF00FF88); }
    if (score >= 75) { return const Color(0xFF00D4FF); }
    if (score >= 60) { return const Color(0xFFFFB800); }
    return const Color(0xFFFF4757);
  }

  String _scoreLabel(double score) {
    if (score >= 90) { return 'Excellent'; }
    if (score >= 75) { return 'Good'; }
    if (score >= 60) { return 'Satisfactory'; }
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
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Student Progress',
                                style: theme.textTheme.headlineMedium?.copyWith(
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'Monitor quiz results & AR lab performance',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: subTextColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Summary badge
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0x2200D4FF),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: const Color(0x5500D4FF)),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const CustomIconWidget(
                                iconName: 'group',
                                color: Color(0xFF00D4FF),
                                size: 14,
                              ),
                              const SizedBox(width: 5),
                              Text(
                                '${_filteredStudents.length} Students',
                                style: theme.textTheme.labelSmall?.copyWith(
                                  color: const Color(0xFF00D4FF),
                                  fontWeight: FontWeight.w600,
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
            const CustomIconWidget(
              iconName: 'quiz',
              color: Color(0xFF8BA3C0),
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
        return Container(
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
                        color: const Color(0x2200D4FF),
                        shape: BoxShape.circle,
                        border: Border.all(color: const Color(0x5500D4FF)),
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
                        color: const Color(0x22FFB800),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: const Color(0x55FFB800)),
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
                  ],
                ),
              ),
              Divider(height: 1, color: borderColor),
              if (student.quizResults.isEmpty)
                Padding(
                  padding: const EdgeInsets.all(14),
                  child: Text(
                    'No quiz results yet.',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: subTextColor,
                    ),
                  ),
                )
              else
                ...student.quizResults.map(
                  (q) => _QuizResultRow(
                    quiz: q,
                    subTextColor: subTextColor,
                    scoreColor: scoreColor,
                    isDark: isDark,
                    theme: theme,
                    borderColor: borderColor,
                  ),
                ),
            ],
          ),
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
                '${quiz.score}/${quiz.total}',
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
            const CustomIconWidget(
              iconName: 'view_in_ar',
              color: Color(0xFF8BA3C0),
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
        return Container(
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
                        color: const Color(0x2200FF88),
                        shape: BoxShape.circle,
                        border: Border.all(color: const Color(0x5500FF88)),
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
                        color: const Color(0x2200FF88),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: const Color(0x5500FF88)),
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
              Divider(height: 1, color: borderColor),
              if (student.arLabRecords.isEmpty)
                Padding(
                  padding: const EdgeInsets.all(14),
                  child: Text(
                    'No AR lab records yet.',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: subTextColor,
                    ),
                  ),
                )
              else
                ...student.arLabRecords.map(
                  (r) => _ArLabRecordRow(
                    record: r,
                    subTextColor: subTextColor,
                    scoreColor: scoreColor,
                    scoreLabel: scoreLabel,
                    isDark: isDark,
                    theme: theme,
                    borderColor: borderColor,
                  ),
                ),
            ],
          ),
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
                  color: const Color(0x2200D4FF),
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
              const Spacer(),
              Text(
                record.lastAttemptDate,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: subTextColor,
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

