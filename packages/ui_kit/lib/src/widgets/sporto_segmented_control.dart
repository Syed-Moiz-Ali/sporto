// ============================================================
// sporto_segmented_control.dart
// Segmented pill control used for tab switching.
// ============================================================
import 'package:flutter/material.dart';
import 'sporto_card.dart';

class SportoSegmentedControl extends StatelessWidget {
  final List<String> items;
  final int selectedIndex;
  final ValueChanged<int> onChanged;
  final double height;

  const SportoSegmentedControl({
    super.key,
    required this.items,
    required this.selectedIndex,
    required this.onChanged,
    this.height = 44,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      height: height,
      decoration: BoxDecoration(
        color: SportoCard.defaultFill.withOpacity(0.6),
        borderRadius: BorderRadius.circular(height / 2),
        border: Border.all(color: SportoCard.defaultBorder),
      ),
      child: Row(
        children: List.generate(items.length, (i) {
          final isSelected = selectedIndex == i;
          return Expanded(
            child: GestureDetector(
              onTap: () => onChanged(i),
              child: Container(
                decoration: BoxDecoration(
                  color: isSelected ? cs.primary : Colors.transparent,
                  borderRadius:
                      BorderRadius.circular(height / 2 - 2),
                ),
                alignment: Alignment.center,
                child: Text(
                  items[i],
                  style: TextStyle(
                    color: isSelected ? Colors.black : cs.onSurfaceVariant,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
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
