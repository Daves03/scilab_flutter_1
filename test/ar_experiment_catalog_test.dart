import 'package:flutter_test/flutter_test.dart';
import 'package:scilab_flutter_1/data/ar_experiment_catalog.dart';
import 'package:scilab_flutter_1/data/dummy_ar_experiments.dart';
import 'package:scilab_flutter_1/models/user_model.dart';

void main() {
  test('Grade 9 only receives Grade 9 and enrichment access', () {
    for (final id in grade9ExperimentIds) {
      expect(canRoleAccessExperiment(UserRole.grade9, id), isTrue);
    }
    for (final id in enrichmentExperimentIds) {
      expect(canRoleAccessExperiment(UserRole.grade9, id), isTrue);
    }
    for (final id in grade10ExperimentIds) {
      expect(canRoleAccessExperiment(UserRole.grade9, id), isFalse);
    }
  });

  test('Grade 10 receives both grade levels and enrichment access', () {
    final allStudentExperiments = [
      ...grade9ExperimentIds,
      ...grade10ExperimentIds,
      ...enrichmentExperimentIds,
    ];
    for (final id in allStudentExperiments) {
      expect(canRoleAccessExperiment(UserRole.grade10, id), isTrue);
    }
  });

  test(
    'teachers and admins retain access to assigned and unknown experiments',
    () {
      expect(canRoleAccessExperiment(UserRole.teacher, 'ar1'), isTrue);
      expect(
        canRoleAccessExperiment(UserRole.teacher, 'future-experiment'),
        isTrue,
      );
      expect(
        canRoleAccessExperiment(UserRole.admin, 'future-experiment'),
        isTrue,
      );
    },
  );

  test('Grade 9-only teachers see Grade 9 and enrichment groups', () {
    final groups = experimentGroupsForTeacherGrades(dummyArExperiments, {
      'Grade 9',
    });

    expect(groups.map((group) => group.title), [
      'Grade 9 Experiments',
      'Enrichment Activities',
    ]);
    expect(groups.expand((group) => group.experiments).map((item) => item.id), [
      ...grade9ExperimentIds,
      ...enrichmentExperimentIds,
    ]);
  });

  test('teachers assigned to both grades see all curriculum groups', () {
    final groups = experimentGroupsForTeacherGrades(dummyArExperiments, {
      'Grade 9',
      'Grade 10',
    });
    expect(groups.map((group) => group.title), [
      'Grade 9 Experiments',
      'Grade 10 Experiments',
      'Enrichment Activities',
    ]);
  });
}
