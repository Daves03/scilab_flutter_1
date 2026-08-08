import 'dart:typed_data';
import 'package:file_selector/file_selector.dart';
import '../../../core/app_export.dart';
import '../../../models/course_model.dart';
import '../../../services/course_service.dart';
import '../../../services/auth_service.dart';
import '../../../services/ai_quiz_generator_service.dart';
import 'package:provider/provider.dart';
import '../teacher_courses_screen.dart';

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
    showDialog(
      context: context,
      builder: (ctx) => _ConfirmDeleteDialog(
        title: 'Remove Module',
        message: 'Remove "${module.title}" from this course?',
        onConfirm: () {
          setState(() {
            widget.course.modules.removeWhere((m) => m.id == module.id);
          });
          widget.onUpdated();
      context.read<CourseService>().updateCourse(widget.course);
        },
      ),
    );
  }

  void _showModuleDialog(CourseModule? existing) {
    final titleCtrl = TextEditingController(text: existing?.title ?? '');
    final descCtrl = TextEditingController(text: existing?.description ?? '');
    String selectedType = existing?.fileType ?? 'pdf';
    bool autoGenerateQuiz = false;
    int numQuizzes = 1;
    int numQuestions = 5;
    XFile? selectedFile;
    bool isGenerating = false;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx2, setDialogState) => _GlassDialog(
          title: existing == null ? 'Attach Module / File' : 'Edit Module',
          accentColor: widget.course.accentColor,
          scrollable: true,
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _GlassTextField(
                controller: titleCtrl,
                label: 'Module Title',
                hint: 'e.g. Introduction to Organic Compounds',
              ),
              const SizedBox(height: 14),
              _GlassTextField(
                controller: descCtrl,
                label: 'Description',
                hint: 'Brief description of this module',
                maxLines: 3,
              ),
              const SizedBox(height: 14),
              const SizedBox(height: 12),
              GestureDetector(
                onTap: () async {
                  final typeGroup = XTypeGroup(
                    label: 'Documents',
                    extensions: ['pdf', 'doc', 'docx', 'ppt', 'pptx'],
                  );
                  final XFile? result = await openFile(acceptedTypeGroups: [typeGroup]);

                  if (result != null) {
                    setDialogState(() {
                      selectedFile = result;
                      // Auto-select type based on extension
                      final lowerName = selectedFile!.name.toLowerCase();
                      if (lowerName.endsWith('pdf')) selectedType = 'pdf';
                      else if (lowerName.endsWith('doc') || lowerName.endsWith('docx')) selectedType = 'doc';
                      else if (lowerName.endsWith('ppt') || lowerName.endsWith('pptx')) selectedType = 'ppt';
                    });
                  }
                },
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF142240),
                    borderRadius: BorderRadius.circular(12.0),
                    border: Border.all(
                      color: widget.course.accentColor.withAlpha(50),
                      width: 1,
                      style: BorderStyle.solid,
                    ),
                  ),
                  child: Column(
                    children: [
                      CustomIconWidget(
                        iconName: selectedFile != null ? 'description' : 'cloud_upload',
                        color: widget.course.accentColor,
                        size: 28,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        selectedFile != null ? selectedFile!.name : 'Tap to attach file',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: widget.course.accentColor,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      if (selectedFile == null) ...[
                        const SizedBox(height: 2),
                        const Text(
                          'PDF, DOC, PPT supported',
                          style: TextStyle(fontSize: 11, color: Color(0xFF8BA3C0)),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              if (selectedType == 'pdf' && existing == null) ...[
                const SizedBox(height: 14),
                GestureDetector(
                  onTap: () {
                    setDialogState(() => autoGenerateQuiz = !autoGenerateQuiz);
                  },
                  child: Row(
                    children: [
                      Icon(
                        autoGenerateQuiz ? Icons.check_box : Icons.check_box_outline_blank,
                        color: autoGenerateQuiz ? const Color(0xFF00D4FF) : Colors.grey,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Auto-generate AI Quiz',
                              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.white),
                            ),
                            Text(
                              'Uses AI to read the PDF and create quizzes.',
                              style: TextStyle(fontSize: 11, color: Colors.grey),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                if (autoGenerateQuiz) ...[
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Quizzes: $numQuizzes', style: const TextStyle(fontSize: 12, color: Colors.white)),
                            Slider(
                              value: numQuizzes.toDouble(),
                              min: 1,
                              max: 5,
                              divisions: 4,
                              activeColor: const Color(0xFF00D4FF),
                              onChanged: (val) => setDialogState(() => numQuizzes = val.toInt()),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Questions/Quiz: $numQuestions', style: const TextStyle(fontSize: 12, color: Colors.white)),
                            Slider(
                              value: numQuestions.toDouble(),
                              min: 1,
                              max: 20,
                              divisions: 19,
                              activeColor: const Color(0xFF00D4FF),
                              onChanged: (val) => setDialogState(() => numQuestions = val.toInt()),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ],
              if (isGenerating) ...[
                const SizedBox(height: 16),
                const Center(
                  child: Column(
                    children: [
                      CircularProgressIndicator(color: Color(0xFF00D4FF)),
                      SizedBox(height: 8),
                      Text('AI is reading document...', style: TextStyle(color: Colors.white, fontSize: 12)),
                    ],
                  ),
                ),
              ],
            ],
          ),
          onSave: () async {
            if (titleCtrl.text.trim().isEmpty) return;
            if (isGenerating) return;

            final now = DateTime.now();
            final dateStr = '${_monthName(now.month)} ${now.day}, ${now.year}';
            
            if (autoGenerateQuiz && selectedFile != null) {
              setDialogState(() => isGenerating = true);
              
              final bytes = await selectedFile!.readAsBytes();
              final aiService = AiQuizGeneratorService();
              final generatedQuizzes = await aiService.generateQuizzesFromPdf(
                bytes, 
                titleCtrl.text.trim(),
                numQuizzes: numQuizzes,
                numQuestions: numQuestions,
              );
              
              if (generatedQuizzes != null && generatedQuizzes.isNotEmpty) {
                widget.course.quizzes.addAll(generatedQuizzes);
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('\${generatedQuizzes.length} AI Quiz(zes) generated successfully!')),
                  );
                }
              } else {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('AI Quiz generation failed.')),
                  );
                }
              }
            }

            setState(() {
              if (existing == null) {
                widget.course.modules.add(
                  CourseModule(
                    id: 'tm_${now.millisecondsSinceEpoch}',
                    title: titleCtrl.text.trim(),
                    description: descCtrl.text.trim(),
                    fileType: selectedType,
                    uploadedByName: context.read<AuthService>().currentUser?.name ?? 'Teacher',
                    uploadedAt: now,
                    fileSizeBytes: 0, // Fallback since XFile doesn't have size directly
                    url: '',
                    storagePath: '',
                  ),
                );
              } else {
                final idx = widget.course.modules.indexWhere((m) => m.id == existing.id);
                if (idx != -1) {
                  widget.course.modules[idx] = CourseModule(
                    id: existing.id,
                    title: titleCtrl.text.trim(),
                    description: descCtrl.text.trim(),
                    fileType: selectedType,
                    uploadedByName: existing.uploadedByName,
                    uploadedAt: existing.uploadedAt,
                    fileSizeBytes: existing.fileSizeBytes,
                    url: existing.url,
                    storagePath: existing.storagePath,
                  );
                }
              }
            });
            widget.onUpdated();
            context.read<CourseService>().updateCourse(widget.course);
            if (mounted) {
              Navigator.pop(ctx2);
            }
          },
          onCancel: () => Navigator.pop(ctx2),
        ),
      ),
    );
  }

  String _monthName(int month) {
    const months = [
      '',
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return months[month];
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
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
          child: SizedBox(
            width: double.infinity,
            child: _AddButton(
              label: 'Attach Module / File',
              icon: 'cloud_upload',
              color: widget.course.accentColor,
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
                  color: widget.course.accentColor,
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
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _ModuleCard({
    required this.module,
    required this.typeColor,
    required this.typeIcon,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF142240),
        borderRadius: BorderRadius.circular(16.0),
        border: Border.all(color: typeColor.withAlpha(40), width: 1),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: typeColor.withAlpha(20),
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
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  module.description,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF8BA3C0),
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    _MetaTag(
                      icon: 'calendar_today',
                      label: module.uploadedDateLabel,
                      color: const Color(0xFF8BA3C0),
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
                icon: 'edit',
                color: const Color(0xFFFFB800),
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
  final bool scrollable;

  const _GlassDialog({
    required this.title,
    required this.accentColor,
    required this.content,
    required this.onSave,
    required this.onCancel,
    this.scrollable = false,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 480),
        decoration: BoxDecoration(
          color: const Color(0xFF0F1E35),
          borderRadius: BorderRadius.circular(20.0),
          border: Border.all(color: accentColor.withAlpha(60), width: 1),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.fromLTRB(20, 16, 12, 16),
              decoration: BoxDecoration(
                color: accentColor.withAlpha(15),
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(20),
                ),
                border: Border(
                  bottom: BorderSide(
                    color: accentColor.withAlpha(40),
                    width: 1,
                  ),
                ),
              ),
              child: Row(
                children: [
                  CustomIconWidget(
                    iconName: 'cloud_upload',
                    color: accentColor,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
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
            scrollable
                ? Flexible(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(20),
                      child: content,
                    ),
                  )
                : Padding(padding: const EdgeInsets.all(20), child: content),
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
                        backgroundColor: accentColor,
                        foregroundColor: const Color(0xFF0A1628),
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

class _GlassTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String hint;
  final int maxLines;

  const _GlassTextField({
    required this.controller,
    required this.label,
    required this.hint,
    this.maxLines = 1,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Color(0xFF8BA3C0),
          ),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          maxLines: maxLines,
          style: const TextStyle(fontSize: 13, color: Colors.white),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(fontSize: 12, color: Color(0xFF4A6A8A)),
            filled: true,
            fillColor: const Color(0xFF142240),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 12,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10.0),
              borderSide: const BorderSide(color: Color(0xFF1E3A5F), width: 1),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10.0),
              borderSide: const BorderSide(color: Color(0xFF1E3A5F), width: 1),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10.0),
              borderSide: const BorderSide(
                color: Color(0xFF00D4FF),
                width: 1.5,
              ),
            ),
          ),
        ),
      ],
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
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 360),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: const Color(0xFF0F1E35),
          borderRadius: BorderRadius.circular(20.0),
          border: Border.all(color: const Color(0x44FF4757), width: 1),
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
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              style: const TextStyle(fontSize: 13, color: Color(0xFF8BA3C0)),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
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
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 30,
        height: 30,
        decoration: BoxDecoration(
          color: color.withAlpha(20),
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
