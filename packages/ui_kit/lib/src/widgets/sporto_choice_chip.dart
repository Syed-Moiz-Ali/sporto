import 'package:flutter/material.dart';

import '../theme/sporto_design_tokens.dart';
import '../theme/sporto_text_styles.dart';
import 'sporto_glass_surface.dart';

/// Selectable option chip (Figma date/time/duration rows): r40, height 31.
/// Selected = gold fill + dark label; unselected = `#1C2026` + light label.
class SportoChoiceChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback? onTap;

  const SportoChoiceChip({
    super.key,
    required this.label,
    this.selected = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final tokens = context.sporto;
    final layout = context.sportoLayout;
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: SportoGlassSurface(
        radius: layout.radiusFull,
        color: selected ? tokens.gold : tokens.cardElevated,
        borderGradient: selected ? SportoGlassBorders.gold : SportoGlassBorders.goldSoft,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Text(
          label,
          style: SportoTextStyles.text(
            size: SportoTextStyles.size15,
            weight: SportoTextStyles.medium,
            color: selected ? tokens.canvas : Theme.of(context).colorScheme.onSurface,
            height: 1.0,
          ),
        ),
      ),
    );
  }
}
