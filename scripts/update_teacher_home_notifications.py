import re

def update_teacher_home_notifications():
    filepath = 'd:/StudioProjects/scilab_flutter_1/lib/presentation/teacher_home_screen/teacher_home_screen.dart'
    with open(filepath, 'r', encoding='utf-8') as f:
        content = f.read()

    # Add imports
    imports_to_add = """import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/user_model.dart';
import '../../models/course_model.dart';
import '../../models/activity_model.dart';
"""
    if "import 'package:cloud_firestore/cloud_firestore.dart';" not in content:
        content = re.sub(r"(import 'package:provider/provider\.dart';)", r"\1\n" + imports_to_add, content)

    # _fetchDynamicNotifications
    # _showNotificationsDialog

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
      final db = FirebaseFirestore.instance;
      // Get 5 recent quizzes
      final qSnap = await db.collection('quiz_attempts').orderBy('submittedAt', descending: true).limit(5).get();
      for (var doc in qSnap.docs) {
         final data = doc.data();
         final studentId = data['studentId'] as String? ?? '';
         final title = data['quizTitle'] as String? ?? '';
         final ts = data['submittedAt'] as Timestamp?;
         
         // Fetch student name
         String name = 'A student';
         if (studentId.isNotEmpty) {
           final sDoc = await db.collection('users').doc(studentId).get();
           if (sDoc.exists) name = sDoc.data()?['name'] ?? name;
         }

         notifications.add({
           'title': 'Quiz Submitted',
           'desc': '$name submitted $title.',
           'icon': 'assignment_turned_in',
           'color': const Color(0xFF00D4FF),
           'timeStr': _formatNotificationTime(ts?.toDate()),
           'timestamp': ts?.toDate() ?? DateTime.now(),
         });
      }
      
      // Since fetching recent activities across all subcollections requires collectionGroup,
      // we'll use collectionGroup('experiment_activity') if indexing allows, 
      // otherwise this is a prototype so we'll just query global recent quiz attempts for now.
      
      // Sort by timestamp
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
                            const CustomIconWidget(iconName: 'notifications', color: Color(0xFF7C3AED), size: 24),
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
                            child: CustomIconWidget(iconName: 'close', color: Theme.of(context).brightness == Brightness.dark ? const Color(0xFF8BA3C0) : Colors.grey.shade600, size: 16),
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
        with open(filepath, 'w', encoding='utf-8') as f:
            f.write(content)
        print("Updated teacher_home_screen.dart")
    else:
        print("Already updated.")

if __name__ == '__main__':
    update_teacher_home_notifications()
