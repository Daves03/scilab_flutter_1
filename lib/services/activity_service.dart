import 'dart:async';
import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/activity_model.dart';

enum ActivitySyncStatus { synced, pending, permissionDenied }

/// Logs student activity and maintains a durable outbox for AR completions.
///
/// A completion is saved locally before Firestore is contacted. The outbox is
/// retried after app startup, authentication changes, and connectivity changes.
/// Its original device timestamp is reused on every retry, so a delayed sync
/// does not make an offline completion appear to have happened later.
class ActivityService {
  ActivityService._();

  static final ActivityService instance = ActivityService._();
  factory ActivityService() => instance;

  static const _completionOutboxKey = 'activity_completion_outbox_v1';
  static const _writeTimeout = Duration(seconds: 10);

  final FirebaseFirestore _db = FirebaseFirestore.instance;
  StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;
  StreamSubscription<User?>? _authSubscription;
  Future<void>? _flushInProgress;
  Future<void> _outboxMutation = Future.value();
  bool _initialized = false;

  CollectionReference<Map<String, dynamic>> _experimentsRef(String uid) =>
      _db.collection('users').doc(uid).collection('experiment_activity');

  CollectionReference<Map<String, dynamic>> _modulesRef(String uid) =>
      _db.collection('users').doc(uid).collection('module_activity');

  Future<void> initialize() async {
    if (_initialized) return;
    _initialized = true;

    _connectivitySubscription = Connectivity().onConnectivityChanged.listen(
      (_) => unawaited(flushPendingCompletions()),
    );
    _authSubscription = FirebaseAuth.instance.authStateChanges().listen(
      (_) => unawaited(flushPendingCompletions()),
    );
    unawaited(flushPendingCompletions());
  }

  Future<void> dispose() async {
    await _connectivitySubscription?.cancel();
    await _authSubscription?.cancel();
    _initialized = false;
  }

