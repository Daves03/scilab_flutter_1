import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:file_selector/file_selector.dart';
import '../core/course_assignment.dart';
import '../models/course_model.dart';
import '../models/user_model.dart';

class CourseService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  static const _coursesCollection = 'courses';
  static const _attemptsCollection = 'quiz_attempts';

  Stream<List<Course>> coursesStream() {
    return _coursesWithLiveTeacherNames(_db.collection(_coursesCollection));
  }

  Stream<List<Course>> coursesForTeacherStream(String teacherUid) {
    return _coursesWithLiveTeacherNames(
      _db
          .collection(_coursesCollection)
          .where('teacherUid', isEqualTo: teacherUid),
    );
  }

  Stream<List<Course>> coursesForStudentStream(AppUser student) {
    final grade = student.role?.label;
    if (!student.isStudent || grade == null || student.sections.isEmpty) {
      return Stream.value(const <Course>[]);
    }

    return _coursesWithStudentProgress(
      _coursesWithLiveTeacherNames(
        _db.collection(_coursesCollection).where('grade', isEqualTo: grade),
        include: (course) =>
            CourseAssignment.courseMatchesStudent(course, student),
      ),
      student.id,
    );
  }

  Stream<List<Course>> _coursesWithStudentProgress(
    Stream<List<Course>> coursesStream,
    String studentId,
  ) {
    late final StreamController<List<Course>> controller;
    StreamSubscription<List<Course>>? coursesSubscription;
    StreamSubscription<List<QuizAttempt>>? attemptsSubscription;
    var latestCourses = <Course>[];
    var latestAttempts = <QuizAttempt>[];
    var hasCourses = false;

    void emitProgress() {
      if (!hasCourses || controller.isClosed) return;
      controller.add(_applyStudentProgress(latestCourses, latestAttempts));
    }

    controller = StreamController<List<Course>>(
      onListen: () {
        coursesSubscription = coursesStream.listen((courses) {
          latestCourses = courses;
          hasCourses = true;
          emitProgress();
        }, onError: controller.addError);
        attemptsSubscription = attemptsForStudent(studentId).listen((attempts) {
          latestAttempts = attempts;
          emitProgress();
        }, onError: controller.addError);
      },
      onCancel: () async {
        await coursesSubscription?.cancel();
        await attemptsSubscription?.cancel();
      },
    );
    return controller.stream;
  }

  List<Course> _applyStudentProgress(
    List<Course> courses,
    List<QuizAttempt> attempts,
  ) {
    final completedQuizIdsByCourse = <String, Set<String>>{};
    for (final attempt in attempts) {
      if (attempt.courseId.isEmpty || attempt.quizId.isEmpty) continue;
      completedQuizIdsByCourse
          .putIfAbsent(attempt.courseId, () => <String>{})
          .add(attempt.quizId);
    }

    for (final course in courses) {
      if (course.quizzes.isEmpty) {
        course.progress = 0;
        continue;
      }
      final validQuizIds = course.quizzes.map((quiz) => quiz.id).toSet();
      final completedIds = completedQuizIdsByCourse[course.id] ?? const {};
      final completedCount = completedIds.where(validQuizIds.contains).length;
      course.progress = (completedCount / course.quizzes.length).clamp(
        0.0,
        1.0,
      );
    }
    return List<Course>.unmodifiable(courses);
  }

  /// Courses keep a name snapshot for offline compatibility, but every active
  /// course stream also watches the owning user's profile. A profile rename
  /// therefore refreshes course cards, recent content, notifications, and
  /// module uploader labels without waiting for the course itself to change.
  Stream<List<Course>> _coursesWithLiveTeacherNames(
    Query<Map<String, dynamic>> query, {
    bool Function(Course course)? include,
  }) {
    late final StreamController<List<Course>> controller;
    StreamSubscription<QuerySnapshot<Map<String, dynamic>>>?
    coursesSubscription;
    final teacherSubscriptions =
        <String, StreamSubscription<DocumentSnapshot<Map<String, dynamic>>>>{};
    final currentTeacherNames = <String, String>{};
    var latestCourses = <Course>[];

    void emitCourses() {
      if (controller.isClosed) return;
      final resolved = latestCourses
          .where((course) => include?.call(course) ?? true)
          .map(
            (course) => _courseWithCurrentTeacherName(
              course,
              currentTeacherNames[course.teacherUid],
            ),
          )
          .toList(growable: false);
      controller.add(resolved);
    }

    void syncTeacherSubscriptions() {
      final desiredIds = latestCourses
          .map((course) => course.teacherUid)
          .where((uid) => uid.isNotEmpty)
          .toSet();
      final removedIds = teacherSubscriptions.keys
          .where((uid) => !desiredIds.contains(uid))
          .toList(growable: false);
      for (final uid in removedIds) {
        unawaited(teacherSubscriptions.remove(uid)?.cancel());
        currentTeacherNames.remove(uid);
      }

      for (final uid in desiredIds) {
        if (teacherSubscriptions.containsKey(uid)) continue;
        teacherSubscriptions[uid] = _db
            .collection('users')
            .doc(uid)
            .snapshots()
            .listen(
              (snapshot) {
                final latestName = snapshot.data()?['name']?.toString().trim();
                if (latestName != null && latestName.isNotEmpty) {
                  currentTeacherNames[uid] = latestName;
                } else {
                  currentTeacherNames.remove(uid);
                }
                emitCourses();
              },
              onError: (_) {
                // Keep displaying the stored course snapshot when a profile
                // cannot be read (for example while temporarily offline).
              },
            );
      }
    }

    controller = StreamController<List<Course>>(
      onListen: () {
        coursesSubscription = query.snapshots().listen((snapshot) {
          latestCourses = snapshot.docs
              .map((document) => Course.fromMap(document.id, document.data()))
              .toList(growable: false);
          syncTeacherSubscriptions();
          emitCourses();
        }, onError: controller.addError);
      },
      onCancel: () async {
        await coursesSubscription?.cancel();
        await Future.wait(
          teacherSubscriptions.values.map(
            (subscription) => subscription.cancel(),
          ),
        );
      },
    );
    return controller.stream;
  }

  Course _courseWithCurrentTeacherName(Course course, String? currentName) {
    final resolvedName = currentName?.trim();
    if (resolvedName == null || resolvedName.isEmpty) return course;

    final resolvedModules = course.modules
        .map(
          (module) =>
              module.uploadedByUid.isEmpty ||
                  module.uploadedByUid == course.teacherUid
              ? module.copyWith(
                  uploadedByUid: course.teacherUid,
                  uploadedByName: resolvedName,
                )
              : module,
        )
        .toList(growable: false);
    return course.copyWith(teacherName: resolvedName, modules: resolvedModules);
  }

  Future<List<Course>> _resolveCurrentTeacherNames(List<Course> courses) async {
    final teacherIds = courses
        .map((course) => course.teacherUid)
        .where((uid) => uid.isNotEmpty)
        .toSet();
    final names = <String, String>{};
    await Future.wait(
      teacherIds.map((uid) async {
        try {
          final snapshot = await _db.collection('users').doc(uid).get();
          final name = snapshot.data()?['name']?.toString().trim();
          if (name != null && name.isNotEmpty) names[uid] = name;
        } catch (_) {
          // The stored name remains available as an offline fallback.
        }
      }),
    );
    return courses
        .map(
          (course) =>
              _courseWithCurrentTeacherName(course, names[course.teacherUid]),
        )
        .toList(growable: false);
  }

  /// One-shot fetch, used where a screen loads once into a mutable
  /// local list rather than staying subscribed to a stream.
  Future<List<Course>> fetchCourses() async {
    final snap = await _db.collection(_coursesCollection).get();
    return _resolveCurrentTeacherNames(
      snap.docs.map((d) => Course.fromMap(d.id, d.data())).toList(),
    );
  }

  Future<List<Course>> fetchCoursesForTeacher(String teacherUid) async {
    final snap = await _db
        .collection(_coursesCollection)
        .where('teacherUid', isEqualTo: teacherUid)
        .get();
    return _resolveCurrentTeacherNames(
      snap.docs.map((d) => Course.fromMap(d.id, d.data())).toList(),
    );
  }

  Future<List<Course>> fetchCoursesForStudent(AppUser student) async {
    final grade = student.role?.label;
    if (!student.isStudent || grade == null || student.sections.isEmpty) {
      return const <Course>[];
    }

    final snapshot = await _db
        .collection(_coursesCollection)
        .where('grade', isEqualTo: grade)
        .get();
    final courses = snapshot.docs
        .map((document) => Course.fromMap(document.id, document.data()))
        .where(
          (course) => CourseAssignment.courseMatchesStudent(course, student),
        )
        .toList();
    final resolvedCourses = await _resolveCurrentTeacherNames(courses);
    final attempts = await fetchAttemptsForStudent(student.id);
    return _applyStudentProgress(resolvedCourses, attempts);
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
      'sections': course.sections,
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
    String uploadedByUid = '',
    required String uploadedByName,
    List<String>? allowedExtensions,
  }) async {
    final typeGroup = XTypeGroup(
      label: 'documents',
      extensions: allowedExtensions,
    );
    final XFile? picked = await openFile(acceptedTypeGroups: [typeGroup]);
    if (picked == null) {
      return null;
    }

    final bytes = await picked.readAsBytes();
    final safeName = picked.name.replaceAll(RegExp(r'\s+'), '_');
    final storagePath =
        'course_modules/$courseId/${DateTime.now().millisecondsSinceEpoch}_$safeName';
    final ref = _storage.ref(storagePath);
    final snapshot = await ref.putData(bytes);
    final url = await snapshot.ref.getDownloadURL();

    final extension = safeName.contains('.')
        ? safeName.split('.').last.toLowerCase()
        : '';
    final module = CourseModule(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: picked.name,
      description: '',
      fileType: extension,
      uploadedByUid: uploadedByUid,
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
    if (course == null) {
      return;
    }
    final updated = [...course.modules, module];
    await _db.collection(_coursesCollection).doc(courseId).update({
      'modules': updated.map((m) => m.toMap()).toList(),
    });
  }

  Future<void> removeModule(String courseId, String moduleId) async {
    final courseRef = _db.collection(_coursesCollection).doc(courseId);
    var storagePath = '';

    await _db.runTransaction((transaction) async {
      final snapshot = await transaction.get(courseRef);
      final data = snapshot.data();
      if (!snapshot.exists || data == null) return;

      final rawModules = data['modules'];
      final modules = rawModules is List
          ? List<dynamic>.from(rawModules)
          : <dynamic>[];
      final updated = <dynamic>[];

      for (final rawModule in modules) {
        if (rawModule is Map && rawModule['id']?.toString() == moduleId) {
          if (storagePath.isEmpty) {
            storagePath = rawModule['storagePath']?.toString() ?? '';
          }
        } else {
          updated.add(rawModule);
        }
      }

      transaction.update(courseRef, {'modules': updated});
    });

    if (storagePath.isNotEmpty) {
      try {
        await _storage.ref(storagePath).delete();
      } catch (_) {}
    }
  }

  Future<void> updateModule(String courseId, CourseModule module) async {
    final course = await _fetchOne(courseId);
    if (course == null) {
      return;
    }
    final updated = course.modules
        .map((m) => m.id == module.id ? module : m)
        .toList();
    await _db.collection(_coursesCollection).doc(courseId).update({
      'modules': updated.map((m) => m.toMap()).toList(),
    });
  }

  // ---- Quizzes ----

  Future<void> addQuiz(String courseId, CourseQuiz quiz) async {
    final course = await _fetchOne(courseId);
    if (course == null) {
      return;
    }
    final updated = [...course.quizzes, quiz];
    await _db.collection(_coursesCollection).doc(courseId).update({
      'quizzes': updated.map((q) => q.toMap()).toList(),
    });
  }

  Future<void> updateQuiz(String courseId, CourseQuiz quiz) async {
    final course = await _fetchOne(courseId);
    if (course == null) {
      return;
    }
    final updated = course.quizzes
        .map((q) => q.id == quiz.id ? quiz : q)
        .toList();
    await _db.collection(_coursesCollection).doc(courseId).update({
      'quizzes': updated.map((q) => q.toMap()).toList(),
    });
  }

  Future<void> removeQuiz(String courseId, String quizId) async {
    final courseRef = _db.collection(_coursesCollection).doc(courseId);
    await _db.runTransaction((transaction) async {
      final snapshot = await transaction.get(courseRef);
      final data = snapshot.data();
      if (!snapshot.exists || data == null) return;

      final rawQuizzes = data['quizzes'];
      final quizzes = rawQuizzes is List
          ? List<dynamic>.from(rawQuizzes)
          : <dynamic>[];
      final updated = quizzes.where((rawQuiz) {
        return rawQuiz is! Map || rawQuiz['id']?.toString() != quizId;
      }).toList();

      transaction.update(courseRef, {'quizzes': updated});
    });
  }

  Future<Course?> _fetchOne(String courseId) async {
    final doc = await _db.collection(_coursesCollection).doc(courseId).get();
    if (!doc.exists) {
      return null;
    }
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
        .map(
          (snap) => snap.docs
              .map((d) => QuizAttempt.fromMap(d.id, d.data()))
              .toList(),
        );
  }

  Future<List<QuizAttempt>> fetchAttemptsForStudent(String studentId) async {
    final snap = await _db
        .collection(_attemptsCollection)
        .where('studentId', isEqualTo: studentId)
        .get();
    return snap.docs.map((d) => QuizAttempt.fromMap(d.id, d.data())).toList();
  }
}
