import 'package:flutter/material.dart';
import 'package:partner_data/partner_data.dart';
import 'package:ui_kit/ui_kit.dart';

import '../widgets/redesign/tournament_visuals.dart';

/// Stats tab — Figma `Partner App / Stats` (export 18–28).
///
/// The partner API exposes no player-performance endpoint, so this tab lists
/// the **registered players** that do exist (from registrations) and states
/// plainly that leaderboards are not available yet. The demo batting/bowling
/// tables from the previous pass are gone.
class TournamentStatsTab extends StatelessWidget {
  const TournamentStatsTab({
    super.key,
    this.registrations = const [],
    this.onViewPlayer,
  });

  final List<TournamentRegistration> registrations;
  final void Function(String name, String team)? onViewPlayer;

  @override
  Widget build(BuildContext context) {
    final t = context.sportoTournament;
    final scale = context.sportoScale;
    final players = <(String, String)>[
      for (final team in registrations)
        for (final player in team.players) (player.name, team.name),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(
            horizontal: 16 * scale,
            vertical: 20 * scale,
          ),
          decoration: BoxDecoration(
            color: t.cardAlt,
            borderRadius: BorderRadius.circular(t.r16),
            border: GradientBorder.all(
              gradient: t.whiteBorderGradient,
              width: 1,
              radius: t.r16,
            ),
          ),
          child: Column(
            children: [
              Icon(Icons.leaderboard_outlined, size: 30, color: t.dim),
              SizedBox(height: 10 * scale),
              Text(
                'Leaderboards are not available yet',
                textAlign: TextAlign.center,
                style: SportoTextStyles.text(
                  size: SportoTextStyles.size13,
                  weight: FontWeight.w600,
                  color: t.white,
                ),
              ),
              SizedBox(height: 4 * scale),
              Text(
                'Batting, bowling and MVP tables appear once scorecards are '
                'synced with the partner API.',
                textAlign: TextAlign.center,
                style: SportoTextStyles.text(
                  size: SportoTextStyles.size11,
                  color: t.muted,
                ),
              ),
            ],
          ),
        ),
        if (players.isNotEmpty) ...[
          SizedBox(height: 14 * scale),
          Text(
            'Registered players (${players.length})',
            style: SportoTextStyles.text(
              size: SportoTextStyles.size13,
              weight: FontWeight.w600,
              color: t.white,
            ),
          ),
          SizedBox(height: 8 * scale),
          for (var i = 0; i < players.length; i++) ...[
            TournamentSurface(
              radius: t.r12,
              padding: EdgeInsets.symmetric(
                horizontal: 12 * scale,
                vertical: 10 * scale,
              ),
              color: t.cardAlt,
              borderColor: t.border,
              onTap: onViewPlayer == null
                  ? null
                  : () => onViewPlayer!(players[i].$1, players[i].$2),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          players[i].$1,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: SportoTextStyles.text(
                            size: SportoTextStyles.size13,
                            weight: FontWeight.w600,
                            color: t.white,
                          ),
                        ),
                        Text(
                          players[i].$2,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: SportoTextStyles.text(
                            size: SportoTextStyles.size11,
                            color: t.muted,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SportoSvgIcon(
                    SportoHomeRedesignIcons.arrowRight,
                    width: 12,
                    height: 8,
                    color: t.blue,
                  ),
                ],
              ),
            ),
            if (i != players.length - 1) SizedBox(height: 8 * scale),
          ],
        ],
      ],
    );
  }
}
