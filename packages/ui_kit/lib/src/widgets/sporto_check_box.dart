import 'package:flutter/material.dart';

import 'sporto_check_circle.dart';

class SportoCheckBox extends StatelessWidget {
  final bool checked;
  final bool enabled;

  final double size;
  final double radius;
  final double checkSize;

  final Color? activeColor;

  const SportoCheckBox({
    super.key,
    required this.checked,
    this.enabled = true,
    this.size = 22,
    this.radius = 6,
    this.checkSize = 14,
    this.activeColor,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    final selectedColor = activeColor ?? cs.secondary;

    final borderColor =
        checked ? selectedColor : SportoCheckCircle.inactiveBorder;

    return Opacity(
      opacity: enabled ? 1 : .55,
      child: AnimatedContainer(
        duration: const Duration(
          milliseconds: 160,
        ),
        width: size,
        height: size,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: checked ? selectedColor : Colors.transparent,
          borderRadius: BorderRadius.circular(radius),
          border: Border.all(
            color: borderColor,
            width: 1.3,
          ),
        ),
        child: checked
            ? Icon(
                Icons.check_rounded,
                color: Colors.white,
                size: checkSize,
              )
            : null,
      ),
    );
  }
}
