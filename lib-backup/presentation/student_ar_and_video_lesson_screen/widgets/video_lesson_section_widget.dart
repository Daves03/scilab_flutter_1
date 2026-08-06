import '../../../core/app_export.dart';

class _VideoLesson {
  final String id;
  final String title;
  final String subject;
  final String duration;
  final String thumbnailUrl;
  final bool isCompleted;
  final String semanticLabel;

  const _VideoLesson({
    required this.id,
    required this.title,
    required this.subject,
    required this.duration,
    required this.thumbnailUrl,
    required this.isCompleted,
    required this.semanticLabel,
  });
}

class VideoLessonSectionWidget extends StatefulWidget {
  const VideoLessonSectionWidget({super.key});

  @override
  State<VideoLessonSectionWidget> createState() =>
      _VideoLessonSectionWidgetState();
}

// TODO: Replace with [Riverpod/Bloc] for production
class _VideoLessonSectionWidgetState extends State<VideoLessonSectionWidget> {
  String? _playingId;

  static const List<Map<String, dynamic>> _lessonMaps = [
    {
      'id': 'v1',
      'title': 'Introduction to Organic Chemistry',
      'subject': 'Organic Chemistry',
      'duration': '14:32',
      'thumbnailUrl':
          'https://img.rocket.new/generatedImages/rocket_gen_img_11bdf30c8-1784441868031.png',
      'isCompleted': true,
      'semanticLabel':
          'Chemistry laboratory with glassware and colorful chemical solutions',
    },
    {
      'id': 'v2',
      'title': 'Alkanes, Alkenes & Alkynes',
      'subject': 'Organic Chemistry',
      'duration': '22:15',
      'thumbnailUrl':
          'https://images.unsplash.com/photo-1645839072940-bb2a4f189ed3',
      'isCompleted': true,
      'semanticLabel':
          'Colorful molecular model with connected atom spheres on dark surface',
    },
    {
      'id': 'v3',
      'title': 'Acid-Base Equilibrium Explained',
      'subject': 'Physical Chemistry',
      'duration': '18:44',
      'thumbnailUrl':
          'https://img.rocket.new/generatedImages/rocket_gen_img_1cfa6b0e0-1779860178403.png',
      'isCompleted': false,
      'semanticLabel':
          'Science lab equipment including Erlenmeyer flasks and pipettes',
    },
    {
      'id': 'v4',
      'title': 'Thermodynamics: First Law',
      'subject': 'Physical Chemistry',
      'duration': '26:08',
      'thumbnailUrl':
          'https://img.rocket.new/generatedImages/rocket_gen_img_13cc2307a-1782299762315.png',
      'isCompleted': false,
      'semanticLabel':
          'Augmented reality interface with scientific data visualization',
    },
  ];

  List<_VideoLesson> _lessons = [];

