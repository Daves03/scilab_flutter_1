import test from 'node:test';
import assert from 'node:assert/strict';
import { AR_RUBRIC_CRITERIA, arPerformanceLevel, arRecordScore, normalizeArRubric, isGradedArRecord } from './arProgressAssessment.js';

test('periodic table is excluded from scoring even with historical scores', () => {
  for (const id of ['ar8', '8', ' AR8 ']) {
    const record = { id, completedAt: { seconds: 10 }, score: 100, rubricScores: { total: 100 } };
    assert.equal(isGradedArRecord(record), false);
    assert.equal(arRecordScore(record), null);
  }
  assert.equal(isGradedArRecord({ id: 'legacy-id', experimentId: 'ar8' }), false);
  const records = [{ id: 'ar1', score: 80 }, { id: 'ar8', score: 100 }];
  const scores = records.filter(isGradedArRecord).map(arRecordScore);
  assert.deepEqual(scores, [80]);
  assert.equal(isGradedArRecord({ id: 'ar4' }), true);
});

test('current categories total 100 and override stale saved totals', () => {
  assert.equal(AR_RUBRIC_CRITERIA.length, 4);
  assert.equal(AR_RUBRIC_CRITERIA.reduce((sum, [, , max]) => sum + max, 0), 100);
  const record = { score: 100, rubricScores: {
    ppe: 25, procedureSequenceEquipment: 18, experimentalResult: 25,
    scientificUnderstanding: 15, sequenceErrors: 1, equipmentErrors: 1,
    correctUnderstandingAnswers: 3, totalUnderstandingQuestions: 5, total: 100,
  } };
  const scores = normalizeArRubric(record.rubricScores);
  assert.equal(scores.total, 83);
  assert.equal(arRecordScore(record), 83);
  assert.equal(scores.sequenceErrors, 1);
  assert.equal(scores.correctUnderstandingAnswers, 3);
  assert.equal(record.rubricScores.total, 100);
});

test('historical records convert once and total the displayed categories', () => {
  const record = { score: 70, rubricScores: {
    ppe: 15, procedureAndSequence: 20, equipmentHandling: 10,
    experimentalResult: 20, scientificUnderstanding: 5, total: 70,
  } };
  const scores = normalizeArRubric(record.rubricScores);
  assert.deepEqual(AR_RUBRIC_CRITERIA.map(([key]) => scores[key]), [25, 14, 25, 13]);
  assert.equal(scores.total, 77);
  assert.equal(arRecordScore(record), 77);
  assert.equal(scores.legacyConverted, 1);
  assert.deepEqual(normalizeArRubric(scores), scores);
});

test('missing category scores stay unknown and old fallback behavior is preserved', () => {
  assert.deepEqual(normalizeArRubric({ total: 85 }), { total: 85 });
  assert.deepEqual(normalizeArRubric(null), {});
  assert.equal(arRecordScore({ rubricScores: { total: 85 } }), 85);
  assert.equal(arRecordScore({ score: 85 }), 85);
  assert.equal(arRecordScore({ completed: true }), 100);
  assert.equal(arRecordScore({}), 0);
});

test('category scores are bounded and nonnumeric metadata does not become a score', () => {
  const scores = normalizeArRubric({ ppe: 30, procedureSequenceEquipment: -5,
    experimentalResult: 25, scientificUnderstanding: 25,
    performanceLevel: 'Excellent', equipmentErrors: Number.NaN });
  assert.equal(scores.total, 75);
  assert.equal(scores.ppe, 25);
  assert.equal(scores.procedureSequenceEquipment, 0);
  assert.equal(arRecordScore({ score: 110 }), 100);
  assert.equal(arRecordScore({ score: -10 }), 0);
});

test('performance levels match the implemented AR result boundaries', () => {
  for (const [score, expected] of [[100, 'Excellent'], [90, 'Excellent'],
    [89, 'Proficient'], [80, 'Proficient'], [79, 'Developing'],
    [70, 'Developing'], [69, 'Needs support'], [0, 'Needs support']]) {
    assert.equal(arPerformanceLevel(score), expected);
  }
});
