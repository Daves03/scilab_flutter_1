import 'package:flutter/material.dart';

/// Keeps the steps available while letting the camera view stay unobstructed.
class CollapsibleStepsPanel extends StatefulWidget {
  const CollapsibleStepsPanel({super.key, required this.child});

  final Widget child;

  @override
  State<CollapsibleStepsPanel> createState() => _CollapsibleStepsPanelState();
}

class _CollapsibleStepsPanelState extends State<CollapsibleStepsPanel> {
  bool _isHidden = false;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 328,
      child: Stack(
        children: [
          AnimatedSlide(
            // Include the screen's outer padding so the panel fully exits.
            offset: _isHidden ? const Offset(1.2, 0) : Offset.zero,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOutCubic,
            child: IgnorePointer(
              ignoring: _isHidden,
              child: ExcludeSemantics(
                excluding: _isHidden,
                child: Padding(
                  padding: const EdgeInsets.only(right: 48),
                  child: widget.child,
                ),
              ),
            ),
          ),
          Positioned(
            top: 0,
            right: 0,
            child: Material(
              color: const Color(0xFF0A1628).withValues(alpha: 0.9),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
                side: BorderSide(
                  color: const Color(0xFF00D4FF).withValues(alpha: 0.4),
                ),
              ),
              clipBehavior: Clip.antiAlias,
              child: IconButton(
                tooltip: _isHidden ? 'Show steps' : 'Hide steps',
                color: const Color(0xFF00D4FF),
                constraints: const BoxConstraints.tightFor(
                  width: 48,
                  height: 48,
                ),
                onPressed: () => setState(() => _isHidden = !_isHidden),
                icon: Icon(
                  _isHidden
                      ? Icons.arrow_back_rounded
                      : Icons.arrow_forward_rounded,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
