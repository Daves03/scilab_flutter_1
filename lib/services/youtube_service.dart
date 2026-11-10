import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class YoutubeVideo {
  final String id;
  final String title;
  final String channelTitle;
  final String thumbnailUrl;
  Uri get watchUrl => Uri.https('www.youtube.com', '/watch', {'v': id});

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
  static const String _configuredApiKey = String.fromEnvironment(
    'YOUTUBE_API_KEY',
  );
  final String apiKey;
  final http.Client? client;

  YoutubeService({this.apiKey = _configuredApiKey, this.client});

  Future<List<YoutubeVideo>> searchVideos(
    String query, {
    int maxResults = 3,
  }) async {
    // Never substitute unrelated videos when live YouTube search is unavailable.
    final normalizedKey = apiKey.trim().toLowerCase();
    if (normalizedKey.isEmpty ||
        normalizedKey == 'your_youtube_api_key' ||
        normalizedKey == 'yt api here') {
      return [];
    }

    try {
      final url = Uri.https('www.googleapis.com', '/youtube/v3/search', {
        'part': 'snippet',
        'maxResults': maxResults.clamp(1, 50).toString(),
        'q': query,
        'type': 'video',
        'order': 'relevance',
        'safeSearch': 'strict',
        'relevanceLanguage': 'en',
        'key': apiKey,
      });

      final response = await (client?.get(url) ?? http.get(url)).timeout(
        const Duration(seconds: 15),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final items = data['items'] as List;
        return items
            .map((item) => YoutubeVideo.fromJson(item))
            .where((video) => video.id.isNotEmpty)
            .toList();
      } else {
        debugPrint('YouTube API Error: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      debugPrint('YouTube search is temporarily unavailable.');
      return [];
    }
  }
}
