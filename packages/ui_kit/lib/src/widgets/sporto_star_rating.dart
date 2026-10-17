import 'package:flutter/material.dart';

import '../assets/sporto_assets.dart';
import '../theme/sporto_design_tokens.dart';

/// Five-star rating row (Figma `Frame 1261154763`): gold stars with the
/// remaining stars tinted `#373435`.
class SportoStarRating extends StatelessWidget {
  final int rating;
  final int total;
  final double starSize;
  final ValueChanged<int>? onChanged;

  const SportoStarRating({
    super.key,
    required this.rating,
    this.total = 5,
    this.starSize = 22,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final tokens = context.sporto;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var i = 1; i <= total; i++)
          Padding(
            padding: const EdgeInsets.only(right: 4),
            child: GestureDetector(
              onTap: onChanged == null ? null : () => onChanged!(i),
              child: SportoSvgIcon(
                SportoRefereeBookingIcons.starGold,
                size: starSize,
                color: i <= rating ? null : tokens.textTertiary,
              ),
            ),
          ),
      ],
    );
  }
}
