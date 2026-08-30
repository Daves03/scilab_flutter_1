class ExperimentStep {
  final String bottleTag; // Matches bottleId in Unity (e.g., 'Surf', 'Yeast')
  final String instructionTitle;
  final String instructionDetail;

  ExperimentStep({
    required this.bottleTag,
    required this.instructionTitle,
    required this.instructionDetail,
  });

  factory ExperimentStep.fromMap(Map<String, dynamic> data) {
    return ExperimentStep(
      bottleTag: data['bottleTag'] ?? '',
      instructionTitle: data['instructionTitle'] ?? '',
      instructionDetail: data['instructionDetail'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'bottleTag': bottleTag,
      'instructionTitle': instructionTitle,
      'instructionDetail': instructionDetail,
    };
  }
}