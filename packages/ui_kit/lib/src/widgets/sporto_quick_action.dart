// ============================================================
// sporto_quick_action.dart
// Icon button with label below, used in quick-action rows.
// ============================================================
import 'package:flutter/material.dart';
import '../assets/sporto_assets.dart';
import '../theme/sporto_design_tokens.dart';
import 'glass_container.dart';

class SportoQuickAction extends StatelessWidget {
  final IconData? icon;
  final String? asset;
  final String label;
  final VoidCallback? onTap;
  final double? width;

  const SportoQuickAction({
    super.key,
    this.icon,
    this.asset,
    required this.label,
    this.onTap,
    this.width,
  }) : assert(icon != null || asset != null);

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final scale = context.sportoScale;
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: GlassContainer(
        width: width ?? 78 * scale,
        height: 78 * scale,
        borderRadius: 14 * scale,
        blur: 14 * scale,
        borderWidth: scale,
        borderColor: context.sporto.fieldBorder,
        backgroundColor: context.sporto.card.withValues(alpha: .92),
        padding: EdgeInsets.symmetric(
          horizontal: 4 * scale,
          vertical: 8 * scale,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (asset != null)
              SportoAssetIcon(asset!, size: 26 * scale)
            else
              Icon(icon, color: cs.tertiary, size: 26 * scale),
            SizedBox(height: 5 * scale),
            Text(
              label,
              textAlign: TextAlign.center,
              maxLines: 2,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: cs.onSurface,
                    fontSize: 11 * scale,
                    height: 1.15,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
