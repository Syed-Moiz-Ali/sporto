import 'package:flutter/material.dart';
import 'glass_container.dart';

class GlassButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool isPrimary;
  final bool isDisabled;
  final double height;
  final double? width;

  const GlassButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.isPrimary = true,
    this.isDisabled = false,
    this.height = 52.0,
    this.width,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final effectiveOnPressed = isDisabled ? null : onPressed;

    final bgColor = isPrimary
        ? (isDisabled
            ? colorScheme.primary.withValues(alpha: 0.3)
            : colorScheme.primary)
        : colorScheme.surfaceContainer;

    final textColor = isPrimary
        ? (isDisabled ? colorScheme.onSurfaceVariant : colorScheme.onPrimary)
        : (isDisabled ? colorScheme.onSurfaceVariant : colorScheme.onSurface);

    return InkWell(
      onTap: effectiveOnPressed,
      borderRadius: BorderRadius.circular(16),
      child: GlassContainer(
        width: width,
        height: height,
        borderRadius: 16,
        blur: isPrimary ? 8 : 15,
        backgroundColor: bgColor,
        borderColor: isPrimary
            ? (isDisabled ? Colors.transparent : colorScheme.primary)
            : colorScheme.outlineVariant,
        hasGlow: isPrimary && !isDisabled,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Center(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (icon != null) ...[
                Icon(icon, color: textColor, size: 20),
                const SizedBox(width: 8),
              ],
              Text(
                label,
                style: TextStyle(
                  color: textColor,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
