import 'package:flutter/material.dart';

import '../theme/sporto_design_tokens.dart';
import '../theme/sporto_text_styles.dart';
import 'sporto_glass_surface.dart';

/// Filter/sort chip (Figma `Frame 1261154416/17`): r10, height 22.
/// Selected = green fill + dark label; unselected = `#1C2026` + light label.
class SportoSortChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback? onTap;

  const SportoSortChip({
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
        radius: layout.radius10,
        blur: layout.glassBlur,
        color: selected ? tokens.accentGreen : tokens.cardElevated,
        borderGradient: SportoGlassBorders.green,
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Text(
          label,
          style: SportoTextStyles.text(
            size: SportoTextStyles.size14,
            weight: SportoTextStyles.medium,
            color: selected ? tokens.canvas : Theme.of(context).colorScheme.onSurface,
            height: 1.0,
          ),
        ),
      ),
    );
  }
}
