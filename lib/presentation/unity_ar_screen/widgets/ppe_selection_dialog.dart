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
      child: SafeArea(
        minimum: const EdgeInsets.all(12),
        child: AlertDialog(
          backgroundColor: const Color(0xFF0A1628),
          insetPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 6),
          titlePadding: const EdgeInsets.fromLTRB(16, 10, 16, 4),
          contentPadding: const EdgeInsets.fromLTRB(20, 4, 20, 4),
          actionsPadding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
          title: Row(
            children: [
              IconButton(
                tooltip: 'Back',
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
              ),
              const SizedBox(width: 4),
              const Icon(Icons.health_and_safety, color: Color(0xFF00D4FF)),
              const SizedBox(width: 10),
              const Expanded(
                child: Text(
                  'PPE Safety Check',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
          content: SizedBox(
            width: 680,
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
                  const SizedBox(height: 4),
                  const Text(
                    'Select all safety equipment required before entering the AR laboratory.',
                    style: TextStyle(color: Color(0xFFB8C7DB), height: 1.35),
                  ),
                  if (_missing.isNotEmpty) ...[
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
                              .where((option) => false)
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
                  const SizedBox(height: 8),
                  LayoutBuilder(
                    builder: (context, constraints) {
                      const spacing = 8.0;
                      final itemWidth = (constraints.maxWidth - spacing) / 2;
                      return Wrap(
                        spacing: spacing,
                        runSpacing: 4,
                        children: ppeOptions.map((option) {
                          final selected = _selected.contains(option.id);
                          final missing = _missing.contains(option.id);
                          final unnecessary = _unnecessary.contains(option.id);
                          final highlightColor = missing
                              ? Colors.orangeAccent
                              : unnecessary
                              ? Colors.redAccent
                              : const Color(0xFF244363);

                          return SizedBox(
                            width: itemWidth,
                            child: Material(
                              color: selected
                                  ? const Color(
                                      0xFF00D4FF,
                                    ).withValues(alpha: 0.10)
                                  : const Color(0xFF101F36),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                                side: BorderSide(
                                  color: highlightColor,
                                  width: missing || unnecessary ? 2 : 1,
                                ),
                              ),
                              clipBehavior: Clip.antiAlias,
                              child: CheckboxListTile(
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
                                  size: 20,
                                  color: missing
                                      ? Colors.orangeAccent
                                      : unnecessary
                                      ? Colors.redAccent
                                      : const Color(0xFF00D4FF),
                                ),
                                title: Text(
                                  option.label,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                dense: true,
                                visualDensity: const VisualDensity(
                                  horizontal: -3,
                                  vertical: -4,
                                ),
                                activeColor: const Color(0xFF00D4FF),
                                checkColor: const Color(0xFF07111F),
                                side: BorderSide(color: highlightColor),
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                ),
                                controlAffinity:
                                    ListTileControlAffinity.trailing,
                              ),
                            ),
                          );
                        }).toList(),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton.icon(
              onPressed: () => Navigator.of(context).pop(),
              style: TextButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: const Color(0xFF142240),
                side: const BorderSide(color: Color(0xFF6F87A6)),
                padding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              icon: const Icon(Icons.arrow_back_rounded),
              label: const Text('Back'),
            ),
            FilledButton.icon(
              onPressed: _submit,
              icon: const Icon(Icons.arrow_forward),
              label: Text(
                _firstAttemptScore == null ? 'Check PPE' : 'Continue',
              ),
            ),
          ],
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
        ),
      ),
    );
  }
}
