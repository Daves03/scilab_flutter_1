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
}
