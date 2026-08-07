// ============================================================
// sporto_ambient_background.dart
// Ambient radial-gradient backdrop used behind screens.
// ============================================================
import 'package:flutter/material.dart';

/// Full-bleed ambient background: solid scaffold color with a soft
/// primary-colored radial glow in the top-right corner.
class SportoAmbientBackground extends StatelessWidget {
  const SportoAmbientBackground({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final base = Scaffold().backgroundColor ?? Colors.black;
    return IgnorePointer(
      child: Stack(
        children: [
          Container(color: base),
          Container(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: const Alignment(0.9, -0.85),
                radius: 0.9,
                colors: [cs.primary.withOpacity(0.12), Colors.transparent],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
