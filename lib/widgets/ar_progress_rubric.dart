import 'package:flutter/material.dart';

import '../models/ar_progress_assessment.dart';

/// Shared by teacher and student progress so category weights stay identical.
class ArProgressRubric extends StatelessWidget {
  const ArProgressRubric({super.key, required this.scores});

  final Map<String, int> scores;

  @override
  Widget build(BuildContext context) {
    final rubric = ArProgressAssessment.normalize(scores);
    final style = Theme.of(context).textTheme.bodySmall;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Each category is worth 25 points (100 points total).',
            style: style,
          ),
          const SizedBox(height: 10),
          for (final (key, label) in ArProgressAssessment.criteria)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: Text(label, style: style)),
                  const SizedBox(width: 8),
                  Text(
                    '${rubric[key] ?? "—"}/25',
                    style: style?.copyWith(fontWeight: FontWeight.w700),
                  ),
                ],
              ),
            ),
          if (rubric['total'] != null)
            Text(
              'Total: ${rubric['total']}/100 · ${ArProgressAssessment.performanceLevel(rubric['total']!)}',
              style: style?.copyWith(fontWeight: FontWeight.w700),
            ),
          const Divider(),
          Text(
            'PPE: required items correctly selected on the first attempt ÷ required items × 25, rounded, minus 1 per unnecessary item (minimum 0).\n'
            'Procedure: 25 points minus 5 per sequence error and 2 per equipment error (minimum 0).\n'
            'Results: whether the expected scientific outcome was produced.\n'
            'Understanding: correct answers ÷ total questions × 25, rounded.',
            style: style,
          ),
          if (rubric['legacyConverted'] == 1) ...[
            const SizedBox(height: 8),
            Text(
              'Historical category scores converted to the current 25-point weights; this is not a new assessment.',
              style: style,
            ),
          ] else ...[
            if (rubric.containsKey('sequenceErrors') ||
                rubric.containsKey('equipmentErrors'))
              Text(
                'Recorded errors: ${rubric['sequenceErrors'] ?? 0} sequence, ${rubric['equipmentErrors'] ?? 0} equipment.',
                style: style,
              ),
            if (rubric.containsKey('totalUnderstandingQuestions'))
              Text(
                'Understanding answers: ${rubric['correctUnderstandingAnswers'] ?? 0}/${rubric['totalUnderstandingQuestions']}.',
                style: style,
              ),
          ],
        ],
      ),
    );
  }
}
