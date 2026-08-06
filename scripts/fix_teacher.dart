import 'dart:io';

void main() {
  final path = 'lib/presentation/teacher_ar_and_video_lesson_screen/teacher_ar_and_video_lesson_screen.dart';
  final file = File(path);
  
  var content = file.readAsStringSync();
  content = content.replaceAll('StudentArAndVideoLessonScreen', 'TeacherArAndVideoLessonScreen');
  content = content.replaceAll('isTeacher: false', 'isTeacher: true');
  content = content.replaceAll('isLocked: _lockedStates[_selectedExperiment!.id] ?? false', 'isLocked: false');
  
  file.writeAsStringSync(content);
}
