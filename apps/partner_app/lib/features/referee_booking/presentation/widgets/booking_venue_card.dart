import 'package:flutter/material.dart';
import 'package:ui_kit/ui_kit.dart';

/// Venue/sport summary card used across the booking flow
/// (Figma `SIGNATURE: MATCH TICKET` header card: pink gradient @10% + blur).
class BookingVenueCard extends StatelessWidget {
  final String sport;
  final String venue;
  final String area;
  final String? meta;
  final double radius;

  const BookingVenueCard({
    super.key,
    required this.sport,
    required this.venue,
    required this.area,
    this.meta,
    this.radius = 20,
  });

  @override
  Widget build(BuildContext context) {
    final tokens = context.sporto;
    final layout = context.sportoLayout;
    final pink = LinearGradient(
      colors:
          tokens.gradientPink.colors.map((c) => c.withValues(alpha: 0.2)).toList(),
    );
    return SportoGlassSurface(
      radius: radius,
      gradient: pink,
      blur: layout.glassBlur,
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              const SportoSvgIcon(SportoRefereeBookingIcons.sport,
                  width: 17, height: 16),
              SizedBox(width: layout.space8),
              Text(
                sport,
                style: SportoTextStyles.text(
                  size: SportoTextStyles.size12,
                  weight: SportoTextStyles.bold,
                  color: tokens.accentGreen,
                ),
              ),
            ],
          ),
          SizedBox(height: layout.space6),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SportoSvgIcon(SportoRefereeBookingIcons.pinGreen,
                  width: 11, height: 12),
              SizedBox(width: layout.space4),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      venue,
                      style: SportoTextStyles.text(
                        size: SportoTextStyles.size14,
                        weight: SportoTextStyles.medium,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                    Text(
                      area,
                      style: SportoTextStyles.text(
                        size: SportoTextStyles.size12,
                        weight: SportoTextStyles.regular,
                        color: tokens.muted,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (meta != null) ...[
            SizedBox(height: layout.space6),
            Text(
              meta!,
              style: SportoTextStyles.text(
                size: SportoTextStyles.size13,
                weight: SportoTextStyles.medium,
                color: tokens.muted,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

