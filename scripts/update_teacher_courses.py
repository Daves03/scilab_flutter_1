import os

filepath = 'lib/presentation/teacher_courses_screen/teacher_courses_screen.dart'
with open(filepath, 'r', encoding='utf-8') as f:
    content = f.read()

# Replace in _showCreateDialog
create_target = '''            final newCourse = Course(
              id: '',
              title: titleCtrl.text.trim(),
              subject: subjectCtrl.text.trim(),
              grade: gradeCtrl.text.trim(),
              teacherUid: user.id,
              teacherName: user.name,
              accentColorValue: 0xFF00D4FF,
              iconName: 'science',
              modules: [],
              quizzes: [],
            );'''
create_repl = '''            final newCourse = Course(
              id: '',
              title: titleCtrl.text.trim(),
              subject: subjectCtrl.text.trim(),
              grade: gradeCtrl.text.trim(),
              teacherUid: user.id,
              teacherName: user.name,
              accentColorValue: 0xFF00D4FF,
              iconName: 'science',
              modules: [],
              quizzes: [],
              assignedSections: user.sections,
            );'''
content = content.replace(create_target, create_repl)

# Replace in _showEditDialog
edit_target = '''            final updatedCourse = Course(
              id: course.id,
              title: titleCtrl.text.trim(),
              subject: subjectCtrl.text.trim(),
              grade: gradeCtrl.text.trim(),
              teacherUid: course.teacherUid,
              teacherName: course.teacherName,
              accentColorValue: course.accentColorValue,
              iconName: course.iconName,
              modules: course.modules,
              quizzes: course.quizzes,
            );'''
edit_repl = '''            final updatedCourse = Course(
              id: course.id,
              title: titleCtrl.text.trim(),
              subject: subjectCtrl.text.trim(),
              grade: gradeCtrl.text.trim(),
              teacherUid: course.teacherUid,
              teacherName: course.teacherName,
              accentColorValue: course.accentColorValue,
              iconName: course.iconName,
              modules: course.modules,
              quizzes: course.quizzes,
              assignedSections: course.assignedSections,
            );'''
content = content.replace(edit_target, edit_repl)

with open(filepath, 'w', encoding='utf-8') as f:
    f.write(content)
print('Updated teacher_courses_screen.dart')
