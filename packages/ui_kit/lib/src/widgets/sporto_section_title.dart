// ============================================================
// sporto_section_title.dart
// Section heading used inside form cards / step screens.
// ============================================================
import 'package:flutter/material.dart';

class SportoSectionTitle extends StatelessWidget {
  final String title;
  final String? subtitle;

  /// Large screen-level heading (24px Space Grotesk, default styling).
  final bool large;

  final EdgeInsetsGeometry padding;

  const SportoSectionTitle({
    super.key,
    required this.title,
    this.subtitle,
    this.large = false,
    this.padding = const EdgeInsets.only(bottom: 16, top: 8),
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    final titleStyle = large
        ? TextStyle(
            fontFamily: 'packages/ui_kit/Quicksand',
            fontSize: 24,
            fontWeight: FontWeight.w600,
            color: cs.onSurface,
            letterSpacing: -0.3,
          )
        : TextStyle(
            color: cs.secondary,
            fontSize: 18,
            fontWeight: FontWeight.w500,
          );

    final subtitleStyle = large
        ? TextStyle(
            color: cs.onTertiary,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          )
        : TextStyle(color: cs.onSurfaceVariant, fontSize: 12);

    return Padding(
      padding: padding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: titleStyle),
          if (subtitle != null) ...[
            const SizedBox(height: 6),
            Text(subtitle!, style: subtitleStyle),
          ],
        ],
      ),
    );
  }
}
