import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:ui_kit/ui_kit.dart';

import '../widgets/booking_details_section.dart';
import '../widgets/booking_primary_button.dart';

/// Screen 11 - Booking success / "Referee found" (Figma E1-11).
class BookingSuccessScreen extends StatelessWidget {
  const BookingSuccessScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final tokens = context.sporto;
    final gap = context.sportoLayout;
    return MediaQuery.withNoTextScaling(
      child: Scaffold(
        backgroundColor: tokens.canvas,
        appBar: SportoBookingAppBar(
          title: '',
          onBack: () => context.canPop() ? context.pop() : context.go('/'),
        ),
        body: SafeArea(
          top: false,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
            children: [
              const _SuccessHero(),
              SizedBox(height: gap.space20),
              const _RefIdCard(),
              SizedBox(height: gap.space20),
              const _RefereeCard(),
              SizedBox(height: gap.space20),
              const BookingDetailsSection(
                tournament: 'SPOTO Random Cricket \u2014 Hyderabad',
                venue: 'KPHB Indoor Stadium',
                location: 'Kompally, Hyderabad',
                date: '24 Aug 2026',
                time: '5:00 PM',
                duration: '2 Hours',
                bookingType: 'Hourly',
              ),
              SizedBox(height: gap.space20),
              BookingPrimaryButton(
                label: 'View My Bookings',
                onTap: () => context.go('/book-referee/bookings'),
              ),
              SizedBox(height: gap.space16),
              Center(
                child: SportoTagChip(
                  label: 'Back to Home',
                  onTap: () => context.go('/'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SuccessHero extends StatelessWidget {
  const _SuccessHero();

  @override
  Widget build(BuildContext context) {
    final tokens = context.sporto;
    final layout = context.sportoLayout;
    return SportoGlassSurface(
      radius: layout.radius30,
      color: tokens.cardElevated,
      padding: const EdgeInsets.fromLTRB(20, 40, 20, 30),
      child: Column(
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: tokens.successArt,
              borderRadius: BorderRadius.circular(layout.radius30),
            ),
            child: const Center(
              child: Text('\u2705', style: TextStyle(fontSize: 44)),
            ),
          ),
          SizedBox(height: layout.space30),
          Text(
            'REFEREE FOUND!',
            style: SportoTextStyles.text(
              size: SportoTextStyles.size24,
              weight: SportoTextStyles.bold,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          SizedBox(height: layout.space12),
          Text(
            'Your registration for SPOTO Random Cricket is confirmed.',
            textAlign: TextAlign.center,
            style: SportoTextStyles.text(
              size: SportoTextStyles.size16,
              weight: SportoTextStyles.medium,
              color: tokens.muted,
            ),
          ),
        ],
      ),
    );
  }
}

class _RefIdCard extends StatelessWidget {
  const _RefIdCard();

  @override
  Widget build(BuildContext context) {
    final tokens = context.sporto;
    final layout = context.sportoLayout;
    return SportoGlassSurface(
      radius: layout.radius16,
      blur: layout.glassBlur,
      color: tokens.card,
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          Text(
            'REF-61307662',
            style: SportoTextStyles.text(
              size: SportoTextStyles.size13,
              weight: SportoTextStyles.medium,
              color: tokens.muted,
            ),
          ),
          const Spacer(),
          Container(
            width: 5,
            height: 5,
            decoration:
                BoxDecoration(shape: BoxShape.circle, color: tokens.statusGreen),
          ),
          SizedBox(width: layout.space4),
          Text(
            'Booking Confirmed',
            style: SportoTextStyles.text(
              size: SportoTextStyles.size13,
              weight: SportoTextStyles.medium,
              color: tokens.accentGreen,
            ),
          ),
        ],
      ),
    );
  }
}

class _RefereeCard extends StatelessWidget {
  const _RefereeCard();

  @override
  Widget build(BuildContext context) {
    final tokens = context.sporto;
    final layout = context.sportoLayout;
    return SportoGlassSurface(
      radius: layout.radius16,
      blur: layout.glassBlur,
      color: tokens.card,
      padding: const EdgeInsets.all(12),
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
                Text(
                  'Suresh Reddy',
                  style: SportoTextStyles.text(
                    size: SportoTextStyles.size16,
                    weight: SportoTextStyles.semiBold,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                SizedBox(height: layout.space4),
                Text(
                  '4.8  \u2022  8 yrs  \u2022  3 Level',
                  style: SportoTextStyles.text(
                    size: SportoTextStyles.size13,
                    weight: SportoTextStyles.medium,
                    color: tokens.muted,
                  ),
                ),
                SizedBox(height: layout.space2),
                Text(
                  '34 matches  \u2022  2.4 km',
                  style: SportoTextStyles.text(
                    size: SportoTextStyles.size13,
                    weight: SportoTextStyles.medium,
                    color: tokens.muted,
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
