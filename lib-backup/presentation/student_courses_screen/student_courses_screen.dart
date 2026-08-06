import 'dart:async';
import 'package:provider/provider.dart';
import '../../core/app_export.dart';
import '../../models/course_model.dart';
import '../../models/user_model.dart';
import '../../services/auth_service.dart';
import '../../services/course_service.dart';
import './widgets/course_detail_widget.dart';

// ── Screen ────────────────────────────────────────────────────────────────────

class StudentCoursesScreen extends StatefulWidget {
  const StudentCoursesScreen({super.key});

  @override
  State<StudentCoursesScreen> createState() => _StudentCoursesScreenState();
}

class _StudentCoursesScreenState extends State<StudentCoursesScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _entranceController;
  Course? _selectedCourse;
  final CourseService _courseService = CourseService();
  List<Course> _allFetchedCourses = [];
  bool _loading = true;
  String? _errorMessage;
  StreamSubscription<List<Course>>? _coursesSub;

  @override
  void initState() {
    super.initState();
    _entranceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    )..forward();

    _coursesSub = _courseService.coursesStream().listen((all) async {
      if (!mounted) { return; }

      debugPrint('DEBUG: Fetched ${all.length} total courses from Firestore');

      final user = AuthService.instance.currentUser;
      final studentId = user?.id;
      if (studentId != null) {
        final attempts = await _courseService.fetchAttemptsForStudent(studentId);
        final completedQuizIdsByCourse = <String, Set<String>>{};
        for (final a in attempts) {
          completedQuizIdsByCourse.putIfAbsent(a.courseId, () => {}).add(a.quizId);
        }
        for (final course in all) {
          final totalQuizzes = course.quizzes.length;
          final completed = completedQuizIdsByCourse[course.id]?.length ?? 0;
          course.progress = totalQuizzes == 0 ? 0.0 : completed / totalQuizzes;
        }
      }

      if (!mounted) { return; }
      setState(() {
        _allFetchedCourses = all;
        _loading = false;
        _errorMessage = null;
      });
    }, onError: (e) {
      debugPrint('Firestore Error in StudentCoursesScreen: $e');
      if (mounted) {
        setState(() {
          _loading = false;
          _errorMessage = e.toString().contains('permission-denied')
              ? 'Permission Denied: Please check your Firestore security rules.'
              : 'Failed to load courses. Please try again later.';
        });
      }
    });
  }

  @override
  void dispose() {
    _entranceController.dispose();
    _coursesSub?.cancel();
    super.dispose();
  }

  void _openCourse(Course course) {
    setState(() => _selectedCourse = course);
  }

  void _closeCourse() {
    setState(() => _selectedCourse = null);
  }

  void _onQuizSubmitted(String quizId, String quizTitle, int score, int total) {
    final studentId = AuthService.instance.currentUser?.id;
    if (studentId == null || _selectedCourse == null) { return; }
    _courseService.submitAttempt(
      QuizAttempt(
        id: '',
        courseId: _selectedCourse!.id,
        quizId: quizId,
        quizTitle: quizTitle,
        studentId: studentId,
        selectedAnswers: const [],
        score: score,
        totalQuestions: total,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthService>(
      builder: (context, auth, _) {
        final myGrade = auth.currentUser?.role?.label;
        
        debugPrint('DEBUG: Current User Grade: "$myGrade"');

        final filteredCourses = myGrade == null
            ? _allFetchedCourses
            : _allFetchedCourses.where((c) {
              final match = c.grade.trim().toLowerCase() ==
                  myGrade.trim().toLowerCase();
              debugPrint('DEBUG: Filtering Course "${c.title}" with grade "${c.grade}" -> Match: $match');
              return match;
            }).toList();

        return Scaffold(
          backgroundColor: const Color(0xFF0A1628),
          body: SafeArea(
            bottom: false,
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : _selectedCourse != null
                    ? CourseDetailWidget(
                        course: _selectedCourse!,
                        onBack: _closeCourse,
                        onQuizSubmitted: _onQuizSubmitted,
                      )
                    : _buildCourseList(filteredCourses),
          ),
        );
      },
    );
  }

  Widget _buildCourseList(List<Course> courses) {
    if (_errorMessage != null) {
      return Column(
        children: [
          _buildHeader(),
          const Spacer(),
          EmptyStateWidget(
            iconName: 'error_outline',
            title: 'Database Error',
            subtitle: _errorMessage!,
          ),
          const Spacer(flex: 2),
        ],
      );
    }
    if (courses.isEmpty) {
      return Column(
        children: [
          _buildHeader(),
          const Spacer(),
          const EmptyStateWidget(
            iconName: 'library_books',
            title: 'No courses found',
            subtitle:
                'You haven\'t enrolled in any courses for your grade level yet.',
          ),
          const Spacer(flex: 2),
        ],
      );
    }
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(child: _buildHeader()),
        SliverToBoxAdapter(child: _buildSubtitle(courses.length)),
        SliverList(
          delegate: SliverChildBuilderDelegate((context, index) {
            final course = courses[index];
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
          }, childCount: courses.length),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: 100)),
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
              color: const Color(0xFF0D2E3F),
              borderRadius: BorderRadius.circular(12.0),
              border: Border.all(color: const Color(0x3300D4FF), width: 1),
            ),
            child: const Center(
              child: CustomIconWidget(
                iconName: 'menu_book',
                color: Color(0xFF00D4FF),
                size: 20,
              ),
            ),
          ),
          const SizedBox(width: 12),
          const Text(
            'My Courses',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubtitle(int count) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 20),
      child: Text(
        '$count enrolled courses',
        style: const TextStyle(fontSize: 13, color: Color(0xFF8BA3C0)),
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
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF142240),
          borderRadius: BorderRadius.circular(20.0),
          border: Border.all(color: course.accentColor.withAlpha(40), width: 1),
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
                    color: course.accentColor.withAlpha(25),
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                  child: Center(
                    child: CustomIconWidget(
                      iconName: course.iconName,
                      color: course.accentColor,
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
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${course.teacher} · ${course.grade}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF8BA3C0),
                        ),
                      ),
                    ],
                  ),
                ),
                const CustomIconWidget(
                  iconName: 'chevron_right',
                  color: Color(0xFF8BA3C0),
                  size: 20,
                ),
              ],
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                _InfoChip(
                  icon: 'quiz',
                  label: '${course.quizzes.length} Quizzes',
                  color: const Color(0xFFFFB800),
                ),
                const SizedBox(width: 8),
                _InfoChip(
                  icon: 'folder_open',
                  label: '${course.modules.length} Modules',
                  color: course.accentColor,
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
                      value: course.progress,
                      backgroundColor: const Color(0xFF1E3A5F),
                      valueColor: AlwaysStoppedAnimation<Color>(
                        course.accentColor,
                      ),
                      minHeight: 5,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  '${(course.progress * 100).toInt()}%',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: course.accentColor,
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
