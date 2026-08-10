// ============================================================
// secondary_button.dart
// Dark glass button used for secondary actions.
// ============================================================
import 'package:flutter/material.dart';
import '../theme/sporto_design_tokens.dart';

class SecondaryButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final double height;
  final double radius;
  final double? width;
  final double? widthFactor;

  const SecondaryButton({
    super.key,
    required this.label,
    this.onPressed,
    this.icon,
    this.height = 56,
    this.radius = 16,
    this.width,
    this.widthFactor,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tokens = context.sporto;
    final effectiveWidth = width ??
        (widthFactor != null
            ? MediaQuery.of(context).size.width * widthFactor!
            : double.infinity);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(radius),
        child: Container(
          width: effectiveWidth,
          height: height,
          decoration: BoxDecoration(
            color: tokens.field,
            borderRadius: BorderRadius.circular(radius),
            border: Border.all(color: tokens.fieldBorder),
          ),
          alignment: Alignment.center,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (icon != null) ...[
                Icon(icon, color: cs.onSurfaceVariant, size: 20),
                const SizedBox(width: 8),
              ],
              Text(label,
                  style: TextStyle(
                      color: cs.onSurface,
                      fontSize: 16,
                      fontWeight: FontWeight.w600)),
            ],
          ),
        ),
      ),
    );
  }
}
