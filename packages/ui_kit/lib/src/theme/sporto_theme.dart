import 'package:flutter/material.dart';

import 'sporto_cricket_scoring_theme.dart';
import 'sporto_design_tokens.dart';

class SportoTheme {
  SportoTheme._();

  static const _primary = Color(0xFFED7B00);
  static const _gold = Color(0xFFCF9E24);
  static const _green = Color(0xFF2BB673);
  static const _blue = Color(0xFF4FBAF0);
  static const _red = Color(0xFFFE464B);

  static ThemeData get lightTheme => _theme(
        brightness: Brightness.light,
        background: const Color(0xFFF8F9FA),
        surface: const Color(0xFFFFFFFF),
        onSurface: const Color(0xFF0F172A),
        onSurfaceVariant: const Color(0xFF475569),
      );

  static ThemeData get darkTheme => _theme(
        brightness: Brightness.dark,
        background: SportoDesignTokens.dark.canvas,
        surface: SportoDesignTokens.dark.card,
        onSurface: const Color(0xFFF4F4F5),
        onSurfaceVariant: const Color(0xFF92949A),
      );

  static ThemeData _theme({
    required Brightness brightness,
    required Color background,
    required Color surface,
    required Color onSurface,
    required Color onSurfaceVariant,
  }) {
    final scheme = ColorScheme(
      brightness: brightness,
      primary: _primary,
      onPrimary: const Color(0xFFFFFFFF),
      secondary: _green,
      onSecondary: const Color(0xFFFFFFFF),
      tertiary: _gold,
      onTertiary: _blue,
      error: _red,
      onError: const Color(0xFFFFFFFF),
      surface: surface,
      onSurface: onSurface,
      outline: SportoDesignTokens.dark.border,
      outlineVariant: SportoDesignTokens.dark.border.withValues(alpha: .55),
      surfaceContainer: SportoDesignTokens.dark.card,
      surfaceContainerHigh: SportoDesignTokens.dark.cardElevated,
      onSurfaceVariant: onSurfaceVariant,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      scaffoldBackgroundColor: background,
      colorScheme: scheme,
      fontFamily: 'packages/ui_kit/Quicksand',
      fontFamilyFallback: const [
        'packages/ui_kit/Inter',
        'packages/ui_kit/Mulish'
      ],
      extensions: const [
        SportoDesignTokens.dark,
        SportoLayoutTokens.figma,
        SportoCricketScoringTheme.dark,
      ],
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        titleTextStyle: TextStyle(
          fontFamily: 'packages/ui_kit/Quicksand',
          color: onSurface,
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
      ),
      textTheme: _textTheme(onSurface, onSurfaceVariant),
      primaryTextTheme: TextTheme(
        displayLarge: TextStyle(
          fontFamily: 'packages/ui_kit/Space Grotesk',
          color: onSurface,
          fontSize: 68,
          height: 1,
          fontWeight: FontWeight.w600,
          letterSpacing: 1.5,
        ),
      ),
      dividerTheme: DividerThemeData(color: scheme.outline, thickness: 1),
      cardTheme: CardThemeData(
        color: scheme.surfaceContainer,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: scheme.outline),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: SportoDesignTokens.dark.field,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(
            color: SportoDesignTokens.dark.fieldBorder,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(
            color: SportoDesignTokens.dark.fieldBorder,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(
            color: SportoDesignTokens.dark.fieldBorderFocused,
            width: 1.5,
          ),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size(0, 48),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          textStyle: const TextStyle(
            fontFamily: 'packages/ui_kit/Quicksand',
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: scheme.surfaceContainer,
        modalBackgroundColor: scheme.surfaceContainer,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
      ),
    );
  }

  static TextTheme _textTheme(Color primary, Color secondary) => TextTheme(
        displayLarge: TextStyle(
          fontFamily: 'packages/ui_kit/Quicksand',
          fontSize: 32,
          height: 1.15,
          fontWeight: FontWeight.w600,
          color: primary,
        ),
        displayMedium: TextStyle(
          fontFamily: 'packages/ui_kit/Quicksand',
          fontSize: 26,
          height: 1.15,
          fontWeight: FontWeight.w600,
          color: primary,
        ),
        displaySmall: TextStyle(
          fontFamily: 'packages/ui_kit/Quicksand',
          fontSize: 22,
          height: 1.15,
          fontWeight: FontWeight.w600,
          color: primary,
        ),
        headlineMedium: TextStyle(
          fontFamily: 'packages/ui_kit/Quicksand',
          fontSize: 18,
          height: 1.2,
          fontWeight: FontWeight.w600,
          color: primary,
        ),
        titleLarge: TextStyle(
          fontFamily: 'packages/ui_kit/Quicksand',
          fontSize: 18,
          height: 1.2,
          fontWeight: FontWeight.w600,
          color: primary,
        ),
        titleMedium: TextStyle(
          fontFamily: 'packages/ui_kit/Quicksand',
          fontSize: 16,
          height: 1.25,
          fontWeight: FontWeight.w600,
          color: primary,
        ),
        bodyLarge: TextStyle(
          fontFamily: 'packages/ui_kit/Quicksand',
          fontSize: 16,
          height: 1.3,
          fontWeight: FontWeight.w500,
          color: primary,
        ),
        bodyMedium: TextStyle(
          fontFamily: 'packages/ui_kit/Quicksand',
          fontSize: 15,
          height: 1.25,
          fontWeight: FontWeight.w500,
          color: secondary,
        ),
        bodySmall: TextStyle(
          fontFamily: 'packages/ui_kit/Quicksand',
          fontSize: 13,
          height: 1.25,
          fontWeight: FontWeight.w500,
          color: secondary,
        ),
        labelLarge: TextStyle(
          fontFamily: 'packages/ui_kit/Quicksand',
          fontSize: 15,
          height: 1.2,
          fontWeight: FontWeight.w600,
          color: primary,
        ),
        labelMedium: TextStyle(
          fontFamily: 'packages/ui_kit/Quicksand',
          fontSize: 14,
          height: 1.2,
          fontWeight: FontWeight.w600,
          color: secondary,
        ),
        labelSmall: TextStyle(
          fontFamily: 'packages/ui_kit/Quicksand',
          fontSize: 13,
          height: 1.2,
          fontWeight: FontWeight.w600,
          color: secondary,
        ),
      );
}
