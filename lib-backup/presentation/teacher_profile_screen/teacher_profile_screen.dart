import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:universal_html/html.dart' as html;

import '../../core/app_export.dart';
import '../../core/theme_provider.dart';
import '../../services/auth_service.dart';

import '../../core/gallery_saver_web.dart' if (dart.library.io) '../../core/gallery_saver_mobile.dart';

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
      _teacherName = prefs.getString('teacher_name') ?? 'Teacher';
      _email = prefs.getString('teacher_email') ?? '';
      _teacherSections = prefs.getStringList('teacher_sections') ?? [];
    });
  }

  Future<void> _downloadMarker() async {
    if (_isDownloading) { return; }
    setState(() => _isDownloading = true);

    try {
      final byteData = await rootBundle.load(_markerAssetPath);
      final bytes = byteData.buffer.asUint8List();

      if (kIsWeb) {
        final blob = html.Blob([bytes], 'image/png');
        final url = html.Url.createObjectUrlFromBlob(blob);
        html.AnchorElement(href: url)
          ..setAttribute('download', 'scilab_ar_marker.png')
          ..click();
        html.Url.revokeObjectUrl(url);
        Fluttertoast.showToast(
          msg: 'AR Marker download started!',
          backgroundColor: const Color(0xFF00D4FF),
          textColor: const Color(0xFF0A1628),
        );
      } else {
        await saveImageBytesToGallery(bytes, 'scilab_ar_marker');
        Fluttertoast.showToast(
          msg: 'AR Marker saved to gallery!',
          backgroundColor: const Color(0xFF00FF88),
          textColor: const Color(0xFF0A1628),
        );
      }
    } catch (e) {
      Fluttertoast.showToast(
        msg: 'Download failed. Please try again.',
        backgroundColor: const Color(0xFFFF4757),
        textColor: Colors.white,
      );
    } finally {
      if (mounted) { setState(() => _isDownloading = false); }
    }
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
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'My Profile',
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const _ThemeToggleButton(),
                ],
              ),
              const SizedBox(height: 28),

              // Profile card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF142240) : Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isDark
                        ? const Color(0xFF1E3A5F)
                        : Colors.grey.shade200,
                  ),
                  boxShadow: isDark
                      ? []
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
                      width: 90,
                      height: 90,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: const Color(0xFF00D4FF),
                          width: 2.5,
                        ),
                      ),
                      child: ClipOval(
                        child: Image.network(
                          _avatarUrl,
                          fit: BoxFit.cover,
                          semanticLabel:
                              'Teacher profile photo of a woman in professional attire',
                          errorBuilder: (_, __, ___) => Container(
                            color: const Color(0xFF0D2E3F),
                            child: const Icon(
                              Icons.person,
                              size: 44,
                              color: Color(0xFF00D4FF),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    Text(
                      _teacherName,
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0x2200D4FF),
                        borderRadius: BorderRadius.circular(50),
                        border: Border.all(color: const Color(0x5500D4FF)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const CustomIconWidget(
                            iconName: 'person_pin_outlined',
                            color: Color(0xFF00D4FF),
                            size: 14,
                          ),
                          const SizedBox(width: 5),
                          Text(
                            'Teacher',
                            style: theme.textTheme.labelMedium?.copyWith(
                              color: const Color(0xFF00D4FF),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    Divider(
                      color: isDark
                          ? const Color(0xFF1E3A5F)
                          : Colors.grey.shade200,
                    ),
                    const SizedBox(height: 16),
                    _InfoRow(
                      icon: 'email_outlined',
                      label: 'Email',
                      value: _email,
                      isDark: isDark,
                    ),
                    if (_teacherSections.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      _SectionsRow(sections: _teacherSections, isDark: isDark),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // AR Marker download section
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: isDark
                      ? const Color(0xFF0D2E3F)
                      : const Color(0xFFE8F9FD),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isDark
                        ? const Color(0x3300D4FF)
                        : const Color(0xFF00D4FF).withAlpha(80),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: const Color(0x2200D4FF),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const CustomIconWidget(
                            iconName: 'view_in_ar',
                            color: Color(0xFF00D4FF),
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 12),
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
                              Text(
                                'Download and print for AR experiments',
                                style: theme.textTheme.bodySmall,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.asset(
                        _markerAssetPath,
                        height: 160,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        semanticLabel:
                            'Scilab AR marker image with geometric pattern for augmented reality experiments',
                        errorBuilder: (_, __, ___) => Container(
                          height: 160,
                          color: const Color(0xFF0D2E3F),
                          child: const Center(
                            child: CustomIconWidget(
                              iconName: 'view_in_ar',
                              color: Color(0xFF00D4FF),
                              size: 48,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton.icon(
                        onPressed: _isDownloading ? null : _downloadMarker,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF00D4FF),
                          foregroundColor: const Color(0xFF0A1628),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          disabledBackgroundColor: const Color(
                            0xFF00D4FF,
                          ).withAlpha(100),
                        ),
                        icon: _isDownloading
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Color(0xFF0A1628),
                                ),
                              )
                            : const CustomIconWidget(
                                iconName: 'download',
                                color: Color(0xFF0A1628),
                                size: 20,
                              ),
                        label: Text(
                          _isDownloading
                              ? 'Saving to Gallery...'
                              : 'Download AR Marker',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Logout Button
              SizedBox(
                width: double.infinity,
                height: 54,
                child: OutlinedButton.icon(
                  onPressed: () => _showLogoutDialog(context),
                  icon: const CustomIconWidget(
                    iconName: 'logout',
                    color: Color(0xFFFF4757),
                    size: 18,
                  ),
                  label: const Text(
                    'Logout',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFFFF4757),
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Color(0x33FF4757), width: 1.5),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    backgroundColor: const Color(0x0AFF4757),
                  ),
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF142240),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'Logout',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        content: const Text(
          'Are you sure you want to log out of ScilabAR?',
          style: TextStyle(color: Color(0xFF8BA3C0)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel', style: TextStyle(color: Color(0xFF8BA3C0))),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              AuthService.instance.logout();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFF4757),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('Logout', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}

class _ThemeToggleButton extends StatelessWidget {
  const _ThemeToggleButton();

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ThemeProvider>(context);
    final isDark = provider.isDark;
    return GestureDetector(
      onTap: () => provider.toggleTheme(),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        width: 64,
        height: 34,
        padding: const EdgeInsets.all(3),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1A2D4A) : const Color(0xFFE0E8F0),
          borderRadius: BorderRadius.circular(50),
          border: Border.all(
            color: isDark
                ? const Color(0xFF00D4FF).withAlpha(80)
                : Colors.grey.shade300,
          ),
        ),
        child: Stack(
          children: [
            AnimatedAlign(
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeOutCubic,
              alignment: isDark ? Alignment.centerRight : Alignment.centerLeft,
              child: Container(
                width: 26,
                height: 26,
                decoration: BoxDecoration(
                  color: isDark
                      ? const Color(0xFF00D4FF)
                      : const Color(0xFF0A1628),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Icon(
                    isDark ? Icons.dark_mode : Icons.light_mode,
                    size: 14,
                    color: isDark ? const Color(0xFF0A1628) : Colors.white,
                  ),
                ),
              ),
            ),
          ],
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
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF0D2E3F) : const Color(0xFFE8F9FD),
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Center(
            child: CustomIconWidget(
              iconName: 'group_outlined',
              color: Color(0xFF00D4FF),
              size: 18,
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
                          color: const Color(0x2200D4FF),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: const Color(0x5500D4FF)),
                        ),
                        child: Text(
                          section,
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: const Color(0xFF00D4FF),
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
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF0D2E3F) : const Color(0xFFE8F9FD),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Center(
            child: CustomIconWidget(
              iconName: icon,
              color: const Color(0xFF00D4FF),
              size: 18,
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

