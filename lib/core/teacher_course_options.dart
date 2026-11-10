import 'course_assignment.dart';

/// Grade and section choices are limited to the teacher's active assignments.
class TeacherCourseOptions {
  final Map<String, List<String>> _sectionsByGrade;

  TeacherCourseOptions({
    required Iterable<String> teacherSections,
    required Iterable<Map<String, dynamic>> catalog,
  }) : _sectionsByGrade = {} {
    for (final section in catalog) {
      final name = section['name']?.toString().trim() ?? '';
      final grade = section['grade']?.toString().trim() ?? '';
      if (section['isTrashed'] == true || name.isEmpty || grade.isEmpty) {
        continue;
      }
      if (!CourseAssignment.matches(
        studentGrade: grade,
        studentSections: [name],
        courseGrade: grade,
        courseSections: teacherSections,
      )) {
        continue;
      }
      final names = _sectionsByGrade.putIfAbsent(grade, () => []);
      if (!names.contains(name)) names.add(name);
    }
    for (final names in _sectionsByGrade.values) {
      names.sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));
    }
  }

  List<String> get grades => _sectionsByGrade.keys.toList()..sort();

  List<String> sectionsForGrade(String grade) =>
      List.unmodifiable(_sectionsByGrade[grade] ?? const <String>[]);
}
