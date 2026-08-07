// ============================================================
// sporto_gradient_card.dart
// Decorative gradient card used for highlighted/hero sections.
// ============================================================
import 'package:flutter/material.dart';

class SportoGradientCard extends StatelessWidget {
  final List<Color> colors;
  final Widget child;
  final EdgeInsetsGeometry padding;
  final double? width;
  final double radius;
  final Color? borderColor;
  final double borderWidth;
  final AlignmentGeometry begin;
  final AlignmentGeometry end;

  const SportoGradientCard({
    super.key,
    required this.colors,
    required this.child,
    this.padding = const EdgeInsets.all(20),
    this.width,
    this.radius = 20,
    this.borderColor,
    this.borderWidth = 1,
    this.begin = Alignment.topLeft,
    this.end = Alignment.bottomRight,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      decoration: BoxDecoration(
        gradient: LinearGradient(begin: begin, end: end, colors: colors),
        borderRadius: BorderRadius.circular(radius),
        border: borderColor != null
            ? Border.all(color: borderColor!, width: borderWidth)
            : null,
      ),
      padding: padding,
      child: child,
    );
  }
}
