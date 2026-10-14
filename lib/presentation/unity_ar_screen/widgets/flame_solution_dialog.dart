import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../theme/app_theme.dart';

/// Model representing a metal salt chemical solution for Flame Test (Experiment 4)
class FlameChemical {
  final int index;
  final String formula;
  final String elementName;
  final String fullName;
  final Color flameColor;
  final String flameColorName;
  final Color badgeBg;
  final Color badgeBorder;
  final Color badgeTextColor;

  const FlameChemical({
    required this.index,
    required this.formula,
    required this.elementName,
    required this.fullName,
    required this.flameColor,
    required this.flameColorName,
    required this.badgeBg,
    required this.badgeBorder,
    required this.badgeTextColor,
  });
}

/// The 6 flame test solutions matching Unity's chemicalModels and elementGradients
const List<FlameChemical> kFlameChemicals = [
  FlameChemical(
    index: 0,
    formula: 'NaCl',
    elementName: 'SODIUM',
    fullName: 'SODIUM CHLORIDE',
    flameColor: Color(0xFFFFB300),
    flameColorName: 'Golden Yellow',
    badgeBg: Color(0xFF1E2818),
    badgeBorder: Color(0xFFFFB300),
    badgeTextColor: Color(0xFFFFB300),
  ),
  FlameChemical(
    index: 1,
    formula: 'CuCl',
    elementName: 'COPPER',
    fullName: 'COPPER CHLORIDE',
    flameColor: Color(0xFF00E5FF),
    flameColorName: 'Blue-Green',
    badgeBg: Color(0xFF0E2A38),
    badgeBorder: Color(0xFF00E5FF),
    badgeTextColor: Color(0xFF00E5FF),
  ),
  FlameChemical(
    index: 2,
    formula: 'KCl',
    elementName: 'POTASSIUM',
    fullName: 'POTASSIUM CHLORIDE',
    flameColor: Color(0xFFCE93D8),
    flameColorName: 'Lilac / Violet',
    badgeBg: Color(0xFF261938),
    badgeBorder: Color(0xFFCE93D8),
    badgeTextColor: Color(0xFFCE93D8),
  ),
  FlameChemical(
    index: 3,
    formula: 'SrCl',
    elementName: 'STRONTIUM',
    fullName: 'STRONTIUM CHLORIDE',
    flameColor: Color(0xFFFF2A55),
    flameColorName: 'Crimson Red',
    badgeBg: Color(0xFF331520),
    badgeBorder: Color(0xFFFF2A55),
    badgeTextColor: Color(0xFFFF2A55),
  ),
  FlameChemical(
    index: 4,
    formula: 'BaCl',
    elementName: 'BARIUM',
    fullName: 'BARIUM CHLORIDE',
    flameColor: Color(0xFF76FF03),
    flameColorName: 'Apple Green',
    badgeBg: Color(0xFF172B10),
    badgeBorder: Color(0xFF76FF03),
    badgeTextColor: Color(0xFF76FF03),
  ),
  FlameChemical(
    index: 5,
    formula: 'CaCl',
    elementName: 'CALCIUM',
    fullName: 'CALCIUM CHLORIDE',
    flameColor: Color(0xFFFF6E40),
    flameColorName: 'Orange-Red',
    badgeBg: Color(0xFF331D15),
    badgeBorder: Color(0xFFFF6E40),
    badgeTextColor: Color(0xFFFF6E40),
  ),
];

