import 'package:cloud_firestore/cloud_firestore.dart';

/// The role a user selects right after logging in.
enum UserRole { grade9, grade10, teacher }

extension UserRoleX on UserRole {
  String get label {
    switch (this) {
      case UserRole.grade9:
        return 'Grade 9';
      case UserRole.grade10:
        return 'Grade 10';
      case UserRole.teacher:
        return 'Teacher';
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
  DateTime? lastNotificationReadAt;

  AppUser({
    required this.id,
    required this.name,
    required this.email,
    this.role,
    this.status = VerificationStatus.pending,
    this.sections = const [],
    this.lastNotificationReadAt,
  });

  /// Only Teacher accounts require admin sign-off.
  bool get requiresAdminApproval => role == UserRole.teacher;

  bool get isStudent => role == UserRole.grade9 || role == UserRole.grade10;
  bool get isTeacher => role == UserRole.teacher;

  factory AppUser.fromMap(String id, Map<String, dynamic> data) {
    final ts = data['lastNotificationReadAt'];
    return AppUser(
      id: id,
      name: (data['name'] as String?) ?? '',
      email: (data['email'] as String?) ?? '',
      role: UserRoleX.fromId(data['role'] as String?),
      status: VerificationStatusX.fromId(data['status'] as String?),
      sections: List<String>.from(data['sections'] ?? const []),
      lastNotificationReadAt: ts is Timestamp ? ts.toDate() : null,
    );
  }

  Map<String, dynamic> toMap() => {
        'name': name,
        'email': email,
        'role': role?.id,
        'status': status.id,
        'sections': sections,
        'lastNotificationReadAt': lastNotificationReadAt != null ? Timestamp.fromDate(lastNotificationReadAt!) : null,
      };
}
