import 'package:flutter/material.dart';

import '../../../models/experiment_grade.dart';
import '../../../models/ppe_selection.dart';

class ExperimentResultRubric extends StatelessWidget {
  const ExperimentResultRubric({
    super.key,
    required this.grade,
    this.ppeResult,
  });

  final ExperimentGrade grade;
  final PpeSelectionResult? ppeResult;

  static const _headerColor = Color(0xFF15304E);
  static const _borderColor = Color(0xFF31506D);
  static const _mutedColor = Color(0xFFB6C8DA);
  static const _accentColor = Color(0xFF00D4FF);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Detailed assessment',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 4),
        const Text(
          'Each category is worth 25 points. Your earned range is highlighted.',
          style: TextStyle(color: _mutedColor, fontSize: 12),
        ),
        const SizedBox(height: 10),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Table(
            defaultVerticalAlignment: TableCellVerticalAlignment.middle,
            border: TableBorder.all(color: _borderColor),
            columnWidths: const {
              0: FixedColumnWidth(170),
              1: FixedColumnWidth(270),
              2: FixedColumnWidth(220),
              3: FixedColumnWidth(220),
              4: FixedColumnWidth(220),
            },
            children: [
              const TableRow(
                decoration: BoxDecoration(color: _headerColor),
                children: [
                  _RubricCell('Category', isHeader: true),
                  _RubricCell('Assessment details', isHeader: true),
                  _RubricCell('25–18', isHeader: true),
                  _RubricCell('17–10', isHeader: true),
                  _RubricCell('9–2', isHeader: true),
                ],
              ),
              for (final row in _rows())
                TableRow(
                  decoration: const BoxDecoration(color: Color(0xFF0E2035)),
                  children: [
                    _RubricCell(
                      '${row.category}\n${row.score}/25 points',
                      isCategory: true,
                    ),
                    _RubricCell(row.assessmentDetails),
                    _RubricCell(
                      row.highDescription,
                      isEarnedBand: row.score >= 18,
                    ),
                    _RubricCell(
                      row.middleDescription,
                      isEarnedBand: row.score >= 10 && row.score <= 17,
                    ),
                    _RubricCell(
                      row.lowDescription,
                      isEarnedBand: row.score >= 2 && row.score <= 9,
                    ),
                  ],
                ),
            ],
          ),
        ),
      ],
    );
  }

  List<_RubricRow> _rows() => [
    _RubricRow(
      category: 'PPE AND SAFETY',
      score: grade.ppeScore,
      assessmentDetails:
          'Checks the first-attempt selection of required PPE and whether unnecessary PPE was chosen. ${_ppeResultDetails()}',
      highDescription:
          'All or nearly all required PPE was selected. Safety choices were appropriate, with no or only a minor error.',
      middleDescription:
          'Some required PPE was missing or unnecessary PPE was selected. The student needed safety reminders.',
      lowDescription:
          'Many required PPE items were missing or inappropriate items were selected, showing unsafe preparation.',
    ),
    _RubricRow(
      category: 'PROCEDURE, SEQUENCE, AND EQUIPMENT HANDLING',
      score: grade.procedureSequenceEquipmentScore,
      assessmentDetails:
          'Checks the order of steps and the correct use of materials, apparatus, containers, and connections. ${_procedureDetails()}',
      highDescription:
          'Steps were completed in the correct or nearly correct order, and equipment was selected, handled, and connected properly.',
      middleDescription:
          'Several sequence or handling errors occurred. The procedure was partly correct but required guidance.',
      lowDescription:
          'Frequent sequence and equipment errors occurred, showing limited ability to perform the procedure safely and correctly.',
    ),
    _RubricRow(
      category: 'EXPERIMENTAL RESULTS',
      score: grade.resultScore,
      assessmentDetails:
          'Checks whether the expected reaction, observation, measurement, or final product was produced. ${_resultDetails()}',
      highDescription:
          'The expected scientific outcome was produced clearly and accurately, with results matching the experiment objective.',
      middleDescription:
          'The expected outcome was partly produced, but some observations or measurements were incomplete or inaccurate.',
      lowDescription:
          'The expected outcome was weak, incorrect, or not successfully produced.',
    ),
    _RubricRow(
      category: 'SCIENTIFIC UNDERSTANDING',
      score: grade.understandingScore,
      assessmentDetails:
          'Checks understanding through ${grade.totalUnderstandingQuestions} post-experiment questions. '
          '${grade.correctUnderstandingAnswers} of ${grade.totalUnderstandingQuestions} answers were correct. '
          '${_scoreAndDeduction(grade.understandingScore)}',
      highDescription:
          'Shows a strong understanding of the scientific concept and correctly explains the experiment and its result.',
      middleDescription:
          'Shows partial understanding. Some answers are correct, but important concepts or explanations remain unclear.',
      lowDescription:
          'Shows limited understanding and cannot correctly explain the scientific concept or experimental result.',
    ),
  ];

  String _ppeResultDetails() {
    final result = ppeResult;
    if (grade.ppeScore == 25) {
      return 'All required PPE was correct on the first attempt. ${_scoreAndDeduction(grade.ppeScore)}';
    }
    if (result == null) return _scoreAndDeduction(grade.ppeScore);

    final details = <String>[];
    if (result.firstAttemptMissing.isNotEmpty) {
      details.add(
        'Missing: ${_ppeLabels(result.firstAttemptMissing).join(', ')}.',
      );
    }
    if (result.firstAttemptUnnecessary.isNotEmpty) {
      details.add(
        'Unnecessary: ${_ppeLabels(result.firstAttemptUnnecessary).join(', ')}.',
      );
    }
    details.add(_scoreAndDeduction(grade.ppeScore));
    return details.join(' ');
  }

  String _procedureDetails() {
    if (grade.sequenceErrors == 0 && grade.equipmentErrors == 0) {
      return 'No sequence or equipment errors were detected. ${_scoreAndDeduction(grade.procedureSequenceEquipmentScore)}';
    }
    return '${grade.sequenceErrors} sequence ${grade.sequenceErrors == 1 ? 'error' : 'errors'} '
        'and ${grade.equipmentErrors} equipment ${grade.equipmentErrors == 1 ? 'error' : 'errors'} were detected. '
        'Sequence errors deduct 5 points and equipment errors deduct 2 points. '
        '${_scoreAndDeduction(grade.procedureSequenceEquipmentScore)}';
  }

  String _resultDetails() => grade.resultScore >= 18
      ? 'The expected scientific outcome was successfully produced. ${_scoreAndDeduction(grade.resultScore)}'
      : grade.resultScore >= 10
      ? 'The expected outcome was partially produced. ${_scoreAndDeduction(grade.resultScore)}'
      : 'The expected outcome was not successfully produced. ${_scoreAndDeduction(grade.resultScore)}';

  String _scoreAndDeduction(int score) {
    final deduction = (25 - score).clamp(0, 25);
    return 'Earned: $score/25. Deduction: -$deduction points.';
  }

  List<String> _ppeLabels(Set<String> ids) => ids
      .map(
        (id) =>
            (ppeResult?.options ?? ppeOptions)
                .where((option) => option.id == id)
                .map((option) => option.label)
                .firstOrNull ??
            id,
      )
      .toList();
}

