// ============================================================
// sporto_stat_card.dart
// Value + label stat box used in overview grids.
// ============================================================
import 'package:flutter/material.dart';
import 'sporto_card.dart';

class SportoStatCard extends StatelessWidget {
  final String label;
  final String value;
  final bool highlight;
  final Color? highlightColor;
  final Color? color;

  /// When provided, a small status dot renders before the value.
  final Color? dotColor;

  final double fontSize;
  final double labelSize;
  final EdgeInsetsGeometry padding;
  final CrossAxisAlignment alignment;

  const SportoStatCard({
    super.key,
    required this.label,
    required this.value,
    this.highlight = false,
    this.highlightColor,
    this.color,
    this.dotColor,
    this.fontSize = 20,
    this.labelSize = 10,
    this.padding = const EdgeInsets.all(12),
    this.alignment = CrossAxisAlignment.center,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final valueColor =
        highlight ? (highlightColor ?? cs.secondary) : (color ?? cs.onSurface);

    final valueWidget = dotColor != null
        ? Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 6,
                height: 6,
                decoration:
                    BoxDecoration(shape: BoxShape.circle, color: dotColor),
              ),
              const SizedBox(width: 6),
              Text(value,
                  style: TextStyle(
                      fontSize: fontSize,
                      fontWeight: FontWeight.w700,
                      color: valueColor)),
            ],
          )
        : Text(value,
            style: TextStyle(
                fontSize: fontSize,
                fontWeight: FontWeight.w700,
                color: valueColor));

    return SportoCard(
      padding: padding,
      child: Column(
        crossAxisAlignment: alignment,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          valueWidget,
          const SizedBox(height: 4),
          Text(label,
              textAlign: alignment == CrossAxisAlignment.center
                  ? TextAlign.center
                  : TextAlign.start,
              style:
                  TextStyle(fontSize: labelSize, color: cs.onSurfaceVariant)),
        ],
      ),
    );
  }
}
