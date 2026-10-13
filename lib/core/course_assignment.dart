import '../models/course_model.dart';
import '../models/user_model.dart';

/// Centralized rules for deciding whether a course belongs to a student.
///
/// Both grade and section must match. Section names are normalized so current
/// catalog values such as `X` remain compatible with legacy values such as
/// `10-X`, `Section X`, and `Grade 10 - X`.
class CourseAssignment {
  const CourseAssignment._();

  static bool courseMatchesStudent(Course course, AppUser student) {
    return matchingSectionsForStudent(course, student).isNotEmpty;
  }

  /// Returns only the student's own sections that are assigned to [course].
  /// Teacher-handled sections that the student does not belong to are omitted.
  static List<String> matchingSectionsForStudent(
    Course course,
    AppUser student,
  ) {
    if (!student.isStudent) return const [];

    return matchingStudentSectionLabels(
      studentGrade: student.role?.label,
      studentSections: student.sections,
      courseGrade: course.grade,
      courseSections: course.sections,
    );
  }

  static bool matches({
    required String? studentGrade,
    required Iterable<String> studentSections,
    required String? courseGrade,
    required Iterable<String> courseSections,
  }) {
    return matchingStudentSectionLabels(
      studentGrade: studentGrade,
      studentSections: studentSections,
      courseGrade: courseGrade,
      courseSections: courseSections,
    ).isNotEmpty;
  }

  static List<String> matchingStudentSectionLabels({
    required String? studentGrade,
    required Iterable<String> studentSections,
    required String? courseGrade,
    required Iterable<String> courseSections,
  }) {
    final normalizedStudentGrade = _gradeNumber(studentGrade);
    final normalizedCourseGrade = _gradeNumber(courseGrade);

    if (normalizedStudentGrade == null ||
        normalizedCourseGrade == null ||
        normalizedStudentGrade != normalizedCourseGrade) {
      return const [];
    }

    final normalizedCourseSections = _sectionKeys(
      courseSections,
      normalizedCourseGrade,
    );

    if (normalizedCourseSections.isEmpty) return const [];

    final matchingSections = <String>[];
    final matchedKeys = <String>{};

    for (final rawSection in studentSections) {
      final parsed = _parseSection(rawSection);
      if (parsed == null ||
          (parsed.grade != null && parsed.grade != normalizedStudentGrade) ||
          !normalizedCourseSections.contains(parsed.key) ||
          !matchedKeys.add(parsed.key)) {
        continue;
      }

      final label = rawSection
          .trim()
          .replaceFirst(
            RegExp(r'^(?:section|sec\.?)\s*', caseSensitive: false),
            '',
          )
          .trim();
      if (label.isNotEmpty) matchingSections.add(label);
    }

    return matchingSections;
  }

  static int? _gradeNumber(String? value) {
    if (value == null) return null;
    final matches = RegExp(r'\d+').allMatches(value);
    for (final match in matches) {
      final number = int.tryParse(match.group(0)!);
      if (number == 9 || number == 10) return number;
    }
    return null;
  }

  static Set<String> _sectionKeys(
    Iterable<String> sections,
    int expectedGrade,
  ) {
    final keys = <String>{};

    for (final rawSection in sections) {
      final parsed = _parseSection(rawSection);
      if (parsed == null) continue;
      if (parsed.grade != null && parsed.grade != expectedGrade) continue;
      keys.add(parsed.key);
    }

    return keys;
  }

  static _ParsedSection? _parseSection(String rawSection) {
    var value = rawSection.trim().toLowerCase();
    if (value.isEmpty) return null;

    value = value
        .replaceAll(RegExp(r'[\u2013\u2014]'), '-')
        .replaceFirst(RegExp(r'^(?:section|sec\.?)\s*'), '')
        .trim();

    int? embeddedGrade;
    final gradePrefix = RegExp(
      r'^(?:(?:grade|g)\s*)?(9|10)\s*(?:[-:/.]|\s)\s*(.+)$',
    ).firstMatch(value);

    if (gradePrefix != null) {
      embeddedGrade = int.parse(gradePrefix.group(1)!);
      value = gradePrefix.group(2)!.trim();
      value = value
          .replaceFirst(RegExp(r'^(?:section|sec\.?)\s*'), '')
          .trim();
    }

    final key = value.replaceAll(RegExp(r'[^a-z0-9]+'), '');
    if (key.isEmpty) return null;
    return _ParsedSection(key: key, grade: embeddedGrade);
  }
}

class _ParsedSection {
  final String key;
  final int? grade;

  const _ParsedSection({required this.key, required this.grade});
}
