import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:ui_kit/ui_kit.dart';

import '../widgets/redesign/tournament_cards.dart';
import '../widgets/redesign/tournament_screen_parts.dart';
import '../widgets/redesign/tournament_visuals.dart';

/// Player details — Figma `Partner App / Player Details` (export 19).
///
/// Identity comes from the real registration roster; performance blocks need a
/// stats endpoint the partner API does not expose yet, so they are stated as
/// unavailable instead of hard-coded numbers.
class PlayerDetailsRedesignScreen extends StatelessWidget {
  const PlayerDetailsRedesignScreen({
    super.key,
    required this.playerName,
    required this.teamName,
    required this.tournamentName,
    this.tournamentCode,
  });

  final String playerName;
  final String teamName;
  final String tournamentName;
  final String? tournamentCode;

  @override
  Widget build(BuildContext context) {
    final t = context.sportoTournament;
    final scale = context.sportoScale;
    return Scaffold(
      backgroundColor: t.screenBase,
      body: Column(
        children: [
          TournamentScreenHeader(
            title: playerName,
            subtitle: tournamentCode == null
                ? tournamentName
                : '$tournamentCode · $tournamentName',
            titleSize: SportoTextStyles.size16,
            subtitleSize: SportoTextStyles.size11,
            backSize: 36 * scale,
            backGap: 10 * scale,
            backBackground: t.white.withValues(alpha: .10),
            padding: EdgeInsets.fromLTRB(
              20 * scale,
              MediaQuery.of(context).padding.top,
              20 * scale,
              6 * scale,
            ),
            rowHeight: 44 * scale,
            onBack: () => context.pop(),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(
                20 * scale,
                16 * scale,
                20 * scale,
                28 * scale,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      TournamentAvatar(
                        label: _initials(playerName),
                        size: 56 * scale,
                        radius: t.r14,
                        color: t.greenDeep,
                        background: t.greenDeep.withValues(alpha: .10),
                        fontSize: SportoTextStyles.size20,
                        showBorder: false,
                      ),
                      SizedBox(width: 12 * scale),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              playerName,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: SportoTextStyles.text(
                                size: SportoTextStyles.size20,
                                weight: FontWeight.w800,
                                color: t.white,
                              ),
                            ),
                            SizedBox(height: 2 * scale),
                            Text(
                              teamName,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: SportoTextStyles.text(
                                size: SportoTextStyles.size14,
                                weight: FontWeight.w600,
                                color: t.gold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16 * scale),
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.symmetric(
                      horizontal: 16 * scale,
                      vertical: 24 * scale,
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
                        Icon(Icons.insights_outlined, size: 30, color: t.dim),
                        SizedBox(height: 10 * scale),
                        Text(
                          'Player statistics are not available yet',
                          textAlign: TextAlign.center,
                          style: SportoTextStyles.text(
                            size: SportoTextStyles.size13,
                            weight: FontWeight.w600,
                            color: t.white,
                          ),
                        ),
                        SizedBox(height: 4 * scale),
                        Text(
                          'Batting, bowling and fielding figures appear once '
                          'this player has a synced scorecard.',
                          textAlign: TextAlign.center,
                          style: SportoTextStyles.text(
                            size: SportoTextStyles.size11,
                            color: t.muted,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  static String _initials(String name) {
    final words =
        name.trim().split(RegExp(r'\s+')).where((w) => w.isNotEmpty).toList();
    if (words.length >= 2) {
      return (words[0][0] + words[1][0]).toUpperCase();
    }
    return name.isEmpty ? '--' : name.substring(0, 1).toUpperCase();
  }
}
