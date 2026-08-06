import '../../../core/app_export.dart';
import '../teacher_courses_screen.dart';
import './teacher_modules_manager_widget.dart';
import './teacher_quiz_manager_widget.dart';

class TeacherCourseDetailWidget extends StatefulWidget {
  final TeacherCourse course;
  final VoidCallback onBack;
  final VoidCallback onUpdated;

  const TeacherCourseDetailWidget({
    required this.course,
    required this.onBack,
    required this.onUpdated,
    super.key,
  });

  @override
  State<TeacherCourseDetailWidget> createState() =>
      _TeacherCourseDetailWidgetState();
}

class _TeacherCourseDetailWidgetState extends State<TeacherCourseDetailWidget>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _refresh() {
    setState(() {});
    widget.onUpdated();
  }

  @override
  Widget build(BuildContext context) {
    final course = widget.course;
    return Column(
      children: [
        // ── Header ──────────────────────────────────────────────────────────
        Container(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  GestureDetector(
                    onTap: widget.onBack,
                    child: Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        color: const Color(0xFF142240),
                        borderRadius: BorderRadius.circular(12.0),
                        border: Border.all(
                          color: const Color(0xFF1E3A5F),
                          width: 1,
                        ),
                      ),
                      child: const Center(
                        child: CustomIconWidget(
                          iconName: 'arrow_back',
                          color: Color(0xFF8BA3C0),
                          size: 18,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      course.title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  _MetaBadge(
                    icon: 'school',
                    label: course.grade,
                    color: course.accentColor,
                  ),
                  const SizedBox(width: 8),
                  _MetaBadge(
                    icon: 'people',
                    label: '${course.studentCount} students',
                    color: const Color(0xFF8BA3C0),
                  ),
                ],
              ),
              const SizedBox(height: 14),
            ],
          ),
        ),
        // ── Tab bar ──────────────────────────────────────────────────────────
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: const Color(0xFF0F1E35),
            borderRadius: BorderRadius.circular(14.0),
          ),
          child: TabBar(
            controller: _tabController,
            indicator: BoxDecoration(
              color: course.accentColor.withAlpha(30),
              borderRadius: BorderRadius.circular(12.0),
              border: Border.all(
                color: course.accentColor.withAlpha(80),
                width: 1,
              ),
            ),
            indicatorSize: TabBarIndicatorSize.tab,
            dividerColor: Colors.transparent,
            labelColor: course.accentColor,
            unselectedLabelColor: const Color(0xFF8BA3C0),
            labelStyle: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
            unselectedLabelStyle: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
            tabs: [
              Tab(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const CustomIconWidget(
                      iconName: 'quiz',
                      color: Colors.white,
                      size: 16,
                    ),
                    const SizedBox(width: 6),
                    Text('Quizzes (${course.quizzes.length})'),
                  ],
                ),
              ),
              Tab(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const CustomIconWidget(
                      iconName: 'folder_open',
                      color: Colors.white,
                      size: 16,
                    ),
                    const SizedBox(width: 6),
                    Text('Modules (${course.modules.length})'),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 4),
        // ── Tab views ────────────────────────────────────────────────────────
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              TeacherQuizManagerWidget(course: course, onUpdated: _refresh),
              TeacherModulesManagerWidget(course: course, onUpdated: _refresh),
            ],
          ),
        ),
      ],
    );
  }
}

class _MetaBadge extends StatelessWidget {
  final String icon;
  final String label;
  final Color color;

  const _MetaBadge({
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        CustomIconWidget(iconName: icon, color: color, size: 13),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: color,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
