import 'package:flutter/material.dart';
import 'package:ui_kit/ui_kit.dart';

/// Underlined text tabs used by the tournament detail screen.
class TournamentUnderlineTabs extends StatelessWidget {
  const TournamentUnderlineTabs({
    super.key,
    required this.labels,
    required this.selectedIndex,
    required this.onChanged,
    this.padding = EdgeInsets.zero,
    this.spacing = 20,
    this.accentColor,
  });

  final List<String> labels;
  final int selectedIndex;
  final ValueChanged<int> onChanged;
  final EdgeInsetsGeometry padding;
  final double spacing;
  final Color? accentColor;

  @override
  Widget build(BuildContext context) {
    final t = context.sportoTournament;
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: padding,
      child: Row(
        children: [
          for (var i = 0; i < labels.length; i++) ...[
            GestureDetector(
              onTap: () => onChanged(i),
              behavior: HitTestBehavior.opaque,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    labels[i],
                    style: SportoTextStyles.text(
                      size: SportoTextStyles.size15,
                      weight: i == selectedIndex
                          ? FontWeight.w600
                          : FontWeight.w500,
                      color: i == selectedIndex
                          ? (accentColor ?? t.gold)
                          : t.muted,
                    ),
                  ),
                  const SizedBox(height: 8),
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    width: i == selectedIndex ? 18 : 0,
                    height: 2,
                    decoration: BoxDecoration(
                      color: accentColor ?? t.gold,
                      borderRadius: BorderRadius.circular(99),
                    ),
                  ),
                ],
              ),
            ),
            if (i != labels.length - 1) SizedBox(width: spacing),
          ],
        ],
      ),
    );
  }
}

/// Green-dot style tab used in the "Applications" tournament list.
class TournamentDotTab extends StatelessWidget {
  const TournamentDotTab({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
    this.dotColor,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;
  final Color? dotColor;

  @override
  Widget build(BuildContext context) {
    final t = context.sportoTournament;
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          gradient: selected ? t.greenPillGradient : null,
          color: selected ? null : t.card,
          borderRadius: BorderRadius.circular(t.r9),
          border: Border.all(color: selected ? t.green : t.border),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (dotColor != null) ...[
              Container(
                width: 7,
                height: 7,
                decoration:
                    BoxDecoration(color: dotColor, shape: BoxShape.circle),
              ),
              const SizedBox(width: 6),
            ],
            Text(
              label,
              style: SportoTextStyles.text(
                size: SportoTextStyles.size12,
                weight: FontWeight.w600,
                color: selected ? t.screenBase : t.warm,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Pill filter chip used for rounds, teams and stats filters.
class TournamentFilterChip extends StatelessWidget {
  const TournamentFilterChip({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
    this.selectedColor,
    this.selectedForeground,
    this.height = 34,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;
  final Color? selectedColor;
  final Color? selectedForeground;
  final double height;

  @override
  Widget build(BuildContext context) {
    final t = context.sportoTournament;
    final bg = selectedColor ??
        (selected ? t.completed.withValues(alpha: .16) : t.card);
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        height: height,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(100),
          border: Border.all(
            color: selected
                ? (selectedForeground ?? t.completed).withValues(alpha: .65)
                : t.border,
          ),
        ),
        child: Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: SportoTextStyles.text(
            size: SportoTextStyles.size12,
            weight: selected ? FontWeight.w600 : FontWeight.w500,
            color: selected ? (selectedForeground ?? t.completed) : t.muted,
          ),
        ),
      ),
    );
  }
}

/// Three-way segmented control used by the Stats tab.
class TournamentSegmentedControl extends StatelessWidget {
  const TournamentSegmentedControl({
    super.key,
    required this.labels,
    required this.selectedIndex,
    required this.onChanged,
  });

  final List<String> labels;
  final int selectedIndex;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    final t = context.sportoTournament;
    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: t.card,
        borderRadius: BorderRadius.circular(100),
        border: Border.all(color: t.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (var i = 0; i < labels.length; i++)
            GestureDetector(
              onTap: () => onChanged(i),
              behavior: HitTestBehavior.opaque,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  gradient: i == selectedIndex ? t.greenPillGradient : null,
                  borderRadius: BorderRadius.circular(100),
                ),
                child: Text(
                  labels[i],
                  style: SportoTextStyles.text(
                    size: SportoTextStyles.size12,
                    weight: FontWeight.w600,
                    color: i == selectedIndex ? t.screenBase : t.warm,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// Horizontal sub-tab row used by Stats and Financials.
class TournamentSubTabs extends StatelessWidget {
  const TournamentSubTabs({
    super.key,
    required this.labels,
    required this.selectedIndex,
    required this.onChanged,
    this.accentColor,
  });

  final List<String> labels;
  final int selectedIndex;
  final ValueChanged<int> onChanged;
  final Color? accentColor;

  @override
  Widget build(BuildContext context) {
    final t = context.sportoTournament;
    final accent = accentColor ?? t.pink;
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          for (var i = 0; i < labels.length; i++)
            GestureDetector(
              onTap: () => onChanged(i),
              behavior: HitTestBehavior.opaque,
              child: Padding(
                padding: EdgeInsets.only(
                  right: i == labels.length - 1 ? 0 : 20,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      labels[i],
                      style: SportoTextStyles.text(
                        size: SportoTextStyles.size15,
                        weight: i == selectedIndex
                            ? FontWeight.w600
                            : FontWeight.w500,
                        color: i == selectedIndex ? accent : t.muted,
                      ),
                    ),
                    const SizedBox(height: 7),
                    Container(
                      width: i == selectedIndex ? 4 : 0,
                      height: 4,
                      decoration: BoxDecoration(
                        color: accent,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
