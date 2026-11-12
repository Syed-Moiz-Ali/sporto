import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:ui_kit/ui_kit.dart';

import '../../../../app/router/app_router.dart';
import '../../../partner_api/application/partner_api_bloc.dart';
import '../widgets/redesign/tournament_cards.dart';
import '../widgets/redesign/tournament_redesign_data.dart';
import '../widgets/redesign/tournament_screen_parts.dart';
import '../widgets/redesign/tournament_shimmer.dart';

class LiveTournamentsRedesignScreen extends StatelessWidget {
  const LiveTournamentsRedesignScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final t = context.sportoTournament;
    PartnerApiLoadedState? loaded;
    try {
      final state = context.watch<PartnerApiBloc>().state;
      if (state is PartnerApiLoadedState) loaded = state;
    } catch (_) {}

    final live = loaded?.liveTournaments ?? const [];

    return Scaffold(
      backgroundColor: t.screenBase,
      body: SafeArea(
        child: Column(
          children: [
            TournamentScreenHeader(
              title: 'Live Tournaments (${live.length})',
              onBack: () => context.pop(),
            ),
            Expanded(
              child: loaded == null
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
                          padding: const EdgeInsets.fromLTRB(20, 6, 20, 24),
                          itemCount: live.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(height: 14),
                          itemBuilder: (_, index) {
                            final tournament = live[index];
                            final registered = tournament.registeredTeams ?? 0;
                            final maxTeams = tournament.maximumTeams ?? 0;
                            return LiveTournamentCard(
                              name: tournament.name,
                              venue: tournamentVenueLabel(tournament),
                              code: tournamentCode(tournament),
                              dateText: formatTournamentDate(
                                tournament.tournamentStartAt,
                              ),
                              teamsText: '$registered/$maxTeams Teams',
                              slotsText:
                                  '${(maxTeams - registered).clamp(0, maxTeams)} slots left',
                              refereeText: '2 awaiting referee',
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
      ),
    );
  }
}
