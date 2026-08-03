import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SportoColors {
  SportoColors._();

  // Primary Brand Colors from Figma
  static const Color primaryGold = Color(0xFFF4B41A); // Vibrant Amber Gold
  static const Color primaryGreen = Color(0xFF27A166); // Emerald Green Accent
  static const Color accentYellow = Color(0xFFF4B41A);

  // Dark Theme Background & Surfaces
  static const Color darkBackground = Color(0xFF0E0C08);  // Obsidian Dark
  static const Color darkSurface = Color(0xFF1C2026);     // Deep Slate Surface
  static const Color darkCardSurface = Color(0xFF1B2335); // Deep Navy Card
  static const Color darkCardContainer = Color(0xFF283040);
  static const Color darkCardBorder = Color(0xFF363E51);

  // Light Theme Background & Surfaces
  static const Color lightBackground = Color(0xFFF8F9FA); // Pure Crisp Light
  static const Color lightSurface = Color(0xFFFFFFFF);    // Clean White Surface
  static const Color lightCardSurface = Color(0xFFF1F5F9); // Light Slate Card
  static const Color lightCardContainer = Color(0xFFE2E8F0);
  static const Color lightCardBorder = Color(0xFFCBD5E1);

  // Glassmorphism Colors
  static const Color glassSurfaceDark = Color(0xA61C2026);
  static const Color glassSurfaceLight = Color(0xCCFFFFFF);
  static const Color glassBorderDark = Color(0x1FFFFFFF);
  static const Color glassBorderLight = Color(0x1F000000);
  static const Color glassBorderGold = Color(0x59F4B41A);

  // Secondary Accents & Indicators
  static const Color accentGreen = Color(0xFF27A166);
  static const Color liveRed = Color(0xFFE1263F);
  static const Color offlineOrange = Color(0xFFFF9100);

  // Text Colors Dark
  static const Color darkTextPrimary = Color(0xFFFFFFFF);
  static const Color darkTextSecondary = Color(0xFFA0A0A0);
  static const Color darkTextMuted = Color(0xFF666666);

  // Text Colors Light
  static const Color lightTextPrimary = Color(0xFF0F172A);
  static const Color lightTextSecondary = Color(0xFF475569);
  static const Color lightTextMuted = Color(0xFF94A3B8);
}

class SportoTheme {
  SportoTheme._();

  // Default Light Theme
  static ThemeData get lightTheme {
    final baseTextTheme = ThemeData.light().textTheme;

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: SportoColors.lightBackground,
      colorScheme: const ColorScheme.light(
        primary: SportoColors.primaryGold,
        onPrimary: Colors.black,
        secondary: SportoColors.accentGreen,
        onSecondary: Colors.white,
        tertiary: SportoColors.accentYellow,
        surface: SportoColors.lightSurface,
        onSurface: SportoColors.lightTextPrimary,
        surfaceContainer: SportoColors.lightCardSurface,
        surfaceContainerHigh: SportoColors.lightCardContainer,
        onSurfaceVariant: SportoColors.lightTextSecondary,
        outline: SportoColors.lightCardBorder,
        outlineVariant: SportoColors.glassBorderLight,
        error: SportoColors.liveRed,
        onError: Colors.white,
      ),
      textTheme: GoogleFonts.interTextTheme(baseTextTheme).copyWith(
        displayLarge: GoogleFonts.spaceGrotesk(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: SportoColors.lightTextPrimary,
        ),
        displayMedium: GoogleFonts.spaceGrotesk(
          fontSize: 26,
          fontWeight: FontWeight.bold,
          color: SportoColors.lightTextPrimary,
        ),
        displaySmall: GoogleFonts.spaceGrotesk(
          fontSize: 22,
          fontWeight: FontWeight.bold,
          color: SportoColors.lightTextPrimary,
        ),
        headlineMedium: GoogleFonts.spaceGrotesk(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: SportoColors.lightTextPrimary,
        ),
        titleLarge: GoogleFonts.spaceGrotesk(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: SportoColors.lightTextPrimary,
        ),
        bodyLarge: GoogleFonts.inter(
          fontSize: 15,
          fontWeight: FontWeight.normal,
          color: SportoColors.lightTextPrimary,
        ),
        bodyMedium: GoogleFonts.inter(
          fontSize: 13,
          fontWeight: FontWeight.normal,
          color: SportoColors.lightTextSecondary,
        ),
        labelSmall: GoogleFonts.inter(
          fontSize: 11,
          fontWeight: FontWeight.w500,
          color: SportoColors.lightTextMuted,
        ),
      ),
    );
  }

  // Dark Theme
  static ThemeData get darkTheme {
    final baseTextTheme = ThemeData.dark().textTheme;

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: SportoColors.darkBackground,
      colorScheme: const ColorScheme.dark(
        primary: SportoColors.primaryGold,
        onPrimary: Colors.black,
        secondary: SportoColors.accentGreen,
        onSecondary: Colors.white,
        tertiary: SportoColors.accentYellow,
        surface: SportoColors.darkSurface,
        onSurface: SportoColors.darkTextPrimary,
        surfaceContainer: SportoColors.darkCardSurface,
        surfaceContainerHigh: SportoColors.darkCardContainer,
        onSurfaceVariant: SportoColors.darkTextSecondary,
        outline: SportoColors.darkCardBorder,
        outlineVariant: SportoColors.glassBorderDark,
        error: SportoColors.liveRed,
        onError: Colors.white,
      ),
      textTheme: GoogleFonts.interTextTheme(baseTextTheme).copyWith(
        displayLarge: GoogleFonts.spaceGrotesk(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: SportoColors.darkTextPrimary,
        ),
        displayMedium: GoogleFonts.spaceGrotesk(
          fontSize: 26,
          fontWeight: FontWeight.bold,
          color: SportoColors.darkTextPrimary,
        ),
        displaySmall: GoogleFonts.spaceGrotesk(
          fontSize: 22,
          fontWeight: FontWeight.bold,
          color: SportoColors.darkTextPrimary,
        ),
        headlineMedium: GoogleFonts.spaceGrotesk(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: SportoColors.darkTextPrimary,
        ),
        titleLarge: GoogleFonts.spaceGrotesk(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: SportoColors.darkTextPrimary,
        ),
        bodyLarge: GoogleFonts.inter(
          fontSize: 15,
          fontWeight: FontWeight.normal,
          color: SportoColors.darkTextPrimary,
        ),
        bodyMedium: GoogleFonts.inter(
          fontSize: 13,
          fontWeight: FontWeight.normal,
          color: SportoColors.darkTextSecondary,
        ),
        labelSmall: GoogleFonts.inter(
          fontSize: 11,
          fontWeight: FontWeight.w500,
          color: SportoColors.darkTextMuted,
        ),
      ),
    );
  }
}
