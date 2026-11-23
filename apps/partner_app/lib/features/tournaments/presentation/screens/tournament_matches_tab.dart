import 'package:flutter/material.dart';
import 'package:partner_data/partner_data.dart';
import 'package:ui_kit/ui_kit.dart';

import '../widgets/redesign/tournament_cards.dart';
import '../widgets/redesign/tournament_navigation.dart';
import '../widgets/redesign/tournament_redesign_data.dart';
import '../widgets/redesign/tournament_screen_parts.dart';

/// Matches tab — Figma `Partner App / Matches` (export 16, 37, 38).
class TournamentMatchesTab extends StatefulWidget {
  const TournamentMatchesTab({
    super.key,
    required this.tournament,
    required this.matches,
    this.rounds = const [],
    this.onAssignReferee,
    this.onScorecard,
  });

  final PartnerTournamentResponse tournament;
  final List<PartnerTournamentMatchResponse> matches;
  final List<TournamentRound> rounds;
  final ValueChanged<PartnerTournamentMatchResponse>? onAssignReferee;
  final ValueChanged<PartnerTournamentMatchResponse>? onScorecard;

  @override
  State<TournamentMatchesTab> createState() => _TournamentMatchesTabState();
}

class _TournamentMatchesTabState extends State<TournamentMatchesTab> {
  int _selectedRound = 0;

  /// Round names in play, derived from the real matches (falling back to the
  /// workflow rounds when a match carries no round label).
  List<String> get _roundLabels {
    final names = <String>{
      for (final m in widget.matches)
        if (_roundOf(m).isNotEmpty) _roundOf(m),
    }.toList();
    if (names.isEmpty) {
      names.addAll(widget.rounds.map((r) => r.name).where((n) => n.isNotEmpty));
    }
    return names;
  }

  String _roundOf(PartnerTournamentMatchResponse m) =>
      (m.roundName ?? m.round?.name ?? '').trim();

  @override
  Widget build(BuildContext context) {
    final t = context.sportoTournament;
    final labels = _roundLabels;
    final rounds = ['All (${widget.matches.length})', ...labels];
    final index = _selectedRound.clamp(0, rounds.length - 1);
    final filtered = index == 0
        ? widget.matches
        : widget.matches
            .where((m) => _roundOf(m) == labels[index - 1])
            .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: 34,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: rounds.length,
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemBuilder: (_, i) => TournamentFilterChip(
              label: rounds[i],
              selected: index == i,
              onTap: () => setState(() => _selectedRound = i),
              selectedColor: t.green,
              selectedForeground: t.screenBase,
            ),
          ),
        ),
        if (widget.rounds.isNotEmpty) ...[
          const SizedBox(height: 14),
          TournamentBracketStrip(rounds: widget.rounds),
        ],
        const SizedBox(height: 14),
        if (widget.matches.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 40),
            child: Center(
              child: Text(
                'No matches scheduled yet.',
                style: SportoTextStyles.text(
                  size: SportoTextStyles.size14,
                  color: t.muted,
                ),
              ),
            ),
          )
        else
          for (var i = 0; i < filtered.length; i++) ...[
            _MatchCard(
              match: filtered[i],
              roundText: _roundOf(filtered[i]),
              onReferee: widget.onAssignReferee == null
                  ? null
                  : () => widget.onAssignReferee!(filtered[i]),
              onScorecard: widget.onScorecard == null
                  ? null
                  : () => widget.onScorecard!(filtered[i]),
            ),
            if (i != filtered.length - 1) const SizedBox(height: 10),
          ],
      ],
    );
  }
}

class _MatchCard extends StatelessWidget {
  const _MatchCard({
    required this.match,
    required this.roundText,
    this.onReferee,
    this.onScorecard,
  });

  final PartnerTournamentMatchResponse match;
  final String roundText;
  final VoidCallback? onReferee;
  final VoidCallback? onScorecard;

  @override
  Widget build(BuildContext context) {
    final t = context.sportoTournament;
    final live = match.isLive;
    final completed = match.isCompleted;
    final statusLabel = live
        ? 'Live Now'
        : completed
            ? 'Completed'
            : 'Scheduled';
    return TournamentMatchCard(
      roundText: roundText.isEmpty ? 'Match' : roundText,
      matchCode: match.matchNumber == null
          ? 'SPT-${match.id}'
          : 'SPT-${match.matchNumber}',
      dateText: match.matchDate == null
          ? '--'
          : '${formatTournamentDay(match.matchDate)}'
              '${match.startTime == null ? '' : ' · ${match.startTime}'}',
      teamA: match.teamAName ?? 'TBA',
      teamB: match.teamBName ?? 'TBA',
      venue: match.venueName,
      resultText: match.result?.toString(),
      statusLabel: statusLabel,
      statusColor: live
          ? t.live
          : completed
              ? t.completed
              : t.upcoming,
      onScorecard: onScorecard,
      onReferee: onReferee,
      refereeActionLabel: 'Assign Referee',
    );
  }
}
