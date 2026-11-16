import 'package:flutter/material.dart';
import 'package:referee_data/referee_data.dart';
import 'package:ui_kit/ui_kit.dart';

import '../../../../core/di/dependency_injector.dart';
import '../widgets/scorecard_redesign_widgets.dart';
import 'full_scorecard_screen.dart';

/// Completed-match summary (redesign screen 02).
///
/// The orchestrator passes [match] when it already has the match list model;
/// otherwise this screen falls back to the scorecard payload for the header
/// and venue.
class MatchSummaryScreen extends StatefulWidget {
  final String? matchId;
  final RefereeMatchResponse? match;
  final VoidCallback? onViewScoreboard;
  final Future<RefereeScorecardResponse>? scorecardFuture;
  final Future<RefereeMatchResultResponse>? resultFuture;

  const MatchSummaryScreen({
    super.key,
    this.matchId,
    this.match,
    this.onViewScoreboard,
    this.scorecardFuture,
    this.resultFuture,
  });

  @override
  State<MatchSummaryScreen> createState() => _MatchSummaryScreenState();
}

class _MatchSummaryScreenState extends State<MatchSummaryScreen> {
  late Future<_SummaryPayload> _future;

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  int? get _matchId {
    final parsed = int.tryParse(widget.matchId ?? '');
    return parsed ?? widget.match?.id;
  }

  Future<_SummaryPayload> _load() async {
    final id = _matchId;
    if (id == null) {
      throw const FormatException('Match id is missing.');
    }

    final injectedScorecard = widget.scorecardFuture;
    final injectedResult = widget.resultFuture;
    if (injectedScorecard != null && injectedResult != null) {
      final values = await Future.wait<Object>([
        injectedScorecard,
        injectedResult,
      ]);
      return _SummaryPayload(
        scorecard: values[0] as RefereeScorecardResponse,
        result: values[1] as RefereeMatchResultResponse,
      );
    }

    final remote = DependencyInjector.instance.refereeRemoteDataSource;
    final values = await Future.wait<Object>([
      injectedScorecard ?? remote.getMatchScorecard(id),
      injectedResult ?? remote.getMatchResult(id),
    ]);
    return _SummaryPayload(
      scorecard: values[0] as RefereeScorecardResponse,
      result: values[1] as RefereeMatchResultResponse,
    );
  }

  void _retry() {
    setState(() => _future = _load());
  }

  void _openScoreboard(
    BuildContext context,
    RefereeScorecardResponse scorecard,
  ) {
    final callback = widget.onViewScoreboard;
    if (callback != null) {
      callback();
      return;
    }
    final id = widget.matchId ?? '${widget.match?.id ?? scorecard.match.id}';
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => FullScorecardScreen(
          matchId: id,
          match: widget.match,
          initialTeamId: scorecard.match.winnerTeamId,
          scorecardFuture: Future.value(scorecard),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final scale = context.sportoScale;
    return Scaffold(
      backgroundColor: const Color(0xFF090C10),
      body: SafeArea(
        bottom: false,
        child: FutureBuilder<_SummaryPayload>(
          future: _future,
          builder: (context, snapshot) {
            final scorecard = snapshot.data?.scorecard;
            final header = ScorecardRedesignHeader(
              scale: scale,
              title: scorecardMatchTitle(
                widget.match,
                scorecard: scorecard,
                fallback: 'Match Summary',
              ),
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
                    child: ScorecardRedesignSkeleton(scale: scale),
                  ),
                ],
              );
            }

            if (snapshot.hasError || !snapshot.hasData) {
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

            final payload = snapshot.data!;
            return Column(
              children: [
                header,
                Expanded(
                  child: _SummaryBody(
                    scale: scale,
                    payload: payload,
                    match: widget.match,
                    onViewScoreboard: () =>
                        _openScoreboard(context, payload.scorecard),
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

class _SummaryPayload {
  const _SummaryPayload({required this.scorecard, required this.result});

  final RefereeScorecardResponse scorecard;
  final RefereeMatchResultResponse result;
}

class _SummaryBody extends StatelessWidget {
  final double scale;
  final _SummaryPayload payload;
  final RefereeMatchResponse? match;
  final VoidCallback onViewScoreboard;

  const _SummaryBody({
    required this.scale,
    required this.payload,
    required this.match,
    required this.onViewScoreboard,
  });

  @override
  Widget build(BuildContext context) {
    final scorecard = payload.scorecard;
    final teams = scorecardTeams(scorecard, match);
    final left = teams.isNotEmpty ? teams[0] : null;
    final right = teams.length > 1 ? teams[1] : null;
    final title = scorecardMatchTitle(match, scorecard: scorecard);
    final winner = scorecardWinnerName(
      scorecard,
      match: match,
      result: payload.result,
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

    return ListView(
      padding: EdgeInsets.fromLTRB(
        20 * scale,
        20 * scale,
        20 * scale,
        40 * scale,
      ),
      children: [
        ScorecardRedesignMetaPills(
          scale: scale,
          sport: scorecardSportLabel(match),
          code: scorecardMatchCode(match, scorecard),
          source: scorecardSourceLabel(match),
          status: scorecardStatusLabel(match),
        ),
        SizedBox(height: 20 * scale),
        ScorecardRedesignMatchCard(
          scale: scale,
          compact: true,
          clock: scorecardClockText(match),
          round: scorecardMatchRound(match, scorecard: scorecard),
          status: scorecardStatusLabel(match),
          tournament: title,
          sport: scorecardSportLabel(match),
          venue: scorecardMatchVenue(match, scorecard: scorecard),
          squareLabel: scorecardCardInitials(match, scorecard: scorecard),
        ),
        SizedBox(height: 20 * scale),
        Row(
          children: [
            Expanded(
              flex: 159,
              child: ScorecardRedesignWinnerPill(
                scale: scale,
                winner: winner ?? 'Match completed',
              ),
            ),
            SizedBox(width: 16 * scale),
            Expanded(
              flex: 175,
              child: ScorecardRedesignViewScoreboardButton(
                scale: scale,
                onTap: onViewScoreboard,
              ),
            ),
          ],
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
        ),
      ],
    );
  }
}
