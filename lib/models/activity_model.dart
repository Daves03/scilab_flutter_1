import 'package:cloud_firestore/cloud_firestore.dart';

/// One row in `users/{uid}/experiment_activity/{experimentId}`.
/// Doc id = experimentId, so relaunching the same experiment updates
/// the same row instead of creating duplicates.
class ExperimentActivity {
  final String experimentId;
  final DateTime? launchedAt;
  final DateTime? completedAt;

  ExperimentActivity({
    required this.experimentId,
    this.launchedAt,
    this.completedAt,
  });

  bool get completed => completedAt != null;

  factory ExperimentActivity.fromMap(String id, Map<String, dynamic> data) {
    final launched = data['launchedAt'];
    final completed = data['completedAt'];
    return ExperimentActivity(
      experimentId: id,
      launchedAt: launched is Timestamp ? launched.toDate() : null,
      completedAt: completed is Timestamp ? completed.toDate() : null,
    );
  }
}

/// One row in `users/{uid}/module_activity/{moduleId}`.
/// Doc id = moduleId, so reopening the same module just bumps openedAt.
class ModuleOpenActivity {
  final String moduleId;
  final String moduleTitle;
  final DateTime? openedAt;

  ModuleOpenActivity({
    required this.moduleId,
    required this.moduleTitle,
    this.openedAt,
  });

  factory ModuleOpenActivity.fromMap(String id, Map<String, dynamic> data) {
    final ts = data['openedAt'];
    return ModuleOpenActivity(
      moduleId: id,
      moduleTitle: (data['moduleTitle'] as String?) ?? '',
      openedAt: ts is Timestamp ? ts.toDate() : null,
    );
  }
}
