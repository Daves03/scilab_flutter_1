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
      if (lines[i].contains('_buildPhoneLayout() {')) {
        lines[i] = lines[i].replaceAll('_buildPhoneLayout() {', '_buildPhoneLayout(List<ArExperimentModel> experiments) {');
      }
      if (lines[i].contains('_buildTabletLayout(),')) {
        lines[i] = lines[i].replaceAll('_buildTabletLayout(),', '_buildTabletLayout(experiments),');
      }
      if (lines[i].contains('_buildTabletLayout() {')) {
        lines[i] = lines[i].replaceAll('_buildTabletLayout() {', '_buildTabletLayout(List<ArExperimentModel> experiments) {');
      }
      if (lines[i].contains('_buildPhoneLayout();')) {
        lines[i] = lines[i].replaceAll('_buildPhoneLayout();', '_buildPhoneLayout(experiments);');
      }
      if (lines[i].contains('_buildTabletLayout();')) {
        lines[i] = lines[i].replaceAll('_buildTabletLayout();', '_buildTabletLayout(experiments);');
      }
      if (lines[i].contains('filtered.length')) {
        lines[i] = lines[i].replaceAll('filtered.length', 'experiments.length'); 
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
      if (lines[i].contains('_experiments.where')) {
         lines[i] = lines[i].replaceAll('_experiments.where', 'experiments.where');
      }
      if (lines[i].contains('_getFilteredExperiments')) {
         lines[i] = lines[i].replaceAll('_getFilteredExperiments(experiments)', 'experiments');
      }
      if (lines[i].contains('List<ArExperimentModel> _getFilteredExperiments')) {
         lines[i] = '';
         lines[i+1] = '';
         lines[i+2] = '';
      }
      // Fix initState map mapping syntax error
      if (lines[i].contains('.map(') && i < 100) {
        // the map syntax error: _experiments = _experimentMaps.map(...)
        // but we already deleted _experimentMaps.
        // Let's just delete the rest of the lines that were part of _experiments = _experimentMaps.map( ... ).toList();
      }
    }

    // A better approach for the initstate map error is to just replace the whole initState block
    String content = lines.join('\\n');
    content = content.replaceAll(RegExp(r'void initState\(\) \{[\s\S]*?\.\.forward\(\);[\s\S]*?\}', multiLine: true), 
      '''void initState() {
    super.initState();
    _entranceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..forward();
  }''');

    file.writeAsStringSync(content.replaceAll('\\n', '\n'));
  }
}
