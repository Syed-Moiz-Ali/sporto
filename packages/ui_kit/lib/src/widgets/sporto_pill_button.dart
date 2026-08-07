// ============================================================
// sporto_pill_button.dart
// Small pill action button (filled or tinted) used on cards.
// ============================================================
import 'package:flutter/material.dart';

class SportoPillButton extends StatelessWidget {
  final String label;
  final Color color;
  final VoidCallback? onTap;
  final IconData? icon;

  /// Filled background + white text, else tinted bg + colored text.
  final bool filled;

  /// Tinted pills render a colored border.
  final bool bordered;

  final double height;
  final EdgeInsetsGeometry padding;

  const SportoPillButton({
    super.key,
    required this.label,
    required this.color,
    this.onTap,
    this.icon,
    this.filled = false,
    this.bordered = true,
    this.height = 32,
    this.padding = const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          height: height,
          padding: padding,
          decoration: BoxDecoration(
            color: filled ? color : color.withOpacity(0.15),
            borderRadius: BorderRadius.circular(12),
            border: !filled && bordered
                ? Border.all(color: color.withOpacity(0.3))
                : null,
          ),
          alignment: Alignment.center,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[
                Icon(icon, size: 14, color: filled ? Colors.white : color),
                const SizedBox(width: 4),
              ],
              Text(
                label,
                style: TextStyle(
                  color: filled ? Colors.white : color,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
