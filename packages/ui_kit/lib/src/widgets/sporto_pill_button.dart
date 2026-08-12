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
  final Gradient? gradient;
  final double? fontSize;
  final Color? foregroundColor;

  const SportoPillButton({
    super.key,
    required this.label,
    required this.color,
    this.onTap,
    this.icon,
    this.filled = false,
    this.bordered = true,
    this.height = 40,
    this.padding = const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    this.gradient,
    this.fontSize,
    this.foregroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          height: height,
          padding: padding,
          decoration: BoxDecoration(
            color: gradient == null
                ? (filled ? color : color.withValues(alpha: 0.15))
                : null,
            gradient: gradient,
            borderRadius: BorderRadius.circular(14),
            border: !filled && bordered
                ? Border.all(color: color.withValues(alpha: 0.3))
                : null,
          ),
          alignment: Alignment.center,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[
                Icon(icon,
                    size: 16,
                    color: foregroundColor ?? (filled ? Colors.white : color)),
                const SizedBox(width: 4),
              ],
              Flexible(
                  child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.visible,
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      fontSize: fontSize,
                      color: foregroundColor ?? (filled ? Colors.white : color),
                      fontWeight: FontWeight.w600,
                    ),
              )),
            ],
          ),
        ),
      ),
    );
  }
}
