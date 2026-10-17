import 'package:flutter/material.dart';

/// Centralized Quicksand type scale derived from the Figma "User App" export.
///
/// Screens must build text through these tokens (sizes/weights) rather than
/// hardcoding `TextStyle(fontSize: ...)`. Figma uses only Quicksand 400/500/
/// 600/700 across sizes 10–28 plus 40/64.
abstract final class SportoTextStyles {
  static const fontFamily = 'packages/ui_kit/Quicksand';

  // Sizes observed in Figma.
  static const double size10 = 10;
  static const double size11 = 11;
  static const double size12 = 12;
  static const double size13 = 13;
  static const double size14 = 14;
  static const double size15 = 15;
  static const double size16 = 16;
  static const double size18 = 18;
  static const double size24 = 24;
  static const double size28 = 28;
  static const double size40 = 40;
  static const double size64 = 64;

  static const FontWeight regular = FontWeight.w400;
  static const FontWeight medium = FontWeight.w500;
  static const FontWeight semiBold = FontWeight.w600;
  static const FontWeight bold = FontWeight.w700;

  static const double defaultHeight = 1.25;

  /// Builds a Quicksand [TextStyle] from scale tokens. [size] and [weight]
  /// should come from the constants above; [color] from `context.sporto`.
  static TextStyle text({
    required double size,
    FontWeight weight = medium,
    Color? color,
    double height = defaultHeight,
    double? letterSpacing,
  }) =>
      TextStyle(
        fontFamily: fontFamily,
        fontSize: size,
        fontWeight: weight,
        color: color,
        height: height,
        letterSpacing: letterSpacing,
      );
}
