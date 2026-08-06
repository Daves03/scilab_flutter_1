import '../../../core/app_export.dart';

// CourseCard — anatomy LOCKED from reference:
// tinted bg card, icon+rating row top, category label, bold title, avatar stack + CTA arrow

class CourseModel {
  final Color tintColor;
  final String iconName;
  final double rating;
  final String category;
  final String title;
  final String grade;
  final int chapters;
  final double progress;
  final int enrolledCount;
  final List<String> studentAvatarUrls;

  const CourseModel({
    required this.tintColor,
    required this.iconName,
    required this.rating,
    required this.category,
    required this.title,
    required this.grade,
    required this.chapters,
    required this.progress,
    required this.enrolledCount,
    required this.studentAvatarUrls,
  });
}

class CourseCardWidget extends StatelessWidget {
  final CourseModel course;
  final VoidCallback onTap;

  const CourseCardWidget({
    required this.course,
    required this.onTap,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: course.tintColor,
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
            // Icon + rating row
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
                      iconName: course.iconName,
                      color: const Color(0xFF00D4FF),
                      size: 24,
                    ),
                  ),
                ),
                Row(
                  children: [
                    const CustomIconWidget(
                      iconName: 'star_outlined',
                      color: Color(0xFFFFB800),
                      size: 16,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      course.rating.toStringAsFixed(1),
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFFFFB800),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 14),
            // Category label
            Text(
              course.category,
              style: const TextStyle(
                fontSize: 12,
                color: Color(0xFF8BA3C0),
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 4),
            // Course title
            Text(
              course.title,
              style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: Colors.white,
                height: 1.3,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 6),
            // Grade + chapters
            Text(
              '${course.grade} · ${course.chapters} chapters',
              style: const TextStyle(fontSize: 12, color: Color(0xFF5A7A9A)),
            ),
            const SizedBox(height: 12),
            // Progress bar
            if (course.progress > 0) ...[
              Row(
                children: [
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(50),
                      child: LinearProgressIndicator(
                        value: course.progress,
                        backgroundColor: Colors.white.withAlpha(26),
                        valueColor: AlwaysStoppedAnimation<Color>(
                          course.progress >= 0.7
                              ? const Color(0xFF00FF88)
                              : const Color(0xFF00D4FF),
                        ),
                        minHeight: 5,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '${(course.progress * 100).toInt()}%',
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF8BA3C0),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
            ] else ...[
              const SizedBox(height: 8),
            ],
            // Avatar stack + CTA
            Row(
              children: [
                _buildAvatarStack(),
                const SizedBox(width: 8),
                Text(
                  '${course.enrolledCount}+ students',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF8BA3C0),
                  ),
                ),
                const Spacer(),
                _buildArrowButton(),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAvatarStack() {
    final avatars = course.studentAvatarUrls.take(3).toList();
    return SizedBox(
      width: 20.0 + (avatars.length - 1) * 18.0,
      height: 28,
      child: Stack(
        children: List.generate(avatars.length, (i) {
          return Positioned(
            left: i * 18.0,
            child: Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: course.tintColor, width: 2),
              ),
              child: ClipOval(
                child: CustomImageWidget(
                  imageUrl: avatars[i],
                  width: 28,
                  height: 28,
                  fit: BoxFit.cover,
                  semanticLabel: 'Student enrolled in course',
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildArrowButton() {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white.withAlpha(20),
        border: Border.all(color: Colors.white.withAlpha(31), width: 1),
      ),
      child: const Center(
        child: CustomIconWidget(
          iconName: 'arrow_forward',
          color: Colors.white,
          size: 18,
        ),
      ),
    );
  }
}
