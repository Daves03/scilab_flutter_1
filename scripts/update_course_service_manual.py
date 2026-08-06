import os

filepath = 'lib/services/course_service.dart'
with open(filepath, 'r', encoding='utf-8') as f:
    content = f.read()

target = '''    return updateCourseFields(course.id, {
      'title': course.title,
      'subject': course.subject,
      'grade': course.grade,
      'accentColorValue': course.accentColorValue,
      'iconName': course.iconName,
    });'''
repl = '''    return updateCourseFields(course.id, {
      'title': course.title,
      'subject': course.subject,
      'grade': course.grade,
      'accentColorValue': course.accentColorValue,
      'iconName': course.iconName,
      'assignedSections': course.assignedSections,
    });'''

if target in content:
    content = content.replace(target, repl)
    with open(filepath, 'w', encoding='utf-8') as f:
        f.write(content)
    print('Updated course_service.dart directly.')
else:
    print('Target not found or already updated.')
