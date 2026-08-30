import 'package:flutter/material.dart';
import 'experiment_step.dart';

class ArExperimentModel {
  final String id;
  final String title;
  final String topic;
  final String category;
  final String backgroundInfo;
  final String safetyNote;
  final List<String> relatedConcepts;
  final List<String> requiredMaterials;
  final String thumbnailUrl;
  final String iconName;
  final int tintColorValue;
  final String semanticLabel;
  final List<ExperimentStep> steps;

  const ArExperimentModel({
    required this.id,
    required this.title,
    required this.topic,
    required this.category,
    required this.backgroundInfo,
    required this.safetyNote,
    required this.relatedConcepts,
    required this.requiredMaterials,
    required this.thumbnailUrl,
    required this.iconName,
    required this.tintColorValue,
    required this.semanticLabel,
    this.steps = const [],
  });

  factory ArExperimentModel.fromMap(String id, Map<String, dynamic> data) {
    return ArExperimentModel(
      id: id,
      title: data['title'] ?? '',
      topic: data['topic'] ?? '',
      category: data['category'] ?? 'General',
      backgroundInfo: data['backgroundInfo'] ?? '',
      safetyNote: data['safetyNote'] ?? '',
      relatedConcepts: List<String>.from(data['relatedConcepts'] ?? []),
      requiredMaterials: List<String>.from(data['requiredMaterials'] ?? []),
      thumbnailUrl: data['thumbnailUrl'] ?? '',
      iconName: data['iconName'] ?? 'science',
      tintColorValue: data['tintColorValue'] ?? 0xFF142240,
      semanticLabel: data['semanticLabel'] ?? 'AR Experiment',
      steps: data['steps'] != null 
          ? (data['steps'] as List).map((s) => ExperimentStep.fromMap(Map<String, dynamic>.from(s))).toList()
          : [],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'topic': topic,
      'category': category,
      'backgroundInfo': backgroundInfo,
      'safetyNote': safetyNote,
      'relatedConcepts': relatedConcepts,
      'requiredMaterials': requiredMaterials,
      'thumbnailUrl': thumbnailUrl,
      'iconName': iconName,
      'tintColorValue': tintColorValue,
      'semanticLabel': semanticLabel,
      'steps': steps.map((s) => s.toMap()).toList(),
    };
  }

  Color get tintColor => Color(tintColorValue);
}
