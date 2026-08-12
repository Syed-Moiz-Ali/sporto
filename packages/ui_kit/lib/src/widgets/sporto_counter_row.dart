// ============================================================
// sporto_counter_row.dart
// Label + stepper (+/-) control used in config forms.
// ============================================================
import 'package:flutter/material.dart';
import '../theme/sporto_design_tokens.dart';

class SportoStepperButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;

  const SportoStepperButton({
    super.key,
    required this.icon,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tokens = context.sporto;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: tokens.field,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: tokens.fieldBorder),
          ),
          alignment: Alignment.center,
          child: Icon(icon, color: cs.onSurface),
        ),
      ),
    );
  }
}

class SportoCounterRow extends StatelessWidget {
  final String label;
  final String value;
  final VoidCallback onMinus;
  final VoidCallback onPlus;

  const SportoCounterRow({
    super.key,
    required this.label,
    required this.value,
    required this.onMinus,
    required this.onPlus,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tokens = context.sporto;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: TextStyle(
                color: cs.onSurface,
                fontSize: 14,
                fontWeight: FontWeight.w500)),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            SportoStepperButton(icon: Icons.remove, onPressed: onMinus),
            const SizedBox(width: 12),
            Container(
              width: 140,
              height: 40,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: tokens.field,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: tokens.fieldBorder),
              ),
              child: Text(value,
                  style: TextStyle(
                      color: cs.onSurface,
                      fontSize: 16,
                      fontWeight: FontWeight.w600)),
            ),
            const SizedBox(width: 12),
            SportoStepperButton(icon: Icons.add, onPressed: onPlus),
          ],
        ),
      ],
    );
  }
}
