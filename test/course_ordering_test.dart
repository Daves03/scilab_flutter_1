import 'package:flutter_test/flutter_test.dart';
import 'package:scilab_flutter_1/models/course_model.dart';

Course course(String id, [DateTime? createdAt]) => Course(
  id: id,
  title: id,
  subject: 'Chemistry',
  grade: 'Grade 9',
  teacherUid: 'teacher',
  teacherName: 'Teacher',
  accentColorValue: 0,
  iconName: 'science',
  sections: [],
  modules: [],
  quizzes: [],
  createdAt: createdAt,
);

void main() {
  test('newest course leads regardless of document ID order', () {
    final courses = [
      course('a', DateTime(2026, 1, 1)),
      course('z', DateTime(2026, 11, 10)),
      course('b', DateTime(2026, 5, 1)),
    ]..sort(Course.newestFirst);
    expect(courses.map((course) => course.id), ['z', 'b', 'a']);
  });
  test('legacy courses without timestamps remain below dated courses', () {
    final courses = [course('legacy'), course('new', DateTime(2026))]
      ..sort(Course.newestFirst);
    expect(courses.map((course) => course.id), ['new', 'legacy']);
  });
  test('tied and missing timestamps have a consistent order', () {
    final courses = [
      course('z'),
      course('b', DateTime(2026)),
      course('a', DateTime(2026)),
      course('y'),
    ]..sort(Course.newestFirst);
    expect(courses.map((course) => course.id), ['a', 'b', 'y', 'z']);
  });
}
