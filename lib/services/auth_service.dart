import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb;
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

  AuthService._internal() {
    _authSub = _auth.authStateChanges().listen(_onAuthChanged);
  }

  void _onAuthChanged(fb.User? fbUser) {
    _userDocSub?.cancel();
    if (fbUser == null) {
      currentUser = null;
      notifyListeners();
      return;
    }
    _userDocSub =
        _db.collection('users').doc(fbUser.uid).snapshots().listen((doc) {
      if (doc.exists) {
        currentUser = AppUser.fromMap(doc.id, doc.data()!);
      }
      notifyListeners();
    });
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
      final newUser = AppUser(
        id: uid,
        name: name,
        email: email,
        role: role,
        status: VerificationStatus.pending,
        sections: sections,
      );
      await _db.collection('users').doc(uid).set(newUser.toMap());
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
  Future<String> login({required String email, required String password}) async {
    loading = true;
    notifyListeners();
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      return currentUser?.role == UserRole.teacher ? 'teacher' : 'student';
    } on fb.FirebaseAuthException catch (e) {
      throw AuthFailure(_friendlyAuthError(e));
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
      if (googleUser == null) { return null; }

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
          role: null,
          status: VerificationStatus.pending,
        );
        await docRef.set(newUser.toMap());
        userRoleStr = 'student';
      } else {
        // Update name to match Google account if it exists
        if (fbUser.displayName != null && fbUser.displayName!.isNotEmpty) {
          await docRef.update({'name': fbUser.displayName});
        }
        final data = doc.data();
        if (data != null) {
          userRoleStr = data['role'] == 'teacher' ? 'teacher' : 'student';
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
        .map((snap) =>
            snap.docs.map((d) => AppUser.fromMap(d.id, d.data())).toList());
  }

  /// Approve an account that already has a role (the normal case, since
  /// the register form lets people pick student/teacher themselves).
  Future<void> approve(AppUser user) => _db
      .collection('users')
      .doc(user.id)
      .update({'status': VerificationStatus.approved.id});

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
        .map((snap) =>
            snap.docs.map((d) => AppUser.fromMap(d.id, d.data())).toList());
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

