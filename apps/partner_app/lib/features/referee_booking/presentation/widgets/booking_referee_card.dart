import 'package:flutter/material.dart';
import 'package:ui_kit/ui_kit.dart';

/// Referee list card (Figma `DocCard` 350x94): avatar, name, level, matches,
/// availability badge, trailing rating/price column and an optional distance.
class BookingRefereeCard extends StatelessWidget {
  final String name;
  final String sport;
  final String experience;
  final String level;
  final String rating;
  final String matches;
  final String price;
  final String? distance;
  final bool available;
  final VoidCallback? onTap;

  const BookingRefereeCard({
    super.key,
    required this.name,
    required this.sport,
    required this.experience,
    required this.level,
    required this.rating,
    required this.matches,
    required this.price,
    this.distance,
    this.available = true,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final tokens = context.sporto;
    final layout = context.sportoLayout;
    final onSurface = Theme.of(context).colorScheme.onSurface;
    final card = SportoGlassSurface(
      radius: layout.radius16,
      blur: layout.glassBlur,
      color: tokens.card,
      padding: const EdgeInsets.all(10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
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
                    Text(
                      name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: SportoTextStyles.text(
                        size: SportoTextStyles.size15,
                        weight: SportoTextStyles.semiBold,
                        color: onSurface,
                      ),
                    ),
                    SizedBox(height: layout.space2),
                    Row(
                      children: [
                        Text(
                          sport,
                          style: SportoTextStyles.text(
                            size: SportoTextStyles.size12,
                            weight: SportoTextStyles.medium,
                            color: tokens.accentGreen,
                          ),
                        ),
                        const _Dot(),
                        Text(
                          experience,
                          style: SportoTextStyles.text(
                            size: SportoTextStyles.size12,
                            weight: SportoTextStyles.medium,
                            color: tokens.muted,
                          ),
                        ),
                        const _Dot(),
                        Text(
                          level,
                          style: SportoTextStyles.text(
                            size: SportoTextStyles.size12,
                            weight: SportoTextStyles.medium,
                            color: tokens.muted,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: layout.space4),
                    Row(
                      children: [
                        Text(
                          rating,
                          style: SportoTextStyles.text(
                            size: SportoTextStyles.size12,
                            weight: SportoTextStyles.medium,
                            color: tokens.muted,
                          ),
                        ),
                        const _Dot(),
                        Text(
                          matches,
                          style: SportoTextStyles.text(
                            size: SportoTextStyles.size12,
                            weight: SportoTextStyles.medium,
                            color: tokens.muted,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              SizedBox(width: layout.space10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (available)
                    Row(
                      children: [
                        Container(
                          width: 4,
                          height: 4,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: tokens.statusGreen,
                          ),
                        ),
                        SizedBox(width: layout.space4),
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
                  Text(
                    price,
                    style: SportoTextStyles.text(
                      size: SportoTextStyles.size16,
                      weight: SportoTextStyles.semiBold,
                      color: onSurface,
                    ),
                  ),
                  Text(
                    'per match',
                    style: SportoTextStyles.text(
                      size: SportoTextStyles.size12,
                      weight: SportoTextStyles.medium,
                      color: tokens.muted,
                    ),
                  ),
                ],
              ),
            ],
          ),
          if (distance != null) ...[
            SizedBox(height: layout.space10),
            Row(
              children: [
                SportoSvgIcon(SportoRefereeBookingIcons.pinGoldSmall,
                    width: 12, height: 11),
                SizedBox(width: layout.space4),
                Text(
                  distance!,
                  style: SportoTextStyles.text(
                    size: SportoTextStyles.size12,
                    weight: SportoTextStyles.medium,
                    color: tokens.muted,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
    if (onTap == null) return card;
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: card,
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
