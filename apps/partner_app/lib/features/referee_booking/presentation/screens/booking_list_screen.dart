import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:ui_kit/ui_kit.dart';

import '../../application/booking_bloc.dart';
import '../../application/booking_models.dart';
import '../widgets/booking_referee_card.dart';

/// Screen 1 - Booking list / "Book A Referee" home (Figma E1-01).
class BookingListScreen extends StatelessWidget {
  const BookingListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MediaQuery.withNoTextScaling(
      child: Scaffold(
        backgroundColor: context.sporto.canvas,
        appBar: SportoBookingAppBar(
          title: 'Book A Referee',
          subtitle: 'Certified officials for your next match.',
          onBack: () => context.canPop() ? context.pop() : context.go('/'),
        ),
        body: SportoBlocStateView<BookingBloc, BookingState, List<Booking>>(
          bloc: context.read<BookingBloc>(),
          statusOf: (s) => s.isLoading
              ? SportoUiStatus.loading
              : s.hasError
                  ? SportoUiStatus.error
                  : s.bookings.isEmpty
                      ? SportoUiStatus.empty
                      : SportoUiStatus.data,
          dataOf: (s) => s.bookings,
          errorOf: (s) => s.error,
          onRetry: () => context.read<BookingBloc>().add(const BookingRetry()),
          skeleton: const Padding(
            padding: EdgeInsets.fromLTRB(20, 10, 20, 20),
            child: SportoSkeletonList(
              itemCount: 3,
              itemBuilder: _bookingSkeleton,
            ),
          ),
          empty: SportoEmptyView(
            headline: 'No referee bookings yet',
            action: 'Book Now',
            onAction: () => context.go('/book-referee/sport'),
          ),
          builder: (bookings) => _Content(bookings: bookings),
        ),
      ),
    );
  }
}

class _Content extends StatelessWidget {
  final List<Booking> bookings;
  const _Content({required this.bookings});

  @override
  Widget build(BuildContext context) {
    final gap = context.sportoLayout;
    return ListView(
      padding: EdgeInsets.fromLTRB(20, gap.space10, 20, gap.space20),
      children: [
        const _PromoCard(),
        SizedBox(height: gap.space20),
        _TabsCard(bookings: bookings),
        SizedBox(height: gap.space20),
        const _LastAssigned(),
      ],
    );
  }
}

class _PromoCard extends StatelessWidget {
  const _PromoCard();

  @override
  Widget build(BuildContext context) {
    final tokens = context.sporto;
    final layout = context.sportoLayout;
    return SportoGlassSurface(
      radius: layout.radius20,
      color: tokens.gold,
      padding: const EdgeInsets.all(14),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Tournament',
                  style: SportoTextStyles.text(
                    size: SportoTextStyles.size12,
                    weight: SportoTextStyles.semiBold,
                    color: tokens.canvas,
                  ),
                ),
                SizedBox(height: layout.space2),
                Text(
                  'Book A Referee',
                  style: SportoTextStyles.text(
                    size: SportoTextStyles.size16,
                    weight: SportoTextStyles.bold,
                    color: tokens.canvas,
                  ),
                ),
              ],
            ),
          ),
          SportoGlassSurface(
            radius: layout.radius12,
            color: tokens.canvas,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            child: Text(
              'Book Now',
              style: SportoTextStyles.text(
                size: SportoTextStyles.size14,
                weight: SportoTextStyles.bold,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TabsCard extends StatelessWidget {
  final List<Booking> bookings;
  const _TabsCard({required this.bookings});

  @override
  Widget build(BuildContext context) {
    final tokens = context.sporto;
    final layout = context.sportoLayout;
    return SportoGlassSurface(
      radius: layout.radius16,
      color: tokens.gold.withValues(alpha: 0.06),
      padding: const EdgeInsets.all(10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              const _TabChip(label: 'Upcoming (1)', selected: true),
              SizedBox(width: layout.space10),
              const _TabChip(label: 'Ongoing (1)', selected: false),
            ],
          ),
          SizedBox(height: layout.space10),
          for (var i = 0; i < bookings.length && i < 2; i++) ...[
            GestureDetector(
              onTap: () => context.go('/bookings/${bookings[i].id}'),
              behavior: HitTestBehavior.opaque,
              child: _BookingRow(booking: bookings[i]),
            ),
            if (i == 0) SizedBox(height: layout.space10),
          ],
        ],
      ),
    );
  }
}

class _TabChip extends StatelessWidget {
  final String label;
  final bool selected;
  const _TabChip({required this.label, required this.selected});

  @override
  Widget build(BuildContext context) {
    final tokens = context.sporto;
    final layout = context.sportoLayout;
    return SportoGlassSurface(
      radius: layout.radius10,
      color: selected ? tokens.accentGreen : tokens.cardElevated,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      child: Text(
        label,
        style: SportoTextStyles.text(
          size: SportoTextStyles.size12,
          weight: selected ? SportoTextStyles.semiBold : SportoTextStyles.medium,
          color: selected ? tokens.canvas : Theme.of(context).colorScheme.onSurface,
        ),
      ),
    );
  }
}

