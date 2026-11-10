import '../../../core/app_export.dart';
import '../../../services/youtube_service.dart';
import '../../../data/video_lesson_topics.dart';
import '../../../models/ar_experiment_model.dart';
import '../../../models/user_model.dart';
import '../../../services/auth_service.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

class _VideoLesson {
  final Uri url;
  final String title;
  final String subject;
  final String thumbnailUrl;
  final String semanticLabel;

  const _VideoLesson({
    required this.url,
    required this.title,
    required this.subject,
    required this.thumbnailUrl,
    required this.semanticLabel,
  });
}

class VideoLessonSectionWidget extends StatefulWidget {
  final List<ArExperimentModel> experiments;
  final Set<String> teacherGrades;

  const VideoLessonSectionWidget({
    super.key,
    this.experiments = const [],
    this.teacherGrades = const {},
  });

  @override
  State<VideoLessonSectionWidget> createState() =>
      _VideoLessonSectionWidgetState();
}

class _VideoLessonSectionWidgetState extends State<VideoLessonSectionWidget> {
  List<_VideoLesson> _lessons = [];
  bool _isLoading = true;
  List<VideoLessonTopic> _topics = [];
  String? _topicKey;
  int _requestVersion = 0;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _updateTopics(context.watch<AuthService>().currentUser?.role);
  }

  @override
  void didUpdateWidget(covariant VideoLessonSectionWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    _updateTopics(context.read<AuthService>().currentUser?.role);
  }

  void _updateTopics(UserRole? role) {
    final topics = videoLessonTopics(
      role: role,
      experiments: widget.experiments,
      teacherGrades: widget.teacherGrades,
    );
    final key = topics.map((topic) => topic.query).join('|');
    if (_topicKey == key) return;
    _topicKey = key;
    _topics = topics;
    _fetchYoutubeVideos();
  }

  Future<void> _fetchYoutubeVideos() async {
    final version = ++_requestVersion;
    if (mounted && !_isLoading) {
      setState(() {
        _isLoading = true;
      });
    }
    try {
      final youtubeService = YoutubeService();
      final topics = List<VideoLessonTopic>.from(_topics);
      final matches = await Future.wait(
        topics.map(
          (topic) => youtubeService.searchVideos(topic.query, maxResults: 1),
        ),
      );
      final usedIds = <String>{};
      final lessons = <_VideoLesson>[];
      for (var index = 0; index < topics.length; index++) {
        final topic = topics[index];
        final videos = matches[index]
            .where((video) => !usedIds.contains(video.id))
            .toList();
        if (videos.isNotEmpty) {
          final video = videos.first;
          usedIds.add(video.id);
          lessons.add(
            _VideoLesson(
              url: video.watchUrl,
              title: video.title,
              subject:
                  '${topic.grade} · ${topic.topic} · ${video.channelTitle}',
              thumbnailUrl: video.thumbnailUrl,
              semanticLabel: video.title,
            ),
          );
        } else {
          lessons.add(
            _VideoLesson(
              url: topic.searchUrl,
              title: topic.title,
              subject: '${topic.grade} · ${topic.topic} · Explore on YouTube',
              thumbnailUrl: '',
              semanticLabel: 'YouTube lessons about ${topic.title}',
            ),
          );
        }
      }

      if (mounted && version == _requestVersion) {
        setState(() {
          _lessons = lessons;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error fetching YouTube videos: $e');
      if (mounted && version == _requestVersion) {
        setState(() {
          _lessons = [];
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final accentColor = isDark
        ? const Color(0xFF00D4FF)
        : const Color(0xFF1565C0);
    final titleColor = isDark ? Colors.white : const Color(0xFF0A1628);
    final mutedColor = isDark ? const Color(0xFF8BA3C0) : Colors.grey.shade700;

    if (_isLoading) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: CircularProgressIndicator(color: accentColor),
        ),
      );
    }

    if (_lessons.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Text(
            'No video topics are available for your grade yet.',
            style: TextStyle(color: mutedColor),
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 20.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Video Lessons',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: titleColor,
                      letterSpacing: 0.5,
                      shadows: isDark
                          ? const [
                              Shadow(
                                color: Color(0x6600D4FF),
                                blurRadius: 10,
                                offset: Offset(0, 2),
                              ),
                            ]
                          : null,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: isDark
                          ? const Color(0xFF1E3A5F).withAlpha(77)
                          : const Color(0xFFE8F2FF),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                        color: isDark
                            ? const Color(0xFF00D4FF).withAlpha(77)
                            : const Color(0xFFB8D8F8),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.play_circle_fill,
                          color: Color(0xFFFF0000),
                          size: 14,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'Suggested on YouTube',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: mutedColor,
                            letterSpacing: 0.3,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              GestureDetector(
                onTap: _fetchYoutubeVideos,
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF0F1E35) : Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isDark
                          ? const Color(0xFF1E3A5F)
                          : Colors.grey.shade300,
                      width: 1,
                    ),
                    boxShadow: isDark
                        ? null
                        : const [
                            BoxShadow(
                              color: Color(0x120A1628),
                              blurRadius: 8,
                              offset: Offset(0, 3),
                            ),
                          ],
                  ),
                  child: Icon(Icons.refresh, color: accentColor, size: 20),
                ),
              ),
            ],
          ),
        ),
        ..._lessons.map((lesson) => _buildLessonItem(lesson)),
      ],
    );
  }

  Widget _buildLessonItem(_VideoLesson lesson) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDark ? const Color(0xFF0F1E35) : Colors.white;
    final borderColor = isDark ? const Color(0xFF1E3A5F) : Colors.grey.shade300;
    final titleColor = isDark ? Colors.white : const Color(0xFF0A1628);
    final mutedColor = isDark ? const Color(0xFF8BA3C0) : Colors.grey.shade600;

    return GestureDetector(
      onTap: () async {
        final opened = await launchUrl(
          lesson.url,
          mode: LaunchMode.externalApplication,
        );
        if (!opened && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Could not open YouTube. Please try again.'),
            ),
          );
        }
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: borderColor, width: 1),
          boxShadow: isDark
              ? null
              : const [
                  BoxShadow(
                    color: Color(0x120A1628),
                    blurRadius: 10,
                    offset: Offset(0, 4),
                  ),
                ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: lesson.thumbnailUrl.isEmpty
                    ? Container(
                        width: 80,
                        height: 60,
                        color: isDark
                            ? const Color(0xFF1E3A5F)
                            : const Color(0xFFE8F2FF),
                        child: const Icon(
                          Icons.smart_display_rounded,
                          color: Color(0xFFFF0000),
                          size: 32,
                        ),
                      )
                    : CustomImageWidget(
                        imageUrl: lesson.thumbnailUrl,
                        width: 80,
                        height: 60,
                        fit: BoxFit.cover,
                        semanticLabel: lesson.semanticLabel,
                      ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      lesson.title,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: titleColor,
                        height: 1.3,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Container(
                          width: 16,
                          height: 12,
                          decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.circular(3),
                          ),
                          child: const Center(
                            child: Icon(
                              Icons.play_arrow,
                              color: Colors.white,
                              size: 10,
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            lesson.subject,
                            style: TextStyle(fontSize: 11, color: mutedColor),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
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
      ),
    );
  }
}
