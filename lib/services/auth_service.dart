import 'dart:async';
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../models/user_model.dart';

/// Firebase-backed authentication service.
///
/// Every new account (student or teacher) starts as
/// VerificationStatus.pending with role == null — an admin reviews it
/// and assigns both the role and approval in one step via
/// [assignRoleAndApprove]. This matches the copy already in
/// sign_up_login_screen.dart: "An admin will approve your registration
/// and assign your role shortly."
class AuthService extends ChangeNotifier {
  /// GoRouter's redirect (in app_routes.dart) reads this same instance,
  /// outside the widget tree — kept as a singleton so Provider and the
  /// router never disagree about auth state.
  static final AuthService instance = AuthService._internal();
  factory AuthService() => instance;

  final fb.FirebaseAuth _auth = fb.FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    clientId: kIsWeb ? 'dummy-client-id.apps.googleusercontent.com' : null,
  );

  AppUser? currentUser;
  bool loading = false;

  StreamSubscription<fb.User?>? _authSub;
  StreamSubscription<DocumentSnapshot<Map<String, dynamic>>>? _userDocSub;
  String? _lastDisplayNameSyncKey;

  AuthService._internal() {
    _authSub = _auth.authStateChanges().listen(_onAuthChanged);
  }

  String _generateStudentNumber() {
    final random = Random();
    final year = DateTime.now().year;
    final randDigits = random.nextInt(90000) + 10000; // 5 digits
    return '$year$randDigits';
  }

  void _onAuthChanged(fb.User? fbUser) {
    _userDocSub?.cancel();
    if (fbUser == null) {
      currentUser = null;
      _lastDisplayNameSyncKey = null;
      notifyListeners();
      return;
    }
    _userDocSub = _db.collection('users').doc(fbUser.uid).snapshots().listen((
      doc,
    ) {
      if (doc.exists) {
        currentUser = AppUser.fromMap(doc.id, doc.data()!);
        _scheduleDisplayNameSync(currentUser!);
      }
      notifyListeners();
    });
  }

  void _scheduleDisplayNameSync(AppUser account) {
    final name = account.name.trim();
    if (name.isEmpty) return;
    final syncKey = '${account.id}|${account.role?.id ?? ''}|$name';
    if (_lastDisplayNameSyncKey == syncKey) return;
    _lastDisplayNameSyncKey = syncKey;
    unawaited(
      _syncDisplayNameReferences(account, name).catchError((Object error) {
        if (_lastDisplayNameSyncKey == syncKey) {
          _lastDisplayNameSyncKey = null;
        }
        debugPrint('Could not reconcile saved display names: $error');
      }),
    );
  }

  bool get isLoggedIn => currentUser != null;
  bool get isApproved => currentUser?.status == VerificationStatus.approved;
  bool get isPending => currentUser != null && !isApproved;

  Future<void> signUp({
    required String name,
    required String email,
    required String password,
    UserRole? role,
    List<String> sections = const [],
  }) async {
    loading = true;
    notifyListeners();
    try {
      final cred = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      final uid = cred.user!.uid;
      final isStudent = role == UserRole.grade9 || role == UserRole.grade10;
      final generatedStudentNumber = isStudent
          ? _generateStudentNumber()
          : null;

      final newUser = AppUser(
        id: uid,
        name: name,
        email: email,
        role: role,
        status: VerificationStatus.pending,
        sections: sections,
        studentNumber: generatedStudentNumber,
      );
      await _db.collection('users').doc(uid).set(newUser.toMap());
      await cred.user?.sendEmailVerification();
    } on fb.FirebaseAuthException catch (e) {
      throw AuthFailure(_friendlyAuthError(e));
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  /// Returns 'teacher' or 'student' (never null) once login succeeds,
  /// matching sign_up_login_screen's `_onLoginSuccess(String role)`
  /// signature. Callers should still check [isApproved] before routing
  /// anywhere — app_routes.dart's redirect enforces this regardless.
  Future<String> login({
    required String email,
    required String password,
  }) async {
    loading = true;
    notifyListeners();
    try {
      final cred = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (cred.user != null && !cred.user!.emailVerified) {
        await _auth.signOut();
        throw AuthFailure('Please verify your email first. Check your inbox.');
      }

      final doc = await _db.collection('users').doc(cred.user!.uid).get();
      final roleData = doc.data()?['role'];

      if (roleData == 'admin') {
        await _auth.signOut();
        throw AuthFailure(
          'Admins must use the separate Admin Web Portal to log in.',
        );
      }

      return roleData == 'teacher' ? 'teacher' : 'student';
    } on fb.FirebaseAuthException catch (e) {
      throw AuthFailure(_friendlyAuthError(e));
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  Future<void> resetPassword(String email) async {
    loading = true;
    notifyListeners();
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } on fb.FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        throw AuthFailure('No user found for that email.');
      }
      throw AuthFailure('Failed to send reset email: ${e.message}');
    } catch (e) {
      throw AuthFailure('An unexpected error occurred.');
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  Future<String?> signInWithGoogle() async {
    loading = true;
    notifyListeners();
    try {
      final googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        return null;
      }

      final googleAuth = await googleUser.authentication;
      final credential = fb.GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCred = await _auth.signInWithCredential(credential);
      final fbUser = userCred.user!;

      final docRef = _db.collection('users').doc(fbUser.uid);
      final doc = await docRef.get();
      String? userRoleStr;
      if (!doc.exists) {
        final newUser = AppUser(
          id: fbUser.uid,
          name: fbUser.displayName ?? '',
          email: fbUser.email ?? '',
          role: null, // Keeps role null so we know it's a new google user
          status: VerificationStatus.pending,
        );
        await docRef.set(newUser.toMap());
        userRoleStr =
            null; // Return null so router redirects to complete profile
      } else {
        // Update name to match Google account if it exists
        if (fbUser.displayName != null && fbUser.displayName!.isNotEmpty) {
          await docRef.update({'name': fbUser.displayName});
        }
        final data = doc.data();
        if (data != null) {
          final roleData = data['role'];
          if (roleData == 'admin') {
            userRoleStr = 'admin';
          } else {
            userRoleStr = roleData == 'teacher' ? 'teacher' : 'student';
          }
        } else {
          userRoleStr = 'student';
        }
      }
      return userRoleStr;
    } on fb.FirebaseAuthException catch (e) {
      throw AuthFailure(_friendlyAuthError(e));
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  Future<void> completeGoogleProfile({
    required String name,
    required String role,
    required List<String> sections,
  }) async {
    final user = _auth.currentUser;
    if (user == null) throw AuthFailure('Not logged in');

    loading = true;
    notifyListeners();
    try {
      final isStudent = role == 'grade9' || role == 'grade10';
      final generatedStudentNumber = isStudent
          ? _generateStudentNumber()
          : null;

      final docRef = _db.collection('users').doc(user.uid);
      await docRef.set({
        'name': name,
        'role': role,
        'sections': sections,
        if (generatedStudentNumber != null)
          'studentNumber': generatedStudentNumber,
      }, SetOptions(merge: true));
      if (currentUser != null) {
        currentUser!.role = UserRoleX.fromId(role);
        currentUser!.sections = sections;
        currentUser!.studentNumber = generatedStudentNumber;
      }
    } catch (e) {
      throw AuthFailure('Failed to complete profile: $e');
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    await _googleSignIn.signOut();
    await _auth.signOut();
  }

  // ---- Admin actions ----
  // Enforced server-side by firestore.rules (only uids in an `admins`
  // collection can actually write these) — hide the entry point
  // client-side too, this is not itself the security boundary.

  /// Every account still waiting on admin review, regardless of what
  /// role they'll eventually get.
  Stream<List<AppUser>> pendingApprovalsStream() {
    return _db
        .collection('users')
        .where('status', isEqualTo: VerificationStatus.pending.id)
        .snapshots()
        .map(
          (snap) =>
              snap.docs.map((d) => AppUser.fromMap(d.id, d.data())).toList(),
        );
  }

  /// Approve an account that already has a role (the normal case, since
  /// the register form lets people pick student/teacher themselves).
  Future<void> approve(AppUser user) => _db
      .collection('users')
      .doc(user.id)
      .update({'status': VerificationStatus.approved.id});

  Future<void> markNotificationsAsRead() async {
    if (currentUser == null) return;
    try {
      await _db.collection('users').doc(currentUser!.id).update({
        'lastNotificationReadAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      debugPrint('Error marking notifications as read: $e');
    }
  }

  Future<void> clearAllNotifications() async {
    if (currentUser == null) return;
    try {
      await _db.collection('users').doc(currentUser!.id).update({
        'notificationsClearedAt': FieldValue.serverTimestamp(),
        'dismissedNotificationIds': <String>[],
      });
      currentUser!.notificationsClearedAt = DateTime.now();
      currentUser!.dismissedNotificationIds = [];
      notifyListeners();
    } catch (e) {
      debugPrint('Error clearing notifications: $e');
    }
  }

  Future<void> dismissNotification(String notificationId) async {
    final user = currentUser;
    if (user == null || notificationId.isEmpty) return;
    if (user.dismissedNotificationIds.contains(notificationId)) return;

    user.dismissedNotificationIds = [
      ...user.dismissedNotificationIds,
      notificationId,
    ];
    notifyListeners();
    try {
      await _db.collection('users').doc(user.id).update({
        'dismissedNotificationIds': FieldValue.arrayUnion([notificationId]),
      });
    } catch (e) {
      user.dismissedNotificationIds = user.dismissedNotificationIds
          .where((id) => id != notificationId)
          .toList(growable: false);
      notifyListeners();
      debugPrint('Error dismissing notification: $e');
    }
  }

  Future<void> acceptTerms() async {
    if (currentUser == null) return;
    loading = true;
    notifyListeners();
    try {
      await _db.collection('users').doc(currentUser!.id).update({
        'hasAcceptedTerms': true,
      });
      currentUser!.hasAcceptedTerms = true;
    } catch (e) {
      debugPrint('Error accepting terms: $e');
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  Future<void> updateName(String newName) async {
    final account = currentUser;
    if (account == null) return;
    final normalizedName = newName.trim();
    if (normalizedName.isEmpty) {
      throw AuthFailure('Name cannot be empty.');
    }
    loading = true;
    notifyListeners();
    try {
      final syncKey = '${account.id}|${account.role?.id ?? ''}|$normalizedName';
      _lastDisplayNameSyncKey = syncKey;
      await _db.collection('users').doc(account.id).update({
        'name': normalizedName,
      });
      final user = _auth.currentUser;
      if (user != null) {
        await user.updateDisplayName(normalizedName);
      }
      if (currentUser?.id == account.id) {
        currentUser!.name = normalizedName;
      }

      try {
        await _syncDisplayNameReferences(account, normalizedName);
      } catch (error) {
        if (_lastDisplayNameSyncKey == syncKey) {
          _lastDisplayNameSyncKey = null;
        }
        // The user profile is the source of truth. Screens resolve names from
        // that document, while these copied fields remain useful offline.
        debugPrint(
          'Profile name saved; reference sync will retry later: $error',
        );
      }
    } catch (e) {
      _lastDisplayNameSyncKey = null;
      debugPrint('Error updating name: $e');
      throw AuthFailure('Failed to update name: $e');
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  Future<void> _syncDisplayNameReferences(
    AppUser account,
    String newName,
  ) async {
    if (account.isTeacher) {
      await _syncTeacherDisplayName(account.id, newName);
    } else if (account.isStudent) {
      await _syncStudentDisplayName(account.id, newName);
    }
  }

  Future<void> _syncTeacherDisplayName(String uid, String newName) async {
    final courseSnapshot = await _db
        .collection('courses')
        .where('teacherUid', isEqualTo: uid)
        .get();
    final courseUpdates =
        <
          MapEntry<
            DocumentReference<Map<String, dynamic>>,
            Map<String, dynamic>
          >
        >[];

    for (final document in courseSnapshot.docs) {
      final update = <String, dynamic>{'teacherName': newName};
      final rawModules = document.data()['modules'];
      if (rawModules is List) {
        update['modules'] = rawModules
            .map((rawModule) {
              if (rawModule is! Map) return rawModule;
              final module = Map<String, dynamic>.from(rawModule);
              final uploaderUid = module['uploadedByUid']?.toString() ?? '';
              if (uploaderUid.isEmpty || uploaderUid == uid) {
                module['uploadedByUid'] = uid;
                module['uploadedByName'] = newName;
              }
              return module;
            })
            .toList(growable: false);
      }
      courseUpdates.add(MapEntry(document.reference, update));
    }
    await _commitNameUpdates(courseUpdates);

    final attachmentSnapshot = await _db
        .collection('module_attachments')
        .where('uploadedByUid', isEqualTo: uid)
        .get();
    await _commitNameUpdates(
      attachmentSnapshot.docs
          .map(
            (document) => MapEntry(document.reference, <String, dynamic>{
              'uploadedByName': newName,
            }),
          )
          .toList(growable: false),
    );
  }

  Future<void> _syncStudentDisplayName(String uid, String newName) async {
    final attemptSnapshot = await _db
        .collection('quiz_attempts')
        .where('studentId', isEqualTo: uid)
        .get();
    await _commitNameUpdates(
      attemptSnapshot.docs
          .map(
            (document) => MapEntry(document.reference, <String, dynamic>{
              'studentName': newName,
            }),
          )
          .toList(growable: false),
    );
  }

  Future<void> _commitNameUpdates(
    List<
      MapEntry<DocumentReference<Map<String, dynamic>>, Map<String, dynamic>>
    >
    updates,
  ) async {
    const batchSize = 400;
    for (var start = 0; start < updates.length; start += batchSize) {
      final end = (start + batchSize < updates.length)
          ? start + batchSize
          : updates.length;
      final batch = _db.batch();
      for (final update in updates.sublist(start, end)) {
        batch.update(update.key, update.value);
      }
      await batch.commit();
    }
  }

  Future<void> updateProfilePicture(
    Uint8List fileBytes,
    String fileName,
  ) async {
    if (currentUser == null) return;
    loading = true;
    notifyListeners();
    try {
      final previousAvatarUrl = currentUser!.avatarUrl;
      final storageRef = firebase_storage.FirebaseStorage.instance
          .ref()
          .child('user_avatars')
          .child(
            '${currentUser!.id}_${DateTime.now().millisecondsSinceEpoch}_$fileName',
          );

      final uploadTask = storageRef.putData(fileBytes);
      final snapshot = await uploadTask;
      final downloadUrl = await snapshot.ref.getDownloadURL();

      await _db.collection('users').doc(currentUser!.id).update({
        'avatarUrl': downloadUrl,
      });

      final user = _auth.currentUser;
      if (user != null) {
        await user.updatePhotoURL(downloadUrl);
      }

      currentUser!.avatarUrl = downloadUrl;

      if (previousAvatarUrl != downloadUrl) {
        await _deleteStoredAvatarBestEffort(previousAvatarUrl);
      }
    } catch (e) {
      debugPrint('Error updating profile picture: $e');
      throw AuthFailure('Failed to update profile picture: $e');
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  Future<void> removeProfilePicture() async {
    if (currentUser == null) return;
    loading = true;
    notifyListeners();

    final previousAvatarUrl = currentUser!.avatarUrl;
    try {
      await _db.collection('users').doc(currentUser!.id).update({
        'avatarUrl': FieldValue.delete(),
      });

      final user = _auth.currentUser;
      if (user != null) {
        try {
          await user.updatePhotoURL(null);
        } catch (e) {
          debugPrint('Failed to clear Firebase Auth profile picture: $e');
        }
      }

      currentUser!.avatarUrl = null;
      await _deleteStoredAvatarBestEffort(previousAvatarUrl);
    } catch (e) {
      debugPrint('Error removing profile picture: $e');
      throw AuthFailure('Failed to remove profile picture: $e');
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  Future<void> _deleteStoredAvatarBestEffort(String? avatarUrl) async {
    if (avatarUrl == null || avatarUrl.trim().isEmpty) return;

    try {
      await firebase_storage.FirebaseStorage.instance
          .refFromURL(avatarUrl)
          .delete();
    } catch (e) {
      // The URL may be external or the old file may already be gone.
      debugPrint('Could not delete previous profile picture file: $e');
    }
  }

  /// For the edge case where role is still null (e.g. first-time Google
  /// sign-in, which doesn't go through the register form) — admin sets
  /// both at once.
  Future<void> assignRoleAndApprove(AppUser user, UserRole role) => _db
      .collection('users')
      .doc(user.id)
      .update({'role': role.id, 'status': VerificationStatus.approved.id});

  Future<void> reject(AppUser user) => _db
      .collection('users')
      .doc(user.id)
      .update({'status': VerificationStatus.rejected.id});

  /// Live roster for the progress-monitoring screens — every approved
  /// Grade 9 / Grade 10 student account.
  Stream<List<AppUser>> studentsStream() {
    return _db
        .collection('users')
        .where('role', whereIn: [UserRole.grade9.id, UserRole.grade10.id])
        .where('status', isEqualTo: VerificationStatus.approved.id)
        .snapshots()
        .map(
          (snap) =>
              snap.docs.map((d) => AppUser.fromMap(d.id, d.data())).toList(),
        );
  }

  /// Counts the total number of approved students in the given sections.
  Future<int> countStudentsInSections(List<String> sections) async {
    if (sections.isEmpty) return 0;

    // array-contains-any limits to 10 elements
    final chunked = sections.take(10).toList();
    try {
      final snapshot = await _db
          .collection('users')
          .where('sections', arrayContainsAny: chunked)
          .where('role', whereIn: [UserRole.grade9.id, UserRole.grade10.id])
          .where('status', isEqualTo: VerificationStatus.approved.id)
          .count()
          .get();
      return snapshot.count ?? 0;
    } catch (e) {
      debugPrint('Error counting students: $e');
      return 0;
    }
  }

  @override
  void dispose() {
    _authSub?.cancel();
    _userDocSub?.cancel();
    super.dispose();
  }

  String _friendlyAuthError(fb.FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
      case 'wrong-password':
      case 'invalid-credential':
        return 'Incorrect email or password.';
      case 'email-already-in-use':
        return 'An account already exists for that email.';
      case 'weak-password':
        return 'Password is too weak — use at least 6 characters.';
      case 'invalid-email':
        return 'That email address looks invalid.';
      case 'account-exists-with-different-credential':
        return 'An account already exists for that email using a '
            'different sign-in method.';
      default:
        return e.message ?? 'Something went wrong. Please try again.';
    }
  }
}

class AuthFailure implements Exception {
  final String message;
  AuthFailure(this.message);
  @override
  String toString() => message;
}
