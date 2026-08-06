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
  late Stream<List<Map<String, dynamic>>> _notificationsStream;
  late Future<Map<String, dynamic>> _progressFuture;

  @override
  void initState() {
    super.initState();
    _notificationsStream = _streamDynamicNotifications();
    _progressFuture = _fetchProgressStats();
    _entranceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..forward();
    
    _updateTime();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) => _updateTime());
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
        SliverToBoxAdapter(child: UserHeaderWidget(onNotificationTap: () => _showNotificationsDialog(context))),
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
        const SliverToBoxAdapter(child: SizedBox(height: 100)),
      ],
    );
  }

  Widget _buildTabletLayout() {
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(child: UserHeaderWidget(onNotificationTap: () => _showNotificationsDialog(context))),
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
           });
        }
      }
      
      notifications.sort((a, b) => (b['timestamp'] as DateTime).compareTo(a['timestamp'] as DateTime));
      if (notifications.length > 5) notifications = notifications.sublist(0, 5);
      return notifications;
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
            child: StreamBuilder<List<Map<String, dynamic>>>(
              stream: _streamDynamicNotifications(),
              builder: (ctx, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const SizedBox(
                    height: 200,
                    child: Center(child: CircularProgressIndicator()),
                  );
                }
                
                final notifs = snapshot.data ?? [];
                return SingleChildScrollView(
                  child: Column(
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
                    const SizedBox(height: 20),
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
                          ),
                        );
                      }).toList(),
                  ],
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }

  Widget _buildNotificationItem(String title, String desc, String icon, Color color, String time) {
    return Container(
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
    );
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
          StreamBuilder<List<Map<String, dynamic>>>(
            stream: _notificationsStream,
            builder: (ctx, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              final notifs = snapshot.data ?? [];
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
          FutureBuilder<Map<String, dynamic>>(
            future: _progressFuture,
            builder: (ctx, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              final stats = snapshot.data ?? {'avgQuiz': '0%', 'labs': '0'};
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
          Container(
            decoration: BoxDecoration(
              color: Theme.of(context).brightness == Brightness.dark ? const Color(0xFF142240) : Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Theme.of(context).brightness == Brightness.dark ? const Color(0xFF1E3A5F) : Colors.grey.shade300),
            ),
            child: Column(
              children: [
                _buildCalendarItem('12', 'Nov', 'Advanced Physics Quiz', '8:00 AM', true),
                Divider(color: Theme.of(context).brightness == Brightness.dark ? const Color(0xFF1E3A5F) : Colors.grey.shade200, height: 1),
                _buildCalendarItem('15', 'Nov', 'Biology AR Simulation', '11:59 PM', false),
                Divider(color: Theme.of(context).brightness == Brightness.dark ? const Color(0xFF1E3A5F) : Colors.grey.shade200, height: 1),
                _buildCalendarItem('18', 'Nov', 'Chemistry Midterm', '10:00 AM', false),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildCalendarItem(String day, String month, String title, String time, bool isUpcoming) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            width: 50,
            padding: const EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(
              color: isUpcoming ? const Color(0xFF00D4FF).withAlpha(20) : (Theme.of(context).brightness == Brightness.dark ? const Color(0xFF0A1628) : Colors.grey.shade50),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: isUpcoming ? const Color(0xFF00D4FF) : (Theme.of(context).brightness == Brightness.dark ? const Color(0xFF1E3A5F) : Colors.grey.shade300)),
            ),
            child: Column(
              children: [
                Text(
                  month,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: isUpcoming ? const Color(0xFF00D4FF) : (Theme.of(context).brightness == Brightness.dark ? const Color(0xFF8BA3C0) : Colors.grey.shade600),
                  ),
                ),
                Text(
                  day,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: isUpcoming ? const Color(0xFF00D4FF) : (Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black87),
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
