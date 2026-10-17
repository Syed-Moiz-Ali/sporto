import 'package:flutter/material.dart';

import '../theme/sporto_design_tokens.dart';
import '../theme/sporto_text_styles.dart';
import 'sporto_glass_surface.dart';

/// Tag chip (Figma `Bars / Nav Bars: Large`): height 32, r14, `#283040` @0.5
/// fill, white-gradient hairline and a muted label.
class SportoTagChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback? onTap;

  const SportoTagChip({
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
        radius: layout.radius14,
        blur: layout.glassBlur,
        color: selected ? tokens.accentGreen.withValues(alpha: 0.16) : tokens.border.withValues(alpha: 0.5),
        borderGradient: SportoGlassBorders.white,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        child: Text(
          label,
          style: SportoTextStyles.text(
            size: SportoTextStyles.size14,
            weight: SportoTextStyles.medium,
            color: selected ? tokens.accentGreen : tokens.muted,
            height: 1.1,
          ),
        ),
      ),
    );
  }
}
