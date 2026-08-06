import '../../core/app_export.dart';
import './widgets/teacher_course_detail_widget.dart';
import 'package:provider/provider.dart';
import '../../models/course_model.dart';
import '../../services/auth_service.dart';
import '../../services/course_service.dart';

// ── Screen ────────────────────────────────────────────────────────────────────

class TeacherCoursesScreen extends StatefulWidget {
  const TeacherCoursesScreen({super.key});

  @override
  State<TeacherCoursesScreen> createState() => _CoursesScreenState();
}

class _CoursesScreenState extends State<TeacherCoursesScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _entranceController;
  Course? _selectedCourse;
  String _mainSearchQuery = '';
  final TextEditingController _mainSearchCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
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

  void _onCourseUpdated() {
    setState(() {});
  }

  // ── CRUD Panel (bottom sheet) ──────────────────────────────────────────────

  void _openCrudPanel() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StreamBuilder<List<Course>>(
        stream: context.read<CourseService>().coursesForTeacherStream(context.read<AuthService>().currentUser!.id),
        builder: (context, snapshot) {
          final courses = snapshot.data ?? [];
          return _CoursesCrudPanel(onChanged: () => setState(() {}), courses: courses);
        }
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        bottom: false,
        child: Stack(
          children: [
            _selectedCourse != null
                ? CourseDetailWidget(
                    course: _selectedCourse!,
                    onBack: _closeCourse,
                    onUpdated: _onCourseUpdated,
                  )
                : StreamBuilder<List<Course>>(
                    stream: context.read<CourseService>().coursesForTeacherStream(context.read<AuthService>().currentUser!.id),
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
            if (_selectedCourse == null)
              Positioned(
                bottom: 116,
                right: 20,
                child: FloatingActionButton(
                  onPressed: _openCrudPanel,
                  backgroundColor: const Color(0xFF00FF88),
                  foregroundColor: const Color(0xFF0A1628),
                  tooltip: 'Manage Courses',
                  child: const Icon(Icons.edit, size: 26),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildCourseList(List<Course> courses) {
    final filteredCourses = courses.where((c) {
      final query = _mainSearchQuery.toLowerCase();
      return c.title.toLowerCase().contains(query) || 
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
            child: Container(
              height: 48,
              decoration: BoxDecoration(
                color: Theme.of(context).brightness == Brightness.dark ? const Color(0xFF142240) : Colors.white,
                borderRadius: BorderRadius.circular(12.0),
                border: Border.all(color: Theme.of(context).brightness == Brightness.dark ? const Color(0x3300FF88) : const Color(0xFF00FF88).withOpacity(0.3), width: 1),
              ),
              child: TextField(
                controller: _mainSearchCtrl,
                style: TextStyle(color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black87, fontSize: 14),
                textAlignVertical: TextAlignVertical.center,
                decoration: InputDecoration(
                  hintText: 'Search courses...',
                  hintStyle: TextStyle(color: Theme.of(context).brightness == Brightness.dark ? const Color(0xFF8BA3C0) : Colors.grey.shade600),
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
                child: _CourseCard(
                  course: course,
                  onTap: () => _openCourse(course),
                  onEdit: () => _showEditCourseDialog(course),
                  onDelete: () => _showDeleteCourseDialog(course),
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
              color: Theme.of(context).brightness == Brightness.dark ? const Color(0xFF1A2E1A) : const Color(0xFFE8F5E9),
              borderRadius: BorderRadius.circular(12.0),
              border: Border.all(color: Theme.of(context).brightness == Brightness.dark ? const Color(0x3300FF88) : const Color(0xFF00FF88).withOpacity(0.3), width: 1),
            ),
            child: Center(
              child: CustomIconWidget(
                iconName: 'menu_book',
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
                  'My Courses',
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
    );
  }

  Widget _buildSubtitle(List<Course> courses) {
    final totalStudents = courses.fold<int>(
      0,
      (sum, c) => sum + 0,
    );
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 20),
      child: Text(
        '${courses.length} courses · $totalStudents students enrolled',
        style: TextStyle(fontSize: 13, color: Theme.of(context).brightness == Brightness.dark ? const Color(0xFF8BA3C0) : Colors.grey.shade600),
      ),
    );
  }

  // ── Edit / Delete helpers (still used from card popup menu) ───────────────

  void _showEditCourseDialog(Course course) {
    final titleCtrl = TextEditingController(text: course.title);
    final subjectCtrl = TextEditingController(text: course.subject);
    final gradeCtrl = TextEditingController(text: course.grade);
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (ctx) => _CourseFormDialog(
        title: 'Edit Course',
        titleCtrl: titleCtrl,
        subjectCtrl: subjectCtrl,
        gradeCtrl: gradeCtrl,
        formKey: formKey,
        onSave: () async {
          if (formKey.currentState!.validate()) {
            final updatedCourse = Course(
              id: course.id,
              title: titleCtrl.text.trim(),
              subject: subjectCtrl.text.trim(),
              grade: gradeCtrl.text.trim(),
              teacherUid: course.teacherUid,
              teacherName: course.teacherName,
              accentColorValue: course.accentColorValue,
              iconName: course.iconName,
              modules: course.modules,
              quizzes: course.quizzes,
              createdAt: course.createdAt ?? DateTime.now(),
            );
            await context.read<CourseService>().updateCourse(updatedCourse);
            if (ctx.mounted) Navigator.of(ctx).pop();
          }
        },
      ),
    );
  }

  void _showDeleteCourseDialog(Course course) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Theme.of(context).brightness == Brightness.dark ? const Color(0xFF142240) : Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.0),
        ),
        title: Text(
          'Delete Course',
          style: TextStyle(color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black87, fontWeight: FontWeight.w700),
        ),
        content: Text(
          'Are you sure you want to delete "${course.title}"? This action cannot be undone.',
          style: TextStyle(color: Theme.of(context).brightness == Brightness.dark ? const Color(0xFF8BA3C0) : Colors.grey.shade600),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(
              'Cancel',
              style: TextStyle(color: Theme.of(context).brightness == Brightness.dark ? const Color(0xFF8BA3C0) : Colors.grey.shade600),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFF4757),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.0),
              ),
            ),
            onPressed: () async {
              await context.read<CourseService>().deleteCourse(course.id);
              if (ctx.mounted) Navigator.of(ctx).pop();
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}

// ── CRUD Panel (bottom sheet) ─────────────────────────────────────────────────

class _CoursesCrudPanel extends StatefulWidget {
  final VoidCallback onChanged;
  final List<Course> courses;

  const _CoursesCrudPanel({required this.onChanged, required this.courses});

  @override
  State<_CoursesCrudPanel> createState() => _CoursesCrudPanelState();
}

class _CoursesCrudPanelState extends State<_CoursesCrudPanel> {
  bool _isSelectMode = false;
  final Set<String> _selectedCourseIds = {};
  String _searchQuery = '';
  final TextEditingController _searchCtrl = TextEditingController();

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  void _refresh() {
    setState(() {});
    widget.onChanged();
  }

  void _showCreateDialog() {
    final titleCtrl = TextEditingController();
    final subjectCtrl = TextEditingController();
    final gradeCtrl = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (ctx) => _CourseFormDialog(
        title: 'Create New Course',
        titleCtrl: titleCtrl,
        subjectCtrl: subjectCtrl,
        gradeCtrl: gradeCtrl,
        formKey: formKey,
        onSave: () async {
          if (formKey.currentState!.validate()) {
            final user = context.read<AuthService>().currentUser!;
            final newCourse = Course(
              id: '',
              title: titleCtrl.text.trim(),
              subject: subjectCtrl.text.trim(),
              grade: gradeCtrl.text.trim(),
              teacherUid: user.id,
              teacherName: user.name,
              accentColorValue: 0xFF00D4FF,
              iconName: 'science',
              modules: [],
              quizzes: [],
              createdAt: DateTime.now(),
            );
            await context.read<CourseService>().createCourse(newCourse);
            if (ctx.mounted) Navigator.of(ctx).pop();
          }
        },
      ),
    );
  }

  void _showEditDialog(Course course) {
    final titleCtrl = TextEditingController(text: course.title);
    final subjectCtrl = TextEditingController(text: course.subject);
    final gradeCtrl = TextEditingController(text: course.grade);
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (ctx) => _CourseFormDialog(
        title: 'Edit Course',
        titleCtrl: titleCtrl,
        subjectCtrl: subjectCtrl,
        gradeCtrl: gradeCtrl,
        formKey: formKey,
        onSave: () async {
          if (formKey.currentState!.validate()) {
            final updatedCourse = Course(
              id: course.id,
              title: titleCtrl.text.trim(),
              subject: subjectCtrl.text.trim(),
              grade: gradeCtrl.text.trim(),
              teacherUid: course.teacherUid,
              teacherName: course.teacherName,
              accentColorValue: course.accentColorValue,
              iconName: course.iconName,
              modules: course.modules,
              quizzes: course.quizzes,
              createdAt: course.createdAt ?? DateTime.now(),
            );
            await context.read<CourseService>().updateCourse(updatedCourse);
            if (ctx.mounted) Navigator.of(ctx).pop();
          }
        },
      ),
    );
  }

  void _showDeleteConfirm(Course course) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Theme.of(context).brightness == Brightness.dark ? const Color(0xFF142240) : Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.0),
        ),
        title: Text(
          'Delete Course',
          style: TextStyle(color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black87, fontWeight: FontWeight.w700),
        ),
        content: Text(
          'Delete "${course.title}"? This cannot be undone.',
          style: TextStyle(color: Theme.of(context).brightness == Brightness.dark ? const Color(0xFF8BA3C0) : Colors.grey.shade600),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(
              'Cancel',
              style: TextStyle(color: Theme.of(context).brightness == Brightness.dark ? const Color(0xFF8BA3C0) : Colors.grey.shade600),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFF4757),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.0),
              ),
            ),
            onPressed: () async {
              await context.read<CourseService>().deleteCourse(course.id);
              if (ctx.mounted) Navigator.of(ctx).pop();
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _showMultiDeleteConfirm() {
    if (_selectedCourseIds.isEmpty) return;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Theme.of(context).brightness == Brightness.dark ? const Color(0xFF142240) : Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.0),
        ),
        title: Text(
          'Delete Courses',
          style: TextStyle(color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black87, fontWeight: FontWeight.w700),
        ),
        content: Text(
          'Delete ${_selectedCourseIds.length} selected course(s)? This cannot be undone.',
          style: TextStyle(color: Theme.of(context).brightness == Brightness.dark ? const Color(0xFF8BA3C0) : Colors.grey.shade600),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(
              'Cancel',
              style: TextStyle(color: Theme.of(context).brightness == Brightness.dark ? const Color(0xFF8BA3C0) : Colors.grey.shade600),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFF4757),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.0),
              ),
            ),
            onPressed: () async {
              for (final id in _selectedCourseIds) {
                await context.read<CourseService>().deleteCourse(id);
              }
              if (ctx.mounted) {
                setState(() {
                  _selectedCourseIds.clear();
                  _isSelectMode = false;
                });
                Navigator.of(ctx).pop();
              }
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).viewInsets.bottom;
    
    final filteredCourses = widget.courses.where((c) {
      final query = _searchQuery.toLowerCase();
      return c.title.toLowerCase().contains(query) || 
             c.subject.toLowerCase().contains(query) ||
             c.grade.toLowerCase().contains(query);
    }).toList();

    return Container(
      height: MediaQuery.of(context).size.height * 0.65,
      margin: const EdgeInsets.fromLTRB(12, 0, 12, 12),
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.dark ? const Color(0xFF142240) : Colors.white,
        borderRadius: BorderRadius.circular(24.0),
        border: Border.all(color: Theme.of(context).brightness == Brightness.dark ? const Color(0x3300FF88) : const Color(0xFF00FF88).withOpacity(0.3), width: 1),
      ),
      clipBehavior: Clip.hardEdge,
      child: Column(
        children: [
          // ── Handle ──────────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.only(top: 12, bottom: 4),
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Theme.of(context).brightness == Brightness.dark ? const Color(0xFF3A5070) : Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2.0),
              ),
            ),
          ),
          // ── Header ──────────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 16, 12),
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: Theme.of(context).brightness == Brightness.dark ? const Color(0x2200FF88) : const Color(0xFF00FF88).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  child: Center(
                    child: Icon(Icons.edit, color: Color(0xFF00FF88), size: 18),
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Manage Courses',
                        style: TextStyle(
                          color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black87,
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        'Create, edit or delete your courses',
                        style: TextStyle(
                          color: Theme.of(context).brightness == Brightness.dark ? const Color(0xFF8BA3C0) : Colors.grey.shade600,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                // Action buttons
                _isSelectMode
                    ? Row(
                        children: [
                          GestureDetector(
                            onTap: () => setState(() {
                              _isSelectMode = false;
                              _selectedCourseIds.clear();
                            }),
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              margin: const EdgeInsets.only(right: 8),
                              decoration: BoxDecoration(
                                color: const Color(0x22FF4757),
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                              child: const Icon(Icons.close, color: Color(0xFFFF4757), size: 16),
                            ),
                          ),
                          GestureDetector(
                            onTap: _showMultiDeleteConfirm,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                              decoration: BoxDecoration(
                                color: _selectedCourseIds.isEmpty ? const Color(0xFF3A5070) : const Color(0xFFFF4757),
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.delete_outline, color: Colors.white, size: 16),
                                  const SizedBox(width: 4),
                                  Text(
                                    'Delete (${_selectedCourseIds.length})',
                                    style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w700),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      )
                    : Row(
                        children: [
                          GestureDetector(
                            onTap: () => setState(() => _isSelectMode = true),
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              margin: const EdgeInsets.only(right: 8),
                              decoration: BoxDecoration(
                                color: const Color(0x2200D4FF),
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                              child: const Icon(Icons.checklist, color: Color(0xFF00D4FF), size: 16),
                            ),
                          ),
                          GestureDetector(
                            onTap: _showCreateDialog,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                              decoration: BoxDecoration(
                                color: const Color(0xFF00FF88),
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                              child: const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.add, color: Color(0xFF0A1628), size: 16),
                                  SizedBox(width: 4),
                                  Text(
                                    'New',
                                    style: TextStyle(color: Color(0xFF0A1628), fontSize: 12, fontWeight: FontWeight.w700),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
              ],
            ),
          ),
          // ── Search Bar ──────────────────────────────────────────────────
          if (widget.courses.isNotEmpty || _searchQuery.isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 12),
              child: Container(
                height: 40,
                decoration: BoxDecoration(
                  color: Theme.of(context).brightness == Brightness.dark ? const Color(0xFF0A1628) : Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(10.0),
                  border: Border.all(color: Theme.of(context).brightness == Brightness.dark ? const Color(0x2200FF88) : const Color(0xFF00FF88).withOpacity(0.2), width: 1),
                ),
                child: TextField(
                  controller: _searchCtrl,
                  style: TextStyle(color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black87, fontSize: 13),
                  textAlignVertical: TextAlignVertical.center,
                  decoration: InputDecoration(
                    hintText: 'Search courses...',
                    hintStyle: TextStyle(color: Theme.of(context).brightness == Brightness.dark ? const Color(0xFF3A5070) : Colors.grey.shade500),
                    prefixIcon: Icon(Icons.search, color: Theme.of(context).brightness == Brightness.dark ? const Color(0xFF3A5070) : Colors.grey.shade500, size: 18),
                    isDense: true,
                    suffixIcon: _searchQuery.isNotEmpty
                        ? GestureDetector(
                            onTap: () {
                              _searchCtrl.clear();
                              setState(() => _searchQuery = '');
                            },
                            child: Icon(Icons.close, color: Theme.of(context).brightness == Brightness.dark ? const Color(0xFF8BA3C0) : Colors.grey.shade600, size: 16),
                          )
                        : null,
                    border: InputBorder.none,
                  ),
                  onChanged: (val) {
                    setState(() => _searchQuery = val);
                  },
                ),
              ),
            ),
          // ── Divider ─────────────────────────────────────────────────────
          Divider(color: Theme.of(context).brightness == Brightness.dark ? const Color(0x220A1628) : Colors.grey.shade300, height: 1),
          // ── Course list ─────────────────────────────────────────────────
          Expanded(
            child: widget.courses.isEmpty
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.library_books_outlined,
                            color: Theme.of(context).brightness == Brightness.dark ? const Color(0xFF3A5070) : Colors.grey.shade400,
                            size: 48,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'No courses yet',
                            style: TextStyle(
                              color: Theme.of(context).brightness == Brightness.dark ? const Color(0xFF8BA3C0) : Colors.grey.shade600,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Tap "New Course" to create your first course',
                            style: TextStyle(
                              color: Theme.of(context).brightness == Brightness.dark ? const Color(0xFF3A5070) : Colors.grey.shade500,
                              fontSize: 12,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  )
                : filteredCourses.isEmpty
                    ? Center(
                        child: Text(
                          'No courses found matching search',
                          style: TextStyle(color: Theme.of(context).brightness == Brightness.dark ? const Color(0xFF8BA3C0) : Colors.grey.shade600, fontSize: 13),
                        ),
                      )
                    : ListView.separated(
                        padding: EdgeInsets.fromLTRB(16, 8, 16, bottomPadding + 120),
                        itemCount: filteredCourses.length,
                        separatorBuilder: (_, __) =>
                            const Divider(color: Color(0x150A1628), height: 1),
                        itemBuilder: (context, index) {
                          final course = filteredCourses[index];
                      final isSelected = _selectedCourseIds.contains(course.id);
                      return GestureDetector(
                        onTap: _isSelectMode
                            ? () {
                                setState(() {
                                  if (isSelected) {
                                    _selectedCourseIds.remove(course.id);
                                  } else {
                                    _selectedCourseIds.add(course.id);
                                  }
                                });
                              }
                            : null,
                        child: Container(
                          color: isSelected ? (Theme.of(context).brightness == Brightness.dark ? const Color(0x1100D4FF) : const Color(0xFF00D4FF).withOpacity(0.1)) : Colors.transparent,
                          child: _PanelCourseRow(
                            course: course,
                            isSelectMode: _isSelectMode,
                            isSelected: isSelected,
                            onEdit: () => _showEditDialog(course),
                            onDelete: () => _showDeleteConfirm(course),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

// ── Panel course row ──────────────────────────────────────────────────────────

class _PanelCourseRow extends StatelessWidget {
  final Course course;
  final bool isSelectMode;
  final bool isSelected;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _PanelCourseRow({
    required this.course,
    required this.isSelectMode,
    required this.isSelected,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          if (isSelectMode)
            Container(
              width: 18,
              height: 18,
              margin: const EdgeInsets.only(right: 12),
              decoration: BoxDecoration(
                color: isSelected ? const Color(0xFF00D4FF) : Colors.transparent,
                border: Border.all(color: isSelected ? const Color(0xFF00D4FF) : (Theme.of(context).brightness == Brightness.dark ? const Color(0xFF3A5070) : Colors.grey.shade400), width: 1.5),
                borderRadius: BorderRadius.circular(4.0),
              ),
              child: isSelected ? Icon(Icons.check, color: Theme.of(context).brightness == Brightness.dark ? const Color(0xFF142240) : Colors.white, size: 14) : null,
            ),
          if (!isSelectMode)
            Container(
              width: 10,
              height: 10,
              margin: const EdgeInsets.only(right: 12),
              decoration: BoxDecoration(
                color: course.accentColor,
                shape: BoxShape.circle,
              ),
            ),
          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  course.title,
                  style: TextStyle(
                    color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black87,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  '${course.subject} · ${course.grade} · ${0} students',
                  style: TextStyle(
                    color: Theme.of(context).brightness == Brightness.dark ? const Color(0xFF8BA3C0) : Colors.grey.shade600,
                    fontSize: 11,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          if (!isSelectMode) const SizedBox(width: 8),
          // Edit button
          if (!isSelectMode)
            GestureDetector(
              onTap: onEdit,
              child: Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: const Color(0x2200D4FF),
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: const Center(
                  child: Icon(
                    Icons.edit_outlined,
                    color: Color(0xFF00D4FF),
                    size: 16,
                  ),
                ),
              ),
            ),
          if (!isSelectMode) const SizedBox(width: 8),
          // Delete button
          if (!isSelectMode)
            GestureDetector(
              onTap: onDelete,
              child: Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: const Color(0x22FF4757),
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: const Center(
                  child: Icon(
                    Icons.delete_outline,
                    color: Color(0xFFFF4757),
                    size: 16,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// ── Teacher course list card ──────────────────────────────────────────────────

class _CourseCard extends StatelessWidget {
  final Course course;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _CourseCard({
    required this.course,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).brightness == Brightness.dark ? const Color(0xFF142240) : Colors.white,
          borderRadius: BorderRadius.circular(20.0),
          border: Border.all(color: course.accentColor.withOpacity(0.3), width: 1),
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
                        '${course.subject} · ${course.grade}',
                        style: TextStyle(
                          fontSize: 12,
                          color: Theme.of(context).brightness == Brightness.dark ? const Color(0xFF8BA3C0) : Colors.grey.shade600,
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
                  icon: 'people',
                  label: '${0} Students',
                  color: const Color(0xFFFFB800),
                ),
                _InfoChip(
                  icon: 'quiz',
                  label: '${course.quizzes.length} Quizzes',
                  color: course.accentColor,
                ),
                _InfoChip(
                  icon: 'folder_open',
                  label: '${course.modules.length} Modules',
                  color: Theme.of(context).brightness == Brightness.dark ? const Color(0xFF8BA3C0) : Colors.grey.shade600,
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
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withAlpha(20),
        borderRadius: BorderRadius.circular(50.0),
        border: Border.all(color: color.withAlpha(50), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          CustomIconWidget(iconName: icon, color: color, size: 12),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Course Form Dialog ────────────────────────────────────────────────────────

class _CourseFormDialog extends StatelessWidget {
  final String title;
  final TextEditingController titleCtrl;
  final TextEditingController subjectCtrl;
  final TextEditingController gradeCtrl;
  final GlobalKey<FormState> formKey;
  final VoidCallback onSave;

  const _CourseFormDialog({
    required this.title,
    required this.titleCtrl,
    required this.subjectCtrl,
    required this.gradeCtrl,
    required this.formKey,
    required this.onSave,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Theme.of(context).brightness == Brightness.dark ? const Color(0xFF142240) : Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
      title: Text(
        title,
        style: TextStyle(
          color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black87,
          fontWeight: FontWeight.w700,
          fontSize: 18,
        ),
      ),
      content: Form(
        key: formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildField(
                context,
                controller: subjectCtrl,
                label: 'Subject',
                hint: 'e.g. Chemistry',
                validator: (v) => (v == null || v.trim().isEmpty)
                    ? 'Subject is required'
                    : null,
              ),
              const SizedBox(height: 14),
              _buildField(
                context,
                controller: titleCtrl,
                label: 'Topic',
                hint: 'e.g. Organic Chemistry Fundamentals',
                validator: (v) => (v == null || v.trim().isEmpty)
                    ? 'Topic is required'
                    : null,
              ),
              const SizedBox(height: 14),
              DropdownButtonFormField<String>(
                value: gradeCtrl.text.isNotEmpty ? gradeCtrl.text : null,
                items: [
                  if (gradeCtrl.text.isNotEmpty && !['Grade 9', 'Grade 10'].contains(gradeCtrl.text)) gradeCtrl.text,
                  'Grade 9',
                  'Grade 10',
                ].map((String val) {
                  return DropdownMenuItem<String>(
                    value: val,
                    child: Text(val),
                  );
                }).toList(),
                onChanged: (val) {
                  if (val != null) {
                    gradeCtrl.text = val;
                  }
                },
                style: TextStyle(color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black87, fontSize: 14),
                dropdownColor: Theme.of(context).brightness == Brightness.dark ? const Color(0xFF142240) : Colors.white,
                decoration: InputDecoration(
                  labelText: 'Grade',
                  hintText: 'Select Grade',
                  labelStyle: TextStyle(color: Theme.of(context).brightness == Brightness.dark ? const Color(0xFF8BA3C0) : Colors.grey.shade600, fontSize: 13),
                  hintStyle: TextStyle(color: Theme.of(context).brightness == Brightness.dark ? const Color(0x668BA3C0) : Colors.grey.shade400, fontSize: 13),
                  filled: true,
                  fillColor: Theme.of(context).brightness == Brightness.dark ? const Color(0xFF0A1628) : Colors.grey.shade100,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                    borderSide: const BorderSide(color: Color(0x3300FF88)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                    borderSide: const BorderSide(color: Color(0x3300FF88)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                    borderSide: const BorderSide(color: Color(0xFF00FF88), width: 1.5),
                  ),
                  errorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                    borderSide: const BorderSide(color: Color(0xFFFF4757)),
                  ),
                  focusedErrorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                    borderSide: const BorderSide(color: Color(0xFFFF4757), width: 1.5),
                  ),
                  errorStyle: const TextStyle(color: Color(0xFFFF4757), fontSize: 11),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                ),
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Grade is required' : null,
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(
            'Cancel',
            style: TextStyle(color: Theme.of(context).brightness == Brightness.dark ? const Color(0xFF8BA3C0) : Colors.grey.shade600),
          ),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF00FF88),
            foregroundColor: const Color(0xFF0A1628),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.0),
            ),
          ),
          onPressed: onSave,
          child: const Text(
            'Save',
            style: TextStyle(fontWeight: FontWeight.w700),
          ),
        ),
      ],
    );
  }

  Widget _buildField(
    BuildContext context, {
    required TextEditingController controller,
    required String label,
    required String hint,
    required String? Function(String?) validator,
  }) {
    return TextFormField(
      controller: controller,
      validator: validator,
      style: TextStyle(color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black87, fontSize: 14),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        labelStyle: TextStyle(color: Theme.of(context).brightness == Brightness.dark ? const Color(0xFF8BA3C0) : Colors.grey.shade600, fontSize: 13),
        hintStyle: TextStyle(color: Theme.of(context).brightness == Brightness.dark ? const Color(0x668BA3C0) : Colors.grey.shade400, fontSize: 13),
        filled: true,
        fillColor: Theme.of(context).brightness == Brightness.dark ? const Color(0xFF0A1628) : Colors.grey.shade100,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.0),
          borderSide: const BorderSide(color: Color(0x3300FF88)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.0),
          borderSide: const BorderSide(color: Color(0x3300FF88)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.0),
          borderSide: const BorderSide(color: Color(0xFF00FF88), width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.0),
          borderSide: const BorderSide(color: Color(0xFFFF4757)),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.0),
          borderSide: const BorderSide(color: Color(0xFFFF4757), width: 1.5),
        ),
        errorStyle: const TextStyle(color: Color(0xFFFF4757), fontSize: 11),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 12,
        ),
      ),
    );
  }
}
