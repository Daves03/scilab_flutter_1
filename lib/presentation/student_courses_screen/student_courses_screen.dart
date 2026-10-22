import '../../core/app_export.dart';
import '../../core/course_assignment.dart';
import './widgets/course_detail_widget.dart';
import 'package:provider/provider.dart';
import '../../models/course_model.dart';
import '../../models/user_model.dart';
import '../../models/student_course_destination.dart';
import '../../services/auth_service.dart';
import '../../services/course_service.dart';

// ── Screen ────────────────────────────────────────────────────────────────────

class StudentCoursesScreen extends StatefulWidget {
  final StudentCourseDestination? initialDestination;
  const StudentCoursesScreen({this.initialDestination, super.key});

  @override
  State<StudentCoursesScreen> createState() => _StudentCoursesScreenState();
}

class _StudentCoursesScreenState extends State<StudentCoursesScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _entranceController;
  String? _selectedCourseId;
  String? _targetQuizId;
  int _initialTabIndex = 0;
  String _mainSearchQuery = '';
  final TextEditingController _mainSearchCtrl = TextEditingController();
  final FocusNode _mainSearchFocusNode = FocusNode();
  Stream<List<Course>>? _coursesStream;
  String? _coursesStreamKey;

  @override
  void initState() {
    super.initState();
    final student = context.read<AuthService>().currentUser;
    final destination = widget.initialDestination;
    if (destination != null &&
        student != null &&
        CourseAssignment.courseMatchesStudent(destination.course, student)) {
      _selectedCourseId = destination.course.id;
      _targetQuizId = destination.quizId;
      _initialTabIndex = destination.initialTabIndex.clamp(0, 1);
    }
    _entranceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    )..forward();
  }

  @override
  void didUpdateWidget(covariant StudentCoursesScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    final oldDestination = oldWidget.initialDestination;
    final destination = widget.initialDestination;
    if (oldDestination?.course.id == destination?.course.id &&
        oldDestination?.quizId == destination?.quizId &&
        oldDestination?.initialTabIndex == destination?.initialTabIndex) {
      return;
    }

    final student = context.read<AuthService>().currentUser;
    final initialCourse = destination?.course;
    _selectedCourseId =
        initialCourse != null &&
            student != null &&
            CourseAssignment.courseMatchesStudent(initialCourse, student)
        ? initialCourse.id
        : null;
    _targetQuizId = _selectedCourseId == null ? null : destination?.quizId;
    _initialTabIndex = _selectedCourseId == null
        ? 0
        : (destination?.initialTabIndex ?? 0).clamp(0, 1);
  }

  @override
  void dispose() {
    _mainSearchCtrl.dispose();
    _mainSearchFocusNode.dispose();
    _entranceController.dispose();
    super.dispose();
  }

  Stream<List<Course>> _courseStreamFor(AppUser? student) {
    final sortedSections = student == null
        ? const <String>[]
        : (List<String>.from(student.sections)..sort());
    final streamKey = student == null
        ? 'signed-out'
        : '${student.id}|${student.role?.id}|${sortedSections.join(',')}';
    if (_coursesStream == null || _coursesStreamKey != streamKey) {
      _coursesStreamKey = streamKey;
      _coursesStream = student == null
          ? Stream.value(const <Course>[])
          : context.read<CourseService>().coursesForStudentStream(student);
    }
    return _coursesStream!;
  }

  void _openCourse(Course course) {
    setState(() => _selectedCourseId = course.id);
  }

  void _closeCourse() {
    setState(() {
      _selectedCourseId = null;
      _targetQuizId = null;
      _initialTabIndex = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    final student = context.watch<AuthService>().currentUser;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        bottom: false,
        child: StreamBuilder<List<Course>>(
          stream: _courseStreamFor(student),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting &&
                !snapshot.hasData) {
              return const Center(
                child: CircularProgressIndicator(color: Color(0xFF00D4FF)),
              );
            }
            if (snapshot.hasError) {
              return const Center(
                child: Text(
                  'Failed to load courses. Please check permissions.',
                  style: TextStyle(color: Colors.red),
                ),
              );
            }

            final courses = snapshot.data ?? const <Course>[];
            Course? selectedCourse;
            final selectedCourseId = _selectedCourseId;
            if (selectedCourseId != null) {
              for (final course in courses) {
                if (course.id == selectedCourseId) {
                  selectedCourse = course;
                  break;
                }
              }
            }

            if (selectedCourse != null &&
                student != null &&
                CourseAssignment.courseMatchesStudent(
                  selectedCourse,
                  student,
                )) {
              return CourseDetailWidget(
                key: ValueKey(
                  'student-course-${selectedCourse.id}-${_targetQuizId ?? 'overview'}-$_initialTabIndex',
                ),
                course: selectedCourse,
                onBack: _closeCourse,
                initialTabIndex: _initialTabIndex,
                initialQuizId: _targetQuizId,
              );
            }

            return _buildCourseList(courses);
          },
        ),
      ),
    );
  }

  Widget _buildCourseList(List<Course> courses) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final accentColor = isDark
        ? const Color(0xFF00D4FF)
        : const Color(0xFF1565C0);
    final filteredCourses = courses.where((c) {
      final query = _mainSearchQuery.trim().toLowerCase();
      return c.title.toLowerCase().contains(query) ||
          c.teacher.toLowerCase().contains(query) ||
          c.subject.toLowerCase().contains(query) ||
          c.grade.toLowerCase().contains(query);
    }).toList();

    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(child: _buildHeader()),
        SliverToBoxAdapter(child: _buildSubtitle(courses)),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
            child: SizedBox(
              height: 52,
              child: TextField(
                controller: _mainSearchCtrl,
                focusNode: _mainSearchFocusNode,
                cursorColor: accentColor,
                textInputAction: TextInputAction.search,
                onTapOutside: (_) => _mainSearchFocusNode.unfocus(),
                style: TextStyle(
                  color: isDark ? Colors.white : const Color(0xFF172033),
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
                textAlignVertical: TextAlignVertical.center,
                decoration: InputDecoration(
                  hintText: 'Search courses...',
                  hintStyle: TextStyle(
                    color: isDark
                        ? const Color(0xFF8BA3C0)
                        : const Color(0xFF75859A),
                    fontSize: 14,
                  ),
                  filled: true,
                  fillColor: isDark
                      ? const Color(0xFF142240)
                      : const Color(0xFFF7FAFD),
                  prefixIcon: Icon(
                    Icons.search_rounded,
                    color: isDark
                        ? const Color(0xFF8BA3C0)
                        : const Color(0xFF60758D),
                    size: 21,
                  ),
                  suffixIcon: _mainSearchQuery.isNotEmpty
                      ? IconButton(
                          tooltip: 'Clear search',
                          onPressed: () {
                            _mainSearchCtrl.clear();
                            setState(() => _mainSearchQuery = '');
                            _mainSearchFocusNode.requestFocus();
                          },
                          icon: Icon(
                            Icons.close_rounded,
                            color: isDark
                                ? const Color(0xFF8BA3C0)
                                : const Color(0xFF60758D),
                            size: 19,
                          ),
                        )
                      : null,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 15,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide.none,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide(
                      color: isDark
                          ? const Color(0xFF244363)
                          : const Color(0xFFD5E0EB),
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide(color: accentColor, width: 1.5),
                  ),
                ),
                onChanged: (val) {
                  setState(() => _mainSearchQuery = val);
                },
              ),
            ),
          ),
        ),
        filteredCourses.isEmpty
            ? SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.only(top: 40),
                  child: Center(
                    child: Text(
                      courses.isEmpty
                          ? 'No courses are assigned to your grade and section yet.'
                          : 'No courses found matching your search.',
                      style: TextStyle(
                        color: Theme.of(context).brightness == Brightness.dark
                            ? const Color(0xFF8BA3C0)
                            : Colors.grey.shade600,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
              )
            : SliverList(
                delegate: SliverChildBuilderDelegate((context, index) {
                  final course = filteredCourses[index];
                  final delay = index * 80;
                  return AnimatedBuilder(
                    animation: _entranceController,
                    builder: (context, child) {
                      final slide =
                          Tween<Offset>(
                            begin: const Offset(0, 0.12),
                            end: Offset.zero,
                          ).animate(
                            CurvedAnimation(
                              parent: _entranceController,
                              curve: Interval(
                                (delay / 500).clamp(0.0, 0.8),
                                ((delay + 300) / 500).clamp(0.0, 1.0),
                                curve: Curves.easeOutCubic,
                              ),
                            ),
                          );
                      return SlideTransition(
                        position: slide,
                        child: FadeTransition(
                          opacity: _entranceController,
                          child: child,
                        ),
                      );
                    },
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 14),
                      child: _CourseListCard(
                        course: course,
                        onTap: () => _openCourse(course),
                      ),
                    ),
                  );
                }, childCount: filteredCourses.length),
              ),
        const SliverToBoxAdapter(child: SizedBox(height: 140)),
      ],
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 4),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Theme.of(context).brightness == Brightness.dark
                  ? const Color(0xFF0D2E3F)
                  : const Color(0xFFE8F9FD),
              borderRadius: BorderRadius.circular(12.0),
              border: Border.all(
                color: Theme.of(context).brightness == Brightness.dark
                    ? const Color(0x3300D4FF)
                    : const Color(0xFF1565C0).withValues(alpha: 0.3),
                width: 1,
              ),
            ),
            child: Center(
              child: CustomIconWidget(
                iconName: 'menu_book',
                color: Theme.of(context).brightness == Brightness.dark
                    ? const Color(0xFF00D4FF)
                    : const Color(0xFF1565C0),
                size: 20,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'My Courses',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Colors.white
                        : Colors.black87,
                  ),
                ),
                Text(
                  'Student Dashboard',
                  style: TextStyle(
                    fontSize: 12,
                    color: Theme.of(context).brightness == Brightness.dark
                        ? const Color(0xFF00FF88)
                        : const Color(0xFF00994C),
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: Theme.of(context).brightness == Brightness.dark
                  ? const Color(0x2200D4FF)
                  : const Color(0xFF1565C0).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(50.0),
              border: Border.all(
                color: Theme.of(context).brightness == Brightness.dark
                    ? const Color(0x5500D4FF)
                    : const Color(0xFF1565C0).withValues(alpha: 0.2),
                width: 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                CustomIconWidget(
                  iconName: 'school',
                  color: Theme.of(context).brightness == Brightness.dark
                      ? const Color(0xFF00D4FF)
                      : const Color(0xFF1565C0),
                  size: 13,
                ),
                const SizedBox(width: 4),
                Text(
                  'Student',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).brightness == Brightness.dark
                        ? const Color(0xFF00D4FF)
                        : const Color(0xFF1565C0),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubtitle(List<Course> courses) {
    final courseLabel = courses.length == 1 ? 'course' : 'courses';
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 20),
      child: Text(
        '${courses.length} enrolled $courseLabel',
        style: TextStyle(
          fontSize: 13,
          color: Theme.of(context).brightness == Brightness.dark
              ? const Color(0xFF8BA3C0)
              : Colors.grey.shade600,
        ),
      ),
    );
  }
}

