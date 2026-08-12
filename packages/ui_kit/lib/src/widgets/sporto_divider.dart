import 'package:flutter/material.dart';

import 'sporto_card.dart';

class SportoDivider extends StatelessWidget {
  final double height;
  final double indent;
  final Color color;

  final bool dashed;

  final double dashWidth;
  final double dashGap;

  const SportoDivider({
    super.key,
    this.height = 1,
    this.indent = 0,
    this.color = SportoCard.defaultBorder,
    this.dashed = false,
    this.dashWidth = 2,
    this.dashGap = 4,
  });

  @override
  Widget build(BuildContext context) {
    if (!dashed) {
      return Divider(
        height: height,
        indent: indent,
        color: color,
      );
    }

    return Padding(
      padding: EdgeInsets.only(
        left: indent,
      ),
      child: SizedBox(
        width: double.infinity,
        height: height,
        child: CustomPaint(
          painter: _SportoDashedDividerPainter(
            color: color,
            dashWidth: dashWidth,
            gap: dashGap,
          ),
        ),
      ),
    );
  }
}

class _SportoDashedDividerPainter extends CustomPainter {
  final Color color;
  final double dashWidth;
  final double gap;

  const _SportoDashedDividerPainter({
    required this.color,
    required this.dashWidth,
    required this.gap,
  });

  @override
  void paint(
    Canvas canvas,
    Size size,
  ) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1;

    double x = 0;

    while (x < size.width) {
      canvas.drawLine(
        Offset(x, 0),
        Offset(
          (x + dashWidth).clamp(0, size.width),
          0,
        ),
        paint,
      );

      x += dashWidth + gap;
    }
  }

  @override
  bool shouldRepaint(
    covariant _SportoDashedDividerPainter oldDelegate,
  ) {
    return oldDelegate.color != color ||
        oldDelegate.dashWidth != dashWidth ||
        oldDelegate.gap != gap;
  }
}
