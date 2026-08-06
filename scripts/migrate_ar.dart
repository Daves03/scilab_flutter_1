import 'dart:io';

void main() {
  final files = [
    'lib/presentation/student_ar_and_video_lesson_screen/student_ar_and_video_lesson_screen.dart',
    'lib/presentation/teacher_ar_and_video_lesson_screen/teacher_ar_and_video_lesson_screen.dart',
  ];

  for (final path in files) {
    final file = File(path);
    if (!file.existsSync()) {
      print('File not found: $path');
      continue;
    }
    String content = file.readAsStringSync();

    // 1. Remove ArExperimentModel class from student file
    content = content.replaceAll(RegExp(r'class ArExperimentModel \{[\s\S]*?\}(?=\s*class (Student|Teacher)ArAndVideoLessonScreen)'), '');

    // 2. Add imports
    if (!content.contains('ar_experiment_model.dart')) {
      content = content.replaceFirst("import '../../routes/app_routes.dart';", 
        "import '../../routes/app_routes.dart';\nimport '../../models/ar_experiment_model.dart';\nimport 'package:provider/provider.dart';\nimport '../../services/ar_service.dart';");
    }

    // 3. Remove _experimentMaps completely
    content = content.replaceAll(RegExp(r'static const List<Map<String, dynamic>> _experimentMaps = \[[\s\S]*?\];'), '');

    // 4. Remove local _experiments state
    content = content.replaceAll(RegExp(r'List<ArExperimentModel> _experiments = \[\];'), '');

    // 5. Update _filteredExperiments to take a list of experiments instead of relying on state
    content = content.replaceAll(
      RegExp(r'List<ArExperimentModel> get _filteredExperiments => _selectedCategory == .All.\s*\?\s*_experiments\s*:\s*_experiments\.where\(\(e\) => e\.category == _selectedCategory\)\.toList\(\);'),
      '''
List<ArExperimentModel> _getFilteredExperiments(List<ArExperimentModel> exps) {
  return _selectedCategory == 'All' ? exps : exps.where((e) => e.category == _selectedCategory).toList();
}'''
    );

    // 6. Remove initialization logic in initState
    content = content.replaceAll(RegExp(r'_experiments = _experimentMaps[\s\S]*?\}\);'), '');

    // 7. Wrap main layout in StreamBuilder
    if (content.contains('return Scaffold(')) {
      content = content.replaceFirst(
        r'''return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        bottom: false,
        child: isTablet
            ? _buildTabletLayout()
            : Stack(
                children: [
                  _buildPhoneLayout(),
                  if (_selectedExperiment != null)
                    ArExperimentDetailWidget(
                      experiment: _selectedExperiment!,
                      isLocked: _lockedStates[_selectedExperiment!.id] ?? false,
                      isTeacher: false,
                      onClose: _onCloseDetail,
                      onRunAR: () => _onRunAR(_selectedExperiment!),
                    ),
                ],
              ),
      ),
    );''',
        '''return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        bottom: false,
        child: StreamBuilder<List<ArExperimentModel>>(
          stream: context.read<ArService>().experimentsStream(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            final experiments = snapshot.data ?? [];
            return isTablet
                ? _buildTabletLayout(experiments)
                : Stack(
                    children: [
                      _buildPhoneLayout(experiments),
                      if (_selectedExperiment != null)
                        ArExperimentDetailWidget(
                          experiment: _selectedExperiment!,
                          isLocked: _lockedStates[_selectedExperiment!.id] ?? false,
                          isTeacher: false,
                          onClose: _onCloseDetail,
                          onRunAR: () => _onRunAR(_selectedExperiment!),
                        ),
                    ],
                  );
          }
        )
      ),
    );'''
      );
    }
    
    // Also teacher screen has slightly different build method
    if (content.contains('isTeacher: true,')) {
      content = content.replaceFirst(
        r'''return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        bottom: false,
        child: isTablet
            ? _buildTabletLayout()
            : Stack(
                children: [
                  _buildPhoneLayout(),
                  if (_selectedExperiment != null)
                    ArExperimentDetailWidget(
                      experiment: _selectedExperiment!,
                      isLocked: false,
                      isTeacher: true,
                      onClose: _onCloseDetail,
                      onRunAR: () => _onRunAR(_selectedExperiment!),
                    ),
                ],
              ),
      ),
    );''',
        '''return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        bottom: false,
        child: StreamBuilder<List<ArExperimentModel>>(
          stream: context.read<ArService>().experimentsStream(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            final experiments = snapshot.data ?? [];
            return isTablet
                ? _buildTabletLayout(experiments)
                : Stack(
                    children: [
                      _buildPhoneLayout(experiments),
                      if (_selectedExperiment != null)
                        ArExperimentDetailWidget(
                          experiment: _selectedExperiment!,
                          isLocked: false,
                          isTeacher: true,
                          onClose: _onCloseDetail,
                          onRunAR: () => _onRunAR(_selectedExperiment!),
                        ),
                    ],
                  );
          }
        )
      ),
    );'''
      );
    }

    // 8. Update _buildPhoneLayout, _buildTabletLayout, _buildExperimentGrid to take `List<ArExperimentModel> experiments`
    content = content.replaceAll('Widget _buildPhoneLayout() {', 'Widget _buildPhoneLayout(List<ArExperimentModel> experiments) {');
    content = content.replaceAll('Widget _buildTabletLayout() {', 'Widget _buildTabletLayout(List<ArExperimentModel> experiments) {');
    content = content.replaceAll('Widget _buildExperimentGrid() {', 'Widget _buildExperimentGrid(List<ArExperimentModel> experiments) {');

    // 9. Update references to _filteredExperiments to _getFilteredExperiments(experiments)
    content = content.replaceAll('final filtered = _filteredExperiments;', 'final filtered = _getFilteredExperiments(experiments);');
    content = content.replaceAll('final isLocked = _lockedStates[e.id] ?? false;', 'final isLocked = _lockedStates[e.id] ?? false;');

    // 10. Update calls to these functions
    content = content.replaceAll('_buildExperimentGrid()', '_buildExperimentGrid(experiments)');
    
    file.writeAsStringSync(content);
    print('Updated \$path');
  }
}
