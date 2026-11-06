class ExperimentGrade {
  const ExperimentGrade({
    required this.ppeScore,
    required this.procedureSequenceEquipmentScore,
    required this.resultScore,
    required this.understandingScore,
    required this.correctUnderstandingAnswers,
    required this.totalUnderstandingQuestions,
    required this.sequenceErrors,
    required this.equipmentErrors,
  });

  final int ppeScore;
  final int procedureSequenceEquipmentScore;
  final int resultScore;
  final int understandingScore;
  final int correctUnderstandingAnswers;
  final int totalUnderstandingQuestions;
  final int sequenceErrors;
  final int equipmentErrors;

  int get totalScore =>
      ppeScore +
      procedureSequenceEquipmentScore +
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
    'procedureSequenceEquipment': procedureSequenceEquipmentScore,
    'experimentalResult': resultScore,
    'scientificUnderstanding': understandingScore,
    'correctUnderstandingAnswers': correctUnderstandingAnswers,
    'totalUnderstandingQuestions': totalUnderstandingQuestions,
    'total': totalScore,
    'performanceLevel': performanceLevel,
    'sequenceErrors': sequenceErrors,
    'equipmentErrors': equipmentErrors,
  };
}
