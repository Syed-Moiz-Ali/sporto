// ============================================================
// sporto_bottom_nav.dart
// Docked bottom navigation bar with active glow + underline.
// ============================================================
import 'package:flutter/material.dart';
import '../theme/sporto_design_tokens.dart';

class SportoNavItem {
  final IconData icon;
  final String label;

  const SportoNavItem(this.icon, this.label);
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
    return Container(
      height: 60,
      decoration: BoxDecoration(
        color: context.sporto.card.withValues(alpha: 0.98),
        border: Border(top: BorderSide(color: context.sporto.border)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
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
                      Icon(item.icon,
                          color: isActive ? cs.tertiary : cs.onSurfaceVariant,
                          size: 24),
                      const SizedBox(height: 4),
                      Text(item.label,
                          style:
                              Theme.of(context).textTheme.labelSmall?.copyWith(
                                    color: isActive
                                        ? cs.tertiary
                                        : cs.onSurfaceVariant,
                                    fontWeight: isActive
                                        ? FontWeight.w600
                                        : FontWeight.normal,
                                  )),
                      if (isActive)
                        Container(
                          margin: const EdgeInsets.only(top: 2),
                          width: 20,
                          height: 3,
                          decoration: BoxDecoration(
                            color: cs.tertiary,
                            borderRadius: BorderRadius.circular(
                                context.sportoLayout.space2),
                          ),
                        )
                      else
                        const SizedBox(height: 5),
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
