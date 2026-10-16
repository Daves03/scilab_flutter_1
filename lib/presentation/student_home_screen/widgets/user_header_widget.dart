import 'dart:ui';

import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../core/app_export.dart';
import '../../../services/auth_service.dart';

class UserHeaderWidget extends StatelessWidget {
  final VoidCallback onNotificationTap;
  final bool hasUnreadNotifications;

  const UserHeaderWidget({
    required this.onNotificationTap,
    this.hasUnreadNotifications = false,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final currentUser = context.watch<AuthService>().currentUser;
    final avatarUrl = currentUser?.avatarUrl?.trim() ?? '';
    final savedStudentName = currentUser?.name.trim() ?? '';
    final studentName = savedStudentName.isEmpty ? 'Student' : savedStudentName;
    
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
                  child: avatarUrl.isNotEmpty
                      ? CustomImageWidget(
                          imageUrl: avatarUrl,
                          width: 48,
                          height: 48,
                          fit: BoxFit.cover,
                          semanticLabel: 'Student avatar',
                        )
                      : Container(
                          width: 48,
                          height: 48,
                          color: isDark
                              ? const Color(0xFF0D2E3F)
                              : const Color(0xFFE8F2FC),
                          alignment: Alignment.center,
                          child: Icon(
                            Icons.person_outline_rounded,
                            size: 26,
                            color: isDark
                                ? const Color(0xFF00D4FF)
                                : const Color(0xFF1565C0),
                          ),
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
                      studentName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: isDark ? Colors.white : const Color(0xFF0A1628),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 9,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: isDark
                            ? const Color(0x2200D4FF)
                            : const Color(0x1A1565C0),
                        borderRadius: BorderRadius.circular(50),
                        border: Border.all(
                          color: isDark
                              ? const Color(0x5500D4FF)
                              : const Color(0x331565C0),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          CustomIconWidget(
                            iconName: 'school',
                            color: isDark
                                ? const Color(0xFF00D4FF)
                                : const Color(0xFF1565C0),
                            size: 12,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Student',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: isDark
                                  ? const Color(0xFF00D4FF)
                                  : const Color(0xFF1565C0),
                            ),
                          ),
                        ],
                      ),
                    ),
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
