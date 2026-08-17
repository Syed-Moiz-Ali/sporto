import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:ui_kit/ui_kit.dart';

import '../../../../app/router/app_router.dart';
import '../../application/match_scoring_bloc.dart';

class RefereeHomeScreen extends StatefulWidget {
  final VoidCallback? onViewAll;

  const RefereeHomeScreen({
    super.key,
    this.onViewAll,
  });

  @override
  State<RefereeHomeScreen> createState() => _RefereeHomeScreenState();
}

class _RefereeHomeScreenState extends State<RefereeHomeScreen> {
  @override
  void initState() {
    super.initState();

    context.read<MatchScoringBloc>().add(
          LoadMatchesEvent(),
        );
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<MatchScoringBloc>().state;

    final hasMatches =
        state is MatchScoringListLoadedState && state.matches.isNotEmpty;

    return SafeArea(
      bottom: false,
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(20, 17, 20, 22),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const _HomeHeader(),
            const SizedBox(height: 15),
            const _HomeSearchBar(),
            const SizedBox(height: 24),
            _MatchOverview(hasMatches: hasMatches),
            const SizedBox(height: 24),
            if (hasMatches)
              _LoadedHomeContent(onViewAll: widget.onViewAll)
            else
              const _EmptyHomeContent(),
            const SizedBox(height: 21),
            const _AdsBanner(),
          ],
        ),
      ),
    );
  }
}

// ============================================================
// HEADER
// ============================================================

class _HomeHeader extends StatelessWidget {
  const _HomeHeader();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Good Evening',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colors.primary,
                  fontSize: 13,
                  height: 1.15,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                'Priya Agrawal',
                style: theme.textTheme.titleLarge?.copyWith(
                  color: colors.onSurface,
                  fontSize: 17,
                  height: 1.15,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        const _WalletBalance(),
        const SizedBox(width: 12),
        Icon(
          Icons.notifications_none_rounded,
          color: colors.onSurface,
          size: 24,
        ),
      ],
    );
  }
}

