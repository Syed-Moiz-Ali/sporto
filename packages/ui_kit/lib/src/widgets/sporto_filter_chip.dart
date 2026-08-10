// ============================================================
// sporto_filter_chip.dart
// Selectable chip used for filters & option picking.
// ============================================================
import 'package:flutter/material.dart';
import '../theme/sporto_design_tokens.dart';

enum SportoFilterChipType {
  /// Compact border-only chip used in filter rows.
  filter,

  /// Larger filled pill with optional check mark (option picking).
  pill,
}

class SportoFilterChip extends StatelessWidget {
  final String label;
  final bool active;
  final VoidCallback? onTap;
  final IconData? icon;
  final bool hasCheck;
  final bool inactiveFill;
  final SportoFilterChipType type;
  final Color? activeColor;

  const SportoFilterChip({
    super.key,
    required this.label,
    this.active = false,
    this.onTap,
    this.icon,
    this.hasCheck = false,
    this.inactiveFill = false,
    this.type = SportoFilterChipType.filter,
    this.activeColor,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tokens = context.sporto;
    final color = activeColor ?? cs.secondary;

    final isPill = type == SportoFilterChipType.pill;
    final radius = isPill ? 9.0 : 12.0;
    final padding = isPill
        ? const EdgeInsets.symmetric(horizontal: 14, vertical: 10)
        : const EdgeInsets.symmetric(horizontal: 12, vertical: 6);
    final fontSize = isPill ? 13.0 : 12.0;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: padding,
        decoration: BoxDecoration(
          color: active
              ? (isPill ? color.withValues(alpha: 0.055) : Colors.transparent)
              : (inactiveFill ? tokens.field : Colors.transparent),
          borderRadius: BorderRadius.circular(radius),
          border: Border.all(
            color: active
                ? color.withValues(alpha: 0.26)
                : tokens.border.withValues(alpha: .42),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 16, color: active ? color : cs.onSurfaceVariant),
              const SizedBox(width: 6),
            ],
            Text(label,
                style: TextStyle(
                    color: active ? color : cs.onSurfaceVariant,
                    fontSize: fontSize,
                    fontWeight: FontWeight.w500)),
            if (hasCheck && active) ...[
              const SizedBox(width: 6),
              Icon(Icons.check_rounded, color: color, size: 16),
            ],
          ],
        ),
      ),
    );
  }
}
