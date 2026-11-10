import 'package:flutter_test/flutter_test.dart';
import 'package:scilab_flutter_1/models/course_model.dart';
import 'package:scilab_flutter_1/models/user_model.dart';
import 'package:scilab_flutter_1/services/student_quiz_progress.dart';

void main() {
  final student = AppUser(
    id: 'student',
    name: 'Student',
    email: 'student@example.com',
    role: UserRole.grade9,
    sections: ['A'],
  );
  final now = DateTime(2026, 11, 10);
  Course course(
    String id, {
    String grade = 'Grade 9',
    List<String> sections = const ['A'],
    QuizApprovalStatus status = QuizApprovalStatus.approved,
  }) => Course(
    id: id,
    title: id,
    subject: 'Chemistry',
    grade: grade,
    teacherUid: 'teacher',
    teacherName: 'Teacher',
    accentColorValue: 0,
    iconName: 'science',
    sections: sections,
    modules: [],
    quizzes: [
      CourseQuiz(
        id: 'quiz',
        title: 'Quiz',
        questions: [],
        dueDate: now.subtract(const Duration(days: 1)),
        approvalStatus: status,
      ),
    ],
  );
  QuizAttempt attempt(
    String id, {
    String courseId = 'course',
    String studentId = 'student',
    int score = 8,
    DateTime? submittedAt,
  }) => QuizAttempt(
    id: id,
    courseId: courseId,
    quizId: 'quiz',
    quizTitle: 'Quiz',
    studentId: studentId,
    selectedAnswers: [],
    score: score,
    totalQuestions: 10,
    submittedAt: submittedAt,
  );
  StudentQuizProgressData build(
    List<QuizAttempt> attempts,
    List<Course> courses,
  ) => StudentQuizProgressData.build(
    student: student,
    attempts: attempts,
    courses: courses,
    now: now,
  );

  test(
    'new submission updates results and removes the missed quiz in the same update',
    () {
      final courses = [course('course')];
      expect(build([], courses).missed.length, 1);
      final completed = build([attempt('result', submittedAt: now)], courses);
      expect(completed.attempts.single.score, 8);
      expect(completed.missed, isEmpty);
      expect(
        build([
          attempt('result', score: 10, submittedAt: now),
        ], courses).attempts.single.score,
        10,
      );
      expect(build([], courses).missed.length, 1);
    },
  );

  test('latest submissions appear first and other students are excluded', () {
    final results = build([
      attempt('older', submittedAt: now.subtract(const Duration(hours: 1))),
      attempt('undated'),
      attempt('other', studentId: 'other', submittedAt: now),
      attempt('latest', submittedAt: now),
    ], []).attempts;
    expect(results.map((result) => result.id), ['latest', 'older', 'undated']);
  });

  test(
    'completion IDs include the course so one course cannot complete another',
    () {
      final progress = build(
        [attempt('result', courseId: 'one')],
        [course('one'), course('two')],
      );
      expect(progress.missed.single.course.id, 'two');
    },
  );

  test(
    'missed quizzes stay within matching grade and section and approved quizzes',
    () {
      final progress = build([], [
        course('right'),
        course('wrong-grade', grade: 'Grade 10'),
        course('wrong-section', sections: ['B']),
        course('pending', status: QuizApprovalStatus.pending),
      ]);
      expect(progress.missed.map((item) => item.course.id), ['right']);
    },
  );

  test('course updates immediately change missed-quiz calculations', () {
    expect(build([], []).missed, isEmpty);
    expect(build([], [course('new')]).missed.single.course.id, 'new');
    expect(
      build([], [course('new', status: QuizApprovalStatus.rejected)]).missed,
      isEmpty,
    );
  });
}
