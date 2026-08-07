// ============================================================
// sporto_check_circle.dart
// Ring-style check indicator used in status/review lists.
// ============================================================
import 'package:flutter/material.dart';

class SportoCheckCircle extends StatelessWidget {
  static const Color inactiveBorder = Color(0xFF4A5160);

  final bool done;

  const SportoCheckCircle({super.key, required this.done});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      width: 22,
      height: 22,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: done ? cs.secondary : inactiveBorder,
          width: 1.6,
        ),
      ),
      alignment: Alignment.center,
      child: done
          ? Icon(Icons.check_rounded, color: cs.secondary, size: 14)
          : null,
    );
  }
}
