import 'dart:ui';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:go_router/go_router.dart';

import '../../core/app_export.dart';
import '../../routes/app_routes.dart';
import '../../models/ar_experiment_model.dart';
import 'package:provider/provider.dart';
import '../../services/ar_service.dart';
import '../student_ar_and_video_lesson_screen/widgets/ar_experiment_card_widget.dart';
import '../student_ar_and_video_lesson_screen/widgets/ar_experiment_detail_widget.dart';
import '../student_ar_and_video_lesson_screen/widgets/category_filter_widget.dart';
import '../ar_and_video_lesson_screen/widgets/video_lesson_section_widget.dart';



class StudentArAndVideoLessonScreen extends StatefulWidget {
  const StudentArAndVideoLessonScreen({super.key});

  @override
  State<StudentArAndVideoLessonScreen> createState() =>
      _StudentArAndVideoLessonScreenState();
}

// TODO: Replace with [Riverpod/Bloc] for production
class _StudentArAndVideoLessonScreenState
    extends State<StudentArAndVideoLessonScreen>
    with SingleTickerProviderStateMixin {
  String _selectedCategory = 'All';
  ArExperimentModel? _selectedExperiment;
  late AnimationController _entranceController;

  

  static const List<String> _categories = [
    'All',
    'Chemical Reactions',
    'Precipitation',
    'Electrochemistry',
    'Spectroscopy',
  ];

  




  @override
  void initState() {
    super.initState();
    _loadLockStates();
    _entranceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..forward();
  }

  Map<String, bool> _lockedStates = {};

  Future<void> _loadLockStates() async {
    final prefs = await SharedPreferences.getInstance();
    final states = <String, bool>{};
    for (final key in prefs.getKeys()) {
      if (key.startsWith('locked_ar_')) {
        states[key.replaceFirst('locked_ar_', '')] = prefs.getBool(key) ?? false;
      }
    }
    if (mounted) {
      setState(() => _lockedStates = states);
    }
  }

  @override
  void dispose() {
    _entranceController.dispose();
    super.dispose();
  }

  void _onExperimentTap(ArExperimentModel experiment) {
    setState(() => _selectedExperiment = experiment);
  }

  void _onCloseDetail() {
    setState(() => _selectedExperiment = null);
  }

  void _onRunAR(ArExperimentModel experiment) {
    context.push('${AppRoutes.unityArScreen}?experimentId=${experiment.id.replaceAll('ar', '')}');
  }

  @override
  Widget build(BuildContext context) {
    final isTablet = MediaQuery.of(context).size.width >= 600;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        bottom: false,
        child: StreamBuilder<List<ArExperimentModel>>(
          stream: context.read<ArService>().experimentsStream(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              print('AR Stream Error: ');
              print('AR Stream StackTrace: ');
              return Center(
                child: Text('Failed to load experiments. Please check permissions.', style: TextStyle(color: Colors.red)),
              );
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
        ),
      ),
    );
  }

  Widget _buildPhoneLayout(List<ArExperimentModel> experiments) {
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(child: _buildHeader()),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: CategoryFilterWidget(
              categories: _categories,
              selected: _selectedCategory,
              onSelected: (c) => setState(() => _selectedCategory = c),
            ),
          ),
        ),
        SliverList(
          delegate: SliverChildBuilderDelegate((context, index) {
            if (index >= experiments.length) return null;
            final exp = experiments[index];
            final delay = index * 70;
            return AnimatedBuilder(
              animation: _entranceController,
              builder: (context, child) {
                final slide =
                    Tween<Offset>(
                      begin: const Offset(0, 0.12),
                      end: Offset.zero,
                    ).animate(
                      CurvedAnimation(
                        parent: _entranceController,
                        curve: Interval(
                          (delay / 600).clamp(0.0, 0.8),
                          ((delay + 300) / 600).clamp(0.0, 1.0),
                          curve: Curves.easeOutCubic,
                        ),
                      ),
                    );
                return SlideTransition(
                  position: slide,
                  child: FadeTransition(
                    opacity: _entranceController,
                    child: child,
                  ),
                );
              },
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
                child: ArExperimentCardWidget(
                  experiment: exp,
                  isLocked: _lockedStates[exp.id] ?? false,
                  isTeacher: false,
                  onTap: () => _onExperimentTap(exp),
                  onRun: () => _onRunAR(exp),
                ),
              ),
            );
          }, childCount: experiments.length),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 100),
            child: VideoLessonSectionWidget(),
          ),
        ),
      ],
    );
  }

  Widget _buildTabletLayout(List<ArExperimentModel> experiments) {
    return Row(
      children: [
        Expanded(flex: 5, child: _buildPhoneLayout(experiments)),
        if (_selectedExperiment != null)
          Expanded(
            flex: 4,
            child: Container(
              margin: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).brightness == Brightness.dark ? const Color(0xFF0F1E35) : Colors.grey.shade100,
                borderRadius: BorderRadius.circular(24),
              ),
              child: ArExperimentDetailWidget(
                experiment: _selectedExperiment!,
                isLocked: _lockedStates[_selectedExperiment!.id] ?? false,
                isTeacher: false,
                onClose: _onCloseDetail,
                onRunAR: () => _onRunAR(_selectedExperiment!),
                isInline: true,
              ),
            ),
          )
        else
          Expanded(
            flex: 4,
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CustomIconWidget(
                    iconName: 'view_in_ar',
                    color: Theme.of(context).brightness == Brightness.dark ? const Color(0xFF8BA3C0) : Colors.grey.shade400,
                    size: 64,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Select an experiment',
                    style: TextStyle(fontSize: 16, color: Theme.of(context).brightness == Brightness.dark ? const Color(0xFF8BA3C0) : Colors.grey.shade500),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Theme.of(context).brightness == Brightness.dark ? const Color(0xFF0D2E3F) : const Color(0xFFE8F9FD),
              borderRadius: BorderRadius.circular(12.0),
              border: Border.all(color: Theme.of(context).brightness == Brightness.dark ? const Color(0x3300D4FF) : const Color(0xFF00D4FF).withOpacity(0.3), width: 1),
            ),
            child: const Center(
              child: CustomIconWidget(
                iconName: 'view_in_ar',
                color: Color(0xFF00D4FF),
                size: 20,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'AR Lab',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black87,
                  ),
                ),
                Text(
                  'Student Dashboard',
                  style: TextStyle(fontSize: 12, color: Color(0xFF00D4FF)),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: const Color(0x2200D4FF),
              borderRadius: BorderRadius.circular(50.0),
              border: Border.all(color: const Color(0x5500D4FF), width: 1),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                CustomIconWidget(
                  iconName: 'school',
                  color: Color(0xFF00D4FF),
                  size: 13,
                ),
                SizedBox(width: 4),
                Text(
                  'Student',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF00D4FF),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}