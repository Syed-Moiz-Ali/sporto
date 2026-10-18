import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:ui_kit/ui_kit.dart';

import '../../application/booking_bloc.dart';
import '../../application/booking_models.dart';

/// Screen 3 - Select Sport (Figma `03_Referees`).
///
/// Two-column grid of sport cards. Selecting a sport persists it in
/// [BookingState.selectedSport] and continues to the location step.
class SelectSportScreen extends StatelessWidget {
  const SelectSportScreen({super.key});

  /// (name, svg asset or null, emoji or null).
  static const List<(String, String?, String?)> _sports = [
    ('Cricket', SportoRefereeBookingIcons.sportCricket, null),
    ('Football', SportoRefereeBookingIcons.sportFootball, null),
    ('Badminton', null, '\u{1F3F8}'),
    ('Basketball', null, '\u{1F3C0}'),
    // NOTE: Figma reuses the football vector for "Darts" (an export bug); a
    // darts emoji is used instead.
    ('Darts', null, '\u{1F3AF}'),
    ('Hockey', null, '\u{1F3D1}'),
    ('Kabaddi', null, '\u{1F93C}'),
    ('Kho Kho', null, '\u{1F3C3}'),
    ('Table Tennis', null, '\u{1F3D3}'),
    ('Throwball', null, '\u{1F3D0}'),
    ('Volleyball', null, '\u{1F3D0}'),
  ];

  @override
  Widget build(BuildContext context) {
    final gap = context.sportoLayout;
    final tokens = context.sporto;
    return MediaQuery.withNoTextScaling(
      child: Scaffold(
        backgroundColor: tokens.canvas,
        appBar: SportoBookingAppBar(
          title: 'Select Sport',
          subtitle: 'Book A Referee',
          onBack: () => context.canPop() ? context.pop() : context.go('/'),
        ),
        body: SafeArea(
          top: false,
          child: ListView(
            padding: EdgeInsets.fromLTRB(20, gap.space10, 20, gap.space20),
            children: [
              SportoGradientText(
                'Which sport needs an official?',
                gradient: tokens.gradientBlue,
                style: SportoTextStyles.text(
                  size: SportoTextStyles.size14,
                  weight: SportoTextStyles.semiBold,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: gap.space20),
              BlocBuilder<BookingBloc, BookingState>(
                builder: (context, state) {
                  final selectedName = state.selectedSport?.name;
                  return Wrap(
                    spacing: gap.space16,
                    runSpacing: gap.space16,
                    children: [
                      for (final sport in _sports)
                        _SportCard(
                          name: sport.$1,
                          asset: sport.$2,
                          emoji: sport.$3,
                          selected: selectedName == sport.$1,
                          onTap: () {
                            context.read<BookingBloc>().add(
                                  BookingSelectSport(
                                    Sport(id: sport.$1.toLowerCase(), name: sport.$1),
                                  ),
                                );
                            context.go('/book-referee/location');
                          },
                        ),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SportCard extends StatelessWidget {
  final String name;
  final String? asset;
  final String? emoji;
  final bool selected;
  final VoidCallback onTap;

  const _SportCard({
    required this.name,
    required this.asset,
    required this.emoji,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final tokens = context.sporto;
    final layout = context.sportoLayout;
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: SportoGlassSurface(
        width: 167,
        radius: layout.radius14,
        gradient: selected ? tokens.gradientBlue : null,
        color: selected ? null : tokens.panel.withValues(alpha: 0.3),
        borderColor: tokens.hairlineWarm.withValues(alpha: 0.08),
        padding: EdgeInsets.symmetric(
          horizontal: layout.space10,
          vertical: layout.space8,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            _iconTile(context),
            SizedBox(height: layout.space10),
            Text(
              name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: SportoTextStyles.text(
                size: SportoTextStyles.size12,
                weight: selected ? SportoTextStyles.semiBold : SportoTextStyles.medium,
                color: selected ? tokens.canvas : tokens.muted,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _iconTile(BuildContext context) {
    final tokens = context.sporto;
    final layout = context.sportoLayout;
    if (asset != null) {
      return SportoSvgIcon(asset!, width: 50, height: 50);
    }
    return SportoGlassSurface(
      width: 50,
      height: 50,
      radius: layout.radius16,
      blur: layout.glassBlur,
      color: tokens.iconTile.withValues(alpha: 0.5),
      borderColor: tokens.whiteOverlay10,
      child: Center(
        child: Text(
          emoji ?? '',
          style: SportoTextStyles.text(
            size: SportoTextStyles.size28,
            weight: SportoTextStyles.medium,
            color: tokens.muted,
            height: 1.0,
          ),
        ),
      ),
    );
  }
}