class _WalletBalance extends StatelessWidget {
  const _WalletBalance();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return ClipRRect(
      borderRadius: BorderRadius.circular(6),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            height: 24,
            padding: const EdgeInsets.symmetric(
              horizontal: 9,
            ),
            alignment: Alignment.center,
            color: const Color(0xFF252B38),
            child: Text(
              '₹ 500',
              style: theme.textTheme.titleMedium?.copyWith(
                color: colors.onSurface,
                fontSize: 16,
                height: 1,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Container(
            width: 25,
            height: 24,
            alignment: Alignment.center,
            color: colors.tertiary,
            child: const Icon(
              Icons.add_rounded,
              size: 20,
              color: Color(0xFF252119),
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// SEARCH
// ============================================================

class _HomeSearchBar extends StatelessWidget {
  const _HomeSearchBar();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Container(
      height: 50,
      decoration: BoxDecoration(
        color: const Color(0xFF202633),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: const Color(0xFF2C3445),
        ),
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: 13,
      ),
      child: Row(
        children: [
          SizedBox(
            width: 27,
            height: 27,
            child: Stack(
              children: [
                Positioned(
                  left: 0,
                  top: 2,
                  child: SportoAssetIcon(
                    SportoAssets.searchNormal,
                    color: colors.onSurfaceVariant,
                    size: 22,
                  ),
                ),
                Positioned(
                  right: 0,
                  bottom: 2,
                  child: Container(
                    width: 3,
                    height: 3,
                    decoration: BoxDecoration(
                      color: colors.tertiary,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 13),
          Expanded(
            child: Text(
              'Search cricket, football..',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colors.onSurfaceVariant,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Container(
            width: 1,
            height: 29,
            color: const Color(0xFF303746),
          ),
          const SizedBox(width: 12),
          SizedBox(
            width: 22,
            height: 27,
            child: Stack(
              alignment: Alignment.center,
              children: [
                SportoAssetIcon(
                  SportoAssets.mic,
                  color: colors.onSurfaceVariant,
                  size: 24,
                ),
                Positioned(
                  bottom: 0,
                  child: Container(
                    width: 13,
                    height: 2,
                    decoration: BoxDecoration(
                      color: colors.tertiary,
                      borderRadius: BorderRadius.circular(2),
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
}

// ============================================================
// OVERVIEW
// ============================================================

class _MatchOverview extends StatelessWidget {
  final bool hasMatches;

  const _MatchOverview({
    required this.hasMatches,
  });

  @override
  Widget build(BuildContext context) {
    final sporto = context.sporto;

    return Column(
      children: [
        SizedBox(
          height: 66,
          child: Row(
            children: [
              Expanded(
                child: _StatCard(
                  value: hasMatches ? '1' : '0',
                  label: 'Live Now',
                  color: sporto.live,
                  hasValue: hasMatches,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _StatCard(
                  value: hasMatches ? '4' : '0',
                  label: 'Upcoming',
                  color: sporto.upcoming,
                  hasValue: hasMatches,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _StatCard(
                  value: hasMatches ? '6' : '0',
                  label: 'Assigned',
                  color: sporto.assigned,
                  hasValue: hasMatches,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Container(
          height: 35,
          decoration: BoxDecoration(
            color: const Color(0xFF161B24),
            borderRadius: BorderRadius.circular(11),
            border: Border.all(
              color: const Color(0xFF2F4256),
            ),
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: 13,
          ),
          child: Row(
            children: [
              Expanded(
                child: _SecondaryStat(
                  label: 'Completed',
                  value: hasMatches ? '1' : '0',
                ),
              ),
              Expanded(
                child: _SecondaryStat(
                  label: 'Cancelled',
                  value: '0',
                  right: true,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final String value;
  final String label;
  final Color color;
  final bool hasValue;

  const _StatCard({
    required this.value,
    required this.label,
    required this.color,
    required this.hasValue,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF151B29),
        borderRadius: BorderRadius.circular(11),
        border: Border.all(
          color: color.withValues(
            alpha: hasValue ? .35 : .20,
          ),
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            value,
            style: theme.textTheme.titleLarge?.copyWith(
              color: hasValue
                  ? colors.onSurface
                  : colors.onSurfaceVariant.withValues(alpha: .70),
              fontSize: 22,
              height: 1,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 7),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 6,
                height: 6,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 4),
              Text(
                label,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colors.onSurfaceVariant,
                  fontSize: 11,
                  height: 1,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SecondaryStat extends StatelessWidget {
  final String label;
  final String value;
  final bool right;

  const _SecondaryStat({
    required this.label,
    required this.value,
    this.right = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Align(
      alignment: right ? Alignment.centerRight : Alignment.centerLeft,
      child: RichText(
        text: TextSpan(
          style: theme.textTheme.bodySmall?.copyWith(
            color: colors.onSurfaceVariant,
            fontSize: 12,
          ),
          children: [
            TextSpan(
              text: '$label ',
            ),
            TextSpan(
              text: value,
              style: TextStyle(
                color: colors.onSurfaceVariant,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================
// EMPTY STATE
// ============================================================

class _EmptyHomeContent extends StatelessWidget {
  const _EmptyHomeContent();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Container(
      width: double.infinity,
      height: 314,
      padding: const EdgeInsets.fromLTRB(
        20,
        30,
        20,
        18,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFF1C2026),
        borderRadius: BorderRadius.circular(36),
      ),
      child: Column(
        children: [
          Container(
            width: 140,
            height: 120,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF372D2E),
                  Color(0xFF332526),
                ],
              ),
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          const SizedBox(height: 21),
          Text(
            'No Assigned Matches',
            style: theme.textTheme.titleMedium?.copyWith(
              color: colors.onSurface,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Enjoy your day!',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: context.sporto.assigned,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          const Spacer(),
          Divider(
            height: 1,
            thickness: 1,
            color: colors.outline.withValues(alpha: .35),
          ),
          const SizedBox(height: 20),
          Text(
            'We\'ll notify you when new matches are\nassigned.',
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colors.onSurfaceVariant,
              fontSize: 13,
              height: 1.3,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// LOADED CONTENT
// ============================================================

class _LoadedHomeContent extends StatelessWidget {
  final VoidCallback? onViewAll;

  const _LoadedHomeContent({
    required this.onViewAll,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionHeader(
          title: 'Live Now',
          color: context.sporto.live,
        ),
        const SizedBox(height: 9),
        const _LiveMatchCard(),
        const SizedBox(height: 21),
        _SectionHeader(
          title: 'Next Match',
          color: context.sporto.upcoming,
          showArrow: true,
        ),
        const SizedBox(height: 10),
        const _UpcomingHomeCard(
          date: 'Today, 08:00 PM',
          leftTeam: 'Thunder Titans',
          rightTeam: 'Royal Smashers',
          showCountdown: true,
        ),
        const SizedBox(height: 25),
        _SectionHeader(
          title: 'Assigned Matches (3)',
          color: context.sporto.assigned,
          action: 'View All  →',
          onAction: onViewAll,
        ),
        const SizedBox(height: 10),
        const _UpcomingHomeCard(
          date: 'Tomorrow, 06:30 PM',
          leftTeam: 'Delhi Warriors',
          rightTeam: 'Hyd Highlanders',
        ),
      ],
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final Color color;
  final bool showArrow;
  final String? action;
  final VoidCallback? onAction;

  const _SectionHeader({
    required this.title,
    required this.color,
    this.showArrow = false,
    this.action,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return SizedBox(
      height: 20,
      child: Row(
        children: [
          Container(
            width: 11,
            height: 11,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: color.withValues(alpha: .45),
                  blurRadius: 8,
                ),
              ],
            ),
          ),
          const SizedBox(width: 7),
          Expanded(
            child: Text(
              title,
              style: theme.textTheme.titleMedium?.copyWith(
                color: color,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          if (action != null)
            GestureDetector(
              onTap: onAction,
              child: Text(
                action!,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: colors.onSurfaceVariant,
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                ),
              ),
            )
          else if (showArrow)
            Icon(
              Icons.arrow_forward_rounded,
              color: colors.onSurfaceVariant,
              size: 18,
            ),
        ],
      ),
    );
  }
}

// ============================================================
// LIVE MATCH
// ============================================================

class _LiveMatchCard extends StatelessWidget {
  const _LiveMatchCard();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final sporto = context.sporto;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [
            sporto.liveCardStart,
            const Color(0xFF713313),
          ],
        ),
        borderRadius: BorderRadius.circular(17),
        border: Border.all(
          color: const Color(0xFF98400D),
          width: 1,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x283B1B06),
            blurRadius: 18,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Jaipur Super Over',
            style: theme.textTheme.titleMedium?.copyWith(
              color: colors.tertiary,
              fontSize: 15,
              height: 1.15,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 9),
          const _TeamVsRow(
            leftTeam: 'Thunder Titans',
            leftScore: '28/1',
            rightTeam: 'Royal Strikers',
            rightScore: 'Waiting to Bat',
          ),
          const SizedBox(height: 9),
          const _DottedDivider(),
          const SizedBox(height: 9),
          const Row(
            children: [
              Expanded(
                child: _InlineMetric(
                  label: 'Current Batter',
                  value: 'Rahul',
                ),
              ),
              Expanded(
                child: _InlineMetric(
                  label: 'Current Bowler',
                  value: 'Amit',
                  right: true,
                ),
              ),
            ],
          ),
          const SizedBox(height: 9),
          const _DottedDivider(),
          const SizedBox(height: 9),
          Row(
            children: [
              Text(
                'Over - 2.1/6',
                style: theme.textTheme.titleMedium?.copyWith(
                  color: colors.onSurface,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              SizedBox(
                height: 31,
                child: FilledButton(
                  onPressed: () {
                    context.push(
                      AppRouter.liveScoringRoute,
                    );
                  },
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFFFF4B00),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 13,
                    ),
                    minimumSize: Size.zero,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(11),
                    ),
                  ),
                  child: const Text(
                    'Continue Scoring',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ============================================================
// UPCOMING CARD
// ============================================================

class _UpcomingHomeCard extends StatelessWidget {
  final String date;
  final String leftTeam;
  final String rightTeam;
  final bool showCountdown;

  const _UpcomingHomeCard({
    required this.date,
    required this.leftTeam,
    required this.rightTeam,
    this.showCountdown = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0xFF1C2026),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _StatusChip(
                text: 'Upcoming',
                color: context.sporto.upcoming,
              ),
              const Spacer(),
              Text(
                date,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colors.onSurfaceVariant,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 9),
          Text(
            'Asia Cup 2026',
            style: theme.textTheme.titleMedium?.copyWith(
              color: colors.onSurface,
              fontSize: 16,
              height: 1.1,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 2),
          Row(
            children: [
              SportoAssetIcon(
                SportoAssets.locationPin,
                color: colors.onSurfaceVariant,
                size: 14,
              ),
              const SizedBox(width: 2),
              Text(
                'Hyderabad',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colors.onSurfaceVariant,
                  fontSize: 11,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          _TeamVsRow(
            leftTeam: leftTeam,
            rightTeam: rightTeam,
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              if (showCountdown)
                Expanded(
                  child: RichText(
                    text: TextSpan(
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: colors.onSurface,
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                      ),
                      children: [
                        const TextSpan(
                          text: 'Starts in ',
                        ),
                        TextSpan(
                          text: '00:28:35',
                          style: TextStyle(
                            color: context.sporto.assigned,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              else
                const Spacer(),
              SizedBox(
                height: 31,
                child: FilledButton(
                  onPressed: () {
                    context.push(
                      AppRouter.matchVerificationRoute,
                    );
                  },
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                    ),
                    minimumSize: Size.zero,
                    backgroundColor: context.sporto.info,
                    foregroundColor: const Color(0xFF082234),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text(
                    'Verify Teams',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ============================================================
// REUSABLE LOCAL ELEMENTS
// ============================================================

class _StatusChip extends StatelessWidget {
  final String text;
  final Color color;

  const _StatusChip({
    required this.text,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 7,
        vertical: 3,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: .13),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        text,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: color,
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
      ),
    );
  }
}

class _TeamVsRow extends StatelessWidget {
  final String leftTeam;
  final String? leftScore;

  final String rightTeam;
  final String? rightScore;

  const _TeamVsRow({
    required this.leftTeam,
    this.leftScore,
    required this.rightTeam,
    this.rightScore,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Row(
      children: [
        Expanded(
          child: _Team(
            name: leftTeam,
            score: leftScore,
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 8,
          ),
          child: Text(
            'Vs',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: colors.onSurfaceVariant,
                  fontSize: 12,
                ),
          ),
        ),
        Expanded(
          child: _Team(
            name: rightTeam,
            score: rightScore,
            right: true,
          ),
        ),
      ],
    );
  }
}

class _Team extends StatelessWidget {
  final String name;
  final String? score;
  final bool right;

  const _Team({
    required this.name,
    this.score,
    this.right = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Column(
      crossAxisAlignment:
          right ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        Text(
          name,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          textAlign: right ? TextAlign.right : TextAlign.left,
          style: theme.textTheme.titleMedium?.copyWith(
            color: colors.onSurface,
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
        if (score != null) ...[
          const SizedBox(height: 2),
          Text(
            score!,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: right ? TextAlign.right : TextAlign.left,
            style: theme.textTheme.titleMedium?.copyWith(
              color: colors.onSurface,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ],
    );
  }
}

class _InlineMetric extends StatelessWidget {
  final String label;
  final String value;
  final bool right;

  const _InlineMetric({
    required this.label,
    required this.value,
    this.right = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return RichText(
      textAlign: right ? TextAlign.right : TextAlign.left,
      text: TextSpan(
        style: theme.textTheme.bodySmall?.copyWith(
          color: colors.onSurfaceVariant,
          fontSize: 12,
        ),
        children: [
          TextSpan(
            text: '$label ',
          ),
          TextSpan(
            text: value,
            style: TextStyle(
              color: colors.onSurface,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _DottedDivider extends StatelessWidget {
  const _DottedDivider();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 1,
      width: double.infinity,
      child: CustomPaint(
        painter: _DottedDividerPainter(
          Theme.of(context).colorScheme.onSurfaceVariant.withValues(alpha: .25),
        ),
      ),
    );
  }
}

class _DottedDividerPainter extends CustomPainter {
  final Color color;

  const _DottedDividerPainter(
    this.color,
  );

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1;

    for (double x = 0; x < size.width; x += 6) {
      canvas.drawLine(
        Offset(x, 0),
        Offset(
          (x + 2).clamp(0, size.width).toDouble(),
          0,
        ),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(
    covariant _DottedDividerPainter oldDelegate,
  ) {
    return oldDelegate.color != color;
  }
}

// ============================================================
// ADS
// ============================================================

class _AdsBanner extends StatelessWidget {
  const _AdsBanner();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Container(
      width: double.infinity,
      height: 60,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [
            colors.primary,
            colors.tertiary,
          ],
        ),
        borderRadius: BorderRadius.circular(18),
      ),
      padding: const EdgeInsets.fromLTRB(
        20,
        0,
        12,
        0,
      ),
      child: Row(
        children: [
          Text(
            'Ads Banner',
            style: theme.textTheme.titleLarge?.copyWith(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const Spacer(),
          Container(
            width: 38,
            height: 38,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: .12),
              borderRadius: BorderRadius.circular(11),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x22000000),
                  blurRadius: 4,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: const Icon(
              Icons.arrow_forward_ios_rounded,
              color: Colors.white,
              size: 18,
            ),
          ),
        ],
      ),
    );
  }
}
