import test from 'node:test';
import assert from 'node:assert/strict';
import { activityUserSections, matchesActivityUser } from './activityLogFilters.js';

const catalog = [{ name: 'A', grade: 'Grade 9' }, { name: 'X', grade: 'Grade 10' }];

test('student role includes both grade roles and composes with grade and section', () => {
  const grade9 = { role: 'grade9', sections: ['A'] };
  const grade10 = { role: 'grade10', sections: ['X'] };
  assert.equal(matchesActivityUser(grade9, { role: 'student' }, catalog), true);
  assert.equal(matchesActivityUser(grade10, { role: 'student' }, catalog), true);
  assert.equal(matchesActivityUser(grade9, { role: 'student', grade: 'Grade 9', section: 'A' }, catalog), true);
  assert.equal(matchesActivityUser(grade9, { grade: 'Grade 10' }, catalog), false);
  assert.equal(matchesActivityUser(grade10, { section: 'A' }, catalog), false);
  assert.equal(matchesActivityUser(grade9, { role: 'teacher' }, catalog), false);
});

test('teachers match handled grades and sections only within the selected grade', () => {
  const teacher = { role: 'teacher', sections: ['A', 'X'] };
  assert.equal(matchesActivityUser(teacher, { role: 'teacher', grade: 'Grade 9', section: 'A' }, catalog), true);
  assert.equal(matchesActivityUser(teacher, { role: 'teacher', grade: 'Grade 10', section: 'X' }, catalog), true);
  assert.equal(matchesActivityUser(teacher, { grade: 'Grade 9', section: 'X' }, catalog), false);
  assert.equal(matchesActivityUser(teacher, { role: 'student' }, catalog), false);
  assert.deepEqual(activityUserSections(teacher, 'Grade 9', catalog), ['A']);
  assert.equal(matchesActivityUser({ role: 'teacher', sections: ['9-A'] }, { grade: 'Grade 9', section: '9-A' }), true);
});

test('all filters preserve administrators and missing profiles without assigning a grade or section', () => {
  for (const user of [{ role: 'admin' }, {}]) {
    assert.equal(matchesActivityUser(user, {}), true);
    assert.equal(matchesActivityUser(user, { role: 'student' }), false);
    assert.equal(matchesActivityUser(user, { grade: 'Grade 9' }), false);
    assert.equal(matchesActivityUser(user, { section: 'A' }), false);
  }
});