class _RubricCell extends StatelessWidget {
  const _RubricCell(
    this.text, {
    this.isHeader = false,
    this.isCategory = false,
    this.isEarnedBand = false,
  });

  final String text;
  final bool isHeader;
  final bool isCategory;
  final bool isEarnedBand;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minHeight: 86),
      padding: const EdgeInsets.all(10),
      color: isEarnedBand
          ? ExperimentResultRubric._accentColor.withValues(alpha: 0.16)
          : Colors.transparent,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (isEarnedBand) ...[
            const Icon(
              Icons.check_circle,
              size: 15,
              color: ExperimentResultRubric._accentColor,
            ),
            const SizedBox(width: 5),
          ],
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                color: isEarnedBand
                    ? Colors.white
                    : isHeader || isCategory
                    ? Colors.white
                    : ExperimentResultRubric._mutedColor,
                fontSize: isHeader ? 12.5 : 11.5,
                height: 1.35,
                fontWeight: isHeader || isCategory || isEarnedBand
                    ? FontWeight.w700
                    : FontWeight.w400,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RubricRow {
  const _RubricRow({
    required this.category,
    required this.score,
    required this.assessmentDetails,
    required this.highDescription,
    required this.middleDescription,
    required this.lowDescription,
  });

  final String category;
  final int score;
  final String assessmentDetails;
  final String highDescription;
  final String middleDescription;
  final String lowDescription;
}
