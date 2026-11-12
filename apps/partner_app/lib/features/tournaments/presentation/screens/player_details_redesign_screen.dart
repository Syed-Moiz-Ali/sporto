import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:ui_kit/ui_kit.dart';

import '../widgets/redesign/tournament_redesign_data.dart';
import '../widgets/redesign/tournament_screen_parts.dart';

class PlayerDetailsRedesignScreen extends StatelessWidget {
  const PlayerDetailsRedesignScreen({
    super.key,
    required this.playerName,
    required this.teamName,
    required this.tournamentName,
  });

  final String playerName;
  final String teamName;
  final String tournamentName;

  @override
  Widget build(BuildContext context) {
    final t = context.sportoTournament;
    return Scaffold(
      backgroundColor: t.screenBase,
      body: SafeArea(
        child: Column(
          children: [
            TournamentScreenHeader(
              title: playerName,
              subtitle: 'TA-2026-0104 · $tournamentName',
              onBack: () => context.pop(),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 2, 20, 28),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TournamentPlayerProfileHeader(
                      name: playerName,
                      team: teamName,
                      role: 'Captain · Batter',
                      playerCode: '#P-0101',
                      matches: '6',
                      mvpPoints: '204',
                      wins: '6',
                      avatarAsset: 'assets/images/tournament_player.jpg',
                    ),
                    const SizedBox(height: 18),
                    _sectionTitle(context, 'Batting'),
                    const SizedBox(height: 10),
                    _statGrid(context, [
                      ('6', 'Innings', null),
                      ('77', 'Runs', null),
                      ('58', 'Balls Faced', null),
                      ('132.76', 'Strike Rate', t.green),
                      ('23', 'Highest Score', t.gold),
                      ('5/4', 'Fours/Sixes', t.pink),
                    ]),
                    const SizedBox(height: 18),
                    _sectionTitle(context, 'Bowling & Fielding'),
                    const SizedBox(height: 10),
                    _statGrid(context, [
                      ('2', 'Overs', null),
                      ('2', 'Wickets', t.live),
                      ('8', 'Runs Conceded', null),
                      ('4.0', 'Economy', null),
                      ('2/8', 'Best Figures', t.green),
                      ('8', 'Dot Balls', t.blue),
                    ]),
                    const SizedBox(height: 10),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: t.cardAlt,
                        borderRadius: BorderRadius.circular(t.r9),
                        border: Border.all(color: t.border),
                      ),
                      child: Text.rich(
                        TextSpan(
                          children: [
                            TextSpan(
                              text: 'Catches / Run-outs  ',
                              style: SportoTextStyles.text(
                                size: SportoTextStyles.size13,
                                color: t.muted,
                              ),
                            ),
                            TextSpan(
                              text: '2/1',
                              style: SportoTextStyles.text(
                                size: SportoTextStyles.size14,
                                weight: FontWeight.w600,
                                color: t.pink,
                              ),
                            ),
                          ],
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(height: 18),
                    Row(
                      children: [
                        Expanded(child: _sectionTitle(context, 'Innings Log')),
                        Text(
                          'R&B   4s   6s',
                          style: SportoTextStyles.text(
                            size: SportoTextStyles.size11,
                            color: t.muted,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Batting',
                      style: SportoTextStyles.text(
                        size: SportoTextStyles.size13,
                        color: t.muted,
                      ),
                    ),
                    const SizedBox(height: 10),
                    for (var i = 0; i < demoInnings.length; i++) ...[
                      TournamentInningsRow(
                        opponent: demoInnings[i].opponent,
                        round: demoInnings[i].round,
                        runs: demoInnings[i].runs,
                        fours: demoInnings[i].fours,
                        sixes: demoInnings[i].sixes,
                      ),
                      if (i != demoInnings.length - 1)
                        const SizedBox(height: 8),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionTitle(BuildContext context, String label) {
    final t = context.sportoTournament;
    return Text(
      label,
      style: SportoTextStyles.text(
        size: SportoTextStyles.size16,
        color: t.muted,
      ),
    );
  }

  Widget _statGrid(
    BuildContext context,
    List<(String, String, Color?)> entries,
  ) {
    final t = context.sportoTournament;
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 4),
      decoration: BoxDecoration(
        color: t.card,
        borderRadius: BorderRadius.circular(t.r11),
        border: Border.all(color: t.border),
      ),
      child: Column(
        children: [
          for (var row = 0; row < entries.length; row += 3)
            Row(
              children: [
                for (var i = row; i < row + 3 && i < entries.length; i++)
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        border: Border(
                          left: i == row
                              ? BorderSide.none
                              : BorderSide(color: t.border),
                          bottom: row + 3 < entries.length
                              ? BorderSide(color: t.border)
                              : BorderSide.none,
                        ),
                      ),
                      child: Column(
                        children: [
                          Text(
                            entries[i].$1,
                            style: SportoTextStyles.text(
                              size: SportoTextStyles.size16,
                              weight: FontWeight.w600,
                              color: entries[i].$3 ?? t.white,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            entries[i].$2,
                            style: SportoTextStyles.text(
                              size: SportoTextStyles.size11,
                              color: t.muted,
                            ),
                          ),
                        ],
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
