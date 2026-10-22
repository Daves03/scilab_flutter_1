import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/user_model.dart';
import '../../models/course_model.dart';
import '../../models/student_course_destination.dart';
import '../../models/class_announcement_model.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../services/auth_service.dart';
import '../../services/course_service.dart';
import '../../services/announcement_service.dart';

import '../../core/app_export.dart';
import '../../routes/app_routes.dart';
import '../../widgets/custom_icon_widget.dart';
import '../../widgets/dashboard_datetime_card.dart';
import './widgets/user_header_widget.dart';

class StudentHomeScreen extends StatefulWidget {
  const StudentHomeScreen({super.key});

  @override
  State<StudentHomeScreen> createState() => _StudentHomeScreenState();
}

class _StudentHomeScreenState extends State<StudentHomeScreen>
    with SingleTickerProviderStateMixin {
  static const int _announcementPageSize = 3;
  static const double _notificationCardHeight = 116;
  static const double _notificationListMaxHeight =
      (_notificationCardHeight * 4) + (12 * 3);

  late AnimationController _entranceController;
  late Timer _timer;
  late final AuthService _authService;
  final AnnouncementService _announcementService = AnnouncementService();
  final Map<String, Stream<List<AnnouncementReaction>>>
  _announcementReactionStreams = {};
  final Set<String> _updatingAnnouncementReactions = {};
  late DateTime _philippinesTime;
  List<Map<String, dynamic>> _courseActivity = [];
  List<ClassAnnouncement> _announcements = [];
  Map<String, List<Map<String, dynamic>>> _deadlines = {
    'upcoming': [],
    'missed': [],
  };
  Map<String, dynamic> _progressStats = {'avgQuiz': '0%', 'labs': '0'};
  bool _isLoadingNotifications = true;
  bool _isLoadingAnnouncements = true;
  bool _isLoadingDeadlines = true;
  bool _isLoadingProgress = true;
  Object? _courseActivityError;
  StreamSubscription? _notificationsSub;
  StreamSubscription<List<ClassAnnouncement>>? _announcementsSub;
  StreamSubscription? _deadlinesSub;
  StreamSubscription<List<QuizAttempt>>? _quizAttemptsSub;
  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? _labActivitySub;
  String? _studentDataKey;
  int _studentDataVersion = 0;
  bool _hasShownDeadlinePopup = false;
  int _studentAnnouncementPage = 0;

  String _announcementTeacherName(ClassAnnouncement announcement) {
    for (final activity in _courseActivity) {
      final course = activity['course'];
      if (course is Course &&
          course.teacherUid == announcement.teacherId &&
          course.teacherName.trim().isNotEmpty) {
        return course.teacherName;
      }
    }
    return announcement.teacherName;
  }

  List<Map<String, dynamic>> get _notifications {
    final user = _authService.currentUser;
    final clearedAt = user?.notificationsClearedAt;
    final dismissedIds = user?.dismissedNotificationIds.toSet() ?? <String>{};
    final combined =
        <Map<String, dynamic>>[
          ..._courseActivity,
          ..._announcements.map(
            (announcement) => {
              'id': 'class-announcement:${announcement.id}',
              'title': 'Class Announcement',
              'desc':
                  '${_announcementTeacherName(announcement)}: ${announcement.message}',
              'icon': 'campaign',
              'color': const Color(0xFF00C875),
              'timeStr': _formatNotificationTime(announcement.createdAt),
              'timestamp':
                  announcement.createdAt ??
                  DateTime.fromMillisecondsSinceEpoch(0),
              'isCourseContent': false,
            },
          ),
        ]..sort(
          (first, second) => (second['timestamp'] as DateTime).compareTo(
            first['timestamp'] as DateTime,
          ),
        );
    final visible = combined.where((activity) {
      final notificationId = activity['id'] as String?;
      final isAfterClear =
          clearedAt == null ||
          (activity['timestamp'] as DateTime).isAfter(clearedAt);
      final isDismissed =
          notificationId != null && dismissedIds.contains(notificationId);
      return isAfterClear && !isDismissed;
    });
    return visible.take(5).toList(growable: false);
  }

  List<Map<String, dynamic>> get _recentCourseContent => _courseActivity
      .where((activity) => activity['isCourseContent'] == true)
      .take(2)
      .toList(growable: false);

  @override
  void initState() {
    super.initState();
    _authService = context.read<AuthService>();
    _authService.addListener(_handleStudentAssignmentChanged);
    _handleStudentAssignmentChanged();
    _entranceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..forward();

    _updateTime();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) => _updateTime());

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkAndShowDeadlinePopup();
    });
  }

  String _studentAssignmentKey(AppUser? user) {
    if (user == null) return 'signed-out';
    final sections =
        user.sections
            .map((section) => section.trim().toLowerCase())
            .where((section) => section.isNotEmpty)
            .toSet()
            .toList()
          ..sort();
    return '${user.id}|${user.role?.id ?? ''}|${sections.join('|')}';
  }

  void _handleStudentAssignmentChanged() {
    final key = _studentAssignmentKey(_authService.currentUser);
    if (key == _studentDataKey) return;
    _studentDataKey = key;
    _subscribeToStudentData();
  }

  void _retryStudentData() {
    _studentDataKey = null;
    _handleStudentAssignmentChanged();
  }

  void _subscribeToStudentData() {
    final version = ++_studentDataVersion;
    _notificationsSub?.cancel();
    _announcementsSub?.cancel();
    _deadlinesSub?.cancel();
    _quizAttemptsSub?.cancel();
    _labActivitySub?.cancel();
    _announcementReactionStreams.clear();

    setState(() {
      _courseActivity = [];
      _announcements = [];
      _deadlines = {'upcoming': [], 'missed': []};
      _progressStats = {'avgQuiz': '0%', 'labs': '0'};
      _courseActivityError = null;
      _isLoadingNotifications = true;
      _isLoadingAnnouncements = true;
      _isLoadingDeadlines = true;
      _isLoadingProgress = true;
    });

    if (_authService.currentUser == null) {
      setState(() {
        _isLoadingNotifications = false;
        _isLoadingAnnouncements = false;
        _isLoadingDeadlines = false;
        _isLoadingProgress = false;
      });
      return;
    }

    final student = _authService.currentUser!;
    _announcementsSub = _announcementService
        .announcementsForStudent(student)
        .listen(
          (announcements) {
            if (!mounted || version != _studentDataVersion) return;
            setState(() {
              _announcements = announcements;
              _studentAnnouncementPage = 0;
              _isLoadingAnnouncements = false;
            });
          },
          onError: (Object error) {
            if (!mounted || version != _studentDataVersion) return;
            debugPrint('Error streaming class announcements: $error');
            setState(() => _isLoadingAnnouncements = false);
          },
        );

    _notificationsSub = _streamDynamicNotifications().listen(
      (data) {
        if (mounted && version == _studentDataVersion) {
          setState(() {
            _courseActivity = data;
            _courseActivityError = null;
            _isLoadingNotifications = false;
          });
        }
      },
      onError: (error) {
        if (mounted && version == _studentDataVersion) {
          setState(() {
            _courseActivityError = error;
            _isLoadingNotifications = false;
          });
        }
      },
    );

    _deadlinesSub = _streamUpcomingDeadlines().listen(
      (data) {
        if (mounted && version == _studentDataVersion) {
          setState(() {
            _deadlines = data;
            _isLoadingDeadlines = false;
          });
        }
      },
      onError: (error) {
        if (mounted && version == _studentDataVersion) {
          setState(() => _isLoadingDeadlines = false);
        }
      },
    );

    _subscribeToProgressStats(version);
  }

  void _subscribeToProgressStats(int version) {
    final user = _authService.currentUser;
    if (user == null) return;

    _quizAttemptsSub = context
        .read<CourseService>()
        .attemptsForStudent(user.id)
        .listen(
          (attempts) {
            if (!mounted || version != _studentDataVersion) return;

            final latestByQuiz = <String, QuizAttempt>{};
            for (final attempt in attempts) {
              if (attempt.quizId.isEmpty || attempt.totalQuestions <= 0) {
                continue;
              }
              final current = latestByQuiz[attempt.quizId];
              final submittedAt = attempt.submittedAt ?? DateTime(2000);
              final currentSubmittedAt = current?.submittedAt ?? DateTime(2000);
              if (current == null ||
                  !submittedAt.isBefore(currentSubmittedAt)) {
                latestByQuiz[attempt.quizId] = attempt;
              }
            }
            final totalPercentage = latestByQuiz.values.fold<double>(
              0,
              (total, attempt) =>
                  total + (attempt.score / attempt.totalQuestions),
            );
            final average = latestByQuiz.isEmpty
                ? 0.0
                : (totalPercentage / latestByQuiz.length) * 100;

            setState(() {
              _progressStats = {
                ..._progressStats,
                'avgQuiz': '${average.toStringAsFixed(0)}%',
              };
              _isLoadingProgress = false;
            });
          },
          onError: (_) {
            if (!mounted || version != _studentDataVersion) return;
            setState(() => _isLoadingProgress = false);
          },
        );

    _labActivitySub = FirebaseFirestore.instance
        .collection('users')
        .doc(user.id)
        .collection('experiment_activity')
        .snapshots()
        .listen(
          (snapshot) {
            if (!mounted || version != _studentDataVersion) return;
            final completedLabs = snapshot.docs
                .where((doc) => doc.data()['completedAt'] != null)
                .length;
            setState(() {
              _progressStats = {..._progressStats, 'labs': '$completedLabs'};
            });
          },
          onError: (Object error) =>
              debugPrint('Error streaming completed labs: $error'),
        );
  }

  Future<void> _checkAndShowDeadlinePopup() async {
    if (_hasShownDeadlinePopup) return;

    final firstEvent = await _streamUpcomingDeadlines().first;
    if (!mounted) return;

    final upcoming = firstEvent['upcoming'] as List<Map<String, dynamic>>;
    final now = DateTime.now();
    final urgentDeadlines = upcoming.where((d) {
      final dueDate = d['dueDate'] as DateTime;
      return dueDate.difference(now).inHours <= 48;
    }).toList();

    if (urgentDeadlines.isNotEmpty) {
      _hasShownDeadlinePopup = true;
      _showUrgentDeadlinesDialog(urgentDeadlines);
    }
  }

  void _showUrgentDeadlinesDialog(List<Map<String, dynamic>> deadlines) {
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          width: 400,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Theme.of(context).brightness == Brightness.dark
                ? const Color(0xFF142240)
                : Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFFFF4757).withAlpha(100)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CustomIconWidget(
                iconName: 'warning',
                color: Color(0xFFFF4757),
                size: 48,
              ),
              const SizedBox(height: 16),
              Text(
                'Upcoming Deadlines!',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Colors.white
                      : Colors.black87,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'You have quizzes due in the next 48 hours.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 16),
              ...deadlines.map((d) {
                final quiz = d['quiz'] as CourseQuiz;
                final date = d['dueDate'] as DateTime;
                return Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFF4757).withAlpha(15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      const CustomIconWidget(
                        iconName: 'schedule',
                        color: Color(0xFFFF4757),
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              quiz.title,
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              'Due: ${date.month}/${date.day} at ${_formatTimeOnly(date)}',
                              style: const TextStyle(
                                fontSize: 12,
                                color: Color(0xFFFF4757),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              }),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => Navigator.pop(ctx),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFF4757),
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 45),
                ),
                child: const Text('Got it'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _updateTime() {
    final now = DateTime.now().toUtc();
    if (mounted) {
      setState(() {
        _philippinesTime = now.add(const Duration(hours: 8));
      });
    }
  }

  @override
  void dispose() {
    _authService.removeListener(_handleStudentAssignmentChanged);
    _studentDataVersion++;
    _timer.cancel();
    _entranceController.dispose();
    _notificationsSub?.cancel();
    _announcementsSub?.cancel();
    _deadlinesSub?.cancel();
    _quizAttemptsSub?.cancel();
    _labActivitySub?.cancel();
    super.dispose();
  }

  String _formatTimeOnly(DateTime dt) {
    final h = dt.hour == 0 ? 12 : (dt.hour > 12 ? dt.hour - 12 : dt.hour);
    final m = dt.minute.toString().padLeft(2, '0');
    final ampm = dt.hour >= 12 ? 'PM' : 'AM';
    return '$h:$m $ampm';
  }

  @override
  Widget build(BuildContext context) {
    final isTablet = MediaQuery.of(context).size.width >= 600;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        bottom: false,
        child: isTablet ? _buildTabletLayout() : _buildPhoneLayout(),
      ),
    );
  }

  Widget _buildPhoneLayout() {
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Builder(
            builder: (context) {
              final user = context.watch<AuthService>().currentUser;
              final lastRead = user?.lastNotificationReadAt ?? DateTime(2000);
              final hasUnread = _notifications.any(
                (n) => (n['timestamp'] as DateTime).isAfter(lastRead),
              );

              return UserHeaderWidget(
                hasUnreadNotifications: hasUnread,
                onNotificationTap: () {
                  context.read<AuthService>().markNotificationsAsRead();
                  _showNotificationsDialog(context);
                },
              );
            },
          ),
        ),
        SliverToBoxAdapter(child: _buildDateTimeSection()),
        SliverToBoxAdapter(
          child: _buildAnimatedSection(
            delay: 0,
            child: _buildStudentAnnouncementsSection(),
          ),
        ),
        SliverToBoxAdapter(
          child: _buildAnimatedSection(
            delay: 0,
            child: _buildNotificationsSection(),
          ),
        ),
        SliverToBoxAdapter(
          child: _buildAnimatedSection(
            delay: 100,
            child: _buildProgressSummarySection(),
          ),
        ),
        SliverToBoxAdapter(
          child: _buildAnimatedSection(
            delay: 200,
            child: _buildCalendarSection(),
          ),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: 140)),
      ],
    );
  }

  Widget _buildTabletLayout() {
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Builder(
            builder: (context) {
              final user = context.watch<AuthService>().currentUser;
              final lastRead = user?.lastNotificationReadAt ?? DateTime(2000);
              final hasUnread = _notifications.any(
                (n) => (n['timestamp'] as DateTime).isAfter(lastRead),
              );

              return UserHeaderWidget(
                hasUnreadNotifications: hasUnread,
                onNotificationTap: () {
                  context.read<AuthService>().markNotificationsAsRead();
                  _showNotificationsDialog(context);
                },
              );
            },
          ),
        ),
        SliverToBoxAdapter(child: _buildDateTimeSection()),
        SliverToBoxAdapter(child: _buildStudentAnnouncementsSection()),
        SliverToBoxAdapter(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 5,
                child: Column(
                  children: [
                    _buildAnimatedSection(
                      delay: 0,
                      child: _buildNotificationsSection(),
                    ),
                    _buildAnimatedSection(
                      delay: 200,
                      child: _buildCalendarSection(),
                    ),
                  ],
                ),
              ),
              Expanded(
                flex: 4,
                child: _buildAnimatedSection(
                  delay: 100,
                  child: _buildProgressSummarySection(),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAnimatedSection({required int delay, required Widget child}) {
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
                  (delay / 600).clamp(0.0, 0.8),
                  ((delay + 300) / 600).clamp(0.0, 1.0),
                  curve: Curves.easeOutCubic,
                ),
              ),
            );
        return SlideTransition(
          position: slide,
          child: FadeTransition(opacity: _entranceController, child: child),
        );
      },
      child: child,
    );
  }

  String _formatNotificationTime(DateTime? dt) {
    if (dt == null) return '';
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 60) return '${diff.inMinutes} mins ago';
    if (diff.inHours < 24) return '${diff.inHours} hrs ago';
    return '${diff.inDays} days ago';
  }

  Stream<List<Map<String, dynamic>>> _streamDynamicNotifications() {
    final user = context.read<AuthService>().currentUser;
    if (user == null) return Stream.value([]);

    return context.read<CourseService>().coursesForStudentStream(user).map((
      courses,
    ) {
      List<Map<String, dynamic>> notifications = [];
      for (final course in courses) {
        // Always expose an assigned course in Recent Course Content. Older
        // course documents may not have a createdAt value, so they receive a
        // deterministic old timestamp instead of disappearing from the feed.
        final courseCreatedAt = course.createdAt;
        notifications.add({
          'id': 'student-course:${course.id}',
          'title': courseCreatedAt == null
              ? 'Course Available'
              : 'New Course Added',
          'desc': courseCreatedAt == null
              ? '${course.teacherName} assigned ${course.title} to your class.'
              : '${course.teacherName} created the course ${course.title}.',
          'icon': 'school',
          'color': const Color(0xFF7C3AED),
          'timeStr': courseCreatedAt == null
              ? 'Available'
              : _formatNotificationTime(courseCreatedAt),
          'timestamp':
              courseCreatedAt ?? DateTime.fromMillisecondsSinceEpoch(0),
          'course': course,
          'contentType': 'course',
          'isCourseContent': true,
        });

        // Modules
        for (var m in course.modules) {
          final moduleId = m.id.isNotEmpty
              ? m.id
              : '${m.title}:${m.uploadedAt?.millisecondsSinceEpoch ?? 0}';
          notifications.add({
            'id': 'student-module:${course.id}:$moduleId',
            'title': 'New Module Uploaded',
            'desc':
                '${course.teacherName} uploaded ${m.title} in ${course.title}.',
            'icon': 'view_in_ar',
            'color': const Color(0xFF00D4FF),
            'timeStr': _formatNotificationTime(m.uploadedAt),
            'timestamp': m.uploadedAt ?? DateTime.fromMillisecondsSinceEpoch(0),
            'course': course,
            'module': m,
            'contentType': 'module',
            'isCourseContent': true,
          });
        }

        // Quizzes
        for (var q in course.quizzes) {
          final quizId = q.id.isNotEmpty ? q.id : q.title;
          notifications.add({
            'id': 'student-quiz:${course.id}:$quizId',
            'title': 'New Quiz Available',
            'desc':
                '${course.teacherName} posted ${q.title} in ${course.title}.',
            'icon': 'quiz',
            'color': const Color(0xFFFFB300),
            'timeStr': _formatNotificationTime(q.createdAt),
            'timestamp': q.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0),
            'course': course,
            'quiz': q,
            'contentType': 'quiz',
            'isCourseContent': true,
          });

          // Upcoming deadlines
          if (q.dueDate != null && q.dueDate!.isAfter(DateTime.now())) {
            final diff = q.dueDate!.difference(DateTime.now());
            if (diff.inHours <= 48) {
              notifications.add({
                'id':
                    'student-deadline:${course.id}:$quizId:${q.dueDate!.millisecondsSinceEpoch}',
                'title': 'Quiz Deadline Approaching',
                'desc': '${q.title} is due in ${diff.inHours} hours.',
                'icon': 'schedule',
                'color': const Color(0xFFFF4757),
                'timeStr': 'Due soon',
                'timestamp': q.dueDate!.subtract(const Duration(hours: 48)),
                'course': course,
                'isCourseContent': false,
              });
            }
          }
        }
      }

      notifications.sort(
        (a, b) =>
            (b['timestamp'] as DateTime).compareTo(a['timestamp'] as DateTime),
      );
      return notifications;
    });
  }

  Stream<Map<String, List<Map<String, dynamic>>>> _streamUpcomingDeadlines() {
    final user = context.read<AuthService>().currentUser;
    if (user == null) return Stream.value({'upcoming': [], 'missed': []});

    return context.read<CourseService>().coursesForStudentStream(user).map((
      courses,
    ) {
      List<Map<String, dynamic>> upcoming = [];
      List<Map<String, dynamic>> missed = [];
      final now = DateTime.now();
      for (final course in courses) {
        for (var q in course.quizzes) {
          if (q.dueDate != null) {
            if (q.dueDate!.isAfter(now)) {
              upcoming.add({
                'course': course,
                'quiz': q,
                'dueDate': q.dueDate!,
              });
            } else {
              missed.add({'course': course, 'quiz': q, 'dueDate': q.dueDate!});
            }
          }
        }
      }
      upcoming.sort(
        (a, b) =>
            (a['dueDate'] as DateTime).compareTo(b['dueDate'] as DateTime),
      );
      missed.sort(
        (a, b) =>
            (b['dueDate'] as DateTime).compareTo(a['dueDate'] as DateTime),
      );
      return {'upcoming': upcoming, 'missed': missed};
    });
  }

  void _showNotificationsDialog(BuildContext context) {
    final dialogNotifications = List<Map<String, dynamic>>.from(_notifications);
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
              builder: (ctx, setDialogState) {
                if (_isLoadingNotifications) {
                  return const SizedBox(
                    height: 200,
                    child: Center(child: CircularProgressIndicator()),
                  );
                }

                final notifs = dialogNotifications;
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Row(
                            children: [
                              CustomIconWidget(
                                iconName: 'notifications',
                                color:
                                    Theme.of(context).brightness ==
                                        Brightness.dark
                                    ? const Color(0xFF00D4FF)
                                    : const Color(0xFF1565C0),
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
                            if (notifs.isNotEmpty)
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
                                          borderRadius: BorderRadius.circular(
                                            16,
                                          ),
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
                                  tapTargetSize:
                                      MaterialTapTargetSize.shrinkWrap,
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
                            if (notifs.isNotEmpty) const SizedBox(width: 12),
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
                                      : Colors.grey.shade700,
                                  size: 16,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Flexible(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(
                          maxHeight: _notificationListMaxHeight,
                        ),
                        child: SingleChildScrollView(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (notifs.isEmpty)
                                const Padding(
                                  padding: EdgeInsets.symmetric(vertical: 20),
                                  child: Text(
                                    'No recent activity.',
                                    style: TextStyle(color: Colors.grey),
                                  ),
                                )
                              else
                                ...notifs.map((n) {
                                  final notificationId = n['id'] as String;
                                  return Padding(
                                    padding: const EdgeInsets.only(bottom: 12),
                                    child: Dismissible(
                                      key: ValueKey(notificationId),
                                      direction: DismissDirection.endToStart,
                                      background: _buildDismissBackground(),
                                      onDismissed: (_) {
                                        setDialogState(() {
                                          dialogNotifications.removeWhere(
                                            (notification) =>
                                                notification['id'] ==
                                                notificationId,
                                          );
                                        });
                                        unawaited(
                                          context
                                              .read<AuthService>()
                                              .dismissNotification(
                                                notificationId,
                                              ),
                                        );
                                      },
                                      child: _buildNotificationItem(
                                        n['title'] as String,
                                        n['desc'] as String,
                                        n['icon'] as String,
                                        n['color'] as Color,
                                        n['timeStr'] as String,
                                        onTap: () {
                                          Navigator.pop(context);
                                          if (n['course'] != null) {
                                            context.go(
                                              AppRoutes.studentCoursesScreen,
                                              extra: n['course'],
                                            );
                                          }
                                        },
                                      ),
                                    ),
                                  );
                                }).toList(),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
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
    String time, {
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        height: _notificationCardHeight,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(context).brightness == Brightness.dark
                ? const Color(0xFF0A1628)
                : Colors.grey.shade50,
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
                                  Theme.of(context).brightness ==
                                      Brightness.dark
                                  ? Colors.white
                                  : Colors.black87,
                            ),
                          ),
                        ),
                        Text(
                          time,
                          style: TextStyle(
                            fontSize: 11,
                            color:
                                Theme.of(context).brightness == Brightness.dark
                                ? const Color(0xFF8BA3C0)
                                : Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      desc,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 12,
                        color: Theme.of(context).brightness == Brightness.dark
                            ? const Color(0xFF8BA3C0)
                            : Colors.grey.shade600,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDateTimeSection() {
    final calendarEvents = <DashboardCalendarEvent>[];
    for (final bucket in const ['upcoming', 'missed']) {
      for (final deadline in _deadlines[bucket] ?? const []) {
        final course = deadline['course'] as Course;
        final quiz = deadline['quiz'] as CourseQuiz;
        final dueDate = deadline['dueDate'] as DateTime;
        calendarEvents.add(
          DashboardCalendarEvent(
            id: '${course.id}:${quiz.id}',
            quizName: quiz.title,
            courseName: course.title,
            // Keep calendar dates and the dashboard clock in Philippine time.
            dueDate: dueDate.toUtc().add(const Duration(hours: 8)),
          ),
        );
      }
    }
    calendarEvents.sort((a, b) => a.dueDate.compareTo(b.dueDate));

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Student Dashboard',
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
            dateTime: _philippinesTime,
            calendarEvents: calendarEvents,
            showQuizDeadlines: true,
          ),
        ],
      ),
    );
  }

  Widget _buildStudentAnnouncementsSection() {
    final isLight = Theme.of(context).brightness == Brightness.light;
    final accent = isLight ? const Color(0xFF087A4F) : const Color(0xFF00FF88);
    final pageCount = _announcements.isEmpty
        ? 0
        : (_announcements.length + _announcementPageSize - 1) ~/
              _announcementPageSize;
    final currentPage = pageCount == 0
        ? 0
        : _studentAnnouncementPage.clamp(0, pageCount - 1);
    final pageStart = currentPage * _announcementPageSize;
    final proposedEnd = pageStart + _announcementPageSize;
    final pageEnd = proposedEnd < _announcements.length
        ? proposedEnd
        : _announcements.length;
    final visibleAnnouncements = pageCount == 0
        ? const <ClassAnnouncement>[]
        : _announcements.sublist(pageStart, pageEnd);

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.campaign_rounded, color: accent, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Class Announcements',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: isLight ? Colors.black87 : Colors.white,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          if (_isLoadingAnnouncements)
            const Center(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 18),
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            )
          else if (_announcements.isEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: isLight ? Colors.white : const Color(0xFF142240),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: isLight
                      ? Colors.grey.shade300
                      : const Color(0xFF1E3A5F),
                ),
              ),
              child: Text(
                'No announcements from your teachers yet.',
                style: TextStyle(
                  color: isLight
                      ? Colors.grey.shade600
                      : const Color(0xFF8BA3C0),
                  fontSize: 12.5,
                ),
              ),
            )
          else
            ...visibleAnnouncements.map(
              (announcement) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: _buildStudentAnnouncementCard(announcement),
              ),
            ),
          if (!_isLoadingAnnouncements && pageCount > 1)
            _buildStudentAnnouncementPager(
              currentPage: currentPage,
              pageCount: pageCount,
              accent: accent,
              isLight: isLight,
            ),
        ],
      ),
    );
  }

  Widget _buildStudentAnnouncementPager({
    required int currentPage,
    required int pageCount,
    required Color accent,
    required bool isLight,
  }) {
    final mutedColor = isLight
        ? const Color(0xFF667085)
        : const Color(0xFF9BB0CA);
    final borderColor = isLight
        ? const Color(0xFFD7E0EA)
        : const Color(0xFF294568);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: isLight ? Colors.white : const Color(0xFF101F36),
        borderRadius: BorderRadius.circular(13),
        border: Border.all(color: borderColor),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextButton.icon(
              onPressed: currentPage > 0
                  ? () => setState(
                      () => _studentAnnouncementPage = currentPage - 1,
                    )
                  : null,
              icon: const Icon(Icons.chevron_left_rounded, size: 18),
              label: const Text('Previous'),
              style: TextButton.styleFrom(
                foregroundColor: accent,
                disabledForegroundColor: mutedColor.withAlpha(90),
                textStyle: const TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Text(
              '${currentPage + 1} / $pageCount',
              style: TextStyle(
                color: mutedColor,
                fontSize: 11,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          Expanded(
            child: TextButton.icon(
              onPressed: currentPage < pageCount - 1
                  ? () => setState(
                      () => _studentAnnouncementPage = currentPage + 1,
                    )
                  : null,
              iconAlignment: IconAlignment.end,
              icon: const Icon(Icons.chevron_right_rounded, size: 18),
              label: const Text('Next'),
              style: TextButton.styleFrom(
                foregroundColor: accent,
                disabledForegroundColor: mutedColor.withAlpha(90),
                textStyle: const TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStudentAnnouncementCard(ClassAnnouncement announcement) {
    final isLight = Theme.of(context).brightness == Brightness.light;
    final accent = isLight ? const Color(0xFF087A4F) : const Color(0xFF00FF88);
    final time = announcement.createdAt == null
        ? 'Just now'
        : _formatNotificationTime(announcement.createdAt);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: isLight ? Colors.white : const Color(0xFF142240),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: accent.withAlpha(65)),
        boxShadow: isLight
            ? [
                BoxShadow(
                  color: Colors.black.withAlpha(10),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ]
            : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: accent.withAlpha(20),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(Icons.campaign_rounded, color: accent, size: 20),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _announcementTeacherName(announcement),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: isLight ? Colors.black87 : Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Teacher announcement • $time${announcement.isEdited ? ' • Edited' : ''}',
                      style: TextStyle(
                        color: isLight
                            ? Colors.grey.shade600
                            : const Color(0xFF8BA3C0),
                        fontSize: 10.5,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 11),
          Text(
            announcement.message,
            style: TextStyle(
              color: isLight
                  ? const Color(0xFF344054)
                  : const Color(0xFFD5E2F0),
              fontSize: 13,
              height: 1.45,
            ),
          ),
          const SizedBox(height: 12),
          _buildStudentAnnouncementReactions(announcement),
        ],
      ),
    );
  }

  Stream<List<AnnouncementReaction>> _reactionStreamFor(
    ClassAnnouncement announcement,
  ) {
    return _announcementReactionStreams.putIfAbsent(
      announcement.id,
      () => _announcementService.reactionsForAnnouncement(announcement.id),
    );
  }

  Future<void> _toggleAnnouncementReaction(
    ClassAnnouncement announcement,
    AnnouncementReactionType type,
  ) async {
    final student = _authService.currentUser;
    if (student == null ||
        !_updatingAnnouncementReactions.add(announcement.id)) {
      return;
    }

    if (mounted) setState(() {});
    try {
      await _announcementService.toggleReaction(
        announcement: announcement,
        student: student,
        type: type,
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Unable to update your reaction. Please try again.'),
        ),
      );
      debugPrint('Announcement reaction update failed: $error');
    } finally {
      _updatingAnnouncementReactions.remove(announcement.id);
      if (mounted) setState(() {});
    }
  }

  Widget _buildStudentAnnouncementReactions(ClassAnnouncement announcement) {
    final isLight = Theme.of(context).brightness == Brightness.light;
    return StreamBuilder<List<AnnouncementReaction>>(
      stream: _reactionStreamFor(announcement),
      builder: (context, snapshot) {
        final reactions = snapshot.data ?? const <AnnouncementReaction>[];
        final studentId = _authService.currentUser?.id;
        AnnouncementReactionType? selectedType;
        var likeCount = 0;
        var loveCount = 0;

        for (final reaction in reactions) {
          switch (reaction.type) {
            case AnnouncementReactionType.like:
              likeCount++;
            case AnnouncementReactionType.love:
              loveCount++;
          }
          if (reaction.studentId == studentId) selectedType = reaction.type;
        }

        final isUpdating = _updatingAnnouncementReactions.contains(
          announcement.id,
        );
        return Row(
          children: [
            Expanded(
              child: _buildStudentReactionButton(
                announcement: announcement,
                type: AnnouncementReactionType.like,
                count: likeCount,
                selected: selectedType == AnnouncementReactionType.like,
                enabled: !isUpdating,
                isLight: isLight,
              ),
            ),
            const SizedBox(width: 9),
            Expanded(
              child: _buildStudentReactionButton(
                announcement: announcement,
                type: AnnouncementReactionType.love,
                count: loveCount,
                selected: selectedType == AnnouncementReactionType.love,
                enabled: !isUpdating,
                isLight: isLight,
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildStudentReactionButton({
    required ClassAnnouncement announcement,
    required AnnouncementReactionType type,
    required int count,
    required bool selected,
    required bool enabled,
    required bool isLight,
  }) {
    final color = type == AnnouncementReactionType.like
        ? const Color(0xFF2684FF)
        : const Color(0xFFFF477E);
    final neutralBorder = isLight
        ? const Color(0xFFD5DEE9)
        : const Color(0xFF294568);
    final neutralText = isLight
        ? const Color(0xFF526174)
        : const Color(0xFFAFC0D5);

    return Material(
      color: selected
          ? color.withAlpha(isLight ? 22 : 35)
          : (isLight ? const Color(0xFFF7F9FC) : const Color(0xFF0C1B30)),
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        onTap: enabled
            ? () => _toggleAnnouncementReaction(announcement, type)
            : null,
        borderRadius: BorderRadius.circular(10),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          height: 38,
          padding: const EdgeInsets.symmetric(horizontal: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: selected ? color : neutralBorder),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                type == AnnouncementReactionType.like
                    ? Icons.thumb_up_rounded
                    : Icons.favorite_rounded,
                color: selected ? color : neutralText,
                size: 17,
              ),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  '${type.label}${count > 0 ? '  $count' : ''}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: selected ? color : neutralText,
                    fontSize: 11.5,
                    fontWeight: selected ? FontWeight.w700 : FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNotificationsSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Recent Course Content',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).brightness == Brightness.dark
                  ? Colors.white
                  : Colors.black87,
            ),
          ),
          const SizedBox(height: 12),
          Builder(
            builder: (ctx) {
              if (_isLoadingNotifications) {
                return const Center(child: CircularProgressIndicator());
              }
              if (_courseActivityError != null) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Unable to load recent course content.',
                          style: TextStyle(
                            color:
                                Theme.of(context).brightness == Brightness.dark
                                ? const Color(0xFF8BA3C0)
                                : Colors.grey.shade700,
                          ),
                        ),
                      ),
                      TextButton(
                        onPressed: _retryStudentData,
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                );
              }
              final recentContent = _recentCourseContent;
              if (recentContent.isEmpty) {
                return const Padding(
                  padding: EdgeInsets.symmetric(vertical: 20),
                  child: Text(
                    'No course content is assigned to your grade and section yet.',
                    style: TextStyle(color: Colors.grey),
                  ),
                );
              }
              return Column(
                children: recentContent.map((n) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: _buildAlertCard(
                      title: n['title'] as String,
                      subtitle: n['desc'] as String,
                      icon: n['icon'] as String,
                      color: n['color'] as Color,
                      onTap: () => _openRecentCourseContent(n),
                    ),
                  );
                }).toList(),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildAlertCard({
    required String title,
    required String subtitle,
    required String icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Material(
      color: color.withAlpha(20),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: color.withAlpha(80)),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withAlpha(30),
                  shape: BoxShape.circle,
                ),
                child: CustomIconWidget(iconName: icon, color: color, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: color,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 13,
                        color: Theme.of(context).brightness == Brightness.dark
                            ? Colors.white.withAlpha(200)
                            : Colors.black54,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Icon(Icons.chevron_right_rounded, color: color, size: 22),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _openRecentCourseContent(Map<String, dynamic> content) async {
    final course = content['course'];
    if (course is! Course) return;

    switch (content['contentType']) {
      case 'quiz':
        final quiz = content['quiz'];
        if (quiz is! CourseQuiz) return;
        context.go(
          AppRoutes.studentCoursesScreen,
          extra: StudentCourseDestination(course: course, quizId: quiz.id),
        );
        return;
      case 'module':
        final module = content['module'];
        if (module is! CourseModule) return;
        await _openRecentModule(course, module);
        return;
      default:
        // A newly added course should land on the course catalogue, not on
        // the course detail's default Quizzes tab.
        context.go(AppRoutes.studentCoursesScreen);
    }
  }

  Future<void> _openRecentModule(Course course, CourseModule module) async {
    final url = module.url.trim();
    if (url.isEmpty) {
      if (!mounted) return;
      context.go(
        AppRoutes.studentCoursesScreen,
        extra: StudentCourseDestination(course: course, initialTabIndex: 1),
      );
      return;
    }

    final encodedUrl = Uri.encodeComponent(url);
    final encodedTitle = Uri.encodeComponent(module.title);
    final lowerUrl = url.toLowerCase();
    if (module.fileType == 'pdf') {
      context.push(
        '${AppRoutes.pdfViewerScreen}?url=$encodedUrl&title=$encodedTitle',
      );
      return;
    }
    if (module.fileType == 'video' ||
        lowerUrl.endsWith('.mp4') ||
        lowerUrl.endsWith('.mov')) {
      context.push(
        '${AppRoutes.videoViewerScreen}?url=$encodedUrl&title=$encodedTitle',
      );
      return;
    }
    if (lowerUrl.endsWith('.jpg') ||
        lowerUrl.endsWith('.jpeg') ||
        lowerUrl.endsWith('.png')) {
      context.push(
        '${AppRoutes.imageViewerScreen}?url=$encodedUrl&title=$encodedTitle',
      );
      return;
    }

    final uri = Uri.tryParse(url);
    if (uri != null && await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.inAppWebView);
      return;
    }
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Could not open this course content.')),
    );
  }

  Widget _buildProgressSummarySection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'My Progress Summary',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).brightness == Brightness.dark
                  ? Colors.white
                  : Colors.black87,
            ),
          ),
          const SizedBox(height: 12),
          Builder(
            builder: (ctx) {
              if (_isLoadingProgress) {
                return const Center(child: CircularProgressIndicator());
              }
              final stats = _progressStats;
              final quizProgressText = stats['avgQuiz'] as String;
              final quizProgressPercent =
                  (double.tryParse(quizProgressText.replaceAll('%', '')) ?? 0) /
                  100;
              return Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: _buildSummaryCard(
                          'Avg Quiz Score',
                          quizProgressText,
                          'quiz',
                          Theme.of(context).brightness == Brightness.dark
                              ? const Color(0xFF00D4FF)
                              : const Color(0xFF1565C0),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildSummaryCard(
                          'Completed Labs',
                          stats['labs'] as String,
                          'biotech',
                          const Color(0xFF7C3AED),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _buildStudentProgressBar(
                    quizProgressText,
                    quizProgressPercent.clamp(0.0, 1.0),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildStudentProgressBar(String progressText, double progressPercent) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final accentColor = isDark
        ? const Color(0xFF00D4FF)
        : const Color(0xFF1565C0);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF142240) : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isDark ? const Color(0xFF1E3A5F) : Colors.grey.shade300,
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              CustomIconWidget(
                iconName: 'menu_book',
                color: accentColor,
                size: 16,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Overall Progress',
                  style: TextStyle(
                    color: isDark ? Colors.white : const Color(0xFF0A1628),
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Text(
                progressText,
                style: TextStyle(
                  color: accentColor,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(50),
            child: LinearProgressIndicator(
              value: progressPercent,
              backgroundColor: isDark
                  ? const Color(0xFF1E3A5F)
                  : Colors.grey.shade300,
              valueColor: AlwaysStoppedAnimation<Color>(accentColor),
              minHeight: 7,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(
    String title,
    String value,
    String icon,
    Color color, {
    bool isWide = false,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.dark
            ? const Color(0xFF142240)
            : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Theme.of(context).brightness == Brightness.dark
              ? const Color(0xFF1E3A5F)
              : Colors.grey.shade300,
        ),
      ),
      child: isWide
          ? Row(
              children: [
                CustomIconWidget(iconName: icon, color: color, size: 28),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: 14,
                      color: Theme.of(context).brightness == Brightness.dark
                          ? const Color(0xFF8BA3C0)
                          : Colors.grey.shade700,
                    ),
                  ),
                ),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: color,
                  ),
                ),
              ],
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CustomIconWidget(iconName: icon, color: color, size: 24),
                const SizedBox(height: 12),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: color,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 13,
                    color: Theme.of(context).brightness == Brightness.dark
                        ? const Color(0xFF8BA3C0)
                        : Colors.grey.shade700,
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildCalendarSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CustomIconWidget(
                iconName: 'calendar_month',
                color: Theme.of(context).brightness == Brightness.dark
                    ? const Color(0xFF8BA3C0)
                    : Colors.grey.shade700,
                size: 20,
              ),
              SizedBox(width: 8),
              Text(
                'Upcoming Due Dates',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Colors.white
                      : Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Builder(
            builder: (ctx) {
              if (_isLoadingDeadlines) {
                return const Center(child: CircularProgressIndicator());
              }
              final data = _deadlines;
              final upcoming = data['upcoming'] as List<Map<String, dynamic>>;
              final missed = data['missed'] as List<Map<String, dynamic>>;

              if (upcoming.isEmpty && missed.isEmpty) {
                return Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).brightness == Brightness.dark
                        ? const Color(0xFF142240)
                        : Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: Theme.of(context).brightness == Brightness.dark
                          ? const Color(0xFF1E3A5F)
                          : Colors.grey.shade300,
                    ),
                  ),
                  child: const Padding(
                    padding: EdgeInsets.symmetric(vertical: 24, horizontal: 16),
                    child: Center(
                      child: Text(
                        'No upcoming due dates',
                        style: TextStyle(color: Colors.grey, fontSize: 14),
                      ),
                    ),
                  ),
                );
              }

              return Column(
                children: [
                  if (upcoming.isNotEmpty)
                    Container(
                      decoration: BoxDecoration(
                        color: Theme.of(context).brightness == Brightness.dark
                            ? const Color(0xFF142240)
                            : Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: Theme.of(context).brightness == Brightness.dark
                              ? const Color(0xFF1E3A5F)
                              : Colors.grey.shade300,
                        ),
                      ),
                      child: Column(
                        children: upcoming.take(4).map((d) {
                          final date = d['dueDate'] as DateTime;
                          final course = d['course'] as Course;
                          final quiz = d['quiz'] as CourseQuiz;
                          const months = [
                            'Jan',
                            'Feb',
                            'Mar',
                            'Apr',
                            'May',
                            'Jun',
                            'Jul',
                            'Aug',
                            'Sep',
                            'Oct',
                            'Nov',
                            'Dec',
                          ];
                          final m = months[date.month - 1];
                          final day = date.day.toString();
                          final title = quiz.title;
                          final time = _formatTimeOnly(date);
                          final isUpcoming =
                              date.difference(DateTime.now()).inHours <= 48;

                          return _buildCalendarItem(
                            day,
                            m,
                            title,
                            time,
                            isUpcoming,
                            onTap: () => _openUpcomingQuiz(course, quiz),
                          );
                        }).toList(),
                      ),
                    ),
                  if (missed.isNotEmpty) ...[
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        CustomIconWidget(
                          iconName: 'warning',
                          color: const Color(0xFFFF4757),
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Missed Deadlines',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFFFF4757),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Container(
                      decoration: BoxDecoration(
                        color: Theme.of(context).brightness == Brightness.dark
                            ? const Color(0xFF142240)
                            : Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: const Color(0xFFFF4757).withAlpha(100),
                        ),
                      ),
                      child: Column(
                        children: missed.take(3).map((d) {
                          final date = d['dueDate'] as DateTime;
                          const months = [
                            'Jan',
                            'Feb',
                            'Mar',
                            'Apr',
                            'May',
                            'Jun',
                            'Jul',
                            'Aug',
                            'Sep',
                            'Oct',
                            'Nov',
                            'Dec',
                          ];
                          final m = months[date.month - 1];
                          final day = date.day.toString();
                          final title = (d['quiz'] as CourseQuiz).title;
                          final time = _formatTimeOnly(date);

                          return _buildCalendarItem(
                            day,
                            m,
                            title,
                            time,
                            false,
                            isMissed: true,
                          );
                        }).toList(),
                      ),
                    ),
                  ],
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildCalendarItem(
    String day,
    String month,
    String title,
    String time,
    bool isUpcoming, {
    bool isMissed = false,
    VoidCallback? onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 50,
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: isMissed
                      ? const Color(0xFFFF4757).withAlpha(20)
                      : (isUpcoming
                            ? (Theme.of(context).brightness == Brightness.dark
                                  ? const Color(0xFF00D4FF).withAlpha(20)
                                  : const Color(0xFF1565C0).withAlpha(20))
                            : (Theme.of(context).brightness == Brightness.dark
                                  ? const Color(0xFF0A1628)
                                  : Colors.grey.shade50)),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isMissed
                        ? const Color(0xFFFF4757)
                        : (isUpcoming
                              ? (Theme.of(context).brightness == Brightness.dark
                                    ? const Color(0xFF00D4FF)
                                    : const Color(0xFF1565C0))
                              : (Theme.of(context).brightness == Brightness.dark
                                    ? const Color(0xFF1E3A5F)
                                    : Colors.grey.shade300)),
                  ),
                ),
                child: Column(
                  children: [
                    Text(
                      month,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: isMissed
                            ? const Color(0xFFFF4757)
                            : (isUpcoming
                                  ? (Theme.of(context).brightness ==
                                            Brightness.dark
                                        ? const Color(0xFF00D4FF)
                                        : const Color(0xFF1565C0))
                                  : (Theme.of(context).brightness ==
                                            Brightness.dark
                                        ? const Color(0xFF8BA3C0)
                                        : Colors.grey.shade600)),
                      ),
                    ),
                    Text(
                      day,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: isMissed
                            ? const Color(0xFFFF4757)
                            : (isUpcoming
                                  ? (Theme.of(context).brightness ==
                                            Brightness.dark
                                        ? const Color(0xFF00D4FF)
                                        : const Color(0xFF1565C0))
                                  : (Theme.of(context).brightness ==
                                            Brightness.dark
                                        ? Colors.white
                                        : Colors.black87)),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: Theme.of(context).brightness == Brightness.dark
                            ? Colors.white
                            : Colors.black87,
                      ),
                    ),
                    SizedBox(height: 4),
                    Row(
                      children: [
                        CustomIconWidget(
                          iconName: 'schedule',
                          color: Theme.of(context).brightness == Brightness.dark
                              ? const Color(0xFF8BA3C0)
                              : Colors.grey.shade600,
                          size: 14,
                        ),
                        SizedBox(width: 4),
                        Text(
                          time,
                          style: TextStyle(
                            fontSize: 13,
                            color:
                                Theme.of(context).brightness == Brightness.dark
                                ? const Color(0xFF8BA3C0)
                                : Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              if (onTap != null) ...[
                const SizedBox(width: 8),
                Icon(
                  Icons.chevron_right_rounded,
                  size: 22,
                  color: Theme.of(context).brightness == Brightness.dark
                      ? const Color(0xFF00D4FF)
                      : const Color(0xFF1565C0),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  void _openUpcomingQuiz(Course course, CourseQuiz quiz) {
    context.go(
      AppRoutes.studentCoursesScreen,
      extra: StudentCourseDestination(course: course, quizId: quiz.id),
    );
  }
}
