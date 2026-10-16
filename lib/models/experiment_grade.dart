class ExperimentGrade {
  const ExperimentGrade({
    required this.ppeScore,
    required this.procedureScore,
    required this.equipmentScore,
    required this.resultScore,
    required this.understandingScore,
    required this.sequenceErrors,
    required this.equipmentErrors,
  });

  final int ppeScore;
  final int procedureScore;
  final int equipmentScore;
  final int resultScore;
  final int understandingScore;
  final int sequenceErrors;
  final int equipmentErrors;

  int get totalScore =>
      ppeScore +
      procedureScore +
      equipmentScore +
      resultScore +
      understandingScore;

  String get performanceLevel {
    if (totalScore >= 90) return 'Excellent';
    if (totalScore >= 80) return 'Proficient';
    if (totalScore >= 70) return 'Developing';
    return 'Needs support';
  }

  Map<String, dynamic> toMap() => {
    'ppe': ppeScore,
    'procedureAndSequence': procedureScore,
    'equipmentHandling': equipmentScore,
    'experimentalResult': resultScore,
    'scientificUnderstanding': understandingScore,
    'total': totalScore,
    'performanceLevel': performanceLevel,
    'sequenceErrors': sequenceErrors,
    'equipmentErrors': equipmentErrors,
  };
}
