import 'package:flutter_test/flutter_test.dart';
import 'package:scilab_flutter_1/core/course_assignment.dart';
import 'package:scilab_flutter_1/models/course_model.dart';

void main() {
  group('CourseAssignment.matches', () {
    test('matches the same grade and section', () {
      expect(
        CourseAssignment.matches(
          studentGrade: 'Grade 9',
          studentSections: const ['A'],
          courseGrade: 'Grade 9',
          courseSections: const ['A'],
        ),
        isTrue,
      );
    });

    test('rejects a different grade even when the section is the same', () {
      expect(
        CourseAssignment.matches(
          studentGrade: 'Grade 9',
          studentSections: const ['A'],
          courseGrade: 'Grade 10',
          courseSections: const ['A'],
        ),
        isFalse,
      );
    });

    test('rejects a different section in the same grade', () {
      expect(
        CourseAssignment.matches(
          studentGrade: 'Grade 9',
          studentSections: const ['A'],
          courseGrade: 'Grade 9',
          courseSections: const ['B'],
        ),
        isFalse,
      );
    });

    test('does not partially match similar section names', () {
      expect(
        CourseAssignment.matches(
          studentGrade: 'Grade 9',
          studentSections: const ['A'],
          courseGrade: 'Grade 9',
          courseSections: const ['AA'],
        ),
        isFalse,
      );
    });

    test('matches any intersection across multiple sections', () {
      expect(
        CourseAssignment.matches(
          studentGrade: 'grade9',
          studentSections: const ['A', 'B'],
          courseGrade: '9',
          courseSections: const ['C', 'B'],
        ),
        isTrue,
      );
    });

    test('returns only the sections that belong to the student', () {
      expect(
        CourseAssignment.matchingStudentSectionLabels(
          studentGrade: 'Grade 9',
          studentSections: const ['B'],
          courseGrade: 'Grade 9',
          courseSections: const ['A', 'B', 'C'],
        ),
        ['B'],
      );
    });

    test('uses the student section label for a legacy course assignment', () {
      expect(
        CourseAssignment.matchingStudentSectionLabels(
          studentGrade: 'Grade 10',
          studentSections: const ['Section X'],
          courseGrade: 'Grade 10',
          courseSections: const ['10-X', '10-Y'],
        ),
        ['X'],
      );
    });

    test('normalizes case, whitespace, and section prefixes', () {
      expect(
        CourseAssignment.matches(
          studentGrade: 'Grade 9',
          studentSections: const [' section a '],
          courseGrade: 'Grade 9',
          courseSections: const ['A'],
        ),
        isTrue,
      );
    });

    test('matches catalog X with legacy 10-X', () {
      expect(
        CourseAssignment.matches(
          studentGrade: 'Grade 10',
          studentSections: const ['X'],
          courseGrade: 'Grade 10',
          courseSections: const ['10-X'],
        ),
        isTrue,
      );
    });

    test('matches Grade 10 - X with Section X', () {
      expect(
        CourseAssignment.matches(
          studentGrade: 'Grade 10',
          studentSections: const ['Section X'],
          courseGrade: 'Grade 10',
          courseSections: const ['Grade 10 - X'],
        ),
        isTrue,
      );
    });

    test('normalizes a Unicode dash in a legacy section', () {
      expect(
        CourseAssignment.matches(
          studentGrade: 'Grade 10',
          studentSections: const ['X'],
          courseGrade: 'Grade 10',
          courseSections: const ['10–X'],
        ),
        isTrue,
      );
    });

    test('rejects a section carrying a conflicting embedded grade', () {
      expect(
        CourseAssignment.matches(
          studentGrade: 'Grade 9',
          studentSections: const ['A'],
          courseGrade: 'Grade 9',
          courseSections: const ['10-A'],
        ),
        isFalse,
      );
    });

    test('fails closed when either side has no section assignment', () {
      expect(
        CourseAssignment.matches(
          studentGrade: 'Grade 9',
          studentSections: const [],
          courseGrade: 'Grade 9',
          courseSections: const ['A'],
        ),
        isFalse,
      );
      expect(
        CourseAssignment.matches(
          studentGrade: 'Grade 9',
          studentSections: const ['A'],
          courseGrade: 'Grade 9',
          courseSections: const [],
        ),
        isFalse,
      );
    });

    test('fails closed for an invalid or missing grade', () {
      expect(
        CourseAssignment.matches(
          studentGrade: null,
          studentSections: const ['A'],
          courseGrade: 'Grade 9',
          courseSections: const ['A'],
        ),
        isFalse,
      );
    });
  });

  test('Course reads legacy assignedSections when sections are absent', () {
    final course = Course.fromMap('legacy-course', {
      'title': 'Legacy Course',
      'subject': 'Chemistry',
      'grade': 'Grade 10',
      'teacherUid': 'teacher-id',
      'teacherName': 'Teacher',
      'assignedSections': ['10-X'],
    });

    expect(course.sections, ['10-X']);
  });

  test('current sections take precedence over legacy assignedSections', () {
    final course = Course.fromMap('current-course', {
      'title': 'Current Course',
      'subject': 'Chemistry',
      'grade': 'Grade 9',
      'teacherUid': 'teacher-id',
      'teacherName': 'Teacher',
      'sections': ['B'],
      'assignedSections': ['A'],
    });

    expect(course.sections, ['B']);
  });
}