/// Full-screen Landscape Solution Picker View styled to match the SciLab dark app theme
class FlameSolutionPickerView extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<FlameChemical> onSelectChemical;
  final VoidCallback onBack;

  const FlameSolutionPickerView({
    super.key,
    required this.selectedIndex,
    required this.onSelectChemical,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    // Column 1 (Left): NaCl (0), KCl (2), BaCl (4)
    final col1 = [kFlameChemicals[0], kFlameChemicals[2], kFlameChemicals[4]];
    // Column 2 (Right): CuCl (1), SrCl (3), CaCl (5)
    final col2 = [kFlameChemicals[1], kFlameChemicals[3], kFlameChemicals[5]];

    return Material(
      color: Colors.transparent,
      child: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF0A1628), // AppTheme.backgroundDark
              Color(0xFF0F1E35), // AppTheme.surfaceDark
              Color(0xFF0A1628),
            ],
          ),
        ),
        child: Stack(
          children: [
            // Ambient neon background glows matching SciLab aesthetics
            Positioned(
              top: -60,
              left: -40,
              child: Container(
                width: 220,
                height: 220,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppTheme.accentCyan.withValues(alpha: 0.07),
                ),
              ),
            ),
            Positioned(
              bottom: -60,
              right: -40,
              child: Container(
                width: 220,
                height: 220,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppTheme.accentPurple.withValues(alpha: 0.07),
                ),
              ),
            ),

            // Main Content Area
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
                child: Column(
                  children: [
                    // Top Bar with Back Button, Header Badge, and Selection Status
                    _buildTopBar(context),

                    const SizedBox(height: 12),

                    // Responsive Chemical Cards Grid matching App Design
                    Expanded(
                      child: Center(
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 920),
                          child: LayoutBuilder(
                            builder: (context, gridConstraints) {
                              if (gridConstraints.maxWidth < 480) {
                                return ListView(
                                  padding: const EdgeInsets.symmetric(vertical: 4),
                                  children: kFlameChemicals.map((chem) => _buildChemicalCard(chem)).toList(),
                                );
                              }
                              return Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  // Column 1: NaCl, KCl, BaCl
                                  Expanded(
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                      children: col1.map((chem) => _buildChemicalCard(chem)).toList(),
                                    ),
                                  ),
                                  const SizedBox(width: 14),
                                  // Column 2: CuCl, SrCl, CaCl
                                  Expanded(
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                      children: col2.map((chem) => _buildChemicalCard(chem)).toList(),
                                    ),
                                  ),
                                ],
                              );
                            },
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Top Bar styled to match the SciLab dark theme, responsive to narrow viewports
  Widget _buildTopBar(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isNarrow = constraints.maxWidth < 480;
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Left circular back button
            Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () {
                  HapticFeedback.lightImpact();
                  onBack();
                },
                borderRadius: BorderRadius.circular(50),
                child: Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppTheme.surfaceCard,
                    border: Border.all(
                      color: const Color(0xFF1E3A5F),
                      width: 1.2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.arrow_back_rounded,
                      color: Colors.white,
                      size: 18,
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(width: 8),

            // Center Title & Pill Badge
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (!isNarrow) ...[
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 3),
                      decoration: BoxDecoration(
                        color: AppTheme.accentCyan.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(50),
                        border: Border.all(
                          color: AppTheme.accentCyan.withValues(alpha: 0.35),
                          width: 1.0,
                        ),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.whatshot_rounded,
                            color: AppTheme.accentCyan,
                            size: 12,
                          ),
                          SizedBox(width: 5),
                          Text(
                            'EXPERIMENT 4 • FLAME TEST',
                            style: TextStyle(
                              color: AppTheme.accentCyan,
                              fontWeight: FontWeight.w700,
                              fontSize: 9.5,
                              letterSpacing: 1.1,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 2),
                  ],
                  Text(
                    'SELECT CHEMICAL SOLUTION',
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: AppTheme.textPrimary,
                      fontWeight: FontWeight.w800,
                      fontSize: isNarrow ? 13 : 15,
                      letterSpacing: 0.6,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(width: 8),

            // Right Status Pill
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: isNarrow ? 8 : 12,
                vertical: isNarrow ? 4 : 6,
              ),
              decoration: BoxDecoration(
                color: AppTheme.surfaceCard,
                borderRadius: BorderRadius.circular(50),
                border: Border.all(
                  color: const Color(0xFF1E3A5F),
                  width: 1.0,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    selectedIndex >= 0 ? Icons.check_circle_rounded : Icons.science_rounded,
                    color: selectedIndex >= 0 ? AppTheme.accentGreen : AppTheme.textMuted,
                    size: 14,
                  ),
                  if (!isNarrow) ...[
                    const SizedBox(width: 6),
                    Text(
                      selectedIndex >= 0
                          ? '${kFlameChemicals[selectedIndex].formula} Selected'
                          : '6 Solutions',
                      style: TextStyle(
                        color: selectedIndex >= 0 ? Colors.white : AppTheme.textMuted,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  /// Modern chemical card matching the App's card and chip design language
  Widget _buildChemicalCard(FlameChemical chem) {
    final isSelected = chem.index == selectedIndex;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3.5),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            HapticFeedback.mediumImpact();
            onSelectChemical(chem);
          },
          borderRadius: BorderRadius.circular(18),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeInOut,
            height: 58,
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: isSelected
                  ? chem.flameColor.withValues(alpha: 0.16)
                  : AppTheme.surfaceCard,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: isSelected ? chem.flameColor : const Color(0xFF1E3A5F),
                width: isSelected ? 2.0 : 1.0,
              ),
              boxShadow: [
                if (isSelected)
                  BoxShadow(
                    color: chem.flameColor.withValues(alpha: 0.32),
                    blurRadius: 14,
                    offset: const Offset(0, 3),
                  )
                else
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.20),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
              ],
            ),
            child: LayoutBuilder(
              builder: (context, cardConstraints) {
                final showChip = cardConstraints.maxWidth > 240;
                return Row(
                  children: [
                    // Formula Badge
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: isSelected
                            ? chem.flameColor.withValues(alpha: 0.25)
                            : AppTheme.surfaceDark,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isSelected
                              ? chem.flameColor
                              : chem.flameColor.withValues(alpha: 0.5),
                          width: 1.5,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          chem.formula,
                          style: TextStyle(
                            fontSize: chem.formula.length > 3 ? 11 : 13,
                            fontWeight: FontWeight.w900,
                            color: isSelected ? Colors.white : chem.flameColor,
                            letterSpacing: -0.2,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(width: 10),

                    // Name & Characteristic Flame Subtitle
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            chem.fullName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 12.5,
                              fontWeight: FontWeight.w700,
                              color: AppTheme.textPrimary,
                              letterSpacing: 0.2,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Row(
                            children: [
                              Container(
                                width: 6,
                                height: 6,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: chem.flameColor,
                                  boxShadow: [
                                    BoxShadow(
                                      color: chem.flameColor,
                                      blurRadius: 4,
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 5),
                              Expanded(
                                child: Text(
                                  'Flame: ${chem.flameColorName}',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 10.5,
                                    fontWeight: FontWeight.w500,
                                    color: isSelected
                                        ? chem.flameColor
                                        : AppTheme.textMuted,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    if (showChip) ...[
                      const SizedBox(width: 6),
                      // Flame Color Chip Tag
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                        decoration: BoxDecoration(
                          color: chem.flameColor.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: chem.flameColor.withValues(alpha: 0.4),
                            width: 1.0,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.whatshot_rounded,
                              color: chem.flameColor,
                              size: 12,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              chem.flameColorName,
                              style: TextStyle(
                                fontSize: 9.5,
                                fontWeight: FontWeight.w700,
                                color: chem.flameColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],

                    const SizedBox(width: 8),

                    // Radio / Checkmark Selection Indicator
                    Icon(
                      isSelected ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded,
                      color: isSelected ? chem.flameColor : const Color(0xFF334E68),
                      size: 18,
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

/// Modal dialog wrapper for showing the Flame Solution Picker
class FlameSolutionDialog extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<FlameChemical> onSelectChemical;

  const FlameSolutionDialog({
    super.key,
    required this.selectedIndex,
    required this.onSelectChemical,
  });

  static Future<FlameChemical?> show(
    BuildContext context, {
    required int selectedIndex,
    required ValueChanged<FlameChemical> onSelectChemical,
  }) {
    return showGeneralDialog<FlameChemical>(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Dismiss Flame Solution Menu',
      barrierColor: Colors.black.withValues(alpha: 0.7),
      transitionDuration: const Duration(milliseconds: 250),
      pageBuilder: (ctx, anim, secAnim) {
        return FlameSolutionPickerView(
          selectedIndex: selectedIndex,
          onSelectChemical: (chem) {
            onSelectChemical(chem);
            Navigator.of(ctx).pop(chem);
          },
          onBack: () => Navigator.of(ctx).pop(),
        );
      },
      transitionBuilder: (ctx, anim, secAnim, child) {
        final curved = CurvedAnimation(parent: anim, curve: Curves.easeOutCubic);
        return ScaleTransition(
          scale: Tween<double>(begin: 0.94, end: 1.0).animate(curved),
          child: FadeTransition(
            opacity: anim,
            child: child,
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return FlameSolutionPickerView(
      selectedIndex: selectedIndex,
      onSelectChemical: onSelectChemical,
      onBack: () => Navigator.of(context).pop(),
    );
  }
}
