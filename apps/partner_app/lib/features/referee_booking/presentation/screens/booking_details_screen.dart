import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:ui_kit/ui_kit.dart';

import '../../application/booking_bloc.dart';

/// Package 2 - Booking Details (Figma 01/02/03). ONE screen, three status
/// variants driven by [BookingState.detailsStatus].
class BookingDetailsScreen extends StatelessWidget {
  const BookingDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final tokens = context.sporto;
    final gap = context.sportoLayout;
    final status = context.watch<BookingBloc>().state.detailsStatus;
    final d = _DetailsData.of(status);

    return MediaQuery.withNoTextScaling(
      child: Scaffold(
        backgroundColor: tokens.canvas,
        appBar: SportoBookingAppBar(
          title: 'Booking Details',
          onBack: () => context.canPop() ? context.pop() : context.go('/'),
        ),
        body: SafeArea(
          top: false,
          child: ListView(
            padding: EdgeInsets.fromLTRB(20, gap.space10, 20, gap.space20),
            children: [
              _RefereeHeaderCard(data: d, status: status),
              SizedBox(height: gap.space20),
              _ScheduleCard(data: d),
              SizedBox(height: gap.space20),
              if (status == BookingDetailsStatus.upcoming) ...[
                _OtpCard(),
                SizedBox(height: gap.space20),
              ],
              _TicketCard(data: d),
              SizedBox(height: gap.space20),
              _PaymentCard(data: d),
              if (status == BookingDetailsStatus.ongoing) ...[
                SizedBox(height: gap.space20),
                _FinishSessionCard(),
              ],
              if (status == BookingDetailsStatus.upcoming) ...[
                SizedBox(height: gap.space20),
                Center(
                  child: SportoTagChip(
                    label: 'Cancel Booking',
                    onTap: () => context.go('/book-referee/bookings'),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _DetailsData {
  final String referee;
  final String sport;
  final String refId;
  final String bookingLabel;
  final String bookingValue;
  final String location;
  final String? actualStart;
  final String? startedAt;
  final String? endAt;
  final String otp;
  final String refereeFee;
  final String platformFee;
  final String totalPaid;

  const _DetailsData({
    required this.referee,
    required this.sport,
    required this.refId,
    required this.bookingLabel,
    required this.bookingValue,
    required this.location,
    required this.otp,
    required this.refereeFee,
    required this.platformFee,
    required this.totalPaid,
    this.actualStart,
    this.startedAt,
    this.endAt,
  });

  factory _DetailsData.of(BookingDetailsStatus status) => switch (status) {
        BookingDetailsStatus.upcoming => const _DetailsData(
              referee: 'Suresh Reddy',
              sport: 'Cricket',
              refId: 'REF-71910900',
              bookingLabel: 'Booking',
              bookingValue: 'Full Day',
              location: 'Kondapur, Hyderabad',
              otp: '220788',
              refereeFee: '\u20B912500',
              platformFee: '\u20B91250',
              totalPaid: '\u20B913750',
            ),
        BookingDetailsStatus.ongoing => const _DetailsData(
              referee: 'Vijay Mohan',
              sport: 'Cricket',
              refId: 'REF-71858723',
              bookingLabel: 'Booking',
              bookingValue: 'Full Day',
              location: 'Kompally, Hyderabad',
              actualStart: 'Today, 5:00 PM',
              otp: '889104',
              refereeFee: '\u20B912600',
              platformFee: '\u20B91260',
              totalPaid: '\u20B913860',
            ),
        BookingDetailsStatus.completed => const _DetailsData(
              referee: 'Vijay Mohan',
              sport: 'Cricket',
              refId: 'REF-71858723',
              bookingLabel: 'Duration',
              bookingValue: '2 Hours',
              location: 'Kompally, Hyderabad',
              startedAt: 'Today, 5:00 PM',
              endAt: 'Today, 7:00 PM',
              otp: '000000',
              refereeFee: '\u20B91350',
              platformFee: '\u20B9135',
              totalPaid: '\u20B91485',
            ),
      };
}

class _RefereeHeaderCard extends StatelessWidget {
  final _DetailsData data;
  final BookingDetailsStatus status;

  const _RefereeHeaderCard({required this.data, required this.status});

  @override
  Widget build(BuildContext context) {
    final tokens = context.sporto;
    final layout = context.sportoLayout;
    final pink = LinearGradient(
      colors:
          tokens.gradientPink.colors.map((c) => c.withValues(alpha: 0.2)).toList(),
    );
    final (pill, label) = switch (status) {
      BookingDetailsStatus.upcoming => (SportoStatusPill.orange, 'Upcoming'),
      BookingDetailsStatus.ongoing => (SportoStatusPill.blue, 'Ongoing'),
      BookingDetailsStatus.completed => (SportoStatusPill.green, 'Completed'),
    };
    return SportoGlassSurface(
      radius: layout.radius16,
      blur: layout.glassBlur,
      gradient: pink,
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Text(
                'Referee',
                style: SportoTextStyles.text(
                  size: SportoTextStyles.size14,
                  weight: SportoTextStyles.medium,
                  color: tokens.muted,
                ),
              ),
              const Spacer(),
              SportoStatusPill(
                label: label,
                gradient: pill,
                leading: const SportoSvgIcon(SportoRefereeBookingIcons.clockGreen,
                    size: 12),
              ),
            ],
          ),
          SizedBox(height: layout.space10),
          Row(
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
                    SportoGradientText(
                      data.referee,
                      gradient: tokens.gradientPink,
                      style: SportoTextStyles.text(
                        size: SportoTextStyles.size16,
                        weight: SportoTextStyles.semiBold,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      data.sport,
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
        ],
      ),
    );
  }
}

class _ScheduleCard extends StatelessWidget {
  final _DetailsData data;
  const _ScheduleCard({required this.data});

  @override
  Widget build(BuildContext context) {
    final tokens = context.sporto;
    final layout = context.sportoLayout;
    final goldFill = LinearGradient(
      colors: tokens.gradientGold.colors
          .map((c) => c.withValues(alpha: 0.06))
          .toList(),
    );
    final goldBorder = LinearGradient(
      colors:
          tokens.gradientGold.colors.map((c) => c.withValues(alpha: 0.2)).toList(),
    );
    return SportoGlassSurface(
      radius: layout.radius16,
      blur: layout.glassBlur,
      gradient: goldFill,
      borderGradient: goldBorder,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Text(
                'Schedule',
                style: SportoTextStyles.text(
                  size: SportoTextStyles.size13,
                  weight: SportoTextStyles.medium,
                  color: tokens.muted,
                ),
              ),
              SizedBox(width: layout.space6),
              Text(
                data.refId,
                style: SportoTextStyles.text(
                  size: SportoTextStyles.size13,
                  weight: SportoTextStyles.medium,
                  color: tokens.textTertiary,
                ),
              ),
            ],
          ),
          SizedBox(height: layout.space10),
          Row(
            children: [
              _col(context, 'Date', '13 Oct 2026'),
              const Spacer(),
              _col(context, 'Start Time', '5:00 PM'),
              const Spacer(),
              _col(context, data.bookingLabel, data.bookingValue),
            ],
          ),
          if (data.actualStart != null || data.startedAt != null) ...[
            SizedBox(height: layout.space10),
            _statLine(context, data),
          ],
        ],
      ),
    );
  }

  Widget _statLine(BuildContext context, _DetailsData data) {
    final tokens = context.sporto;
    final value = data.actualStart ?? data.startedAt ?? '';
    return Row(
      children: [
        Text(
          data.actualStart != null ? 'Actual Start: ' : 'Started At: ',
          style: SportoTextStyles.text(
            size: SportoTextStyles.size12,
            weight: SportoTextStyles.medium,
            color: tokens.textTertiary,
          ),
        ),
        Text(
          value,
          style: SportoTextStyles.text(
            size: SportoTextStyles.size12,
            weight: SportoTextStyles.medium,
            color: tokens.muted,
          ),
        ),
        if (data.endAt != null) ...[
          const Spacer(),
          Text(
            'End At: ',
            style: SportoTextStyles.text(
              size: SportoTextStyles.size12,
              weight: SportoTextStyles.medium,
              color: tokens.textTertiary,
            ),
          ),
          Text(
            data.endAt!,
            style: SportoTextStyles.text(
              size: SportoTextStyles.size12,
              weight: SportoTextStyles.medium,
              color: tokens.muted,
            ),
          ),
        ],
      ],
    );
  }

  Widget _col(BuildContext context, String label, String value) {
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
            color: tokens.muted,
          ),
        ),
        SportoGradientText(
          value,
          gradient: tokens.gradientGold,
          style: SportoTextStyles.text(
            size: SportoTextStyles.size14,
            weight: SportoTextStyles.semiBold,
            color: Colors.white,
          ),
        ),
      ],
    );
  }
}

