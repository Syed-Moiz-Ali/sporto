// ============================================================
// sporto_info_row.dart
// Label / value row with optional highlighted suffix.
// ============================================================
import 'package:flutter/material.dart';

class SportoInfoRow extends StatelessWidget {
  final String label;
  final String value;
  final String? suffix;
  final EdgeInsetsGeometry padding;

  const SportoInfoRow({
    super.key,
    required this.label,
    required this.value,
    this.suffix,
    this.padding = const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: padding,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: TextStyle(color: cs.onSurfaceVariant, fontSize: 14)),
          const SizedBox(width: 12),
          Expanded(
            child: RichText(
                textAlign: TextAlign.end,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                text: TextSpan(
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                    children: [
                      TextSpan(
                          text: value, style: TextStyle(color: cs.onSurface)),
                      if (suffix != null)
                        TextSpan(
                            text: suffix,
                            style: TextStyle(
                                color: cs.tertiary,
                                fontWeight: FontWeight.normal)),
                    ])),
          ),
        ],
      ),
    );
  }
}
