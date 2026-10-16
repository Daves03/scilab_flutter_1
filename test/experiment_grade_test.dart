import 'package:flutter_test/flutter_test.dart';
import 'package:scilab_flutter_1/data/experiment_assessment_data.dart';
import 'package:scilab_flutter_1/models/experiment_grade.dart';

void main() {
  test('rubric categories total 100 for a perfect experiment', () {
    const grade = ExperimentGrade(
      ppeScore: 15,
      procedureScore: 35,
      equipmentScore: 20,
      resultScore: 20,
      understandingScore: 10,
      sequenceErrors: 0,
      equipmentErrors: 0,
    );

    expect(grade.totalScore, 100);
    expect(grade.performanceLevel, 'Excellent');
    expect(grade.toMap()['total'], 100);
  });

  test('performance levels use the approved score boundaries', () {
    ExperimentGrade gradeWithTotal(int understandingScore) => ExperimentGrade(
      ppeScore: 15,
      procedureScore: 35,
      equipmentScore: 20,
      resultScore: 20,
      understandingScore: understandingScore,
      sequenceErrors: 0,
      equipmentErrors: 0,
    );

    expect(gradeWithTotal(0).performanceLevel, 'Excellent');

    const developing = ExperimentGrade(
      ppeScore: 10,
      procedureScore: 25,
      equipmentScore: 15,
      resultScore: 15,
      understandingScore: 5,
      sequenceErrors: 2,
      equipmentErrors: 1,
    );
    expect(developing.totalScore, 70);
    expect(developing.performanceLevel, 'Developing');
  });

  test('every AR activity has two automatically graded questions', () {
    for (var experiment = 1; experiment <= 8; experiment++) {
      final questions = questionsForExperiment('ar$experiment');
      expect(questions, hasLength(2));
      for (final question in questions) {
        expect(question.options, hasLength(4));
        expect(question.correctOption, inInclusiveRange(0, 3));
      }
    }
  });
}
