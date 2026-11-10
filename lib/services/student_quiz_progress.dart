import '../core/course_assignment.dart';
import '../models/course_model.dart';
import '../models/user_model.dart';

class MissedCourseQuiz {
  final Course course;
  final CourseQuiz quiz;
  const MissedCourseQuiz(this.course, this.quiz);
}

class StudentQuizProgressData {
  final List<QuizAttempt> attempts;
  final List<MissedCourseQuiz> missed;
  const StudentQuizProgressData(this.attempts, this.missed);

  factory StudentQuizProgressData.build({
    required AppUser student,
    required Iterable<QuizAttempt> attempts,
    required Iterable<Course> courses,
    required DateTime now,
  }) {
    final results =
        attempts.where((attempt) => attempt.studentId == student.id).toList()
          ..sort((first, second) {
            final firstDate = first.submittedAt;
            final secondDate = second.submittedAt;
            if (firstDate == null) return secondDate == null ? 0 : 1;
            if (secondDate == null) return -1;
            return secondDate.compareTo(firstDate);
          });
    final completed = {
      for (final attempt in results) '${attempt.courseId}/${attempt.quizId}',
    };
    final missed = <MissedCourseQuiz>[];
    for (final course in courses) {
      if (!CourseAssignment.courseMatchesStudent(course, student)) continue;
      for (final quiz in course.quizzes) {
        if (quiz.isApproved &&
            quiz.dueDate != null &&
            quiz.dueDate!.isBefore(now) &&
            !completed.contains('${course.id}/${quiz.id}')) {
          missed.add(MissedCourseQuiz(course, quiz));
        }
      }
    }
    return StudentQuizProgressData(results, missed);
  }
}
