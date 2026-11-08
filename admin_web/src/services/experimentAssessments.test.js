import test from 'node:test';
import assert from 'node:assert/strict';
import { prepareExperimentAssessment, validateExperimentAssessment, assessmentFieldsForSave } from './experimentAssessments.js';

test('all existing experiments open with valid editable defaults', () => {
  for (let id = 1; id <= 8; id++) {
    const experiment = prepareExperimentAssessment({ id: `ar${id}` });
    assert.equal(validateExperimentAssessment(experiment), '');
    assert.equal(experiment.assessmentQuestions.length, 5);
  }
});

test('a teacher can save custom PPE choices and correct selections', () => {
  const experiment = prepareExperimentAssessment({ id: 'ar1' });
  experiment.ppeAssessment = {
    options: [{ id: 'teacher_ppe', label: 'Custom protection', reason: 'Teacher feedback.' }],
    requiredIds: ['teacher_ppe'],
  };
  const saved = assessmentFieldsForSave(experiment);
  assert.deepEqual(saved.ppeAssessment, experiment.ppeAssessment);
  experiment.ppeAssessment.requiredIds.push('removed_choice');
  assert.match(validateExperimentAssessment(experiment), /must be present/);
});

test('question limits are enforced when saving, including bypassed UI limits', () => {
  const experiment = prepareExperimentAssessment({ id: 'ar2' });
  const question = structuredClone(experiment.assessmentQuestions[0]);
  experiment.assessmentQuestions = Array.from({ length: 4 }, () => structuredClone(question));
  assert.throws(() => assessmentFieldsForSave(experiment), /5–10/);
  experiment.assessmentQuestions = Array.from({ length: 10 }, () => structuredClone(question));
  assert.equal(assessmentFieldsForSave(experiment).assessmentQuestions.length, 10);
  experiment.assessmentQuestions.push(question);
  assert.throws(() => assessmentFieldsForSave(experiment), /5–10/);
});

test('correct answers can change, but blank, duplicate, or unkeyed questions cannot save', () => {
  const experiment = prepareExperimentAssessment({ id: 'ar3' });
  experiment.assessmentQuestions[0].correctOption = 3;
  assert.equal(assessmentFieldsForSave(experiment).assessmentQuestions[0].correctOption, 3);
  experiment.assessmentQuestions[0].correctOption = -1;
  assert.match(validateExperimentAssessment(experiment), /correct answer/);
  experiment.assessmentQuestions[0].correctOption = 0;
  experiment.assessmentQuestions[0].options[1] = experiment.assessmentQuestions[0].options[0];
  assert.match(validateExperimentAssessment(experiment), /different answer/);
  experiment.assessmentQuestions[0].prompt = ' ';
  assert.match(validateExperimentAssessment(experiment), /question 1/);
});

test('editing one experiment does not mutate another experiment or its defaults', () => {
  const first = prepareExperimentAssessment({ id: 'ar1' });
  const second = prepareExperimentAssessment({ id: 'ar1' });
  first.ppeAssessment.options[0].label = 'Changed';
  first.assessmentQuestions[0].prompt = 'Changed';
  assert.notEqual(second.ppeAssessment.options[0].label, 'Changed');
  assert.notEqual(second.assessmentQuestions[0].prompt, 'Changed');
});
