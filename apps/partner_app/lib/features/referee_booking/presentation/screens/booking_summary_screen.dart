import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:ui_kit/ui_kit.dart';

import '../widgets/booking_details_section.dart';
import '../widgets/booking_primary_button.dart';

/// Screen 15 - Booking Summary (Figma E1-15). Choose-referee branch.
class BookingSummaryScreen extends StatelessWidget {
  const BookingSummaryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final tokens = context.sporto;
    final gap = context.sportoLayout;
    return MediaQuery.withNoTextScaling(
      child: Scaffold(
        backgroundColor: tokens.canvas,
        appBar: SportoBookingAppBar(
          title: 'Booking Summary',
          onBack: () => context.canPop() ? context.pop() : context.go('/'),
        ),
        body: SafeArea(
          top: false,
          child: ListView(
            padding: EdgeInsets.fromLTRB(20, gap.space10, 20, gap.space20),
            children: [
              const _RefereeHeaderCard(),
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
              const _NoticeCard(),
              SizedBox(height: gap.space20),
              const SportoPriceSummaryCard(
                rows: [
                  SportoPriceRow('Referee Fee', '\u20B91400'),
                  SportoPriceRow('Platform Fee', '\u20B9140'),
                ],
                totalLabel: 'Total Paid',
                totalValue: '\u20B91440',
              ),
              SizedBox(height: gap.space20),
              BookingPrimaryButton(
                label: 'Confirm & Pay \u20B91440',
                onTap: () => context.go('/book-referee/payment'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RefereeHeaderCard extends StatelessWidget {
  const _RefereeHeaderCard();

  @override
  Widget build(BuildContext context) {
    final tokens = context.sporto;
    final layout = context.sportoLayout;
    final onSurface = Theme.of(context).colorScheme.onSurface;
    final pink = LinearGradient(
      colors:
          tokens.gradientPink.colors.map((c) => c.withValues(alpha: 0.2)).toList(),
    );
    return SportoGlassSurface(
      radius: layout.radius20,
      blur: layout.glassBlur,
      gradient: pink,
      padding: const EdgeInsets.all(14),
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

class _NoticeCard extends StatelessWidget {
  const _NoticeCard();

  @override
  Widget build(BuildContext context) {
    final tokens = context.sporto;
    final layout = context.sportoLayout;
    final goldFill = LinearGradient(
      colors:
          tokens.gradientGold.colors.map((c) => c.withValues(alpha: 0.06)).toList(),
    );
    final goldBorder = LinearGradient(
      colors:
          tokens.gradientGold.colors.map((c) => c.withValues(alpha: 0.5)).toList(),
    );
    return SportoGlassSurface(
      radius: layout.radius16,
      blur: layout.glassBlur,
      gradient: goldFill,
      borderGradient: goldBorder,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 3),
            child: Container(
              width: 6,
              height: 6,
              decoration:
                  BoxDecoration(shape: BoxShape.circle, color: tokens.gold),
            ),
          ),
          SizedBox(width: layout.space6),
          Expanded(
            child: SportoGradientText(
              'This is a Quick Booking - your request goes out to eligible nearby referees after payment. The first to accept is assigned.',
              gradient: tokens.gradientGold,
              style: SportoTextStyles.text(
                size: SportoTextStyles.size12,
                weight: SportoTextStyles.medium,
                color: Colors.white,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

