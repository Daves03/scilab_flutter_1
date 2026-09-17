import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/ar_experiment_model.dart';
import '../data/dummy_ar_experiments.dart';

class ArService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  static const _collection = 'ar_experiments';

  Stream<List<ArExperimentModel>> experimentsStream() async* {
    try {
      await for (final snap in _db.collection(_collection).snapshots()) {
        final exps = snap.docs.map((d) => ArExperimentModel.fromMap(d.id, d.data())).toList();
        if (exps.isNotEmpty) {
          yield exps;
        } else {
          yield dummyArExperiments;
        }
      }
    } catch (e) {
      print('AR Service fallback due to error: ');
      yield dummyArExperiments;
    }
  }

  Future<List<ArExperimentModel>> fetchExperiments() async {
    final snap = await _db.collection(_collection).get();
    return snap.docs.map((d) => ArExperimentModel.fromMap(d.id, d.data())).toList();
  }

  Future<void> addExperiment(ArExperimentModel experiment) async {
    await _db.collection(_collection).doc(experiment.id).set(experiment.toMap());
  }

  Future<void> updateExperiment(ArExperimentModel experiment) async {
    await _db.collection(_collection).doc(experiment.id).update(experiment.toMap());
  }

  Future<void> deleteExperiment(String id) async {
    await _db.collection(_collection).doc(id).delete();
  }

  /// Stream locked experiment IDs for a specific set of sections.
  Stream<List<String>> streamLockedExperimentsForSections(List<String> sections) {
    if (sections.isEmpty) return Stream.value([]);
    
    return _db
        .collection('ar_locks')
        .where(FieldPath.documentId, whereIn: sections.take(10).toList())
        .snapshots()
        .map((snap) {
      final Set<String> lockedIds = {};
      for (final doc in snap.docs) {
        final list = List<String>.from(doc.data()['lockedExperiments'] ?? []);
        lockedIds.addAll(list);
      }
      return lockedIds.toList();
    });
  }

  /// Stream a map of Section -> List of locked experiment IDs
  Stream<Map<String, List<String>>> streamSectionLocks(List<String> sections) {
    if (sections.isEmpty) return Stream.value({});
    
    return _db
        .collection('ar_locks')
        .where(FieldPath.documentId, whereIn: sections.take(10).toList())
        .snapshots()
        .map((snap) {
      final Map<String, List<String>> map = {};
      for (final doc in snap.docs) {
        map[doc.id] = List<String>.from(doc.data()['lockedExperiments'] ?? []);
      }
      return map;
    });
  }

  /// Toggle the lock state of an AR experiment for a specific section
  Future<void> toggleExperimentLockForSection(String section, String experimentId, bool lock) async {
    final docRef = _db.collection('ar_locks').doc(section);
    if (lock) {
      await docRef.set({
        'lockedExperiments': FieldValue.arrayUnion([experimentId])
      }, SetOptions(merge: true));
    } else {
      await docRef.set({
        'lockedExperiments': FieldValue.arrayRemove([experimentId])
      }, SetOptions(merge: true));
    }
  }
}
