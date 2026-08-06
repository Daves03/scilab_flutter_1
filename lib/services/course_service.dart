import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:file_selector/file_selector.dart';
import '../models/course_model.dart';

class CourseService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  static const _coursesCollection = 'courses';
  static const _attemptsCollection = 'quiz_attempts';

  Stream<List<Course>> coursesStream() {
    return _db
        .collection(_coursesCollection)
        .snapshots()
        .map((snap) => snap.docs.map((d) => Course.fromMap(d.id, d.data())).toList());
  }

  Stream<List<Course>> coursesForTeacherStream(String teacherUid) {
    return _db
        .collection(_coursesCollection)
        .where('teacherUid', isEqualTo: teacherUid)
        .snapshots()
        .map((snap) => snap.docs.map((d) => Course.fromMap(d.id, d.data())).toList());
  }

  /// One-shot fetch, used where a screen loads once into a mutable
  /// local list rather than staying subscribed to a stream.
  Future<List<Course>> fetchCourses() async {
    final snap = await _db.collection(_coursesCollection).get();
    return snap.docs.map((d) => Course.fromMap(d.id, d.data())).toList();
  }

  Future<List<Course>> fetchCoursesForTeacher(String teacherUid) async {
    final snap = await _db
        .collection(_coursesCollection)
        .where('teacherUid', isEqualTo: teacherUid)
        .get();
    return snap.docs.map((d) => Course.fromMap(d.id, d.data())).toList();
  }

  Future<String> createCourse(Course course) async {
    final ref = await _db.collection(_coursesCollection).add(course.toMap());
    return ref.id;
  }

  /// Same as [createCourse] but with a client-chosen id, so the caller
  /// can keep using that id locally right away instead of waiting on a
  /// round trip to learn the auto-generated one.
  Future<void> createCourseWithId(String id, Course course) {
    return _db.collection(_coursesCollection).doc(id).set(course.toMap());
  }

  Future<void> deleteCourse(String courseId) async {
    // Best-effort cleanup of any uploaded module files in Storage.
    final doc = await _db.collection(_coursesCollection).doc(courseId).get();
    if (doc.exists) {
      final course = Course.fromMap(doc.id, doc.data()!);
      for (final module in course.modules) {
        if (module.storagePath.isNotEmpty) {
          try {
            await _storage.ref(module.storagePath).delete();
          } catch (_) {
            // File may already be gone — not fatal to course deletion.
          }
        }
      }
    }
    await _db.collection(_coursesCollection).doc(courseId).delete();
  }

  Future<void> updateCourse(Course course) {
    return updateCourseFields(course.id, {
      'title': course.title,
      'subject': course.subject,
      'grade': course.grade,
      'accentColorValue': course.accentColorValue,
      'iconName': course.iconName,
      'modules': course.modules.map((m) => m.toMap()).toList(),
      'quizzes': course.quizzes.map((q) => q.toMap()).toList(),
    });
  }

  Future<void> updateCourseFields(String id, Map<String, dynamic> data) {
    return _db.collection(_coursesCollection).doc(id).update(data);
  }

  // ---- Modules ----

  /// Opens the system file/Drive picker, uploads to Storage, and appends
  /// the module to the course doc. Returns the new module so the caller
  /// can update its local in-memory copy too.
  Future<CourseModule?> pickUploadAndAddModule({
    required String courseId,
    required String uploadedByName,
    List<String>? allowedExtensions,
  }) async {
    final typeGroup = XTypeGroup(label: 'documents', extensions: allowedExtensions);
    final XFile? picked = await openFile(acceptedTypeGroups: [typeGroup]);
    if (picked == null) { return null; }

    final bytes = await picked.readAsBytes();
    final safeName = picked.name.replaceAll(RegExp(r'\s+'), '_');
    final storagePath =
        'course_modules/$courseId/${DateTime.now().millisecondsSinceEpoch}_$safeName';
    final ref = _storage.ref(storagePath);
    final snapshot = await ref.putData(bytes);
    final url = await snapshot.ref.getDownloadURL();

    final extension = safeName.contains('.') ? safeName.split('.').last.toLowerCase() : '';
    final module = CourseModule(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: picked.name,
      description: '',
      fileType: extension,
      uploadedByName: uploadedByName,
      uploadedAt: DateTime.now(),
      fileSizeBytes: bytes.length,
      url: url,
      storagePath: storagePath,
    );

    await addModule(courseId, module);
    return module;
  }

  Future<void> addModule(String courseId, CourseModule module) async {
    final course = await _fetchOne(courseId);
    if (course == null) { return; }
    final updated = [...course.modules, module];
    await _db.collection(_coursesCollection).doc(courseId).update({
      'modules': updated.map((m) => m.toMap()).toList(),
    });
  }

  Future<void> removeModule(String courseId, String moduleId) async {
    final course = await _fetchOne(courseId);
    if (course == null) { return; }
    final target = course.modules.where((m) => m.id == moduleId).toList();
    final updated = course.modules.where((m) => m.id != moduleId).toList();
    await _db.collection(_coursesCollection).doc(courseId).update({
      'modules': updated.map((m) => m.toMap()).toList(),
    });
    if (target.isNotEmpty && target.first.storagePath.isNotEmpty) {
      try {
        await _storage.ref(target.first.storagePath).delete();
      } catch (_) {}
    }
  }

  Future<void> updateModule(String courseId, CourseModule module) async {
    final course = await _fetchOne(courseId);
    if (course == null) { return; }
    final updated = course.modules.map((m) => m.id == module.id ? module : m).toList();
    await _db.collection(_coursesCollection).doc(courseId).update({
      'modules': updated.map((m) => m.toMap()).toList(),
    });
  }

  // ---- Quizzes ----

  Future<void> addQuiz(String courseId, CourseQuiz quiz) async {
    final course = await _fetchOne(courseId);
    if (course == null) { return; }
    final updated = [...course.quizzes, quiz];
    await _db.collection(_coursesCollection).doc(courseId).update({
      'quizzes': updated.map((q) => q.toMap()).toList(),
    });
  }

  Future<void> updateQuiz(String courseId, CourseQuiz quiz) async {
    final course = await _fetchOne(courseId);
    if (course == null) { return; }
    final updated = course.quizzes.map((q) => q.id == quiz.id ? quiz : q).toList();
    await _db.collection(_coursesCollection).doc(courseId).update({
      'quizzes': updated.map((q) => q.toMap()).toList(),
    });
  }

  Future<void> removeQuiz(String courseId, String quizId) async {
    final course = await _fetchOne(courseId);
    if (course == null) { return; }
    final updated = course.quizzes.where((q) => q.id != quizId).toList();
    await _db.collection(_coursesCollection).doc(courseId).update({
      'quizzes': updated.map((q) => q.toMap()).toList(),
    });
  }

  Future<Course?> _fetchOne(String courseId) async {
    final doc = await _db.collection(_coursesCollection).doc(courseId).get();
    if (!doc.exists) { return null; }
    return Course.fromMap(doc.id, doc.data()!);
  }

  // ---- Quiz attempts ----

  Future<void> submitAttempt(QuizAttempt attempt) =>
      _db.collection(_attemptsCollection).add(attempt.toMap());

  Stream<List<QuizAttempt>> attemptsForStudent(String studentId) {
    return _db
        .collection(_attemptsCollection)
        .where('studentId', isEqualTo: studentId)
        .snapshots()
        .map((snap) => snap.docs.map((d) => QuizAttempt.fromMap(d.id, d.data())).toList());
  }

  Future<List<QuizAttempt>> fetchAttemptsForStudent(String studentId) async {
    final snap = await _db
        .collection(_attemptsCollection)
        .where('studentId', isEqualTo: studentId)
        .get();
    return snap.docs.map((d) => QuizAttempt.fromMap(d.id, d.data())).toList();
  }
}

