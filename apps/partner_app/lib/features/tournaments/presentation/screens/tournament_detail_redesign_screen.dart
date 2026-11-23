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
    this.initialRounds = const [],
    this.initialReview,
    this.initialMatches = const [],
    this.initialRegistrations = const [],
  });

  final String? tournamentId;
  final int initialTabIndex;
  final bool? isLoading;
  final PartnerRemoteDataSource? remoteDataSource;
  final PartnerTournamentResponse? initialTournament;

  /// Rounds from the workflow API (bracket ladder); injectable for tests.
  final List<TournamentRound> initialRounds;

  /// Review payload (financial summary); injectable for tests.
  final PartnerTournamentReviewData? initialReview;

  /// Test seams for the tab captures.
  final List<PartnerTournamentMatchResponse> initialMatches;
  final List<TournamentRegistration> initialRegistrations;

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
  List<TournamentRound> _rounds = const [];
  PartnerTournamentReviewData? _review;
  TournamentSchedule? _schedule;
  bool _isLoading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _tabIndex = widget.initialTabIndex.clamp(0, _tabs.length - 1);
    _tournament = widget.initialTournament;
    _rounds = widget.initialRounds;
    _review = widget.initialReview;
    _matches = widget.initialMatches;
    _registrations = widget.initialRegistrations;
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
      List<TournamentRound> rounds = const [];
      try {
        rounds = await _remoteDataSource.getRounds(id);
      } catch (_) {}
      TournamentSchedule? schedule;
      try {
        schedule = await _remoteDataSource.getSchedule(id);
      } catch (_) {}
      if (!mounted) return;
      setState(() {
        _tournament = tournament;
        _matches = matches;
        _registrations = registrations;
        _review = review;
        _rounds = rounds;
        _schedule = schedule;
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
    final scale = context.sportoScale;
    final tournament = _tournament;
    final loading = widget.isLoading ?? (_isLoading && tournament == null);

    return Scaffold(
      backgroundColor: t.screenBase,
      body: Column(
        children: [
          TournamentScreenHeader(
            title: tournament?.name ?? 'Tournament Details',
            subtitle: tournament == null
                ? (widget.tournamentId == null
                    ? null
                    : 'SPT-${widget.tournamentId}')
                : tournamentCode(tournament),
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
            trailing: TournamentActionPill(
              label: 'Edit',
              icon: SportoSvgIcon(SportoTournamentIcons.edit, size: 14),
              gradient: t.bluePillGradient,
              foreground: t.screenBase,
              fontWeight: FontWeight.w600,
              height: 27 * scale,
              radius: t.r10,
              padding: EdgeInsets.symmetric(horizontal: 10 * scale),
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
                        textAlign: TextAlign.center,
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
                          : formatTournamentDay(tournament.tournamentStartAt),
                    ),
                    SizedBox(height: 10 * scale),
                    TournamentUnderlineTabs(
                      labels: _tabs,
                      selectedIndex: _tabIndex,
                      onChanged: (index) => setState(() => _tabIndex = index),
                    ),
                    SizedBox(height: 14 * scale),
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
          rounds: _rounds,
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
          rounds: _rounds,
          scheduleIsPublished: _schedule?.isPublished ?? false,
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
          registrations: _registrations,
          onViewPlayer: (name, team) => Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (_) => PlayerDetailsRedesignScreen(
                playerName: name,
                teamName: team,
                tournamentName: tournament.name,
                tournamentCode: tournamentCode(tournament),
              ),
            ),
          ),
        ),
      _ => TournamentFinancialsTab(
          review: _review,
          tournament: tournament,
        ),
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
