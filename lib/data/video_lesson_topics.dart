import 'ar_experiment_catalog.dart';
import 'dummy_ar_experiments.dart';
import '../models/ar_experiment_model.dart';
import '../models/user_model.dart';

class VideoLessonTopic {
  final String title;
  final String topic;
  final String grade;
  const VideoLessonTopic({
    required this.title,
    required this.topic,
    required this.grade,
  });

  String get query => '$grade chemistry $title $topic lesson';
  Uri get searchUrl =>
      Uri.https('www.youtube.com', '/results', {'search_query': query});
}

List<VideoLessonTopic> videoLessonTopics({
  required UserRole? role,
  List<ArExperimentModel> experiments = const [],
  Set<String> teacherGrades = const {},
}) {
  final source = experiments.isEmpty ? dummyArExperiments : experiments;
  final groups = role == UserRole.teacher
      ? experimentGroupsForTeacherGrades(source, teacherGrades)
      : experimentGroupsForRole(source, role);
  final topics = <VideoLessonTopic>[];
  for (final group in groups) {
    // Use the grade's curriculum topics before the shared enrichment activities.
    if (!group.title.startsWith('Grade ')) continue;
    final grade = group.title.replaceFirst(' Experiments', '');
    for (final experiment in group.experiments) {
      topics.add(
        VideoLessonTopic(
          title: experiment.title,
          topic: experiment.topic,
          grade: grade,
        ),
      );
    }
  }
  return topics;
}
