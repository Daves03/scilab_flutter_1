import 'package:flutter_test/flutter_test.dart';
import 'package:scilab_flutter_1/models/class_announcement_model.dart';
import 'package:scilab_flutter_1/models/course_model.dart';
import 'package:scilab_flutter_1/models/user_model.dart';

void main() {
  final teacher = AppUser(
    id: 'teacher',
    name: 'Teacher',
    email: 'teacher@example.com',
    role: UserRole.teacher,
    sections: ['9-A', '10-X'],
  );
  AppUser student(
    String id,
    UserRole role,
    List<String> sections, {
    VerificationStatus status = VerificationStatus.approved,
  }) => AppUser(
    id: id,
    name: id,
    email: '$id@example.com',
    role: role,
    sections: sections,
    status: status,
  );

  test(
    'assigned-section students form an announcement audience without courses',
    () {
      final grade9 = student('nine', UserRole.grade9, ['A', 'B']);
      final grade10 = student('ten', UserRole.grade10, ['X']);
      final targets = AnnouncementTarget.forTeacher(
        teacher: teacher,
        students: [grade9, grade10],
      );
      expect(targets.map((target) => target.toMap()), [
        {
          'grade': 'Grade 10',
          'sections': ['X'],
        },
        {
          'grade': 'Grade 9',
          'sections': ['A'],
        },
      ]);
      expect(targets.any((target) => target.matchesStudent(grade9)), isTrue);
      expect(targets.any((target) => target.matchesStudent(grade10)), isTrue);
    },
  );

  test('excludes unrelated grades, sections, and unapproved accounts', () {
    final targets = AnnouncementTarget.forTeacher(
      teacher: teacher,
      students: [
        student('wrong-grade', UserRole.grade10, ['A']),
        student('wrong-section', UserRole.grade9, ['B']),
        student('pending', UserRole.grade9, [
          'A',
        ], status: VerificationStatus.pending),
        student('rejected', UserRole.grade9, [
          'A',
        ], status: VerificationStatus.rejected),
        student('other-teacher', UserRole.teacher, ['A']),
      ],
    );
    expect(targets, isEmpty);
  });

  test('keeps course audiences and deduplicates assigned sections', () {
    final course = Course.fromMap('course', {
      'grade': 'Grade 9',
      'sections': ['A', 'C'],
    });
    final targets = AnnouncementTarget.forTeacher(
      teacher: teacher,
      students: [
        student('one', UserRole.grade9, ['A']),
        student('two', UserRole.grade9, ['A']),
      ],
      courses: [course],
    );
    expect(targets.single.sections, ['A', 'C']);
  });
}
