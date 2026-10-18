import 'package:flutter/material.dart';

/// Renders [text] filled with a gradient (Figma gradient text).
class SportoGradientText extends StatelessWidget {
  final String text;
  final Gradient gradient;
  final TextStyle style;
  final TextAlign textAlign;
  final int? maxLines;

  const SportoGradientText(
    this.text, {
    super.key,
    required this.gradient,
    required this.style,
    this.textAlign = TextAlign.start,
    this.maxLines,
  });

  @override
  Widget build(BuildContext context) {
    return ShaderMask(
      blendMode: BlendMode.srcIn,
      shaderCallback: (bounds) => gradient.createShader(
        Rect.fromLTWH(0, 0, bounds.width, bounds.height),
      ),
      child: Text(
        text,
        textAlign: textAlign,
        maxLines: maxLines,
        style: style,
      ),
    );
  }
}
