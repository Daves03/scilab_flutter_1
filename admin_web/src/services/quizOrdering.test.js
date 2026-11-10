import test from 'node:test';
import assert from 'node:assert/strict';
import { newestQuizFirst, quizzesNewestFirst, modulesNewestFirst, teacherUploadTimeline, teacherUploadGroups } from './quizOrdering.js';

test('course/card groups follow course creation even when older courses get new uploads', () => {
  const groups = teacherUploadGroups([
    { id: 'older', createdAt: { seconds: 1 }, modules: [{ id: 'recent-module', uploadedAt: { seconds: 200 } }], quizzes: [{ id: 'pending', approvalStatus: 'pending', createdAt: { seconds: 100 } }] },
    { id: 'newer', createdAt: { seconds: 2 }, modules: [{ id: 'first', uploadedAt: { seconds: 2 } }, { id: 'latest', uploadedAt: { seconds: 5 } }], quizzes: [{ id: 'approved', approvalStatus: 'approved', createdAt: { seconds: 4 } }] },
  ]);
  assert.deepEqual(groups.map(({ course }) => course.id), ['newer', 'older']);
  assert.deepEqual(groups[0].modules.map(({ item }) => item.id), ['latest', 'first']);
  assert.equal(groups[0].modules[0].index, 1);
  assert.equal(groups[1].quizzes.length, 0);
  assert.equal(groups[0].createdTimestamp, 2000);
});

test('courses with no creation timestamp stay below dated courses regardless of uploads', () => {
  const groups = teacherUploadGroups([
    { id: 'undated', modules: [{ uploadedAt: { seconds: 999 } }] },
    { id: 'course1', createdAt: { seconds: 1 } },
    { id: 'course2', createdAt: { seconds: 2 } },
  ]);
  assert.deepEqual(groups.map(({ course }) => course.id), ['course2', 'course1', 'undated']);
});

test('main uploads show modules and approved quizzes with original archive indices', () => {
  const course = { id: 'course', modules: [{ id: 'module', uploadedAt: { seconds: 1 } }], quizzes: [
    { id: 'pending', approvalStatus: 'pending', createdAt: { seconds: 5 } },
    { id: 'approved', approvalStatus: 'approved', createdAt: { seconds: 4 } },
    { id: 'rejected', approvalStatus: 'rejected', createdAt: { seconds: 3 } },
    { id: 'legacy', createdAt: { seconds: 2 } },
  ] };
  const timeline = teacherUploadTimeline([course]);
  assert.deepEqual(timeline.map(({ item }) => item.id), ['approved', 'legacy', 'module']);
  assert.equal(timeline[0].index, 1);
  assert.equal(course.quizzes[timeline[0].index].id, 'approved');
  course.quizzes[0].approvalStatus = 'approved';
  assert.equal(teacherUploadTimeline([course])[0].item.id, 'pending');
});

test('sorts mixed timestamps newest first and keeps missing dates last', () => {
  const quizzes = [
    { id: 'missing' },
    { id: 'old', createdAt: { seconds: 1 } },
    { id: 'new', createdAt: { toMillis: () => 5000 } },
    { id: 'uploaded', uploadedAt: new Date(3000) },
    { id: 'iso', createdAt: new Date(2000).toISOString() },
  ];
  const result = quizzesNewestFirst(quizzes);
  assert.deepEqual(result.map(({ quiz }) => quiz.id), ['new', 'uploaded', 'iso', 'old', 'missing']);
  assert.deepEqual(result.map(({ index }) => index), [2, 3, 4, 1, 0]);
  assert.equal(quizzes[0].id, 'missing');
});

test('approval rows sort by upload date regardless of review date or course order', () => {
  const rows = [
    { courseId: 'first', quiz: { createdAt: { seconds: 2 }, reviewedAt: { seconds: 99 } } },
    { courseId: 'second', quiz: { createdAt: { seconds: 3 } } },
  ];
  rows.sort((a, b) => newestQuizFirst(a.quiz, b.quiz));
  assert.equal(rows[0].courseId, 'second');
});

test('uses upload date for invalid creation dates and sorts nanoseconds', () => {
  assert.ok(newestQuizFirst({ createdAt: 'invalid', uploadedAt: { seconds: 10 } }, { createdAt: { seconds: 9 } }) < 0);
  assert.ok(newestQuizFirst({ createdAt: { seconds: 5, nanoseconds: 200 } }, { createdAt: { seconds: 5, nanoseconds: 100 } }) < 0);
});

test('modules sort newest first while archive indices still identify the original upload', () => {
  const modules = [
    { title: 'Chemical_Reactions', uploadedAt: { seconds: 1 } },
    { title: 'Latest', uploadedAt: { seconds: 10 } },
    { title: 'Middle', createdAt: { seconds: 5 } },
  ];
  const sorted = modulesNewestFirst(modules);
  assert.deepEqual(sorted.map(({ module }) => module.title), ['Latest', 'Middle', 'Chemical_Reactions']);
  assert.deepEqual(sorted.map(({ index }) => index), [1, 2, 0]);
  assert.equal(modules[0].title, 'Chemical_Reactions');
});

