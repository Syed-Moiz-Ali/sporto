import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:partner_data/partner_data.dart';
import 'package:ui_kit/ui_kit.dart';

import '../widgets/redesign/tournament_cards.dart';
import '../widgets/redesign/tournament_redesign_data.dart';
import '../widgets/redesign/tournament_screen_parts.dart';
import '../widgets/redesign/tournament_shimmer.dart';
import '../widgets/redesign/tournament_visuals.dart';

/// Venue & Schedule — Figma `Partner App / Venue & Schedule` (export 13).
///
/// Venue rows are real: `tournament_venues` carries `round_name`, `date`,
/// `start_time`, `ground_type`; per-round match counts come from
/// `getRounds(id)`.
class VenueScheduleRedesignScreen extends StatefulWidget {
  const VenueScheduleRedesignScreen({
    super.key,
    required this.tournamentId,
    this.tournamentOverride,
    this.roundsOverride,
    this.isLoading,
  });

  final String tournamentId;

  /// Test injection.
  final PartnerTournamentResponse? tournamentOverride;
  final List<TournamentRound>? roundsOverride;
  final bool? isLoading;

  @override
  State<VenueScheduleRedesignScreen> createState() =>
      _VenueScheduleRedesignScreenState();
}

class _VenueScheduleRedesignScreenState
    extends State<VenueScheduleRedesignScreen> {
  late final PartnerRemoteDataSource _api = PartnerRemoteDataSource(
    apiClient: SportoApiClient(tokenProvider: AuthSessionStore().getToken),
  );

  PartnerTournamentResponse? _tournament;
  List<TournamentRound> _rounds = const [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    if (widget.tournamentOverride != null) {
      _tournament = widget.tournamentOverride;
      _rounds = widget.roundsOverride ?? const [];
      _loading = false;
      return;
    }
    _load();
  }

  Future<void> _load() async {
    try {
      final tournament = await _api.showTournamentData(widget.tournamentId);
      List<TournamentRound> rounds = const [];
      try {
        rounds = await _api.getRounds(widget.tournamentId);
      } catch (_) {}
      if (!mounted) return;
      setState(() {
        _tournament = tournament;
        _rounds = rounds;
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = context.sportoTournament;
    final scale = context.sportoScale;
    final tournament = _tournament;
    final loading = widget.isLoading ?? (_loading && tournament == null);

    return Scaffold(
      backgroundColor: t.screenBase,
      body: Column(
        children: [
          TournamentScreenHeader(
            title: 'Venue & Schedule',
            subtitle: tournament == null
                ? 'SPT-${widget.tournamentId}'
                : '${tournamentCode(tournament)} · ${tournament.name}',
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
          if (loading)
            const Expanded(child: VenueScheduleShimmer())
          else if (tournament == null)
            Expanded(
              child: Center(
                child: Text(
                  'Venue details could not be loaded.',
                  style: SportoTextStyles.text(
                    size: SportoTextStyles.size14,
                    color: t.muted,
                  ),
                ),
              ),
            )
          else
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(
                  20 * scale,
                  10 * scale,
                  20 * scale,
                  28 * scale,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TournamentStatusStrip(
                      tournament: tournament,
                      dateText: tournament.status == 6
                          ? formatTournamentStripDate(
                              tournament.tournamentStartAt)
                          : formatTournamentDay(
                              tournament.tournamentStartAt),
                    ),
                    SizedBox(height: 16 * scale),
                    TournamentIdentityCard(tournament: tournament),
                    SizedBox(height: 16 * scale),
                    _SchedulePanel(
                      tournament: tournament,
                      rounds: _rounds,
                      onEdit: () => _editHint(context),
                    ),
                    for (final venue in _venues(tournament)) ...[
                      SizedBox(height: 10 * scale),
                      TournamentVenueCard(
                        index: venue.$1,
                        roundText:
                            venue.$2 == null ? '' : venue.$2!.roundName ?? '',
                        matchesText: _matchesLabel(venue.$2?.roundName),
                        name: venue.$2?.venueName ?? '',
                        location: venue.$2?.location ?? '--',
                        groundType: venue.$2?.groundType ?? '--',
                        matchDate: venue.$2?.date == null
                            ? '--'
                            : formatTournamentDay(venue.$2!.date),
                        startTime: venue.$2?.startTime ?? '--',
                        onEdit: () => _editHint(context),
                      ),
                    ],
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  List<(int, PartnerTournamentVenueResponse?)> _venues(
    PartnerTournamentResponse tournament,
  ) {
    final venues = [
      ...tournament.tournamentVenues
    ]..sort((a, b) => (a.displayOrder ?? 999).compareTo(b.displayOrder ?? 999));
    return [for (var i = 0; i < venues.length; i++) (i + 1, venues[i])];
  }

  String _matchesLabel(String? roundName) {
    if (roundName == null || roundName.trim().isEmpty) return '';
    final round = _rounds.where((r) => r.name == roundName).firstOrNull;
    if (round == null) return '';
    final count =
        round.matchCount > 0 ? round.matchCount : round.expectedMatchCount;
    if (count <= 0) return '';
    return count == 1 ? '1 Match' : '$count Matches';
  }

  void _editHint(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Venue editing will open here.')),
    );
  }
}

/// `Venue & Schedule` panel: teams, bracket ladder (export: white hairline).
class _SchedulePanel extends StatelessWidget {
  const _SchedulePanel({
    required this.tournament,
    required this.rounds,
    this.onEdit,
  });

  final PartnerTournamentResponse tournament;
  final List<TournamentRound> rounds;
  final VoidCallback? onEdit;

  @override
  Widget build(BuildContext context) {
    final t = context.sportoTournament;
    final scale = context.sportoScale;
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(12 * scale),
      decoration: BoxDecoration(
        color: t.cardAlt,
        borderRadius: BorderRadius.circular(t.r16),
        border: GradientBorder.all(
          gradient: t.whiteBorderGradient,
          width: 1,
          radius: t.r16,
        ),
        boxShadow: t.softCardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Venue & Schedule',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: SportoTextStyles.text(
                    size: SportoTextStyles.size14,
                    weight: FontWeight.w500,
                    color: t.gold,
                  ),
                ),
              ),
              if (onEdit != null)
                GestureDetector(
                  onTap: onEdit,
                  behavior: HitTestBehavior.opaque,
                  child: Row(
                    children: [
                      Text(
                        'Edit',
                        style: SportoTextStyles.text(
                          size: SportoTextStyles.size11,
                          color: t.blue,
                        ),
                      ),
                      const SizedBox(width: 2),
                      SportoSvgIcon(
                        SportoHomeRedesignIcons.arrowRight,
                        width: 11,
                        height: 7,
                        color: t.blue,
                      ),
                    ],
                  ),
                ),
            ],
          ),
          SizedBox(height: 8 * scale),
          TournamentDivider(
            height: .8,
            color: t.border.withValues(alpha: .5),
          ),
          SizedBox(height: 8 * scale),
          Row(
            children: [
              Expanded(
                child: Text(
                  'Number of Teams',
                  style: SportoTextStyles.text(
                    size: SportoTextStyles.size14,
                    color: t.muted,
                  ),
                ),
              ),
              Flexible(
                child: Text(
                  '${tournament.maximumTeams ?? 0} Teams',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: SportoTextStyles.text(
                    size: SportoTextStyles.size14,
                    color: t.muted,
                  ),
                ),
              ),
            ],
          ),
          if (rounds.isNotEmpty) ...[
            SizedBox(height: 10 * scale),
            TournamentBracketStrip(rounds: rounds),
          ],
        ],
      ),
    );
  }
}
