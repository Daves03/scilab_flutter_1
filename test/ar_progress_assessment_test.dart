import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:scilab_flutter_1/models/activity_model.dart';
import 'package:scilab_flutter_1/models/ar_progress_assessment.dart';
import 'package:scilab_flutter_1/widgets/ar_progress_rubric.dart';

void main() {
  test('periodic table is ungraded even when a historical score exists', () {
    for (final id in ['ar8', '8', ' AR8 ']) {
      final activity = ExperimentActivity.fromMap(id, {
        'score': 100,
        'rubricScores': {
          'ppe': 25,
          'procedureSequenceEquipment': 25,
          'experimentalResult': 25,
          'scientificUnderstanding': 25,
          'total': 100,
        },
      });
      expect(activity.isGraded, isFalse);
      expect(activity.rubricScore, isNull);
      expect(activity.rubricScores, isEmpty);
    }
    expect(ArProgressAssessment.isGraded('ar1'), isTrue);
    expect(ArProgressAssessment.isGraded('ar4'), isTrue);
  });
  const current = {
    'ppe': 25,
    'procedureSequenceEquipment': 18,
    'experimentalResult': 25,
    'scientificUnderstanding': 15,
    'sequenceErrors': 1,
    'equipmentErrors': 1,
    'correctUnderstandingAnswers': 3,
    'totalUnderstandingQuestions': 5,
    'total': 83,
  };

  test('current category scores take priority over stale stored totals', () {
    final activity = ExperimentActivity.fromMap('ar1', {
      'score': 100,
      'rubricScores': {...current, 'total': 100},
    });
    expect(activity.rubricScore, 83);
    expect(activity.rubricScores['total'], 83);
    expect(activity.rubricScores['sequenceErrors'], 1);
    expect(
      ArProgressAssessment.performanceLevel(activity.rubricScore!),
      'Proficient',
    );
  });

  test('historical weights convert consistently and only once', () {
    final scores = ArProgressAssessment.normalize({
      'ppe': 12,
      'procedureAndSequence': 28,
      'equipmentHandling': 16,
      'experimentalResult': 16,
      'scientificUnderstanding': 8,
      'total': 80,
    });
    expect(scores['ppe'], 20);
    expect(scores['procedureSequenceEquipment'], 20);
    expect(scores['experimentalResult'], 20);
    expect(scores['scientificUnderstanding'], 20);
    expect(scores['total'], 80);
    expect(scores['legacyConverted'], 1);
    expect(ArProgressAssessment.normalize(scores), scores);
  });

  test('converted total equals the new category sum', () {
    final activity = ExperimentActivity.fromMap('ar1', {
      'score': 70,
      'rubricScores': {
        'ppe': 15,
        'procedureAndSequence': 20,
        'equipmentHandling': 10,
        'experimentalResult': 20,
        'scientificUnderstanding': 5,
        'total': 70,
      },
    });
    expect(activity.rubricScores['total'], 77);
    expect(activity.rubricScore, 77);
  });

  test('total-only records do not invent category scores', () {
    expect(ArProgressAssessment.normalize({'total': 85}), {'total': 85});
    expect(ExperimentActivity.fromMap('ar1', {'score': 85}).rubricScore, 85);
    expect(ArProgressAssessment.score({'total': 110}), 100);
  });

  test('performance levels match the AR result boundaries', () {
    for (final (score, level) in [
      (100, 'Excellent'),
      (90, 'Excellent'),
      (89, 'Proficient'),
      (80, 'Proficient'),
      (79, 'Developing'),
      (70, 'Developing'),
      (69, 'Needs support'),
      (0, 'Needs support'),
    ]) {
      expect(ArProgressAssessment.performanceLevel(score), level);
    }
  });

  testWidgets('shared progress rubric shows new scoring at phone width', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(child: ArProgressRubric(scores: current)),
        ),
      ),
    );
    expect(find.text('PPE and Safety'), findsOneWidget);
    expect(
      find.text('Procedure, Sequence & Equipment Handling'),
      findsOneWidget,
    );
    expect(find.text('Experimental Results'), findsOneWidget);
    expect(find.text('Scientific Understanding'), findsOneWidget);
    expect(find.text('25/25'), findsNWidgets(2));
    expect(find.text('18/25'), findsOneWidget);
    expect(find.text('15/25'), findsOneWidget);
    expect(find.text('Total: 83/100 · Proficient'), findsOneWidget);
    expect(find.text('Understanding answers: 3/5.'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
