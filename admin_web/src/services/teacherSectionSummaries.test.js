import assert from 'node:assert/strict';
import test from 'node:test';
import { teacherSectionSummaries } from './teacherSectionSummaries.js';

const catalog = [
  { name: 'A', grade: 'Grade 9' },
  { name: 'A', grade: 'Grade 10' },
  { name: 'B', grade: 'Grade 10' },
  { name: 'Archived', grade: 'Grade 9', isTrashed: true },
];
const students = [
  { role: 'grade9', sections: ['A', 'A'], status: 'approved' },
  { role: 'grade9', sections: ['Section A'], status: 'pending' },
  { role: 'grade9', sections: ['A'], status: 'rejected' },
  { role: 'grade10', sections: ['A'], status: 'approved' },
  { role: 'grade10', sections: ['B'], status: 'approved' },
  { role: 'teacher', sections: ['A'], status: 'approved' },
  { role: 'admin', sections: ['A'], status: 'approved' },
];

test('counts each student once per assigned grade and section, with status breakdowns', () => {
  const summaries = teacherSectionSummaries(['A', 'B', 'A'], catalog, students);
  assert.deepEqual(summaries.map(({ name, grade, total, approved, pending, rejected }) => ({ name, grade, total, approved, pending, rejected })), [
    { name: 'A', grade: 'Grade 9', total: 3, approved: 1, pending: 1, rejected: 1 },
    { name: 'A', grade: 'Grade 10', total: 1, approved: 1, pending: 0, rejected: 0 },
    { name: 'B', grade: 'Grade 10', total: 1, approved: 1, pending: 0, rejected: 0 },
  ]);
});

test('grade-prefixed assignments do not include the same section in another grade', () => {
  const summaries = teacherSectionSummaries(['9-A'], catalog, students);
  assert.equal(summaries.length, 1);
  assert.equal(summaries[0].grade, 'Grade 9');
  assert.equal(summaries[0].total, 3);
});

test('shows empty assigned sections and skips archived and unassigned sections', () => {
  const summaries = teacherSectionSummaries(['B', 'Archived'], catalog, []);
  assert.equal(summaries.length, 1);
  assert.equal(summaries[0].name, 'B');
  assert.equal(summaries[0].total, 0);
  assert.deepEqual(teacherSectionSummaries([], catalog, students), []);
});

test('supports assignments without catalog entries and uses their embedded grade', () => {
  const summaries = teacherSectionSummaries(['9-A'], [], students);
  assert.equal(summaries[0].grade, 'Grade 9');
  assert.equal(summaries[0].total, 3);
});
