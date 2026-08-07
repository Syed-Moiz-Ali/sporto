// ============================================================
// sporto_quick_action.dart
// Icon button with label below, used in quick-action rows.
// ============================================================
import 'package:flutter/material.dart';
import 'glass_container.dart';
import 'sporto_card.dart';

class SportoQuickAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onTap;

  const SportoQuickAction({
    super.key,
    required this.icon,
    required this.label,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
        children: [
          GlassContainer(
            width: 64,
            height: 64,
            borderRadius: 16,
            blur: 14,
            borderWidth: 1,
            borderColor: SportoCard.defaultBorder,
            backgroundColor: SportoCard.defaultFill.withOpacity(0.6),
            padding: EdgeInsets.zero,
            child: Center(
              child: Icon(icon, color: cs.tertiary, size: 26),
            ),
          ),
          const SizedBox(height: 8),
          Text(label,
              textAlign: TextAlign.center,
              style: TextStyle(color: cs.onSurface, fontSize: 11, height: 1.3)),
        ],
      ),
    );
  }
}
