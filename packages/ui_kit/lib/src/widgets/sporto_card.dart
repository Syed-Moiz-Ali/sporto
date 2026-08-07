// ============================================================
// sporto_card.dart
// Standard glass card used across all Sporto apps.
// ============================================================
import 'package:flutter/material.dart';
import 'glass_container.dart';

/// The canonical glass card for SPORTO screens: dark tinted fill,
/// hairline border and backdrop blur.
class SportoCard extends StatelessWidget {
  static const Color defaultFill = Color(0xFF15171C);
  static const Color defaultBorder = Color(0x0FFFFFFF);
  static const double defaultRadius = 16;
  static const double defaultBlur = 14;

  final Widget child;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry? margin;
  final double radius;
  final double blur;
  final double borderWidth;
  final Color? borderColor;
  final Color? backgroundColor;
  final VoidCallback? onTap;

  const SportoCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.margin,
    this.radius = defaultRadius,
    this.blur = defaultBlur,
    this.borderWidth = 1,
    this.borderColor = defaultBorder,
    this.backgroundColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final card = GlassContainer(
      margin: margin,
      borderRadius: radius,
      blur: blur,
      borderWidth: borderWidth,
      borderColor: borderColor ?? defaultBorder,
      backgroundColor: backgroundColor ?? defaultFill.withOpacity(0.6),
      padding: padding,
      child: child,
    );

    if (onTap == null) return card;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: card,
    );
  }
}
