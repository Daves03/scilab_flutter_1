import 'package:flutter/material.dart';

class CenteredEditableName extends StatelessWidget {
  const CenteredEditableName({
    super.key,
    required this.name,
    required this.style,
    required this.editColor,
    required this.onEdit,
  });

  final String name;
  final TextStyle style;
  final Color editColor;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final maxNameWidth = constraints.maxWidth > 96
              ? constraints.maxWidth - 96
              : constraints.maxWidth;
          final textPainter = TextPainter(
            text: TextSpan(text: name, style: style),
            maxLines: 1,
            ellipsis: '…',
            textDirection: Directionality.of(context),
            textScaler: MediaQuery.textScalerOf(context),
          )..layout(maxWidth: maxNameWidth);
          final editLeft =
              (constraints.maxWidth / 2) + (textPainter.width / 2) + 2;

          return Stack(
            alignment: Alignment.center,
            clipBehavior: Clip.none,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 48),
                child: Text(
                  name,
                  style: style,
                  maxLines: 1,
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Positioned(
                left: editLeft,
                top: 4,
                child: SizedBox.square(
                  dimension: 40,
                  child: IconButton(
                    tooltip: 'Edit name',
                    padding: EdgeInsets.zero,
                    onPressed: onEdit,
                    icon: Icon(Icons.edit_rounded, color: editColor, size: 20),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
