import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/activity_model.dart';

/// Logs what a student does on the AR/Unity screen and the Modules
/// screen, and reads it back for the Classroom monitoring panel.
///
/// Storage shape: `users/{uid}/experiment_activity/{experimentId}` and
/// `users/{uid}/module_activity/{moduleId}` — doc id = the item id, so
/// relaunching/reopening the same thing updates one row instead of
/// growing an unbounded log.
class ActivityService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> _experimentsRef(String uid) =>
      _db.collection('users').doc(uid).collection('experiment_activity');

  CollectionReference<Map<String, dynamic>> _modulesRef(String uid) =>
      _db.collection('users').doc(uid).collection('module_activity');

  Future<void> logExperimentLaunch(String uid, String experimentId) {
    return _experimentsRef(uid).doc(experimentId).set({
      'launchedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Future<void> markExperimentCompleted(String uid, String experimentId) {
    return _experimentsRef(uid).doc(experimentId).set({
      'completedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Future<void> logModuleOpen(String uid, String moduleId, String moduleTitle) {
    return _modulesRef(uid).doc(moduleId).set({
      'moduleTitle': moduleTitle,
      'openedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Stream<List<ExperimentActivity>> experimentActivityStream(String uid) {
    return _experimentsRef(uid).snapshots().map((snap) =>
        snap.docs.map((d) => ExperimentActivity.fromMap(d.id, d.data())).toList());
  }

  Stream<List<ModuleOpenActivity>> moduleActivityStream(String uid) {
    return _modulesRef(uid).snapshots().map((snap) =>
        snap.docs.map((d) => ModuleOpenActivity.fromMap(d.id, d.data())).toList());
  }
}
