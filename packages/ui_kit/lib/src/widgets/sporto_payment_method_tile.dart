import 'package:flutter/material.dart';

import '../theme/sporto_design_tokens.dart';
import '../theme/sporto_text_styles.dart';
import 'sporto_glass_surface.dart';

/// Payment method tile (Figma `Frame 31` unselected / `Frame 29` selected):
/// height 50, r14/15, leading 24px icon + light label.
class SportoPaymentMethodTile extends StatelessWidget {
  final String label;
  final Widget icon;
  final bool selected;
  final VoidCallback? onTap;
  final double? width;

  const SportoPaymentMethodTile({
    super.key,
    required this.label,
    required this.icon,
    this.selected = false,
    this.onTap,
    this.width,
  });

  static const LinearGradient selectedGradient = LinearGradient(
    colors: [Color(0xFF171C26), Color(0xFF3D424C)],
  );

  @override
  Widget build(BuildContext context) {
    final tokens = context.sporto;
    final layout = context.sportoLayout;
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: SportoGlassSurface(
        width: width,
        height: 50,
        radius: selected ? layout.radius16 : layout.radius14,
        gradient: selected ? selectedGradient : null,
        color: selected ? null : tokens.cardElevated,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          children: [
            icon,
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: SportoTextStyles.text(
                  size: SportoTextStyles.size16,
                  weight: SportoTextStyles.medium,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
