import 'package:flutter/material.dart';
import 'package:ui_kit/ui_kit.dart';

/// Primary CTA used across the booking flow (orange gradient + glow).
class BookingPrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  final double width;
  final double height;
  final double fontSize;

  const BookingPrimaryButton({
    super.key,
    required this.label,
    required this.onTap,
    this.width = 270,
    this.height = 48,
    this.fontSize = SportoTextStyles.size16,
  });

  @override
  Widget build(BuildContext context) {
    final tokens = context.sporto;
    final layout = context.sportoLayout;
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Center(
        child: SizedBox(
          width: width,
          height: height,
          child: SportoGlassSurface(
            radius: layout.radius16,
            gradient: tokens.primaryGradient,
            shadows: layout.ctaGlow,
            child: Center(
              child: Text(
                label,
                style: SportoTextStyles.text(
                  size: fontSize,
                  weight: SportoTextStyles.bold,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
