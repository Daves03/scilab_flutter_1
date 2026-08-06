import 'dart:ui';

import 'package:shared_preferences/shared_preferences.dart';

import '../core/app_export.dart';

// V3 Liquid Glass — BackdropFilter blur + frosted surface + animated pill — LOCKED

class _TabSpec {
  final String label;
  final String activeIcon;
  final String inactiveIcon;
  final int? branchIndex;

  const _TabSpec({
    required this.label,
    required this.activeIcon,
    required this.inactiveIcon,
    this.branchIndex,
  });
}

class AppNavigation extends StatefulWidget {
  final StatefulNavigationShell navigationShell;
  const AppNavigation({required this.navigationShell, super.key});

  @override
  State<AppNavigation> createState() => _AppNavigationState();
}

class _AppNavigationState extends State<AppNavigation> {
  int _selectedVisualIndex = 0;
  String _userRole = 'student';

  static const List<_TabSpec> _tabs = [
    _TabSpec(
      label: 'Home',
      activeIcon: 'home',
      inactiveIcon: 'home_outlined',
      branchIndex: 0,
    ),
    _TabSpec(
      label: 'Courses',
      activeIcon: 'menu_book',
      inactiveIcon: 'menu_book_outlined',
      branchIndex: 1,
    ),
    _TabSpec(
      label: 'AR Lab',
      activeIcon: 'view_in_ar',
      inactiveIcon: 'view_in_ar_outlined',
      branchIndex: 2,
    ),
    _TabSpec(
      label: 'Progress',
      activeIcon: 'insights',
      inactiveIcon: 'insights_outlined',
      branchIndex: null,
    ),
    _TabSpec(
      label: 'Profile',
      activeIcon: 'person',
      inactiveIcon: 'person_outline',
      branchIndex: 3,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _loadUserRole();
  }

  Future<void> _loadUserRole() async {
    final prefs = await SharedPreferences.getInstance();
    if (mounted) {
      setState(() {
        _userRole = prefs.getString('user_role') ?? 'student';
      });
    }
  }

  void _onTabTap(int visualIndex) {
    final tab = _tabs[visualIndex];
    if (tab.branchIndex == null) {
      // Progress tab — navigate to role-specific progress screen
      if (visualIndex == 3) {
        setState(() => _selectedVisualIndex = visualIndex);
        if (_userRole == 'teacher') {
          context.go('/teacher-progress-screen');
        } else {
          context.go('/student-progress-screen');
        }
      }
      return;
    }
    setState(() => _selectedVisualIndex = visualIndex);

    // For Home tab (branch 0), navigate to role-specific home screen
    if (tab.branchIndex == 0) {
      if (_userRole == 'teacher') {
        context.go('/teacher-home-screen');
      } else {
        context.go('/student-home-screen');
      }
      return;
    }

    // For AR Lab tab (branch 2), navigate to role-specific AR screen
    if (tab.branchIndex == 2) {
      if (_userRole == 'teacher') {
        context.go('/teacher-ar-and-video-lesson-screen');
      } else {
        context.go('/student-ar-and-video-lesson-screen');
      }
      return;
    }

    // For Profile tab (branch 3), navigate to role-specific profile screen
    if (tab.branchIndex == 3) {
      if (_userRole == 'teacher') {
        context.go('/teacher-profile-screen');
      } else {
        context.go('/student-profile-screen');
      }
      return;
    }

    widget.navigationShell.goBranch(
      tab.branchIndex!,
      initialLocation: tab.branchIndex == widget.navigationShell.currentIndex,
    );
  }

  @override
  void didUpdateWidget(AppNavigation oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Sync visual index with shell index
    final currentBranch = widget.navigationShell.currentIndex;
    for (int i = 0; i < _tabs.length; i++) {
      if (_tabs[i].branchIndex == currentBranch) {
        if (_selectedVisualIndex != i) {
          setState(() => _selectedVisualIndex = i);
        }
        break;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          height: 72 + MediaQuery.of(context).padding.bottom,
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).padding.bottom,
          ),
          decoration: BoxDecoration(
            color: const Color(0xFF0A1628).withAlpha(191),
            border: const Border(
              top: BorderSide(color: Color(0x2200D4FF), width: 1),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(_tabs.length, (i) {
              final tab = _tabs[i];
              final isActive = _selectedVisualIndex == i;
              final isStub = tab.branchIndex == null;
              return GestureDetector(
                onTap: () => _onTabTap(i),
                behavior: HitTestBehavior.opaque,
                child: Opacity(
                  opacity: isStub ? 1.0 : 1.0,
                  child: SizedBox(
                    width: 60,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 250),
                          curve: Curves.easeOutCubic,
                          width: 44,
                          height: 32,
                          decoration: BoxDecoration(
                            color: isActive
                                ? const Color(0x2200D4FF)
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Center(
                            child: CustomIconWidget(
                              iconName: isActive
                                  ? tab.activeIcon
                                  : tab.inactiveIcon,
                              color: isActive
                                  ? const Color(0xFF00D4FF)
                                  : const Color(0xFF8BA3C0),
                              size: 22,
                            ),
                          ),
                        ),
                        const SizedBox(height: 2),
                        AnimatedDefaultTextStyle(
                          duration: const Duration(milliseconds: 200),
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: isActive
                                ? FontWeight.w600
                                : FontWeight.w400,
                            color: isActive
                                ? const Color(0xFF00D4FF)
                                : const Color(0xFF8BA3C0),
                          ),
                          child: Text(tab.label),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}
