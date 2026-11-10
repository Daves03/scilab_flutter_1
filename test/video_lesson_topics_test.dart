import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:scilab_flutter_1/data/video_lesson_topics.dart';
import 'package:scilab_flutter_1/data/dummy_ar_experiments.dart';
import 'package:scilab_flutter_1/models/user_model.dart';
import 'package:scilab_flutter_1/services/youtube_service.dart';

void main() {
  test('Grade 9 and Grade 10 receive different curriculum topics', () {
    final grade9 = videoLessonTopics(role: UserRole.grade9);
    final grade10 = videoLessonTopics(role: UserRole.grade10);
    expect(grade9.length, 3);
    expect(grade10.length, 3);
    expect(grade9.every((topic) => topic.grade == 'Grade 9'), isTrue);
    expect(grade10.every((topic) => topic.grade == 'Grade 10'), isTrue);
    expect(
      grade9
          .map((topic) => topic.title)
          .toSet()
          .intersection(grade10.map((topic) => topic.title).toSet()),
      isEmpty,
    );
    expect(grade9.any((topic) => topic.query.contains('Limewater')), isTrue);
    expect(
      grade10.any((topic) => topic.query.contains('Conservation of Mass')),
      isTrue,
    );
  });

  test('teacher suggestions include only handled grade topics', () {
    final topics = videoLessonTopics(
      role: UserRole.teacher,
      teacherGrades: {'Grade 10'},
    );
    expect(topics.length, 3);
    expect(topics.every((topic) => topic.grade == 'Grade 10'), isTrue);
    expect(videoLessonTopics(role: UserRole.teacher), isEmpty);
  });

  test(
    'search links use the actual catalog topic and safely encode queries',
    () {
      final topics = videoLessonTopics(
        role: UserRole.grade9,
        experiments: dummyArExperiments
            .where((experiment) => experiment.id == 'ar3')
            .toList(),
      );
      expect(topics.single.searchUrl.host, 'www.youtube.com');
      expect(
        topics.single.searchUrl.queryParameters['search_query'],
        topics.single.query,
      );
      expect(topics.single.query, contains('Gas Testing'));
    },
  );

  test('no API key returns no fabricated videos or network requests', () async {
    final service = YoutubeService(
      apiKey: '',
      client: MockClient((_) async => throw StateError('Unexpected request')),
    );
    expect(await service.searchVideos('Grade 9 Gas Testing'), isEmpty);
  });

  test(
    'live search sends the topic query and returns real video metadata',
    () async {
      final query = videoLessonTopics(role: UserRole.grade10).first.query;
      final service = YoutubeService(
        apiKey: 'test-key',
        client: MockClient((request) async {
          expect(request.url.queryParameters['q'], query);
          expect(request.url.queryParameters['safeSearch'], 'strict');
          expect(request.url.queryParameters['type'], 'video');
          return http.Response(
            '{"items":[{"id":{"videoId":"real-video"},"snippet":{"title":"Real lesson","channelTitle":"Science","thumbnails":{"medium":{"url":"https://example.com/image.jpg"}}}}]}',
            200,
          );
        }),
      );
      final videos = await service.searchVideos(query, maxResults: 1);
      expect(videos.single.id, 'real-video');
      expect(videos.single.watchUrl.queryParameters['v'], 'real-video');
    },
  );

  test('API failure returns no unrelated placeholder videos', () async {
    final service = YoutubeService(
      apiKey: 'test-key',
      client: MockClient((_) async => http.Response('{}', 403)),
    );
    expect(await service.searchVideos('Grade 10 acids and bases'), isEmpty);
  });
}
