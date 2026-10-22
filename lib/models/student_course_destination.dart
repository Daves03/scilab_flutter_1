import 'course_model.dart';

/// Identifies the exact student course content that should open after
/// navigating from the dashboard.
class StudentCourseDestination {
  const StudentCourseDestination({
    required this.course,
    this.quizId,
    this.initialTabIndex = 0,
  });

  final Course course;
  final String? quizId;
  final int initialTabIndex;
}
