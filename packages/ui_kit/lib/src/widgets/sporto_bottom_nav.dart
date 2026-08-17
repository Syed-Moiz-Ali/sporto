// ============================================================
// sporto_bottom_nav.dart
// Docked bottom navigation bar with active glow + underline.
// ============================================================
import 'package:flutter/material.dart';
import '../assets/sporto_assets.dart';
import '../theme/sporto_design_tokens.dart';
import 'sporto_responsive_layout.dart';

class SportoNavItem {
  final IconData? icon;
  final String label;
  final String? asset;

  const SportoNavItem(this.icon, this.label) : asset = null;

  const SportoNavItem.asset({
    required this.asset,
    required this.label,
  }) : icon = null;
}

class SportoBottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  final List<SportoNavItem> items;

  const SportoBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final scale = context.sportoScale;
    final metrics = context.sportoResponsive;
    final bottomInset = MediaQuery.paddingOf(context).bottom;
    final isFloating = metrics.isTablet;
    final iconSize = (22) * scale;
    final labelSize = (11) * scale;
    final indicatorWidth = (18) * scale;

    final availableWidth = MediaQuery.sizeOf(context).width -
        metrics.horizontalPadding * 2 -
        MediaQuery.paddingOf(context).horizontal;
    final itemWidth = 76 * scale;
    final floatingWidth = (items.length * itemWidth + 18 * scale)
        .clamp(0, metrics.navMaxWidth)
        .clamp(0, availableWidth)
        .toDouble();

    return Container(
      width: isFloating ? floatingWidth : double.infinity,
      height: metrics.bottomNavHeight + (isFloating ? 0 : bottomInset),
      margin: isFloating
          ? EdgeInsets.symmetric(horizontal: metrics.horizontalPadding)
          : EdgeInsets.zero,
      padding: EdgeInsets.fromLTRB(
        8 * scale,
        0,
        8 * scale,
        isFloating ? 0 : bottomInset,
      ),
      decoration: BoxDecoration(
        color: context.sporto.navSurface.withValues(
          alpha: isFloating ? 0.96 : 0.98,
        ),
        borderRadius: isFloating ? BorderRadius.circular(22 * scale) : null,
        border: isFloating
            ? Border.all(color: context.sporto.border)
            : Border(top: BorderSide(color: context.sporto.border)),
        boxShadow: isFloating
            ? [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.28),
                  blurRadius: 18 * scale,
                  offset: Offset(0, 8 * scale),
                ),
              ]
            : [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.20),
                  blurRadius: 14 * scale,
                  offset: Offset(0, -4 * scale),
                ),
              ],
      ),
      child: Row(
        children: List.generate(items.length, (i) {
          final item = items[i];
          final isActive = i == currentIndex;
          return Expanded(
            child: Semantics(
              button: true,
              selected: isActive,
              label: item.label,
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () => onTap(i),
                  splashColor: cs.tertiary.withValues(alpha: .10),
                  highlightColor: cs.tertiary.withValues(alpha: .06),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (item.asset != null)
                        _ActiveNavAssetIcon(
                          asset: item.asset!,
                          active: isActive,
                          size: iconSize,
                        )
                      else
                        Icon(item.icon,
                            color: isActive ? cs.tertiary : cs.onSurfaceVariant,
                            size: iconSize),
                      SizedBox(height: 3 * scale),
                      Text(
                        item.label,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                              color:
                                  isActive ? cs.tertiary : cs.onSurfaceVariant,
                              fontSize: labelSize,
                              fontWeight: isActive
                                  ? FontWeight.w500
                                  : FontWeight.normal,
                            ),
                      ),
                      if (isActive)
                        Container(
                          margin: EdgeInsets.only(top: 2 * scale),
                          width: indicatorWidth,
                          height: 3 * scale,
                          decoration: BoxDecoration(
                            color: cs.tertiary,
                            borderRadius: BorderRadius.circular(
                                context.sportoLayout.space2),
                          ),
                        )
                      else
                        SizedBox(height: 5 * scale),
                    ],
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}

class _ActiveNavAssetIcon extends StatelessWidget {
  final String asset;
  final bool active;
  final double size;

  const _ActiveNavAssetIcon({
    required this.asset,
    required this.active,
    required this.size,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final color = active ? cs.tertiary : cs.onSurfaceVariant;

    if (!active) {
      return SportoAssetIcon(asset, color: color, size: size);
    }

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          SportoAssetIcon(
            asset,
            color: color.withValues(alpha: .34),
            size: size * 1.08,
          ),
          SportoAssetIcon(asset, color: color, size: size),
        ],
      ),
    );
  }
}
