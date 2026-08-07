// ============================================================
// sporto_section_title.dart
// Section heading used inside form cards / step screens.
// ============================================================
import 'package:flutter/material.dart';

class SportoSectionTitle extends StatelessWidget {
  final String title;
  final String? subtitle;

  const SportoSectionTitle({super.key, required this.title, this.subtitle});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 16, top: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: TextStyle(
                  color: cs.secondary,
                  fontSize: 18,
                  fontWeight: FontWeight.w700)),
          if (subtitle != null)
            Text(subtitle!,
                style:
                    TextStyle(color: cs.onSurfaceVariant, fontSize: 13)),
        ],
      ),
    );
  }
}
