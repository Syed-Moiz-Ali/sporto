// ============================================================
// sporto_ambient_background.dart
// Ambient radial-gradient backdrop used behind screens.
// ============================================================
import 'package:flutter/material.dart';
import '../theme/sporto_design_tokens.dart';

/// Full-bleed ambient background: solid scaffold color with a soft
/// primary-colored radial glow in the top-right corner.
class SportoAmbientBackground extends StatelessWidget {
  const SportoAmbientBackground({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return IgnorePointer(
      child: Stack(
        children: [
          Container(color: theme.scaffoldBackgroundColor),
          Container(
            decoration: BoxDecoration(gradient: context.sporto.ambientGradient),
          ),
        ],
      ),
    );
  }
}
