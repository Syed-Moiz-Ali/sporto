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

class VenueScheduleRedesignScreen extends StatefulWidget {
  const VenueScheduleRedesignScreen({super.key, required this.tournamentId});

  final String tournamentId;

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
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final tournament = await _api.showTournamentData(widget.tournamentId);
      if (!mounted) return;
      setState(() {
        _tournament = tournament;
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
    final tournament = _tournament;
    return Scaffold(
      backgroundColor: t.screenBase,
      body: SafeArea(
        child: Column(
          children: [
            TournamentScreenHeader(
              title: 'Venue & Schedule',
              subtitle: tournament == null
                  ? 'SPT-${widget.tournamentId}'
                  : '${tournamentCode(tournament)} · ${tournament.name}',
              onBack: () => context.pop(),
            ),
            if (_loading)
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
                  padding: const EdgeInsets.fromLTRB(20, 2, 20, 28),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TournamentStatusBar(
                        statusLabel: tournamentStatusLabel(tournament),
                        statusColor: tournamentStatusColor(tournament, t),
                        sport: tournamentSportLabel(tournament),
                        dateText: formatTournamentDate(
                          tournament.tournamentStartAt,
                        ),
                        live: tournament.status == 6,
                      ),
                      const SizedBox(height: 14),
                      TournamentSurface(
                        radius: t.r11,
                        padding: const EdgeInsets.all(14),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              tournament.name,
                              style: SportoTextStyles.text(
                                size: SportoTextStyles.size16,
                                weight: FontWeight.w600,
                                color: t.white,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Icon(Icons.location_on_outlined,
                                    size: 14, color: t.green),
                                const SizedBox(width: 3),
                                Expanded(
                                  child: Text(
                                    tournamentVenueLabel(tournament),
                                    style: SportoTextStyles.text(
                                      size: SportoTextStyles.size12,
                                      color: t.green,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 14),
                      TournamentSurface(
                        radius: t.r11,
                        padding: const EdgeInsets.all(14),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: TournamentSectionLabel(
                                    'Venue & Schedule',
                                    color: t.gold,
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () => _editHint(context),
                                  child: Row(
                                    children: [
                                      Text(
                                        'Edit',
                                        style: SportoTextStyles.text(
                                          size: SportoTextStyles.size12,
                                          color: t.blue,
                                        ),
                                      ),
                                      const SizedBox(width: 2),
                                      Icon(Icons.arrow_forward_rounded,
                                          size: 14, color: t.blue),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    'Number of Teams',
                                    style: SportoTextStyles.text(
                                      size: SportoTextStyles.size13,
                                      color: t.muted,
                                    ),
                                  ),
                                ),
                                Text(
                                  '${tournament.maximumTeams ?? 0} Teams',
                                  style: SportoTextStyles.text(
                                    size: SportoTextStyles.size13,
                                    color: t.warm,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            const TournamentBracketStrip(isExpanded: true),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                      if (tournament.tournamentVenues.isEmpty)
                        Text(
                          'No venues assigned yet.',
                          style: SportoTextStyles.text(
                            size: SportoTextStyles.size13,
                            color: t.muted,
                          ),
                        )
                      else
                        for (var i = 0;
                            i < tournament.tournamentVenues.length;
                            i++) ...[
                          TournamentVenueCard(
                            index: i + 1,
                            roundText:
                                tournament.tournamentVenues[i].roundName ??
                                    'Round of ${tournament.maximumTeams ?? 0}',
                            matchesText:
                                '${((tournament.maximumTeams ?? 0) ~/ 2)} Matches',
                            name: tournament.tournamentVenues[i].venueName,
                            location:
                                tournament.tournamentVenues[i].location ?? '--',
                            groundType:
                                tournament.tournamentVenues[i].groundType ??
                                    'Turf',
                            matchDate: formatTournamentDay(
                              tournament.tournamentVenues[i].date,
                            ),
                            startTime:
                                tournament.tournamentVenues[i].startTime ??
                                    '08:00 PM',
                            onEdit: () => _editHint(context),
                          ),
                          if (i != tournament.tournamentVenues.length - 1)
                            const SizedBox(height: 12),
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

  void _editHint(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Venue editing will open here.')),
    );
  }
}
