import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:ui_kit/ui_kit.dart';

import '../../application/booking_bloc.dart';
import '../widgets/booking_primary_button.dart';
import '../widgets/booking_venue_card.dart';

/// Screens 8 & 12 - "Your Sponsorship" schedule (Figma E1-08 / E1-12).
///
/// ONE screen, two states selected via the Hourly / Daily segmented control.
class BookingScheduleScreen extends StatelessWidget {
  const BookingScheduleScreen({super.key});

  static const List<String> _dates = [
    '12 Oct 2026',
    '13 Oct 2026',
    '14 Oct 2026',
    '15 Oct 2026',
  ];
  static const List<String> _times = ['3:00 PM', '5:00 PM', '6:30 PM', '8:00 PM'];
  static const List<String> _durations = ['1 Hour', '2 Hours'];

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
          child: BlocBuilder<BookingBloc, BookingState>(
            builder: (context, state) {
              return ListView(
                padding: EdgeInsets.fromLTRB(20, gap.space10, 20, gap.space20),
                children: [
                  const BookingVenueCard(
                    sport: 'Cricket',
                    venue: 'KPHB Indoor Stadium',
                    area: 'Kompally, Hyderabad',
                  ),
                  SizedBox(height: gap.space20),
                  Center(
                    child: SportoGradientText(
                      'Booking Type',
                      gradient: tokens.gradientBlue,
                      style: SportoTextStyles.text(
                        size: SportoTextStyles.size14,
                        weight: SportoTextStyles.semiBold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  SizedBox(height: gap.space10),
                  Center(
                    child: _Segmented(
                      selected: state.scheduleMode,
                      onChanged: (mode) => context
                          .read<BookingBloc>()
                          .add(BookingSelectScheduleMode(mode)),
                    ),
                  ),
                  SizedBox(height: gap.space20),
                  _ChipSection(
                    label: 'Date',
                    options: _dates,
                    selected: state.selectedDate,
                    onSelect: (v) => context
                        .read<BookingBloc>()
                        .add(BookingSelectDate(v)),
                  ),
                  SizedBox(height: gap.space20),
                  _ChipSection(
                    label: 'Start Time',
                    options: _times,
                    selected: state.selectedTime,
                    onSelect: (v) => context
                        .read<BookingBloc>()
                        .add(BookingSelectTime(v)),
                  ),
                  SizedBox(height: gap.space20),
                  _ChipSection(
                    label: 'Duration',
                    options: _durations,
                    selected: state.selectedDuration,
                    onSelect: (v) => context
                        .read<BookingBloc>()
                        .add(BookingSelectDuration(v)),
                  ),
                  SizedBox(height: gap.space30),
                  BookingPrimaryButton(
                    label: 'Register Individually',
                    onTap: () => context.go('/book-referee/confirm'),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class _Segmented extends StatelessWidget {
  final ScheduleMode selected;
  final ValueChanged<ScheduleMode> onChanged;

  const _Segmented({required this.selected, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final tokens = context.sporto;
    final track = _alpha(tokens.gradientBlue, 0.1);
    return Align(
      alignment: Alignment.centerLeft,
      child: SportoGlassSurface(
        radius: 60,
        gradient: track,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _seg(context, 'Hourly', ScheduleMode.hourly),
            const SizedBox(width: 10),
            _seg(context, 'Daily', ScheduleMode.daily),
          ],
        ),
      ),
    );
  }

  Widget _seg(BuildContext context, String label, ScheduleMode mode) {
    final tokens = context.sporto;
    final active = selected == mode;
    return GestureDetector(
      onTap: () => onChanged(mode),
      behavior: HitTestBehavior.opaque,
      child: SportoGlassSurface(
        width: 109,
        height: 30,
        radius: 60,
        gradient: active ? tokens.gradientBlue : null,
        color: active ? null : tokens.canvas.withValues(alpha: 0.3),
        child: Center(
          child: Text(
            label,
            style: SportoTextStyles.text(
              size: SportoTextStyles.size14,
              weight: SportoTextStyles.semiBold,
              color: active ? tokens.canvas : tokens.muted,
            ),
          ),
        ),
      ),
    );
  }
}

class _ChipSection extends StatelessWidget {
  final String label;
  final List<String> options;
  final String selected;
  final ValueChanged<String> onSelect;

  const _ChipSection({
    required this.label,
    required this.options,
    required this.selected,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    final tokens = context.sporto;
    final gap = context.sportoLayout;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: SportoTextStyles.text(
            size: SportoTextStyles.size14,
            weight: SportoTextStyles.medium,
            color: tokens.muted,
          ),
        ),
        SizedBox(height: gap.space10),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              for (var i = 0; i < options.length; i++) ...[
                SportoChoiceChip(
                  label: options[i],
                  selected: selected == options[i],
                  onTap: () => onSelect(options[i]),
                ),
                if (i != options.length - 1) SizedBox(width: gap.space10),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

LinearGradient _alpha(Gradient g, double a) {
  final lg = g is LinearGradient ? g : null;
  return LinearGradient(
    begin: lg?.begin ?? Alignment.topLeft,
    end: lg?.end ?? Alignment.bottomRight,
    colors: g.colors.map((c) => c.withValues(alpha: a)).toList(),
    stops: lg?.stops,
  );
}
