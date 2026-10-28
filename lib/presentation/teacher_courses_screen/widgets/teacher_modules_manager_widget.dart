import 'package:file_selector/file_selector.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/app_export.dart';
import '../../../models/course_model.dart';
import '../../../services/course_service.dart';
import '../../../services/auth_service.dart';
import 'package:provider/provider.dart';

class CourseModulesManagerWidget extends StatefulWidget {
  final Course course;
  final VoidCallback onUpdated;

  const CourseModulesManagerWidget({
    required this.course,
    required this.onUpdated,
    super.key,
  });

  @override
  State<CourseModulesManagerWidget> createState() =>
      _CourseModulesManagerWidgetState();
}

class _CourseModulesManagerWidgetState
    extends State<CourseModulesManagerWidget> {
  void _addModule() {
    _showModuleDialog(null);
  }

  void _editModule(CourseModule module) {
    _showModuleDialog(module);
  }

  void _deleteModule(CourseModule module) {
    final courseService = context.read<CourseService>();
    showDialog(
      context: context,
      builder: (ctx) => _ConfirmDeleteDialog(
        title: 'Remove Module',
        message: 'Remove "${module.title}" from this course?',
        onConfirm: () async {
          try {
            await courseService.removeModule(widget.course.id, module.id);
            if (!mounted) return;

            setState(() {
              widget.course.modules.removeWhere((m) => m.id == module.id);
            });
            widget.onUpdated();
          } catch (_) {
            if (!mounted) return;
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text(
                  'Could not remove the module. Please check your connection and try again.',
                ),
              ),
            );
          }
        },
      ),
    );
  }

  void _showModuleDialog(CourseModule? existing) {
    XFile? selectedFile;
    bool isUploading = false;

    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        final isLight = Theme.of(dialogContext).brightness == Brightness.light;
        final accentColor =
            (isLight && widget.course.accentColor == const Color(0xFF00D4FF))
            ? const Color(0xFF1565C0)
            : widget.course.accentColor;

        return StatefulBuilder(
          builder: (context, setDialogState) => _GlassDialog(
            title: existing == null ? 'Upload Module' : 'Replace Module File',
            accentColor: widget.course.accentColor,
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                GestureDetector(
                  onTap: isUploading
                      ? null
                      : () async {
                          final result = await openFile(
                            acceptedTypeGroups: [
                              XTypeGroup(
                                label: 'Module files',
                                extensions: const [
                                  'pdf',
                                  'doc',
                                  'docx',
                                  'ppt',
                                  'pptx',
                                  'mp4',
                                  'mov',
                                  'jpg',
                                  'jpeg',
                                  'png',
                                ],
                              ),
                            ],
                          );
                          if (result != null && context.mounted) {
                            setDialogState(() => selectedFile = result);
                          }
                        },
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: isLight
                          ? Colors.grey.shade50
                          : const Color(0xFF142240),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: accentColor.withAlpha(70)),
                    ),
                    child: Column(
                      children: [
                        Icon(
                          selectedFile == null
                              ? Icons.cloud_upload_outlined
                              : Icons.description_outlined,
                          color: accentColor,
                          size: 30,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          selectedFile?.name ??
                              (existing == null
                                  ? 'Tap to select a module file'
                                  : 'Tap to select a replacement file'),
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: accentColor,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'The file name will be used as the module name.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: isLight
                                ? Colors.grey.shade600
                                : const Color(0xFF8BA3C0),
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                if (isUploading) ...[
                  const SizedBox(height: 16),
                  const CircularProgressIndicator(),
                  const SizedBox(height: 8),
                  const Text('Uploading module...'),
                ],
              ],
            ),
            onSave: () async {
              if (selectedFile == null) {
                ScaffoldMessenger.of(this.context).showSnackBar(
                  const SnackBar(content: Text('Please select a module file.')),
                );
                return;
              }
              if (isUploading) return;

              final courseService = this.context.read<CourseService>();
              final uploader = this.context.read<AuthService>().currentUser;
              final messenger = ScaffoldMessenger.of(this.context);
              setDialogState(() => isUploading = true);
              final file = selectedFile!;
              try {
                final bytes = await file.readAsBytes();
                final safeName = file.name.replaceAll(RegExp(r'\s+'), '_');
                final now = DateTime.now();
                final storagePath =
                    'course_modules/${widget.course.id}/${now.millisecondsSinceEpoch}_$safeName';
                final snapshot = await FirebaseStorage.instance
                    .ref(storagePath)
                    .putData(bytes);
                final downloadUrl = await snapshot.ref.getDownloadURL();
                final extension = file.name.contains('.')
                    ? file.name.split('.').last.toLowerCase()
                    : 'other';
                final fileType = switch (extension) {
                  'doc' || 'docx' => 'doc',
                  'ppt' || 'pptx' => 'ppt',
                  'mp4' || 'mov' => 'video',
                  'jpg' || 'jpeg' || 'png' => 'image',
                  'pdf' => 'pdf',
                  _ => 'other',
                };
                final module = CourseModule(
                  id: existing?.id ?? 'tm_${now.millisecondsSinceEpoch}',
                  title: file.name,
                  description: '',
                  fileType: fileType,
                  uploadedByUid: existing?.uploadedByUid.isNotEmpty == true
                      ? existing!.uploadedByUid
                      : (uploader?.id ?? widget.course.teacherUid),
                  uploadedByName:
                      existing?.uploadedByName ?? uploader?.name ?? 'Teacher',
                  uploadedAt: existing?.uploadedAt ?? now,
                  fileSizeBytes: bytes.length,
                  url: downloadUrl,
                  storagePath: storagePath,
                );

                if (existing == null) {
                  widget.course.modules.add(module);
                } else {
                  final index = widget.course.modules.indexWhere(
                    (item) => item.id == existing.id,
                  );
                  if (index != -1) widget.course.modules[index] = module;
                }
                await courseService.updateCourse(widget.course);
                if (!mounted) return;
                setState(() {});
                widget.onUpdated();
                if (context.mounted) Navigator.pop(context);
              } catch (error) {
                if (!mounted) return;
                messenger.showSnackBar(
                  SnackBar(
                    content: Text('Could not upload the module: $error'),
                  ),
                );
                if (context.mounted) {
                  setDialogState(() => isUploading = false);
                }
              }
            },
            onCancel: () => Navigator.pop(context),
          ),
        );
      },
    );
  }

  Map<String, dynamic> _fileTypeInfo(String type) {
    switch (type) {
      case 'pdf':
        return {'icon': 'picture_as_pdf', 'color': const Color(0xFFFF4757)};
      case 'video':
        return {
          'icon': 'play_circle_outline',
          'color': const Color(0xFF00D4FF),
        };
      case 'ppt':
        return {'icon': 'slideshow', 'color': const Color(0xFFFFB800)};
      case 'doc':
        return {'icon': 'description', 'color': const Color(0xFF7C5CBF)};
      default:
        return {'icon': 'insert_drive_file', 'color': const Color(0xFF8BA3C0)};
    }
  }

  @override
  Widget build(BuildContext context) {
    final modules = widget.course.modules;
    final isLight = Theme.of(context).brightness == Brightness.light;
    final accentColor =
        (isLight && widget.course.accentColor == const Color(0xFF00D4FF))
        ? const Color(0xFF1565C0)
        : widget.course.accentColor;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
          child: SizedBox(
            width: double.infinity,
            child: _AddButton(
              label: 'Attach Module / File',
              icon: 'cloud_upload',
              color: accentColor,
              onTap: _addModule,
            ),
          ),
        ),
        Expanded(
          child: modules.isEmpty
              ? _EmptyState(
                  icon: 'folder_open',
                  message:
                      'No modules yet.\nTap "Attach Module / File" to upload.',
                  color: accentColor,
                )
              : ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
                  itemCount: modules.length,
                  itemBuilder: (context, index) {
                    final module = modules[index];
                    final info = _fileTypeInfo(module.fileType);
                    return _ModuleCard(
                      module: module,
                      typeColor: info['color'],
                      typeIcon: info['icon'],
                      onPreview: () async {
                        final type = module.fileType;
                        final url = module.url;
                        final title = module.title;

                        if (url.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'This file is unavailable or not uploaded properly.',
                              ),
                            ),
                          );
                          return;
                        }

                        if (type == 'pdf') {
                          context.push(
                            '/pdf-viewer?url=${Uri.encodeComponent(url)}&title=${Uri.encodeComponent(title)}',
                          );
                        } else if (type == 'video' ||
                            url.toLowerCase().endsWith('.mp4') ||
                            url.toLowerCase().endsWith('.mov')) {
                          context.push(
                            '/video-viewer?url=${Uri.encodeComponent(url)}&title=${Uri.encodeComponent(title)}',
                          );
                        } else if (url.toLowerCase().endsWith('.jpg') ||
                            url.toLowerCase().endsWith('.png') ||
                            url.toLowerCase().endsWith('.jpeg')) {
                          context.push(
                            '/image-viewer?url=${Uri.encodeComponent(url)}&title=${Uri.encodeComponent(title)}',
                          );
                        } else {
                          final uri = Uri.parse(url);
                          if (await canLaunchUrl(uri)) {
                            await launchUrl(uri, mode: LaunchMode.inAppWebView);
                          } else {
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'Could not open the file link.',
                                  ),
                                ),
                              );
                            }
                          }
                        }
                      },
                      onEdit: () => _editModule(module),
                      onDelete: () => _deleteModule(module),
                    );
                  },
                ),
        ),
      ],
    );
  }
}

