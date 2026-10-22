import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../routes/app_routes.dart';

class DbowCurriculumButton extends StatelessWidget {
  const DbowCurriculumButton({super.key, required this.gradeLevel})
    : assert(gradeLevel == 9 || gradeLevel == 10);

  final int gradeLevel;

  String get _assetPath =>
      'assets/documents/SCIENCE-$gradeLevel-TRIMESTER-DBOW-1.pdf';

  String get _documentTitle => 'Science $gradeLevel Trimester DBOW 1';

  Future<void> _openCurriculum(BuildContext context) async {
    try {
      await rootBundle.load(_assetPath);
    } catch (_) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text(
              'Grade $gradeLevel curriculum PDF not added yet. Add '
              'SCIENCE-$gradeLevel-TRIMESTER-DBOW-1.pdf to '
              'assets/documents, then restart the app.',
            ),
          ),
        );
      return;
    }

    if (!context.mounted) return;
    context.push(
      '${AppRoutes.pdfViewerScreen}'
      '?asset=${Uri.encodeComponent(_assetPath)}'
      '&title=${Uri.encodeComponent(_documentTitle)}',
    );
  }

  @override
  Widget build(BuildContext context) {
    const accent = Color(0xFF00D4FF);
    final foreground = Theme.of(context).colorScheme.onSurface;
    final secondary = Theme.of(context).colorScheme.onSurfaceVariant;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
      child: Semantics(
        button: true,
        label: 'Open the revised K to 10 Science $gradeLevel curriculum PDF',
        child: Material(
          color: accent.withValues(alpha: 0.1),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
            side: BorderSide(color: accent.withValues(alpha: 0.35)),
          ),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: () => _openCurriculum(context),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  const Icon(Icons.school_rounded, color: accent, size: 20),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '(DBOW) REVISED K TO 10 CURRICULUM',
                          style: TextStyle(
                            color: foreground,
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'THREE-TERM DEFINITIVE BUDGET OF WORK',
                          style: TextStyle(
                            color: secondary,
                            fontSize: 11,
                            letterSpacing: 0.2,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Icon(Icons.chevron_right_rounded, color: accent),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
