// ============================================================
// sporto_check_box.dart
// Square checkbox used in confirm/selection rows.
// ============================================================
import 'package:flutter/material.dart';
import 'sporto_check_circle.dart';

class SportoCheckBox extends StatelessWidget {
  final bool checked;

  const SportoCheckBox({super.key, required this.checked});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      width: 22,
      height: 22,
      decoration: BoxDecoration(
        color: checked ? cs.secondary : Colors.transparent,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: checked ? cs.secondary : SportoCheckCircle.inactiveBorder,
          width: 1.5,
        ),
      ),
      alignment: Alignment.center,
      child: checked
          ? const Icon(Icons.check_rounded, color: Colors.white, size: 14)
          : null,
    );
  }
}
