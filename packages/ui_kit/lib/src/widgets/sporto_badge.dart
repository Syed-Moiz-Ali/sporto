// ============================================================
// sporto_badge.dart
// Small status/tag badge (filled or outlined).
// ============================================================
import 'package:flutter/material.dart';

class SportoBadge extends StatelessWidget {
  final String text;
  final Color color;
  final bool outlined;
  final IconData? icon;

  const SportoBadge({
    super.key,
    required this.text,
    required this.color,
    this.outlined = false,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: outlined ? Colors.transparent : color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(6),
        border: outlined ? Border.all(color: color, width: 1) : null,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, color: color, size: 12),
            const SizedBox(width: 4),
          ],
          Text(
            text,
            style: TextStyle(
              color: color,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
