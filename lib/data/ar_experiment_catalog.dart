import '../models/ar_experiment_model.dart';
import '../models/user_model.dart';

enum ArExperimentTrack { grade9, grade10, enrichment, unassigned }

const List<String> grade9ExperimentIds = ['ar3', 'ar2', 'ar5'];
const List<String> grade10ExperimentIds = ['ar7', 'ar1', 'ar6'];
const List<String> enrichmentExperimentIds = ['ar4', 'ar8'];

String normalizeExperimentId(String id) {
  final digits = id.replaceAll(RegExp(r'[^0-9]'), '');
  return digits.isEmpty ? id.toLowerCase() : 'ar$digits';
}

ArExperimentTrack experimentTrackFor(String experimentId) {
  final id = normalizeExperimentId(experimentId);
  if (grade9ExperimentIds.contains(id)) return ArExperimentTrack.grade9;
  if (grade10ExperimentIds.contains(id)) return ArExperimentTrack.grade10;
  if (enrichmentExperimentIds.contains(id)) {
    return ArExperimentTrack.enrichment;
  }
  return ArExperimentTrack.unassigned;
}

bool canRoleAccessExperiment(UserRole? role, String experimentId) {
  final track = experimentTrackFor(experimentId);
  return switch (role) {
    UserRole.grade9 =>
      track == ArExperimentTrack.grade9 ||
          track == ArExperimentTrack.enrichment,
    UserRole.grade10 => track != ArExperimentTrack.unassigned,
    UserRole.teacher || UserRole.admin => true,
    null => false,
  };
}

class ArExperimentGroup {
  const ArExperimentGroup({
    required this.title,
    required this.subtitle,
    required this.experiments,
  });

  final String title;
  final String subtitle;
  final List<ArExperimentModel> experiments;
}

List<ArExperimentGroup> experimentGroupsForRole(
  List<ArExperimentModel> experiments,
  UserRole? role,
) {
  List<ArExperimentModel> ordered(List<String> ids) => ids
      .map(
        (id) => experiments.cast<ArExperimentModel?>().firstWhere(
          (experiment) => normalizeExperimentId(experiment!.id) == id,
          orElse: () => null,
        ),
      )
      .whereType<ArExperimentModel>()
      .toList();

  final groups = <ArExperimentGroup>[];
  final showsAll = role == UserRole.teacher || role == UserRole.admin;
  if (role == UserRole.grade9 || role == UserRole.grade10 || showsAll) {
    groups.add(
      ArExperimentGroup(
        title: 'Grade 9 Experiments',
        subtitle: role == UserRole.grade10
            ? 'Foundation experiments from Grade 9'
            : showsAll
            ? 'Grade 9 curriculum experiments'
            : 'Experiments for your grade level',
        experiments: ordered(grade9ExperimentIds),
      ),
    );
  }
  if (role == UserRole.grade10 || showsAll) {
    groups.add(
      ArExperimentGroup(
        title: 'Grade 10 Experiments',
        subtitle: showsAll
            ? 'Grade 10 curriculum experiments'
            : 'Experiments for your grade level',
        experiments: ordered(grade10ExperimentIds),
      ),
    );
  }
  if (role == UserRole.grade9 || role == UserRole.grade10 || showsAll) {
    groups.add(
      ArExperimentGroup(
        title: 'Enrichment Activities',
        subtitle: 'Optional AR add-ons available to both grade levels',
        experiments: ordered(enrichmentExperimentIds),
      ),
    );
  }

  return groups.where((group) => group.experiments.isNotEmpty).toList();
}

List<ArExperimentGroup> experimentGroupsForTeacherGrades(
  List<ArExperimentModel> experiments,
  Set<String> gradeLabels,
) {
  final normalizedGrades = gradeLabels
      .map((grade) => grade.toLowerCase().replaceAll(' ', ''))
      .toSet();
  final allGroups = experimentGroupsForRole(experiments, UserRole.teacher);

  return allGroups.where((group) {
    if (group.title == 'Grade 9 Experiments') {
      return normalizedGrades.contains('grade9');
    }
    if (group.title == 'Grade 10 Experiments') {
      return normalizedGrades.contains('grade10');
    }
    return group.title == 'Enrichment Activities' &&
        normalizedGrades.isNotEmpty;
  }).toList();
}
