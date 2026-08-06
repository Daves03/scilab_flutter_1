import re

def update_student_home_screen():
    filepath = 'd:/StudioProjects/scilab_flutter_1/lib/presentation/student_home_screen/student_home_screen.dart'
    with open(filepath, 'r', encoding='utf-8') as f:
        content = f.read()

    imports_to_add = """import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/user_model.dart';
import '../../models/course_model.dart';
import '../../models/activity_model.dart';
import 'package:provider/provider.dart';
import '../../services/auth_service.dart';
"""
    if "import 'package:cloud_firestore/cloud_firestore.dart';" not in content:
        content = re.sub(r"(import 'package:flutter/material\.dart';)", r"\1\n" + imports_to_add, content)

    # 1. Update _showNotificationsDialog
    fetch_method = """
  String _formatNotificationTime(DateTime? dt) {
    if (dt == null) return '';
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 60) return '${diff.inMinutes} mins ago';
    if (diff.inHours < 24) return '${diff.inHours} hrs ago';
    return '${diff.inDays} days ago';
  }

  Future<List<Map<String, dynamic>>> _fetchDynamicNotifications() async {
    List<Map<String, dynamic>> notifications = [];
    try {
      final user = context.read<AuthService>().currentUser;
      if (user == null) return [];
      
      final db = FirebaseFirestore.instance;
      // Get courses matching user's grade
      final cSnap = await db.collection('courses').where('grade', isEqualTo: user.role.label).get();
      
      for (var doc in cSnap.docs) {
        final course = Course.fromMap(doc.id, doc.data());
        
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
      
    } catch (e) {
      print('Error fetching notifications: $e');
    }
    return notifications;
  }
"""

    dialog_replacement = """
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
            child: FutureBuilder<List<Map<String, dynamic>>>(
              future: _fetchDynamicNotifications(),
              builder: (ctx, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const SizedBox(
                    height: 200,
                    child: Center(child: CircularProgressIndicator()),
                  );
                }
                
                final notifs = snapshot.data ?? [];
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
                );
              },
            ),
          ),
        );
      },
    );
  }
"""
    dialog_pattern = re.compile(r"  void _showNotificationsDialog.*?Widget _buildNotificationItem", re.DOTALL)
    if "FutureBuilder" not in content:
        content = dialog_pattern.sub(fetch_method + "\n" + dialog_replacement + "\n  Widget _buildNotificationItem", content)
    
    # 2. Update _buildNotificationsSection
    urgent_deadlines = """
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
          FutureBuilder<List<Map<String, dynamic>>>(
            future: _fetchDynamicNotifications(),
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
"""
    urgent_pattern = re.compile(r"  Widget _buildNotificationsSection\(\) \{.*?Widget _buildAlertCard", re.DOTALL)
    if "Recent Course Content" not in content:
        content = urgent_pattern.sub(urgent_deadlines + "\n  Widget _buildAlertCard", content)

    # 3. Update Progress Summary
    progress_summary_replacement = """
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
            future: _fetchProgressStats(),
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
"""
    progress_pattern = re.compile(r"  Widget _buildProgressSummarySection\(\) \{.*?Widget _buildSummaryCard", re.DOTALL)
    if "_fetchProgressStats" not in content:
        content = progress_pattern.sub(progress_summary_replacement + "\n  Widget _buildSummaryCard", content)

    with open(filepath, 'w', encoding='utf-8') as f:
        f.write(content)
        
    print("Updated student_home_screen.dart")

if __name__ == '__main__':
    update_student_home_screen()
