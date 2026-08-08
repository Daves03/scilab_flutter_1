import '../../../core/app_export.dart';
import '../../../services/youtube_service.dart';
import 'package:url_launcher/url_launcher.dart';

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
  List<_VideoLesson> _lessons = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchYoutubeVideos();
  }

  Future<void> _fetchYoutubeVideos() async {
    try {
      final youtubeService = YoutubeService();
      final videos = await youtubeService.searchVideos('Chemistry experiments', maxResults: 4);
      
      if (mounted) {
        setState(() {
          _lessons = videos.map((v) => _VideoLesson(
            id: v.id,
            title: v.title,
            subject: v.channelTitle,
            duration: '10:00', // Placeholder
            thumbnailUrl: v.thumbnailUrl,
            isCompleted: false,
            semanticLabel: v.title,
          )).toList();
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error fetching youtube videos: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(20.0),
          child: CircularProgressIndicator(color: Color(0xFF00D4FF)),
        ),
      );
    }

    if (_lessons.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(20.0),
          child: Text('No videos found.', style: TextStyle(color: Colors.white)),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Video Lessons',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Suggested on YouTube',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.white,
                  letterSpacing: 0.2,
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
    return GestureDetector(
      onTap: () async {
        final url = Uri.parse('https://www.youtube.com/watch?v=${lesson.id}');
        if (await canLaunchUrl(url)) {
          await launchUrl(url);
        } else {
          print('Could not launch $url');
        }
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: const Color(0xFF0F1E35),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: const Color(0xFF1E3A5F),
            width: 1,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
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
                            style: const TextStyle(
                              fontSize: 11,
                              color: Color(0xFF8BA3C0),
                            ),
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
