import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/class_announcement_model.dart';
import '../models/user_model.dart';

class AnnouncementService {
  AnnouncementService({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _announcements =>
      _firestore.collection('class_announcements');

  Future<void> createAnnouncement({
    required AppUser teacher,
    required String message,
    required List<AnnouncementTarget> targets,
    required List<String> targetStudentIds,
  }) async {
    final normalizedMessage = message.trim();
    final uniqueStudentIds = targetStudentIds
        .map((id) => id.trim())
        .where((id) => id.isNotEmpty)
        .toSet()
        .toList(growable: false);
    if (normalizedMessage.isEmpty ||
        targets.isEmpty ||
        uniqueStudentIds.isEmpty) {
      throw StateError('Select at least one student audience.');
    }

    final targetGrades = <String>{};
    for (final target in targets) {
      final grade = target.grade.trim();
      if (grade.isEmpty) continue;
      targetGrades.add(grade);
      final gradeNumber = RegExp(r'(9|10)').firstMatch(grade)?.group(1);
      if (gradeNumber != null) targetGrades.add('grade$gradeNumber');
    }

    await _announcements.add({
      'teacherId': teacher.id,
      'teacherName': teacher.name,
      'message': normalizedMessage,
      'targets': targets.map((target) => target.toMap()).toList(),
      'targetGrades': targetGrades.toList(),
      'targetStudentIds': uniqueStudentIds,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> updateAnnouncementMessage({
    required ClassAnnouncement announcement,
    required AppUser teacher,
    required String message,
  }) async {
    final normalizedMessage = message.trim();
    if (normalizedMessage.isEmpty) {
      throw StateError('Enter an announcement first.');
    }
    if (normalizedMessage.length > 500) {
      throw StateError('Announcements cannot exceed 500 characters.');
    }
    if (teacher.id != announcement.teacherId) {
      throw StateError('You can only edit your own announcements.');
    }

    final announcementReference = _announcements.doc(announcement.id);
    await _firestore.runTransaction((transaction) async {
      final current = await transaction.get(announcementReference);
      if (!current.exists) {
        throw StateError('This announcement no longer exists.');
      }
      if (current.data()?['teacherId']?.toString() != teacher.id) {
        throw StateError('You can only edit your own announcements.');
      }

      transaction.update(announcementReference, {
        'message': normalizedMessage,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    });
  }

  Stream<List<ClassAnnouncement>> announcementsForTeacher(String teacherId) {
    return _announcements
        .where('teacherId', isEqualTo: teacherId)
        .snapshots()
        .map((snapshot) {
          final announcements = snapshot.docs
              .map(
                (document) =>
                    ClassAnnouncement.fromMap(document.id, document.data()),
              )
              .where((announcement) => announcement.message.isNotEmpty)
              .toList();
          announcements.sort(_newestFirst);
          return announcements;
        });
  }

  Stream<List<ClassAnnouncement>> announcementsForStudent(AppUser student) {
    final role = student.role;
    if (!student.isStudent || role == null || student.sections.isEmpty) {
      return Stream.value(const []);
    }

    return _announcements
        .where('targetStudentIds', arrayContains: student.id)
        .snapshots()
        .map((snapshot) {
          final announcements = snapshot.docs
              .map(
                (document) =>
                    ClassAnnouncement.fromMap(document.id, document.data()),
              )
              .where((announcement) => announcement.isForStudent(student))
              .toList();
          announcements.sort(_newestFirst);
          return announcements;
        });
  }

  Stream<List<AnnouncementReaction>> reactionsForAnnouncement(
    String announcementId,
  ) {
    return _announcements
        .doc(announcementId)
        .collection('reactions')
        .snapshots()
        .map((snapshot) {
          final reactions = snapshot.docs
              .map(
                (document) =>
                    AnnouncementReaction.fromMap(document.id, document.data()),
              )
              .toList();
          reactions.sort((first, second) {
            final firstDate =
                first.reactedAt ?? DateTime.fromMillisecondsSinceEpoch(0);
            final secondDate =
                second.reactedAt ?? DateTime.fromMillisecondsSinceEpoch(0);
            return secondDate.compareTo(firstDate);
          });
          return reactions;
        });
  }

  Future<void> toggleReaction({
    required ClassAnnouncement announcement,
    required AppUser student,
    required AnnouncementReactionType type,
  }) async {
    if (!student.isStudent || !announcement.isForStudent(student)) {
      throw StateError('This announcement is not assigned to the student.');
    }
    if (announcement.targetStudentIds.isNotEmpty &&
        !announcement.targetStudentIds.contains(student.id)) {
      throw StateError('This announcement is not assigned to the student.');
    }

    final reactionReference = _announcements
        .doc(announcement.id)
        .collection('reactions')
        .doc(student.id);

    await _firestore.runTransaction((transaction) async {
      final current = await transaction.get(reactionReference);
      final currentType = current.data()?['type']?.toString();
      if (current.exists && currentType == type.storageValue) {
        transaction.delete(reactionReference);
        return;
      }

      transaction.set(reactionReference, {
        'studentId': student.id,
        'studentName': student.name,
        if (student.avatarUrl != null) 'avatarUrl': student.avatarUrl,
        'type': type.storageValue,
        'reactedAt': FieldValue.serverTimestamp(),
      });
    });
  }

  static int _newestFirst(ClassAnnouncement first, ClassAnnouncement second) {
    final firstDate = first.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
    final secondDate =
        second.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
    return secondDate.compareTo(firstDate);
  }
}
