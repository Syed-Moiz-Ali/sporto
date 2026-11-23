import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:partner_data/partner_data.dart';
import 'package:ui_kit/ui_kit.dart';

import '../../../../app/router/app_router.dart';
import '../../../partner_api/application/partner_api_bloc.dart';
import '../widgets/redesign/tournament_cards.dart';
import '../widgets/redesign/tournament_redesign_data.dart';
import '../widgets/redesign/tournament_screen_parts.dart';
import '../widgets/redesign/tournament_shimmer.dart';

/// Live Tournaments — Figma `Partner App / Live Tournaments` (export 01).
class LiveTournamentsRedesignScreen extends StatelessWidget {
  const LiveTournamentsRedesignScreen({super.key, this.tournamentsOverride});

  /// Test injection; production reads [PartnerApiBloc].
  final List<PartnerTournamentResponse>? tournamentsOverride;

  @override
  Widget build(BuildContext context) {
    final t = context.sportoTournament;
    final scale = context.sportoScale;
    PartnerApiLoadedState? loaded;
    try {
      final state = context.watch<PartnerApiBloc>().state;
      if (state is PartnerApiLoadedState) loaded = state;
    } catch (_) {}

    final all = tournamentsOverride ?? loaded?.tournaments ?? const [];
    final live = tournamentsOverride != null
        ? all.where((item) => item.status == 6).toList()
        : loaded?.liveTournaments ?? const [];
    final upcoming = all.where((t) => t.status >= 2 && t.status <= 5).length;
    final completed = all.where((t) => t.status == 7).length;

    return Scaffold(
      backgroundColor: t.screenBase,
      body: Column(
        children: [
          TournamentScreenHeader(
            title: 'Live Tournaments (${live.length})',
            titleSize: SportoTextStyles.size16,
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
            child: loaded == null && tournamentsOverride == null
                ? const TournamentListScreenShimmer()
                : live.isEmpty
                    ? Center(
                        child: Text(
                          'No live tournaments right now',
                          style: SportoTextStyles.text(
                            size: SportoTextStyles.size14,
                            color: t.muted,
                          ),
                        ),
                      )
                    : ListView.separated(
                        padding: EdgeInsets.fromLTRB(
                          20 * scale,
                          10 * scale,
                          20 * scale,
                          24 * scale,
                        ),
                        itemCount: live.length,
                        separatorBuilder: (_, __) =>
                            SizedBox(height: 10 * scale),
                        itemBuilder: (_, index) {
                          final tournament = live[index];
                          final registered = tournament.registeredTeams ?? 0;
                          final maxTeams = tournament.maximumTeams ?? 0;
                          return LiveTournamentCard(
                            name: tournament.name,
                            venue: tournamentVenueLabel(tournament),
                            code: tournamentCode(tournament),
                            dateText: formatTournamentStripDate(
                              tournament.tournamentStartAt,
                            ),
                            teamsText: '$registered/$maxTeams Teams',
                            slotsText:
                                '${(maxTeams - registered).clamp(0, maxTeams)} slots left',
                            upcoming: '$upcoming',
                            live: '${live.length}',
                            completed: '$completed',
                            onOpen: () => context.push(
                              AppRouter.tournamentDetailRoute(
                                '${tournament.id}',
                              ),
                            ),
                            onMonitor: () => context.push(
                              AppRouter.tournamentDetailRoute(
                                '${tournament.id}',
                              ),
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}
