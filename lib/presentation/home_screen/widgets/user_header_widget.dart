import 'dart:ui';

import 'package:provider/provider.dart';
import '../../../core/app_export.dart';
import '../../../services/auth_service.dart';

class UserHeaderWidget extends StatelessWidget {
  final VoidCallback onNotificationTap;
  const UserHeaderWidget({required this.onNotificationTap, super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
          color: Theme.of(context).scaffoldBackgroundColor.withAlpha(220),
          child: Row(
            children: [
              // Avatar
              GestureDetector(
                onTap: () => context.go('/teacher-profile-screen'),
                child: Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: const Color(0xFF00D4FF).withAlpha(153),
                      width: 2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF00D4FF).withAlpha(51),
                        blurRadius: 12,
                      ),
                    ],
                  ),
                  child: ClipOval(
                    child: CustomImageWidget(
                      imageUrl: context.watch<AuthService>().currentUser?.avatarUrl ?? 'https://images.pexels.com/photos/3769021/pexels-photo-3769021.jpeg?auto=compress&cs=tinysrgb&w=400',
                      width: 48,
                      height: 48,
                      fit: BoxFit.cover,
                      semanticLabel: 'Teacher avatar',
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              // Name + progress
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Hello ${context.watch<AuthService>().currentUser?.name ?? 'Teacher'} 👋',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: isDark ? Colors.white : const Color(0xFF0A1628),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        CustomIconWidget(
                          iconName: 'menu_book',
                          color: const Color(0xFF00D4FF),
                          size: 14,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(50),
                            child: LinearProgressIndicator(
                              value: 0.62,
                              backgroundColor: isDark ? const Color(0xFF1E3A5F) : Colors.grey.shade300,
                              valueColor: const AlwaysStoppedAnimation<Color>(
                                Color(0xFF00D4FF),
                              ),
                              minHeight: 6,
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                        const Text(
                          '62%',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF00D4FF),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              // Notification bell
              GestureDetector(
                onTap: onNotificationTap,
                child: Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF142240) : Colors.white,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isDark ? const Color(0xFF1E3A5F) : Colors.grey.shade300,
                      width: 1,
                    ),
                  ),
                  child: Stack(
                    children: [
                      Center(
                        child: CustomIconWidget(
                          iconName: 'notifications_outlined',
                          color: isDark ? const Color(0xFF8BA3C0) : Colors.grey.shade700,
                          size: 22,
                        ),
                      ),
                      Positioned(
                        top: 10,
                        right: 10,
                        child: Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: Color(0xFF00D4FF),
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
