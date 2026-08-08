import '../../../core/app_export.dart';
import '../../../models/ar_experiment_model.dart';
import '../student_ar_and_video_lesson_screen.dart';

// ARExperimentCard — anatomy LOCKED:
// tinted bg, difficulty badge + icon row top, topic label, bold title,
// background info snippet, Run AR circular button

class ArExperimentCardWidget extends StatelessWidget {
  final ArExperimentModel experiment;
  final VoidCallback onTap;
  final VoidCallback onRun;
  final bool isLocked;
  final bool isTeacher;
  final ValueChanged<bool>? onToggleLock;

  const ArExperimentCardWidget({
    required this.experiment,
    required this.onTap,
    required this.onRun,
    this.isLocked = false,
    this.isTeacher = false,
    this.onToggleLock,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: experiment.tintColor,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: const Color(0xFF00D4FF).withAlpha(20),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(64),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Icon row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: Colors.white.withAlpha(20),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: CustomIconWidget(
                        iconName: experiment.iconName,
                        color: const Color(0xFF00D4FF),
                        size: 24,
                      ),
                    ),
                  ),
                  if (isTeacher)
                    GestureDetector(
                      onTap: () {
                        if (!isLocked) {
                          showDialog(
                            context: context,
                            builder: (ctx) => AlertDialog(
                              backgroundColor: const Color(0xFF142240),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                              title: Row(
                                children: [
                                  const Icon(Icons.lightbulb_outline, color: Color(0xFFFFB800)),
                                  const SizedBox(width: 8),
                                  const Text('Tip', style: TextStyle(color: Colors.white, fontSize: 18)),
                                ],
                              ),
                              content: const Text(
                                'Lock it if you want to focus on a specific experiment for students, so they cannot test it out if it\'s not connected to the topic yet.',
                                style: TextStyle(color: Color(0xFF8BA3C0), fontSize: 14, height: 1.5),
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(ctx),
                                  child: const Text('Cancel', style: TextStyle(color: Color(0xFF8BA3C0))),
                                ),
                                TextButton(
                                  onPressed: () {
                                    Navigator.pop(ctx);
                                    if (onToggleLock != null) {
                                      onToggleLock!(true);
                                    }
                                  },
                                  child: const Text('Lock Experiment', style: TextStyle(color: Color(0xFFFF4757), fontWeight: FontWeight.w600)),
                                ),
                              ],
                            ),
                          );
                        } else {
                          if (onToggleLock != null) {
                            onToggleLock!(false);
                          }
                        }
                      },
                      child: Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: isLocked ? const Color(0xFFFF4757).withAlpha(30) : const Color(0xFF00FF88).withAlpha(30),
                          shape: BoxShape.circle,
                          border: Border.all(color: isLocked ? const Color(0xFFFF4757).withAlpha(80) : const Color(0xFF00FF88).withAlpha(80)),
                        ),
                        child: Center(
                          child: CustomIconWidget(
                            iconName: isLocked ? 'lock' : 'lock_open',
                            color: isLocked ? const Color(0xFFFF4757) : const Color(0xFF00FF88),
                            size: 20,
                          ),
                        ),
                      ),
                    )
                  else if (isLocked)
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: const Color(0xFFFF4757).withAlpha(30),
                        shape: BoxShape.circle,
                      ),
                      child: const Center(
                        child: CustomIconWidget(
                          iconName: 'lock',
                          color: Color(0xFFFF4757),
                          size: 18,
                        ),
                      ),
                    ),
                ],
              ),
            const SizedBox(height: 14),
            // Topic label
            Text(
              experiment.topic,
              style: TextStyle(
                fontSize: 12,
                color: Theme.of(context).brightness == Brightness.dark ? const Color(0xFF8BA3C0) : Colors.grey.shade600,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 4),
            // Title
            Text(
              experiment.title,
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black87,
                height: 1.3,
              ),
            ),
            const SizedBox(height: 8),
            // Background info snippet
            Text(
              experiment.backgroundInfo,
              style: TextStyle(
                fontSize: 13,
                color: Theme.of(context).brightness == Brightness.dark ? const Color(0xFF8BA3C0) : Colors.grey.shade700,
                height: 1.5,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 16),
            // Bottom row: category + run button
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0x1400D4FF),
                    borderRadius: BorderRadius.circular(50),
                  ),
                  child: Text(
                    experiment.category,
                    style: const TextStyle(
                      fontSize: 11,
                      color: Color(0xFF00D4FF),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                const Spacer(),
                // Run AR circular button
                GestureDetector(
                  onTap: (!isTeacher && isLocked)
                      ? () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: const Text('This lab is locked by your teacher.'),
                              backgroundColor: const Color(0xFFFF4757),
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                          );
                        }
                      : onRun,
                  child: Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: (!isTeacher && isLocked)
                            ? [Colors.grey.shade700, Colors.grey.shade800]
                            : [const Color(0xFF00D4FF), const Color(0xFF0090B0)],
                      ),
                      boxShadow: (!isTeacher && isLocked)
                          ? []
                          : [
                              BoxShadow(
                                color: const Color(0xFF00D4FF).withAlpha(102),
                                blurRadius: 16,
                                spreadRadius: 1,
                              ),
                            ],
                    ),
                    child: Center(
                      child: CustomIconWidget(
                        iconName: (!isTeacher && isLocked) ? 'lock' : 'view_in_ar',
                        color: (!isTeacher && isLocked) ? Colors.white70 : const Color(0xFF0A1628),
                        size: 22,
                      ),
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
