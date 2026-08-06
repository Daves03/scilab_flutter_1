import '../../core/app_export.dart';
import '../../models/course_model.dart';
import '../../services/auth_service.dart';
import '../../services/course_service.dart';
import './widgets/teacher_course_detail_widget.dart';

// ── Shared mock data models (reused from student side) ────────────────────────

class TeacherCourse {
  final String id;
  String title;
  String subject;
  String grade;
  final Color accentColor;
  final String iconName;
  final int studentCount;
  List<TeacherModule> modules;
  List<TeacherQuiz> quizzes;

  TeacherCourse({
    required this.id,
    required this.title,
    required this.subject,
    required this.grade,
    required this.accentColor,
    required this.iconName,
    required this.studentCount,
    required this.modules,
    required this.quizzes,
  });
}

class TeacherModule {
  String id;
  String title;
  String description;
  String fileType;
  String uploadedDate;
  String fileSize;
  DateTime? uploadedAtRaw;
  int fileSizeBytesRaw;
  String url;
  String storagePath;

  TeacherModule({
    required this.id,
    required this.title,
    required this.description,
    required this.fileType,
    required this.uploadedDate,
    required this.fileSize,
    this.uploadedAtRaw,
    this.fileSizeBytesRaw = 0,
    this.url = '',
    this.storagePath = '',
  });
}

class TeacherQuiz {
  String id;
  String title;
  List<TeacherQuestion> questions;

  TeacherQuiz({required this.id, required this.title, required this.questions});
}

class TeacherQuestion {
  String id;
  String question;
  List<String> options;
  int correctIndex;
  String explanation;

  TeacherQuestion({
    required this.id,
    required this.question,
    required this.options,
    required this.correctIndex,
    required this.explanation,
  });
}

// ── Conversion helpers: Teacher* (mutable, UI-friendly) <-> Course* (real Firestore models) ──

extension TeacherCourseConversion on TeacherCourse {
  static TeacherCourse fromCourse(Course c) {
    return TeacherCourse(
      id: c.id,
      title: c.title,
      subject: c.subject,
      grade: c.grade,
      accentColor: c.accentColor,
      iconName: c.iconName,
      studentCount: 0, // no real enrollment-count concept yet
      modules: c.modules.map(TeacherModuleConversion.fromCourseModule).toList(),
      quizzes: c.quizzes.map(TeacherQuizConversion.fromCourseQuiz).toList(),
    );
  }

  Course toCourseModel({required String teacherUid, required String teacherName}) {
    return Course(
      id: id,
      title: title,
      subject: subject,
      grade: grade,
      teacherUid: teacherUid,
      teacherName: teacherName,
      accentColorValue: accentColor.value,
      iconName: iconName,
      modules: modules.map((m) => m.toCourseModuleModel()).toList(),
      quizzes: quizzes.map((q) => q.toCourseQuizModel()).toList(),
    );
  }
}

extension TeacherModuleConversion on TeacherModule {
  static TeacherModule fromCourseModule(CourseModule m) {
    return TeacherModule(
      id: m.id,
      title: m.title,
      description: m.description,
      fileType: m.fileType,
      uploadedDate: m.uploadedDateLabel,
      fileSize: m.friendlySize.isEmpty ? '—' : m.friendlySize,
      uploadedAtRaw: m.uploadedAt,
      fileSizeBytesRaw: m.fileSizeBytes,
      url: m.url,
      storagePath: m.storagePath,
    );
  }

  CourseModule toCourseModuleModel() {
    return CourseModule(
      id: id,
      title: title,
      description: description,
      fileType: fileType,
      uploadedByName: '',
      uploadedAt: uploadedAtRaw ?? DateTime.now(),
      fileSizeBytes: fileSizeBytesRaw,
      url: url,
      storagePath: storagePath,
    );
  }
}

extension TeacherQuizConversion on TeacherQuiz {
  static TeacherQuiz fromCourseQuiz(CourseQuiz q) {
    return TeacherQuiz(
      id: q.id,
      title: q.title,
      questions: q.questions.map(TeacherQuestionConversion.fromCourseQuestion).toList(),
    );
  }

  CourseQuiz toCourseQuizModel() {
    return CourseQuiz(
      id: id,
      title: title,
      questions: questions.map((q) => q.toCourseQuestionModel()).toList(),
    );
  }
}

