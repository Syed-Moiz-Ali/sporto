import 'package:flutter/material.dart';
import 'package:referee_data/referee_data.dart';
import 'package:ui_kit/ui_kit.dart';

import '../../../../core/di/dependency_injector.dart';
import '../widgets/scorecard_redesign_widgets.dart';

/// Complete cricket scorecard (redesign screens 03/04).
///
/// The selected team pill controls both tables:
/// * batting innings where `battingTeamId == team.id`;
/// * bowling figures from the innings where `bowlingTeamId == team.id`.
class FullScorecardScreen extends StatefulWidget {
  final String? matchId;
  final RefereeMatchResponse? match;
  final int? initialTeamId;
  final Future<RefereeScorecardResponse>? scorecardFuture;

  const FullScorecardScreen({
    super.key,
    this.matchId,
    this.match,
    this.initialTeamId,
    this.scorecardFuture,
  });

  @override
  State<FullScorecardScreen> createState() => _FullScorecardScreenState();
}

class _FullScorecardScreenState extends State<FullScorecardScreen> {
  late Future<RefereeScorecardResponse> _future;

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  int? get _matchId {
    final parsed = int.tryParse(widget.matchId ?? '');
    return parsed ?? widget.match?.id;
  }

  Future<RefereeScorecardResponse> _load() {
    final injected = widget.scorecardFuture;
    if (injected != null) return injected;
    final id = _matchId;
    if (id == null) {
      return Future<RefereeScorecardResponse>.error(
        const FormatException('Match id is missing.'),
      );
    }
    return DependencyInjector.instance.refereeRemoteDataSource
        .getMatchScorecard(id);
  }

  void _retry() {
    setState(() => _future = _load());
  }

