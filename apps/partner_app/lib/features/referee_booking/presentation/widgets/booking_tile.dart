import 'package:flutter/material.dart';
import 'package:ui_kit/ui_kit.dart';

import '../../application/booking_models.dart';

/// Booking list tile (Figma `DocCard` 350x70/73 + status pill).
///
/// Built from shared primitives (`SportoDocCard`, `SportoStatusPill`,
/// `SportoSvgIcon`, `SportoTextStyles`) with the exact Figma composition.
class BookingTile extends StatelessWidget {
  final Booking booking;
  final VoidCallback? onTap;

  const BookingTile({super.key, required this.booking, this.onTap});

  LinearGradient get _statusGradient => switch (booking.status) {
        BookingStatus.upcoming => SportoStatusPill.orange,
        BookingStatus.ongoing => SportoStatusPill.blue,
        BookingStatus.completed => SportoStatusPill.green,
      };

  String get _statusLabel => switch (booking.status) {
        BookingStatus.upcoming => 'Upcoming',
        BookingStatus.ongoing => 'Ongoing',
        BookingStatus.completed => 'Completed',
      };

  String get _clockAsset => switch (booking.status) {
        // No blue clock asset was exported; the orange clock is the closest
        // available (deferred: add `ic_clock_blue` if required).
        BookingStatus.upcoming => SportoRefereeBookingIcons.clockOrange,
        BookingStatus.ongoing => SportoRefereeBookingIcons.clockOrange,
        BookingStatus.completed => SportoRefereeBookingIcons.clockGreen,
      };

  @override
  Widget build(BuildContext context) {
    final tokens = context.sporto;
    final gap = context.sportoLayout;
    final onSurface = Theme.of(context).colorScheme.onSurface;

    return SportoDocCard(
      padding: const EdgeInsets.all(10),
      onTap: onTap,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _RefereeAvatar(),
          SizedBox(width: gap.space10),
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
                              size: SportoTextStyles.size16,
                              weight: SportoTextStyles.semiBold,
                              color: onSurface,
                              height: 1.15,
                            ),
                          ),
                          SizedBox(height: gap.space2),
                          Row(
                            children: [
                              Text(
                                booking.sport,
                                style: SportoTextStyles.text(
                                  size: SportoTextStyles.size13,
                                  weight: SportoTextStyles.medium,
                                  color: tokens.accentGreen,
                                  height: 1.1,
                                ),
                              ),
                              const _Dot(),
                              Text(
                                '${booking.level} Level',
                                style: SportoTextStyles.text(
                                  size: SportoTextStyles.size13,
                                  weight: SportoTextStyles.medium,
                                  color: tokens.muted,
                                  height: 1.1,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    SizedBox(width: gap.space8),
                    SportoStatusPill(
                      label: _statusLabel,
                      gradient: _statusGradient,
                      leading: SportoSvgIcon(_clockAsset, size: 12),
                    ),
                  ],
                ),
                SizedBox(height: gap.space6),
                Row(
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          Text(
                            booking.durationLabel,
                            style: SportoTextStyles.text(
                              size: SportoTextStyles.size13,
                              weight: SportoTextStyles.medium,
                              color: tokens.gold,
                              height: 1.1,
                            ),
                          ),
                          const _Dot(),
                          Flexible(
                            child: Text(
                              booking.dateLabel,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: SportoTextStyles.text(
                                size: SportoTextStyles.size13,
                                weight: SportoTextStyles.medium,
                                color: tokens.muted,
                                height: 1.1,
                              ),
                            ),
                          ),
                          const _Dot(),
                          Text(
                            booking.timeLabel,
                            style: SportoTextStyles.text(
                              size: SportoTextStyles.size13,
                              weight: SportoTextStyles.medium,
                              color: tokens.muted,
                              height: 1.1,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(width: gap.space8),
                    Text(
                      '\u20B9${booking.price.toInt()}',
                      style: SportoTextStyles.text(
                        size: SportoTextStyles.size15,
                        weight: SportoTextStyles.semiBold,
                        color: onSurface,
                        height: 1.1,
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
}

class _Dot extends StatelessWidget {
  const _Dot();

  @override
  Widget build(BuildContext context) => const Padding(
        padding: EdgeInsets.symmetric(horizontal: 5),
        child: SportoSvgIcon(SportoRefereeBookingIcons.dotSeparator, size: 3),
      );
}

class _RefereeAvatar extends StatelessWidget {
  const _RefereeAvatar();

  @override
  Widget build(BuildContext context) {
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
