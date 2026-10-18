import 'package:flutter/material.dart';
import 'package:ui_kit/ui_kit.dart';

/// Tournament / Venue / Location + Date / Start Time / Duration + Booking Type
/// block (Figma `Section` 350x269, `#12161C`).
class BookingDetailsSection extends StatelessWidget {
  final String tournament;
  final String venue;
  final String location;
  final String date;
  final String time;
  final String duration;
  final String bookingType;

  const BookingDetailsSection({
    super.key,
    required this.tournament,
    required this.venue,
    required this.location,
    required this.date,
    required this.time,
    required this.duration,
    required this.bookingType,
  });

  @override
  Widget build(BuildContext context) {
    final tokens = context.sporto;
    final layout = context.sportoLayout;
    return SportoGlassSurface(
      radius: layout.radius16,
      blur: layout.glassBlur,
      color: tokens.section,
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          _pair(context, 'Tournament', tournament),
          SizedBox(height: layout.space10),
          _pair(context, 'Venue', venue),
          SizedBox(height: layout.space10),
          _pair(context, 'Location', location),
          SizedBox(height: layout.space10),
          SportoGlassSurface(
            radius: layout.radius14,
            gradient: _alpha(tokens.gradientBlue, 0.04),
            padding: EdgeInsets.symmetric(
                horizontal: layout.space14, vertical: layout.space10),
            child: Row(
              children: [
                _stat(context, 'Date', date),
                const Spacer(),
                _stat(context, 'Start Time', time),
                const Spacer(),
                _stat(context, 'Duration', duration),
              ],
            ),
          ),
          SizedBox(height: layout.space10),
          Row(
            children: [
              Text(
                'Booking Type: ',
                style: SportoTextStyles.text(
                  size: SportoTextStyles.size14,
                  weight: SportoTextStyles.medium,
                  color: tokens.muted,
                ),
              ),
              Text(
                bookingType,
                style: SportoTextStyles.text(
                  size: SportoTextStyles.size14,
                  weight: SportoTextStyles.semiBold,
                  color: tokens.accentGreen,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _pair(BuildContext context, String label, String value) {
    final tokens = context.sporto;
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
        Text(
          value,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: SportoTextStyles.text(
            size: SportoTextStyles.size16,
            weight: SportoTextStyles.medium,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
      ],
    );
  }

  Widget _stat(BuildContext context, String label, String value) {
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
        Text(
          value,
          style: SportoTextStyles.text(
            size: SportoTextStyles.size14,
            weight: SportoTextStyles.semiBold,
            color: Theme.of(context).colorScheme.onSurface,
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
