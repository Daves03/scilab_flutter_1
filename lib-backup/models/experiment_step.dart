class ExperimentStep {
  final String bottleTag; // Matches bottleId in Unity (e.g., 'Surf', 'Yeast')
  final String instructionTitle;
  final String instructionDetail;

  ExperimentStep({
    required this.bottleTag,
    required this.instructionTitle,
    required this.instructionDetail,
  });
}