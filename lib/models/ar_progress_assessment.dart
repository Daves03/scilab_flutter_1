/// The four equally weighted categories used by the current AR assessment.
class ArProgressAssessment {
  static bool isGraded(String experimentId) =>
      !{'8', 'ar8'}.contains(experimentId.trim().toLowerCase());

  static const criteria = [
    ('ppe', 'PPE and Safety'),
    ('procedureSequenceEquipment', 'Procedure, Sequence & Equipment Handling'),
    ('experimentalResult', 'Experimental Results'),
    ('scientificUnderstanding', 'Scientific Understanding'),
  ];

  /// Convert historical category weights for display without changing storage.
  /// A converted total must equal the sum of the displayed categories.
  static Map<String, int> normalize(Map<String, int> scores) {
    final result = Map<String, int>.of(scores);
    final isLegacy =
        !scores.containsKey('procedureSequenceEquipment') &&
        (scores.containsKey('procedureAndSequence') ||
            scores.containsKey('equipmentHandling'));
    if (isLegacy) {
      result['ppe'] = ((scores['ppe'] ?? 0) * 25 / 15).round();
      result['procedureSequenceEquipment'] =
          (((scores['procedureAndSequence'] ?? 0) +
                      (scores['equipmentHandling'] ?? 0)) *
                  25 /
                  55)
              .round();
      result['experimentalResult'] =
          ((scores['experimentalResult'] ?? 0) * 25 / 20).round();
      result['scientificUnderstanding'] =
          ((scores['scientificUnderstanding'] ?? 0) * 25 / 10).round();
      result['legacyConverted'] = 1;
    }
    for (final (key, _) in criteria) {
      if (result.containsKey(key)) result[key] = result[key]!.clamp(0, 25);
    }
    if (criteria.every((criterion) => result.containsKey(criterion.$1))) {
      result['total'] = criteria.fold<int>(
        0,
        (total, criterion) => total + result[criterion.$1]!,
      );
    }
    return result;
  }

  static double? score(Map<String, int> scores, {double? fallback}) =>
      (normalize(scores)['total']?.toDouble() ?? fallback)
          ?.clamp(0, 100)
          .toDouble();

  static String performanceLevel(num score) {
    if (score >= 90) return 'Excellent';
    if (score >= 80) return 'Proficient';
    if (score >= 70) return 'Developing';
    return 'Needs support';
  }
}
