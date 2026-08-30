import 'package:url_launcher/url_launcher.dart';
import 'package:go_router/go_router.dart';
import '../../../core/app_export.dart';
import '../../../models/course_model.dart';

class ModulesSectionWidget extends StatelessWidget {
  final Course course;

  const ModulesSectionWidget({required this.course, super.key});

  @override
  Widget build(BuildContext context) {
    final modules = course.modules;
    if (modules.isEmpty) {
      return Center(
        child: Padding(
          padding: EdgeInsets.all(40),
          child: Text(
            'No modules uploaded yet.',
            style: TextStyle(color: Theme.of(context).brightness == Brightness.dark ? const Color(0xFF8BA3C0) : Colors.grey.shade600, fontSize: 14),
          ),
        ),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
      itemCount: modules.length,
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: _ModuleCard(
            module: modules[index],
            accentColor: course.accentColor,
            index: index,
          ),
        );
      },
    );
  }
}

class _ModuleCard extends StatefulWidget {
  final CourseModule module;
  final Color accentColor;
  final int index;

  const _ModuleCard({
    required this.module,
    required this.accentColor,
    required this.index,
  });

  @override
  State<_ModuleCard> createState() => _ModuleCardState();
}

class _ModuleCardState extends State<_ModuleCard> {
  bool _expanded = false;

  String get _fileTypeIcon {
    switch (widget.module.fileType) {
      case 'pdf':
        return 'picture_as_pdf';
      case 'video':
        return 'play_circle_outline';
      case 'ppt':
        return 'slideshow';
      case 'doc':
        return 'description';
      default:
        return 'insert_drive_file';
    }
  }

  Color get _fileTypeColor {
    switch (widget.module.fileType) {
      case 'pdf':
        return const Color(0xFFFF4757);
      case 'video':
        return const Color(0xFF7C5CBF);
      case 'ppt':
        return const Color(0xFFFFB800);
      case 'doc':
        return const Color(0xFF00D4FF);
      default:
        return const Color(0xFF8BA3C0);
    }
  }

  String get _fileTypeLabel {
    switch (widget.module.fileType) {
      case 'pdf':
        return 'PDF';
      case 'video':
        return 'VIDEO';
      case 'ppt':
        return 'SLIDES';
      case 'doc':
        return 'DOC';
      default:
        return 'FILE';
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _fileTypeColor;
    return GestureDetector(
      onTap: () => setState(() => _expanded = !_expanded),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOutCubic,
        decoration: BoxDecoration(
          color: Theme.of(context).brightness == Brightness.dark ? const Color(0xFF142240) : Colors.white,
          borderRadius: BorderRadius.circular(18.0),
          border: Border.all(
            color: _expanded ? color.withAlpha(80) : (Theme.of(context).brightness == Brightness.dark ? const Color(0xFF1E3A5F) : Colors.grey.shade300),
            width: 1,
          ),
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                // File type icon
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: color.withAlpha(25),
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                  child: Center(
                    child: CustomIconWidget(
                      iconName: _fileTypeIcon,
                      color: color,
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
                        widget.module.title,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black87,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: color.withAlpha(20),
                              borderRadius: BorderRadius.circular(4.0),
                            ),
                            child: Text(
                              _fileTypeLabel,
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                color: color,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            widget.module.friendlySize,
                            style: TextStyle(
                              fontSize: 11,
                              color: Theme.of(context).brightness == Brightness.dark ? const Color(0xFF5A7A9A) : Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                CustomIconWidget(
                  iconName: _expanded ? 'expand_less' : 'expand_more',
                  color: Theme.of(context).brightness == Brightness.dark ? const Color(0xFF8BA3C0) : Colors.grey.shade600,
                  size: 20,
                ),
              ],
            ),
            // Expanded details
            if (_expanded) ...[
              const SizedBox(height: 12),
              Container(height: 1, color: Theme.of(context).brightness == Brightness.dark ? const Color(0xFF1E3A5F) : Colors.grey.shade200),
              const SizedBox(height: 12),
              Text(
                widget.module.description,
                style: TextStyle(
                  fontSize: 13,
                  color: Theme.of(context).brightness == Brightness.dark ? const Color(0xFF8BA3C0) : Colors.grey.shade700,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  CustomIconWidget(
                    iconName: 'person_outline',
                    color: Theme.of(context).brightness == Brightness.dark ? const Color(0xFF5A7A9A) : Colors.grey.shade500,
                    size: 13,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    widget.module.uploadedByName,
                    style: TextStyle(
                      fontSize: 12,
                      color: Theme.of(context).brightness == Brightness.dark ? const Color(0xFF5A7A9A) : Colors.grey.shade500,
                    ),
                  ),
                  const SizedBox(width: 14),
                  CustomIconWidget(
                    iconName: 'calendar_today',
                    color: Theme.of(context).brightness == Brightness.dark ? const Color(0xFF5A7A9A) : Colors.grey.shade500,
                    size: 13,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    widget.module.uploadedDateLabel,
                    style: TextStyle(
                      fontSize: 12,
                      color: Theme.of(context).brightness == Brightness.dark ? const Color(0xFF5A7A9A) : Colors.grey.shade500,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () async {
                    if (widget.module.url.isNotEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'Opening "${widget.module.title}"…',
                            style: TextStyle(color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black87),
                          ),
                          backgroundColor: Theme.of(context).brightness == Brightness.dark ? const Color(0xFF142240) : Colors.white,
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.0),
                          ),
                          duration: const Duration(seconds: 2),
                        ),
                      );
                      
                      final type = widget.module.fileType;
                      final url = widget.module.url;
                      final title = widget.module.title;
                      
                      if (type == 'pdf') {
                        context.push('/pdf-viewer?url=${Uri.encodeComponent(url)}&title=${Uri.encodeComponent(title)}');
                      } else if (type == 'video' || url.toLowerCase().endsWith('.mp4') || url.toLowerCase().endsWith('.mov')) {
                        context.push('/video-viewer?url=${Uri.encodeComponent(url)}&title=${Uri.encodeComponent(title)}');
                      } else if (url.toLowerCase().endsWith('.jpg') || url.toLowerCase().endsWith('.png') || url.toLowerCase().endsWith('.jpeg')) {
                        context.push('/image-viewer?url=${Uri.encodeComponent(url)}&title=${Uri.encodeComponent(title)}');
                      } else {
                        final uri = Uri.parse(url);
                        if (await canLaunchUrl(uri)) {
                          await launchUrl(uri, mode: LaunchMode.inAppWebView);
                        } else {
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Could not open the file link.')),
                            );
                          }
                        }
                      }
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('This file is unavailable or not uploaded properly.'),
                        ),
                      );
                    }
                  },
                  icon: CustomIconWidget(
                    iconName: widget.module.fileType == 'video'
                        ? 'play_arrow'
                        : 'open_in_new',
                    color: Theme.of(context).brightness == Brightness.dark ? const Color(0xFF0A1628) : Colors.white,
                    size: 16,
                  ),
                  label: Text(
                    widget.module.fileType == 'video'
                        ? 'Watch Video'
                        : 'Open File',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: color,
                    foregroundColor: Theme.of(context).brightness == Brightness.dark ? const Color(0xFF0A1628) : Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    elevation: 0,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
