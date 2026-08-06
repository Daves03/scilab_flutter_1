import os

filepath = 'lib/presentation/student_courses_screen/student_courses_screen.dart'
with open(filepath, 'r', encoding='utf-8') as f:
    content = f.read()

# 1. Add import
if 'auth_service.dart' not in content:
    content = content.replace(
        'import \'../../services/course_service.dart\';',
        'import \'../../services/course_service.dart\';\nimport \'../../services/auth_service.dart\';'
    )

# 2. Filter courses
filter_target = '''  Widget _buildCourseList(List<Course> courses) {
    final filteredCourses = courses.where((c) {
      final query = _mainSearchQuery.toLowerCase();
      return c.title.toLowerCase().contains(query) || 
             c.teacher.toLowerCase().contains(query) ||
             c.subject.toLowerCase().contains(query) ||
             c.grade.toLowerCase().contains(query);
    }).toList();'''
    
filter_repl = '''  Widget _buildCourseList(List<Course> courses) {
    final user = context.read<AuthService>().currentUser;
    final userSection = user?.sections.isNotEmpty == true ? user!.sections.first : null;
    
    final sectionFilteredCourses = courses.where((c) {
      // If course has no assigned sections, it's visible to everyone (backward compatibility)
      if (c.assignedSections.isEmpty) return true;
      // Otherwise, only visible if student's section is in the assigned sections
      if (userSection == null) return false;
      return c.assignedSections.contains(userSection);
    }).toList();

    final filteredCourses = sectionFilteredCourses.where((c) {
      final query = _mainSearchQuery.toLowerCase();
      return c.title.toLowerCase().contains(query) || 
             c.teacher.toLowerCase().contains(query) ||
             c.subject.toLowerCase().contains(query) ||
             c.grade.toLowerCase().contains(query);
    }).toList();'''
    
content = content.replace(filter_target, filter_repl)

with open(filepath, 'w', encoding='utf-8') as f:
    f.write(content)
print('Updated student_courses_screen.dart')
