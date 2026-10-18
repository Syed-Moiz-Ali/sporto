import 'package:flutter/material.dart';

import '../theme/sporto_design_tokens.dart';
import '../theme/sporto_text_styles.dart';
import 'sporto_glass_surface.dart';

/// Stat chip (Figma `STAT CHIPS / Background+Border`): 107x54, r16, gold
/// gradient fill with a warm hairline. Used on the referee profile.
class SportoStatChip extends StatelessWidget {
  final String value;
  final String label;
  final Widget? icon;

  const SportoStatChip({
    super.key,
    required this.value,
    required this.label,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final tokens = context.sporto;
    final layout = context.sportoLayout;
    return SportoGlassSurface(
      radius: layout.radius16,
      gradient: LinearGradient(
        colors: tokens.gradientGold.colors
            .map((c) => c.withValues(alpha: 0.1))
            .toList(),
      ),
      borderColor: tokens.hairlineWarm.withValues(alpha: 0.08),
      padding: const EdgeInsets.all(10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[icon!, const SizedBox(width: 2)],
              Text(
                value,
                style: SportoTextStyles.text(
                  size: SportoTextStyles.size18,
                  weight: SportoTextStyles.semiBold,
                  color: Theme.of(context).colorScheme.onSurface,
                  height: 1.0,
                ),
              ),
            ],
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: SportoTextStyles.text(
              size: SportoTextStyles.size13,
              weight: SportoTextStyles.medium,
              color: tokens.muted,
              height: 1.0,
            ),
          ),
        ],
      ),
    );
  }
}
