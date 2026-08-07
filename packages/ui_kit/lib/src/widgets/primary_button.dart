import 'package:flutter/material.dart';

class PrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool disabled;
  final double widthFactor;
  final double? width;
  final double height;
  final double radius;

  const PrimaryButton({
    super.key,
    required this.label,
    this.onPressed,
    this.disabled = false,
    this.widthFactor = 0.7,
    this.width,
    this.height = 52,
    this.radius = 16,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final effectiveOnPressed = disabled ? null : onPressed;
    final width = this.width ?? MediaQuery.of(context).size.width * widthFactor;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: effectiveOnPressed,
        borderRadius: BorderRadius.circular(radius),
        child: Opacity(
          opacity: disabled ? 0.45 : 1.0,
          child: Container(
            width: width,
            height: height,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                colors: [cs.primary, cs.tertiary],
              ),
              borderRadius: BorderRadius.circular(radius),
              boxShadow: disabled
                  ? null
                  : [
                      BoxShadow(
                        color: cs.primary.withOpacity(0.35),
                        blurRadius: 22,
                        offset: const Offset(0, 8),
                      ),
                      BoxShadow(
                        color: cs.tertiary.withOpacity(0.25),
                        blurRadius: 30,
                        offset: const Offset(0, 12),
                      ),
                    ],
            ),
            alignment: Alignment.center,
            child: Text(
              label,
              style: tt.titleLarge?.copyWith(
                color: cs.onPrimary,
                fontSize: 16,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.3,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
