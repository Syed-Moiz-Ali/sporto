// ============================================================
// sporto_bullet_point.dart
// Small bullet point used in feature/point lists.
// ============================================================
import 'package:flutter/material.dart';

class SportoBulletPoint extends StatelessWidget {
  final String text;

  const SportoBulletPoint({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 4,
          height: 4,
          decoration: BoxDecoration(
              shape: BoxShape.circle, color: cs.onSurfaceVariant),
        ),
        const SizedBox(width: 8),
        Flexible(
          child: Text(
            text,
            softWrap: true,
            style: TextStyle(color: cs.onSurfaceVariant, fontSize: 13),
          ),
        ),
      ],
    );
  }
}
