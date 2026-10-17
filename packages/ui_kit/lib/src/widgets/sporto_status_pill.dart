import 'package:flutter/material.dart';

import '../theme/sporto_design_tokens.dart';
import '../theme/sporto_text_styles.dart';
import 'sporto_glass_surface.dart';

/// Small gradient status pill (Figma `Frame 1261154583`): r50, height 19,
/// gradient fill + matching gradient hairline, an optional 12px leading icon
/// and a 13px label.
class SportoStatusPill extends StatelessWidget {
  final String label;
  final LinearGradient gradient;
  final Widget? leading;

  const SportoStatusPill({
    super.key,
    required this.label,
    required this.gradient,
    this.leading,
  });

  /// Figma orange variant `#FF9364 -> #F25F33`.
  static const LinearGradient orange = LinearGradient(
    colors: [Color(0xFFFF9364), Color(0xFFF25F33)],
  );

  /// Figma blue variant `#7AD3FF -> #4FBAF0`.
  static const LinearGradient blue = LinearGradient(
    colors: [Color(0xFF7AD3FF), Color(0xFF4FBAF0)],
  );

  /// Figma green variant `#2BB673`.
  static const LinearGradient green = LinearGradient(
    colors: [Color(0xFF2BB673), Color(0xFF2BB673)],
  );

  @override
  Widget build(BuildContext context) {
    final layout = context.sportoLayout;
    return SportoGlassSurface(
      radius: layout.radiusFull,
      gradient: gradient,
      borderGradient: gradient,
      borderWidth: 1,
      padding: const EdgeInsets.fromLTRB(3, 2, 5, 2),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (leading != null) ...[
            leading!,
            const SizedBox(width: 3),
          ],
          Text(
            label,
            style: SportoTextStyles.text(
              size: SportoTextStyles.size13,
              weight: SportoTextStyles.medium,
              color: Theme.of(context).colorScheme.onSurface,
              height: 1.0,
            ),
          ),
        ],
      ),
    );
  }
}
