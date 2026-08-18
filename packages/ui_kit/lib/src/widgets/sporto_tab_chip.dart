// ============================================================
// sporto_tab_chip.dart
// Tab pill used for sub-navigation between tabs.
// ============================================================
import 'package:flutter/material.dart';
import '../assets/sporto_assets.dart';
import 'sporto_card.dart';

class SportoTabChip extends StatelessWidget {
  final String label;
  final IconData? icon;
  final String? asset;
  final bool active;
  final VoidCallback onTap;

  const SportoTabChip({
    super.key,
    required this.label,
    this.icon,
    this.asset,
    this.active = false,
    required this.onTap,
  }) : assert(icon == null || asset == null,
            'Use either icon or asset for SportoTabChip, not both.');

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color:
              active
                  ? cs.secondary
                  : SportoCard.defaultFill.withValues(alpha: 0.6),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: active ? Colors.transparent : SportoCard.defaultBorder,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (asset != null || icon != null) ...[
              if (asset != null)
                SportoAssetIcon(
                  asset!,
                  size: 16,
                )
              else
                Icon(icon,
                    size: 16,
                    color: active ? Colors.white : cs.onSurfaceVariant),
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
