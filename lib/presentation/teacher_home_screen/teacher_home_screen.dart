import 'dart:async';
import 'dart:ui';
import 'package:fl_chart/fl_chart.dart';

import '../../core/app_export.dart';
import '../../core/course_assignment.dart';
import '../../data/dummy_ar_experiments.dart';
import '../../widgets/dashboard_datetime_card.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/user_model.dart';
import '../../models/course_model.dart';
import '../../models/activity_model.dart';
import 'widgets/student_approval_dialog.dart';
import '../../services/auth_service.dart';
import 'package:provider/provider.dart';

// ── Reuse data models from teacher_progress_screen ────────────────────────────
class _StudentSummary {
  final String id;
  final String name;
  final String section;
  final String? studentNumber;
  final String? avatarUrl;
  final double avgQuizScore; // 0.0 – 1.0
  final double avgArScore; // 0.0 – 100.0
  final int quizzesTaken;
  final int arAttempts;

  const _StudentSummary({
    required this.id,
    required this.name,
    required this.section,
    this.studentNumber,
    this.avatarUrl,
    required this.avgQuizScore,
    required this.avgArScore,
    required this.quizzesTaken,
    required this.arAttempts,
  });

  double get overallScore {
    var total = 0.0;
    var metricCount = 0;
    if (quizzesTaken > 0) {
      total += avgQuizScore * 100;
      metricCount++;
    }
    if (arAttempts > 0) {
      total += avgArScore;
      metricCount++;
    }
    return metricCount == 0 ? 0 : total / metricCount;
  }

  Color get performanceColor {
    if (overallScore >= 80) return const Color(0xFF00D4FF);
    if (overallScore >= 60) return const Color(0xFF7C3AED);
    return const Color(0xFFFF6B6B);
  }

  String get performanceLabel {
    if (overallScore >= 80) return 'Excellent';
    if (overallScore >= 60) return 'Good';
    return 'Needs Help';
  }
}

enum DashboardTab { allStudents, needsHelp, classAvg }

class TeacherHomeScreen extends StatefulWidget {
  const TeacherHomeScreen({super.key});

  @override
  State<TeacherHomeScreen> createState() => _TeacherHomeScreenState();
}

