import '../../../core/app_export.dart';
import '../../../models/course_model.dart';
import './modules_section_widget.dart';
import './quiz_section_widget.dart';

class CourseDetailWidget extends StatefulWidget {
  final Course course;
  final VoidCallback onBack;

  const CourseDetailWidget({
    required this.course,
    required this.onBack,
    super.key,
  });

  @override
  State<CourseDetailWidget> createState() => _CourseDetailWidgetState();
}

class _CourseDetailWidgetState extends State<CourseDetailWidget>
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
                        color: Theme.of(context).brightness == Brightness.dark ? const Color(0xFF142240) : Colors.white,
                        borderRadius: BorderRadius.circular(12.0),
                        border: Border.all(
                          color: Theme.of(context).brightness == Brightness.dark ? const Color(0xFF1E3A5F) : Colors.grey.shade300,
                          width: 1,
                        ),
                      ),
                      child: Center(
                        child: CustomIconWidget(
                          iconName: 'arrow_back',
                          color: Theme.of(context).brightness == Brightness.dark ? const Color(0xFF8BA3C0) : Colors.grey.shade600,
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
              const SizedBox(height: 12),
              // Course info row
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _MetaBadge(
                    icon: 'person',
                    label: course.teacherName,
                    color: course.accentColor,
                  ),
                  _MetaBadge(
                    icon: 'school',
                    label: course.grade,
                    color: Theme.of(context).brightness == Brightness.dark ? const Color(0xFF8BA3C0) : Colors.grey.shade600,
                  ),
                ],
              ),
              const SizedBox(height: 12),
              // Progress bar
              Row(
                children: [
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(4.0),
                      child: LinearProgressIndicator(
                        value: 0.0,
                        backgroundColor: Theme.of(context).brightness == Brightness.dark ? const Color(0xFF1E3A5F) : Colors.grey.shade200,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          course.accentColor,
                        ),
                        minHeight: 6,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    '${(0.0 * 100).toInt()}% complete',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: course.accentColor,
                    ),
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
            unselectedLabelColor: Theme.of(context).brightness == Brightness.dark ? const Color(0xFF8BA3C0) : Colors.grey.shade600,
            labelStyle: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
            unselectedLabelStyle: TextStyle(
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
                      color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.grey.shade800,
                      size: 16,
                    ),
                    SizedBox(width: 6),
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
                      color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.grey.shade800,
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
              QuizSectionWidget(course: course),
              ModulesSectionWidget(course: course),
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
