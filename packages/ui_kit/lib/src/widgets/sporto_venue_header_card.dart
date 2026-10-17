import 'package:flutter/material.dart';

import '../assets/sporto_assets.dart';
import '../theme/sporto_design_tokens.dart';
import '../theme/sporto_text_styles.dart';
import 'sporto_doc_card.dart';

/// Venue/sport header card (Figma `SIGNATURE: MATCH TICKET` + sport row).
/// Sports glyph + sport name, then pin + venue name + area.
class SportoVenueHeaderCard extends StatelessWidget {
  final String sportName;
  final String venueName;
  final String area;
  final String? sportIconAsset;

  const SportoVenueHeaderCard({
    super.key,
    required this.sportName,
    required this.venueName,
    required this.area,
    this.sportIconAsset = SportoRefereeBookingIcons.sport,
  });

  @override
  Widget build(BuildContext context) {
    final tokens = context.sporto;
    return SportoDocCard(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              SportoSvgIcon(sportIconAsset!, height: 16),
              const SizedBox(width: 8),
              Text(
                sportName,
                style: SportoTextStyles.text(
                  size: SportoTextStyles.size15,
                  weight: SportoTextStyles.semiBold,
                  color: tokens.accentGreen,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SportoSvgIcon(SportoRefereeBookingIcons.pinGreen, width: 11, height: 12),
              const SizedBox(width: 4),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      venueName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: SportoTextStyles.text(
                        size: SportoTextStyles.size16,
                        weight: SportoTextStyles.semiBold,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                    Text(
                      area,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: SportoTextStyles.text(
                        size: SportoTextStyles.size14,
                        weight: SportoTextStyles.medium,
                        color: tokens.muted,
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
