export const AR_RUBRIC_CRITERIA = [
  ['ppe', 'PPE and Safety', 25],
  ['procedureSequenceEquipment', 'Procedure, Sequence & Equipment Handling', 25],
  ['experimentalResult', 'Experimental Results', 25],
  ['scientificUnderstanding', 'Scientific Understanding', 25],
];

const numeric = (value) => typeof value === 'number' && Number.isFinite(value);
const clamp = (value, maximum) => Math.max(0, Math.min(maximum, value));

export function isGradedArRecord(record) {
  const ids = [record.experimentId, record.id].filter((id) => id != null)
    .map((id) => String(id).trim().toLowerCase());
  return !ids.some((id) => id === 'ar8' || id === '8');
}

// Match the Flutter progress conversion without rewriting historical records.
export function normalizeArRubric(scores = {}) {
  const result = Object.fromEntries(Object.entries(scores || {})
    .filter(([, value]) => numeric(value)).map(([key, value]) => [key, Math.trunc(value)]));
  if (!Object.hasOwn(result, 'procedureSequenceEquipment')
    && (Object.hasOwn(result, 'procedureAndSequence') || Object.hasOwn(result, 'equipmentHandling'))) {
    result.ppe = Math.round((result.ppe ?? 0) * 25 / 15);
    result.procedureSequenceEquipment = Math.round(((result.procedureAndSequence ?? 0) + (result.equipmentHandling ?? 0)) * 25 / 55);
    result.experimentalResult = Math.round((result.experimentalResult ?? 0) * 25 / 20);
    result.scientificUnderstanding = Math.round((result.scientificUnderstanding ?? 0) * 25 / 10);
    result.legacyConverted = 1;
  }
  AR_RUBRIC_CRITERIA.forEach(([key, , maximum]) => {
    if (Object.hasOwn(result, key)) result[key] = clamp(result[key], maximum);
  });
  if (AR_RUBRIC_CRITERIA.every(([key]) => Object.hasOwn(result, key))) {
    result.total = AR_RUBRIC_CRITERIA.reduce((total, [key]) => total + result[key], 0);
  }
  return result;
}

export function arRecordScore(record) {
  if (!isGradedArRecord(record)) return null;
  const scores = normalizeArRubric(record.rubricScores);
  const value = scores.total ?? record.score ?? record.rubricScore;
  if (value != null && Number.isFinite(Number(value))) return clamp(Number(value), 100);
  return record.completed === true || record.completedAt ? 100 : 0;
}

export function arPerformanceLevel(score) {
  if (score >= 90) return 'Excellent';
  if (score >= 80) return 'Proficient';
  if (score >= 70) return 'Developing';
  return 'Needs support';
}
