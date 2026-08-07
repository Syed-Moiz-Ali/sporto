// ============================================================
// sporto_theme.dart
// ============================================================
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SportoTheme {
  SportoTheme._();

  // Raw brand values (used ONLY to seed the ColorScheme below —
  // widgets must read them via Theme.of(context).colorScheme).
  static const Color _primaryOrange = Color(0xFFEE7005);
  static const Color _ctaGold = Color(0xFFE2A22C);
  static const Color _accentGreen = Color(0xFF27A166);
  static const Color _infoBlue = Color(0xFF4BA3F0);
  static const Color _liveRed = Color(0xFFE1263F);

  static const Color _darkBackground = Color(0xFF0B0A08);
  static const Color _darkSurface = Color(0xFF1C2026);
  static const Color _darkCard = Color(0xFF1B2335);
  static const Color _darkCardHigh = Color(0xFF283040);
  static const Color _darkTextPrimary = Color(0xFFFFFFFF);
  static const Color _darkTextSecondary = Color(0xFFA0A0A0);
  static const Color _darkTextMuted = Color(0xFF666666);

  static const Color _lightBackground = Color(0xFFF8F9FA);
  static const Color _lightSurface = Color(0xFFFFFFFF);
  static const Color _lightCard = Color(0xFFF1F5F9);
  static const Color _lightCardHigh = Color(0xFFE2E8F0);
  static const Color _lightTextPrimary = Color(0xFF0F172A);
  static const Color _lightTextSecondary = Color(0xFF475569);
  static const Color _lightTextMuted = Color(0xFF94A3B8);

  static ThemeData get lightTheme {
    final base = ThemeData.light().textTheme;
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: _lightBackground,
      colorScheme: ColorScheme.light(
        primary: _primaryOrange,
        onPrimary: Colors.white,
        secondary: _accentGreen,
        onSecondary: Colors.white,
        tertiary: _ctaGold, // CTA gradient tail
        onTertiary: _infoBlue, // repurposed as info/subtitle blue
        surface: _lightSurface,
        onSurface: _lightTextPrimary,
        surfaceContainer: _lightCard.withOpacity(0.85),
        surfaceContainerHigh: _lightCardHigh,
        onSurfaceVariant: _lightTextSecondary,
        outline: const Color(0x33000000),
        outlineVariant: const Color(0x1F000000),
        error: _liveRed,
        onError: Colors.white,
      ),
      textTheme: GoogleFonts.interTextTheme(base).copyWith(
        displayLarge: GoogleFonts.spaceGrotesk(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: _lightTextPrimary),
        displayMedium: GoogleFonts.spaceGrotesk(
            fontSize: 26,
            fontWeight: FontWeight.bold,
            color: _lightTextPrimary),
        displaySmall: GoogleFonts.spaceGrotesk(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: _lightTextPrimary),
        headlineMedium: GoogleFonts.spaceGrotesk(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: _lightTextPrimary),
        titleLarge: GoogleFonts.spaceGrotesk(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: _lightTextPrimary),
        bodyLarge: GoogleFonts.inter(
            fontSize: 15,
            fontWeight: FontWeight.normal,
            color: _lightTextPrimary),
        bodyMedium: GoogleFonts.inter(
            fontSize: 13,
            fontWeight: FontWeight.normal,
            color: _lightTextSecondary),
        labelSmall: GoogleFonts.inter(
            fontSize: 11, fontWeight: FontWeight.w500, color: _lightTextMuted),
      ),
    );
  }

  static ThemeData get darkTheme {
    final base = ThemeData.dark().textTheme;
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: _darkBackground,
      colorScheme: ColorScheme.dark(
        primary: _primaryOrange,
        onPrimary: Colors.white,
        secondary: _accentGreen,
        onSecondary: Colors.white,
        tertiary: _ctaGold, // CTA gradient tail
        onTertiary: _infoBlue, // repurposed as info/subtitle blue
        surface: _darkSurface,
        onSurface: _darkTextPrimary,
        surfaceContainer: _darkCard.withOpacity(0.4),
        surfaceContainerHigh: _darkCardHigh.withOpacity(0.5),
        onSurfaceVariant: _darkTextSecondary,
        outline: const Color(0x33FFFFFF),
        outlineVariant: const Color(0x1FFFFFFF),
        error: _liveRed,
        onError: Colors.white,
      ),
      textTheme: GoogleFonts.interTextTheme(base).copyWith(
        displayLarge: GoogleFonts.spaceGrotesk(
            fontSize: 32, fontWeight: FontWeight.bold, color: _darkTextPrimary),
        displayMedium: GoogleFonts.spaceGrotesk(
            fontSize: 26, fontWeight: FontWeight.bold, color: _darkTextPrimary),
        displaySmall: GoogleFonts.spaceGrotesk(
            fontSize: 22, fontWeight: FontWeight.bold, color: _darkTextPrimary),
        headlineMedium: GoogleFonts.spaceGrotesk(
            fontSize: 18, fontWeight: FontWeight.w600, color: _darkTextPrimary),
        titleLarge: GoogleFonts.spaceGrotesk(
            fontSize: 16, fontWeight: FontWeight.w600, color: _darkTextPrimary),
        bodyLarge: GoogleFonts.inter(
            fontSize: 15,
            fontWeight: FontWeight.normal,
            color: _darkTextPrimary),
        bodyMedium: GoogleFonts.inter(
            fontSize: 13,
            fontWeight: FontWeight.normal,
            color: _darkTextSecondary),
        labelSmall: GoogleFonts.inter(
            fontSize: 11, fontWeight: FontWeight.w500, color: _darkTextMuted),
      ),
    );
  }
}
