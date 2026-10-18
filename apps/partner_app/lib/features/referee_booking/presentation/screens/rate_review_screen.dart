import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:ui_kit/ui_kit.dart';

/// Package 2 - Rate & Review (Figma 04). Separate screen.
class RateReviewScreen extends StatefulWidget {
  const RateReviewScreen({super.key});

  @override
  State<RateReviewScreen> createState() => _RateReviewScreenState();
}

class _RateReviewScreenState extends State<RateReviewScreen> {
  final Set<String> _tags = {'On Time'};

  static const List<String> _allTags = [
    'On Time',
    'Fair Decisions',
    'Good Communication',
    'Experienced',
  ];

  @override
  Widget build(BuildContext context) {
    final tokens = context.sporto;
    final gap = context.sportoLayout;
    return MediaQuery.withNoTextScaling(
      child: Scaffold(
        backgroundColor: tokens.canvas,
        appBar: SportoBookingAppBar(
          title: 'Rate & Review',
          onBack: () => context.canPop() ? context.pop() : context.go('/'),
        ),
        body: SafeArea(
          top: false,
          child: ListView(
            padding: EdgeInsets.fromLTRB(20, gap.space10, 20, gap.space20),
            children: [
              const _RefereeHeaderCard(),
              SizedBox(height: gap.space20),
              const _RatingCard(),
              SizedBox(height: gap.space20),
              Text(
                'Quick Tags',
                style: SportoTextStyles.text(
                  size: SportoTextStyles.size14,
                  weight: SportoTextStyles.medium,
                  color: tokens.textTertiary,
                ),
              ),
              SizedBox(height: gap.space10),
              Wrap(
                spacing: gap.space10,
                runSpacing: gap.space10,
                children: [
                  for (final tag in _allTags)
                    SportoTagChip(
                      label: tag,
                      selected: _tags.contains(tag),
                      onTap: () => setState(() {
                        if (!_tags.remove(tag)) _tags.add(tag);
                      }),
                    ),
                ],
              ),
              SizedBox(height: gap.space20),
              Text(
                'Written Review (optional)',
                style: SportoTextStyles.text(
                  size: SportoTextStyles.size14,
                  weight: SportoTextStyles.medium,
                  color: tokens.textTertiary,
                ),
              ),
              SizedBox(height: gap.space10),
              const _WrittenReviewField(),
              SizedBox(height: gap.space30),
              _SubmitButton(
                onTap: () => context.go('/bookings/upcoming'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RefereeHeaderCard extends StatelessWidget {
  const _RefereeHeaderCard();

  @override
  Widget build(BuildContext context) {
    final tokens = context.sporto;
    final layout = context.sportoLayout;
    final onSurface = Theme.of(context).colorScheme.onSurface;
    final pink = LinearGradient(
      colors:
          tokens.gradientPink.colors.map((c) => c.withValues(alpha: 0.2)).toList(),
    );
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
                label: 'Completed',
                gradient: SportoStatusPill.green,
                leading: const SportoSvgIcon(
                    SportoRefereeBookingIcons.clockGreen,
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
                    Text(
                      'Vijay Mohan',
                      style: SportoTextStyles.text(
                        size: SportoTextStyles.size16,
                        weight: SportoTextStyles.semiBold,
                        color: onSurface,
                      ),
                    ),
                    Text(
                      'Cricket',
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

class _RatingCard extends StatefulWidget {
  const _RatingCard();

  @override
  State<_RatingCard> createState() => _RatingCardState();
}

class _RatingCardState extends State<_RatingCard> {
  int _rating = 5;

  @override
  Widget build(BuildContext context) {
    final tokens = context.sporto;
    final layout = context.sportoLayout;
    final goldFill = LinearGradient(
      colors:
          tokens.gradientGold.colors.map((c) => c.withValues(alpha: 0.06)).toList(),
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
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'How was Vijay Mohan?',
            style: SportoTextStyles.text(
              size: SportoTextStyles.size12,
              weight: SportoTextStyles.medium,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          SizedBox(height: layout.space10),
          SportoStarRating(
            rating: _rating,
            starSize: 30,
            onChanged: (v) => setState(() => _rating = v),
          ),
        ],
      ),
    );
  }
}

class _WrittenReviewField extends StatelessWidget {
  const _WrittenReviewField();

  @override
  Widget build(BuildContext context) {
    final tokens = context.sporto;
    final layout = context.sportoLayout;
    return Container(
      height: 100,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: tokens.cardElevated,
        borderRadius: BorderRadius.circular(layout.radius16),
      ),
      child: Text(
        'Share more about your experience',
        style: SportoTextStyles.text(
          size: SportoTextStyles.size14,
          weight: SportoTextStyles.medium,
          color: tokens.muted,
        ),
      ),
    );
  }
}

class _SubmitButton extends StatelessWidget {
  final VoidCallback onTap;
  const _SubmitButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    final tokens = context.sporto;
    final layout = context.sportoLayout;
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Center(
        child: SizedBox(
          width: 270,
          height: 48,
          child: SportoGlassSurface(
            radius: layout.radius16,
            gradient: tokens.gradientBlue,
            shadows: layout.buttonShadow(tokens.gradientBlue.colors.first),
            child: Center(
              child: Text(
                'Submit Review',
                style: SportoTextStyles.text(
                  size: SportoTextStyles.size16,
                  weight: SportoTextStyles.bold,
                  color: tokens.canvas,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

