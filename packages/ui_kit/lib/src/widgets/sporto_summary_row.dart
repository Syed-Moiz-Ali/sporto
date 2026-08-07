// ============================================================
// sporto_summary_row.dart
// Label / value row used in summary & finance sections.
// ============================================================
import 'package:flutter/material.dart';

class SportoSummaryRow extends StatelessWidget {
  final String label;
  final String value;
  final bool highlight;
  final bool boldValue;
  final Color? valueColor;

  const SportoSummaryRow({
    super.key,
    required this.label,
    required this.value,
    this.highlight = false,
    this.boldValue = false,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: TextStyle(
                  color: highlight ? cs.tertiary : cs.onSurfaceVariant,
                  fontSize: 13,
                  fontWeight: highlight ? FontWeight.w700 : FontWeight.normal)),
          Text(value,
              style: TextStyle(
                  color: valueColor ??
                      (highlight ? cs.tertiary : cs.onSurface),
                  fontSize: 13,
                  fontWeight:
                      highlight || boldValue ? FontWeight.w700 : FontWeight.normal)),
        ],
      ),
    );
  }
}
