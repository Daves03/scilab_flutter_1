import 'dart:ui';

import 'package:shared_preferences/shared_preferences.dart';

import '../core/app_export.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import '../models/user_model.dart';

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
      branchIndex: 3,
    ),
    _TabSpec(
      label: 'Profile',
      activeIcon: 'person',
      inactiveIcon: 'person_outline',
      branchIndex: 4,
    ),
  ];

  @override
  void initState() {
    super.initState();
  }

  void _onTabTap(int visualIndex) {
    final tab = _tabs[visualIndex];
    setState(() => _selectedVisualIndex = visualIndex);
    
    final userRole = context.read<AuthService>().currentUser?.role == UserRole.teacher ? 'teacher' : 'student';

    // For Home tab (branch 0), navigate to role-specific home screen
    if (tab.branchIndex == 0) {
      if (userRole == 'teacher') {
        context.go('/teacher-home-screen');
      } else {
        context.go('/student-home-screen');
      }
      return;
    }

    // For Courses tab (branch 1), navigate to role-specific courses screen
    if (tab.branchIndex == 1) {
      if (userRole == 'teacher') {
        context.go('/teacher-courses-screen');
      } else {
        context.go('/student-courses-screen');
      }
      return;
    }

    // For AR Lab tab (branch 2), navigate to role-specific AR screen
    if (tab.branchIndex == 2) {
      if (userRole == 'teacher') {
        context.go('/teacher-ar-and-video-lesson-screen');
      } else {
        context.go('/student-ar-and-video-lesson-screen');
      }
      return;
    }

    // For Progress tab (branch 3), navigate to role-specific progress screen
    if (tab.branchIndex == 3) {
      if (userRole == 'teacher') {
        context.go('/teacher-progress-screen');
      } else {
        context.go('/student-progress-screen');
      }
      return;
    }

    // For Profile tab (branch 4), navigate to role-specific profile screen
    if (tab.branchIndex == 4) {
      if (userRole == 'teacher') {
        context.go('/teacher-profile-screen');
      } else {
        context.go('/student-profile-screen');
      }
      return;
    }
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
    final theme = Theme.of(context);
    return Padding(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        bottom: 16 + MediaQuery.of(context).padding.bottom,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(36),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
            height: 72,
            decoration: BoxDecoration(
              color: theme.brightness == Brightness.dark ? const Color(0xFF0A1628).withAlpha(191) : Colors.white.withAlpha(220),
              border: Border.all(color: const Color(0x2200D4FF), width: 1),
              borderRadius: BorderRadius.circular(36),
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
                  opacity: 1.0,
                  child: SizedBox(
                    width: i == 2 ? 64 : 60,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 250),
                          curve: Curves.easeOutCubic,
                          width: i == 2 ? 46 : 44,
                          height: i == 2 ? 46 : 32,
                          decoration: BoxDecoration(
                            color: i == 2
                                ? (isActive ? const Color(0xFF00D4FF) : const Color(0x2200D4FF))
                                : (isActive
                                    ? const Color(0x2200D4FF)
                                    : Colors.transparent),
                            borderRadius: BorderRadius.circular(i == 2 ? 23 : 16),
                            border: i == 2 
                                ? Border.all(color: const Color(0xFF00D4FF), width: 1.5)
                                : null,
                            boxShadow: i == 2 && isActive
                                ? [
                                    BoxShadow(
                                      color: const Color(0xFF00D4FF).withAlpha(120),
                                      blurRadius: 12,
                                      offset: const Offset(0, 4),
                                    )
                                  ]
                                : [],
                          ),
                          child: Center(
                            child: CustomIconWidget(
                              iconName: isActive
                                  ? tab.activeIcon
                                  : tab.inactiveIcon,
                              color: i == 2
                                  ? (isActive ? const Color(0xFF0A1628) : const Color(0xFF00D4FF))
                                  : (isActive
                                      ? const Color(0xFF00D4FF)
                                      : (theme.brightness == Brightness.dark ? const Color(0xFF8BA3C0) : Colors.grey.shade500)),
                              size: i == 2 ? 26 : 22,
                            ),
                          ),
                        ),
                        const SizedBox(height: 2),
                        AnimatedDefaultTextStyle(
                          duration: const Duration(milliseconds: 200),
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: isActive || i == 2
                                ? FontWeight.w600
                                : FontWeight.w400,
                            color: isActive
                                ? const Color(0xFF00D4FF)
                                : (theme.brightness == Brightness.dark ? const Color(0xFF8BA3C0) : Colors.grey.shade500),
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
      ),
    );
  }
}