extension TeacherQuestionConversion on TeacherQuestion {
  static TeacherQuestion fromCourseQuestion(CourseQuestion q) {
    return TeacherQuestion(
      id: q.id,
      question: q.question,
      options: q.options,
      correctIndex: q.correctIndex,
      explanation: q.explanation,
    );
  }

  CourseQuestion toCourseQuestionModel() {
    return CourseQuestion(
      id: id,
      question: question,
      options: options,
      correctIndex: correctIndex,
      explanation: explanation,
    );
  }
}

// ── Data ──────────────────────────────────────────────────────────────────────
// Loaded once from Firestore in _TeacherCoursesScreenState.initState() via
// CourseService.fetchCoursesForTeacher(). Kept as a plain mutable list (not a
// stream) so the existing in-place-edit UI code below needs no restructuring —
// every mutation site also fires the matching CourseService write so it
// persists, instead of only living in this list.
List<TeacherCourse> teacherMockCourses = [];


// ── Screen ────────────────────────────────────────────────────────────────────

class TeacherCoursesScreen extends StatefulWidget {
  const TeacherCoursesScreen({super.key});

  @override
  State<TeacherCoursesScreen> createState() => _TeacherCoursesScreenState();
}

class _TeacherCoursesScreenState extends State<TeacherCoursesScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _entranceController;
  TeacherCourse? _selectedCourse;
  bool _loading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _entranceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    )..forward();
    _loadCourses();
  }

  Future<void> _loadCourses() async {
    final teacherUid = AuthService.instance.currentUser?.id;
    if (teacherUid == null) {
      setState(() => _loading = false);
      return;
    }
    try {
      final courses = await CourseService().fetchCoursesForTeacher(teacherUid);
      if (!mounted) { return; }
      setState(() {
        teacherMockCourses =
            courses.map(TeacherCourseConversion.fromCourse).toList();
        _loading = false;
        _errorMessage = null;
      });
    } catch (e) {
      debugPrint('Error loading teacher courses: $e');
      if (mounted) {
        setState(() {
          _loading = false;
          _errorMessage = e.toString().contains('permission-denied')
              ? 'Permission Denied: Please check your Firestore security rules.'
              : 'Failed to load teacher dashboard data.';
        });
      }
    }
  }

  @override
  void dispose() {
    _entranceController.dispose();
    super.dispose();
  }

  void _openCourse(TeacherCourse course) {
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
      builder: (ctx) => _CoursesCrudPanel(onChanged: () => setState(() {})),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        backgroundColor: Color(0xFF0A1628),
        body: Center(child: CircularProgressIndicator()),
      );
    }
    return Scaffold(
      backgroundColor: const Color(0xFF0A1628),
      body: SafeArea(
        bottom: false,
        child: Stack(
          children: [
            _selectedCourse != null
                ? TeacherCourseDetailWidget(
                    course: _selectedCourse!,
                    onBack: _closeCourse,
                    onUpdated: _onCourseUpdated,
                  )
                : _buildCourseList(),
            if (_selectedCourse == null)
              Positioned(
                bottom: 88,
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

  Widget _buildCourseList() {
    if (_errorMessage != null) {
      return Column(
        children: [
          _buildHeader(),
          const Spacer(),
          EmptyStateWidget(
            iconName: 'error_outline',
            title: 'Access Error',
            subtitle: _errorMessage!,
          ),
          const Spacer(flex: 2),
        ],
      );
    }
    if (teacherMockCourses.isEmpty) {
      return Column(
        children: [
          _buildHeader(),
          const Spacer(),
          const EmptyStateWidget(
            iconName: 'library_books',
            title: 'No courses created',
            subtitle:
                'You haven\'t created any courses yet. Tap the button below to get started.',
          ),
          const Spacer(flex: 2),
        ],
      );
    }
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(child: _buildHeader()),
        SliverToBoxAdapter(child: _buildSubtitle()),
        SliverList(
          delegate: SliverChildBuilderDelegate((context, index) {
            final course = teacherMockCourses[index];
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
                child: _TeacherCourseCard(
                  course: course,
                  onTap: () => _openCourse(course),
                  onEdit: () => _showEditCourseDialog(course),
                  onDelete: () => _showDeleteCourseDialog(course),
                ),
              ),
            );
          }, childCount: teacherMockCourses.length),
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
              color: const Color(0xFF1A2E1A),
              borderRadius: BorderRadius.circular(12.0),
              border: Border.all(color: const Color(0x3300FF88), width: 1),
            ),
            child: const Center(
              child: CustomIconWidget(
                iconName: 'school',
                color: Color(0xFF00FF88),
                size: 20,
              ),
            ),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'My Courses',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
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
              color: const Color(0x2200FF88),
              borderRadius: BorderRadius.circular(50.0),
              border: Border.all(color: const Color(0x5500FF88), width: 1),
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

  Widget _buildSubtitle() {
    final totalStudents = teacherMockCourses.fold<int>(
      0,
      (sum, c) => sum + c.studentCount,
    );
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 20),
      child: Text(
        '${teacherMockCourses.length} courses · $totalStudents students enrolled',
        style: const TextStyle(fontSize: 13, color: Color(0xFF8BA3C0)),
      ),
    );
  }

  // ── Edit / Delete helpers (still used from card popup menu) ───────────────

  void _showEditCourseDialog(TeacherCourse course) {
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
        onSave: () {
          if (formKey.currentState!.validate()) {
            setState(() {
              course.title = titleCtrl.text.trim();
              course.subject = subjectCtrl.text.trim();
              course.grade = gradeCtrl.text.trim();
            });
            CourseService().updateCourseFields(course.id, {
              'title': course.title,
              'subject': course.subject,
              'grade': course.grade,
            });
            Navigator.of(ctx).pop();
          }
        },
      ),
    );
  }

  void _showDeleteCourseDialog(TeacherCourse course) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF142240),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.0),
        ),
        title: const Text(
          'Delete Course',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
        ),
        content: Text(
          'Are you sure you want to delete "${course.title}"? This action cannot be undone.',
          style: const TextStyle(color: Color(0xFF8BA3C0)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text(
              'Cancel',
              style: TextStyle(color: Color(0xFF8BA3C0)),
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
            onPressed: () {
              setState(() {
                teacherMockCourses.removeWhere((c) => c.id == course.id);
              });
              CourseService().deleteCourse(course.id);
              Navigator.of(ctx).pop();
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

  const _CoursesCrudPanel({required this.onChanged});

  @override
  State<_CoursesCrudPanel> createState() => _CoursesCrudPanelState();
}

class _CoursesCrudPanelState extends State<_CoursesCrudPanel> {
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
        onSave: () {
          if (formKey.currentState!.validate()) {
            final newCourse = TeacherCourse(
              id: 'tc_${DateTime.now().millisecondsSinceEpoch}',
              title: titleCtrl.text.trim(),
              subject: subjectCtrl.text.trim(),
              grade: gradeCtrl.text.trim(),
              accentColor: const Color(0xFF00D4FF),
              iconName: 'science',
              studentCount: 0,
              modules: [],
              quizzes: [],
            );
            teacherMockCourses.add(newCourse);

            final auth = AuthService.instance.currentUser;
            CourseService().createCourseWithId(
              newCourse.id,
              newCourse.toCourseModel(
                teacherUid: auth?.id ?? '',
                teacherName: auth?.name ?? 'Teacher',
              ),
            );

            Navigator.of(ctx).pop();
            _refresh();
          }
        },
      ),
    );
  }

  void _showEditDialog(TeacherCourse course) {
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
        onSave: () {
          if (formKey.currentState!.validate()) {
            course.title = titleCtrl.text.trim();
            course.subject = subjectCtrl.text.trim();
            course.grade = gradeCtrl.text.trim();
            CourseService().updateCourseFields(course.id, {
              'title': course.title,
              'subject': course.subject,
              'grade': course.grade,
            });
            Navigator.of(ctx).pop();
            _refresh();
          }
        },
      ),
    );
  }

  void _showDeleteConfirm(TeacherCourse course) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF142240),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.0),
        ),
        title: const Text(
          'Delete Course',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
        ),
        content: Text(
          'Delete "${course.title}"? This cannot be undone.',
          style: const TextStyle(color: Color(0xFF8BA3C0)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text(
              'Cancel',
              style: TextStyle(color: Color(0xFF8BA3C0)),
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
            onPressed: () {
              teacherMockCourses.removeWhere((c) => c.id == course.id);
              CourseService().deleteCourse(course.id);
              Navigator.of(ctx).pop();
              _refresh();
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

    return Container(
      margin: const EdgeInsets.fromLTRB(12, 0, 12, 12),
      decoration: BoxDecoration(
        color: const Color(0xFF142240),
        borderRadius: BorderRadius.circular(24.0),
        border: Border.all(color: const Color(0x3300FF88), width: 1),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // ── Handle ──────────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.only(top: 12, bottom: 4),
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: const Color(0xFF3A5070),
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
                    color: const Color(0x2200FF88),
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  child: const Center(
                    child: Icon(Icons.edit, color: Color(0xFF00FF88), size: 18),
                  ),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Manage Courses',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        'Create, edit or delete your courses',
                        style: TextStyle(
                          color: Color(0xFF8BA3C0),
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
                // Create button
                GestureDetector(
                  onTap: _showCreateDialog,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF00FF88),
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.add, color: Color(0xFF0A1628), size: 16),
                        SizedBox(width: 4),
                        Text(
                          'New Course',
                          style: TextStyle(
                            color: Color(0xFF0A1628),
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          // ── Divider ─────────────────────────────────────────────────────
          const Divider(color: Color(0x220A1628), height: 1),
          // ── Course list ─────────────────────────────────────────────────
          ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.5,
            ),
            child: teacherMockCourses.isEmpty
                ? Padding(
                    padding: const EdgeInsets.all(32),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.library_books_outlined,
                          color: const Color(0xFF3A5070),
                          size: 48,
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'No courses yet',
                          style: TextStyle(
                            color: Color(0xFF8BA3C0),
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Tap "New Course" to create your first course',
                          style: TextStyle(
                            color: Color(0xFF3A5070),
                            fontSize: 12,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  )
                : ListView.separated(
                    shrinkWrap: true,
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                    itemCount: teacherMockCourses.length,
                    separatorBuilder: (_, __) =>
                        const Divider(color: Color(0x150A1628), height: 1),
                    itemBuilder: (context, index) {
                      final course = teacherMockCourses[index];
                      return _PanelCourseRow(
                        course: course,
                        onEdit: () => _showEditDialog(course),
                        onDelete: () => _showDeleteConfirm(course),
                      );
                    },
                  ),
          ),
          SizedBox(height: bottomPadding + 12),
        ],
      ),
    );
  }
}

// ── Panel course row ──────────────────────────────────────────────────────────

class _PanelCourseRow extends StatelessWidget {
  final TeacherCourse course;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _PanelCourseRow({
    required this.course,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          // Color dot
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(
              color: course.accentColor,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),
          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  course.title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  '${course.subject} · ${course.grade} · ${course.studentCount} students',
                  style: const TextStyle(
                    color: Color(0xFF8BA3C0),
                    fontSize: 11,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          // Edit button
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
          const SizedBox(width: 8),
          // Delete button
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

class _TeacherCourseCard extends StatelessWidget {
  final TeacherCourse course;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _TeacherCourseCard({
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
                        '${course.subject} · ${course.grade}',
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
                  icon: 'people',
                  label: '${course.studentCount} Students',
                  color: const Color(0xFFFFB800),
                ),
                const SizedBox(width: 8),
                _InfoChip(
                  icon: 'quiz',
                  label: '${course.quizzes.length} Quizzes',
                  color: course.accentColor,
                ),
                const SizedBox(width: 8),
                _InfoChip(
                  icon: 'folder_open',
                  label: '${course.modules.length} Modules',
                  color: const Color(0xFF8BA3C0),
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
      backgroundColor: const Color(0xFF142240),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
      title: Text(
        title,
        style: const TextStyle(
          color: Colors.white,
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
                controller: titleCtrl,
                label: 'Course Title',
                hint: 'e.g. Organic Chemistry Fundamentals',
                validator: (v) => (v == null || v.trim().isEmpty)
                    ? 'Title is required'
                    : null,
              ),
              const SizedBox(height: 14),
              _buildField(
                controller: subjectCtrl,
                label: 'Subject',
                hint: 'e.g. Chemistry',
                validator: (v) => (v == null || v.trim().isEmpty)
                    ? 'Subject is required'
                    : null,
              ),
              const SizedBox(height: 14),
              _buildField(
                controller: gradeCtrl,
                label: 'Grade',
                hint: 'e.g. Grade 10',
                validator: (v) => (v == null || v.trim().isEmpty)
                    ? 'Grade is required'
                    : null,
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text(
            'Cancel',
            style: TextStyle(color: Color(0xFF8BA3C0)),
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

  Widget _buildField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required String? Function(String?) validator,
  }) {
    return TextFormField(
      controller: controller,
      validator: validator,
      style: const TextStyle(color: Colors.white, fontSize: 14),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        labelStyle: const TextStyle(color: Color(0xFF8BA3C0), fontSize: 13),
        hintStyle: const TextStyle(color: Color(0x668BA3C0), fontSize: 13),
        filled: true,
        fillColor: const Color(0xFF0A1628),
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

