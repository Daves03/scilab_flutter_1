import re

def main():
    filepath = 'd:/StudioProjects/scilab_flutter_1/lib/presentation/student_home_screen/student_home_screen.dart'
    with open(filepath, 'r', encoding='utf-8') as f:
        content = f.read()

    # Change _notificationsFuture to Stream
    content = content.replace("late Future<List<Map<String, dynamic>>> _notificationsFuture;", 
                              "late Stream<List<Map<String, dynamic>>> _notificationsStream;")
    
    # Change assignment in initState
    content = content.replace("_notificationsFuture = _fetchDynamicNotifications();", 
                              "_notificationsStream = _streamDynamicNotifications();")
    
    # Change _fetchDynamicNotifications to _streamDynamicNotifications
    stream_method = """
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
"""
    # Replace the old _fetchDynamicNotifications with _streamDynamicNotifications
    # We will regex replace the whole method
    old_method_pattern = r"Future<List<Map<String, dynamic>>> _fetchDynamicNotifications\(\) async \{.*?\n  \}"
    content = re.sub(old_method_pattern, stream_method.strip(), content, flags=re.DOTALL)
    
    # Replace FutureBuilder with StreamBuilder in _buildNotificationsSection
    content = re.sub(
        r"FutureBuilder<List<Map<String, dynamic>>>\(\s*future: _notificationsFuture,",
        r"StreamBuilder<List<Map<String, dynamic>>>(\n            stream: _notificationsStream,",
        content
    )
    
    # Replace FutureBuilder with StreamBuilder in the notification dialog
    content = re.sub(
        r"FutureBuilder<List<Map<String, dynamic>>>\(\s*future: _fetchDynamicNotifications\(\),",
        r"StreamBuilder<List<Map<String, dynamic>>>(\n              stream: _streamDynamicNotifications(),",
        content
    )

    with open(filepath, 'w', encoding='utf-8') as f:
        f.write(content)
        
    print("Updated student_home_screen.dart")

if __name__ == '__main__':
    main()
