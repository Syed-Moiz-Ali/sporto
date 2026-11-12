import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:partner_data/partner_data.dart';
import 'package:ui_kit/ui_kit.dart';

import '../../../../app/router/app_router.dart';
import '../widgets/redesign/tournament_navigation.dart';
import '../widgets/redesign/tournament_redesign_data.dart';
import '../widgets/redesign/tournament_screen_parts.dart';
import '../widgets/redesign/tournament_shimmer.dart';
import '../widgets/redesign/tournament_visuals.dart';
import 'assign_referee_screen.dart';
import 'player_details_redesign_screen.dart';
import 'team_details_screen.dart';
import 'tournament_financials_tab.dart';
import 'tournament_info_tab.dart';
import 'tournament_matches_tab.dart';
import 'tournament_stats_tab.dart';
import 'tournament_teams_tab.dart';

class TournamentDetailRedesignScreen extends StatefulWidget {
  const TournamentDetailRedesignScreen({
    super.key,
    this.tournamentId,
    this.initialTabIndex = 0,
    this.isLoading,
    this.remoteDataSource,
    this.initialTournament,
  });

  final String? tournamentId;
  final int initialTabIndex;
  final bool? isLoading;
  final PartnerRemoteDataSource? remoteDataSource;
  final PartnerTournamentResponse? initialTournament;

  @override
  State<TournamentDetailRedesignScreen> createState() =>
      _TournamentDetailRedesignScreenState();
}

class _TournamentDetailRedesignScreenState
    extends State<TournamentDetailRedesignScreen> {
  static const _tabs = ['Info', 'Matches', 'Teams', 'Stats', 'Financials'];

  late int _tabIndex;
  late final PartnerRemoteDataSource _remoteDataSource =
      widget.remoteDataSource ??
          PartnerRemoteDataSource(
            apiClient: SportoApiClient(
              tokenProvider: AuthSessionStore().getToken,
            ),
          );

  PartnerTournamentResponse? _tournament;
  List<PartnerTournamentMatchResponse> _matches = const [];
  List<TournamentRegistration> _registrations = const [];
  PartnerTournamentReviewData? _review;
  bool _isLoading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _tabIndex = widget.initialTabIndex.clamp(0, _tabs.length - 1);
    _tournament = widget.initialTournament;
    final id = widget.tournamentId;
    if (widget.isLoading != true && id != null && id.isNotEmpty) {
      _load(id);
    }
  }

  Future<void> _load(String id) async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final tournament = await _remoteDataSource.showTournamentData(id);
      List<PartnerTournamentMatchResponse> matches = const [];
      List<TournamentRegistration> registrations = const [];
      PartnerTournamentReviewData? review;
      try {
        matches = await _remoteDataSource.listTournamentMatchesData(id);
      } catch (_) {}
      try {
        registrations = await _remoteDataSource.getRegistrations(id);
      } catch (_) {}
      try {
        review = await _remoteDataSource.reviewTournamentData(id);
      } catch (_) {}
      if (!mounted) return;
      setState(() {
        _tournament = tournament;
        _matches = matches;
        _registrations = registrations;
        _review = review;
        _isLoading = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _error = error.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = context.sportoTournament;
    final tournament = _tournament;
    final loading = widget.isLoading ?? (_isLoading && tournament == null);

    return Scaffold(
      backgroundColor: t.screenBase,
      body: SafeArea(
        child: Column(
          children: [
            TournamentScreenHeader(
              title: tournament?.name ?? 'Tournament Details',
              subtitle: tournament == null
                  ? (widget.tournamentId == null
                      ? null
                      : 'SPT-${widget.tournamentId}')
                  : '${tournamentCode(tournament)} · ${tournamentVenueLabel(tournament)}',
              onBack: () => context.pop(),
              trailing: TournamentActionPill(
                label: 'Edit',
                icon: Icon(Icons.edit_outlined, size: 14, color: t.blue),
                background: t.card,
                foreground: t.blue,
                border: t.border,
                height: 34,
                onTap: () => _showEditHint(context),
              ),
            ),
            if (loading)
              const Expanded(child: TournamentDetailScreenShimmer())
            else if (tournament == null)
              Expanded(
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Tournament details could not be loaded.',
                          style: SportoTextStyles.text(
                            size: SportoTextStyles.size15,
                            color: t.white,
                          ),
                        ),
                        if (_error != null) ...[
                          const SizedBox(height: 6),
                          Text(
                            _error!,
                            textAlign: TextAlign.center,
                            style: SportoTextStyles.text(
                              size: SportoTextStyles.size11,
                              color: t.muted,
                            ),
                          ),
                        ],
                        const SizedBox(height: 16),
                        TournamentActionPill(
                          label: 'Try Again',
                          gradient: t.bluePillGradient,
                          foreground: t.screenBase,
                          onTap: () {
                            final id = widget.tournamentId;
                            if (id != null && id.isNotEmpty) _load(id);
                          },
                        ),
                      ],
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
                      const SizedBox(height: 16),
                      TournamentUnderlineTabs(
                        labels: _tabs,
                        selectedIndex: _tabIndex,
                        onChanged: (index) => setState(() => _tabIndex = index),
                      ),
                      const SizedBox(height: 18),
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 180),
                        child: KeyedSubtree(
                          key: ValueKey(_tabIndex),
                          child: _tabContent(context, tournament),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _tabContent(
    BuildContext context,
    PartnerTournamentResponse tournament,
  ) {
    return switch (_tabIndex) {
      0 => TournamentInfoTab(
          tournament: tournament,
          matches: _matches,
          review: _review,
          onOpenVenue: () => context.push(
            AppRouter.venueScheduleRoute('${tournament.id}'),
          ),
          onOpenPrize: () => context.push(
            AppRouter.prizePoolRoute('${tournament.id}'),
          ),
          onEdit: () => _showEditHint(context),
        ),
      1 => TournamentMatchesTab(
          tournament: tournament,
          matches: _matches,
          onAssignReferee: (match) => _openReferee(context, tournament, match),
          onScorecard: (_) => _showScorecardHint(context),
        ),
      2 => TournamentTeamsTab(
          registrations: _registrations,
          onViewTeam: (registration) => _openTeam(
            context,
            tournament,
            registration,
          ),
        ),
      3 => TournamentStatsTab(
          onViewPlayer: (entry) => Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (_) => PlayerDetailsRedesignScreen(
                playerName: entry.name,
                teamName: entry.team,
                tournamentName: tournament.name,
              ),
            ),
          ),
        ),
      _ => TournamentFinancialsTab(review: _review),
    };
  }

  void _openReferee(
    BuildContext context,
    PartnerTournamentResponse tournament,
    PartnerTournamentMatchResponse match,
  ) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => AssignRefereeScreen(
          tournamentName: tournament.name,
          tournamentCode: tournamentCode(tournament),
          tournamentId: tournament.id,
          matchId: match.id,
          match: match,
          remoteDataSource: _remoteDataSource,
        ),
      ),
    );
  }

  void _openTeam(
    BuildContext context,
    PartnerTournamentResponse tournament,
    TournamentRegistration registration,
  ) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => TeamDetailsScreen(
          tournamentId: '${tournament.id}',
          registrationId: registration.id,
          api: _remoteDataSource,
        ),
      ),
    );
  }

  void _showEditHint(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Tournament editing will open here.')),
    );
  }

  void _showScorecardHint(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Scorecard will be available soon.')),
    );
  }
}
