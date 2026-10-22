import 'dart:async';

import '../../core/app_export.dart';
import '../../routes/app_routes.dart';
import '../../models/ar_experiment_model.dart';
import '../../data/ar_experiment_catalog.dart';
import 'package:provider/provider.dart';
import '../../services/ar_service.dart';
import '../student_ar_and_video_lesson_screen/widgets/ar_experiment_card_widget.dart';
import '../student_ar_and_video_lesson_screen/widgets/ar_experiment_detail_widget.dart';
import '../ar_and_video_lesson_screen/widgets/video_lesson_section_widget.dart';
import '../../services/auth_service.dart';
import '../../models/user_model.dart';
import '../../widgets/grade9_curriculum_button.dart';

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
  ArExperimentModel? _selectedExperiment;
  late AnimationController _entranceController;

  final Map<String, bool> _lockedStates = {};
  StreamSubscription? _lockSub;

  @override
  void initState() {
    super.initState();
    _entranceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..forward();

    // Using post frame callback to safely access context
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _listenToLocks();
    });
  }

  void _listenToLocks() {
    final user = AuthService.instance.currentUser;
    if (user == null || user.sections.isEmpty) return;

    _lockSub = context
        .read<ArService>()
        .streamLockedExperimentsForSections(user.sections)
        .listen((lockedIds) {
          if (mounted) {
            setState(() {
              _lockedStates.clear();
              for (final id in lockedIds) {
                _lockedStates[id] = true;
              }
            });
          }
        });
  }

  @override
  void dispose() {
    _lockSub?.cancel();
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
    context.push('${AppRoutes.unityArScreen}?experimentId=${experiment.id}');
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
              debugPrint('AR experiment stream failed: ${snapshot.error}');
              return Center(
                child: Text(
                  'Failed to load experiments. Please check permissions.',
                  style: TextStyle(color: Colors.red),
                ),
              );
            }
            final experiments = snapshot.data ?? [];
            final role = context.read<AuthService>().currentUser?.role;
            final groups = experimentGroupsForRole(experiments, role);
            return isTablet
                ? _buildTabletLayout(groups)
                : Stack(
                    children: [
                      _buildPhoneLayout(groups),
                      if (_selectedExperiment != null)
                        ArExperimentDetailWidget(
                          experiment: _selectedExperiment!,
                          isLocked:
                              _lockedStates[_selectedExperiment!.id] ?? false,
                          isTeacher: false,
                          onClose: _onCloseDetail,
                          onRunAR: () => _onRunAR(_selectedExperiment!),
                        ),
                    ],
                  );
          },
        ),
      ),
    );
  }

  Widget _buildPhoneLayout(List<ArExperimentGroup> groups) {
    final role = AuthService.instance.currentUser?.role;
    final curriculumGrade = switch (role) {
      UserRole.grade9 => 9,
      UserRole.grade10 => 10,
      _ => null,
    };

    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(child: _buildHeader()),
        if (curriculumGrade != null)
          SliverToBoxAdapter(
            child: DbowCurriculumButton(gradeLevel: curriculumGrade),
          ),
        SliverList(
          delegate: SliverChildListDelegate(_buildCatalogItems(groups)),
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

  List<Widget> _buildCatalogItems(List<ArExperimentGroup> groups) {
    final items = <Widget>[];
    var experimentIndex = 0;
    for (final group in groups) {
      items.add(
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 10, 20, 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                group.title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                group.subtitle,
                style: TextStyle(
                  fontSize: 12,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      );
      for (final experiment in group.experiments) {
        final delay = experimentIndex * 70;
        experimentIndex++;
        items.add(
          AnimatedBuilder(
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
                experiment: experiment,
                isLocked: _lockedStates[experiment.id] ?? false,
                isTeacher: false,
                onTap: () => _onExperimentTap(experiment),
                onRun: () => _onRunAR(experiment),
              ),
            ),
          ),
        );
      }
    }
    return items;
  }

  Widget _buildTabletLayout(List<ArExperimentGroup> groups) {
    return Row(
      children: [
        Expanded(flex: 5, child: _buildPhoneLayout(groups)),
        if (_selectedExperiment != null)
          Expanded(
            flex: 4,
            child: Container(
              margin: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).brightness == Brightness.dark
                    ? const Color(0xFF0F1E35)
                    : Colors.grey.shade100,
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
                    color: Theme.of(context).brightness == Brightness.dark
                        ? const Color(0xFF8BA3C0)
                        : Colors.grey.shade400,
                    size: 64,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Select an experiment',
                    style: TextStyle(
                      fontSize: 16,
                      color: Theme.of(context).brightness == Brightness.dark
                          ? const Color(0xFF8BA3C0)
                          : Colors.grey.shade500,
                    ),
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
              color: Theme.of(context).brightness == Brightness.dark
                  ? const Color(0xFF0D2E3F)
                  : const Color(0xFFE8F9FD),
              borderRadius: BorderRadius.circular(12.0),
              border: Border.all(
                color: Theme.of(context).brightness == Brightness.dark
                    ? const Color(0x3300D4FF)
                    : const Color(0xFF1565C0).withValues(alpha: 0.3),
                width: 1,
              ),
            ),
            clipBehavior: Clip.antiAlias,
            child: Image.asset(
              'assets/images/scilab_logo_cropped.png',
              fit: BoxFit.contain,
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
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Colors.white
                        : Colors.black87,
                  ),
                ),
                Text(
                  'Student Dashboard',
                  style: TextStyle(
                    fontSize: 12,
                    color: Theme.of(context).brightness == Brightness.dark
                        ? const Color(0xFF00D4FF)
                        : const Color(0xFF1565C0),
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: Theme.of(context).brightness == Brightness.dark
                  ? const Color(0x2200D4FF)
                  : const Color(0xFF1565C0).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(50.0),
              border: Border.all(
                color: Theme.of(context).brightness == Brightness.dark
                    ? const Color(0x5500D4FF)
                    : const Color(0xFF1565C0).withValues(alpha: 0.2),
                width: 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                CustomIconWidget(
                  iconName: 'school',
                  color: Theme.of(context).brightness == Brightness.dark
                      ? const Color(0xFF00D4FF)
                      : const Color(0xFF1565C0),
                  size: 13,
                ),
                const SizedBox(width: 4),
                Text(
                  'Student',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).brightness == Brightness.dark
                        ? const Color(0xFF00D4FF)
                        : const Color(0xFF1565C0),
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
