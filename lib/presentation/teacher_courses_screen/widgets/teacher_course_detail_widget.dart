import '../../../core/app_export.dart';
import '../../../models/course_model.dart';
import '../../../services/course_service.dart';
import '../../../services/auth_service.dart';
import 'package:provider/provider.dart';
import '../teacher_courses_screen.dart';
import './teacher_modules_manager_widget.dart';
import './teacher_quiz_manager_widget.dart';

class CourseDetailWidget extends StatefulWidget {
  final Course course;
  final VoidCallback onBack;
  final VoidCallback onUpdated;

  const CourseDetailWidget({
    required this.course,
    required this.onBack,
    required this.onUpdated,
    super.key,
  });

  @override
  State<CourseDetailWidget> createState() =>
      _CourseDetailWidgetState();
}

class _CourseDetailWidgetState extends State<CourseDetailWidget>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  Future<int>? _studentCountFuture;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _studentCountFuture = context.read<AuthService>().countStudentsInSections(widget.course.sections);
  }

  @override
  void didUpdateWidget(covariant CourseDetailWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.course.sections != oldWidget.course.sections) {
      _studentCountFuture = context.read<AuthService>().countStudentsInSections(widget.course.sections);
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _refresh() {
    setState(() {});
    widget.onUpdated();
      context.read<CourseService>().updateCourse(widget.course);
  }

  @override
  Widget build(BuildContext context) {
    final course = widget.course;
    final isLight = Theme.of(context).brightness == Brightness.light;
    final accentColor = (isLight && course.accentColor == const Color(0xFF00D4FF))
        ? const Color(0xFF1565C0)
        : course.accentColor;

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
                        color: Theme.of(context).brightness == Brightness.dark ? const Color(0xFF142240) : Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(12.0),
                        border: Border.all(
                          color: Theme.of(context).brightness == Brightness.dark ? const Color(0xFF1E3A5F) : Colors.grey.shade300,
                          width: 1,
                        ),
                      ),
                      child: Center(
                        child: CustomIconWidget(
                          iconName: 'arrow_back',
                          color: Theme.of(context).brightness == Brightness.dark ? const Color(0xFF8BA3C0) : Colors.grey.shade700,
                          size: 18,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      course.title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black87,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _MetaBadge(
                    icon: 'school',
                    label: course.grade,
                    color: accentColor,
                  ),
                  FutureBuilder<int>(
                    future: _studentCountFuture,
                    builder: (context, snapshot) {
                      final count = snapshot.data ?? 0;
                      return _MetaBadge(
                        icon: 'people',
                        label: '$count students',
                        color: const Color(0xFF8BA3C0),
                      );
                    }
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
            color: Theme.of(context).brightness == Brightness.dark ? const Color(0xFF0F1E35) : Colors.grey.shade100,
            borderRadius: BorderRadius.circular(14.0),
            border: Border.all(color: Theme.of(context).brightness == Brightness.dark ? Colors.transparent : Colors.grey.shade300),
          ),
          child: TabBar(
            controller: _tabController,
            indicator: BoxDecoration(
              color: Theme.of(context).brightness == Brightness.dark ? accentColor.withAlpha(30) : accentColor.withAlpha(50),
              borderRadius: BorderRadius.circular(12.0),
              border: Border.all(
                color: accentColor.withAlpha(80),
                width: 1,
              ),
            ),
            indicatorSize: TabBarIndicatorSize.tab,
            dividerColor: Colors.transparent,
            labelColor: accentColor,
            unselectedLabelColor: Theme.of(context).brightness == Brightness.dark ? const Color(0xFF8BA3C0) : Colors.grey.shade600,
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
                    CustomIconWidget(
                      iconName: 'quiz',
                      color: accentColor,
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
                    CustomIconWidget(
                      iconName: 'folder_open',
                      color: accentColor,
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
              CourseQuizManagerWidget(course: course, onUpdated: _refresh),
              CourseModulesManagerWidget(course: course, onUpdated: _refresh),
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