  @override
  void initState() {
    super.initState();
    _lessons = _lessonMaps
        .map(
          (m) => _VideoLesson(
            id: m['id'] as String,
            title: m['title'] as String,
            subject: m['subject'] as String,
            duration: m['duration'] as String,
            thumbnailUrl: m['thumbnailUrl'] as String,
            isCompleted: m['isCompleted'] as bool,
            semanticLabel: m['semanticLabel'] as String,
          ),
        )
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: _lessons.map((lesson) => _buildLessonItem(lesson)).toList(),
    );
  }

  Widget _buildLessonItem(_VideoLesson lesson) {
    final isPlaying = _playingId == lesson.id;

    return GestureDetector(
      onTap: () => setState(() => _playingId = isPlaying ? null : lesson.id),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: const Color(0xFF0F1E35),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isPlaying
                ? const Color(0xFF00D4FF).withAlpha(102)
                : const Color(0xFF1E3A5F),
            width: isPlaying ? 1.5 : 1,
          ),
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(14),
              child: Row(
                children: [
                  // Thumbnail with play overlay
                  Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: CustomImageWidget(
                          imageUrl: lesson.thumbnailUrl,
                          width: 80,
                          height: 60,
                          fit: BoxFit.cover,
                          semanticLabel: lesson.semanticLabel,
                        ),
                      ),
                      Positioned.fill(
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.black.withAlpha(89),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Center(
                            child: Container(
                              width: 28,
                              height: 28,
                              decoration: BoxDecoration(
                                color: isPlaying
                                    ? const Color(0xFF00D4FF)
                                    : Colors.white.withAlpha(230),
                                shape: BoxShape.circle,
                              ),
                              child: Center(
                                child: CustomIconWidget(
                                  iconName: isPlaying ? 'pause' : 'play_arrow',
                                  color: const Color(0xFF0A1628),
                                  size: 16,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          lesson.title,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                            height: 1.3,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          lesson.subject,
                          style: const TextStyle(
                            fontSize: 11,
                            color: Color(0xFF8BA3C0),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            const CustomIconWidget(
                              iconName: 'access_time',
                              color: Color(0xFF5A7A9A),
                              size: 12,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              lesson.duration,
                              style: const TextStyle(
                                fontSize: 11,
                                color: Color(0xFF5A7A9A),
                              ),
                            ),
                            const Spacer(),
                            if (lesson.isCompleted)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 3,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0x1400FF88),
                                  borderRadius: BorderRadius.circular(50),
                                ),
                                child: Row(
                                  children: const [
                                    CustomIconWidget(
                                      iconName: 'check_circle',
                                      color: Color(0xFF00FF88),
                                      size: 11,
                                    ),
                                    SizedBox(width: 3),
                                    Text(
                                      'Done',
                                      style: TextStyle(
                                        fontSize: 10,
                                        color: Color(0xFF00FF88),
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            // Expanded player mock
            if (isPlaying)
              Container(
                margin: const EdgeInsets.fromLTRB(14, 0, 14, 14),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFF142240),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Column(
                  children: [
                    // Seek bar
                    Row(
                      children: [
                        const Text(
                          '4:22',
                          style: TextStyle(
                            fontSize: 11,
                            color: Color(0xFF8BA3C0),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: SliderTheme(
                            data: SliderThemeData(
                              trackHeight: 3,
                              thumbShape: const RoundSliderThumbShape(
                                enabledThumbRadius: 6,
                              ),
                              overlayShape: const RoundSliderOverlayShape(
                                overlayRadius: 12,
                              ),
                              activeTrackColor: const Color(0xFF00D4FF),
                              inactiveTrackColor: const Color(0xFF1E3A5F),
                              thumbColor: const Color(0xFF00D4FF),
                              overlayColor: const Color(
                                0xFF00D4FF,
                              ).withAlpha(51),
                            ),
                            child: Slider(value: 0.3, onChanged: (_) {}),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          lesson.duration,
                          style: const TextStyle(
                            fontSize: 11,
                            color: Color(0xFF8BA3C0),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    // Controls
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildControlBtn('replay_10', 28),
                        _buildControlBtn('skip_previous', 28),
                        Container(
                          width: 44,
                          height: 44,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: Color(0xFF00D4FF),
                          ),
                          child: const Center(
                            child: CustomIconWidget(
                              iconName: 'pause',
                              color: Color(0xFF0A1628),
                              size: 22,
                            ),
                          ),
                        ),
                        _buildControlBtn('skip_next', 28),
                        _buildControlBtn('forward_10', 28),
                      ],
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      height: 40,
                      child: ElevatedButton(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0x1400FF88),
                          foregroundColor: const Color(0xFF00FF88),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(50),
                          ),
                          elevation: 0,
                          side: const BorderSide(
                            color: Color(0x3300FF88),
                            width: 1,
                          ),
                        ),
                        child: const Text(
                          'Mark as Complete',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
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

  Widget _buildControlBtn(String icon, double size) {
    return Container(
      width: 36,
      height: 36,
      decoration: const BoxDecoration(
        color: Color(0xFF1E3A5F),
        shape: BoxShape.circle,
      ),
      child: Center(
        child: CustomIconWidget(
          iconName: icon,
          color: const Color(0xFF8BA3C0),
          size: 18,
        ),
      ),
    );
  }
}
