import 'package:flutter/material.dart';

import '../theme/sporto_design_tokens.dart';
import '../theme/sporto_text_styles.dart';
import 'sporto_doc_card.dart';

/// A single label/value row inside a price summary card.
class SportoPriceRow {
  final String label;
  final String value;
  final Color? valueColor;

  const SportoPriceRow(this.label, this.value, {this.valueColor});
}

/// Price summary card (Figma `DocCard` payment block): label/value rows,
/// a hairline, and a highlighted total row.
class SportoPriceSummaryCard extends StatelessWidget {
  final List<SportoPriceRow> rows;
  final String? totalLabel;
  final String? totalValue;

  const SportoPriceSummaryCard({
    super.key,
    required this.rows,
    this.totalLabel,
    this.totalValue,
  });

  @override
  Widget build(BuildContext context) {
    final tokens = context.sporto;
    final hasTotal = totalLabel != null && totalValue != null;

    return SportoDocCard(
      plain: true,
      padding: const EdgeInsets.all(14),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (final row in rows) ...[
            _row(context, row.label, row.value, row.valueColor ?? tokens.muted),
            const SizedBox(height: 10),
          ],
          if (hasTotal) ...[
            Container(height: 1, color: tokens.border.withValues(alpha: 0.5)),
            const SizedBox(height: 10),
            _row(
              context,
              totalLabel!,
              totalValue!,
              Theme.of(context).colorScheme.onSurface,
              valueSize: SportoTextStyles.size18,
            ),
          ],
        ],
      ),
    );
  }

  Widget _row(BuildContext context, String label, String value, Color color,
      {double valueSize = SportoTextStyles.size15}) {
    final tokens = context.sporto;
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: SportoTextStyles.text(
              size: SportoTextStyles.size15,
              weight: SportoTextStyles.medium,
              color: tokens.muted,
            ),
          ),
        ),
        Text(
          value,
          style: SportoTextStyles.text(
            size: valueSize,
            weight: SportoTextStyles.medium,
            color: color,
          ),
        ),
      ],
    );
  }
}
