import 'package:flutter_test/flutter_test.dart';
import 'package:scilab_flutter_1/models/activity_model.dart';
import 'package:scilab_flutter_1/services/student_ar_progress.dart';

void main() {
  test(
    'periodic table activity is retained without a rubric or graded result',
    () {
      final result = buildStudentArRecords(
        activities: {
          'ar8': ExperimentActivity(
            experimentId: 'ar8',
            completedAt: DateTime(2026, 11, 10),
            rubricScore: 100,
            rubricScores: {'total': 100},
          ),
        },
        experimentTitles: {'ar8': 'Interactive Periodic Table'},
        formatDate: (_) => 'Today',
      ).single;
      expect(result.experimentName, 'Interactive Periodic Table');
      expect(result.isGraded, isFalse);
      expect(result.rubricScores, isEmpty);
    },
  );
  final now = DateTime(2026, 11, 10);
  List<ArLabRecord> records(Map<String, ExperimentActivity> activities) =>
      buildStudentArRecords(
        activities: activities,
        experimentTitles: {'ar1': 'Experiment One', 'ar2': 'Experiment Two'},
        formatDate: (value) => value?.toIso8601String() ?? '',
      );

  test(
    'new completion and later score corrections replace the current result',
    () {
      expect(records({}), isEmpty);
      expect(
        records({
          'ar1': ExperimentActivity(experimentId: 'ar1', launchedAt: now),
        }).single.rubricScore,
        0,
      );
      final completed = records({
        'ar1': ExperimentActivity(
          experimentId: 'ar1',
          completedAt: now,
          rubricScore: 85,
          rubricScores: {'total': 85},
        ),
      });
      expect(completed.single.experimentName, 'Experiment One');
      expect(completed.single.rubricScore, 85);
      expect(completed.single.rubricScores['total'], 85);
      expect(completed.single.lastAttemptDate, now.toIso8601String());
      expect(
        records({
          'ar1': ExperimentActivity(
            experimentId: 'ar1',
            completedAt: now,
            rubricScore: 95,
          ),
        }).single.rubricScore,
        95,
      );
      expect(records({}), isEmpty);
    },
  );

  test(
    'newer AR records move above older ones while undated records stay last',
    () {
      final result = records({
        'ar1': ExperimentActivity(
          experimentId: 'ar1',
          completedAt: now.subtract(const Duration(days: 1)),
        ),
        'unknown': ExperimentActivity(experimentId: 'unknown'),
        'ar2': ExperimentActivity(experimentId: 'ar2', completedAt: now),
      });
      expect(result.map((record) => record.experimentName), [
        'Experiment Two',
        'Experiment One',
        'Unknown Experiment',
      ]);
    },
  );

  test('legacy completed records keep the existing score fallback', () {
    expect(
      records({
        'ar1': ExperimentActivity(experimentId: 'ar1', completedAt: now),
      }).single.rubricScore,
      100,
    );
  });
}
