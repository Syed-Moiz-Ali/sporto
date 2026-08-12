import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:ui_kit/ui_kit.dart';

import '../../../../app/router/app_router.dart';

class MatchVerificationScreen extends StatefulWidget {
  const MatchVerificationScreen({
    super.key,
  });

  @override
  State<MatchVerificationScreen> createState() =>
      _MatchVerificationScreenState();
}

class _MatchVerificationScreenState extends State<MatchVerificationScreen> {
  // ==========================================================
  // CURRENT CHECK-IN STATE
  //
  // These should eventually come from MatchScoringBloc/API.
  // ==========================================================

  bool _team1Present = true;
  bool _team2Present = true;

  // Toss is NOT completed on this screen.
  final bool _tossDone = false;

  // ==========================================================
  // DATA
  // ==========================================================

  static const String _team1Label = 'Team 1';

  static const String _team1Name = 'Delhi Warriors';

  static const String _team2Label = 'Team 2';

  static const String _team2Name = 'Hyd Highlanders';

  static const List<String> _team1Players = [
    'Shrvn Prajapati (Captain)',
    'Amit Kumar',
    'Manish K',
    'Sumit Nai',
    'Mayank S',
  ];

  static const List<String> _team2Players = [
    'Vikram Reddy (Captain)',
    'Dev Kumar',
    'Pankaj S',
    'Rohan A',
    'Vinayak L',
  ];

  // ==========================================================
  // DERIVED STATE
  // ==========================================================

  bool get _bothTeamsReady => _team1Present && _team2Present;

  bool get _hasAbsentTeam => !_team1Present || !_team2Present;

  String get _absentTeamLabel {
    if (!_team1Present) {
      return _team1Label;
    }

    return _team2Label;
  }

  String get _absentTeamName {
    if (!_team1Present) {
      return _team1Name;
    }

    return _team2Name;
  }

  String get _walkoverWinner {
    if (!_team1Present) {
      return _team2Name;
    }

    // Use "Rockets CC" here only if this
    // is the real team name coming from API.
    return _team1Name;
  }

  // ==========================================================
  // BUILD
  // ==========================================================

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scale = context.sportoScale;

    return SportoScreenShell(
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // =================================================
            // HEADER
            // =================================================

            SportoMatchVerificationHeader(
              matchId: 'SPT-20481',
              onBack: () {
                if (context.canPop()) {
                  context.pop();
                }
              },
            ),

            // =================================================
            // CONTENT
            // =================================================

            Expanded(
              child: SingleChildScrollView(
                physics: const ClampingScrollPhysics(),
                padding: EdgeInsets.fromLTRB(
                  20 * scale,
                  0,
                  20 * scale,
                  40 * scale,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // =========================================
                    // MATCH SUMMARY
                    // =========================================

                    const SportoVerificationMatchSummaryCard(
                      team1: _team1Name,
                      team2: _team2Name,
                    ),

                    SizedBox(height: 20 * scale),

                    // =========================================
                    // TITLE
                    // =========================================

                    Text(
                      'Team Verification',
                      style: theme.textTheme.titleLarge?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                        fontSize: 15 * scale,
                        fontWeight: FontWeight.w600,
                      ),
                    ),

                    SizedBox(height: 12 * scale),

                    // =========================================
                    // TEAM 1
                    // =========================================

                    SportoTeamVerificationCard(
                      teamLabel: _team1Label,
                      teamName: _team1Name,
                      players: _team1Players,
                      isPresent: _team1Present,
                      onMarkPresent: () {
                        setState(() {
                          _team1Present = true;
                        });
                      },
                      onMarkAbsent: () {
                        setState(() {
                          _team1Present = false;
                        });
                      },
                    ),

                    SizedBox(height: 10 * scale),

                    // =========================================
                    // TEAM 2
                    // =========================================

                    SportoTeamVerificationCard(
                      teamLabel: _team2Label,
                      teamName: _team2Name,
                      players: _team2Players,
                      isPresent: _team2Present,
                      onMarkPresent: () {
                        setState(() {
                          _team2Present = true;
                        });
                      },
                      onMarkAbsent: () {
                        setState(() {
                          _team2Present = false;
                        });
                      },
                    ),

                    SizedBox(height: 24 * scale),

                    // =========================================
                    // FINAL CHECKLIST
                    // =========================================

                    Text(
                      'Final Checklist',
                      style: theme.textTheme.titleLarge?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                        fontSize: 15 * scale,
                        fontWeight: FontWeight.w600,
                      ),
                    ),

                    SizedBox(height: 11 * scale),

                    SportoVerificationChecklist(
                      team1Checked: _team1Present,
                      team2Checked: _team2Present,
                      tossChecked: _tossDone,
                    ),

                    // =========================================
                    // BOTH TEAMS READY
                    // =========================================

                    if (_bothTeamsReady) ...[
                      SizedBox(
                        height: 20 * scale,
                      ),
                      SportoVerificationReadyButton(
                        onTap: () {
                          context.push(
                            AppRouter.conductTossRoute,
                          );
                        },
                      ),
                    ],

                    // =========================================
                    // TEAM ABSENT / GRACE PERIOD EXPIRED
                    // =========================================

                    if (_hasAbsentTeam) ...[
                      SizedBox(
                        height: 21 * scale,
                      ),
                      SportoVerificationAbsentDecisionCard(
                        absentTeamLabel: _absentTeamLabel,
                        absentTeamName: _absentTeamName,
                        team1Ready: _team1Present,
                        team2Ready: _team2Present,
                      ),
                      SizedBox(
                        height: 20 * scale,
                      ),
                      SportoWalkoverActions(
                        awardToTeam: _walkoverWinner,
                        onAwardWalkover: () {
                          _awardWalkover();
                        },
                        onMarkAbsent: () {
                          _confirmAbsent();
                        },
                      ),
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

  // ==========================================================
  // WALKOVER
  // ==========================================================

  void _awardWalkover() {
    final winner = _walkoverWinner;

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(
            'Walkover awarded to $winner',
          ),
        ),
      );

    // Later:
    //
    // context.read<MatchScoringBloc>().add(
    //   AwardWalkoverEvent(...)
    // );
  }

  // ==========================================================
  // ABSENT
  // ==========================================================

  void _confirmAbsent() {
    final absentTeam = _absentTeamName;

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(
            '$absentTeam marked absent',
          ),
        ),
      );

    // Later persist through your BLoC/API.
  }
}