class _OtpCard extends StatelessWidget {
  const _OtpCard();

  @override
  Widget build(BuildContext context) {
    final tokens = context.sporto;
    final layout = context.sportoLayout;
    final blueFill = LinearGradient(
      colors:
          tokens.gradientBlue.colors.map((c) => c.withValues(alpha: 0.05)).toList(),
    );
    final blueBorder = LinearGradient(
      colors:
          tokens.gradientBlue.colors.map((c) => c.withValues(alpha: 0.5)).toList(),
    );
    return SportoGlassSurface(
      radius: layout.radius20,
      blur: layout.glassBlur,
      gradient: blueFill,
      borderGradient: blueBorder,
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Start Session?',
            style: SportoTextStyles.text(
              size: SportoTextStyles.size16,
              weight: SportoTextStyles.bold,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          SizedBox(height: layout.space6),
          Text(
            'Share this OTP with your referee to start the session.',
            style: SportoTextStyles.text(
              size: SportoTextStyles.size12,
              weight: SportoTextStyles.medium,
              color: tokens.muted,
            ),
          ),
          SizedBox(height: layout.space20),
          Center(
            child: SportoGlassSurface(
              width: 227,
              height: 68,
              radius: layout.radius14,
              gradient: LinearGradient(
                colors: tokens.gradientBlue.colors
                    .map((c) => c.withValues(alpha: 0.04))
                    .toList(),
              ),
              child: Center(
                child: SportoGradientText(
                  '220788',
                  gradient: tokens.gradientBlue,
                  style: SportoTextStyles.text(
                    size: SportoTextStyles.size40,
                    weight: SportoTextStyles.bold,
                    color: Colors.white,
                    letterSpacing: 2.4,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TicketCard extends StatelessWidget {
  final _DetailsData data;
  const _TicketCard({required this.data});

  @override
  Widget build(BuildContext context) {
    final tokens = context.sporto;
    final layout = context.sportoLayout;
    final onSurface = Theme.of(context).colorScheme.onSurface;
    return SportoGlassSurface(
      radius: layout.radius20,
      blur: layout.glassBlur,
      gradient: _flat(tokens.accentGreen.withValues(alpha: 0.06)),
      borderColor: tokens.accentGreen.withValues(alpha: 0.2),
      padding: const EdgeInsets.fromLTRB(0, 0, 0, 6),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SportoGlassSurface(
            radius: layout.radius20,
            color: tokens.gold.withValues(alpha: 0.2),
            borderColor: tokens.gold.withValues(alpha: 0.2),
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Text(
                      'Tournament',
                      style: SportoTextStyles.text(
                        size: SportoTextStyles.size12,
                        weight: SportoTextStyles.medium,
                        color: tokens.muted,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      '24 Aug 2026',
                      style: SportoTextStyles.text(
                        size: SportoTextStyles.size12,
                        weight: SportoTextStyles.medium,
                        color: tokens.muted,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: layout.space6),
                Text(
                  'Kompally Turf Arena',
                  style: SportoTextStyles.text(
                    size: SportoTextStyles.size16,
                    weight: SportoTextStyles.semiBold,
                    color: onSurface,
                  ),
                ),
                SizedBox(height: layout.space4),
                Text(
                  'Team: Smash Arena',
                  style: SportoTextStyles.text(
                    size: SportoTextStyles.size14,
                    weight: SportoTextStyles.medium,
                    color: tokens.muted,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: layout.space6),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Booking Location',
                        style: SportoTextStyles.text(
                          size: SportoTextStyles.size12,
                          weight: SportoTextStyles.medium,
                          color: tokens.muted,
                        ),
                      ),
                      SizedBox(height: layout.space2),
                      Row(
                        children: [
                          SportoSvgIcon(SportoRefereeBookingIcons.pinGreen,
                              width: 11, height: 12),
                          SizedBox(width: layout.space4),
                          Text(
                            data.location,
                            style: SportoTextStyles.text(
                              size: SportoTextStyles.size15,
                              weight: SportoTextStyles.medium,
                              color: onSurface,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Container(
                  width: 30,
                  height: 30,
                  decoration: BoxDecoration(
                    color: tokens.gold,
                    borderRadius: BorderRadius.circular(layout.radius10),
                  ),
                  child: const Center(
                    child: SportoSvgIcon(
                      SportoRefereeBookingIcons.chevronRight,
                      size: 14,
                      color: Color(0xFF090C10),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  LinearGradient _flat(Color c) => LinearGradient(colors: [c, c]);
}

class _PaymentCard extends StatelessWidget {
  final _DetailsData data;
  const _PaymentCard({required this.data});

  @override
  Widget build(BuildContext context) {
    final tokens = context.sporto;
    final layout = context.sportoLayout;
    final onSurface = Theme.of(context).colorScheme.onSurface;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'Payment',
          style: SportoTextStyles.text(
            size: SportoTextStyles.size14,
            weight: SportoTextStyles.semiBold,
            color: tokens.muted,
          ),
        ),
        SizedBox(height: layout.space10),
        SportoGlassSurface(
          radius: layout.radius16,
          color: tokens.cardElevated.withValues(alpha: 0.4),
          padding: const EdgeInsets.all(14),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _row(context, 'Status', 'Confirmed', tokens.accentGreen),
              SizedBox(height: layout.space10),
              _row(context, 'Referee Fee', data.refereeFee, onSurface),
              SizedBox(height: layout.space10),
              _row(context, 'Platform Fee', data.platformFee, onSurface),
              SizedBox(height: layout.space10),
              Container(height: 1, color: tokens.border.withValues(alpha: 0.5)),
              SizedBox(height: layout.space10),
              _row(context, 'Total Paid', data.totalPaid, tokens.gold,
                  big: true),
            ],
          ),
        ),
      ],
    );
  }

  Widget _row(BuildContext context, String label, String value, Color color,
      {bool big = false}) {
    final tokens = context.sporto;
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: SportoTextStyles.text(
              size: SportoTextStyles.size14,
              weight: SportoTextStyles.medium,
              color: tokens.muted,
            ),
          ),
        ),
        Text(
          value,
          style: SportoTextStyles.text(
            size: big ? SportoTextStyles.size16 : SportoTextStyles.size14,
            weight: SportoTextStyles.semiBold,
            color: color,
          ),
        ),
      ],
    );
  }
}

class _FinishSessionCard extends StatelessWidget {
  const _FinishSessionCard();

  @override
  Widget build(BuildContext context) {
    final tokens = context.sporto;
    final layout = context.sportoLayout;
    final redFill = LinearGradient(
      colors:
          tokens.gradientRed.colors.map((c) => c.withValues(alpha: 0.05)).toList(),
    );
    final redBorder = LinearGradient(
      colors:
          tokens.gradientRed.colors.map((c) => c.withValues(alpha: 0.5)).toList(),
    );
    return SportoGlassSurface(
      radius: layout.radius20,
      blur: layout.glassBlur,
      gradient: redFill,
      borderGradient: redBorder,
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Finish Session?',
            style: SportoTextStyles.text(
              size: SportoTextStyles.size16,
              weight: SportoTextStyles.bold,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          SizedBox(height: layout.space6),
          Text(
            'Your referee has requested to finish the session. Share this OTP to confirm.',
            style: SportoTextStyles.text(
              size: SportoTextStyles.size12,
              weight: SportoTextStyles.medium,
              color: tokens.muted,
            ),
          ),
          SizedBox(height: layout.space16),
          Center(
            child: SportoGlassSurface(
              width: 227,
              height: 68,
              radius: layout.radius14,
              gradient: LinearGradient(
                colors: tokens.gradientRed.colors
                    .map((c) => c.withValues(alpha: 0.04))
                    .toList(),
              ),
              child: Center(
                child: SportoGradientText(
                  '889104',
                  gradient: tokens.gradientRed,
                  style: SportoTextStyles.text(
                    size: SportoTextStyles.size40,
                    weight: SportoTextStyles.bold,
                    color: Colors.white,
                    letterSpacing: 2.4,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

