import '../models/activity_model.dart';
import '../models/ar_progress_assessment.dart';

class ArLabRecord {
  final String experimentName;
  final int attempts;
  final double rubricScore;
  final Map<String, int> rubricScores;
  final String lastAttemptDate;
  final bool isGraded;

  const ArLabRecord({
    required this.experimentName,
    required this.attempts,
    required this.rubricScore,
    required this.rubricScores,
    required this.lastAttemptDate,
    this.isGraded = true,
  });
}

List<ArLabRecord> buildStudentArRecords({
  required Map<String, ExperimentActivity> activities,
  required Map<String, String> experimentTitles,
  required String Function(DateTime?) formatDate,
}) {
  final ordered = activities.entries.toList()
    ..sort((first, second) {
      final firstDate = first.value.completedAt ?? first.value.launchedAt;
      final secondDate = second.value.completedAt ?? second.value.launchedAt;
      if (firstDate == null) return secondDate == null ? 0 : 1;
      if (secondDate == null) return -1;
      return secondDate.compareTo(firstDate);
    });
  return ordered.map((entry) {
    final activity = entry.value;
    return ArLabRecord(
      experimentName: experimentTitles[entry.key] ?? 'Unknown Experiment',
      attempts: 1,
      isGraded: activity.isGraded,
      rubricScore: !activity.isGraded
          ? 0
          : ArProgressAssessment.score(
              activity.rubricScores,
              fallback:
                  activity.rubricScore ?? (activity.completed ? 100.0 : 0.0),
            )!,
      rubricScores: !activity.isGraded
          ? const {}
          : ArProgressAssessment.normalize(activity.rubricScores),
      lastAttemptDate: formatDate(activity.completedAt ?? activity.launchedAt),
    );
  }).toList();
}
