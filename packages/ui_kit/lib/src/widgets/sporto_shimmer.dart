import 'package:flutter/material.dart';

/// Animated skeleton shimmer placeholder for loading states.
class SportoShimmer extends StatefulWidget {
  final double? width;
  final double height;
  final double borderRadius;

  const SportoShimmer({
    super.key,
    this.width,
    required this.height,
    this.borderRadius = 12.0,
  });

  @override
  State<SportoShimmer> createState() => _SportoShimmerState();
}

class _SportoShimmerState extends State<SportoShimmer>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);
    _animation = Tween<double>(begin: 0.08, end: 0.22).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          width: widget.width ?? double.infinity,
          height: widget.height,
          decoration: BoxDecoration(
            color: cs.onSurface.withValues(alpha: _animation.value),
            borderRadius: BorderRadius.circular(widget.borderRadius),
          ),
        );
      },
    );
  }
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
  Widget build(BuildContext context) {
    return SportoShimmer(
      height: height,
      borderRadius: borderRadius,
    );
  }
}