class _TeacherHomeScreenState extends State<TeacherHomeScreen>
    with SingleTickerProviderStateMixin {
  static const String _allSummarySections = 'All Sections';
  static const double _notificationCardHeight = 116;
  static const double _notificationListMaxHeight =
      (_notificationCardHeight * 4) + (12 * 3);

  late AnimationController _entranceController;
  late Timer _clockTimer;
  DateTime _now = DateTime.now().toUtc().add(const Duration(hours: 8));

  List<_StudentSummary> _students = [];
  bool _loading = true;
  DashboardTab _currentTab = DashboardTab.allStudents;
  String _selectedSummarySection = _allSummarySections;

  StreamSubscription? _usersSub;
  StreamSubscription? _approvedStudentsSub;
  final List<StreamSubscription> _quizNotifSubs = [];
  final Map<String, StreamSubscription> _arNotifSubs = {};
  StreamSubscription? _teacherCoursesSub;

  List<QueryDocumentSnapshot<Map<String, dynamic>>> _pendingUsers = [];
  final Map<int, List<QueryDocumentSnapshot<Map<String, dynamic>>>>
  _quizAttemptChunks = {};
  final Map<String, List<QueryDocumentSnapshot<Map<String, dynamic>>>>
  _arAttemptsByStudent = {};
  final Map<String, AppUser> _approvedStudentsById = {};
  List<QuizAttempt> _notificationQuizAttempts = [];
  List<Map<String, dynamic>> _notifications = [];
  int _quizSubscriptionGeneration = 0;

  List<Course> _teacherCourses = [];
  List<QuizAttempt> _allAttempts = [];

  final Map<String, DateTime> _pendingUserTimestamps = {};

  List<QuizAttempt> _latestAttemptsForStudent(
    Iterable<QuizAttempt> attempts,
    String studentId,
  ) {
    final latestByQuiz = <String, QuizAttempt>{};
    for (final attempt in attempts) {
      if (attempt.studentId != studentId ||
          attempt.quizId.isEmpty ||
          attempt.totalQuestions <= 0) {
        continue;
      }

      final current = latestByQuiz[attempt.quizId];
      final submittedAt = attempt.submittedAt ?? DateTime(2000);
      final currentSubmittedAt = current?.submittedAt ?? DateTime(2000);
      if (current == null || !submittedAt.isBefore(currentSubmittedAt)) {
        latestByQuiz[attempt.quizId] = attempt;
      }
    }
    return latestByQuiz.values.toList();
  }

  double _averageQuizScore(List<QuizAttempt> attempts) {
    if (attempts.isEmpty) return 0;
    final total = attempts.fold<double>(
      0,
      (totalValue, attempt) =>
          totalValue + (attempt.score / attempt.totalQuestions),
    );
    return total / attempts.length;
  }

  void _applyLiveQuizAttempts(List<QuizAttempt> attempts) {
    if (!mounted) return;

    setState(() {
      _allAttempts = attempts;
      _students = _students.map((student) {
        final studentAttempts = _latestAttemptsForStudent(attempts, student.id);
        return _StudentSummary(
          id: student.id,
          name: student.name,
          section: student.section,
          studentNumber: student.studentNumber,
          avatarUrl: student.avatarUrl,
          avgQuizScore: _averageQuizScore(studentAttempts),
          avgArScore: student.avgArScore,
          quizzesTaken: studentAttempts.length,
          arAttempts: student.arAttempts,
        );
      }).toList();
    });
    _updateNotifs();
  }

  Future<void> _loadData() async {
    try {
      final db = FirebaseFirestore.instance;
      final teacher = context.read<AuthService>().currentUser;
      if (teacher == null) {
        if (mounted) setState(() => _loading = false);
        return;
      }

      final coursesSnap = await db
          .collection('courses')
          .where('teacherUid', isEqualTo: teacher.id)
          .get();
      final courses = coursesSnap.docs
          .map((document) => Course.fromMap(document.id, document.data()))
          .toList();

      final studentsSnap = await db
          .collection('users')
          .where('role', whereIn: [UserRole.grade9.id, UserRole.grade10.id])
          .where('status', isEqualTo: VerificationStatus.approved.id)
          .get();

      final users = studentsSnap.docs
          .map((document) => AppUser.fromMap(document.id, document.data()))
          .where(
            (student) => courses.any(
              (course) =>
                  CourseAssignment.courseMatchesStudent(course, student),
            ),
          )
          .toList();

      final attemptsSnap = await db.collection('quiz_attempts').get();
      final coursesById = {for (final course in courses) course.id: course};
      final usersById = {for (final student in users) student.id: student};
      final allAttempts = attemptsSnap.docs
          .map((document) => QuizAttempt.fromMap(document.id, document.data()))
          .where((attempt) {
            final course = coursesById[attempt.courseId];
            final student = usersById[attempt.studentId];
            return course != null &&
                student != null &&
                CourseAssignment.courseMatchesStudent(course, student);
          })
          .toList();

      if (mounted) {
        _allAttempts = allAttempts;
      }

      List<_StudentSummary> dynamicStudents = [];
      for (var u in users) {
        final uAttempts = _latestAttemptsForStudent(allAttempts, u.id);
        final avgQuizScore = _averageQuizScore(uAttempts);

        int arAttempts = 0;
        double avgArScore = 0.0;
        try {
          final uArSnap = await db
              .collection('users')
              .doc(u.id)
              .collection('experiment_activity')
              .get();
          arAttempts = uArSnap.docs.length;
          int completed = 0;
          for (var d in uArSnap.docs) {
            final act = ExperimentActivity.fromMap(d.id, d.data());
            if (act.completed) completed++;
          }
          if (arAttempts > 0) {
            avgArScore = (completed / arAttempts) * 100.0;
          }
        } catch (e) {
          print('Error fetching AR records for ${u.id}: $e');
        }

        final matchingSections = courses
            .expand(
              (course) =>
                  CourseAssignment.matchingSectionsForStudent(course, u),
            )
            .toSet()
            .toList();
        final section = matchingSections.isNotEmpty
            ? matchingSections.first
            : (u.sections.isNotEmpty ? u.sections.first : 'No Section');

        dynamicStudents.add(
          _StudentSummary(
            id: u.id,
            name: u.name,
            section: section,
            studentNumber: u.studentNumber,
            avatarUrl: u.avatarUrl,
            avgQuizScore: avgQuizScore,
            avgArScore: avgArScore,
            quizzesTaken: uAttempts.length,
            arAttempts: arAttempts,
          ),
        );
      }

      if (mounted) {
        final loadedSections = dynamicStudents.map((s) => s.section).toSet();
        setState(() {
          _students = dynamicStudents;
          if (_selectedSummarySection != _allSummarySections &&
              !loadedSections.contains(_selectedSummarySection)) {
            _selectedSummarySection = _allSummarySections;
          }
          _loading = false;
        });
        _updateNotifs();
      }
    } catch (e) {
      print('Error loading dynamic progress: $e');
      if (mounted) {
        setState(() {
          _loading = false;
        });
      }
    }
  }

  double get _classAvgScore {
    if (_students.isEmpty) return 0;
    return _students.map((s) => s.overallScore).reduce((a, b) => a + b) /
        _students.length;
  }

  int get _needsHelpCount => _students.where((s) => s.overallScore < 60).length;

  bool _isSearching = false;
  String _searchQuery = '';
  String _selectedChartSection = 'All';
  final TextEditingController _searchCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadData();
    _entranceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    )..forward();
    _clockTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      setState(() {
        _now = DateTime.now().toUtc().add(const Duration(hours: 8));
      });
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initNotificationStreams();
    });
  }

  bool _studentMatchesAnyTeacherCourse(AppUser student) {
    if (_teacherCourses.isNotEmpty) {
      return _teacherCourses.any(
        (course) => CourseAssignment.courseMatchesStudent(course, student),
      );
    }
    // Fallback: use teacher's own sections field when no courses are assigned yet
    final user = context.read<AuthService>().currentUser;
    if (user == null) return false;
    return student.sections.any((s) => user.sections.contains(s));
  }

  Set<String> get _handledStudentIds => _approvedStudentsById.values
      .where(_studentMatchesAnyTeacherCourse)
      .map((student) => student.id)
      .toSet();

  String _matchingSectionLabel(AppUser student, [Course? course]) {
    final matches = course == null
        ? _teacherCourses
              .expand(
                (item) =>
                    CourseAssignment.matchingSectionsForStudent(item, student),
              )
              .toSet()
              .toList()
        : CourseAssignment.matchingSectionsForStudent(course, student);
    if (matches.isNotEmpty) return matches.join(', ');
    return student.sections.isNotEmpty ? student.sections.first : 'No Section';
  }

  void _initNotificationStreams() {
    final db = FirebaseFirestore.instance;
    final user = context.read<AuthService>().currentUser;
    if (user == null) return;

    _teacherCoursesSub = db
        .collection('courses')
        .where('teacherUid', isEqualTo: user.id)
        .snapshots()
        .listen(
          (snapshot) {
            if (!mounted) return;
            final courses = snapshot.docs
                .map((document) => Course.fromMap(document.id, document.data()))
                .toList();
            setState(() {
              _teacherCourses = courses;
            });
            _refreshQuizAttemptSubscriptions(db);
            _refreshArActivitySubscriptions(db);
            _updateNotifs();
          },
          onError: (Object error) {
            debugPrint('Teacher course notification stream failed: $error');
          },
        );

    _usersSub = db
        .collection('users')
        .where('role', whereIn: [UserRole.grade9.id, UserRole.grade10.id])
        .where('status', isEqualTo: VerificationStatus.pending.id)
        .snapshots()
        .listen(
          (snapshot) {
            if (!mounted) return;
            _pendingUsers = snapshot.docs;
            _updateNotifs();
          },
          onError: (Object error) {
            debugPrint('Pending-student notification stream failed: $error');
          },
        );

    _approvedStudentsSub = db
        .collection('users')
        .where('role', whereIn: [UserRole.grade9.id, UserRole.grade10.id])
        .where('status', isEqualTo: VerificationStatus.approved.id)
        .snapshots()
        .listen(
          (snapshot) {
            if (!mounted) return;
            _approvedStudentsById
              ..clear()
              ..addEntries(
                snapshot.docs.map((document) {
                  final student = AppUser.fromMap(document.id, document.data());
                  return MapEntry(student.id, student);
                }),
              );
            _applyCurrentQuizAttempts();
            _refreshArActivitySubscriptions(db);
            _updateNotifs();
          },
          onError: (Object error) {
            debugPrint('Approved-student notification stream failed: $error');
          },
        );
  }

  void _refreshQuizAttemptSubscriptions(FirebaseFirestore db) {
    final generation = ++_quizSubscriptionGeneration;
    for (final subscription in _quizNotifSubs) {
      unawaited(subscription.cancel());
    }
    _quizNotifSubs.clear();
    _quizAttemptChunks.clear();

    final courseIds = _teacherCourses
        .map((course) => course.id)
        .where((id) => id.isNotEmpty)
        .toList();
    if (courseIds.isEmpty) {
      // No courses assigned: fall back to section-based quiz attempt filtering
      _subscribeQuizAttemptsBySections(db, generation);
      return;
    }

    const chunkSize = 30;
    for (
      var start = 0, chunkIndex = 0;
      start < courseIds.length;
      start += chunkSize, chunkIndex++
    ) {
      final end = start + chunkSize > courseIds.length
          ? courseIds.length
          : start + chunkSize;
      final chunk = courseIds.sublist(start, end);
      final currentChunk = chunkIndex;
      final subscription = db
          .collection('quiz_attempts')
          .where('courseId', whereIn: chunk)
          .snapshots()
          .listen(
            (snapshot) {
              if (!mounted || generation != _quizSubscriptionGeneration) return;
              _quizAttemptChunks[currentChunk] = snapshot.docs;
              _applyCurrentQuizAttempts();
            },
            onError: (Object error) {
              debugPrint('Quiz notification stream failed: $error');
              if (!mounted || generation != _quizSubscriptionGeneration) return;
              _quizAttemptChunks[currentChunk] = [];
              _applyCurrentQuizAttempts();
            },
          );
      _quizNotifSubs.add(subscription);
    }
  }

  void _subscribeQuizAttemptsBySections(FirebaseFirestore db, int generation) {
    // When teacher has no courses yet, subscribe to ALL quiz_attempts and
    // filter in-memory by whether the student belongs to the teacher's sections.
    final subscription = db
        .collection('quiz_attempts')
        .orderBy('submittedAt', descending: true)
        .snapshots()
        .listen(
          (snapshot) {
            if (!mounted || generation != _quizSubscriptionGeneration) return;
            _quizAttemptChunks[0] = snapshot.docs;
            _applyCurrentQuizAttempts();
          },
          onError: (Object error) {
            debugPrint('Section-based quiz notification stream failed: $error');
          },
        );
    _quizNotifSubs.add(subscription);
  }

  void _applyCurrentQuizAttempts() {
    final coursesById = {
      for (final course in _teacherCourses) course.id: course,
    };
    final attempts = <QuizAttempt>[];
    for (final document in _quizAttemptChunks.values.expand((docs) => docs)) {
      final attempt = QuizAttempt.fromMap(document.id, document.data());
      final student = _approvedStudentsById[attempt.studentId];
      if (student == null) continue;
      if (coursesById.isNotEmpty) {
        // Prefer strict course-based matching
        final course = coursesById[attempt.courseId];
        if (course == null ||
            !CourseAssignment.courseMatchesStudent(course, student))
          continue;
      } else {
        // Fallback: student must be in one of the teacher's sections
        if (!_studentMatchesAnyTeacherCourse(student)) continue;
      }
      attempts.add(attempt);
    }
    attempts.sort(
      (a, b) => (b.submittedAt ?? DateTime(2000)).compareTo(
        a.submittedAt ?? DateTime(2000),
      ),
    );
    _notificationQuizAttempts = attempts;
    _applyLiveQuizAttempts(attempts);
  }

  void _refreshArActivitySubscriptions(FirebaseFirestore db) {
    final desiredStudentIds = _handledStudentIds;
    final removedStudentIds = _arNotifSubs.keys
        .where((studentId) => !desiredStudentIds.contains(studentId))
        .toList();

    for (final studentId in removedStudentIds) {
      final subscription = _arNotifSubs.remove(studentId);
      if (subscription != null) unawaited(subscription.cancel());
      _arAttemptsByStudent.remove(studentId);
    }

    for (final studentId in desiredStudentIds) {
      if (_arNotifSubs.containsKey(studentId)) continue;
      _arNotifSubs[studentId] = db
          .collection('users')
          .doc(studentId)
          .collection('experiment_activity')
          .snapshots()
          .listen(
            (snapshot) {
              if (!mounted || !_handledStudentIds.contains(studentId)) return;
              _arAttemptsByStudent[studentId] = snapshot.docs;
              _updateNotifs();
            },
            onError: (Object error) {
              debugPrint(
                'AR notification stream failed for $studentId: $error',
              );
              if (!mounted) return;
              _arAttemptsByStudent[studentId] = [];
              _updateNotifs();
            },
          );
    }
    _updateNotifs();
  }

  String _arExperimentTitle(String experimentId) {
    for (final experiment in dummyArExperiments) {
      if (experiment.id == experimentId) return experiment.title;
    }
    final label = experimentId
        .replaceAll(RegExp(r'[_-]+'), ' ')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
    if (label.isEmpty) return 'AR experiment';
    return label
        .split(' ')
        .map(
          (word) => word.isEmpty
              ? word
              : '${word[0].toUpperCase()}${word.substring(1)}',
        )
        .join(' ');
  }

  void _updateNotifs() {
    if (!mounted) return;
    final user = context.read<AuthService>().currentUser;
    if (user == null) return;

    final notifications = <Map<String, dynamic>>[];
    final teacherSections = user.sections;

    // Pending approvals stay section-scoped. Once courses are available, use
    // their grade + section assignment so Grade 9 A never matches Grade 10 A.
    for (final document in _pendingUsers) {
      final student = AppUser.fromMap(document.id, document.data());
      final belongsToTeacher = _teacherCourses.isNotEmpty
          ? _studentMatchesAnyTeacherCourse(student)
          : student.sections.any(teacherSections.contains);
      if (belongsToTeacher) {
        if (!_pendingUserTimestamps.containsKey(student.id)) {
          _pendingUserTimestamps[student.id] = DateTime.now();
        }
        notifications.add({
          'id': 'teacher-pending-student:${student.id}',
          'title': 'New Student Approval',
          'desc':
              '${student.name} requested to join ${_matchingSectionLabel(student)}.',
          'icon': 'person_add',
          'color': const Color(0xFF7C3AED),
          'timeStr': _formatNotificationTime(
            _pendingUserTimestamps[student.id],
          ),
          'timestamp': _pendingUserTimestamps[student.id]!,
          'action': 'approval',
        });
      }
    }

    final coursesById = {
      for (final course in _teacherCourses) course.id: course,
    };

    // Every quiz event must belong to this teacher's course and that exact
    // course must match the student's grade and section.
    for (final attempt in _notificationQuizAttempts) {
      final student = _approvedStudentsById[attempt.studentId];
      final course = coursesById[attempt.courseId];
      if (student == null ||
          course == null ||
          !CourseAssignment.courseMatchesStudent(course, student)) {
        continue;
      }
      final total = attempt.totalQuestions;
      final percent = total > 0 ? ((attempt.score / total) * 100).round() : 0;
      final submittedAt = attempt.submittedAt ?? DateTime(2000);
      notifications.add({
        'id': 'teacher-quiz-attempt:${attempt.id}',
        'title': 'Quiz Submitted',
        'desc':
            '${student.name} (${_matchingSectionLabel(student, course)}) '
            'answered "${attempt.quizTitle}" — '
            '${attempt.score}/$total ($percent%).',
        'icon': 'assignment_turned_in',
        'color': const Color(0xFF00D4FF),
        'timeStr': attempt.submittedAt == null
            ? ''
            : _formatNotificationTime(submittedAt),
        'timestamp': submittedAt,
      });
    }

    // AR activity stores launchedAt/completedAt in each student's nested
    // collection. A newer launch means the student started a new simulation.
    for (final entry in _arAttemptsByStudent.entries) {
      final student = _approvedStudentsById[entry.key];
      if (student == null || !_studentMatchesAnyTeacherCourse(student)) {
        continue;
      }
      for (final document in entry.value) {
        final data = document.data();
        final launchedAt = data['launchedAt'] is Timestamp
            ? (data['launchedAt'] as Timestamp).toDate()
            : null;
        final completedAt = data['completedAt'] is Timestamp
            ? (data['completedAt'] as Timestamp).toDate()
            : null;
        if (launchedAt == null && completedAt == null) continue;

        final isCompletion =
            completedAt != null &&
            (launchedAt == null || !completedAt.isBefore(launchedAt));
        final eventAt = isCompletion ? completedAt : launchedAt;
        if (eventAt == null) continue;
        final experimentTitle = _arExperimentTitle(document.id);
        final section = _matchingSectionLabel(student);
        notifications.add({
          'id':
              'teacher-ar:${student.id}:${document.id}:${isCompletion ? 'completed' : 'launched'}:${eventAt.millisecondsSinceEpoch}',
          'title': isCompletion ? 'AR Lab Completed' : 'AR Lab Simulated',
          'desc': isCompletion
              ? '${student.name} ($section) completed "$experimentTitle".'
              : '${student.name} ($section) started "$experimentTitle".',
          'icon': 'view_in_ar',
          'color': isCompletion
              ? const Color(0xFF22C55E)
              : const Color(0xFFFFB300),
          'timeStr': _formatNotificationTime(eventAt),
          'timestamp': eventAt,
        });
      }
    }

    // Missed quizzes use the same exact teacher/course/student assignment.
    final missedQuizzes = <String, List<String>>{};
    final missedQuizTitles = <String, String>{};
    final missedQuizTimes = <String, DateTime>{};
    for (final student in _approvedStudentsById.values) {
      for (final course in _teacherCourses) {
        if (!CourseAssignment.courseMatchesStudent(course, student)) continue;
        for (final quiz in course.quizzes) {
          final dueDate = quiz.dueDate;
          if (dueDate == null || !dueDate.isBefore(DateTime.now())) continue;
          final hasAttempted = _allAttempts.any(
            (attempt) =>
                attempt.courseId == course.id &&
                attempt.quizId == quiz.id &&
                attempt.studentId == student.id,
          );
          if (!hasAttempted) {
            final key = '${course.id}/${quiz.id}';
            missedQuizzes.putIfAbsent(key, () => []).add(student.id);
            missedQuizTitles[key] = quiz.title;
            missedQuizTimes[key] = dueDate;
          }
        }
      }
    }
    for (final entry in missedQuizzes.entries) {
      final title = missedQuizTitles[entry.key] ?? 'Quiz';
      final studentIds = entry.value;
      final count = studentIds.length;
      final dueDate = missedQuizTimes[entry.key] ?? DateTime(2000);
      final firstStudent = _approvedStudentsById[studentIds.first];
      notifications.add({
        'id':
            'teacher-missed-quiz:${entry.key}:${dueDate.millisecondsSinceEpoch}',
        'title': 'Quiz Missed',
        'desc': count == 1
            ? '${firstStudent?.name ?? 'A student'} missed "$title".'
            : '$count students missed "$title".',
        'icon': 'warning',
        'color': const Color(0xFFFF4757),
        'timeStr': _formatNotificationTime(dueDate),
        'timestamp': dueDate,
      });
    }

    notifications.sort(
      (a, b) =>
          (b['timestamp'] as DateTime).compareTo(a['timestamp'] as DateTime),
    );
    setState(() {
      _notifications = notifications;
    });
  }

  @override
  void dispose() {
    _quizSubscriptionGeneration++;
    _usersSub?.cancel();
    _approvedStudentsSub?.cancel();
    for (final sub in _quizNotifSubs) {
      sub.cancel();
    }
    for (final sub in _arNotifSubs.values) {
      sub.cancel();
    }
    _teacherCoursesSub?.cancel();
    _searchCtrl.dispose();
    _entranceController.dispose();
    _clockTimer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final summarySections =
        _students
            .map((student) => student.section.trim())
            .where((section) => section.isNotEmpty && section != 'No Section')
            .toSet()
            .toList()
          ..sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));
    final summarySectionOptions = <String>[
      _allSummarySections,
      ...summarySections,
    ];
    final selectedSummarySection =
        summarySectionOptions.contains(_selectedSummarySection)
        ? _selectedSummarySection
        : _allSummarySections;

    List<_StudentSummary> activeStudents = _students;
    if (!_isSearching && _currentTab == DashboardTab.needsHelp) {
      activeStudents = _students.where((s) => s.overallScore < 60).toList();
    }
    if (!_isSearching && selectedSummarySection != _allSummarySections) {
      activeStudents = activeStudents
          .where((student) => student.section == selectedSummarySection)
          .toList();
    }

    final filteredStudents = activeStudents.where((s) {
      final q = _searchQuery.toLowerCase();
      return s.name.toLowerCase().contains(q) ||
          s.section.toLowerCase().contains(q) ||
          (s.studentNumber != null &&
              s.studentNumber!.toLowerCase().contains(q));
    }).toList();

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        bottom: false,
        child: Stack(
          children: [
            _loading
                ? const Center(
                    child: CircularProgressIndicator(color: Color(0xFF00D4FF)),
                  )
                : CustomScrollView(
                    slivers: [
                      SliverToBoxAdapter(child: _buildHeader()),
                      if (!_isSearching)
                        SliverToBoxAdapter(child: _buildDateTimeCard()),
                      if (!_isSearching)
                        SliverToBoxAdapter(child: _buildClassOverview()),
                      if (!_isSearching &&
                          _currentTab == DashboardTab.classAvg)
                        SliverToBoxAdapter(child: _buildClassAvgChart())
                      else ...[
                        SliverToBoxAdapter(
                          child: _isSearching
                              ? _buildSearchResultsLabel(
                                  filteredStudents.length,
                                )
                              : _buildSectionLabel(
                                  'Student Progress Summary',
                                  sectionOptions: summarySectionOptions,
                                  selectedSection: selectedSummarySection,
                                ),
                        ),
                        filteredStudents.isEmpty
                            ? SliverToBoxAdapter(
                                child: Padding(
                                  padding: const EdgeInsets.only(top: 40),
                                  child: Center(
                                    child: Text(
                                      _isSearching
                                          ? _searchQuery.trim().isNotEmpty
                                                ? 'No students match your search'
                                                : 'No students found'
                                          : selectedSummarySection !=
                                                _allSummarySections
                                          ? 'No students found in Section $selectedSummarySection'
                                          : _currentTab ==
                                                DashboardTab.needsHelp
                                          ? 'No students currently need help'
                                          : 'No students found',
                                      style: TextStyle(
                                        color:
                                            Theme.of(context).brightness ==
                                                Brightness.dark
                                            ? const Color(0xFF8BA3C0)
                                            : Colors.grey.shade600,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ),
                                ),
                              )
                            : SliverList(
                                delegate: SliverChildBuilderDelegate((
                                  context,
                                  index,
                                ) {
                                  final delay = index * 80;
                                  return AnimatedBuilder(
                                    animation: _entranceController,
                                    builder: (context, child) {
                                      final slide =
                                          Tween<Offset>(
                                            begin: const Offset(0, 0.15),
                                            end: Offset.zero,
                                          ).animate(
                                            CurvedAnimation(
                                              parent: _entranceController,
                                              curve: Interval(
                                                (delay / 700).clamp(0.0, 0.8),
                                                ((delay + 300) / 700).clamp(
                                                  0.0,
                                                  1.0,
                                                ),
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
                                      padding: const EdgeInsets.fromLTRB(
                                        20,
                                        0,
                                        20,
                                        12,
                                      ),
                                      child: _StudentProgressCard(
                                        student: filteredStudents[index],
                                        showBadge:
                                            !_isSearching &&
                                            _currentTab ==
                                            DashboardTab.needsHelp,
                                      ),
                                    ),
                                  );
                                }, childCount: filteredStudents.length),
                              ),
                      ],
                      const SliverToBoxAdapter(child: SizedBox(height: 140)),
                    ],
                  ),
            if (!_isSearching)
              Positioned(
              bottom: 124,
              right: 20,
              child: FloatingActionButton(
                heroTag: null,
                onPressed: () async {
                  final result = await showDialog(
                    context: context,
                    builder: (_) => const StudentApprovalDialog(),
                  );
                  if (result == true) {
                    _loadData();
                  }
                },
                backgroundColor: Theme.of(context).brightness == Brightness.dark
                    ? const Color(0xFF00D4FF)
                    : const Color(0xFF1565C0),
                elevation: 8,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: CustomIconWidget(
                  iconName: 'person_add_outlined',
                  color: Theme.of(context).brightness == Brightness.dark
                      ? const Color(0xFF0A1628)
                      : Colors.white,
                  size: 28,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    final user = context.watch<AuthService>().currentUser;
    final savedTeacherName = user?.name.trim() ?? '';
    final teacherName = savedTeacherName.isEmpty ? 'Teacher' : savedTeacherName;
    final lastRead = user?.lastNotificationReadAt ?? DateTime(2000);
    final clearedAt = user?.notificationsClearedAt;
    final dismissedIds = user?.dismissedNotificationIds.toSet() ?? <String>{};
    final visibleNotifications = _notifications
        .where((notification) {
          final notificationId = notification['id'] as String?;
          final isAfterClear =
              clearedAt == null ||
              (notification['timestamp'] as DateTime).isAfter(clearedAt);
          final isDismissed =
              notificationId != null && dismissedIds.contains(notificationId);
          return isAfterClear && !isDismissed;
        })
        .take(50)
        .toList(growable: false);
    final hasUnread = visibleNotifications.any(
      (notification) =>
          (notification['timestamp'] as DateTime).isAfter(lastRead),
    );

    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
          color: Theme.of(context).brightness == Brightness.dark
              ? const Color(0xFF0A1628).withAlpha(204)
              : Colors.white.withAlpha(204),
          child: Row(
            children: [
              GestureDetector(
                onTap: () {
                  context.go('/teacher-profile-screen');
                },
                child: Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: const Color(0xFF7C3AED).withAlpha(153),
                      width: 2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF7C3AED).withAlpha(80),
                        blurRadius: 12,
                      ),
                    ],
                  ),
                  child: ClipOval(
                    child: Builder(
                      builder: (context) {
                        final avatarUrl = context
                            .watch<AuthService>()
                            .currentUser
                            ?.avatarUrl;
                        Widget fallback = Container(
                          decoration: const BoxDecoration(
                            gradient: LinearGradient(
                              colors: [Color(0xFF7C3AED), Color(0xFF00D4FF)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                          ),
                          child: const Center(
                            child: CustomIconWidget(
                              iconName: 'school',
                              color: Colors.white,
                              size: 24,
                            ),
                          ),
                        );
                        if (avatarUrl != null && avatarUrl.isNotEmpty) {
                          return Image.network(
                            avatarUrl,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => fallback,
                          );
                        }
                        return fallback;
                      },
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _isSearching
                    ? TextField(
                        controller: _searchCtrl,
                        style: TextStyle(
                          color: Theme.of(context).brightness == Brightness.dark
                              ? Colors.white
                              : Colors.black87,
                          fontSize: 14,
                        ),
                        decoration: InputDecoration(
                          hintText: 'Search students...',
                          hintStyle: TextStyle(
                            color:
                                Theme.of(context).brightness == Brightness.dark
                                ? const Color(0xFF8BA3C0)
                                : Colors.grey.shade600,
                          ),
                          border: InputBorder.none,
                          isDense: true,
                        ),
                        onChanged: (val) => setState(() => _searchQuery = val),
                        autofocus: true,
                      )
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            teacherName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color:
                                  Theme.of(context).brightness ==
                                      Brightness.dark
                                  ? Colors.white
                                  : Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 9,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color:
                                  Theme.of(context).brightness ==
                                      Brightness.dark
                                  ? const Color(0x2200FF88)
                                  : const Color(0x1A00994C),
                              borderRadius: BorderRadius.circular(50),
                              border: Border.all(
                                color:
                                    Theme.of(context).brightness ==
                                        Brightness.dark
                                    ? const Color(0x5500FF88)
                                    : const Color(0x4D00994C),
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                CustomIconWidget(
                                  iconName: 'verified',
                                  color:
                                      Theme.of(context).brightness ==
                                          Brightness.dark
                                      ? const Color(0xFF00FF88)
                                      : const Color(0xFF00994C),
                                  size: 12,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  'Teacher',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color:
                                        Theme.of(context).brightness ==
                                            Brightness.dark
                                        ? const Color(0xFF00FF88)
                                        : const Color(0xFF00994C),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
              ),
              GestureDetector(
                onTap: () {
                  setState(() {
                    _isSearching = !_isSearching;
                    if (!_isSearching) {
                      _searchCtrl.clear();
                      _searchQuery = '';
                    }
                  });
                },
                child: Container(
                  width: 44,
                  height: 44,
                  margin: const EdgeInsets.only(right: 8),
                  decoration: BoxDecoration(
                    color: Theme.of(context).brightness == Brightness.dark
                        ? const Color(0xFF142240)
                        : Colors.grey.shade100,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Theme.of(context).brightness == Brightness.dark
                          ? const Color(0xFF1E3A5F)
                          : Colors.grey.shade300,
                    ),
                  ),
                  child: Center(
                    child: CustomIconWidget(
                      iconName: _isSearching ? 'close' : 'search',
                      color: _isSearching
                          ? const Color(0xFFFF4757)
                          : (Theme.of(context).brightness == Brightness.dark
                                ? const Color(0xFF8BA3C0)
                                : Colors.grey.shade600),
                      size: 22,
                    ),
                  ),
                ),
              ),
              GestureDetector(
                onTap: () {
                  context.read<AuthService>().markNotificationsAsRead();
                  _showNotificationsDialog(context, visibleNotifications);
                },
                child: Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: Theme.of(context).brightness == Brightness.dark
                        ? const Color(0xFF142240)
                        : Colors.grey.shade100,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Theme.of(context).brightness == Brightness.dark
                          ? const Color(0xFF1E3A5F)
                          : Colors.grey.shade300,
                    ),
                  ),
                  child: Stack(
                    children: [
                      Center(
                        child: CustomIconWidget(
                          iconName: 'notifications_outlined',
                          color: Theme.of(context).brightness == Brightness.dark
                              ? const Color(0xFF8BA3C0)
                              : Colors.grey.shade600,
                          size: 22,
                        ),
                      ),
                      if (hasUnread)
                        Positioned(
                          top: 10,
                          right: 10,
                          child: Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              color: Color(0xFF00D4FF),
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatNotificationTime(DateTime? dt) {
    if (dt == null) return '';
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 60) return '${diff.inMinutes} mins ago';
    if (diff.inHours < 24) return '${diff.inHours} hrs ago';
    return '${diff.inDays} days ago';
  }

  // _fetchDynamicNotifications removed, replaced by Stream

  void _showNotificationsDialog(
    BuildContext context,
    List<Map<String, dynamic>> notifs,
  ) {
    final dialogNotifications = List<Map<String, dynamic>>.from(notifs);
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 24,
          ),
          child: Container(
            width: 400,
            constraints: BoxConstraints(
              maxHeight: MediaQuery.sizeOf(context).height * 0.75,
            ),
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Theme.of(context).brightness == Brightness.dark
                  ? const Color(0xFF142240)
                  : Colors.white,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: Theme.of(context).brightness == Brightness.dark
                    ? const Color(0xFF1E3A5F)
                    : Colors.grey.shade300,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: StatefulBuilder(
              builder: (context, setDialogState) => Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Row(
                          children: [
                            const CustomIconWidget(
                              iconName: 'notifications',
                              color: Color(0xFF7C3AED),
                              size: 24,
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                'Notifications',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w700,
                                  color:
                                      Theme.of(context).brightness ==
                                          Brightness.dark
                                      ? Colors.white
                                      : Colors.black87,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (dialogNotifications.isNotEmpty)
                            TextButton(
                              onPressed: () {
                                showDialog(
                                  context: context,
                                  builder: (confirmCtx) {
                                    final isDark =
                                        Theme.of(context).brightness ==
                                        Brightness.dark;
                                    return AlertDialog(
                                      backgroundColor: isDark
                                          ? const Color(0xFF142240)
                                          : Colors.white,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(16),
                                        side: BorderSide(
                                          color: isDark
                                              ? const Color(0xFF1E3A5F)
                                              : Colors.grey.shade300,
                                        ),
                                      ),
                                      title: Text(
                                        'Clear All Notifications',
                                        style: TextStyle(
                                          color: isDark
                                              ? Colors.white
                                              : Colors.black87,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                      content: Text(
                                        'Are you sure you want to clear all notifications?',
                                        style: TextStyle(
                                          color: isDark
                                              ? const Color(0xFF8BA3C0)
                                              : Colors.grey.shade700,
                                        ),
                                      ),
                                      actions: [
                                        TextButton(
                                          onPressed: () =>
                                              Navigator.pop(confirmCtx),
                                          child: const Text(
                                            'Cancel',
                                            style: TextStyle(
                                              color: Colors.grey,
                                            ),
                                          ),
                                        ),
                                        TextButton(
                                          onPressed: () {
                                            context
                                                .read<AuthService>()
                                                .clearAllNotifications();
                                            Navigator.pop(confirmCtx);
                                            Navigator.pop(context);
                                          },
                                          child: const Text(
                                            'Clear',
                                            style: TextStyle(
                                              color: Color(0xFFFF4757),
                                            ),
                                          ),
                                        ),
                                      ],
                                    );
                                  },
                                );
                              },
                              style: TextButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 8,
                                ),
                                minimumSize: Size.zero,
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              ),
                              child: Text(
                                'Clear All',
                                style: TextStyle(
                                  color:
                                      Theme.of(context).brightness ==
                                          Brightness.dark
                                      ? const Color(0xFF8BA3C0)
                                      : Colors.grey.shade600,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          if (dialogNotifications.isNotEmpty)
                            const SizedBox(width: 12),
                          GestureDetector(
                            onTap: () => Navigator.pop(context),
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color:
                                    Theme.of(context).brightness ==
                                        Brightness.dark
                                    ? const Color(0xFF0A1628)
                                    : Colors.grey.shade200,
                                shape: BoxShape.circle,
                              ),
                              child: CustomIconWidget(
                                iconName: 'close',
                                color:
                                    Theme.of(context).brightness ==
                                        Brightness.dark
                                    ? const Color(0xFF8BA3C0)
                                    : Colors.grey.shade600,
                                size: 16,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  if (dialogNotifications.isEmpty)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 20),
                      child: Text(
                        'No recent activity.',
                        style: TextStyle(color: Colors.grey),
                      ),
                    )
                  else
                    Flexible(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(
                          maxHeight: _notificationListMaxHeight,
                        ),
                        child: ListView.separated(
                          shrinkWrap: true,
                          itemCount: dialogNotifications.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(height: 12),
                          itemBuilder: (context, index) {
                            final notification = dialogNotifications[index];
                            final notificationId = notification['id'] as String;
                            return Dismissible(
                              key: ValueKey(notificationId),
                              direction: DismissDirection.endToStart,
                              background: _buildDismissBackground(),
                              onDismissed: (_) {
                                setDialogState(() {
                                  dialogNotifications.removeWhere(
                                    (item) => item['id'] == notificationId,
                                  );
                                });
                                unawaited(
                                  context
                                      .read<AuthService>()
                                      .dismissNotification(notificationId),
                                );
                              },
                              child: _buildNotificationItem(
                                notification['title'] as String,
                                notification['desc'] as String,
                                notification['icon'] as String,
                                notification['color'] as Color,
                                (notification['timeStr'] as String?) ?? '',
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildDismissBackground() {
    return Container(
      alignment: Alignment.centerRight,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: const Color(0xFFFF4757),
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Clear',
            style: TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(width: 8),
          CustomIconWidget(
            iconName: 'delete_outline',
            color: Colors.white,
            size: 20,
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationItem(
    String title,
    String desc,
    String icon,
    Color color,
    String time,
  ) {
    return SizedBox(
      height: _notificationCardHeight,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).brightness == Brightness.dark
              ? const Color(0xFF0A1628)
              : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Theme.of(context).brightness == Brightness.dark
                ? const Color(0xFF1E3A5F)
                : Colors.grey.shade300,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: CustomIconWidget(iconName: icon, color: color, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color:
                                Theme.of(context).brightness == Brightness.dark
                                ? Colors.white
                                : Colors.black87,
                          ),
                        ),
                      ),
                      Text(
                        time,
                        style: const TextStyle(
                          fontSize: 11,
                          color: Color(0xFF8BA3C0),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    desc,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF8BA3C0),
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDateTimeCard() {
    final calendarEvents = <DashboardCalendarEvent>[];
    for (final course in _teacherCourses) {
      for (final quiz in course.quizzes) {
        final quizDate = quiz.dueDate;
        if (quizDate == null) continue;
        calendarEvents.add(
          DashboardCalendarEvent(
            id: '${course.id}:${quiz.id}',
            quizName: quiz.title,
            courseName: course.title,
            dueDate: quizDate.toUtc().add(const Duration(hours: 8)),
          ),
        );
      }
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Teacher Dashboard',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).brightness == Brightness.dark
                  ? Colors.white
                  : Colors.black87,
            ),
          ),
          const SizedBox(height: 14),
          DashboardDateTimeCard(
            dateTime: _now,
            calendarEvents: calendarEvents,
            showTeacherQuizSummary: true,
          ),
        ],
      ),
    );
  }

  Widget _buildClassOverview() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Row(
        children: [
          Expanded(
            child: _StatCard(
              icon: 'groups',
              label: 'Total Students',
              value: '${_students.length}',
              color: _currentTab == DashboardTab.allStudents
                  ? (Theme.of(context).brightness == Brightness.dark
                        ? const Color(0xFF00D4FF)
                        : const Color(0xFF1565C0))
                  : (Theme.of(context).brightness == Brightness.dark
                            ? const Color(0xFF00D4FF)
                            : const Color(0xFF1565C0))
                        .withAlpha(128),
              onTap: () =>
                  setState(() => _currentTab = DashboardTab.allStudents),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _StatCard(
              icon: 'warning_amber',
              label: 'Needs Help',
              value: '$_needsHelpCount',
              color: _currentTab == DashboardTab.needsHelp
                  ? const Color(0xFFFF6B6B)
                  : const Color(0xFFFF6B6B).withAlpha(128),
              onTap: () => setState(() => _currentTab = DashboardTab.needsHelp),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _StatCard(
              icon: 'bar_chart',
              label: 'Class Avg',
              value: '${_classAvgScore.toStringAsFixed(0)}%',
              color: _currentTab == DashboardTab.classAvg
                  ? const Color(0xFF7C3AED)
                  : const Color(0xFF7C3AED).withAlpha(128),
              onTap: () => setState(() => _currentTab = DashboardTab.classAvg),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildClassAvgChart() {
    if (_students.isEmpty) {
      return Padding(
        padding: const EdgeInsets.only(top: 40),
        child: Center(
          child: Text(
            'No student data available',
            style: TextStyle(
              color: Theme.of(context).brightness == Brightness.dark
                  ? const Color(0xFF8BA3C0)
                  : Colors.grey.shade600,
              fontSize: 14,
            ),
          ),
        ),
      );
    }

    final sections = ['All'];
    for (var s in _students) {
      if (!sections.contains(s.section)) {
        sections.add(s.section);
      }
    }

    final List<String> xAxisLabels = [];
    final List<double> yValues = [];
    final List<Color> barColors = [];
    final List<String> tooltips = [];

    if (_selectedChartSection == 'All') {
      final Map<String, List<_StudentSummary>> grouped = {};
      for (var s in _students) {
        grouped.putIfAbsent(s.section, () => []).add(s);
      }

      final sortedSections = grouped.keys.toList()..sort();
      for (var sec in sortedSections) {
        final sectionStudents = grouped[sec]!;
        final avg =
            sectionStudents.map((s) => s.overallScore).reduce((a, b) => a + b) /
            sectionStudents.length;

        Color c = const Color(0xFF00D4FF);
        if (avg >= 80)
          c = const Color(0xFF00D4FF);
        else if (avg >= 60)
          c = const Color(0xFF7C3AED);
        else
          c = const Color(0xFFFF6B6B);

        String shortSec = sec.length > 10 ? sec.substring(0, 10) + '...' : sec;

        xAxisLabels.add(shortSec);
        yValues.add(avg);
        barColors.add(c);
        tooltips.add('Section $sec\nAvg: ${avg.toStringAsFixed(1)}%');
      }
    } else {
      final filteredStudents = _students
          .where((s) => s.section == _selectedChartSection)
          .toList();
      filteredStudents.sort((a, b) => a.name.compareTo(b.name));

      for (var s in filteredStudents) {
        String shortName = s.name.split(' ').first;
        if (shortName.length > 6) shortName = shortName.substring(0, 6) + '.';

        xAxisLabels.add(shortName);
        yValues.add(s.overallScore);
        barColors.add(s.performanceColor);
        tooltips.add(
          '${s.name}\n${s.section}\n${s.overallScore.toStringAsFixed(1)}%',
        );
      }
    }

    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Student Overall Scores',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: sections.map((sec) {
                final isSelected = _selectedChartSection == sec;
                return Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: InkWell(
                    onTap: () {
                      setState(() {
                        _selectedChartSection = sec;
                      });
                    },
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? const Color(0xFF00D4FF).withAlpha(40)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isSelected
                              ? const Color(0xFF00D4FF)
                              : (Theme.of(context).brightness == Brightness.dark
                                    ? const Color(0xFF1E3A5F)
                                    : Colors.grey.shade300),
                        ),
                      ),
                      child: Text(
                        sec == 'All' ? 'All Sections' : 'Section $sec',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: isSelected
                              ? FontWeight.bold
                              : FontWeight.normal,
                          color: isSelected
                              ? const Color(0xFF00D4FF)
                              : (Theme.of(context).brightness == Brightness.dark
                                    ? const Color(0xFF8BA3C0)
                                    : Colors.grey.shade600),
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 250,
            child: yValues.isEmpty
                ? Center(
                    child: Text(
                      'No data in this section',
                      style: TextStyle(
                        color: Theme.of(context).brightness == Brightness.dark
                            ? const Color(0xFF8BA3C0)
                            : Colors.grey.shade600,
                        fontSize: 14,
                      ),
                    ),
                  )
                : BarChart(
                    BarChartData(
                      alignment: BarChartAlignment.spaceAround,
                      maxY: 100,
                      barTouchData: BarTouchData(
                        enabled: true,
                        touchTooltipData: BarTouchTooltipData(
                          getTooltipItem: (group, groupIndex, rod, rodIndex) {
                            return BarTooltipItem(
                              tooltips[group.x],
                              const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            );
                          },
                        ),
                      ),
                      titlesData: FlTitlesData(
                        show: true,
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 40,
                            getTitlesWidget: (value, meta) {
                              if (value.toInt() >= 0 &&
                                  value.toInt() < xAxisLabels.length) {
                                return Padding(
                                  padding: const EdgeInsets.only(top: 8.0),
                                  child: Text(
                                    xAxisLabels[value.toInt()],
                                    style: const TextStyle(fontSize: 10),
                                  ),
                                );
                              }
                              return const Text('');
                            },
                          ),
                        ),
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 40,
                            getTitlesWidget: (value, meta) {
                              if (value % 20 != 0)
                                return const SizedBox.shrink();
                              return Text(
                                '${value.toInt()}',
                                style: TextStyle(
                                  fontSize: 10,
                                  color:
                                      Theme.of(context).brightness ==
                                          Brightness.dark
                                      ? const Color(0xFF8BA3C0)
                                      : Colors.grey.shade600,
                                ),
                              );
                            },
                          ),
                        ),
                        topTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        rightTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                      ),
                      borderData: FlBorderData(show: false),
                      gridData: FlGridData(
                        show: true,
                        drawVerticalLine: false,
                        getDrawingHorizontalLine: (value) => FlLine(
                          color: Theme.of(context).brightness == Brightness.dark
                              ? const Color(0xFF1E3A5F)
                              : Colors.grey.shade300,
                          strokeWidth: 1,
                        ),
                      ),
                      barGroups: List.generate(yValues.length, (i) {
                        return BarChartGroupData(
                          x: i,
                          barRods: [
                            BarChartRodData(
                              toY: yValues[i],
                              color: barColors[i],
                              width: 20,
                              borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(6),
                              ),
                            ),
                          ],
                        );
                      }),
                    ),
                  ),
          ),
          const SizedBox(height: 32),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).brightness == Brightness.dark
                  ? const Color(0xFF142240)
                  : Colors.grey.shade100,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Theme.of(context).brightness == Brightness.dark
                    ? const Color(0xFF1E3A5F)
                    : Colors.grey.shade300,
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const CustomIconWidget(
                  iconName: 'info_outline',
                  color: Color(0xFF00D4FF),
                  size: 24,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'This chart displays the individual overall score of every student you handle across all sections. The overall score represents an equal average between your students\' Quiz results and their performance in the AR Laboratory.',
                    style: TextStyle(
                      fontSize: 13,
                      height: 1.5,
                      color: Theme.of(context).brightness == Brightness.dark
                          ? const Color(0xFF8BA3C0)
                          : Colors.grey.shade700,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchResultsLabel(int resultCount) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final accentColor = isDark
        ? const Color(0xFF00D4FF)
        : const Color(0xFF1565C0);

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
      child: Row(
        children: [
          CustomIconWidget(
            iconName: 'search',
            color: accentColor,
            size: 18,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Search Results',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
            decoration: BoxDecoration(
              color: accentColor.withAlpha(isDark ? 28 : 18),
              borderRadius: BorderRadius.circular(50),
              border: Border.all(color: accentColor.withAlpha(100)),
            ),
            child: Text(
              '$resultCount',
              style: TextStyle(
                color: accentColor,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionLabel(
    String label, {
    required List<String> sectionOptions,
    required String selectedSection,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final accentColor = isDark
        ? const Color(0xFF00D4FF)
        : const Color(0xFF1565C0);
    final mutedColor = isDark ? const Color(0xFF8BA3C0) : Colors.grey.shade600;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
      child: Row(
        children: [
          CustomIconWidget(
            iconName: 'people_alt',
            color: accentColor,
            size: 18,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
          ),
          const SizedBox(width: 8),
          PopupMenuButton<String>(
            initialValue: selectedSection,
            tooltip: 'Filter students by section',
            offset: const Offset(0, 42),
            color: isDark ? const Color(0xFF142240) : Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(
                color: isDark ? const Color(0xFF1E3A5F) : Colors.grey.shade300,
              ),
            ),
            onSelected: (section) {
              setState(() => _selectedSummarySection = section);
            },
            itemBuilder: (context) => sectionOptions.map((section) {
              final isSelected = section == selectedSection;
              final studentCount = section == _allSummarySections
                  ? _students.length
                  : _students
                        .where((student) => student.section == section)
                        .length;
              return PopupMenuItem<String>(
                value: section,
                child: Row(
                  children: [
                    Icon(
                      isSelected
                          ? Icons.check_circle_rounded
                          : section == _allSummarySections
                          ? Icons.groups_outlined
                          : Icons.class_outlined,
                      color: isSelected ? accentColor : mutedColor,
                      size: 19,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        section == _allSummarySections
                            ? _allSummarySections
                            : 'Section $section',
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: isDark ? Colors.white : Colors.black87,
                          fontSize: 13,
                          fontWeight: isSelected
                              ? FontWeight.w600
                              : FontWeight.w400,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Text(
                      '$studentCount',
                      style: TextStyle(
                        color: isSelected ? accentColor : mutedColor,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: selectedSection == _allSummarySections
                    ? (isDark ? const Color(0xFF142240) : Colors.grey.shade50)
                    : accentColor.withAlpha(isDark ? 30 : 20),
                shape: BoxShape.circle,
                border: Border.all(
                  color: selectedSection == _allSummarySections
                      ? (isDark
                            ? const Color(0xFF1E3A5F)
                            : Colors.grey.shade300)
                      : accentColor,
                ),
              ),
              child: Center(
                child: CustomIconWidget(
                  iconName: 'filter_alt_outlined',
                  color: selectedSection == _allSummarySections
                      ? mutedColor
                      : accentColor,
                  size: 18,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Stat card ─────────────────────────────────────────────────────────────────

class _StatCard extends StatelessWidget {
  final String icon;
  final String label;
  final String value;
  final Color color;
  final VoidCallback? onTap;

  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: Theme.of(context).brightness == Brightness.dark
              ? const Color(0xFF142240)
              : Colors.white,
          borderRadius: BorderRadius.circular(14.0),
          border: Border.all(
            color: Theme.of(context).brightness == Brightness.dark
                ? const Color(0xFF1E3A5F)
                : Colors.grey.shade300,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CustomIconWidget(iconName: icon, color: color, size: 18),
            const SizedBox(height: 6),
            Text(
              value,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: color,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontSize: 9,
                color: Theme.of(context).brightness == Brightness.dark
                    ? const Color(0xFF8BA3C0)
                    : Colors.grey.shade600,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

// ── Student progress card ─────────────────────────────────────────────────────

class _StudentProgressCard extends StatelessWidget {
  final _StudentSummary student;
  final bool showBadge;

  const _StudentProgressCard({required this.student, this.showBadge = true});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.dark
            ? const Color(0xFF142240)
            : Colors.white,
        borderRadius: BorderRadius.circular(16.0),
        border: Border.all(
          color: Theme.of(context).brightness == Brightness.dark
              ? const Color(0xFF1E3A5F)
              : Colors.grey.shade300,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Name + section + badge
          Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: student.performanceColor.withAlpha(30),
                  shape: BoxShape.circle,
                ),
                child: ClipOval(
                  child:
                      (student.avatarUrl != null &&
                          student.avatarUrl!.isNotEmpty)
                      ? Image.network(
                          student.avatarUrl!,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Center(
                            child: Text(
                              student.name.isNotEmpty ? student.name[0] : '?',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: student.performanceColor,
                              ),
                            ),
                          ),
                        )
                      : Center(
                          child: Text(
                            student.name.isNotEmpty ? student.name[0] : '?',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: student.performanceColor,
                            ),
                          ),
                        ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      student.name,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Theme.of(context).brightness == Brightness.dark
                            ? Colors.white
                            : Colors.black87,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      'Section ${student.section}',
                      style: TextStyle(
                        fontSize: 11,
                        color: Theme.of(context).brightness == Brightness.dark
                            ? const Color(0xFF8BA3C0)
                            : Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  if (student.studentNumber != null &&
                      student.studentNumber!.isNotEmpty)
                    Padding(
                      padding: EdgeInsets.only(bottom: showBadge ? 6.0 : 0),
                      child: Text(
                        '#${student.studentNumber}',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Theme.of(context).brightness == Brightness.dark
                              ? const Color(0xFF00D4FF)
                              : const Color(0xFF1565C0),
                        ),
                      ),
                    ),
                  if (showBadge)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: student.performanceColor.withAlpha(30),
                        borderRadius: BorderRadius.circular(20.0),
                        border: Border.all(
                          color: student.performanceColor.withAlpha(80),
                        ),
                      ),
                      child: Text(
                        student.performanceLabel,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: student.performanceColor,
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 14),
          // Overall score bar
          Row(
            children: [
              Text(
                'Overall',
                style: TextStyle(
                  fontSize: 11,
                  color: Theme.of(context).brightness == Brightness.dark
                      ? const Color(0xFF8BA3C0)
                      : Colors.grey.shade600,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(4.0),
                  child: LinearProgressIndicator(
                    value: student.overallScore / 100,
                    backgroundColor:
                        Theme.of(context).brightness == Brightness.dark
                        ? const Color(0xFF1E3A5F)
                        : Colors.grey.shade300,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      student.performanceColor,
                    ),
                    minHeight: 6,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '${student.overallScore.toStringAsFixed(0)}%',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: student.performanceColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          // Stats row
          Row(
            children: [
              _MiniStat(
                icon: 'quiz',
                label: 'Quiz Avg',
                value: '${(student.avgQuizScore * 100).toStringAsFixed(0)}%',
                color: Theme.of(context).brightness == Brightness.dark
                    ? const Color(0xFF00D4FF)
                    : const Color(0xFF1565C0),
              ),
              const SizedBox(width: 8),
              _MiniStat(
                icon: 'science',
                label: 'AR Score',
                value: '${student.avgArScore.toStringAsFixed(0)}%',
                color: const Color(0xFF7C3AED),
              ),
              const SizedBox(width: 8),
              _MiniStat(
                icon: 'assignment_turned_in',
                label: 'Quizzes',
                value: '${student.quizzesTaken}',
                color: const Color(0xFF8BA3C0),
              ),
              const SizedBox(width: 8),
              _MiniStat(
                icon: 'biotech',
                label: 'AR Tries',
                value: '${student.arAttempts}',
                color: const Color(0xFF8BA3C0),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MiniStat extends StatelessWidget {
  final String icon;
  final String label;
  final String value;
  final Color color;

  const _MiniStat({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 6),
        decoration: BoxDecoration(
          color: Theme.of(context).brightness == Brightness.dark
              ? const Color(0xFF0A1628)
              : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(10.0),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CustomIconWidget(iconName: icon, color: color, size: 14),
            const SizedBox(height: 4),
            Text(
              value,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: color,
              ),
            ),
            Text(
              label,
              style: TextStyle(
                fontSize: 9,
                color: Theme.of(context).brightness == Brightness.dark
                    ? const Color(0xFF8BA3C0)
                    : Colors.grey.shade600,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
