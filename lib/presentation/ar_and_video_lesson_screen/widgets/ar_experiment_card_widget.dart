import '../../../core/app_export.dart';
import '../ar_and_video_lesson_screen.dart';

// ARExperimentCard — anatomy LOCKED:
// tinted bg, difficulty badge + icon row top, topic label, bold title,
// background info snippet, Run AR circular button

class ArExperimentCardWidget extends StatelessWidget {
  final ArExperimentModel experiment;
  final VoidCallback onTap;
  final VoidCallback onRun;

  const ArExperimentCardWidget({
    required this.experiment,
    required this.onTap,
    required this.onRun,
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
              ],
            ),
            const SizedBox(height: 14),
            // Topic label
            Text(
              experiment.topic,
              style: const TextStyle(
                fontSize: 12,
                color: Color(0xFF8BA3C0),
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 4),
            // Title
            Text(
              experiment.title,
              style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: Colors.white,
                height: 1.3,
              ),
            ),
            const SizedBox(height: 8),
            // Background info snippet
            Text(
              experiment.backgroundInfo,
              style: const TextStyle(
                fontSize: 13,
                color: Color(0xFF8BA3C0),
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
                  onTap: onRun,
                  child: Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [Color(0xFF00D4FF), Color(0xFF0090B0)],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF00D4FF).withAlpha(102),
                          blurRadius: 16,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                    child: const Center(
                      child: CustomIconWidget(
                        iconName: 'view_in_ar',
                        color: Color(0xFF0A1628),
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
