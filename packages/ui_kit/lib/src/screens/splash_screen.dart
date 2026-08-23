import 'package:flutter/material.dart';
import '../assets/sporto_assets.dart';

class SplashScreen extends StatefulWidget {
  final VoidCallback onFinish;

  const SplashScreen({super.key, required this.onFinish});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late final AnimationController _entryController;
  late final AnimationController _glowController;
  late final Animation<double> _scaleAnimation;
  late final Animation<double> _fadeAnimation;
  late final Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();

    _entryController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    )..repeat(reverse: true);

    _scaleAnimation = Tween<double>(begin: 0.85, end: 1.0).animate(
      CurvedAnimation(parent: _entryController, curve: Curves.easeOutBack),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _entryController, curve: Curves.easeOut),
    );

    _glowAnimation = Tween<double>(begin: 0.25, end: 0.60).animate(
      CurvedAnimation(parent: _glowController, curve: Curves.easeInOut),
    );

    _entryController.forward();

    // Proceed after 2.4 seconds
    Future.delayed(const Duration(milliseconds: 2400), () {
      if (mounted) widget.onFinish();
    });
  }

  @override
  void dispose() {
    _entryController.dispose();
    _glowController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const bgInk = Color(0xFF0A0E12);
    const turfGreen = Color(0xFF1E8A4C);
    const amberColor = Color(0xFFF4B41A);
    const dimColor = Color(0xFF7C8894);

    return Scaffold(
      backgroundColor: bgInk,
      body: Stack(
        alignment: Alignment.center,
        children: [
          // Background Radial Glow & Orbs
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment(0, -0.2),
                  radius: 0.9,
                  colors: [
                    Color(0xFF16210F),
                    bgInk,
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            top: -80,
            left: -60,
            child: Container(
              width: 280,
              height: 280,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: turfGreen.withValues(alpha: 0.15),
              ),
            ),
          ),
          Positioned(
            bottom: -70,
            right: -60,
            child: Container(
              width: 240,
              height: 240,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: amberColor.withValues(alpha: 0.15),
              ),
            ),
          ),

          // Main Center Content
          Center(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Full Unclipped Image Hero with Backdrop Glow
                  ScaleTransition(
                    scale: _scaleAnimation,
                    child: AnimatedBuilder(
                      animation: _glowAnimation,
                      builder: (context, child) {
                        return Container(
                          constraints: const BoxConstraints(
                            maxWidth: 300,
                            maxHeight: 200,
                          ),
                          child: Image.asset(
                            SportoAssets.playAndWin,
                            package: SportoAssets.package,
                            fit: BoxFit.contain,
                          ),
                        );
                      },
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Wordmark "SPOTO"
                  RichText(
                    text: const TextSpan(
                      style: TextStyle(
                        fontFamily: 'packages/ui_kit/Quicksand',
                        fontSize: 34,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 4.0,
                        color: Colors.white,
                      ),
                      children: [
                        TextSpan(text: 'S'),
                        TextSpan(
                          text: 'POTO',
                          style: TextStyle(color: amberColor),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 8),

                  // Sub-tagline "PARTNER CONSOLE"
                  const Text(
                    'PARTNER CONSOLE',
                    style: TextStyle(
                      fontFamily: 'packages/ui_kit/Quicksand',
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 3.0,
                      color: dimColor,
                    ),
                  ),

                  const SizedBox(height: 52),

                  // 3-dot Animated Loader
                  _SplashLoader(
                    color1: turfGreen,
                    color2: amberColor,
                    color3: const Color(0xFF5B8DEF),
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

class _SplashLoader extends StatefulWidget {
  final Color color1;
  final Color color2;
  final Color color3;

  const _SplashLoader({
    required this.color1,
    required this.color2,
    required this.color3,
  });

  @override
  State<_SplashLoader> createState() => _SplashLoaderState();
}

class _SplashLoaderState extends State<_SplashLoader>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final val = _controller.value;
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _dot(widget.color1, _scaleForDot(val, 0.0)),
            const SizedBox(width: 8),
            _dot(widget.color2, _scaleForDot(val, 0.2)),
            const SizedBox(width: 8),
            _dot(widget.color3, _scaleForDot(val, 0.4)),
          ],
        );
      },
    );
  }

  double _scaleForDot(double progress, double delay) {
    final t = (progress - delay) % 1.0;
    if (t < 0.4) return 0.5 + (t / 0.4) * 0.7;
    if (t < 0.8) return 1.2 - ((t - 0.4) / 0.4) * 0.7;
    return 0.5;
  }

  Widget _dot(Color color, double scale) {
    return Transform.scale(
      scale: scale,
      child: Container(
        width: 8,
        height: 8,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}