// ── Module card ───────────────────────────────────────────────────────────────

class _ModuleCard extends StatelessWidget {
  final CourseModule module;
  final Color typeColor;
  final String typeIcon;
  final VoidCallback onPreview;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _ModuleCard({
    required this.module,
    required this.typeColor,
    required this.typeIcon,
    required this.onPreview,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final isLight = Theme.of(context).brightness == Brightness.light;
    final cardBg = isLight ? Colors.white : const Color(0xFF142240);
    final titleColor = isLight ? const Color(0xFF1E253F) : Colors.white;
    final subtitleColor = isLight
        ? const Color(0xFF6C7B90)
        : const Color(0xFF8BA3C0);
    final iconBg = isLight ? typeColor.withAlpha(30) : typeColor.withAlpha(20);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(16.0),
        border: Border.all(
          color: typeColor.withAlpha(isLight ? 60 : 40),
          width: 1,
        ),
        boxShadow: isLight
            ? [
                BoxShadow(
                  color: Colors.black.withAlpha(8),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ]
            : null,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: iconBg,
              borderRadius: BorderRadius.circular(12.0),
            ),
            child: Center(
              child: CustomIconWidget(
                iconName: typeIcon,
                color: typeColor,
                size: 22,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  module.title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: titleColor,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  module.description,
                  style: TextStyle(fontSize: 12, color: subtitleColor),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    _MetaTag(
                      icon: 'calendar_today',
                      label: module.uploadedDateLabel,
                      color: subtitleColor,
                    ),
                    const SizedBox(width: 8),
                    _MetaTag(
                      icon: 'storage',
                      label: module.friendlySize,
                      color: typeColor,
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Column(
            children: [
              _ActionIconBtn(
                icon: 'visibility',
                color: isLight
                    ? const Color(0xFF00B4D8)
                    : const Color(0xFF00D4FF),
                onTap: onPreview,
              ),
              const SizedBox(height: 6),
              _ActionIconBtn(
                icon: 'edit',
                color: isLight
                    ? const Color(0xFFE5A500)
                    : const Color(0xFFFFB800),
                onTap: onEdit,
              ),
              const SizedBox(height: 6),
              _ActionIconBtn(
                icon: 'delete_outline',
                color: const Color(0xFFFF4757),
                onTap: onDelete,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MetaTag extends StatelessWidget {
  final String icon;
  final String label;
  final Color color;

  const _MetaTag({
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        CustomIconWidget(iconName: icon, color: color, size: 11),
        const SizedBox(width: 3),
        Text(label, style: TextStyle(fontSize: 11, color: color)),
      ],
    );
  }
}

// ── Shared helpers ────────────────────────────────────────────────────────────

class _AddButton extends StatelessWidget {
  final String label;
  final String icon;
  final Color color;
  final VoidCallback onTap;

  const _AddButton({
    required this.label,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 13),
        decoration: BoxDecoration(
          color: color.withAlpha(20),
          borderRadius: BorderRadius.circular(14.0),
          border: Border.all(color: color.withAlpha(70), width: 1.5),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CustomIconWidget(iconName: icon, color: color, size: 18),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GlassDialog extends StatelessWidget {
  final String title;
  final Color accentColor;
  final Widget content;
  final VoidCallback onSave;
  final VoidCallback onCancel;

  const _GlassDialog({
    required this.title,
    required this.accentColor,
    required this.content,
    required this.onSave,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    final isLight = Theme.of(context).brightness == Brightness.light;
    final mediaQuery = MediaQuery.of(context);
    final maxDialogHeight =
        (mediaQuery.size.height -
                mediaQuery.viewInsets.bottom -
                mediaQuery.padding.vertical -
                32)
            .clamp(240.0, 720.0)
            .toDouble();
    final displayAccentColor =
        (isLight && accentColor == const Color(0xFF00D4FF))
        ? const Color(0xFF1565C0)
        : accentColor;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
      child: Container(
        constraints: BoxConstraints(maxWidth: 480, maxHeight: maxDialogHeight),
        decoration: BoxDecoration(
          color: isLight ? Colors.white : const Color(0xFF0F1E35),
          borderRadius: BorderRadius.circular(20.0),
          border: Border.all(color: displayAccentColor.withAlpha(60), width: 1),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.fromLTRB(20, 16, 12, 16),
              decoration: BoxDecoration(
                color: displayAccentColor.withAlpha(15),
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(20),
                ),
                border: Border(
                  bottom: BorderSide(
                    color: displayAccentColor.withAlpha(40),
                    width: 1,
                  ),
                ),
              ),
              child: Row(
                children: [
                  CustomIconWidget(
                    iconName: 'cloud_upload',
                    color: displayAccentColor,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: isLight ? Colors.black87 : Colors.white,
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: onCancel,
                    child: const CustomIconWidget(
                      iconName: 'close',
                      color: Color(0xFF8BA3C0),
                      size: 20,
                    ),
                  ),
                ],
              ),
            ),
            Padding(padding: const EdgeInsets.all(20), child: content),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: onCancel,
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(
                          color: Color(0xFF3A5A7A),
                          width: 1,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(50),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: const Text(
                        'Cancel',
                        style: TextStyle(
                          color: Color(0xFF8BA3C0),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: onSave,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: displayAccentColor,
                        foregroundColor: isLight
                            ? Colors.white
                            : const Color(0xFF0A1628),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(50),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        elevation: 0,
                      ),
                      child: const Text(
                        'Save',
                        style: TextStyle(fontWeight: FontWeight.w700),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ConfirmDeleteDialog extends StatelessWidget {
  final String title;
  final String message;
  final VoidCallback onConfirm;

  const _ConfirmDeleteDialog({
    required this.title,
    required this.message,
    required this.onConfirm,
  });

  @override
  Widget build(BuildContext context) {
    final isLight = Theme.of(context).brightness == Brightness.light;
    final bgColor = isLight ? Colors.white : const Color(0xFF0F1E35);
    final borderColor = isLight
        ? const Color(0x22FF4757)
        : const Color(0x44FF4757);
    final titleColor = isLight ? const Color(0xFF1E253F) : Colors.white;
    final textColor = isLight
        ? const Color(0xFF6C7B90)
        : const Color(0xFF8BA3C0);
    final btnBorderColor = isLight
        ? Colors.grey.shade300
        : const Color(0xFF3A5A7A);

    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 360),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(20.0),
          border: Border.all(color: borderColor, width: 1),
          boxShadow: isLight
              ? [
                  BoxShadow(
                    color: Colors.black.withAlpha(13),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CustomIconWidget(
              iconName: 'warning_amber',
              color: Color(0xFFFF4757),
              size: 40,
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: titleColor,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              style: TextStyle(fontSize: 13, color: textColor),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: btnBorderColor, width: 1),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(50),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: Text(
                      'Cancel',
                      style: TextStyle(
                        color: textColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      onConfirm();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFF4757),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(50),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      elevation: 0,
                    ),
                    child: const Text(
                      'Delete',
                      style: TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ActionIconBtn extends StatelessWidget {
  final String icon;
  final Color color;
  final VoidCallback onTap;

  const _ActionIconBtn({
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isLight = Theme.of(context).brightness == Brightness.light;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 30,
        height: 30,
        decoration: BoxDecoration(
          color: color.withAlpha(isLight ? 40 : 20),
          borderRadius: BorderRadius.circular(8.0),
        ),
        child: Center(
          child: CustomIconWidget(iconName: icon, color: color, size: 15),
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final String icon;
  final String message;
  final Color color;

  const _EmptyState({
    required this.icon,
    required this.message,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CustomIconWidget(
            iconName: icon,
            color: color.withAlpha(80),
            size: 48,
          ),
          const SizedBox(height: 12),
          Text(
            message,
            style: const TextStyle(fontSize: 13, color: Color(0xFF8BA3C0)),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