// ── Course list card ──────────────────────────────────────────────────────────

class _CourseListCard extends StatelessWidget {
  final Course course;
  final VoidCallback onTap;

  const _CourseListCard({required this.course, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final effectiveAccentColor = course.accentColor == const Color(0xFF00D4FF)
        ? (Theme.of(context).brightness == Brightness.dark
              ? const Color(0xFF00D4FF)
              : const Color(0xFF1565C0))
        : course.accentColor;
    final progress = course.progress.clamp(0.0, 1.0).toDouble();
    final student = context.read<AuthService>().currentUser;
    final sections = student == null
        ? const <String>[]
        : CourseAssignment.matchingSectionsForStudent(course, student);
    final sectionSummary = sections.isEmpty
        ? 'No section assigned'
        : sections.length == 1
        ? 'Section ${sections.first}'
        : 'Sections ${sections.join(', ')}';

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).brightness == Brightness.dark
              ? const Color(0xFF142240)
              : Colors.white,
          borderRadius: BorderRadius.circular(20.0),
          border: Border.all(
            color: Theme.of(context).brightness == Brightness.dark
                ? effectiveAccentColor.withAlpha(40)
                : Colors.grey.shade300,
            width: 1,
          ),
        ),
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: effectiveAccentColor.withAlpha(
                      Theme.of(context).brightness == Brightness.dark ? 25 : 40,
                    ),
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                  child: Center(
                    child: CustomIconWidget(
                      iconName: course.iconName,
                      color: effectiveAccentColor,
                      size: 22,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        course.title,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: Theme.of(context).brightness == Brightness.dark
                              ? Colors.white
                              : Colors.black87,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${course.teacherName} · ${course.grade} · $sectionSummary',
                        style: TextStyle(
                          fontSize: 12,
                          color: Theme.of(context).brightness == Brightness.dark
                              ? const Color(0xFF8BA3C0)
                              : Colors.grey.shade700,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                CustomIconWidget(
                  iconName: 'chevron_right',
                  color: Theme.of(context).brightness == Brightness.dark
                      ? const Color(0xFF8BA3C0)
                      : Colors.grey.shade600,
                  size: 20,
                ),
              ],
            ),
            const SizedBox(height: 14),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _InfoChip(
                  icon: 'quiz',
                  label: '${course.quizzes.length} Quizzes',
                  color: const Color(0xFFFFB800),
                ),
                _InfoChip(
                  icon: 'folder_open',
                  label: '${course.modules.length} Modules',
                  color: effectiveAccentColor,
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(4.0),
                    child: LinearProgressIndicator(
                      value: progress,
                      backgroundColor:
                          Theme.of(context).brightness == Brightness.dark
                          ? const Color(0xFF1E3A5F)
                          : Colors.grey.shade200,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        effectiveAccentColor,
                      ),
                      minHeight: 5,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  '${(progress * 100).round()}%',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: effectiveAccentColor,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final String icon;
  final String label;
  final Color color;

  const _InfoChip({
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withAlpha(20),
        borderRadius: BorderRadius.circular(50.0),
        border: Border.all(color: color.withAlpha(50), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          CustomIconWidget(iconName: icon, color: color, size: 13),
          const SizedBox(width: 5),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
