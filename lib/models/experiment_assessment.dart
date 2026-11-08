import 'package:flutter/material.dart';

import '../data/experiment_assessment_data.dart';
import 'ppe_selection.dart';

/// A launch-time snapshot of the teacher's assessment configuration.
class ExperimentAssessment {
  const ExperimentAssessment({
    required this.ppeChoices,
    required this.requiredPpe,
    required this.questions,
  });

  final List<PpeOption> ppeChoices;
  final Set<String> requiredPpe;
  final List<ExperimentQuestion> questions;

  factory ExperimentAssessment.fromExperiment(
    String experimentId,
    Map<String, dynamic> data,
  ) {
    final fallbackRequired = requiredPpeForExperiment(experimentId);
    final ppe = _readPpe(data['ppeAssessment']);
    return ExperimentAssessment(
      ppeChoices: ppe?.$1 ?? ppeOptions,
      requiredPpe: ppe?.$2 ?? fallbackRequired,
      questions:
          _readQuestions(data['assessmentQuestions']) ??
          List.unmodifiable(questionsForExperiment(experimentId)),
    );
  }

  static (List<PpeOption>, Set<String>)? _readPpe(Object? raw) {
    if (raw is! Map || raw['options'] is! List || raw['requiredIds'] is! List) {
      return null;
    }
    final choices = <PpeOption>[];
    final ids = <String>{};
    final labels = <String>{};
    for (final item in raw['options'] as List) {
      if (item is! Map) return null;
      final id = item['id'];
      final label = item['label'];
      final reason = item['reason'];
      if (id is! String ||
          id.trim().isEmpty ||
          label is! String ||
          label.trim().isEmpty ||
          reason is! String ||
          reason.trim().isEmpty ||
          !ids.add(id.trim()) ||
          !labels.add(label.trim().toLowerCase())) {
        return null;
      }
      final known = ppeOptions.where((option) => option.id == id.trim());
      choices.add(
        PpeOption(
          id: id.trim(),
          label: label.trim(),
          reason: reason.trim(),
          icon: known.firstOrNull?.icon ?? Icons.health_and_safety,
        ),
      );
    }
    if (choices.isEmpty) return null;
    final required = <String>{};
    for (final id in raw['requiredIds'] as List) {
      if (id is! String || !ids.contains(id.trim())) return null;
      required.add(id.trim());
    }
    return (List.unmodifiable(choices), Set.unmodifiable(required));
  }

  static List<ExperimentQuestion>? _readQuestions(Object? raw) {
    if (raw is! List ||
        raw.length < minimumExperimentQuestions ||
        raw.length > maximumExperimentQuestions) {
      return null;
    }
    final questions = <ExperimentQuestion>[];
    for (final item in raw) {
      if (item is! Map) return null;
      final prompt = item['prompt'];
      final options = item['options'];
      final answer = item['correctOption'];
      if (prompt is! String ||
          prompt.trim().isEmpty ||
          options is! List ||
          options.length != 4 ||
          options.any((option) => option is! String || option.trim().isEmpty) ||
          answer is! int ||
          answer < 0 ||
          answer >= options.length) {
        return null;
      }
      final choices = options
          .cast<String>()
          .map((value) => value.trim())
          .toList();
      if (choices.map((value) => value.toLowerCase()).toSet().length != 4) {
        return null;
      }
      questions.add(
        ExperimentQuestion(
          prompt: prompt.trim(),
          options: List.unmodifiable(choices),
          correctOption: answer,
        ),
      );
    }
    return List.unmodifiable(questions);
  }
}
