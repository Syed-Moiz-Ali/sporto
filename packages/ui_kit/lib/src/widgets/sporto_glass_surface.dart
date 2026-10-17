import 'dart:ui';

import 'package:flutter/material.dart';

/// Gradient border presets exported from Figma (hairline glass edges).
/// Used by the referee-booking widgets; centralised here so screens never
/// repeat raw colours.
abstract final class SportoGlassBorders {
  /// `#FFFFFF` 0.2 -> 0.1 -> 0.2
  static const white = LinearGradient(
    colors: [Color(0x33FFFFFF), Color(0x1AFFFFFF), Color(0x33FFFFFF)],
    stops: [0, 0.48, 1],
  );

  /// `#2BB673` 0.06 -> 0.2 -> 0.06
  static const green = LinearGradient(
    colors: [Color(0x0F2BB673), Color(0x332BB673), Color(0x0F2BB673)],
    stops: [0, 0.52, 1],
  );

  /// `#F4B41A` 0.06 -> 0.2 -> 0.06
  static const gold = LinearGradient(
    colors: [Color(0x0FF4B41A), Color(0x33F4B41A), Color(0x0FF4B41A)],
    stops: [0, 0.52, 1],
  );

  /// `#FFC641` 0.06 -> 0.2 -> 0.06
  static const goldSoft = LinearGradient(
    colors: [Color(0x0FFFC641), Color(0x33FFC641), Color(0x0FFFC641)],
    stops: [0, 0.52, 1],
  );
}

/// The canonical glass surface used across the referee-booking flow: a tinted
/// fill (solid or gradient), optional backdrop blur, optional hairline colour
/// or gradient border, optional shadows, and a corner radius.
///
/// Mirrors the Figma `DocCard` / `Section` / `Controls` pattern without
/// reproducing the raw Figma frame nesting in screen code.
class SportoGlassSurface extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry? margin;
  final double radius;
  final double blur;
  final Color? color;
  final Gradient? gradient;
  final Color? borderColor;
  final Gradient? borderGradient;
  final double borderWidth;
  final List<BoxShadow>? shadows;
  final double? width;
  final double? height;
  final Clip clipBehavior;

  const SportoGlassSurface({
    super.key,
    required this.child,
    this.padding = EdgeInsets.zero,
    this.margin,
    this.radius = 16,
    this.blur = 0,
    this.color,
    this.gradient,
    this.borderColor,
    this.borderGradient,
    this.borderWidth = 1,
    this.shadows,
    this.width,
    this.height,
    this.clipBehavior = Clip.antiAlias,
  });

  @override
  Widget build(BuildContext context) {
    final innerRadius = Radius.circular(radius);
    final fill = BoxDecoration(
      color: gradient == null ? color : null,
      gradient: gradient,
      borderRadius: BorderRadius.all(innerRadius),
    );

    Widget core = Container(
      width: width,
      height: height,
      decoration: fill,
      padding: padding,
      child: child,
    );

    if (blur > 0) {
      core = ClipRRect(
        borderRadius: BorderRadius.all(innerRadius),
        clipBehavior: clipBehavior,
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
          child: core,
        ),
      );
    }

    Widget bordered = core;
    if (borderGradient != null) {
      bordered = Container(
        decoration: BoxDecoration(
          gradient: borderGradient,
          borderRadius: BorderRadius.all(innerRadius),
          boxShadow: shadows,
        ),
        padding: EdgeInsets.all(borderWidth),
        child: core,
      );
    } else if (borderColor != null) {
      bordered = Container(
        decoration: BoxDecoration(
          color: color ?? (gradient == null ? null : null),
          borderRadius: BorderRadius.all(innerRadius),
          border: Border.all(color: borderColor!, width: borderWidth),
          boxShadow: shadows,
        ),
        child: core,
      );
    } else if (shadows != null) {
      bordered = Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.all(innerRadius),
          boxShadow: shadows,
        ),
        child: core,
      );
    }

    if (margin == null) return bordered;
    return Padding(padding: margin!, child: bordered);
  }
}
