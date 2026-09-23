import 'dart:ui';

import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../core/app_export.dart';
import '../../../services/auth_service.dart';
import '../../student_profile_screen/student_profile_screen.dart';

class UserHeaderWidget extends StatelessWidget {
  final VoidCallback onNotificationTap;
  final bool hasUnreadNotifications;
  final String? progressText;
  final double? progressPercent;

  const UserHeaderWidget({
    required this.onNotificationTap,
    this.hasUnreadNotifications = false,
    this.progressText,
    this.progressPercent,
    super.key,
  });

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
              GestureDetector(
                onTap: () {
                  context.go('/student-profile-screen');
                },
                child: Container(
                  width: 48,
                  height: 48,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isDark ? const Color(0xFF00D4FF).withAlpha(153) : const Color(0xFF1565C0).withAlpha(153),
                    width: 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: isDark ? const Color(0xFF00D4FF).withAlpha(51) : const Color(0xFF1565C0).withAlpha(51),
                      blurRadius: 12,
                    ),
                  ],
                ),
                child: ClipOval(
                  child: CustomImageWidget(
                    imageUrl:
                        'https://images.pexels.com/photos/4145153/pexels-photo-4145153.jpeg',
                    width: 48,
                    height: 48,
                    fit: BoxFit.cover,
                    semanticLabel:
                        'Student avatar — young person studying chemistry',
                  ),
                ),
              ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Hello ${context.watch<AuthService>().currentUser?.name ?? 'User'} 👋',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: isDark ? Colors.white : const Color(0xFF0A1628),
                      ),
                    ),
                    if (progressText != null && progressPercent != null) ...[
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          CustomIconWidget(
                            iconName: 'menu_book',
                            color: isDark ? const Color(0xFF00D4FF) : const Color(0xFF1565C0),
                            size: 14,
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(50),
                              child: LinearProgressIndicator(
                                value: progressPercent,
                                backgroundColor: isDark ? const Color(0xFF1E3A5F) : Colors.grey.shade300,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  isDark ? const Color(0xFF00D4FF) : const Color(0xFF1565C0),
                                ),
                                minHeight: 6,
                              ),
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            progressText!,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: isDark ? const Color(0xFF00D4FF) : const Color(0xFF1565C0),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 12),
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
                      if (hasUnreadNotifications)
                        Positioned(
                          top: 10,
                          right: 10,
                          child: Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: isDark ? const Color(0xFF00D4FF) : const Color(0xFF1565C0),
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
