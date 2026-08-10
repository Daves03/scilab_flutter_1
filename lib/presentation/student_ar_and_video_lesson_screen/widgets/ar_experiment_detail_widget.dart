import 'dart:ui';

import '../../../core/app_export.dart';
import '../../../models/ar_experiment_model.dart';
import '../student_ar_and_video_lesson_screen.dart';

class ArExperimentDetailWidget extends StatefulWidget {
  final ArExperimentModel experiment;
  final VoidCallback onClose;
  final VoidCallback onRunAR;
  final bool isInline;
  final bool isLocked;
  final bool isTeacher;
  final ValueChanged<bool>? onToggleLock;

  const ArExperimentDetailWidget({
    required this.experiment,
    required this.onClose,
    required this.onRunAR,
    this.isInline = false,
    this.isLocked = false,
    this.isTeacher = false,
    this.onToggleLock,
    super.key,
  });

  @override
  State<ArExperimentDetailWidget> createState() =>
      _ArExperimentDetailWidgetState();
}

class _ArExperimentDetailWidgetState extends State<ArExperimentDetailWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _slideAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );
    _slideAnimation = Tween<double>(
      begin: 1.0,
      end: 0.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));
    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _close() async {
    await _controller.reverse();
    widget.onClose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.isInline) return _buildContent();

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Stack(
          children: [
            GestureDetector(
              onTap: _close,
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: Container(color: Colors.black.withAlpha(153)),
              ),
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Transform.translate(
                offset: Offset(0, _slideAnimation.value * 600),
                child: _buildContent(),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildContent() {
    final exp = widget.experiment;
    return ClipRRect(
      borderRadius: widget.isInline
          ? BorderRadius.circular(24)
          : const BorderRadius.vertical(top: Radius.circular(32)),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          height: widget.isInline ? null : MediaQuery.of(context).size.height * 0.85,
          color: Theme.of(context).brightness == Brightness.dark ? const Color(0xFF0F1E35).withAlpha(247) : Colors.white.withAlpha(247),
          child: Column(
            children: [
              Padding(
                padding: EdgeInsets.fromLTRB(24, widget.isInline ? 24 : 12, 24, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                if (!widget.isInline) ...[
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      margin: const EdgeInsets.only(bottom: 20),
                      decoration: BoxDecoration(
                        color: Theme.of(context).brightness == Brightness.dark ? const Color(0xFF1E3A5F) : Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(50),
                      ),
                    ),
                  ),
                ],
                // Header
                Row(
                  children: [
                    Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        color: exp.tintColor,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Center(
                        child: CustomIconWidget(
                          iconName: exp.iconName,
                          color: const Color(0xFF00D4FF),
                          size: 26,
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            exp.title,
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w700,
                              color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            exp.topic,
                            style: TextStyle(
                              fontSize: 13,
                              color: Theme.of(context).brightness == Brightness.dark ? const Color(0xFF8BA3C0) : Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ),

                    GestureDetector(
                      onTap: _close,
                      child: Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: Theme.of(context).brightness == Brightness.dark ? const Color(0xFF142240) : Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(50),
                        ),
                        child: Center(
                          child: CustomIconWidget(
                            iconName: 'close',
                            color: Theme.of(context).brightness == Brightness.dark ? const Color(0xFF8BA3C0) : Colors.grey.shade700,
                            size: 18,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                  ],
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(24, 8, 24, 120),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                // Thumbnail
                ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: CustomImageWidget(
                    imageUrl: exp.thumbnailUrl,
                    width: double.infinity,
                    height: 160,
                    fit: BoxFit.cover,
                    semanticLabel: exp.semanticLabel,
                  ),
                ),
                const SizedBox(height: 20),
                // Background Info section
                _buildSectionLabel('Background Info', 'info_outline'),
                const SizedBox(height: 10),
                Text(
                  exp.backgroundInfo,
                  style: TextStyle(
                    fontSize: 14,
                    color: Theme.of(context).brightness == Brightness.dark ? const Color(0xFF8BA3C0) : Colors.grey.shade700,
                    height: 1.6,
                  ),
                ),
                const SizedBox(height: 20),
                // Safety Notes
                _buildSectionLabel('Safety Notes', 'warning_amber_outlined'),
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Theme.of(context).brightness == Brightness.dark ? const Color(0xFF2E2010) : const Color(0xFFFFF8E7),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: const Color(0xFFFFB800).withAlpha(77),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const CustomIconWidget(
                        iconName: 'warning_amber',
                        color: Color(0xFFFFB800),
                        size: 18,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          exp.safetyNote,
                          style: TextStyle(
                            fontSize: 13,
                            color: Theme.of(context).brightness == Brightness.dark ? const Color(0xFFFFB800) : Colors.orange.shade800,
                            height: 1.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                // Required Materials
                _buildSectionLabel('Required Materials', 'science_outlined'),
                const SizedBox(height: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: exp.requiredMaterials
                      .map((material) => Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  width: 6,
                                  height: 6,
                                  margin: const EdgeInsets.only(top: 7, right: 10),
                                  decoration: const BoxDecoration(
                                    color: Color(0xFF00D4FF),
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                Expanded(
                                  child: Text(
                                    material,
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Theme.of(context).brightness == Brightness.dark ? const Color(0xFF8BA3C0) : Colors.grey.shade700,
                                      height: 1.5,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ))
                      .toList(),
                ),
                const SizedBox(height: 20),
                // Related Concepts
                _buildSectionLabel('Related Concepts', 'hub_outlined'),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: exp.relatedConcepts
                      .map(
                        (concept) => Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0x1400D4FF),
                            borderRadius: BorderRadius.circular(50),
                            border: Border.all(
                              color: const Color(0x2200D4FF),
                              width: 1,
                            ),
                          ),
                          child: Text(
                            concept,
                            style: const TextStyle(
                              fontSize: 12,
                              color: Color(0xFF00D4FF),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      )
                      .toList(),
                ),
                const SizedBox(height: 28),
                // Launch AR Button
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: (!widget.isTeacher && widget.isLocked) ? () {
                      ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: const Text('This lab is locked by your teacher.'),
                              backgroundColor: const Color(0xFFFF4757),
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                          );
                    } : widget.onRunAR,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: (!widget.isTeacher && widget.isLocked) ? Colors.grey.shade700 : const Color(0xFF00D4FF),
                      foregroundColor: (!widget.isTeacher && widget.isLocked) ? Colors.white70 : const Color(0xFF0A1628),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(50),
                      ),
                      elevation: 0,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CustomIconWidget(
                          iconName: (!widget.isTeacher && widget.isLocked) ? 'lock' : 'view_in_ar',
                          color: (!widget.isTeacher && widget.isLocked) ? Colors.white70 : const Color(0xFF0A1628),
                          size: 22,
                        ),
                        const SizedBox(width: 10),
                        Text(
                          (!widget.isTeacher && widget.isLocked) ? 'Locked by Teacher' : 'Launch AR Experiment',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: (!widget.isTeacher && widget.isLocked) ? Colors.white70 : const Color(0xFF0A1628),
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
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionLabel(String label, String icon) {
    return Row(
      children: [
        CustomIconWidget(
          iconName: icon,
          color: const Color(0xFF00D4FF),
          size: 16,
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black87,
          ),
        ),
      ],
    );
  }
}
