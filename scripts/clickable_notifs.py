import re

def main():
    # 1. Update StudentCoursesScreen
    screen_path = 'd:/StudioProjects/scilab_flutter_1/lib/presentation/student_courses_screen/student_courses_screen.dart'
    with open(screen_path, 'r', encoding='utf-8') as f:
        content = f.read()
    
    content = content.replace("const StudentCoursesScreen({super.key});", "final Course? initialCourse;\n  const StudentCoursesScreen({this.initialCourse, super.key});")
    content = content.replace(
        "    _entranceController = AnimationController(",
        "    if (widget.initialCourse != null) _selectedCourse = widget.initialCourse;\n    _entranceController = AnimationController("
    )
    with open(screen_path, 'w', encoding='utf-8') as f:
        f.write(content)
        
    # 2. Update app_routes.dart
    routes_path = 'd:/StudioProjects/scilab_flutter_1/lib/routes/app_routes.dart'
    with open(routes_path, 'r', encoding='utf-8') as f:
        content = f.read()
        
    old_route = """              pageBuilder: (context, state) => CustomTransitionPage(
                key: state.pageKey,
                child: const StudentCoursesScreen(),"""
    new_route = """              pageBuilder: (context, state) {
                final course = state.extra as Course?;
                return CustomTransitionPage(
                key: state.pageKey,
                child: StudentCoursesScreen(initialCourse: course),"""
    content = content.replace(old_route, new_route)
    
    # We also need to add '}' at the end of the pageBuilder block for studentCoursesScreen
    # Let's find it with regex
    pattern = r"""(path: AppRoutes\.studentCoursesScreen,\s*pageBuilder: \(context, state\) \{\s*final course = state\.extra as Course\?;\s*return CustomTransitionPage\(.*?transitionDuration: const Duration\(milliseconds: 280\),\s*\),)"""
    content = re.sub(pattern, r"\1\n              },", content, flags=re.DOTALL)
    
    with open(routes_path, 'w', encoding='utf-8') as f:
        f.write(content)

    # 3. Update student_home_screen.dart
    home_path = 'd:/StudioProjects/scilab_flutter_1/lib/presentation/student_home_screen/student_home_screen.dart'
    with open(home_path, 'r', encoding='utf-8') as f:
        content = f.read()
        
    # a. add course to the notification objects in _streamDynamicNotifications
    content = content.replace("'timestamp': course.createdAt!,", "'timestamp': course.createdAt!,\n             'course': course,")
    content = content.replace("'timestamp': m.uploadedAt ?? DateTime.now().subtract(const Duration(days: 365)),", "'timestamp': m.uploadedAt ?? DateTime.now().subtract(const Duration(days: 365)),\n             'course': course,")
    content = content.replace("'timestamp': q.createdAt ?? DateTime.now().subtract(const Duration(days: 365)),", "'timestamp': q.createdAt ?? DateTime.now().subtract(const Duration(days: 365)),\n             'course': course,")
    
    # b. add onTap parameter to _buildNotificationItem
    old_build = "Widget _buildNotificationItem(String title, String desc, String icon, Color color, String time) {"
    new_build = "Widget _buildNotificationItem(String title, String desc, String icon, Color color, String time, {VoidCallback? onTap}) {"
    content = content.replace(old_build, new_build)
    
    # wrap Container with GestureDetector in _buildNotificationItem
    old_ret = """    return Container(
      padding: const EdgeInsets.all(16),"""
    new_ret = """    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),"""
    content = content.replace(old_ret, new_ret)
    
    # fix the closing parenthesis for Container
    content = content.replace("""                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );""", """                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ));""")

    # c. update Dialog calls
    old_dialog_call = """                                  child: _buildNotificationItem(
                                    n['title'] as String,
                                    n['desc'] as String,
                                    n['icon'] as String,
                                    n['color'] as Color,
                                    n['timeStr'] as String,
                                  ),"""
    new_dialog_call = """                                  child: _buildNotificationItem(
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
                                  ),"""
    content = content.replace(old_dialog_call, new_dialog_call)

    # d. update Recent calls
    old_recent_call = """                        child: _buildNotificationItem(
                          n['title'] as String,
                          n['desc'] as String,
                          n['icon'] as String,
                          n['color'] as Color,
                          n['timeStr'] as String,
                        ),"""
    new_recent_call = """                        child: _buildNotificationItem(
                          n['title'] as String,
                          n['desc'] as String,
                          n['icon'] as String,
                          n['color'] as Color,
                          n['timeStr'] as String,
                          onTap: () {
                            if (n['course'] != null) {
                              context.go(AppRoutes.studentCoursesScreen, extra: n['course']);
                            }
                          },
                        ),"""
    content = content.replace(old_recent_call, new_recent_call)
    
    with open(home_path, 'w', encoding='utf-8') as f:
        f.write(content)
        
    print("Done applying notification clicks")

if __name__ == '__main__':
    main()
