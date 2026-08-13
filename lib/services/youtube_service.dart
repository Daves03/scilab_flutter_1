import 'dart:convert';
import 'package:http/http.dart' as http;

class YoutubeVideo {
  final String id;
  final String title;
  final String channelTitle;
  final String thumbnailUrl;

  YoutubeVideo({
    required this.id,
    required this.title,
    required this.channelTitle,
    required this.thumbnailUrl,
  });

  factory YoutubeVideo.fromJson(Map<String, dynamic> json) {
    return YoutubeVideo(
      id: json['id']['videoId'] ?? '',
      title: json['snippet']['title'] ?? 'Unknown Title',
      channelTitle: json['snippet']['channelTitle'] ?? 'Unknown Channel',
      thumbnailUrl: json['snippet']['thumbnails']['medium']['url'] ?? '',
    );
  }
}

class YoutubeService {
  // TODO: Replace with your actual YouTube Data API v3 Key
  static const String _apiKey = 'yt api';
  static const String _baseUrl = 'https://www.googleapis.com/youtube/v3/search';

  Future<List<YoutubeVideo>> searchVideos(String query, {int maxResults = 3}) async {
    // If API key is not set, return dummy data to prevent crashes
    if (_apiKey == 'YOUR_YOUTUBE_API_KEY' || _apiKey.isEmpty) {
      return [
        YoutubeVideo(
          id: 'jNQXAC9IVRw', // "Me at the zoo" - First YouTube video
          title: 'Chemistry Tutorial: $query',
          channelTitle: 'Science Channel',
          thumbnailUrl: 'https://img.youtube.com/vi/jNQXAC9IVRw/mqdefault.jpg',
        ),
        YoutubeVideo(
          id: 'dQw4w9WgXcQ',
          title: 'Advanced Concepts in $query',
          channelTitle: 'EduChem',
          thumbnailUrl: 'https://img.youtube.com/vi/dQw4w9WgXcQ/mqdefault.jpg',
        ),
      ];
    }

    try {
      final url = Uri.parse(
          '$_baseUrl?part=snippet&maxResults=$maxResults&q=$query&type=video&key=$_apiKey');
      
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final items = data['items'] as List;
        return items.map((item) => YoutubeVideo.fromJson(item)).toList();
      } else {
        print('YouTube API Error: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      print('Exception fetching YouTube videos: $e');
      return [];
    }
  }
}