class _BookingRow extends StatelessWidget {
  final Booking booking;
  const _BookingRow({required this.booking});

  @override
  Widget build(BuildContext context) {
    final tokens = context.sporto;
    final layout = context.sportoLayout;
    final onSurface = Theme.of(context).colorScheme.onSurface;
    return SportoGlassSurface(
      radius: layout.radius16,
      color: tokens.card,
      borderGradient: SportoGlassBorders.green,
      padding: const EdgeInsets.all(10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _avatar(context),
          SizedBox(width: layout.space8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            booking.refereeName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: SportoTextStyles.text(
                              size: SportoTextStyles.size14,
                              weight: SportoTextStyles.semiBold,
                              color: onSurface,
                            ),
                          ),
                          Row(
                            children: [
                              Text(
                                booking.sport,
                                style: SportoTextStyles.text(
                                  size: SportoTextStyles.size10,
                                  weight: SportoTextStyles.semiBold,
                                  color: tokens.accentGreen,
                                ),
                              ),
                              const _Dot(),
                              Flexible(
                                child: Text(
                                  booking.venue,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: SportoTextStyles.text(
                                    size: SportoTextStyles.size10,
                                    weight: SportoTextStyles.medium,
                                    color: tokens.muted,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    SizedBox(width: layout.space8),
                    SportoStatusPill(
                      label: booking.status == BookingStatus.ongoing
                          ? 'Ongoing'
                          : 'Upcoming',
                      gradient: booking.status == BookingStatus.ongoing
                          ? SportoStatusPill.blue
                          : SportoStatusPill.orange,
                    ),
                  ],
                ),
                SizedBox(height: layout.space4),
                Row(
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          Text(
                            booking.durationLabel,
                            style: SportoTextStyles.text(
                              size: SportoTextStyles.size10,
                              weight: SportoTextStyles.medium,
                              color: tokens.gold,
                            ),
                          ),
                          const _Dot(),
                          Flexible(
                            child: Text(
                              booking.dateLabel,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: SportoTextStyles.text(
                                size: SportoTextStyles.size10,
                                weight: SportoTextStyles.medium,
                                color: tokens.muted,
                              ),
                            ),
                          ),
                          const _Dot(),
                          Text(
                            booking.timeLabel,
                            style: SportoTextStyles.text(
                              size: SportoTextStyles.size10,
                              weight: SportoTextStyles.medium,
                              color: tokens.muted,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(width: layout.space8),
                    Text(
                      '\u20B9${booking.price.toInt()}',
                      style: SportoTextStyles.text(
                        size: SportoTextStyles.size12,
                        weight: SportoTextStyles.medium,
                        color: onSurface,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _avatar(BuildContext context) {
    final tokens = context.sporto;
    return Container(
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
    );
  }
}

class _LastAssigned extends StatelessWidget {
  const _LastAssigned();

  @override
  Widget build(BuildContext context) {
    final tokens = context.sporto;
    final layout = context.sportoLayout;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            Text(
              'Last Assigned',
              style: SportoTextStyles.text(
                size: SportoTextStyles.size14,
                weight: SportoTextStyles.medium,
                color: tokens.muted,
              ),
            ),
            const Spacer(),
            SportoGradientText(
              'View all',
              gradient: tokens.gradientBlue,
              style: SportoTextStyles.text(
                size: SportoTextStyles.size12,
                weight: SportoTextStyles.regular,
                color: Colors.white,
              ),
            ),
            const SportoSvgIcon(SportoRefereeBookingIcons.chevronRight,
                size: 14),
          ],
        ),
        SizedBox(height: layout.space10),
        BookingRefereeCard(
          name: 'Suresh Reddy',
          sport: 'Cricket',
          experience: '8 yrs',
          level: '3 Level',
          rating: '4.8',
          matches: '34 matches',
          price: '\u20B9800',
          onTap: () => context.go('/book-referee/referee/r1'),
        ),
        SizedBox(height: layout.space10),
        BookingRefereeCard(
          name: 'Suresh Reddy',
          sport: 'Cricket',
          experience: '8 yrs',
          level: '3 Level',
          rating: '4.8',
          matches: '34 matches',
          price: '\u20B9800',
          onTap: () => context.go('/book-referee/referee/r2'),
        ),
      ],
    );
  }
}

class _Dot extends StatelessWidget {
  const _Dot();

  @override
  Widget build(BuildContext context) => const Padding(
        padding: EdgeInsets.symmetric(horizontal: 4),
        child: SportoSvgIcon(SportoRefereeBookingIcons.dotSeparator, size: 3),
      );
}

Widget _bookingSkeleton(BuildContext context) => const BookingListItemSkeleton();
