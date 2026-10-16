import 'package:flutter/material.dart';

class PpeOption {
  const PpeOption({
    required this.id,
    required this.label,
    required this.icon,
    required this.reason,
  });

  final String id;
  final String label;
  final IconData icon;
  final String reason;
}

const List<PpeOption> ppeOptions = [
  PpeOption(
    id: 'goggles',
    label: 'Safety goggles',
    icon: Icons.visibility,
    reason: 'Protects the eyes from chemical splashes, droplets, and debris.',
  ),
  PpeOption(
    id: 'gloves',
    label: 'Nitrile gloves',
    icon: Icons.back_hand,
    reason: 'Reduces skin contact with irritating or corrosive chemicals.',
  ),
  PpeOption(
    id: 'lab_coat',
    label: 'Lab coat / apron',
    icon: Icons.checkroom,
    reason: 'Protects skin and clothing from spills and splashes.',
  ),
  PpeOption(
    id: 'closed_shoes',
    label: 'Closed-toe shoes',
    icon: Icons.hiking,
    reason: 'Protects the feet from spills, broken glass, and dropped tools.',
  ),
  PpeOption(
    id: 'face_shield',
    label: 'Face shield',
    icon: Icons.face_retouching_natural,
    reason: 'Adds full-face protection during high-risk splash procedures.',
  ),
  PpeOption(
    id: 'heat_gloves',
    label: 'Heat-resistant gloves',
    icon: Icons.whatshot,
    reason: 'Protects the hands when handling hot equipment or containers.',
  ),
  PpeOption(
    id: 'respirator',
    label: 'Face mask / respirator',
    icon: Icons.masks,
    reason: 'Helps protect against specific airborne hazards when required.',
  ),
  PpeOption(
    id: 'hair_restraint',
    label: 'Hair restraint',
    icon: Icons.content_cut,
    reason: 'Keeps long hair away from flames, chemicals, and equipment.',
  ),
];

const Map<String, Set<String>> requiredPpeByExperiment = {
  '1': {'goggles', 'gloves', 'lab_coat', 'closed_shoes'},
  '2': {'goggles', 'gloves', 'lab_coat', 'closed_shoes'},
  '3': {'goggles', 'gloves', 'lab_coat', 'closed_shoes'},
  '4': {'goggles', 'lab_coat', 'closed_shoes', 'hair_restraint'},
  '5': {'goggles', 'lab_coat', 'closed_shoes'},
  '6': {'goggles', 'gloves', 'lab_coat', 'closed_shoes'},
  '7': {'goggles', 'gloves', 'lab_coat', 'closed_shoes'},
  '8': <String>{},
};

Set<String> requiredPpeForExperiment(String experimentId) {
  final normalizedId = experimentId.replaceAll(RegExp(r'[^0-9]'), '');
  return requiredPpeByExperiment[normalizedId] ?? const <String>{};
}

class PpeSelectionResult {
  const PpeSelectionResult({
    required this.selected,
    required this.required,
    required this.score,
  });

  final Set<String> selected;
  final Set<String> required;
  final int score;
}
