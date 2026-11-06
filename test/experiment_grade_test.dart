import 'package:flutter_test/flutter_test.dart';
import 'package:scilab_flutter_1/data/experiment_assessment_data.dart';
import 'package:scilab_flutter_1/models/experiment_grade.dart';

void main() {
  test('rubric categories total 100 for a perfect experiment', () {
    const grade = ExperimentGrade(
      ppeScore: 25,
      procedureSequenceEquipmentScore: 25,
      resultScore: 25,
      understandingScore: 25,
      correctUnderstandingAnswers: 5,
      totalUnderstandingQuestions: 5,
      sequenceErrors: 0,
      equipmentErrors: 0,
    );

    expect(grade.totalScore, 100);
    expect(grade.performanceLevel, 'Excellent');
    expect(grade.toMap()['total'], 100);
  });

  test('performance levels use the approved score boundaries', () {
    ExperimentGrade gradeWithTotal(int understandingScore) => ExperimentGrade(
      ppeScore: 25,
      procedureSequenceEquipmentScore: 25,
      resultScore: 25,
      understandingScore: understandingScore,
      correctUnderstandingAnswers: switch (understandingScore) {
        15 => 3,
        5 => 1,
        _ => 0,
      },
      totalUnderstandingQuestions: 5,
      sequenceErrors: 0,
      equipmentErrors: 0,
    );

    expect(gradeWithTotal(15).performanceLevel, 'Excellent');
    expect(gradeWithTotal(5).performanceLevel, 'Proficient');
    expect(gradeWithTotal(0).performanceLevel, 'Developing');

    const developing = ExperimentGrade(
      ppeScore: 17,
      procedureSequenceEquipmentScore: 15,
      resultScore: 25,
      understandingScore: 13,
      correctUnderstandingAnswers: 5,
      totalUnderstandingQuestions: 10,
      sequenceErrors: 2,
      equipmentErrors: 1,
    );
    expect(developing.totalScore, 70);
    expect(developing.performanceLevel, 'Developing');
  });

  test('every AR activity has between 5 and 10 graded questions', () {
    for (var experiment = 1; experiment <= 8; experiment++) {
      final questions = questionsForExperiment('ar$experiment');
      expect(
        questions.length,
        inInclusiveRange(
          minimumExperimentQuestions,
          maximumExperimentQuestions,
        ),
      );
      for (final question in questions) {
        expect(question.options, hasLength(4));
        expect(question.correctOption, inInclusiveRange(0, 3));
      }
    }
  });
}
