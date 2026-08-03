import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SportoColors {
  SportoColors._();

  static const Color primaryGold = Color(0xFFF4B41A);
  static const Color primaryGreen = Color(0xFF27A166);
  static const Color accentYellow = Color(0xFFF4B41A);

  static const Color background = Color(0xFF0E0C08);
  static const Color surfaceDark = Color(0xFF1C2026);
  static const Color cardSurface = Color(0xFF1B2335);
  static const Color cardContainer = Color(0xFF283040);
  static const Color cardBorder = Color(0xFF363E51);

  static const Color glassSurface = Color(0xA61C2026);
  static const Color glassCard = Color(0x8C1B2335);
  static const Color glassBorder = Color(0x1FFFFFFF);
  static const Color glassBorderGold = Color(0x59F4B41A);

  static const Color accentGreen = Color(0xFF27A166);
  static const Color liveRed = Color(0xFFE1263F);
  static const Color offlineOrange = Color(0xFFFF9100);

  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFFA0A0A0);
  static const Color textMuted = Color(0xFF666666);
}

class SportoTheme {
  SportoTheme._();

  static ThemeData get darkTheme {
    final baseTextTheme = ThemeData.dark().textTheme;

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: SportoColors.background,
      colorScheme: const ColorScheme.dark(
        primary: SportoColors.primaryGold,
        onPrimary: Colors.black,
        secondary: SportoColors.accentGreen,
        onSecondary: Colors.white,
        tertiary: SportoColors.accentYellow,
        surface: SportoColors.surfaceDark,
        onSurface: SportoColors.textPrimary,
        surfaceContainer: SportoColors.cardSurface,
        surfaceContainerHigh: SportoColors.cardContainer,
        onSurfaceVariant: SportoColors.textSecondary,
        outline: SportoColors.cardBorder,
        outlineVariant: SportoColors.glassBorder,
        error: SportoColors.liveRed,
        onError: Colors.white,
      ),
      textTheme: GoogleFonts.interTextTheme(baseTextTheme).copyWith(
        displayLarge: GoogleFonts.spaceGrotesk(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: SportoColors.textPrimary,
        ),
        displayMedium: GoogleFonts.spaceGrotesk(
          fontSize: 26,
          fontWeight: FontWeight.bold,
          color: SportoColors.textPrimary,
        ),
        displaySmall: GoogleFonts.spaceGrotesk(
          fontSize: 22,
          fontWeight: FontWeight.bold,
          color: SportoColors.textPrimary,
        ),
        headlineMedium: GoogleFonts.spaceGrotesk(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: SportoColors.textPrimary,
        ),
        titleLarge: GoogleFonts.spaceGrotesk(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: SportoColors.textPrimary,
        ),
        bodyLarge: GoogleFonts.inter(
          fontSize: 15,
          fontWeight: FontWeight.normal,
          color: SportoColors.textPrimary,
        ),
        bodyMedium: GoogleFonts.inter(
          fontSize: 13,
          fontWeight: FontWeight.normal,
          color: SportoColors.textSecondary,
        ),
        labelSmall: GoogleFonts.inter(
          fontSize: 11,
          fontWeight: FontWeight.w500,
          color: SportoColors.textMuted,
        ),
      ),
    );
  }
}
