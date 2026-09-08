import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/user_model.dart';
import '../../models/course_model.dart';
import '../../models/activity_model.dart';
import 'package:provider/provider.dart';
import '../../services/auth_service.dart';

import '../../core/app_export.dart';
import '../../routes/app_routes.dart';
import '../../widgets/custom_icon_widget.dart';
import './widgets/user_header_widget.dart';

class StudentHomeScreen extends StatefulWidget {
  const StudentHomeScreen({super.key});

  @override
  State<StudentHomeScreen> createState() => _StudentHomeScreenState();
}

class _StudentHomeScreenState extends State<StudentHomeScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _entranceController;
  late Timer _timer;
  late DateTime _philippinesTime;
  List<Map<String, dynamic>> _notifications = [];
  Map<String, List<Map<String, dynamic>>> _deadlines = {'upcoming': [], 'missed': []};
  Map<String, dynamic> _progressStats = {'avgQuiz': '0%', 'labs': '0'};
  bool _isLoadingNotifications = true;
  bool _isLoadingDeadlines = true;
  bool _isLoadingProgress = true;
  StreamSubscription? _notificationsSub;
  StreamSubscription? _deadlinesSub;
  bool _hasShownDeadlinePopup = false;

  @override
  void initState() {
    super.initState();
    _notificationsSub = _streamDynamicNotifications().listen((data) {
      if (mounted) {
        setState(() {
          _notifications = data;
          _isLoadingNotifications = false;
        });
      }
    }, onError: (e) {
      if (mounted) setState(() => _isLoadingNotifications = false);
    });

    _deadlinesSub = _streamUpcomingDeadlines().listen((data) {
      if (mounted) {
        setState(() {
          _deadlines = data;
          _isLoadingDeadlines = false;
        });
      }
    }, onError: (e) {
      if (mounted) setState(() => _isLoadingDeadlines = false);
    });

    _fetchProgressStats().then((data) {
      if (mounted) {
        setState(() {
          _progressStats = data;
          _isLoadingProgress = false;
        });
      }
    }).catchError((e) {
      if (mounted) setState(() => _isLoadingProgress = false);
    });
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
            color: Theme.of(context).brightness == Brightness.dark ? const Color(0xFF142240) : Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFFFF4757).withAlpha(100)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CustomIconWidget(iconName: 'warning', color: Color(0xFFFF4757), size: 48),
              const SizedBox(height: 16),
              Text(
                'Upcoming Deadlines!',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black87,
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
                      const CustomIconWidget(iconName: 'schedule', color: Color(0xFFFF4757), size: 20),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(quiz.title, style: const TextStyle(fontWeight: FontWeight.w600)),
                            Text(
                              'Due: ${date.month}/${date.day} at ${_formatTimeOnly(date)}',
                              style: const TextStyle(fontSize: 12, color: Color(0xFFFF4757)),
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
              )
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
    _timer.cancel();
    _entranceController.dispose();
    _notificationsSub?.cancel();
    _deadlinesSub?.cancel();
    super.dispose();
  }

  String _formatDateTime(DateTime dt) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    final month = months[dt.month - 1];
    final day = dt.day;
    final year = dt.year;
    
    final h = dt.hour == 0 ? 12 : (dt.hour > 12 ? dt.hour - 12 : dt.hour);
    final m = dt.minute.toString().padLeft(2, '0');
    final s = dt.second.toString().padLeft(2, '0');
    final ampm = dt.hour >= 12 ? 'PM' : 'AM';
    
    return '$month $day, $year  •  $h:$m:$s $ampm PHT';
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
              final hasUnread = _notifications.any((n) => (n['timestamp'] as DateTime).isAfter(lastRead));
              
              final avgStr = _progressStats['avgQuiz'] as String;
              final doubleVal = double.tryParse(avgStr.replaceAll('%', '')) ?? 0.0;
              final double progressPercent = doubleVal / 100.0;

              return UserHeaderWidget(
                hasUnreadNotifications: hasUnread,
                progressText: avgStr,
                progressPercent: progressPercent,
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
          child: _buildAnimatedSection(delay: 0, child: _buildNotificationsSection()),
        ),
        SliverToBoxAdapter(
          child: _buildAnimatedSection(delay: 100, child: _buildProgressSummarySection()),
        ),
        SliverToBoxAdapter(
          child: _buildAnimatedSection(delay: 200, child: _buildCalendarSection()),
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
              final hasUnread = _notifications.any((n) => (n['timestamp'] as DateTime).isAfter(lastRead));
              
              final avgStr = _progressStats['avgQuiz'] as String;
              final doubleVal = double.tryParse(avgStr.replaceAll('%', '')) ?? 0.0;
              final double progressPercent = doubleVal / 100.0;

              return UserHeaderWidget(
                hasUnreadNotifications: hasUnread,
                progressText: avgStr,
                progressPercent: progressPercent,
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
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 5,
                child: Column(
                  children: [
                    _buildAnimatedSection(delay: 0, child: _buildNotificationsSection()),
                    _buildAnimatedSection(delay: 200, child: _buildCalendarSection()),
                  ],
                ),
              ),
              Expanded(
                flex: 4,
                child: _buildAnimatedSection(delay: 100, child: _buildProgressSummarySection()),
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
        final slide = Tween<Offset>(
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
          child: FadeTransition(
            opacity: _entranceController,
            child: child,
          ),
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
    
    final db = FirebaseFirestore.instance;
    return db.collection('courses').where('grade', isEqualTo: user.role?.label).snapshots().map((cSnap) {
      List<Map<String, dynamic>> notifications = [];
      for (var doc in cSnap.docs) {
        final course = Course.fromMap(doc.id, doc.data());

        // Course Created
        if (course.createdAt != null) {
           notifications.add({
             'title': 'New Course Added',
             'desc': '${course.teacherName} created the course ${course.title}.',
             'icon': 'school',
             'color': const Color(0xFF7C3AED),
             'timeStr': _formatNotificationTime(course.createdAt),
             'timestamp': course.createdAt!,
             'course': course,
           });
        }
        
        // Modules
        for (var m in course.modules) {
           notifications.add({
             'title': 'New Module Uploaded',
             'desc': '${course.teacherName} uploaded ${m.title} in ${course.title}.',
             'icon': 'view_in_ar',
             'color': const Color(0xFF00D4FF),
             'timeStr': _formatNotificationTime(m.uploadedAt),
             'timestamp': m.uploadedAt ?? DateTime.now().subtract(const Duration(days: 365)),
             'course': course,
           });
        }
        
        // Quizzes
        for (var q in course.quizzes) {
           notifications.add({
             'title': 'New Quiz Available',
             'desc': '${course.teacherName} posted ${q.title} in ${course.title}.',
             'icon': 'quiz',
             'color': const Color(0xFFFFB300),
             'timeStr': _formatNotificationTime(q.createdAt),
             'timestamp': q.createdAt ?? DateTime.now().subtract(const Duration(days: 365)),
             'course': course,
           });

           // Upcoming deadlines
           if (q.dueDate != null && q.dueDate!.isAfter(DateTime.now())) {
             final diff = q.dueDate!.difference(DateTime.now());
             if (diff.inHours <= 48) {
               notifications.add({
                 'title': 'Quiz Deadline Approaching',
                 'desc': '${q.title} is due in ${diff.inHours} hours.',
                 'icon': 'schedule',
                 'color': const Color(0xFFFF4757),
                 'timeStr': 'Due soon',
                 'timestamp': q.dueDate!.subtract(const Duration(hours: 48)),
                 'course': course,
               });
             }
           }
        }
      }
      
      final clearedAt = user.notificationsClearedAt;
      if (clearedAt != null) {
        notifications.removeWhere((n) => !(n['timestamp'] as DateTime).isAfter(clearedAt));
      }

      notifications.sort((a, b) => (b['timestamp'] as DateTime).compareTo(a['timestamp'] as DateTime));
      if (notifications.length > 5) notifications = notifications.sublist(0, 5);
      return notifications;
    });
  }

  Stream<Map<String, List<Map<String, dynamic>>>> _streamUpcomingDeadlines() {
    final user = context.read<AuthService>().currentUser;
    if (user == null) return Stream.value({'upcoming': [], 'missed': []});
    
    final db = FirebaseFirestore.instance;
    return db.collection('courses').where('grade', isEqualTo: user.role?.label).snapshots().map((cSnap) {
      List<Map<String, dynamic>> upcoming = [];
      List<Map<String, dynamic>> missed = [];
      final now = DateTime.now();
      for (var doc in cSnap.docs) {
        final course = Course.fromMap(doc.id, doc.data());
        for (var q in course.quizzes) {
          if (q.dueDate != null) {
            if (q.dueDate!.isAfter(now)) {
              upcoming.add({
                'course': course,
                'quiz': q,
                'dueDate': q.dueDate!,
              });
            } else {
              missed.add({
                'course': course,
                'quiz': q,
                'dueDate': q.dueDate!,
              });
            }
          }
        }
      }
      upcoming.sort((a, b) => (a['dueDate'] as DateTime).compareTo(b['dueDate'] as DateTime));
      missed.sort((a, b) => (b['dueDate'] as DateTime).compareTo(a['dueDate'] as DateTime));
      return {'upcoming': upcoming, 'missed': missed};
    });
  }

  void _showNotificationsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          child: Container(
            width: 400,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Theme.of(context).brightness == Brightness.dark ? const Color(0xFF142240) : Colors.white,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: Theme.of(context).brightness == Brightness.dark ? const Color(0xFF1E3A5F) : Colors.grey.shade300),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Builder(
              builder: (ctx) {
                if (_isLoadingNotifications) {
                  return const SizedBox(
                    height: 200,
                    child: Center(child: CircularProgressIndicator()),
                  );
                }
                
                final notifs = _notifications;
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            const CustomIconWidget(iconName: 'notifications', color: Color(0xFF00D4FF), size: 24),
                            const SizedBox(width: 10),
                            Text(
                              'Notifications',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w700,
                                color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black87,
                              ),
                            ),
                          ],
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
                                      final isDark = Theme.of(context).brightness == Brightness.dark;
                                      return AlertDialog(
                                        backgroundColor: isDark ? const Color(0xFF142240) : Colors.white,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(16),
                                          side: BorderSide(color: isDark ? const Color(0xFF1E3A5F) : Colors.grey.shade300),
                                        ),
                                        title: Text(
                                          'Clear All Notifications',
                                          style: TextStyle(
                                            color: isDark ? Colors.white : Colors.black87,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                        content: Text(
                                          'Are you sure you want to clear all notifications?',
                                          style: TextStyle(
                                            color: isDark ? const Color(0xFF8BA3C0) : Colors.grey.shade700,
                                          ),
                                        ),
                                        actions: [
                                          TextButton(
                                            onPressed: () => Navigator.pop(confirmCtx),
                                            child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
                                          ),
                                          TextButton(
                                            onPressed: () {
                                              context.read<AuthService>().clearAllNotifications();
                                              Navigator.pop(confirmCtx);
                                              Navigator.pop(context);
                                            },
                                            child: const Text('Clear', style: TextStyle(color: Color(0xFFFF4757))),
                                          ),
                                        ],
                                      );
                                    },
                                  );
                                },
                                style: TextButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                  minimumSize: Size.zero,
                                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                ),
                                child: Text(
                                  'Clear All',
                                  style: TextStyle(
                                    color: Theme.of(context).brightness == Brightness.dark ? const Color(0xFF8BA3C0) : Colors.grey.shade600,
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
                                  color: Theme.of(context).brightness == Brightness.dark ? const Color(0xFF0A1628) : Colors.grey.shade200,
                                  shape: BoxShape.circle,
                                ),
                                child: CustomIconWidget(iconName: 'close', color: Theme.of(context).brightness == Brightness.dark ? const Color(0xFF8BA3C0) : Colors.grey.shade700, size: 16),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Flexible(
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
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 12),
                                  child: _buildNotificationItem(
                                    n['title'] as String,
                                    n['desc'] as String,
                                    n['icon'] as String,
                                    n['color'] as Color,
                                    n['timeStr'] as String,
                                    onTap: () {
                                      Navigator.pop(context);
                                      if (n['course'] != null) {
                                        context.go(AppRoutes.studentCoursesScreen, extra: n['course']);
                                      }
                                    },
                                  ),
                                );
                              }).toList(),
                          ],
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

  Widget _buildNotificationItem(String title, String desc, String icon, Color color, String time, {VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.dark ? const Color(0xFF0A1628) : Colors.grey.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Theme.of(context).brightness == Brightness.dark ? const Color(0xFF1E3A5F) : Colors.grey.shade300),
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
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black87,
                        ),
                      ),
                    ),
                    Text(
                      time,
                      style: TextStyle(
                        fontSize: 11,
                        color: Theme.of(context).brightness == Brightness.dark ? const Color(0xFF8BA3C0) : Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  desc,
                  style: TextStyle(
                    fontSize: 12,
                    color: Theme.of(context).brightness == Brightness.dark ? const Color(0xFF8BA3C0) : Colors.grey.shade600,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ));
  }

  Widget _buildDateTimeSection() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Dashboard',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w700,
              color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black87,
            ),
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              const CustomIconWidget(iconName: 'schedule', color: Color(0xFF00D4FF), size: 16),
              const SizedBox(width: 6),
              Text(
                _formatDateTime(_philippinesTime),
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF00D4FF),
                ),
              ),
            ],
          ),
        ],
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
              color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black87,
            ),
          ),
          const SizedBox(height: 12),
          Builder(
            builder: (ctx) {
              if (_isLoadingNotifications) {
                return const Center(child: CircularProgressIndicator());
              }
              final notifs = _notifications;
              if (notifs.isEmpty) {
                 return const Padding(
                    padding: EdgeInsets.symmetric(vertical: 20),
                    child: Text('No new content.', style: TextStyle(color: Colors.grey)),
                 );
              }
              // take top 2
              final top2 = notifs.take(2).toList();
              return Column(
                children: top2.map((n) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: _buildAlertCard(
                      title: n['title'] as String,
                      subtitle: n['desc'] as String,
                      icon: n['icon'] as String,
                      color: n['color'] as Color,
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

  Widget _buildAlertCard({required String title, required String subtitle, required String icon, required Color color}) {
    return Container(
        padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withAlpha(20),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withAlpha(80), width: 1),
      ),
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
                    color: Theme.of(context).brightness == Brightness.dark ? Colors.white.withAlpha(200) : Colors.black54,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }


  Future<Map<String, dynamic>> _fetchProgressStats() async {
    final user = context.read<AuthService>().currentUser;
    if (user == null) return {'avgQuiz': '0%', 'labs': '0'};
    final db = FirebaseFirestore.instance;
    
    // fetch quizzes
    final qSnap = await db.collection('quiz_attempts').where('studentId', isEqualTo: user.id).get();
    double totalScore = 0;
    int quizCount = 0;
    for (var doc in qSnap.docs) {
       final data = doc.data();
       final s = (data['score'] as num?)?.toInt() ?? 0;
       final t = (data['totalQuestions'] as num?)?.toInt() ?? 1;
       if (t > 0) {
         totalScore += (s / t);
         quizCount++;
       }
    }
    final avg = quizCount > 0 ? (totalScore / quizCount) * 100 : 0.0;
    
    // fetch labs
    final lSnap = await db.collection('users').doc(user.id).collection('experiment_activity').where('completedAt', isNotEqualTo: null).get();
    
    return {
       'avgQuiz': '${avg.toStringAsFixed(0)}%',
       'labs': '${lSnap.docs.length}',
    };
  }

  Widget _buildProgressSummarySection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Progress Summary',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black87,
            ),
          ),
          const SizedBox(height: 12),
          Builder(
            builder: (ctx) {
              if (_isLoadingProgress) {
                return const Center(child: CircularProgressIndicator());
              }
              final stats = _progressStats;
              return Row(
                children: [
                  Expanded(child: _buildSummaryCard('Avg Quiz Score', stats['avgQuiz'] as String, 'quiz', const Color(0xFF00D4FF))),
                  const SizedBox(width: 12),
                  Expanded(child: _buildSummaryCard('Completed Labs', stats['labs'] as String, 'biotech', const Color(0xFF7C3AED))),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(String title, String value, String icon, Color color, {bool isWide = false}) {
    return Container(
        padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.dark ? const Color(0xFF142240) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Theme.of(context).brightness == Brightness.dark ? const Color(0xFF1E3A5F) : Colors.grey.shade300),
      ),
      child: isWide 
        ? Row(
            children: [
              CustomIconWidget(iconName: icon, color: color, size: 28),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(fontSize: 14, color: Theme.of(context).brightness == Brightness.dark ? const Color(0xFF8BA3C0) : Colors.grey.shade700),
                ),
              ),
              Text(
                value,
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700, color: color),
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
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700, color: color),
              ),
              const SizedBox(height: 4),
              Text(
                title,
                style: TextStyle(fontSize: 13, color: Theme.of(context).brightness == Brightness.dark ? const Color(0xFF8BA3C0) : Colors.grey.shade700),
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
              CustomIconWidget(iconName: 'calendar_month', color: Theme.of(context).brightness == Brightness.dark ? const Color(0xFF8BA3C0) : Colors.grey.shade700, size: 20),
              SizedBox(width: 8),
              Text(
                'Upcoming Due Dates',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black87,
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
                    color: Theme.of(context).brightness == Brightness.dark ? const Color(0xFF142240) : Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Theme.of(context).brightness == Brightness.dark ? const Color(0xFF1E3A5F) : Colors.grey.shade300),
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
                        color: Theme.of(context).brightness == Brightness.dark ? const Color(0xFF142240) : Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Theme.of(context).brightness == Brightness.dark ? const Color(0xFF1E3A5F) : Colors.grey.shade300),
                      ),
                      child: Column(
                        children: upcoming.take(4).map((d) {
                          final date = d['dueDate'] as DateTime;
                          const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
                          final m = months[date.month - 1];
                          final day = date.day.toString();
                          final title = (d['quiz'] as CourseQuiz).title;
                          final time = _formatTimeOnly(date);
                          final isUpcoming = date.difference(DateTime.now()).inHours <= 48;
                          
                          return _buildCalendarItem(day, m, title, time, isUpcoming);
                        }).toList(),
                      ),
                    ),
                  if (missed.isNotEmpty) ...[
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        CustomIconWidget(iconName: 'warning', color: const Color(0xFFFF4757), size: 20),
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
                        color: Theme.of(context).brightness == Brightness.dark ? const Color(0xFF142240) : Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xFFFF4757).withAlpha(100)),
                      ),
                      child: Column(
                        children: missed.take(3).map((d) {
                          final date = d['dueDate'] as DateTime;
                          const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
                          final m = months[date.month - 1];
                          final day = date.day.toString();
                          final title = (d['quiz'] as CourseQuiz).title;
                          final time = _formatTimeOnly(date);
                          
                          return _buildCalendarItem(day, m, title, time, false, isMissed: true);
                        }).toList(),
                      ),
                    ),
                  ],
                ],
              );
            },
          )
        ],
      ),
    );
  }

  Widget _buildCalendarItem(String day, String month, String title, String time, bool isUpcoming, {bool isMissed = false}) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            width: 50,
            padding: const EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(
              color: isMissed 
                  ? const Color(0xFFFF4757).withAlpha(20) 
                  : (isUpcoming ? const Color(0xFF00D4FF).withAlpha(20) : (Theme.of(context).brightness == Brightness.dark ? const Color(0xFF0A1628) : Colors.grey.shade50)),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: isMissed 
                  ? const Color(0xFFFF4757) 
                  : (isUpcoming ? const Color(0xFF00D4FF) : (Theme.of(context).brightness == Brightness.dark ? const Color(0xFF1E3A5F) : Colors.grey.shade300))),
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
                        : (isUpcoming ? const Color(0xFF00D4FF) : (Theme.of(context).brightness == Brightness.dark ? const Color(0xFF8BA3C0) : Colors.grey.shade600)),
                  ),
                ),
                Text(
                  day,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: isMissed
                        ? const Color(0xFFFF4757)
                        : (isUpcoming ? const Color(0xFF00D4FF) : (Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black87)),
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
                    color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black87,
                  ),
                ),
                SizedBox(height: 4),
                Row(
                  children: [
                    CustomIconWidget(iconName: 'schedule', color: Theme.of(context).brightness == Brightness.dark ? const Color(0xFF8BA3C0) : Colors.grey.shade600, size: 14),
                    SizedBox(width: 4),
                    Text(
                      time,
                      style: TextStyle(
                        fontSize: 13,
                        color: Theme.of(context).brightness == Brightness.dark ? const Color(0xFF8BA3C0) : Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
