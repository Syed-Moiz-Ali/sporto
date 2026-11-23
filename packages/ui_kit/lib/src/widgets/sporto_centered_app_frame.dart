import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Keeps every app screen at a phone-sized width and centres it on wide
/// displays (web, tablet, desktop) instead of stretching to the full viewport.
///
/// On phones narrower than [maxWidth] the frame is a no-op. The nested
/// [MediaQuery] also reports the constrained width so proportional layout code
/// (`MediaQuery.sizeOf(context).width`) stays consistent with the visible app.
class SportoCenteredAppFrame extends StatelessWidget {
  const SportoCenteredAppFrame({
    super.key,
    required this.child,
    this.maxWidth = 430,
  });

  final Widget child;
  final double maxWidth;

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    final background = Theme.of(context).scaffoldBackgroundColor;

    return ColoredBox(
      color: background,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final availableWidth = constraints.maxWidth.isFinite
              ? constraints.maxWidth
              : media.size.width;
          final availableHeight = constraints.maxHeight.isFinite
              ? constraints.maxHeight
              : media.size.height;
          final width = math.min(availableWidth, maxWidth);

          return Center(
            child: SizedBox(
              width: width,
              height: availableHeight,
              child: MediaQuery(
                data: media.copyWith(size: Size(width, availableHeight)),
                child: child,
              ),
            ),
          );
        },
      ),
    );
  }
}
