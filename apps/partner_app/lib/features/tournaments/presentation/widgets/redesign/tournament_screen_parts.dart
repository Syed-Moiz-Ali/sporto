import 'package:flutter/material.dart';
import 'package:partner_data/partner_data.dart';
import 'package:ui_kit/ui_kit.dart';

import 'tournament_redesign_data.dart';
import 'tournament_visuals.dart';

class TournamentScreenHeader extends StatelessWidget {
  const TournamentScreenHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.onBack,
    this.trailing,
    this.padding = const EdgeInsets.fromLTRB(20, 8, 20, 10),
    this.backgroundColor,
    this.background,
    this.bottomRadius,
    this.minHeight,
    this.rowHeight,
    this.titleSize = SportoTextStyles.size18,
    this.subtitleSize = SportoTextStyles.size12,
    this.backSize = 38,
    this.backBackground,
    this.backGap = 12,
  });

  final String title;
  final String? subtitle;
  final VoidCallback? onBack;
  final Widget? trailing;
  final EdgeInsetsGeometry padding;

  /// Optional header plate used by the tournament list (export: `#0A0E12`
  /// plus a `#6075FF0A → #274D4D0A` wash, rounded 20 at the bottom).
  final Color? backgroundColor;
  final Gradient? background;
  final double? bottomRadius;
  final double? minHeight;

  /// Fixed height of the title row (export: 44).
  final double? rowHeight;

  /// Title / subtitle sizes (prize pool header: 16 / 11).
  final double titleSize;
  final double subtitleSize;

  /// Back button size and background (prize pool: 36 px on 10 % white).
  final double backSize;
  final Color? backBackground;
  final double backGap;

  @override
  Widget build(BuildContext context) {
    final t = context.sportoTournament;
    Widget content = Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        if (onBack != null) ...[
          TournamentIconButton(
            icon: Icon(
              Icons.arrow_back_ios_new_rounded,
              size: backSize * .45,
              color: t.white,
            ),
            onTap: onBack,
            size: backSize,
            radius: t.r10,
            background: backBackground ?? t.cardElevated,
          ),
          SizedBox(width: backGap),
        ],
        Expanded(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: SportoTextStyles.text(
                  size: titleSize,
                  weight: FontWeight.w700,
                  color: t.white,
                ),
              ),
              if (subtitle != null) ...[
                const SizedBox(height: 2),
                Text(
                  subtitle!,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: SportoTextStyles.text(
                    size: subtitleSize,
                    color: t.muted,
                  ),
                ),
              ],
            ],
          ),
        ),
        if (trailing != null) ...[const SizedBox(width: 10), trailing!],
      ],
    );

    if (rowHeight != null) {
      content = ConstrainedBox(
        constraints: BoxConstraints(minHeight: rowHeight!),
        child: content,
      );
    }
    final row = Padding(padding: padding, child: content);

    if (backgroundColor == null && background == null) return row;

    return Container(
      constraints:
          minHeight == null ? null : BoxConstraints(minHeight: minHeight!),
      alignment: Alignment.centerLeft,
      decoration: BoxDecoration(
        color: backgroundColor,
        gradient: background,
        borderRadius: bottomRadius == null
            ? null
            : BorderRadius.vertical(bottom: Radius.circular(bottomRadius!)),
      ),
      child: row,
    );
  }
}

/// Colored status strip under the header: `Completed | Cricket | date`.
class TournamentStatusBar extends StatelessWidget {
  const TournamentStatusBar({
    super.key,
    required this.statusLabel,
    required this.statusColor,
    required this.sport,
    required this.dateText,
    this.live = false,
  });

  final String statusLabel;
  final Color statusColor;
  final String sport;
  final String dateText;
  final bool live;

  @override
  Widget build(BuildContext context) {
    final t = context.sportoTournament;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: live
            ? t.liveCardGradient.colors.first.withValues(alpha: .55)
            : statusColor.withValues(alpha: .06),
        borderRadius: BorderRadius.circular(t.r10),
        border: Border.all(
          color: live
              ? t.live.withValues(alpha: .35)
              : statusColor.withValues(alpha: .35),
        ),
      ),
      child: Row(
        children: [
          TournamentStatusChip(
            label: statusLabel,
            color: statusColor,
            background: statusColor.withValues(alpha: .10),
            border: statusColor.withValues(alpha: .30),
            dot: live,
          ),
          const SizedBox(width: 10),
          Text(
            sport,
            style: SportoTextStyles.text(
              size: SportoTextStyles.size12,
              weight: FontWeight.w600,
              color: t.gold,
            ),
          ),
          const Spacer(),
          Text(
            dateText,
            style: SportoTextStyles.text(
              size: SportoTextStyles.size12,
              color: live ? t.warm : t.muted,
            ),
          ),
        ],
      ),
    );
  }
}

