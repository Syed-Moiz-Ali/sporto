import 'package:flutter/material.dart';

class SportoBadge extends StatelessWidget {
  final String text;
  final Color color;

  final bool outlined;

  final IconData? icon;

  final bool leadingDot;

  final Color? backgroundColor;
  final Color? foregroundColor;
  final Color? dotColor;

  final double radius;
  final double fontSize;

  final EdgeInsetsGeometry padding;

  const SportoBadge({
    super.key,
    required this.text,
    required this.color,
    this.outlined = false,
    this.icon,
    this.leadingDot = false,
    this.backgroundColor,
    this.foregroundColor,
    this.dotColor,
    this.radius = 6,
    this.fontSize = 11,
    this.padding = const EdgeInsets.symmetric(
      horizontal: 8,
      vertical: 4,
    ),
  });

  @override
  Widget build(BuildContext context) {
    final foreground = foregroundColor ?? color;

    final background = backgroundColor ??
        (outlined ? Colors.transparent : color.withValues(alpha: .15));

    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(radius),
        border: outlined
            ? Border.all(
                color: color,
                width: 1,
              )
            : null,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (leadingDot) ...[
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: dotColor ?? color,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 4),
          ],
          if (icon != null) ...[
            Icon(
              icon,
              color: foreground,
              size: 12,
            ),
            const SizedBox(width: 4),
          ],
          Text(
            text,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: foreground,
                  fontSize: fontSize,
                  fontWeight: FontWeight.w600,
                ),
          ),
        ],
      ),
    );
  }
}
