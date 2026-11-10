import 'package:flutter_test/flutter_test.dart';
import 'package:scilab_flutter_1/core/teacher_course_options.dart';

void main() {
  final catalog = [
    {'name': 'A', 'grade': 'Grade 9'},
    {'name': 'B', 'grade': 'Grade 9'},
    {'name': 'X', 'grade': 'Grade 10'},
    {'name': 'Y', 'grade': 'Grade 10', 'isTrashed': true},
  ];
  test('a Grade 9-only teacher has one automatic grade choice', () {
    final options = TeacherCourseOptions(
      teacherSections: ['A', 'B'],
      catalog: catalog,
    );
    expect(options.grades, ['Grade 9']);
    expect(options.sectionsForGrade(options.grades.single), ['A', 'B']);
    expect(options.sectionsForGrade('Grade 10'), isEmpty);
  });
  test(
    'select-all choices stay within the selected grade and assigned sections',
    () {
      final options = TeacherCourseOptions(
        teacherSections: ['B', 'X', 'Y'],
        catalog: catalog,
      );
      expect(options.grades.toSet(), {'Grade 9', 'Grade 10'});
      expect(options.sectionsForGrade('Grade 9'), ['B']);
      expect(options.sectionsForGrade('Grade 10'), ['X']);
    },
  );
  test(
    'legacy grade prefixes restrict assignments to their matching grade',
    () {
      final options = TeacherCourseOptions(
        teacherSections: ['9-A'],
        catalog: [
          ...catalog,
          {'name': 'A', 'grade': 'Grade 10'},
        ],
      );
      expect(options.grades, ['Grade 9']);
      expect(options.sectionsForGrade('Grade 9'), ['A']);
    },
  );
  test('unassigned teachers do not receive unrelated grade choices', () {
    expect(
      TeacherCourseOptions(teacherSections: [], catalog: catalog).grades,
      isEmpty,
    );
  });
}
