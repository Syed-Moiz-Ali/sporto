// ============================================================
// secondary_button.dart
// Dark glass button used for secondary actions.
// ============================================================
import 'package:flutter/material.dart';
import 'sporto_text_field.dart';

class SecondaryButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final double height;
  final double radius;
  final double? width;
  final double? widthFactor;

  const SecondaryButton({
    super.key,
    required this.label,
    this.onPressed,
    this.height = 56,
    this.radius = 16,
    this.width,
    this.widthFactor,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
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
            color: SportoTextField.inputFill,
            borderRadius: BorderRadius.circular(radius),
            border: Border.all(color: SportoTextField.inputBorder),
          ),
          alignment: Alignment.center,
          child: Text(label,
              style: TextStyle(
                  color: cs.onSurface,
                  fontSize: 16,
                  fontWeight: FontWeight.w600)),
        ),
      ),
    );
  }
}
