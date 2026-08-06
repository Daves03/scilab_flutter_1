import 'dart:io';

void main() {
  final files = [
    'lib/presentation/student_ar_and_video_lesson_screen/student_ar_and_video_lesson_screen.dart',
    'lib/presentation/teacher_ar_and_video_lesson_screen/teacher_ar_and_video_lesson_screen.dart',
  ];

  for (final path in files) {
    final file = File(path);
    if (!file.existsSync()) continue;
    
    var lines = file.readAsLinesSync();
    
    for (int i = 0; i < lines.length; i++) {
      if (lines[i].contains('_experiments = _experimentMaps')) {
        lines[i] = '';
      }
      if (lines[i].contains('tintColor: m[')) {
        lines[i] = "tintColorValue: m['tintColorValue'] as int,";
      }
      if (lines[i].contains('if (_experiments.isNotEmpty) {')) {
        lines[i] = "if (true) {";
      }
      if (lines[i].contains('_filteredExperiments.length')) {
        lines[i] = lines[i].replaceAll('_filteredExperiments.length', 'experiments.length');
      }
      if (lines[i].contains('_filteredExperiments[')) {
        lines[i] = lines[i].replaceAll('_filteredExperiments[', 'experiments[');
      }
      if (lines[i].contains('_buildPhoneLayout(),')) {
        lines[i] = lines[i].replaceAll('_buildPhoneLayout(),', '_buildPhoneLayout(experiments),');
      }
      if (lines[i].contains('filtered.length')) {
        lines[i] = lines[i].replaceAll('filtered.length', 'experiments.length'); // actually filtered is correctly created but wait, just use filtered
      }
      if (lines[i].contains('filtered[')) {
        lines[i] = lines[i].replaceAll('filtered[', 'experiments[');
      }
      if (lines[i].contains('_filteredExperiments.isEmpty')) {
         lines[i] = lines[i].replaceAll('_filteredExperiments.isEmpty', 'experiments.isEmpty');
      }
      if (lines[i].contains('!_experiments.any(')) {
         lines[i] = lines[i].replaceAll('!_experiments.any(', '!experiments.any(');
      }
      // Fix _getFilteredExperiments usage if needed
    }
    file.writeAsStringSync(lines.join('\n'));
  }
}
