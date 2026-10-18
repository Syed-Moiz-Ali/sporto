import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:ui_kit/ui_kit.dart';

/// Screen 2 - Booking overview / "how it works" (Figma `02_Referees`).
///
/// Static explainer: hero Section card (image + eyebrow + subtitle), three
/// numbered steps, and a CTA. No data loading.
class BookingOverviewScreen extends StatelessWidget {
  const BookingOverviewScreen({super.key});

  static const List<(String, String, String)> _steps = [
    ('1', 'Sport & Location', "Tell us what you're playing and where"),
    ('2', 'Quick or Choose', 'Auto-match instantly, or pick your referee'),
    ('3', 'Confirmed', 'OTP-secured start and finish for every session'),
  ];

  @override
  Widget build(BuildContext context) {
    final gap = context.sportoLayout;
    return MediaQuery.withNoTextScaling(
      child: Scaffold(
        backgroundColor: context.sporto.canvas,
        appBar: SportoBookingAppBar(
          title: 'Book A Referee',
          subtitle: 'Certified officials for your next match.',
          onBack: () => context.canPop() ? context.pop() : context.go('/'),
        ),
        body: SafeArea(
          top: false,
          child: ListView(
            padding: EdgeInsets.fromLTRB(20, gap.space10, 20, gap.space20),
            children: [
              const _HeroCard(),
              SizedBox(height: gap.space20),
              const _StepsCard(),
              SizedBox(height: gap.space20),
              _RegisterButton(
                onTap: () => context.go('/book-referee/sport'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HeroCard extends StatelessWidget {
  const _HeroCard();

  @override
  Widget build(BuildContext context) {
    final tokens = context.sporto;
    final layout = context.sportoLayout;
    return SportoDocCard(
      plain: true,
      radius: layout.radius30,
      padding: const EdgeInsets.fromLTRB(20, 30, 20, 26),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 140,
            height: 120,
            decoration: BoxDecoration(
              gradient: tokens.gradientOrange,
              borderRadius: BorderRadius.circular(layout.radius10),
            ),
          ),
          SizedBox(height: layout.space30),
          Text(
            'BOOK A REFEREE',
            style: SportoTextStyles.text(
              size: SportoTextStyles.size18,
              weight: SportoTextStyles.semiBold,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          SizedBox(height: layout.space10),
          Text(
            'Find the right official for your game.',
            style: SportoTextStyles.text(
              size: SportoTextStyles.size14,
              weight: SportoTextStyles.regular,
              color: tokens.muted,
            ),
          ),
        ],
      ),
    );
  }
}

class _StepsCard extends StatelessWidget {
  const _StepsCard();

  @override
  Widget build(BuildContext context) {
    final tokens = context.sporto;
    final layout = context.sportoLayout;
    return SportoGlassSurface(
      radius: layout.radius20,
      color: tokens.panel.withValues(alpha: 0.3),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          for (var i = 0; i < BookingOverviewScreen._steps.length; i++) ...[
            _StepRow(
              number: BookingOverviewScreen._steps[i].$1,
              title: BookingOverviewScreen._steps[i].$2,
              subtitle: BookingOverviewScreen._steps[i].$3,
            ),
            if (i != BookingOverviewScreen._steps.length - 1)
              SizedBox(height: layout.space12),
          ],
        ],
      ),
    );
  }
}

class _StepRow extends StatelessWidget {
  final String number;
  final String title;
  final String subtitle;

  const _StepRow({
    required this.number,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    final tokens = context.sporto;
    final layout = context.sportoLayout;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SportoGlassSurface(
          width: 26,
          height: 26,
          radius: layout.radius10,
          color: tokens.red.withValues(alpha: 0.06),
          borderColor: tokens.hairlineWarm.withValues(alpha: 0.08),
          child: Center(
            child: _GradientText(
              number,
              gradient: tokens.primaryGradient,
              style: SportoTextStyles.text(
                size: SportoTextStyles.size12,
                weight: SportoTextStyles.medium,
                color: Colors.white,
              ),
            ),
          ),
        ),
        SizedBox(width: layout.space10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                title,
                style: SportoTextStyles.text(
                  size: SportoTextStyles.size12,
                  weight: SportoTextStyles.medium,
                  color: tokens.muted,
                  height: 1.2,
                ),
              ),
              SizedBox(height: layout.space2),
              Text(
                subtitle,
                style: SportoTextStyles.text(
                  size: SportoTextStyles.size11,
                  weight: SportoTextStyles.medium,
                  color: tokens.textTertiary,
                  height: 1.2,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _RegisterButton extends StatelessWidget {
  final VoidCallback onTap;

  const _RegisterButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    final tokens = context.sporto;
    final layout = context.sportoLayout;
    return Center(
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: SportoGlassSurface(
          width: 270,
          height: 48,
          radius: layout.radius16,
          gradient: tokens.primaryGradient,
          shadows: layout.buttonShadow(tokens.primaryGradient.colors.first),
          child: Center(
            child: Text(
              'Register Individually',
              style: SportoTextStyles.text(
                size: SportoTextStyles.size16,
                weight: SportoTextStyles.bold,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Renders [text] with a gradient shader (used for the step numbers).
class _GradientText extends StatelessWidget {
  final String text;
  final TextStyle style;
  final Gradient gradient;

  const _GradientText(this.text, {required this.style, required this.gradient});

  @override
  Widget build(BuildContext context) {
    return ShaderMask(
      blendMode: BlendMode.srcIn,
      shaderCallback: (bounds) => gradient.createShader(
        Rect.fromLTWH(0, 0, bounds.width, bounds.height),
      ),
      child: Text(text, style: style),
    );
  }
}
