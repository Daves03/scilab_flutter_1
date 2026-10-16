import 'package:flutter/material.dart';

import '../../../models/ppe_selection.dart';

class PpeSelectionDialog extends StatefulWidget {
  const PpeSelectionDialog({
    super.key,
    required this.experimentTitle,
    required this.requiredPpe,
  });

  final String experimentTitle;
  final Set<String> requiredPpe;

  @override
  State<PpeSelectionDialog> createState() => _PpeSelectionDialogState();
}

class _PpeSelectionDialogState extends State<PpeSelectionDialog> {
  final Set<String> _selected = {};
  Set<String> _missing = {};
  Set<String> _unnecessary = {};
  int? _firstAttemptScore;

  void _submit() {
    final missing = widget.requiredPpe.difference(_selected);
    final unnecessaryItems = _selected.difference(widget.requiredPpe);
    final unnecessary = unnecessaryItems.length;
    _firstAttemptScore ??= widget.requiredPpe.isEmpty
        ? 15
        : (((_selected.intersection(widget.requiredPpe).length /
                              widget.requiredPpe.length) *
                          15)
                      .round() -
                  unnecessary)
              .clamp(0, 15)
              .toInt();

    if (missing.isNotEmpty || unnecessaryItems.isNotEmpty) {
      setState(() {
        _missing = missing;
        _unnecessary = unnecessaryItems;
      });
      return;
    }

    Navigator.of(context).pop(
      PpeSelectionResult(
        selected: Set.unmodifiable(_selected),
        required: Set.unmodifiable(widget.requiredPpe),
        score: _firstAttemptScore!,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: true,
      child: AlertDialog(
        backgroundColor: const Color(0xFF0A1628),
        title: const Row(
          children: [
            Icon(Icons.health_and_safety, color: Color(0xFF00D4FF)),
            SizedBox(width: 10),
            Expanded(
              child: Text(
                'PPE Safety Check',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
        content: SizedBox(
          width: 560,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.experimentTitle,
                  style: const TextStyle(
                    color: Color(0xFF00D4FF),
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Select all safety equipment required before entering the AR laboratory.',
                  style: TextStyle(color: Color(0xFFB8C7DB), height: 1.35),
                ),
                if (_missing.isNotEmpty || _unnecessary.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.orange.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.orange),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Review your PPE selection:',
                          style: TextStyle(
                            color: Colors.orangeAccent,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        ...ppeOptions
                            .where((option) => _missing.contains(option.id))
                            .map(
                              (option) => Padding(
                                padding: const EdgeInsets.only(bottom: 6),
                                child: Text(
                                  '• ${option.label}: ${option.reason}',
                                  style: const TextStyle(
                                    color: Color(0xFFFFD29A),
                                    height: 1.3,
                                  ),
                                ),
                              ),
                            ),
                        ...ppeOptions
                            .where((option) => _unnecessary.contains(option.id))
                            .map(
                              (option) => Padding(
                                padding: const EdgeInsets.only(bottom: 6),
                                child: Text(
                                  '• ${option.label}: This protection is not required for the hazards in this experiment.',
                                  style: const TextStyle(
                                    color: Color(0xFFFFB3B3),
                                    height: 1.3,
                                  ),
                                ),
                              ),
                            ),
                        const Text(
                          'Correct the highlighted choices to continue.',
                          style: TextStyle(color: Colors.orangeAccent),
                        ),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: 14),
                ...ppeOptions.map((option) {
                  final selected = _selected.contains(option.id);
                  final missing = _missing.contains(option.id);
                  final unnecessary = _unnecessary.contains(option.id);
                  return CheckboxListTile(
                    value: selected,
                    onChanged: (value) {
                      setState(() {
                        value == true
                            ? _selected.add(option.id)
                            : _selected.remove(option.id);
                        _missing.remove(option.id);
                        _unnecessary.remove(option.id);
                      });
                    },
                    secondary: Icon(
                      option.icon,
                      color: missing
                          ? Colors.orangeAccent
                          : unnecessary
                          ? Colors.redAccent
                          : const Color(0xFF00D4FF),
                    ),
                    title: Text(
                      option.label,
                      style: const TextStyle(color: Colors.white),
                    ),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 3),
                      child: Text(
                        option.reason,
                        style: TextStyle(
                          color: missing
                              ? const Color(0xFFFFD29A)
                              : unnecessary
                              ? const Color(0xFFFFB3B3)
                              : const Color(0xFF8BA3C0),
                          fontSize: 12,
                          height: 1.25,
                        ),
                      ),
                    ),
                    activeColor: const Color(0xFF00D4FF),
                    checkColor: const Color(0xFF07111F),
                    side: BorderSide(
                      color: missing
                          ? Colors.orangeAccent
                          : unnecessary
                          ? Colors.redAccent
                          : Colors.white54,
                      width: missing || unnecessary ? 2 : 1,
                    ),
                    contentPadding: EdgeInsets.zero,
                    controlAffinity: ListTileControlAffinity.trailing,
                  );
                }),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton.icon(
            onPressed: _submit,
            icon: const Icon(Icons.arrow_forward),
            label: Text(_firstAttemptScore == null ? 'Check PPE' : 'Continue'),
          ),
        ],
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      ),
    );
  }
}
