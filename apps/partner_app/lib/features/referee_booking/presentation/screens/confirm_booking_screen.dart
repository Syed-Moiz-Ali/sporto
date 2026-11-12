import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:ui_kit/ui_kit.dart';

import '../../application/booking_bloc.dart';
import '../widgets/booking_details_section.dart';
import '../widgets/booking_primary_button.dart';
import '../widgets/booking_venue_card.dart';

/// Screen 9 - Confirm Booking (Figma E1-09).
class ConfirmBookingScreen extends StatefulWidget {
  const ConfirmBookingScreen({super.key});

  @override
  State<ConfirmBookingScreen> createState() => _ConfirmBookingScreenState();
}

class _ConfirmBookingScreenState extends State<ConfirmBookingScreen> {
  bool _requested = false;

  @override
  Widget build(BuildContext context) {
    final tokens = context.sporto;
    final gap = context.sportoLayout;
    return MediaQuery.withNoTextScaling(
      child: BlocConsumer<BookingBloc, BookingState>(
        listener: (context, state) {
          if (!_requested) return;
          if (state.hasError) {
            setState(() => _requested = false);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  state.error?.message ?? 'Unable to create booking.',
                ),
              ),
            );
            return;
          }
          if (!state.isLoading && state.bookingDetails != null) {
            setState(() => _requested = false);
            context.go('/book-referee/payment');
          }
        },
        builder: (context, state) {
          return Scaffold(
            backgroundColor: tokens.canvas,
            appBar: SportoBookingAppBar(
              title: 'Confirm Booking',
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
                  ),
                  SizedBox(height: gap.space20),
                  BookingDetailsSection(
                    tournament: 'SPOTO Random Cricket \u2014 Hyderabad',
                    venue: 'KPHB Indoor Stadium',
                    location: 'Kompally, Hyderabad',
                    date: state.selectedDate,
                    time: state.selectedTime,
                    duration: state.selectedDuration,
                    bookingType: state.scheduleMode == ScheduleMode.daily
                        ? 'Daily'
                        : 'Hourly',
                  ),
                  SizedBox(height: gap.space20),
                  const _NoticeCard(
                    text:
                        'This is a Quick Booking - your request goes out to eligible nearby referees after payment. The first to accept is assigned.',
                  ),
                  SizedBox(height: gap.space20),
                  const SportoPriceSummaryCard(
                    rows: [
                      SportoPriceRow('Referee Fee', '\u20B91350'),
                      SportoPriceRow('Platform Fee', '\u20B9135'),
                    ],
                    totalLabel: 'Total Paid',
                    totalValue: '\u20B91385',
                  ),
                  SizedBox(height: gap.space20),
                  BookingPrimaryButton(
                    label: state.isLoading
                        ? 'Creating booking…'
                        : 'Proceed To Booking',
                    onTap: state.isLoading
                        ? () {}
                        : () {
                            setState(() => _requested = true);
                            context
                                .read<BookingBloc>()
                                .add(const BookingConfirm());
                          },
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _NoticeCard extends StatelessWidget {
  final String text;
  const _NoticeCard({required this.text});

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
      colors: tokens.gradientGold.colors
          .map((c) => c.withValues(alpha: 0.5))
          .toList(),
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
              text,
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
