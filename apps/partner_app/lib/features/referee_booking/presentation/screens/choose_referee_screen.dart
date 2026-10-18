import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:ui_kit/ui_kit.dart';

import '../widgets/booking_referee_card.dart';
import '../widgets/booking_venue_card.dart';

/// Screen 13 - Choose Referee (Figma E1-13). Scrollable list of referees.
class ChooseRefereeScreen extends StatelessWidget {
  const ChooseRefereeScreen({super.key});

  static const List<String> _sorts = [
    'Best Match',
    'Top Rated',
    'Closest',
    'Lowest Price',
    'Most Experienced',
  ];

  @override
  Widget build(BuildContext context) {
    final tokens = context.sporto;
    final gap = context.sportoLayout;
    return MediaQuery.withNoTextScaling(
      child: Scaffold(
        backgroundColor: tokens.canvas,
        appBar: SportoBookingAppBar(
          title: 'Your Sponsorship',
          onBack: () => context.canPop() ? context.pop() : context.go('/'),
        ),
        body: SafeArea(
          top: false,
          child: ListView(
            padding: EdgeInsets.fromLTRB(20, gap.space10, 20, gap.space20),
            children: [
              const BookingVenueCard(
                sport: 'Cricket',
                venue: 'KPHB Indoor Stadium',
                area: 'Kompally, Hyderabad',
                meta: '12 Oct 2026   \u2022   5:00 PM',
              ),
              SizedBox(height: gap.space20),
              SportoGradientText(
                'Choose Referee',
                gradient: tokens.gradientBlue,
                style: SportoTextStyles.text(
                  size: SportoTextStyles.size14,
                  weight: SportoTextStyles.semiBold,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: gap.space10),
              _SortRow(sorts: _sorts),
              SizedBox(height: gap.space16),
              BookingRefereeCard(
                name: 'Suresh Reddy',
                sport: 'Cricket',
                experience: '8 yrs',
                level: '3 Level',
                rating: '4.8',
                matches: '34 matches',
                price: '\u20B91800',
                distance: '3.6 km away',
                onTap: () => context.go('/book-referee/referee/r1'),
              ),
              SizedBox(height: gap.space10),
              BookingRefereeCard(
                name: 'Vijay Mohan',
                sport: 'Cricket',
                experience: '6 yrs',
                level: '3 Level',
                rating: '4.6',
                matches: '28 matches',
                price: '\u20B91800',
                distance: '4.2 km away',
                onTap: () => context.go('/book-referee/referee/r2'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SortRow extends StatelessWidget {
  final List<String> sorts;
  const _SortRow({required this.sorts});

  @override
  Widget build(BuildContext context) {
    final tokens = context.sporto;
    final gap = context.sportoLayout;
    return Row(
      children: [
        Text(
          'Sort By',
          style: SportoTextStyles.text(
            size: SportoTextStyles.size12,
            weight: SportoTextStyles.medium,
            color: tokens.muted,
          ),
        ),
        SizedBox(width: gap.space8),
        Expanded(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                for (var i = 0; i < sorts.length; i++) ...[
                  SportoSortChip(label: sorts[i], selected: i == 0),
                  if (i != sorts.length - 1) SizedBox(width: gap.space8),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }
}
