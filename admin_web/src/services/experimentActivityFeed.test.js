import test from 'node:test';
import assert from 'node:assert/strict';
import { createExperimentActivityFeed } from './experimentActivityFeed.js';

function setup() {
  const watchers = new Map();
  const stopped = [];
  const errors = [];
  let logs = [];
  let subscriptionCount = 0;
  const feed = createExperimentActivityFeed({
    watchUser(uid, next, error) {
      subscriptionCount++;
      watchers.set(uid, { next, error });
      return () => stopped.push(uid);
    },
    onChange: (value) => { logs = value; },
    onError: (uid, error) => errors.push({ uid, error }),
  });
  return { feed, watchers, stopped, errors, get logs() { return logs; }, get subscriptionCount() { return subscriptionCount; } };
}

const launch = { toDate: () => new Date('2026-11-12T01:00:00Z') };
const completedAt = { toDate: () => new Date('2026-11-12T01:05:00Z') };

test('student and teacher launches and completions appear without a user profile update', () => {
  const state = setup();
  state.feed.setUsers({ student: { name: 'Student', role: 'grade9' }, teacher: { name: 'Teacher', role: 'teacher' } });
  state.watchers.get('student').next([{ id: 'ar2', data: { launchedAt: launch } }]);
  state.watchers.get('teacher').next([{ id: 'ar2', data: { launchedAt: launch } }]);
  assert.equal(state.logs.length, 2);
  assert.equal(new Set(state.logs.map(log => log.id)).size, 2);
  assert.deepEqual(state.logs.map(log => log.userRole), ['grade9', 'teacher']);

  state.watchers.get('student').next([{ id: 'ar2', data: { launchedAt: launch, completedAt } }]);
  assert.equal(state.logs.length, 3);
  const completed = state.logs.find(log => log.type === 'experiment_complete');
  assert.equal(completed.uid, 'student');
  assert.equal(completed.timestamp.toISOString(), '2026-11-12T01:05:00.000Z');
  state.feed.dispose();
});

test('profile changes refresh names without duplicating subscriptions; removed users and cleanup stop listeners', () => {
  const state = setup();
  state.feed.setUsers({ teacher: { name: 'Old Name', role: 'teacher' } });
  const callback = state.watchers.get('teacher').next;
  callback([{ id: 'ar8', data: { launchedAt: launch } }]);
  state.feed.setUsers({ teacher: { displayName: 'New Name', role: 'teacher' }, student: { role: 'grade10' } });
  assert.equal(state.logs[0].userName, 'New Name');
  assert.equal(state.subscriptionCount, 2);
  state.feed.setUsers({ student: { role: 'grade10' } });
  assert.deepEqual(state.stopped, ['teacher']);
  callback([{ id: 'ar8', data: { launchedAt: launch } }]);
  assert.equal(state.logs.length, 0);
  state.feed.dispose();
  assert.deepEqual(state.stopped, ['teacher', 'student']);
  state.watchers.get('student').next([{ id: 'ar1', data: { launchedAt: launch } }]);
  assert.equal(state.logs.length, 0);
});

test('legacy records, ungraded exploration, and empty records remain usable', () => {
  const state = setup();
  state.feed.setUsers({ student: { email: 'student@example.test' } });
  state.watchers.get('student').next([
    { id: 'ar8', data: { launchedAt: launch } },
    { id: 'ar2', data: { experimentTitle: 'Silver Nitrate', completedAt: '2026-11-12T01:05:00Z' } },
    { id: 'ar1', data: {} },
  ]);
  assert.equal(state.logs.length, 2);
  assert.equal(state.logs[0].title, 'Interactive Periodic Table');
  assert.equal(state.logs[1].title, 'Silver Nitrate');
  assert.equal(state.logs[1].userName, 'student@example.test');
  const error = new Error('permission-denied');
  state.watchers.get('student').error(error);
  assert.deepEqual(state.errors, [{ uid: 'student', error }]);
  assert.equal(state.logs.length, 2);
  state.feed.dispose();
});

test('historical launches and completions resolve names and follow catalog title changes', () => {
  const state = setup();
  state.feed.setUsers({ student: { role: 'grade9' } });
  state.watchers.get('student').next([
    { id: 'ar5', data: { launchedAt: launch, completedAt } },
    { id: '2', data: { launchedAt: launch } },
    { id: 'unknown', data: { launchedAt: launch } },
  ]);
  assert.deepEqual(state.logs.map(log => log.title), [
    'Conductivity Test', 'Conductivity Test', 'Silver Nitrate Precipitation Test', 'unknown',
  ]);
  state.feed.setExperiments([{ id: 'ar5', title: 'Updated Conductivity Experiment' }]);
  assert.deepEqual(state.logs.slice(0, 2).map(log => log.title), [
    'Updated Conductivity Experiment', 'Updated Conductivity Experiment',
  ]);
  state.feed.setExperiments([{ id: 'ar5', title: '  ' }]);
  assert.equal(state.logs[0].title, 'Conductivity Test');
  state.feed.dispose();
});
