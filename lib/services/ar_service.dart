import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import '../models/ar_experiment_model.dart';
import '../data/dummy_ar_experiments.dart';

class ArService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  static const _collection = 'ar_experiments';
  static const _periodicTableId = 'ar8';
  static const _periodicTableThumbnail =
      'assets/images/ar_periodic_table_thumbnail.png';

  bool get _isSignedIn => FirebaseAuth.instance.currentUser != null;

  ArExperimentModel _withBundledPeriodicTableThumbnail(
    ArExperimentModel experiment,
  ) {
    if (experiment.id != _periodicTableId ||
        experiment.thumbnailUrl == _periodicTableThumbnail) {
      return experiment;
    }
    return ArExperimentModel(
      id: experiment.id,
      title: experiment.title,
      topic: experiment.topic,
      category: experiment.category,
      backgroundInfo: experiment.backgroundInfo,
      safetyNote: experiment.safetyNote,
      relatedConcepts: experiment.relatedConcepts,
      requiredMaterials: experiment.requiredMaterials,
      thumbnailUrl: _periodicTableThumbnail,
      iconName: experiment.iconName,
      tintColorValue: experiment.tintColorValue,
      semanticLabel: experiment.semanticLabel,
      steps: experiment.steps,
    );
  }

  Stream<List<ArExperimentModel>> experimentsStream() async* {
    if (!_isSignedIn) {
      yield dummyArExperiments;
      return;
    }
    try {
      await for (final snap in _db.collection(_collection).snapshots()) {
        final exps = snap.docs
            .map((d) => ArExperimentModel.fromMap(d.id, d.data()))
            .map(_withBundledPeriodicTableThumbnail)
            .toList();

        // Merge Firestore experiments with our local dummy experiments
        final List<ArExperimentModel> merged = [...exps];
        for (var dummy in dummyArExperiments) {
          if (!merged.any((e) => e.id == dummy.id)) {
            merged.add(dummy);
          }
        }
        yield merged;
      }
    } catch (error) {
      // Firestore closes authenticated listeners when logout clears the token.
      // That is an expected lifecycle event, not an application error.
      if (_isSignedIn) {
        debugPrint('AR Service fallback due to error: $error');
      }
      yield dummyArExperiments;
    }
  }

  Future<List<ArExperimentModel>> fetchExperiments() async {
    final snap = await _db.collection(_collection).get();
    return snap.docs
        .map((d) => ArExperimentModel.fromMap(d.id, d.data()))
        .map(_withBundledPeriodicTableThumbnail)
        .toList();
  }

  Future<void> addExperiment(ArExperimentModel experiment) async {
    await _db
        .collection(_collection)
        .doc(experiment.id)
        .set(experiment.toMap());
  }

  Future<void> updateExperiment(ArExperimentModel experiment) async {
    await _db
        .collection(_collection)
        .doc(experiment.id)
        .update(experiment.toMap());
  }

  Future<void> deleteExperiment(String id) async {
    await _db.collection(_collection).doc(id).delete();
  }

  /// Stream locked experiment IDs for a specific set of sections.
  Stream<List<String>> streamLockedExperimentsForSections(
    List<String> sections,
  ) async* {
    if (sections.isEmpty || !_isSignedIn) {
      yield const [];
      return;
    }

    try {
      await for (final snap
          in _db
              .collection('ar_locks')
              .where(FieldPath.documentId, whereIn: sections.take(10).toList())
              .snapshots()) {
        final lockedIds = <String>{};
        for (final doc in snap.docs) {
          final list = List<String>.from(
            doc.data()['lockedExperiments'] ?? const [],
          );
          lockedIds.addAll(list);
        }
        yield lockedIds.toList();
      }
    } catch (error) {
      if (_isSignedIn) {
        debugPrint('AR lock fallback due to error: $error');
      }
      // If locks cannot be read, keep the catalogue usable and default to
      // unlocked instead of leaking an unhandled Firestore stream error.
      yield const [];
    }
  }

  /// Stream a map of Section -> List of locked experiment IDs
  Stream<Map<String, List<String>>> streamSectionLocks(
    List<String> sections,
  ) async* {
    if (sections.isEmpty || !_isSignedIn) {
      yield const {};
      return;
    }

    try {
      await for (final snap
          in _db
              .collection('ar_locks')
              .where(FieldPath.documentId, whereIn: sections.take(10).toList())
              .snapshots()) {
        final map = <String, List<String>>{};
        for (final doc in snap.docs) {
          map[doc.id] = List<String>.from(
            doc.data()['lockedExperiments'] ?? const [],
          );
        }
        yield map;
      }
    } catch (error) {
      if (_isSignedIn) {
        debugPrint('AR section-lock fallback due to error: $error');
      }
      yield const {};
    }
  }

  /// Toggle the lock state of an AR experiment for a specific section
  Future<void> toggleExperimentLockForSection(
    String section,
    String experimentId,
    bool lock,
  ) async {
    final docRef = _db.collection('ar_locks').doc(section);
    if (lock) {
      await docRef.set({
        'lockedExperiments': FieldValue.arrayUnion([experimentId]),
      }, SetOptions(merge: true));
    } else {
      await docRef.set({
        'lockedExperiments': FieldValue.arrayRemove([experimentId]),
      }, SetOptions(merge: true));
    }
  }
}
