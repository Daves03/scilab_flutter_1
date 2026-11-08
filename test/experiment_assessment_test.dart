import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:scilab_flutter_1/data/experiment_assessment_data.dart';
import 'package:scilab_flutter_1/models/experiment_assessment.dart';
import 'package:scilab_flutter_1/models/ppe_selection.dart';

Map<String, dynamic> question(int index) => {
  'prompt': 'Teacher question $index',
  'options': ['Choice A', 'Choice B', 'Choice C', 'Choice D'],
  'correctOption': 3,
};

void main() {
  test('teacher PPE options and answer keys replace built-ins for one run', () {
    final data = <String, dynamic>{
      'ppeAssessment': {
        'options': [
          {'id': 'custom', 'label': 'Teacher PPE', 'reason': 'Custom feedback'},
        ],
        'requiredIds': ['custom'],
      },
      'assessmentQuestions': List.generate(7, question),
    };
    final assessment = ExperimentAssessment.fromExperiment('ar1', data);
    expect(assessment.ppeChoices.single.label, 'Teacher PPE');
    expect(assessment.requiredPpe, {'custom'});
    expect(assessment.questions, hasLength(7));
    expect(assessment.questions.first.correctOption, 3);
    (data['assessmentQuestions'] as List).first['correctOption'] = 0;
    expect(assessment.questions.first.correctOption, 3);
    expect(() => assessment.questions.clear(), throwsUnsupportedError);
  });

  test('both question-count boundaries load and invalid counts fall back', () {
    for (final count in [5, 10]) {
      final assessment = ExperimentAssessment.fromExperiment('ar2', {
        'assessmentQuestions': List.generate(count, question),
      });
      expect(assessment.questions, hasLength(count));
      expect(assessment.questions.first.prompt, 'Teacher question 0');
    }
    for (final count in [0, 4, 11]) {
      final assessment = ExperimentAssessment.fromExperiment('ar2', {
        'assessmentQuestions': List.generate(count, question),
      });
      expect(
        assessment.questions.first.prompt,
        questionsForExperiment('ar2').first.prompt,
      );
    }
  });

  test(
    'invalid answer keys and indistinguishable choices fall back safely',
    () {
      for (final answer in [-1, 4, 1.5, '1', null]) {
        final questions = List.generate(5, question);
        questions[0]['correctOption'] = answer;
        final assessment = ExperimentAssessment.fromExperiment('ar3', {
          'assessmentQuestions': questions,
        });
        expect(
          assessment.questions.first.prompt,
          questionsForExperiment('ar3').first.prompt,
        );
      }
      final questions = List.generate(5, question);
      questions[0]['options'] = ['Same', ' same ', 'Other', 'Final'];
      expect(
        ExperimentAssessment.fromExperiment('ar3', {
          'assessmentQuestions': questions,
        }).questions.first.prompt,
        questionsForExperiment('ar3').first.prompt,
      );
    },
  );

  test(
    'invalid required PPE IDs fall back without replacing a valid teacher quiz',
    () {
      final assessment = ExperimentAssessment.fromExperiment('ar4', {
        'ppeAssessment': {
          'options': [
            {'id': 'custom', 'label': 'Custom', 'reason': 'Feedback'},
          ],
          'requiredIds': ['missing'],
        },
        'assessmentQuestions': List.generate(5, question),
      });
      expect(assessment.requiredPpe, requiredPpeForExperiment('ar4'));
      expect(assessment.questions.first.prompt, 'Teacher question 0');
    },
  );

  test(
    'web initial assessment choices and keys match every Flutter fallback',
    () {
      final defaults =
          jsonDecode(
                File(
                  'admin_web/src/data/experimentAssessmentDefaults.json',
                ).readAsStringSync(),
              )
              as Map;
      expect(
        (defaults['ppeOptions'] as List).map((option) => option['label']),
        ppeOptions.map((option) => option.label),
      );
      for (var id = 1; id <= 8; id++) {
        final required = defaults['requiredPpeByExperiment']['$id'] as List;
        expect(required.toSet(), requiredPpeForExperiment('ar$id'));
        final questions = defaults['questionsByExperiment']['$id'] as List;
        final expected = questionsForExperiment('ar$id');
        expect(questions.length, expected.length);
        for (var index = 0; index < expected.length; index++) {
          expect(questions[index]['prompt'], expected[index].prompt);
          expect(questions[index]['options'], expected[index].options);
          expect(
            questions[index]['correctOption'],
            expected[index].correctOption,
          );
        }
      }
    },
  );
}
