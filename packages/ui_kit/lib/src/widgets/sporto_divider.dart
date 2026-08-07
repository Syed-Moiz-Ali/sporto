// ============================================================
// sporto_divider.dart
// Hairline divider used between card sections.
// ============================================================
import 'package:flutter/material.dart';
import 'sporto_card.dart';

class SportoDivider extends StatelessWidget {
  final double height;
  final double indent;
  final Color color;

  const SportoDivider({
    super.key,
    this.height = 1,
    this.indent = 0,
    this.color = SportoCard.defaultBorder,
  });

  @override
  Widget build(BuildContext context) {
    return Divider(height: height, indent: indent, color: color);
  }
}
