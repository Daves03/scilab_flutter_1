import 'package:cloud_firestore/cloud_firestore.dart';

import '../core/course_assignment.dart';
import 'user_model.dart';

class AnnouncementTarget {
  final String grade;
  final List<String> sections;

  const AnnouncementTarget({required this.grade, required this.sections});

  factory AnnouncementTarget.fromMap(Map<String, dynamic> data) {
    return AnnouncementTarget(
      grade: data['grade']?.toString() ?? '',
      sections:
          (data['sections'] as List?)
              ?.map((section) => section.toString())
              .toList() ??
          const [],
    );
  }

  Map<String, dynamic> toMap() => {'grade': grade, 'sections': sections};

  bool matchesStudent(AppUser student) {
    return CourseAssignment.matches(
      studentGrade: student.role?.label,
      studentSections: student.sections,
      courseGrade: grade,
      courseSections: sections,
    );
  }
}

class ClassAnnouncement {
  final String id;
  final String teacherId;
  final String teacherName;
  final String message;
  final List<AnnouncementTarget> targets;
  final List<String> targetStudentIds;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const ClassAnnouncement({
    required this.id,
    required this.teacherId,
    required this.teacherName,
    required this.message,
    required this.targets,
    required this.targetStudentIds,
    this.createdAt,
    this.updatedAt,
  });

  factory ClassAnnouncement.fromMap(String id, Map<String, dynamic> data) {
    final createdAt = data['createdAt'];
    final updatedAt = data['updatedAt'];
    return ClassAnnouncement(
      id: id,
      teacherId: data['teacherId']?.toString() ?? '',
      teacherName: data['teacherName']?.toString() ?? 'Teacher',
      message: data['message']?.toString() ?? '',
      targets: ((data['targets'] as List?) ?? const [])
          .whereType<Map>()
          .map(
            (target) =>
                AnnouncementTarget.fromMap(Map<String, dynamic>.from(target)),
          )
          .toList(),
      targetStudentIds: ((data['targetStudentIds'] as List?) ?? const [])
          .map((id) => id.toString())
          .where((id) => id.isNotEmpty)
          .toList(growable: false),
      createdAt: createdAt is Timestamp ? createdAt.toDate() : null,
      updatedAt: updatedAt is Timestamp ? updatedAt.toDate() : null,
    );
  }

  bool get isEdited => updatedAt != null;

  bool isForStudent(AppUser student) {
    return targets.any((target) => target.matchesStudent(student));
  }
}

enum AnnouncementReactionType {
  like,
  love;

  String get storageValue => switch (this) {
    AnnouncementReactionType.like => 'like',
    AnnouncementReactionType.love => 'love',
  };

  String get label => switch (this) {
    AnnouncementReactionType.like => 'Like',
    AnnouncementReactionType.love => 'Heart',
  };

  static AnnouncementReactionType fromStorageValue(Object? value) {
    return AnnouncementReactionType.values.firstWhere(
      (type) => type.storageValue == value?.toString(),
      orElse: () => AnnouncementReactionType.like,
    );
  }
}

class AnnouncementReaction {
  final String studentId;
  final String studentName;
  final String? avatarUrl;
  final AnnouncementReactionType type;
  final DateTime? reactedAt;

  const AnnouncementReaction({
    required this.studentId,
    required this.studentName,
    this.avatarUrl,
    required this.type,
    this.reactedAt,
  });

  factory AnnouncementReaction.fromMap(
    String studentId,
    Map<String, dynamic> data,
  ) {
    final reactedAt = data['reactedAt'];
    return AnnouncementReaction(
      studentId: studentId,
      studentName: data['studentName']?.toString() ?? 'Student',
      avatarUrl: data['avatarUrl']?.toString(),
      type: AnnouncementReactionType.fromStorageValue(data['type']),
      reactedAt: reactedAt is Timestamp ? reactedAt.toDate() : null,
    );
  }
}
