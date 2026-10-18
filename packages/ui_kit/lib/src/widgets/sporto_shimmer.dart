import 'package:flutter/material.dart';

import '../theme/sporto_design_tokens.dart';

/// Animated skeleton shimmer placeholder for loading states.
///
/// Base/highlight colours, duration, curve and sweep direction all come from
/// design tokens (`SportoDesignTokens.shimmerBase/Highlight`,
/// `SportoLayoutTokens.shimmerDuration/shimmerCurve/shimmerDirection`).
class SportoShimmer extends StatefulWidget {
  final double? width;
  final double height;
  final double borderRadius;
  final BoxShape shape;

  const SportoShimmer({
    super.key,
    this.width,
    required this.height,
    this.borderRadius = 12.0,
    this.shape = BoxShape.rectangle,
  });

  @override
  State<SportoShimmer> createState() => _SportoShimmerState();
}

class _SportoShimmerState extends State<SportoShimmer>
    with SingleTickerProviderStateMixin {
  AnimationController? _controller;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final layout = Theme.of(context).extension<SportoLayoutTokens>();
    _controller ??= AnimationController(
      vsync: this,
      duration: layout?.shimmerDuration ?? const Duration(milliseconds: 1000),
    )..repeat();
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  (Alignment, Alignment) _alignment(ShimmerDirection d) {
    switch (d) {
      case ShimmerDirection.leftToRight:
        return (Alignment.centerLeft, Alignment.centerRight);
      case ShimmerDirection.rightToLeft:
        return (Alignment.centerRight, Alignment.centerLeft);
      case ShimmerDirection.topToBottom:
        return (Alignment.topCenter, Alignment.bottomCenter);
      case ShimmerDirection.bottomToTop:
        return (Alignment.bottomCenter, Alignment.topCenter);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tokens = theme.extension<SportoDesignTokens>();
    final layout = theme.extension<SportoLayoutTokens>();
    final controller = _controller;
    final (begin, end) =
        _alignment(layout?.shimmerDirection ?? ShimmerDirection.leftToRight);
    final curve = layout?.shimmerCurve ?? Curves.easeInOut;
    final base =
        tokens?.shimmerBase ?? theme.colorScheme.onSurface.withValues(alpha: 0.08);
    final highlight = tokens?.shimmerHighlight ??
        theme.colorScheme.onSurface.withValues(alpha: 0.22);

    return AnimatedBuilder(
      animation: controller ?? const AlwaysStoppedAnimation<double>(0),
      builder: (context, child) {
        final t = controller == null ? 0.5 : curve.transform(controller.value);
        final center = (t * 2) - 0.5;
        final gradient = LinearGradient(
          begin: begin,
          end: end,
          colors: [base, highlight, base],
          stops: [
            (center - 0.4).clamp(0.0, 1.0),
            center.clamp(0.0, 1.0),
            (center + 0.4).clamp(0.0, 1.0),
          ],
        );
        return Container(
          width: widget.width ?? double.infinity,
          height: widget.height,
          decoration: BoxDecoration(
            color: base,
            gradient: gradient,
            shape: widget.shape,
            borderRadius: widget.shape == BoxShape.circle
                ? null
                : BorderRadius.circular(widget.borderRadius),
          ),
        );
      },
    );
  }
}

/// Rounded-rectangle skeleton block.
class SkeletonBox extends StatelessWidget {
  final double? width;
  final double height;
  final double radius;

  const SkeletonBox({
    super.key,
    this.width,
    required this.height,
    this.radius = 8,
  });

  @override
  Widget build(BuildContext context) =>
      SportoShimmer(width: width, height: height, borderRadius: radius);
}

/// Single text-line skeleton (defaults to a body line height).
class SkeletonLine extends StatelessWidget {
  final double? width;
  final double height;
  final double radius;

  const SkeletonLine({
    super.key,
    this.width,
    this.height = 12,
    this.radius = 4,
  });

  @override
  Widget build(BuildContext context) =>
      SportoShimmer(width: width, height: height, borderRadius: radius);
}

/// Circular skeleton for avatars/status dots.
class SkeletonCircle extends StatelessWidget {
  final double size;

  const SkeletonCircle({super.key, required this.size});

  @override
  Widget build(BuildContext context) => SportoShimmer(
        width: size,
        height: size,
        shape: BoxShape.circle,
      );
}

/// A standard card-shaped skeleton loading placeholder.
class SportoSkeletonCard extends StatelessWidget {
  final double height;
  final double borderRadius;

  const SportoSkeletonCard({
    super.key,
    this.height = 100.0,
    this.borderRadius = 16.0,
  });

  @override
  Widget build(BuildContext context) =>
      SportoShimmer(height: height, borderRadius: borderRadius);
}
