import 'package:flutter/material.dart';

import '../theme/sporto_design_tokens.dart';
import 'sporto_glass_surface.dart';

/// The Figma `DocCard` / `Section` glass card used across the booking flow.
///
/// `plain` drops the blur and hairline (Figma `#1C2026` fill) for summary rows.
class SportoDocCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final double? radius;
  final double? blur;
  final bool plain;
  final Color? color;
  final Gradient? borderGradient;
  final double? width;
  final List<BoxShadow>? shadows;
  final VoidCallback? onTap;

  const SportoDocCard({
    super.key,
    required this.child,
    this.padding,
    this.radius,
    this.blur,
    this.plain = false,
    this.color,
    this.borderGradient,
    this.width,
    this.shadows,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final tokens = context.sporto;
    final layout = context.sportoLayout;

    final card = SportoGlassSurface(
      width: width,
      radius: radius ?? layout.radius16,
      blur: plain ? 0 : (blur ?? layout.glassBlur),
      color: color ?? (plain ? tokens.cardElevated : tokens.card),
      borderGradient: plain ? null : (borderGradient ?? SportoGlassBorders.white),
      padding: padding ?? const EdgeInsets.all(10),
      shadows: shadows,
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
