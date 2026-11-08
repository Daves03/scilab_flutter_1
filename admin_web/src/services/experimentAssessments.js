import defaults from '../data/experimentAssessmentDefaults.json' with { type: 'json' };

export const MIN_EXPERIMENT_QUESTIONS = 5;
export const MAX_EXPERIMENT_QUESTIONS = 10;

export function prepareExperimentAssessment(experiment) {
  const id = String(experiment.id || experiment._docId || '').replace(/\D/g, '');
  const ppe = experiment.ppeAssessment;
  return {
    ...experiment,
    ppeAssessment: structuredClone(ppe && Array.isArray(ppe.options) && Array.isArray(ppe.requiredIds) ? ppe : {
      options: defaults.ppeOptions,
      requiredIds: defaults.requiredPpeByExperiment[id] || [],
    }),
    assessmentQuestions: structuredClone(Array.isArray(experiment.assessmentQuestions)
      ? experiment.assessmentQuestions
      : defaults.questionsByExperiment[id] || defaults.questionsByExperiment['1']),
  };
}

export function validateExperimentAssessment(experiment) {
  const ppe = experiment.ppeAssessment;
  if (!ppe || !Array.isArray(ppe.options) || !ppe.options.length || !Array.isArray(ppe.requiredIds)) {
    return 'Add at least one PPE choice.';
  }
  const ids = new Set();
  const labels = new Set();
  for (const option of ppe.options) {
    if (!option || typeof option.id !== 'string' || !option.id.trim() || ids.has(option.id.trim())) {
      return 'PPE choices must have unique identifiers. Remove and add the duplicate choice again.';
    }
    ids.add(option.id.trim());
    if (typeof option.label !== 'string' || !option.label.trim() || typeof option.reason !== 'string' || !option.reason.trim()) {
      return 'Give every PPE choice a name and feedback explanation.';
    }
    const label = option.label.trim().toLowerCase();
    if (labels.has(label)) return 'Give each PPE choice a different name.';
    labels.add(label);
  }
  if (ppe.requiredIds.some((id) => typeof id !== 'string' || !ids.has(id.trim()))) {
    return 'Every correct PPE selection must be present in the choice list.';
  }
  const questions = experiment.assessmentQuestions;
  if (!Array.isArray(questions) || questions.length < MIN_EXPERIMENT_QUESTIONS || questions.length > MAX_EXPERIMENT_QUESTIONS) {
    return `The mini quiz must have ${MIN_EXPERIMENT_QUESTIONS}–${MAX_EXPERIMENT_QUESTIONS} questions.`;
  }
  for (const [index, question] of questions.entries()) {
    if (!question || typeof question.prompt !== 'string' || !question.prompt.trim()) {
      return `Enter the text for question ${index + 1}.`;
    }
    if (!Array.isArray(question.options) || question.options.length !== 4 || question.options.some((choice) => typeof choice !== 'string' || !choice.trim())) {
      return `Question ${index + 1} needs four non-empty answer choices.`;
    }
    if (new Set(question.options.map((choice) => choice.trim().toLowerCase())).size !== 4) {
      return `Question ${index + 1} needs four different answer choices.`;
    }
    if (!Number.isInteger(question.correctOption) || question.correctOption < 0 || question.correctOption > 3) {
      return `Select the correct answer for question ${index + 1}.`;
    }
  }
  return '';
}

export function assessmentFieldsForSave(experiment) {
  const error = validateExperimentAssessment(experiment);
  if (error) throw new Error(error);
  return {
    ppeAssessment: {
      options: experiment.ppeAssessment.options.map(({ id, label, reason }) => ({ id: id.trim(), label: label.trim(), reason: reason.trim() })),
      requiredIds: [...new Set(experiment.ppeAssessment.requiredIds.map((id) => id.trim()))],
    },
    assessmentQuestions: experiment.assessmentQuestions.map(({ prompt, options, correctOption }) => ({
      prompt: prompt.trim(), options: options.map((choice) => choice.trim()), correctOption,
    })),
  };
}
