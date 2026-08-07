// ============================================================
// sporto_tab_chip.dart
// Tab pill used for sub-navigation between tabs.
// ============================================================
import 'package:flutter/material.dart';
import 'sporto_card.dart';

class SportoTabChip extends StatelessWidget {
  final String label;
  final IconData? icon;
  final bool active;
  final VoidCallback onTap;

  const SportoTabChip({
    super.key,
    required this.label,
    this.icon,
    this.active = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: active ? cs.secondary : SportoCard.defaultFill.withOpacity(0.6),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: active ? Colors.transparent : SportoCard.defaultBorder,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon,
                  size: 16, color: active ? Colors.white : cs.onSurfaceVariant),
              const SizedBox(width: 6),
            ],
            Text(
              label,
              style: TextStyle(
                color: active ? Colors.white : cs.onSurfaceVariant,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
