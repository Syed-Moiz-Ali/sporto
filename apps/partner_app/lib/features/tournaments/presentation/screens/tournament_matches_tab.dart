import 'package:flutter/material.dart';
import 'package:partner_data/partner_data.dart';
import 'package:ui_kit/ui_kit.dart';

import '../widgets/redesign/tournament_cards.dart';
import '../widgets/redesign/tournament_navigation.dart';
import '../widgets/redesign/tournament_redesign_data.dart';
import '../widgets/redesign/tournament_screen_parts.dart';

class TournamentMatchesTab extends StatefulWidget {
  const TournamentMatchesTab({
    super.key,
    required this.tournament,
    required this.matches,
    this.onAssignReferee,
    this.onScorecard,
  });

  final PartnerTournamentResponse tournament;
  final List<PartnerTournamentMatchResponse> matches;
  final ValueChanged<PartnerTournamentMatchResponse>? onAssignReferee;
  final ValueChanged<PartnerTournamentMatchResponse>? onScorecard;

  @override
  State<TournamentMatchesTab> createState() => _TournamentMatchesTabState();
}

class _TournamentMatchesTabState extends State<TournamentMatchesTab> {
  int _selectedRound = 0;

  @override
  Widget build(BuildContext context) {
    final t = context.sportoTournament;
    final rounds = _roundLabels();
    final filtered = _filteredMatches();
    final showDemo = widget.matches.isEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: 34,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: rounds.length,
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemBuilder: (_, index) => TournamentFilterChip(
              label: rounds[index],
              selected: _selectedRound == index,
              onTap: () => setState(() => _selectedRound = index),
              selectedColor: t.green,
              selectedForeground: t.screenBase,
            ),
          ),
        ),
        const SizedBox(height: 12),
        const TournamentBracketStrip(isExpanded: true),
        const SizedBox(height: 14),
        if (showDemo)
          for (var i = 0; i < _demoMatches.length; i++) ...[
            _demoMatches[i],
            if (i != _demoMatches.length - 1) const SizedBox(height: 10),
          ]
        else
          for (var i = 0; i < filtered.length; i++) ...[
            _matchCard(context, filtered[i]),
            if (i != filtered.length - 1) const SizedBox(height: 10),
          ],
      ],
    );
  }

  List<String> _roundLabels() {
    if (widget.matches.isEmpty) {
      return const [
        'All (32)',
        'Round of 64 (32)',
        'Round of 32 (16)',
        'Quarter-finals (4)',
        'Semi-finals (2)',
        'Final (1)',
      ];
    }
    final labels = <String>{'All (${widget.matches.length})'};
    for (final match in widget.matches) {
      final name = match.roundName?.trim();
      if (name != null && name.isNotEmpty) labels.add(name);
    }
    return labels.toList();
  }

  List<PartnerTournamentMatchResponse> _filteredMatches() {
    if (_selectedRound == 0) return widget.matches;
    final rounds = _roundLabels();
    if (_selectedRound >= rounds.length) return widget.matches;
    final selected =
        rounds[_selectedRound].replaceAll(RegExp(r'\s*\(\d+\)$'), '');
    return widget.matches
        .where(
            (m) => (m.roundName ?? '').toLowerCase() == selected.toLowerCase())
        .toList();
  }

  Widget _matchCard(
    BuildContext context,
    PartnerTournamentMatchResponse match,
  ) {
    final t = context.sportoTournament;
    final teamA = match.displayTeamA;
    final teamB = match.displayTeamB;
    final scoreA = _scoreFor(match, true);
    final scoreB = _scoreFor(match, false);
    final date = formatTournamentDate(
      match.schedule?.date ?? match.matchDate,
      fallback: '--',
    );
    final venue = match.displayVenue;
    final round = match.roundName ?? 'Match';
    final code = match.matchNumber ?? 'SPT-${match.id}';

    if (match.isLive) {
      return TournamentLiveMatchCard(
        teamA: teamA,
        teamB: teamB,
        scoreA: scoreA,
        scoreB: scoreB,
        venue: venue.isEmpty ? 'Venue TBD' : venue,
        roundText: round,
        dateText: formatTournamentDay(match.schedule?.date ?? match.matchDate),
        referee: 'Kiran Kumar',
        onScorecard: widget.onScorecard == null
            ? null
            : () => widget.onScorecard!(match),
      );
    }

    return TournamentMatchCard(
      roundText: round,
      matchCode: code,
      dateText: date,
      teamA: teamA,
      teamB: teamB,
      scoreA: match.isCompleted ? scoreA : null,
      scoreB: match.isCompleted ? scoreB : null,
      venue: venue.isEmpty ? null : venue,
      resultText: match.isCompleted
          ? '${match.result ?? '$teamA won the match'}'
          : null,
      referee: match.isCompleted ? 'Divya Sri' : null,
      statusLabel: match.isCompleted ? 'Completed' : 'Scheduled',
      statusColor: match.isCompleted ? t.completed : t.blue,
      refereeActionLabel: 'Change Referee',
      onReferee: widget.onAssignReferee == null
          ? null
          : () => widget.onAssignReferee!(match),
      onScorecard:
          widget.onScorecard == null ? null : () => widget.onScorecard!(match),
    );
  }

  String _scoreFor(PartnerTournamentMatchResponse match, bool teamA) {
    final score = match.raw[teamA ? 'team_a_score' : 'team_b_score'] ??
        match.raw[teamA ? 'team_a_runs' : 'team_b_runs'];
    if (score != null) return score.toString();
    return teamA ? '80/2 · 6.0' : '78/4 · 6.0';
  }

  List<Widget> get _demoMatches => [
        TournamentMatchCard(
          roundText: 'Final',
          matchCode: 'SPT-20481',
          dateText: '11 Oct 2026 · 8:00 AM',
          teamA: 'Hyd Highlanders',
          teamB: 'Delhi Warriors',
          scoreA: '80/2 · 6.0',
          scoreB: '78/4 · 6.0',
          resultText: 'Hyd Highlanders by 2 runs',
          statusLabel: 'Completed',
          statusColor: context.sportoTournament.completed,
          onScorecard: () => _scorecardHint(context),
        ),
        TournamentMatchCard(
          roundText: 'Semi-final 2',
          matchCode: 'SPT-20481',
          dateText: '11 Oct 2026 · 8:00 AM',
          teamA: 'Hyd Highlanders',
          teamB: 'Delhi Warriors',
          scoreA: '80/2 · 6.0',
          scoreB: '78/4 · 6.0',
          resultText: 'Hyd Highlanders by 2 runs',
          statusLabel: 'Completed',
          statusColor: context.sportoTournament.completed,
          onScorecard: () => _scorecardHint(context),
        ),
        TournamentMatchCard(
          roundText: 'Scheduled',
          matchCode: 'Round of 64 · 32 Matches',
          dateText: '05 Aug 2026',
          teamA: 'Cyber Panthers',
          teamB: 'Galli Kings',
          venue: 'KPHB Cricket Ground · Kondapur, Hyderabad',
          referee: 'Divya Sri',
          statusLabel: 'Scheduled',
          statusColor: context.sportoTournament.blue,
          onReferee: () => _refereeHint(context),
          onScorecard: () => _scorecardHint(context),
        ),
      ];

  void _scorecardHint(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Scorecard will be available soon.')),
    );
  }

  void _refereeHint(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Open the match to assign a referee.')),
    );
  }
}
