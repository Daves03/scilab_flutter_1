import 'dart:ui';
import 'dart:async';
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
import '../../services/auth_service.dart';



class TeacherArAndVideoLessonScreen extends StatefulWidget {
  const TeacherArAndVideoLessonScreen({super.key});

  @override
  State<TeacherArAndVideoLessonScreen> createState() =>
      _TeacherArAndVideoLessonScreenState();
}

// TODO: Replace with [Riverpod/Bloc] for production
class _TeacherArAndVideoLessonScreenState
    extends State<TeacherArAndVideoLessonScreen>
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

  




  Map<String, List<String>> _sectionLocks = {};
  StreamSubscription? _lockSub;
  List<String> _teacherSections = [];

  @override
  void initState() {
    super.initState();
    _entranceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..forward();
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _listenToLocks();
    });
  }

  void _listenToLocks() {
    final user = AuthService.instance.currentUser;
    if (user == null || user.sections.isEmpty) return;
    
    _teacherSections = user.sections;
    _lockSub = context.read<ArService>().streamSectionLocks(user.sections).listen((locks) {
      if (mounted) {
        setState(() {
          _sectionLocks = locks;
        });
      }
    });
  }

  bool _isExpLocked(String expId) {
    for (final list in _sectionLocks.values) {
      if (list.contains(expId)) return true;
    }
    return false;
  }

  Set<String> _getLockedSectionsFor(String expId) {
    final Set<String> lockedSections = {};
    _sectionLocks.forEach((section, list) {
      if (list.contains(expId)) lockedSections.add(section);
    });
    return lockedSections;
  }

  Future<void> _toggleSectionLock(String section, bool locked) async {
    if (_selectedExperiment == null) return;
    await context.read<ArService>().toggleExperimentLockForSection(section, _selectedExperiment!.id, locked);
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
                          isLocked: _isExpLocked(_selectedExperiment!.id),
                          isTeacher: true,
                          teacherSections: _teacherSections,
                          lockedSections: _getLockedSectionsFor(_selectedExperiment!.id),
                          onToggleSectionLock: _toggleSectionLock,
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
                  isLocked: _isExpLocked(exp.id),
                  isTeacher: true,
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
                isLocked: _isExpLocked(_selectedExperiment!.id),
                isTeacher: true,
                teacherSections: _teacherSections,
                lockedSections: _getLockedSectionsFor(_selectedExperiment!.id),
                onToggleSectionLock: _toggleSectionLock,
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
              color: Theme.of(context).brightness == Brightness.dark ? const Color(0xFF0D3F2E) : const Color(0xFFE8FDF3),
              borderRadius: BorderRadius.circular(12.0),
              border: Border.all(color: Theme.of(context).brightness == Brightness.dark ? const Color(0x3300FF88) : const Color(0xFF00994C).withOpacity(0.3), width: 1),
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
                    color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black87,
                  ),
                ),
                Text(
                  'Teacher Dashboard',
                  style: TextStyle(
                    fontSize: 12,
                    color: Theme.of(context).brightness == Brightness.dark ? const Color(0xFF00FF88) : const Color(0xFF00994C),
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: Theme.of(context).brightness == Brightness.dark ? const Color(0x2200FF88) : const Color(0xFF00994C).withOpacity(0.1),
              borderRadius: BorderRadius.circular(50.0),
              border: Border.all(
                color: Theme.of(context).brightness == Brightness.dark ? const Color(0x5500FF88) : const Color(0xFF00994C).withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                CustomIconWidget(
                  iconName: 'verified',
                  color: Theme.of(context).brightness == Brightness.dark ? const Color(0xFF00FF88) : const Color(0xFF00994C),
                  size: 13,
                ),
                const SizedBox(width: 4),
                Text(
                  'Teacher',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).brightness == Brightness.dark ? const Color(0xFF00FF88) : const Color(0xFF00994C),
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