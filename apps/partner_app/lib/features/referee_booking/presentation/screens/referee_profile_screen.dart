import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:ui_kit/ui_kit.dart';

import '../widgets/booking_primary_button.dart';
import '../widgets/booking_venue_card.dart';

/// Screen 14 - Referee Profile (Figma E1-14). Full page.
class RefereeProfileScreen extends StatelessWidget {
  const RefereeProfileScreen({super.key});

  static const List<(String, String)> _reviews = [
    ('Warriors FC Captain', '\u201CFair and fast decisions, kept the match moving.\u201D'),
    ('Falcons CC', '\u201CArrived early, very professional.\u201D'),
  ];

  @override
  Widget build(BuildContext context) {
    final tokens = context.sporto;
    final gap = context.sportoLayout;
    return MediaQuery.withNoTextScaling(
      child: Scaffold(
        backgroundColor: tokens.canvas,
        appBar: SportoBookingAppBar(
          title: 'Referee Profile',
          onBack: () => context.canPop() ? context.pop() : context.go('/'),
        ),
        body: SafeArea(
          top: false,
          child: ListView(
            padding: EdgeInsets.fromLTRB(20, gap.space10, 20, gap.space20),
            children: [
              const _RefereeHeaderCard(),
              SizedBox(height: gap.space20),
              const Row(
                children: [
                  Expanded(
                    child: SportoStatChip(
                      value: '4.8',
                      label: '20 reviews',
                      icon: SportoSvgIcon(SportoRefereeBookingIcons.starGold,
                          size: 14),
                    ),
                  ),
                  SizedBox(width: 14),
                  Expanded(
                    child: SportoStatChip(value: '34', label: 'Matches'),
                  ),
                  SizedBox(width: 14),
                  Expanded(
                    child: SportoStatChip(value: '4.2 km', label: 'Distance'),
                  ),
                ],
              ),
              SizedBox(height: gap.space20),
              const _AboutCard(
                text:
                    'Former state-level cricketer turned certified umpire. Specialises in T10/T20 league matches and keeps a calm, decisive presence on tight calls.',
              ),
              SizedBox(height: gap.space20),
              _SectionLabel('Pricing', tokens.textTertiary),
              SizedBox(height: gap.space10),
              const _PricingCard(),
              SizedBox(height: gap.space20),
              Row(
                children: [
                  Text(
                    'Reviews',
                    style: SportoTextStyles.text(
                      size: SportoTextStyles.size14,
                      weight: SportoTextStyles.semiBold,
                      color: tokens.textTertiary,
                    ),
                  ),
                  const Spacer(),
                  const SportoSvgIcon(SportoRefereeBookingIcons.starGold,
                      size: 14),
                  SizedBox(width: gap.space4),
                  Text(
                    '4.8 (184)',
                    style: SportoTextStyles.text(
                      size: SportoTextStyles.size13,
                      weight: SportoTextStyles.medium,
                      color: tokens.muted,
                    ),
                  ),
                  SizedBox(width: gap.space6),
                  Text(
                    'View All',
                    style: SportoTextStyles.text(
                      size: SportoTextStyles.size13,
                      weight: SportoTextStyles.medium,
                      color: tokens.info,
                    ),
                  ),
                ],
              ),
              SizedBox(height: gap.space10),
              for (final review in _reviews) ...[
                _ReviewCard(review: review),
                SizedBox(height: gap.space10),
              ],
              SizedBox(height: gap.space10),
              const BookingVenueCard(
                sport: 'Cricket',
                venue: 'KPHB Indoor Stadium',
                area: 'Kompally, Hyderabad',
              ),
              SizedBox(height: gap.space20),
              BookingPrimaryButton(
                label: 'Book This Referee',
                onTap: () => context.go('/book-referee/summary'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String label;
  final Color color;
  const _SectionLabel(this.label, this.color);

  @override
  Widget build(BuildContext context) => Text(
        label,
        style: SportoTextStyles.text(
          size: SportoTextStyles.size14,
          weight: SportoTextStyles.semiBold,
          color: color,
        ),
      );
}

class _RefereeHeaderCard extends StatelessWidget {
  const _RefereeHeaderCard();

  @override
  Widget build(BuildContext context) {
    final tokens = context.sporto;
    final layout = context.sportoLayout;
    final onSurface = Theme.of(context).colorScheme.onSurface;
    return SportoGlassSurface(
      radius: layout.radius16,
      blur: layout.glassBlur,
      color: tokens.card,
      padding: const EdgeInsets.all(10),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: tokens.avatarGreen.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(13.16),
            ),
            clipBehavior: Clip.antiAlias,
            child: const SportoAssetIcon(
              SportoRefereeBookingIcons.avatarReferee,
              size: 50,
              fit: BoxFit.cover,
            ),
          ),
          SizedBox(width: layout.space10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Text(
                      'Vijay Mohan',
                      style: SportoTextStyles.text(
                        size: SportoTextStyles.size16,
                        weight: SportoTextStyles.semiBold,
                        color: onSurface,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      'Available',
                      style: SportoTextStyles.text(
                        size: SportoTextStyles.size12,
                        weight: SportoTextStyles.medium,
                        color: tokens.statusGreen,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: layout.space2),
                Text(
                  'Cricket  \u2022  8 yrs  \u2022  3 Level',
                  style: SportoTextStyles.text(
                    size: SportoTextStyles.size12,
                    weight: SportoTextStyles.medium,
                    color: tokens.accentGreen,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AboutCard extends StatelessWidget {
  final String text;
  const _AboutCard({required this.text});

  @override
  Widget build(BuildContext context) {
    final tokens = context.sporto;
    final layout = context.sportoLayout;
    return SportoGlassSurface(
      radius: layout.radius16,
      color: tokens.section,
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'About',
            style: SportoTextStyles.text(
              size: SportoTextStyles.size13,
              weight: SportoTextStyles.medium,
              color: tokens.muted,
            ),
          ),
          SizedBox(height: layout.space6),
          Text(
            text,
            style: SportoTextStyles.text(
              size: SportoTextStyles.size13,
              weight: SportoTextStyles.medium,
              color: Theme.of(context).colorScheme.onSurface,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}

class _PricingCard extends StatelessWidget {
  const _PricingCard();

  @override
  Widget build(BuildContext context) {
    final tokens = context.sporto;
    final layout = context.sportoLayout;
    final pink = LinearGradient(
      colors:
          tokens.gradientPink.colors.map((c) => c.withValues(alpha: 0.1)).toList(),
    );
    return SportoGlassSurface(
      radius: layout.radius16,
      blur: layout.glassBlur,
      gradient: pink,
      padding: const EdgeInsets.all(14),
      child: Row(
        children: [
          _price(context, 'Hourly', '\u20B91400'),
          const Spacer(),
          _price(context, 'Daily', '\u20B912800'),
        ],
      ),
    );
  }

  Widget _price(BuildContext context, String label, String value) {
    final tokens = context.sporto;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: SportoTextStyles.text(
            size: SportoTextStyles.size12,
            weight: SportoTextStyles.medium,
            color: tokens.accentGreen,
          ),
        ),
        Text(
          value,
          style: SportoTextStyles.text(
            size: SportoTextStyles.size18,
            weight: SportoTextStyles.semiBold,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
      ],
    );
  }
}

class _ReviewCard extends StatelessWidget {
  final (String, String) review;
  const _ReviewCard({required this.review});

  @override
  Widget build(BuildContext context) {
    final tokens = context.sporto;
    final layout = context.sportoLayout;
    return SportoGlassSurface(
      radius: layout.radius16,
      color: tokens.cardElevated,
      padding: const EdgeInsets.all(14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  review.$1,
                  style: SportoTextStyles.text(
                    size: SportoTextStyles.size13,
                    weight: SportoTextStyles.semiBold,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                SizedBox(height: layout.space4),
                Text(
                  review.$2,
                  style: SportoTextStyles.text(
                    size: SportoTextStyles.size13,
                    weight: SportoTextStyles.medium,
                    color: tokens.muted,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: layout.space10),
          const SportoStarRating(rating: 5, starSize: 12),
        ],
      ),
    );
  }
}