  Future<void> logExperimentLaunch(String uid, String experimentId) {
    return _experimentsRef(uid).doc(experimentId).set({
      'launchedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Future<ActivitySyncStatus> markExperimentCompleted(
    String uid,
    String experimentId, {
    int? ppeScore,
    List<String>? selectedPpe,
    List<String>? requiredPpe,
    Map<String, dynamic>? rubricScores,
  }) async {
    final completion = _PendingCompletion(
      uid: uid,
      experimentId: experimentId,
      completedAt: DateTime.now().toUtc(),
      ppeScore: ppeScore,
      selectedPpe: selectedPpe,
      requiredPpe: requiredPpe,
      rubricScores: rubricScores,
    );
    await _saveToOutbox(completion);

    final status = await _upload(completion);
    if (status == ActivitySyncStatus.synced) {
      await _removeFromOutbox(completion.key);
    }
    return status;
  }

  Future<void> flushPendingCompletions() {
    final running = _flushInProgress;
    if (running != null) return running;

    final flush = _flushPendingCompletions();
    _flushInProgress = flush;
    return flush.whenComplete(() => _flushInProgress = null);
  }

  Future<void> _flushPendingCompletions() async {
    final currentUid = FirebaseAuth.instance.currentUser?.uid;
    if (currentUid == null) return;

    final pending = await _readOutbox();
    for (final completion in pending.where((item) => item.uid == currentUid)) {
      final status = await _upload(completion);
      if (status == ActivitySyncStatus.synced) {
        await _removeFromOutbox(completion.key);
      }
    }
  }

  Future<ActivitySyncStatus> _upload(_PendingCompletion completion) async {
    if (FirebaseAuth.instance.currentUser?.uid != completion.uid) {
      return ActivitySyncStatus.pending;
    }

    try {
      final connections = await Connectivity().checkConnectivity();
      if (connections.isEmpty ||
          connections.every((result) => result == ConnectivityResult.none)) {
        return ActivitySyncStatus.pending;
      }

      await _experimentsRef(completion.uid)
          .doc(completion.experimentId)
          .set({
            'experimentId': completion.experimentId,
            'completedAt': Timestamp.fromDate(completion.completedAt),
            if (completion.ppeScore != null) 'ppeScore': completion.ppeScore,
            if (completion.selectedPpe != null)
              'selectedPpe': completion.selectedPpe,
            if (completion.requiredPpe != null)
              'requiredPpe': completion.requiredPpe,
            if (completion.rubricScores != null)
              'rubricScores': completion.rubricScores,
            if (completion.rubricScores != null &&
                completion.rubricScores!['total'] is num)
              'score': completion.rubricScores!['total'],
          }, SetOptions(merge: true))
          .timeout(_writeTimeout);
      return ActivitySyncStatus.synced;
    } on FirebaseException catch (error) {
      if (error.code == 'permission-denied') {
        debugPrint(
          'AR completion remains queued because Firestore denied the write.',
        );
        return ActivitySyncStatus.permissionDenied;
      }
      debugPrint('AR completion queued for retry: ${error.code}');
      return ActivitySyncStatus.pending;
    } on TimeoutException {
      debugPrint('AR completion queued while the device is offline.');
      return ActivitySyncStatus.pending;
    } catch (error) {
      debugPrint('AR completion queued for retry: $error');
      return ActivitySyncStatus.pending;
    }
  }

  Future<List<_PendingCompletion>> _readOutbox() async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = prefs.getString(_completionOutboxKey);
    if (encoded == null || encoded.isEmpty) return [];

    try {
      final values = jsonDecode(encoded) as List<dynamic>;
      return values
          .whereType<Map<String, dynamic>>()
          .map(_PendingCompletion.fromJson)
          .toList();
    } catch (error) {
      debugPrint('Could not read the AR completion outbox: $error');
      return [];
    }
  }

  Future<void> _saveToOutbox(_PendingCompletion completion) async {
    await _mutateOutbox((pending) {
      pending.removeWhere((item) => item.key == completion.key);
      pending.add(completion);
    });
  }

  Future<void> _removeFromOutbox(String key) async {
    await _mutateOutbox(
      (pending) => pending.removeWhere((item) => item.key == key),
    );
  }

  Future<void> _mutateOutbox(void Function(List<_PendingCompletion>) mutation) {
    final operation = _outboxMutation.then((_) async {
      final pending = await _readOutbox();
      mutation(pending);
      await _writeOutbox(pending);
    });
    _outboxMutation = operation.catchError((_) {});
    return operation;
  }

  Future<void> _writeOutbox(List<_PendingCompletion> pending) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _completionOutboxKey,
      jsonEncode(pending.map((item) => item.toJson()).toList()),
    );
  }

  Future<void> logModuleOpen(String uid, String moduleId, String moduleTitle) {
    return _modulesRef(uid).doc(moduleId).set({
      'moduleTitle': moduleTitle,
      'openedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Stream<List<ExperimentActivity>> experimentActivityStream(String uid) {
    return _experimentsRef(uid).snapshots().map(
      (snap) => snap.docs
          .map((d) => ExperimentActivity.fromMap(d.id, d.data()))
          .toList(),
    );
  }

  Stream<List<ModuleOpenActivity>> moduleActivityStream(String uid) {
    return _modulesRef(uid).snapshots().map(
      (snap) => snap.docs
          .map((d) => ModuleOpenActivity.fromMap(d.id, d.data()))
          .toList(),
    );
  }
}

class _PendingCompletion {
  const _PendingCompletion({
    required this.uid,
    required this.experimentId,
    required this.completedAt,
    this.ppeScore,
    this.selectedPpe,
    this.requiredPpe,
    this.rubricScores,
  });

  final String uid;
  final String experimentId;
  final DateTime completedAt;
  final int? ppeScore;
  final List<String>? selectedPpe;
  final List<String>? requiredPpe;
  final Map<String, dynamic>? rubricScores;

  String get key => '$uid/$experimentId';

  factory _PendingCompletion.fromJson(Map<String, dynamic> json) {
    return _PendingCompletion(
      uid: json['uid'] as String,
      experimentId: json['experimentId'] as String,
      completedAt: DateTime.parse(json['completedAt'] as String).toUtc(),
      ppeScore: (json['ppeScore'] as num?)?.toInt(),
      selectedPpe: (json['selectedPpe'] as List?)?.cast<String>(),
      requiredPpe: (json['requiredPpe'] as List?)?.cast<String>(),
      rubricScores: json['rubricScores'] is Map
          ? Map<String, dynamic>.from(json['rubricScores'] as Map)
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
    'uid': uid,
    'experimentId': experimentId,
    'completedAt': completedAt.toIso8601String(),
    if (ppeScore != null) 'ppeScore': ppeScore,
    if (selectedPpe != null) 'selectedPpe': selectedPpe,
    if (requiredPpe != null) 'requiredPpe': requiredPpe,
    if (rubricScores != null) 'rubricScores': rubricScores,
  };
}
