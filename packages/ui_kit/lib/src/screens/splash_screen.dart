import 'package:flutter/material.dart';

class SplashScreen extends StatefulWidget {
  final VoidCallback onFinish;

  const SplashScreen({super.key, required this.onFinish});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  double _opacity = 0.0;
  double _scale = 0.90;

  @override
  void initState() {
    super.initState();

    // Trigger the fluid 2026 entry animation immediately after build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        setState(() {
          _opacity = 1.0;
          _scale = 1.0;
        });
      }
    });

    // Hold the splash screen for the duration, then proceed
    Future.delayed(const Duration(milliseconds: 2500), () {
      if (mounted) widget.onFinish();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Stack(
        children: [
          Center(
            child: AnimatedOpacity(
              duration: const Duration(milliseconds: 1400),
              curve: Curves.easeOutExpo,
              opacity: _opacity,
              child: AnimatedScale(
                duration: const Duration(milliseconds: 1400),
                curve: Curves.easeOutExpo,
                scale: _scale,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Bare, high-contrast brand icon
                    Icon(
                      Icons.sports_cricket_rounded,
                      color: colorScheme.primary,
                      size: 72,
                    ),
                    const SizedBox(height: 24),
                    // Typographic logo
                    Text(
                      'SPORTO',
                      style: textTheme.displayLarge?.copyWith(
                        color: colorScheme.onSurface,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 4.0,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Enterprise Mobile Platform',
                      style: textTheme.titleMedium?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                        fontWeight: FontWeight.w500,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Minimalist, faded footer
          Positioned(
            bottom: 40,
            left: 0,
            right: 0,
            child: AnimatedOpacity(
              duration: const Duration(milliseconds: 1400),
              curve: Curves.easeOutExpo,
              opacity: _opacity,
              child: Column(
                children: [
                  Text(
                    'Powered by Sporto Engine',
                    style: textTheme.labelMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant.withOpacity(0.7),
                      fontWeight: FontWeight.w500,
                      letterSpacing: 1.0,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'VERSION 1.0.0',
                    style: textTheme.labelSmall?.copyWith(
                      color: colorScheme.onSurfaceVariant.withOpacity(0.4),
                      letterSpacing: 2.0,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
