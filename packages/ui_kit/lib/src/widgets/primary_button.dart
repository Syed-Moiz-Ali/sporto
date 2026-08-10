import 'package:flutter/material.dart';

class PrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool disabled;

  /// Shows a spinner inside the button (label hidden) while `true`.
  final bool loading;

  final double widthFactor;
  final double? width;
  final double height;
  final double radius;

  const PrimaryButton({
    super.key,
    required this.label,
    this.onPressed,
    this.disabled = false,
    this.loading = false,
    this.widthFactor = 0.7,
    this.width,
    this.height = 52,
    this.radius = 16,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final effectiveOnPressed = (disabled || loading) ? null : onPressed;
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
                        color: cs.primary.withValues(alpha: 0.24),
                        blurRadius: 20,
                        spreadRadius: -2,
                        offset: const Offset(0, 8),
                      ),
                      BoxShadow(
                        color: cs.tertiary.withValues(alpha: 0.16),
                        blurRadius: 26,
                        spreadRadius: -3,
                        offset: const Offset(0, 10),
                      ),
                    ],
            ),
            alignment: Alignment.center,
            child: loading
                ? SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      color: cs.onPrimary,
                    ),
                  )
                : Text(
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
