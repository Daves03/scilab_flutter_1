import 'package:cloud_firestore/cloud_firestore.dart';

/// The role a user selects right after logging in.
enum UserRole { grade9, grade10, teacher, admin }

extension UserRoleX on UserRole {
  String get label {
    switch (this) {
      case UserRole.grade9:
        return 'Grade 9';
      case UserRole.grade10:
        return 'Grade 10';
      case UserRole.teacher:
        return 'Teacher';
      case UserRole.admin:
        return 'Admin';
    }
  }

  String get symbol {
    switch (this) {
      case UserRole.grade9:
        return 'G9';
      case UserRole.grade10:
        return 'G10';
      case UserRole.teacher:
        return 'Tc';
      case UserRole.admin:
        return 'Ad';
    }
  }

  /// Stored in Firestore as a plain string, e.g. "grade9".
  String get id => name;

  static UserRole? fromId(String? id) {
    switch (id) {
      case 'grade9':
        return UserRole.grade9;
      case 'grade10':
        return UserRole.grade10;
      case 'teacher':
        return UserRole.teacher;
      case 'admin':
        return UserRole.admin;
      default:
        return null;
    }
  }
}

enum VerificationStatus { pending, approved, rejected }

extension VerificationStatusX on VerificationStatus {
  String get id => name;

  static VerificationStatus fromId(String? id) {
    switch (id) {
      case 'approved':
        return VerificationStatus.approved;
      case 'rejected':
        return VerificationStatus.rejected;
      default:
        return VerificationStatus.pending;
    }
  }
}

/// A user account in the app.
///
/// Mirrors one document in the Firestore `users` collection, keyed by
/// the Firebase Auth uid.
class AppUser {
  final String id;
  final String name;
  final String email;
  UserRole? role;
  VerificationStatus status;
  List<String> sections; // teacher's class sections, e.g. ['9-Rizal', '10-Luna']
  String? studentNumber; // unique identifier for students
  DateTime? lastNotificationReadAt;
  bool hasAcceptedTerms;

  AppUser({
    required this.id,
    required this.name,
    required this.email,
    this.role,
    this.status = VerificationStatus.pending,
    this.sections = const [],
    this.studentNumber,
    this.lastNotificationReadAt,
    this.hasAcceptedTerms = false,
  });

  /// Only Teacher accounts require admin sign-off.
  bool get requiresAdminApproval => role == UserRole.teacher;

  bool get isStudent => role == UserRole.grade9 || role == UserRole.grade10;
  bool get isTeacher => role == UserRole.teacher;
  bool get isAdmin => role == UserRole.admin;

  factory AppUser.fromMap(String id, Map<String, dynamic> data) {
    final ts = data['lastNotificationReadAt'];
    return AppUser(
      id: id,
      name: (data['name'] as String?) ?? '',
      email: (data['email'] as String?) ?? '',
      role: UserRoleX.fromId(data['role'] as String?),
      status: VerificationStatusX.fromId(data['status'] as String?),
      sections: List<String>.from(data['sections'] ?? const []),
      studentNumber: data['studentNumber'] as String?,
      lastNotificationReadAt: ts is Timestamp ? ts.toDate() : null,
      hasAcceptedTerms: data['hasAcceptedTerms'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toMap() => {
        'name': name,
        'email': email,
        'role': role?.id,
        'status': status.id,
        'sections': sections,
        if (studentNumber != null) 'studentNumber': studentNumber,
        'lastNotificationReadAt': lastNotificationReadAt != null ? Timestamp.fromDate(lastNotificationReadAt!) : null,
        'hasAcceptedTerms': hasAcceptedTerms,
      };
}
