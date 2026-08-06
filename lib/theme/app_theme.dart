// THEME LOCK: dark — source: user prompt ("Dark theme with glowing neon accents")
// Scaffold.backgroundColor = AppTheme.backgroundDark — ALL screens

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // ── Brand colors ──────────────────────────────────────────────
  static const Color primaryNavy = Color(0xFF0A1628);
  static const Color accentCyan = Color(0xFF00D4FF);
  static const Color accentGreen = Color(0xFF00FF88);
  static const Color accentPurple = Color(0xFF7C5CBF);
  static const Color warningAmber = Color(0xFFFFB800);
  static const Color errorRed = Color(0xFFFF4757);

  // ── Dark surfaces ─────────────────────────────────────────────
  static const Color backgroundDark = Color(0xFF0A1628);
  static const Color surfaceDark = Color(0xFF0F1E35);
  static const Color surfaceCard = Color(0xFF142240);
  static const Color surfaceElevated = Color(0xFF1A2D4A);

  // ── Tinted card backgrounds ───────────────────────────────────
  static const Color tintCyan = Color(0xFF0D2E3F);
  static const Color tintPurple = Color(0xFF1E1535);
  static const Color tintGreen = Color(0xFF0D2E1F);
  static const Color tintAmber = Color(0xFF2E2010);

  // ── Text ──────────────────────────────────────────────────────
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textMuted = Color(0xFF8BA3C0);
  static const Color textCaption = Color(0xFF5A7A9A);

  static ThemeData get darkTheme => ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: backgroundDark,
    colorScheme: const ColorScheme.dark(
      primary: accentCyan,
      onPrimary: primaryNavy,
      primaryContainer: Color(0xFF0D2E3F),
      onPrimaryContainer: accentCyan,
      secondary: accentGreen,
      onSecondary: primaryNavy,
      secondaryContainer: Color(0xFF0D2E1F),
      onSecondaryContainer: accentGreen,
      tertiary: accentPurple,
      onTertiary: Colors.white,
      surface: surfaceDark,
      onSurface: textPrimary,
      surfaceContainerHighest: surfaceElevated,
      onSurfaceVariant: textMuted,
      error: errorRed,
      onError: Colors.white,
      outline: Color(0xFF1E3A5F),
      outlineVariant: Color(0xFF0F2A45),
      inverseSurface: Color(0xFFE0E8F0),
      onInverseSurface: primaryNavy,
    ),
    textTheme: GoogleFonts.interTextTheme(
      const TextTheme(
        displayLarge: TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.w700,
          color: textPrimary,
        ),
        displayMedium: TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.w700,
          color: textPrimary,
        ),
        displaySmall: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.w700,
          color: textPrimary,
        ),
        headlineLarge: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.w700,
          color: textPrimary,
        ),
        headlineMedium: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: textPrimary,
        ),
        headlineSmall: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: textPrimary,
        ),
        titleLarge: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: textPrimary,
        ),
        titleMedium: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w600,
          color: textPrimary,
        ),
        titleSmall: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: textPrimary,
        ),
        bodyLarge: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w400,
          color: textPrimary,
        ),
        bodyMedium: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: textPrimary,
        ),
        bodySmall: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w400,
          color: textMuted,
        ),
        labelLarge: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: textPrimary,
        ),
        labelMedium: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: textMuted,
          letterSpacing: 0.3,
        ),
        labelSmall: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w500,
          color: textCaption,
          letterSpacing: 0.2,
        ),
      ),
    ),
    appBarTheme: const AppBarThemeData(
      backgroundColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
      iconTheme: IconThemeData(color: textPrimary),
      titleTextStyle: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: textPrimary,
      ),
    ),
    cardTheme: CardThemeData(
      color: surfaceCard,
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    ),
    inputDecorationTheme: InputDecorationThemeData(
      filled: true,
      fillColor: const Color(0x14FFFFFF),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Color(0x2900D4FF), width: 1),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Color(0x2900D4FF), width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: accentCyan, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: errorRed, width: 1),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: errorRed, width: 1.5),
      ),
      labelStyle: const TextStyle(color: textMuted, fontSize: 14),
      hintStyle: const TextStyle(color: textCaption, fontSize: 14),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: accentCyan,
        foregroundColor: primaryNavy,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
        textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
        elevation: 0,
      ),
    ),
    chipTheme: ChipThemeData(
      backgroundColor: const Color(0x1400D4FF),
      selectedColor: const Color(0x3300D4FF),
      labelStyle: const TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: accentCyan,
      ),
      side: const BorderSide(color: Color(0x3300D4FF), width: 1),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
    ),
    dividerTheme: const DividerThemeData(
      color: Color(0xFF1E3A5F),
      thickness: 1,
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: Colors.transparent,
      selectedItemColor: accentCyan,
      unselectedItemColor: textMuted,
    ),
  );

  // Light theme — required by contract even though app is dark-only
  static ThemeData get lightTheme => ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    colorScheme: ColorScheme.light(
      primary: const Color(0xFF0A1628),
      onPrimary: Colors.white,
      secondary: const Color(0xFF00D4FF),
      surface: Colors.white,
      onSurface: const Color(0xFF0A1628),
      error: const Color(0xFFFF4757),
      onError: Colors.white,
      outline: Colors.grey.shade300,
    ),
    textTheme: GoogleFonts.interTextTheme(),
    scaffoldBackgroundColor: const Color(0xFFF5F7FA),
  );
}
