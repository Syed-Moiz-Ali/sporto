import 'package:flutter/material.dart';
import 'package:ui_kit/ui_kit.dart';

import 'tournament_visuals.dart';

class TournamentScreenHeader extends StatelessWidget {
  const TournamentScreenHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.onBack,
    this.trailing,
    this.padding = const EdgeInsets.fromLTRB(20, 8, 20, 10),
  });

  final String title;
  final String? subtitle;
  final VoidCallback? onBack;
  final Widget? trailing;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    final t = context.sportoTournament;
    return Padding(
      padding: padding,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (onBack != null) ...[
            TournamentIconButton(
              icon: Icon(Icons.arrow_back_ios_new_rounded,
                  size: 17, color: t.white),
              onTap: onBack,
              size: 38,
              radius: t.r11,
              background: t.cardElevated,
            ),
            const SizedBox(width: 12),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: SportoTextStyles.text(
                    size: SportoTextStyles.size18,
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
                      size: SportoTextStyles.size12,
                      color: t.muted,
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (trailing != null) ...[const SizedBox(width: 10), trailing!],
        ],
      ),
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
    required this.isExpanded,
    this.onToggle,
    this.teams = '64 Teams',
  });

  final bool isExpanded;
  final VoidCallback? onToggle;
  final String teams;

  @override
  Widget build(BuildContext context) {
    final t = context.sportoTournament;
    final stages = [
      teams,
      '32 Teams',
      '16 Teams',
      'Quarter Finals',
      'Semi Finals',
      'Final'
    ];
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        gradient: t.bracketPanelGradient,
        borderRadius: BorderRadius.circular(t.r9),
        border: Border.all(color: t.green.withValues(alpha: .35)),
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
                    color: t.green,
                  ),
                ),
              ),
              if (onToggle != null)
                GestureDetector(
                  onTap: onToggle,
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
          const SizedBox(height: 8),
          Text.rich(
            TextSpan(
              children: [
                for (var i = 0; i < stages.length; i++) ...[
                  TextSpan(
                    text: stages[i],
                    style: SportoTextStyles.text(
                      size: SportoTextStyles.size12,
                      weight: FontWeight.w600,
                      color: t.warm,
                    ),
                  ),
                  if (i != stages.length - 1)
                    TextSpan(
                      text: '  →  ',
                      style: SportoTextStyles.text(
                        size: SportoTextStyles.size12,
                        color: t.gold,
                      ),
                    ),
                ],
              ],
            ),
          ),
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
