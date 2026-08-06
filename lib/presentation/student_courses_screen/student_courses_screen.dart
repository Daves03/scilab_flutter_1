import '../../core/app_export.dart';
import './widgets/course_detail_widget.dart';
import 'package:provider/provider.dart';
import '../../models/course_model.dart';
import '../../services/course_service.dart';

// ── Screen ────────────────────────────────────────────────────────────────────

class StudentCoursesScreen extends StatefulWidget {
  final Course? initialCourse;
  const StudentCoursesScreen({this.initialCourse, super.key});

  @override
  State<StudentCoursesScreen> createState() => _StudentCoursesScreenState();
}

class _StudentCoursesScreenState extends State<StudentCoursesScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _entranceController;
  Course? _selectedCourse;
  String _mainSearchQuery = '';
  final TextEditingController _mainSearchCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.initialCourse != null) _selectedCourse = widget.initialCourse;
    _entranceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    )..forward();
  }

  @override
  void dispose() {
    _mainSearchCtrl.dispose();
    _entranceController.dispose();
    super.dispose();
  }

  void _openCourse(Course course) {
    setState(() => _selectedCourse = course);
  }

  void _closeCourse() {
    setState(() => _selectedCourse = null);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        bottom: false,
        child: _selectedCourse != null
            ? CourseDetailWidget(course: _selectedCourse!, onBack: _closeCourse)
            : StreamBuilder<List<Course>>(
                stream: context.read<CourseService>().coursesStream(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator(color: Color(0xFF00D4FF)));
                  }
                  if (snapshot.hasError) {
                    return Center(
                      child: Text('Failed to load courses. Please check permissions.', style: TextStyle(color: Colors.red)),
                    );
                  }
                  final courses = snapshot.data ?? [];
                  return _buildCourseList(courses);
                },
              ),
      ),
    );
  }

  Widget _buildCourseList(List<Course> courses) {
    final filteredCourses = courses.where((c) {
      final query = _mainSearchQuery.toLowerCase();
      return c.title.toLowerCase().contains(query) || 
             c.teacher.toLowerCase().contains(query) ||
             c.subject.toLowerCase().contains(query) ||
             c.grade.toLowerCase().contains(query);
    }).toList();

    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(child: _buildHeader(courses)),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
            child: Container(
              height: 48,
              decoration: BoxDecoration(
                color: Theme.of(context).brightness == Brightness.dark ? const Color(0xFF142240) : Colors.white,
                borderRadius: BorderRadius.circular(12.0),
                border: Border.all(color: Theme.of(context).brightness == Brightness.dark ? const Color(0x3300FF88) : Colors.grey.shade300, width: 1),
              ),
              child: TextField(
                controller: _mainSearchCtrl,
                style: TextStyle(color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black87, fontSize: 14),
                textAlignVertical: TextAlignVertical.center,
                decoration: InputDecoration(
                  hintText: 'Search courses...',
                  hintStyle: TextStyle(color: Theme.of(context).brightness == Brightness.dark ? const Color(0xFF8BA3C0) : Colors.black38),
                  prefixIcon: Icon(Icons.search, color: Theme.of(context).brightness == Brightness.dark ? const Color(0xFF8BA3C0) : Colors.grey.shade600, size: 20),
                  isDense: true,
                  suffixIcon: _mainSearchQuery.isNotEmpty
                      ? GestureDetector(
                          onTap: () {
                            _mainSearchCtrl.clear();
                            setState(() => _mainSearchQuery = '');
                          },
                          child: Icon(Icons.close, color: Theme.of(context).brightness == Brightness.dark ? const Color(0xFF8BA3C0) : Colors.grey.shade600, size: 18),
                        )
                      : null,
                  border: InputBorder.none,
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
                      'No courses found matching search',
                      style: TextStyle(color: Theme.of(context).brightness == Brightness.dark ? const Color(0xFF8BA3C0) : Colors.grey.shade600, fontSize: 14),
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
        const SliverToBoxAdapter(child: SizedBox(height: 100)),
      ],
    );
  }

  Widget _buildHeader(List<Course> courses) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Theme.of(context).brightness == Brightness.dark ? const Color(0xFF0D2E3F) : const Color(0xFFE8F9FD),
              borderRadius: BorderRadius.circular(12.0),
              border: Border.all(color: Theme.of(context).brightness == Brightness.dark ? const Color(0x3300D4FF) : const Color(0xFF00D4FF).withOpacity(0.3), width: 1),
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
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'My Courses',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black87,
                  ),
                ),
                Text(
                  '${courses.length} enrolled courses',
                  style: const TextStyle(fontSize: 12, color: Color(0xFF00D4FF)),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: const Color(0x2200D4FF),
              borderRadius: BorderRadius.circular(50.0),
              border: Border.all(color: const Color(0x5500D4FF), width: 1),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                CustomIconWidget(
                  iconName: 'school',
                  color: Color(0xFF00D4FF),
                  size: 13,
                ),
                SizedBox(width: 4),
                Text(
                  'Student',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF00D4FF),
                  ),
                ),
              ],
            ),
          ),
        ],
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
          color: Theme.of(context).brightness == Brightness.dark ? const Color(0xFF142240) : Colors.white,
          borderRadius: BorderRadius.circular(20.0),
          border: Border.all(color: Theme.of(context).brightness == Brightness.dark ? course.accentColor.withAlpha(40) : Colors.grey.shade300, width: 1),
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
                    color: course.accentColor.withAlpha(Theme.of(context).brightness == Brightness.dark ? 25 : 40),
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
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black87,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${course.teacherName} · ${course.grade}',
                        style: TextStyle(
                          fontSize: 12,
                          color: Theme.of(context).brightness == Brightness.dark ? const Color(0xFF8BA3C0) : Colors.grey.shade700,
                        ),
                      ),
                    ],
                  ),
                ),
                CustomIconWidget(
                  iconName: 'chevron_right',
                  color: Theme.of(context).brightness == Brightness.dark ? const Color(0xFF8BA3C0) : Colors.grey.shade600,
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
                      backgroundColor: Theme.of(context).brightness == Brightness.dark ? const Color(0xFF1E3A5F) : Colors.grey.shade200,
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
