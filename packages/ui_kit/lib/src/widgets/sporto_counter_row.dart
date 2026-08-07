// ============================================================
// sporto_counter_row.dart
// Label + stepper (+/-) control used in config forms.
// ============================================================
import 'package:flutter/material.dart';
import 'sporto_text_field.dart';

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
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: SportoTextField.inputFill,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: SportoTextField.inputBorder),
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: TextStyle(
                color: cs.onSurface, fontSize: 14, fontWeight: FontWeight.w500)),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SportoStepperButton(icon: Icons.remove, onPressed: onMinus),
            const SizedBox(width: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              decoration: BoxDecoration(
                color: SportoTextField.inputFill,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: SportoTextField.inputBorder),
              ),
              child: Text(value,
                  style: TextStyle(
                      color: cs.onSurface,
                      fontSize: 16,
                      fontWeight: FontWeight.w700)),
            ),
            const SizedBox(width: 16),
            SportoStepperButton(icon: Icons.add, onPressed: onPlus),
          ],
        ),
      ],
    );
  }
}