  @override
  Widget build(BuildContext context) {
    final scale = context.sportoScale;
    return Scaffold(
      backgroundColor: const Color(0xFF090C10),
      body: SafeArea(
        bottom: false,
        child: FutureBuilder<RefereeScorecardResponse>(
          future: _future,
          builder: (context, snapshot) {
            final scorecard = snapshot.data;
            final header = ScorecardRedesignHeader(
              scale: scale,
              title: scorecardMatchTitle(widget.match, scorecard: scorecard),
              location: scorecardMatchLocation(
                widget.match,
                scorecard: scorecard,
              ),
              dateLabel: scorecardDateMeta(widget.match),
              onBack: () => Navigator.of(context).maybePop(),
            );

            if (snapshot.connectionState == ConnectionState.waiting) {
              return Column(
                children: [
                  header,
                  Expanded(
                    child: ScorecardRedesignSkeleton(
                      scale: scale,
                      showPills: false,
                    ),
                  ),
                ],
              );
            }

            if (snapshot.hasError || scorecard == null) {
              return Column(
                children: [
                  header,
                  Expanded(
                    child: ListView(
                      padding: EdgeInsets.fromLTRB(
                        20 * scale,
                        20 * scale,
                        20 * scale,
                        40 * scale,
                      ),
                      children: [
                        ScorecardRedesignErrorCard(
                          scale: scale,
                          message: snapshot.error?.toString() ??
                              'The scorecard could not be loaded.',
                          onRetry: _retry,
                        ),
                      ],
                    ),
                  ),
                ],
              );
            }

            return Column(
              children: [
                header,
                Expanded(
                  child: _FullScorecardBody(
                    scorecard: scorecard,
                    match: widget.match,
                    initialTeamId: widget.initialTeamId,
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _FullScorecardBody extends StatefulWidget {
  final RefereeScorecardResponse scorecard;
  final RefereeMatchResponse? match;
  final int? initialTeamId;

  const _FullScorecardBody({
    required this.scorecard,
    required this.match,
    required this.initialTeamId,
  });

  @override
  State<_FullScorecardBody> createState() => _FullScorecardBodyState();
}

class _FullScorecardBodyState extends State<_FullScorecardBody> {
  late List<ScorecardRedesignTeamPillData> _teams;
  int? _selectedTeamId;

  @override
  void initState() {
    super.initState();
    _syncTeams();
  }

  @override
  void didUpdateWidget(covariant _FullScorecardBody oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!identical(oldWidget.scorecard, widget.scorecard) ||
        oldWidget.initialTeamId != widget.initialTeamId) {
      _syncTeams();
    }
  }

  void _syncTeams() {
    _teams = [
      for (final team in scorecardTeams(widget.scorecard, widget.match))
        ScorecardRedesignTeamPillData(id: team.id, name: team.name),
    ];
    _selectedTeamId = _pickTeam(widget.initialTeamId);
  }

  int? _pickTeam(int? preferred) {
    if (_teams.isEmpty) return null;
    if (preferred != null && _teams.any((team) => team.id == preferred)) {
      return preferred;
    }
    return _teams.first.id;
  }

  RefereeScorecardTeam? _selectedTeam() {
    final id = _selectedTeamId;
    if (id == null) return null;
    for (final team in scorecardTeams(widget.scorecard, widget.match)) {
      if (team.id == id) return team;
    }
    return null;
  }

  RefereeScorecardInnings? _battingInnings(RefereeScorecardTeam team) {
    for (final innings in widget.scorecard.innings) {
      if (innings.battingTeamId == team.id) return innings;
    }
    final name = team.name.trim().toLowerCase();
    for (final innings in widget.scorecard.innings) {
      if (innings.battingTeamName?.trim().toLowerCase() == name) {
        return innings;
      }
    }
    return null;
  }

  RefereeScorecardInnings? _bowlingInnings(RefereeScorecardTeam team) {
    for (final innings in widget.scorecard.innings) {
      if (innings.bowlingTeamId == team.id) return innings;
    }
    final name = team.name.trim().toLowerCase();
    for (final innings in widget.scorecard.innings) {
      if (innings.bowlingTeamName?.trim().toLowerCase() == name) {
        return innings;
      }
    }
    return null;
  }

  int? _playerRuns(String name) {
    final target = name.trim().toLowerCase();
    for (final innings in widget.scorecard.innings) {
      for (final bat in innings.batting) {
        if (bat.name.trim().toLowerCase() == target) return bat.runs;
      }
    }
    return null;
  }

  int? _playerWickets(String name) {
    final target = name.trim().toLowerCase();
    for (final innings in widget.scorecard.innings) {
      for (final bowl in innings.bowling) {
        if (bowl.name.trim().toLowerCase() == target) return bowl.wickets;
      }
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final scale = context.sportoScale;
    final scorecard = widget.scorecard;
    final match = widget.match;
    final teams = scorecardTeams(scorecard, match);
    final left = teams.isNotEmpty ? teams[0] : null;
    final right = teams.length > 1 ? teams[1] : null;
    final title = scorecardMatchTitle(match, scorecard: scorecard);

    final selectedTeam = _selectedTeam();
    final battingInnings =
        selectedTeam == null ? null : _battingInnings(selectedTeam);
    final bowlingInnings =
        selectedTeam == null ? null : _bowlingInnings(selectedTeam);

    final winner = scorecardWinnerName(scorecard, match: match);
    final winnerSubtitle = scorecardWinnerSubtitle(
      scorecard,
      match: match,
      winner: winner,
    );

    final superRows = <ScorecardRedesignSuperOverRow>[];
    if (left != null && right != null) {
      final leftSuper = scorecardSuperOverScore(scorecard, left.id);
      final rightSuper = scorecardSuperOverScore(scorecard, right.id);
      if (leftSuper != null || rightSuper != null) {
        superRows.add(
          ScorecardRedesignSuperOverRow(
            leftScore: leftSuper ?? '\u2014',
            rightScore: rightSuper ?? '\u2014',
          ),
        );
      }
    }

    final player = scorecard.playerOfMatch?.trim();
    final playerRuns =
        (player == null || player.isEmpty) ? null : _playerRuns(player);
    final playerWickets =
        (player == null || player.isEmpty) ? null : _playerWickets(player);

    final hasInnings = battingInnings != null || bowlingInnings != null;

    return ListView(
      padding: EdgeInsets.fromLTRB(
        20 * scale,
        20 * scale,
        20 * scale,
        40 * scale,
      ),
      children: [
        ScorecardRedesignMatchCard(
          scale: scale,
          clock: scorecardClockText(match),
          round: scorecardMatchRound(match, scorecard: scorecard),
          status: scorecardStatusLabel(match),
          tournament: title,
          sport: scorecardSportLabel(match),
          venue: scorecardMatchVenue(match, scorecard: scorecard),
          squareLabel: scorecardTeamInitials(title),
        ),
        SizedBox(height: 20 * scale),
        ScorecardRedesignMatchSummaryCard(
          scale: scale,
          leftTeam: left?.name ?? match?.displayTeamA ?? 'Team A',
          leftScore: left != null
              ? scorecardTeamScore(scorecard, left.id, match)
              : (match?.teamA?.score ?? '\u2014'),
          rightTeam: right?.name ?? match?.displayTeamB ?? 'Team B',
          rightScore: right != null
              ? scorecardTeamScore(scorecard, right.id, match)
              : (match?.teamB?.score ?? '\u2014'),
          superOvers: superRows,
          dateLine: scorecardVenueLine(match, scorecard: scorecard),
          winnerName: winner,
          winnerSubtitle: winnerSubtitle,
          showWinner: true,
        ),
        if (_teams.length >= 2) ...[
          SizedBox(height: 20 * scale),
          ScorecardRedesignTeamToggles(
            scale: scale,
            teams: _teams,
            selectedId: _selectedTeamId,
            onSelected: (id) => setState(() => _selectedTeamId = id),
          ),
        ],
        SizedBox(height: 20 * scale),
        if (selectedTeam == null || !hasInnings)
          ScorecardRedesignEmptyCard(
            scale: scale,
            message: selectedTeam == null
                ? 'No team innings are available for this match.'
                : 'No innings have been recorded for ${selectedTeam.name} yet.',
          )
        else ...[
          if (battingInnings != null) ...[
            ScorecardRedesignInningsHeader(
              scale: scale,
              scoreLine: '${battingInnings.totals.scoreText} '
                  '(${scorecardOversShort(battingInnings.totals)} overs)',
            ),
            SizedBox(height: 8 * scale),
            ScorecardRedesignBattingTable(
              scale: scale,
              innings: battingInnings,
            ),
          ] else ...[
            ScorecardRedesignInningsHeader(
              scale: scale,
              scoreLine: 'No batting innings',
            ),
            SizedBox(height: 8 * scale),
            ScorecardRedesignEmptyCard(
              scale: scale,
              message:
                  'Batting figures are not available for ${selectedTeam.name}.',
            ),
          ],
          SizedBox(height: 20 * scale),
          ScorecardRedesignSectionLabel(scale: scale, text: 'Bowling'),
          SizedBox(height: 8 * scale),
          if (bowlingInnings != null && bowlingInnings.bowling.isNotEmpty)
            ScorecardRedesignBowlingTable(
              scale: scale,
              innings: bowlingInnings,
            )
          else
            ScorecardRedesignEmptyCard(
              scale: scale,
              message:
                  'Bowling figures are not available for ${selectedTeam.name}.',
            ),
        ],
        if (player != null && player.isNotEmpty) ...[
          SizedBox(height: 20 * scale),
          ScorecardRedesignPlayerOfMatchCard(
            scale: scale,
            name: player,
            runs: playerRuns,
            wickets: playerWickets,
          ),
        ],
      ],
    );
  }
}