class TournamentBanner extends StatelessWidget {
  const TournamentBanner({
    super.key,
    required this.title,
    required this.message,
    this.color,
  });

  final String title;
  final String message;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final t = context.sportoTournament;
    final c = color ?? t.orange;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: c.withValues(alpha: .08),
        borderRadius: BorderRadius.circular(t.r10),
        border: Border.all(color: c.withValues(alpha: .30)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: SportoTextStyles.text(
              size: SportoTextStyles.size14,
              weight: FontWeight.w600,
              color: c,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            message,
            style: SportoTextStyles.text(
              size: SportoTextStyles.size12,
              color: t.warm,
            ),
          ),
        ],
      ),
    );
  }
}

class TournamentBracketStrip extends StatelessWidget {
  const TournamentBracketStrip({
    super.key,
    this.rounds = const [],
    this.isExpanded = true,
    this.onToggle,
  });

  /// Rounds from `getRounds(id)` (workflow API), ordered by `sequence`.
  final List<TournamentRound> rounds;
  final bool isExpanded;
  final VoidCallback? onToggle;

  @override
  Widget build(BuildContext context) {
    final t = context.sportoTournament;
    final scale = context.sportoScale;
    final ordered = [...rounds]
      ..sort((a, b) => a.sequence.compareTo(b.sequence));
    final visible = ordered.where((r) => r.name.trim().isNotEmpty).toList();
    if (visible.isEmpty) return const SizedBox.shrink();
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(10 * scale),
      decoration: BoxDecoration(
        color: t.green.withValues(alpha: .06),
        borderRadius: BorderRadius.circular(t.r12),
        border: GradientBorder.all(
          gradient: t.greenPillBorderGradient,
          width: 1,
          radius: t.r12,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Tournament Bracket',
                  style: SportoTextStyles.text(
                    size: SportoTextStyles.size12,
                    weight: FontWeight.w500,
                    color: t.green,
                  ),
                ),
              ),
              if (onToggle != null)
                GestureDetector(
                  onTap: onToggle,
                  behavior: HitTestBehavior.opaque,
                  child: Icon(
                    isExpanded
                        ? Icons.keyboard_arrow_up_rounded
                        : Icons.keyboard_arrow_down_rounded,
                    size: 18,
                    color: t.green,
                  ),
                ),
            ],
          ),
          if (isExpanded) ...[
            SizedBox(height: 6 * scale),
            Wrap(
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 6 * scale,
              runSpacing: 4 * scale,
              children: [
                for (var i = 0; i < visible.length; i++) ...[
                  if (i > 0)
                    Text(
                      '›',
                      style: SportoTextStyles.text(
                        size: SportoTextStyles.size12,
                        weight: FontWeight.w700,
                        color: t.gold,
                      ),
                    ),
                  Text(
                    visible[i].name,
                    style: SportoTextStyles.text(
                      size: SportoTextStyles.size12,
                      color: t.white,
                    ),
                  ),
                ],
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class TournamentPlayerProfileHeader extends StatelessWidget {
  const TournamentPlayerProfileHeader({
    super.key,
    required this.name,
    required this.team,
    required this.role,
    required this.playerCode,
    required this.matches,
    required this.mvpPoints,
    required this.wins,
    this.avatarAsset,
  });

  final String name;
  final String team;
  final String role;
  final String playerCode;
  final String matches;
  final String mvpPoints;
  final String wins;
  final String? avatarAsset;

  @override
  Widget build(BuildContext context) {
    final t = context.sportoTournament;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF291228), Color(0xFF160D1C)],
        ),
        borderRadius: BorderRadius.circular(t.r14),
        border: Border.all(color: t.pink.withValues(alpha: .35)),
      ),
      child: Column(
        children: [
          Align(
            alignment: Alignment.topRight,
            child: Text(
              playerCode,
              style: SportoTextStyles.text(
                size: SportoTextStyles.size12,
                color: t.muted,
              ),
            ),
          ),
          Container(
            width: 88,
            height: 100,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(t.r18),
              border:
                  Border.all(color: t.warm.withValues(alpha: .55), width: 2),
              image: avatarAsset == null
                  ? null
                  : DecorationImage(
                      image: AssetImage(avatarAsset!),
                      fit: BoxFit.cover,
                    ),
            ),
            child: avatarAsset == null
                ? Icon(Icons.person_rounded, size: 46, color: t.muted)
                : null,
          ),
          const SizedBox(height: 10),
          Text(
            name,
            textAlign: TextAlign.center,
            style: SportoTextStyles.text(
              size: SportoTextStyles.size20,
              weight: FontWeight.w700,
              color: t.white,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            team,
            style: SportoTextStyles.text(
              size: SportoTextStyles.size15,
              color: t.blue,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            role,
            style: SportoTextStyles.text(
              size: SportoTextStyles.size12,
              color: t.muted,
            ),
          ),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(
              color: t.screenBase.withValues(alpha: .35),
              borderRadius: BorderRadius.circular(t.r11),
              border: Border.all(color: t.border),
            ),
            child: Row(
              children: [
                _profileStat(context, matches, 'Matches'),
                Container(width: 1, height: 28, color: t.border),
                _profileStat(context, mvpPoints, 'MVP pts', color: t.gold),
                Container(width: 1, height: 28, color: t.border),
                _profileStat(context, wins, 'Wins', color: t.green),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _profileStat(
    BuildContext context,
    String value,
    String label, {
    Color? color,
  }) {
    final t = context.sportoTournament;
    return Expanded(
      child: Column(
        children: [
          Text(
            value,
            style: SportoTextStyles.text(
              size: SportoTextStyles.size16,
              weight: FontWeight.w700,
              color: color ?? t.white,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: SportoTextStyles.text(
              size: SportoTextStyles.size11,
              color: t.muted,
            ),
          ),
        ],
      ),
    );
  }
}

class TournamentInningsRow extends StatelessWidget {
  const TournamentInningsRow({
    super.key,
    required this.opponent,
    required this.round,
    required this.runs,
    required this.fours,
    required this.sixes,
  });

  final String opponent;
  final String round;
  final String runs;
  final String fours;
  final String sixes;

  @override
  Widget build(BuildContext context) {
    final t = context.sportoTournament;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: t.cardAlt,
        borderRadius: BorderRadius.circular(t.r9),
        border: Border.all(color: t.border),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(
                        text: 'vs ',
                        style: SportoTextStyles.text(
                          size: SportoTextStyles.size13,
                          color: t.muted,
                        ),
                      ),
                      TextSpan(
                        text: opponent,
                        style: SportoTextStyles.text(
                          size: SportoTextStyles.size13,
                          color: t.blue,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  round,
                  style: SportoTextStyles.text(
                    size: SportoTextStyles.size11,
                    color: t.dim,
                  ),
                ),
              ],
            ),
          ),
          Text(
            runs,
            style: SportoTextStyles.text(
              size: SportoTextStyles.size13,
              color: t.warm,
            ),
          ),
          const SizedBox(width: 18),
          Text(
            fours,
            style: SportoTextStyles.text(
              size: SportoTextStyles.size13,
              color: t.gold,
            ),
          ),
          const SizedBox(width: 18),
          Text(
            sixes,
            style: SportoTextStyles.text(
              size: SportoTextStyles.size13,
              color: t.pink,
            ),
          ),
        ],
      ),
    );
  }
}

/// Status strip shared by the tournament detail and prize-pool screens
/// (export 06/07/03): tinted band, gradient badge, sport, date.
class TournamentStatusStrip extends StatelessWidget {
  const TournamentStatusStrip({
    super.key,
    required this.tournament,
    this.dateText,
  });

  final PartnerTournamentResponse tournament;
  final String? dateText;

  @override
  Widget build(BuildContext context) {
    final t = context.sportoTournament;
    final scale = context.sportoScale;
    final gradient = tournamentStatusGradient(t, tournament);
    final statusColor = tournamentStatusColor(tournament, t);
    return Container(
      constraints: BoxConstraints(minHeight: 43 * scale),
      padding: EdgeInsets.symmetric(horizontal: 12 * scale),
      decoration: BoxDecoration(
        gradient: washGradient(gradient, .05),
        borderRadius: BorderRadius.circular(t.r14),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Row(
              children: [
                Flexible(
                  fit: FlexFit.loose,
                  child: TournamentStatusChip(
                    label: tournamentStatusLabel(tournament),
                    color: statusColor,
                    gradient: washGradient(gradient, .06),
                    borderGradient: gradient,
                    textGradient: gradient,
                    height: 23 * scale,
                    fontSize: SportoTextStyles.size12,
                  ),
                ),
                SizedBox(width: 6 * scale),
                Flexible(
                  child: Text(
                    tournamentSportLabel(tournament),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: SportoTextStyles.text(
                      size: SportoTextStyles.size12,
                      weight: FontWeight.w600,
                      color: statusColor,
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: 8 * scale),
          Flexible(
            flex: 2,
            child: Text(
              dateText ?? formatTournamentDay(tournament.tournamentStartAt),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.right,
              style: SportoTextStyles.text(
                size: SportoTextStyles.size12,
                weight: FontWeight.w500,
                color: t.muted,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Low-alpha version of a gradient (status bands and badge fills).
Gradient washGradient(Gradient gradient, double alpha) {
  if (gradient is LinearGradient) {
    return LinearGradient(
      begin: gradient.begin,
      end: gradient.end,
      stops: gradient.stops,
      colors: [for (final c in gradient.colors) c.withValues(alpha: alpha)],
    );
  }
  return gradient;
}

/// Tournament identity card (export 03/07): name, venue, optional sponsor.
/// Pink/blue wash over the card fill, vertical blue hairline.
class TournamentIdentityCard extends StatelessWidget {
  const TournamentIdentityCard({
    super.key,
    required this.tournament,
    this.showSponsor = false,
    this.onTap,
  });

  final PartnerTournamentResponse tournament;
  final bool showSponsor;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final t = context.sportoTournament;
    final scale = context.sportoScale;
    final sponsor = showSponsor && tournament.tournamentSponsors.isNotEmpty
        ? tournament.tournamentSponsors.first.name
        : null;
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        width: double.infinity,
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: t.cardAlt.withValues(alpha: .20),
          borderRadius: BorderRadius.circular(t.r14),
          border: GradientBorder.all(
            gradient: t.blueEdgeGradient,
            width: 1,
            radius: t.r14,
          ),
        ),
        child: Stack(
          children: [
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      t.pink.withValues(alpha: .004),
                      t.pink.withValues(alpha: .03),
                      t.pink.withValues(alpha: .004),
                    ],
                    stops: const [0, .52, 1],
                  ),
                ),
              ),
            ),
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      t.blueBright.withValues(alpha: .006),
                      t.blueBright.withValues(alpha: .03),
                      t.blueBright.withValues(alpha: .006),
                    ],
                    stops: const [0, .52, 1],
                  ),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(12 * scale),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    tournament.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: SportoTextStyles.text(
                      size: SportoTextStyles.size16,
                      weight: FontWeight.w600,
                      color: t.white,
                    ),
                  ),
                  SizedBox(height: 4 * scale),
                  Row(
                    children: [
                      SportoSvgIcon(
                        SportoTournamentIcons.mapPin,
                        width: 11,
                        height: 12,
                        color: t.green,
                      ),
                      SizedBox(width: 4 * scale),
                      Expanded(
                        child: Text(
                          tournamentVenueLabel(tournament),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: SportoTextStyles.text(
                            size: SportoTextStyles.size12,
                            weight: FontWeight.w500,
                            color: t.green,
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (sponsor != null) ...[
                    SizedBox(height: 8 * scale),
                    TournamentDivider(
                      height: .8,
                      gradient: LinearGradient(
                        colors: [
                          t.dim.withValues(alpha: 0),
                          t.dim.withValues(alpha: .3),
                          t.dim.withValues(alpha: 0),
                        ],
                        stops: const [0, .5, 1],
                      ),
                    ),
                    SizedBox(height: 6 * scale),
                    Text(
                      'Sponsor by: $sponsor',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: SportoTextStyles.text(
                        size: SportoTextStyles.size12,
                        weight: FontWeight.w500,
                        color: t.warm,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
