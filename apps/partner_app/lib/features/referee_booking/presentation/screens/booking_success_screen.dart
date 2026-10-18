import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:ui_kit/ui_kit.dart';

import '../../application/booking_bloc.dart';
import '../widgets/booking_details_section.dart';
import '../widgets/booking_primary_button.dart';

/// Screen 11 / 17 - Booking success (Figma E1-11 quick, E1-17 choose-referee).
class BookingSuccessScreen extends StatelessWidget {
  const BookingSuccessScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final tokens = context.sporto;
    final gap = context.sportoLayout;
    final isReferee =
        context.watch<BookingBloc>().state.bookingMode == BookingMode.choose;
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
              _SuccessHero(
                title: isReferee ? 'BOOKING CONFIRMED!' : 'REFEREE FOUND!',
                subtitleName: isReferee ? 'Vijay Mohan' : null,
                subtitleText: isReferee
                    ? ' is confirmed for your match.'
                    : 'Your registration for SPOTO Random Cricket is confirmed.',
              ),
              SizedBox(height: gap.space20),
              _RefIdCard(refId: isReferee ? 'REF-83836615' : 'REF-61307662'),
              SizedBox(height: gap.space20),
              _RefereeCard(name: isReferee ? 'Vijay Mohan' : 'Suresh Reddy'),
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
                outlined: true,
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
  final String title;
  final String? subtitleName;
  final String subtitleText;
  const _SuccessHero({
    required this.title,
    required this.subtitleText,
    this.subtitleName,
  });

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
              color: tokens.iconTile,
              borderRadius: BorderRadius.circular(layout.radius30 + 10),
            ),
            child: const Center(
              child: Text('\u{1F389}', style: TextStyle(fontSize: 64)),
            ),
          ),
          SizedBox(height: layout.space30),
          Text(
            title,
            style: SportoTextStyles.text(
              size: SportoTextStyles.size24,
              weight: SportoTextStyles.bold,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          SizedBox(height: layout.space12),
          Text.rich(
            TextSpan(
              children: [
                if (subtitleName != null)
                  TextSpan(
                    text: subtitleName,
                    style: SportoTextStyles.text(
                      size: SportoTextStyles.size16,
                      weight: SportoTextStyles.semiBold,
                      color: tokens.gold,
                    ),
                  ),
                TextSpan(
                  text: subtitleText,
                  style: SportoTextStyles.text(
                    size: SportoTextStyles.size16,
                    weight: SportoTextStyles.medium,
                    color: tokens.muted,
                  ),
                ),
              ],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _RefIdCard extends StatelessWidget {
  final String refId;
  const _RefIdCard({required this.refId});

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
            refId,
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
  final String name;
  const _RefereeCard({required this.name});

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
                  name,
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
