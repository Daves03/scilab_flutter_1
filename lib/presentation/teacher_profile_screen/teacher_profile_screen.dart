import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:universal_html/html.dart' as html;
import 'package:go_router/go_router.dart';

import '../../core/app_export.dart';
import '../../services/auth_service.dart';
import '../../core/theme_provider.dart';
import '../../routes/app_routes.dart';

import '../../core/gallery_saver_web.dart'
    if (dart.library.io) '../../core/gallery_saver_mobile.dart';

class TeacherProfileScreen extends StatefulWidget {
  const TeacherProfileScreen({super.key});

  @override
  State<TeacherProfileScreen> createState() => _TeacherProfileScreenState();
}

class _TeacherProfileScreenState extends State<TeacherProfileScreen> {
  bool _isDownloading = false;

  static const String _markerAssetPath =
      'assets/images/scilab_AR_marker-1785125880437.png';

  String _teacherName = 'Teacher';
  String _email = '';
  List<String> _teacherSections = [];

  final String _avatarUrl =
      'https://images.pexels.com/photos/3769021/pexels-photo-3769021.jpeg?auto=compress&cs=tinysrgb&w=400';

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      final user = context.read<AuthService>().currentUser;
      _teacherName = user?.name ?? 'Teacher';
      _email = user?.email ?? 'teacher@scilabar.edu';
      _teacherSections = (user?.sections?.isNotEmpty ?? false) 
          ? user!.sections! 
          : ['Grade 9', 'Grade 10'];
    });
  }

  Future<void> _downloadMarker() async {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final confirm = await showDialog<bool>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          backgroundColor: isDark ? const Color(0xFF142240) : Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text(
            'Confirm Download',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w700,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
          content: Text(
            'Are you sure you want to download the AR Marker?',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: isDark ? const Color(0xFF8BA3C0) : Colors.grey.shade700,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: Text(
                'Cancel',
                style: TextStyle(
                  color: isDark ? const Color(0xFF8BA3C0) : Colors.grey.shade600,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF00FF88),
                foregroundColor: const Color(0xFF0A1628),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text('Download', style: TextStyle(fontWeight: FontWeight.w600)),
            ),
          ],
        );
      },
    );

    if (confirm != true) return;

    if (_isDownloading) return;
    setState(() => _isDownloading = true);

    try {
      final byteData = await rootBundle.load(_markerAssetPath);
      final bytes = byteData.buffer.asUint8List();

      if (kIsWeb) {
        final blob = html.Blob([bytes], 'image/png');
        final url = html.Url.createObjectUrlFromBlob(blob);
        final anchor = html.AnchorElement(href: url)
          ..setAttribute('download', 'scilab_ar_marker.png')
          ..click();
        html.Url.revokeObjectUrl(url);
        _showResultDialog('AR Marker saved to gallery!');
      } else {
        await saveImageBytesToGallery(bytes, 'scilab_ar_marker');
        _showResultDialog('AR Marker saved to gallery!');
      }
    } catch (e) {
      _showResultDialog('Download failed. Please try again.', isError: true);
    } finally {
      if (mounted) setState(() => _isDownloading = false);
    }
  }

  void _showResultDialog(String message, {bool isError = false}) {
    if (!mounted) return;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          backgroundColor: isDark ? const Color(0xFF142240) : Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text(
            isError ? 'Error' : 'Download Complete',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w700,
              color: isError ? const Color(0xFFFF4757) : (isDark ? Colors.white : Colors.black87),
            ),
          ),
          content: Text(
            message,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: isDark ? const Color(0xFF8BA3C0) : Colors.grey.shade700,
            ),
          ),
          actions: [
            ElevatedButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              style: ElevatedButton.styleFrom(
                backgroundColor: isError ? const Color(0xFFFF4757) : const Color(0xFF00FF88),
                foregroundColor: isError ? Colors.white : const Color(0xFF0A1628),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text('OK', style: TextStyle(fontWeight: FontWeight.w600)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF1A2E1A) : const Color(0xFFE8F9FD),
                      borderRadius: BorderRadius.circular(12.0),
                      border: Border.all(color: isDark ? const Color(0x3300FF88) : const Color(0xFF00FF88).withOpacity(0.3), width: 1),
                    ),
                    child: const Center(
                      child: CustomIconWidget(
                        iconName: 'person',
                        color: Color(0xFF00FF88),
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
                          'My Profile',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                            color: isDark ? Colors.white : Colors.black87,
                          ),
                        ),
                        Text(
                          'Teacher Dashboard',
                          style: TextStyle(fontSize: 12, color: isDark ? const Color(0xFF00FF88) : const Color(0xFF00A050)),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: const Color(0x2200FF88),
                      borderRadius: BorderRadius.circular(50.0),
                      border: Border.all(color: const Color(0x5500FF88), width: 1),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const CustomIconWidget(
                          iconName: 'verified',
                          color: Color(0xFF00FF88),
                          size: 13,
                        ),
                        SizedBox(width: 4),
                        Text(
                          'Teacher',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: isDark ? const Color(0xFF00FF88) : const Color(0xFF00A050),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 28),

              // Profile card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: isDark
                      ? const LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [Color(0xFF1A2A42), Color(0xFF0F192E)],
                        )
                      : null,
                  color: isDark ? null : Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: isDark ? const Color(0x3300FF88) : Colors.grey.shade200,
                    width: 1,
                  ),
                  boxShadow: isDark
                      ? [
                          const BoxShadow(
                            color: Color(0x1100FF88),
                            blurRadius: 20,
                            offset: Offset(0, 8),
                          )
                        ]
                      : [
                          BoxShadow(
                            color: Colors.black.withAlpha(15),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                ),
                child: Column(
                  children: [
                    Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: const Color(0xFF00FF88), width: 3),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x4400FF88),
                            blurRadius: 15,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: ClipOval(
                        child: Image.network(
                          _avatarUrl,
                          fit: BoxFit.cover,
                          semanticLabel: 'Teacher profile photo',
                          errorBuilder: (_, __, ___) => Container(
                            color: const Color(0xFF1A2E1A),
                            child: const Icon(
                              Icons.person,
                              size: 44,
                              color: Color(0xFF00FF88),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      _teacherName,
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                      decoration: BoxDecoration(
                        color: const Color(0x2200FF88),
                        borderRadius: BorderRadius.circular(50),
                        border: Border.all(color: const Color(0x5500FF88)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const CustomIconWidget(
                            iconName: 'verified',
                            color: Color(0xFF00FF88),
                            size: 14,
                          ),
                          const SizedBox(width: 5),
                          Text(
                            'Verified Teacher',
                            style: theme.textTheme.labelMedium?.copyWith(
                              color: isDark ? const Color(0xFF00FF88) : const Color(0xFF00A050),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    Divider(
                      color: isDark ? const Color(0xFF1E3A5F) : Colors.grey.shade200,
                    ),
                    const SizedBox(height: 20),
                    _InfoRow(
                      icon: 'email_outlined',
                      label: 'Email Address',
                      value: _email,
                      isDark: isDark,
                    ),
                    if (_teacherSections.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      _SectionsRow(sections: _teacherSections, isDark: isDark),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // AR Marker download section
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: isDark
                      ? const LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [Color(0xFF1A2E1A), Color(0xFF0A1F0A)],
                        )
                      : null,
                  color: isDark ? null : const Color(0xFFE8F9FD),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: isDark ? const Color(0x3300FF88) : const Color(0xFF00FF88).withAlpha(80),
                    width: 1,
                  ),
                  boxShadow: isDark
                      ? [
                          const BoxShadow(
                            color: Color(0x1100FF88),
                            blurRadius: 20,
                            offset: Offset(0, 8),
                          )
                        ]
                      : [],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: const Color(0x2200FF88),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const CustomIconWidget(
                            iconName: 'view_in_ar',
                            color: Color(0xFF00FF88),
                            size: 22,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Scilab AR Marker',
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'Download and print for AR experiments',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: isDark ? const Color(0xFF8BA3C0) : Colors.grey.shade600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0x3300FF88)),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x22000000),
                            blurRadius: 10,
                            offset: Offset(0, 4),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(15),
                        child: Image.asset(
                          _markerAssetPath,
                          height: 160,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          semanticLabel: 'Scilab AR marker image',
                          errorBuilder: (_, __, ___) => Container(
                            height: 160,
                            color: const Color(0xFF0D2E3F),
                            child: const Center(
                              child: CustomIconWidget(
                                iconName: 'view_in_ar',
                                color: Color(0xFF00FF88),
                                size: 48,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton.icon(
                        onPressed: _isDownloading ? null : _downloadMarker,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF00FF88),
                          foregroundColor: const Color(0xFF0A1628),
                          elevation: 4,
                          shadowColor: const Color(0x6600FF88),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          disabledBackgroundColor: const Color(0xFF00FF88).withAlpha(100),
                        ),
                        icon: _isDownloading
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.5,
                                  color: Color(0xFF0A1628),
                                ),
                              )
                            : const CustomIconWidget(
                                iconName: 'download',
                                color: Color(0xFF0A1628),
                                size: 20,
                              ),
                        label: Text(
                          _isDownloading ? 'Saving to Gallery...' : 'Download AR Marker',
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              // About App Button
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton.icon(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (BuildContext dialogContext) {
                        return AlertDialog(
                          backgroundColor: isDark ? const Color(0xFF142240) : Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          title: Text(
                            'About App & Developer',
                            style: theme.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.w700,
                              color: isDark ? Colors.white : Colors.black87,
                            ),
                          ),
                          content: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Image.asset(
                                    'assets/images/scilab_logo-1784970842098.png',
                                    width: 56,
                                    height: 56,
                                  ),
                                  const SizedBox(width: 12),
                                  Text(
                                    'Scilab AR',
                                    style: theme.textTheme.titleMedium?.copyWith(
                                      fontWeight: FontWeight.w700,
                                      color: isDark ? Colors.white : Colors.black87,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'Version 1.0',
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: isDark ? const Color(0xFF8BA3C0) : Colors.grey.shade600,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                'Designed and developed exclusively for Las Piñas National High School - Main',
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: isDark ? const Color(0xFF8BA3C0) : Colors.grey.shade700,
                                  height: 1.4,
                                ),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                'Technical Credits: Built by Scilab AR Team',
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: isDark ? const Color(0xFF8BA3C0) : Colors.grey.shade700,
                                ),
                              ),
                              const SizedBox(height: 12),
                              Image.asset(
                                'assets/images/unity_logo.png',
                                height: 40,
                                color: isDark ? Colors.grey.shade300 : Colors.grey.shade800,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Core Technology AR: Powered by Unity Game Engine',
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: isDark ? const Color(0xFF8BA3C0) : Colors.grey.shade700,
                                ),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                'Contact us : scilabar@gmail.com',
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: isDark ? const Color(0xFF00FF88) : Colors.green,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                          actions: [
                            ElevatedButton(
                              onPressed: () => Navigator.of(dialogContext).pop(),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF00FF88),
                                foregroundColor: const Color(0xFF0A1628),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              child: const Text('Close', style: TextStyle(fontWeight: FontWeight.w600)),
                            ),
                          ],
                        );
                      },
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    foregroundColor: const Color(0xFF8BA3C0),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                      side: const BorderSide(color: Color(0xFF334A66), width: 1.5),
                    ),
                  ),
                  icon: const Icon(Icons.info_outline, size: 20),
                  label: const Text(
                    'About App & Developer',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // Logout Button
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton.icon(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (BuildContext dialogContext) {
                        return AlertDialog(
                          backgroundColor: isDark ? const Color(0xFF142240) : Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          title: Text(
                            'Log Out',
                            style: theme.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.w700,
                              color: isDark ? Colors.white : Colors.black87,
                            ),
                          ),
                          content: Text(
                            'Are you sure you want to log out?',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: isDark ? const Color(0xFF8BA3C0) : Colors.grey.shade700,
                            ),
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.of(dialogContext).pop(),
                              child: Text(
                                'Cancel',
                                style: TextStyle(
                                  color: isDark ? const Color(0xFF8BA3C0) : Colors.grey.shade600,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            ElevatedButton(
                              onPressed: () async {
                                Navigator.of(dialogContext).pop();
                                final prefs = await SharedPreferences.getInstance();
                                await prefs.clear();
                                if (context.mounted) {
                                  await context.read<AuthService>().logout();
                                  if (context.mounted) {
                                    context.go(AppRoutes.signUpLoginScreen);
                                  }
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFFF4757),
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              child: const Text('Log Out', style: TextStyle(fontWeight: FontWeight.w600)),
                            ),
                          ],
                        );
                      },
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    foregroundColor: const Color(0xFFFF4757),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                      side: const BorderSide(color: Color(0xFFFF4757), width: 1.5),
                    ),
                  ),
                  icon: const Icon(Icons.logout, size: 20),
                  label: const Text(
                    'Log Out',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 120),
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionsRow extends StatelessWidget {
  final List<String> sections;
  final bool isDark;

  const _SectionsRow({required this.sections, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: const Color(0x1100FF88),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0x3300FF88)),
          ),
          child: const Center(
            child: CustomIconWidget(
              iconName: 'group_outlined',
              color: Color(0xFF00FF88),
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
                'Sections Teaching',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: isDark
                      ? const Color(0xFF8BA3C0)
                      : Colors.grey.shade600,
                ),
              ),
              const SizedBox(height: 4),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: sections
                    .map(
                      (section) => Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0x2200FF88),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: const Color(0x5500FF88)),
                        ),
                        child: Text(
                          section,
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: isDark ? const Color(0xFF00FF88) : const Color(0xFF00A050),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    )
                    .toList(),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String icon;
  final String label;
  final String value;
  final bool isDark;
  final Color? valueColor;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.isDark,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: const Color(0x1100FF88),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0x3300FF88)),
          ),
          child: Center(
            child: CustomIconWidget(
              iconName: icon,
              color: const Color(0xFF00FF88),
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
                label,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: isDark
                      ? const Color(0xFF8BA3C0)
                      : Colors.grey.shade600,
                ),
              ),
              Text(
                value,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: valueColor,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }
}