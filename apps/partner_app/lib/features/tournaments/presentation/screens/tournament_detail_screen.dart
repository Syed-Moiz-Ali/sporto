import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:partner_data/partner_data.dart';
import 'package:ui_kit/ui_kit.dart';

import 'assign_referee_screen.dart';

// ============================================================
// MAIN TOURNAMENT DETAIL SCREEN
// ============================================================
class TournamentDetailScreen extends StatefulWidget {
  final String? tournamentId;
  final int initialTabIndex;
  final bool? isLoading;
  final PartnerRemoteDataSource? remoteDataSource;
  final PartnerTournamentResponse? initialTournament;

  const TournamentDetailScreen({
    super.key,
    this.tournamentId,
    this.initialTabIndex = 0,
    this.isLoading,
    this.remoteDataSource,
    this.initialTournament,
  });

  @override
  State<TournamentDetailScreen> createState() => _TournamentDetailScreenState();
}

class _TournamentDetailScreenState extends State<TournamentDetailScreen> {
  late int _selectedTabIndex;
  int _refereeAssignmentTab = 0;
  final List<String> _tabs = [
    'Overview',
    'Teams',
    'Referees',
    'Schedule',
    'Venues',
  ];
  final List<String?> _tabAssets = [
    null,
    SportoAssets.cricketAction,
    SportoAssets.soccer,
    SportoAssets.calendarTick,
    SportoAssets.soccer,
  ];

  late final PartnerRemoteDataSource _remoteDataSource =
      widget.remoteDataSource ??
          PartnerRemoteDataSource(
            apiClient:
                SportoApiClient(tokenProvider: AuthSessionStore().getToken),
          );

  PartnerTournamentResponse? _tournament;
  List<PartnerTournamentMatchResponse>? _apiMatches;
  final Map<int, List<PartnerMatchRefereeAssignmentResponse>> _apiAssignments =
      {};
  bool _isRefereeApiLoading = false;
  String? _refereeApiError;
  bool _isLoading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _selectedTabIndex = widget.initialTabIndex.clamp(0, _tabs.length - 1);
    if (widget.initialTournament != null) {
      _tournament = widget.initialTournament;
    }
    final shouldFetch = widget.isLoading != true &&
        widget.tournamentId != null &&
        widget.tournamentId!.isNotEmpty;
    if (shouldFetch) {
      _fetchTournamentDetails(widget.tournamentId!);
    }
  }

  Future<void> _fetchTournamentDetails(String id) async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final data = await _remoteDataSource.showTournamentData(id);
      await _fetchRefereeAssignments(_remoteDataSource, id);
      if (mounted) {
        setState(() {
          _tournament = data;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _fetchRefereeAssignments(
    PartnerRemoteDataSource ds,
    String tournamentId,
  ) async {
    if (mounted) {
      setState(() {
        _isRefereeApiLoading = true;
        _refereeApiError = null;
      });
    }
    try {
      final matches = await ds.listTournamentMatchesData(tournamentId);
      final assignments = <int, List<PartnerMatchRefereeAssignmentResponse>>{};
      for (final match in matches) {
        try {
          assignments[match.id] =
              await ds.listMatchRefereeAssignmentsData(tournamentId, match.id);
        } catch (_) {
          assignments[match.id] = const [];
        }
      }
      if (!mounted) return;
      setState(() {
        _apiMatches = matches;
        _apiAssignments
          ..clear()
          ..addAll(assignments);
        _isRefereeApiLoading = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _apiMatches = const [];
        _apiAssignments.clear();
        _refereeApiError = error.toString();
        _isRefereeApiLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final scale = context.sportoScale;

    final effectiveLoading = widget.isLoading ??
        (_isLoading || (_tournament == null && _error == null));
    final name = _tournament?.name;
    final code = _tournament?.code ??
        (widget.tournamentId != null
            ? 'SPT-${widget.tournamentId}'
            : null);

    return SportoScreenShell(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.all(8),
          child: Material(
            color: cs.surfaceContainerHigh,
            borderRadius: BorderRadius.circular(11),
            child: InkWell(
              borderRadius: BorderRadius.circular(11),
              onTap: () => Navigator.maybePop(context),
              child: Icon(Icons.arrow_back_ios_new_rounded,
                  color: cs.onSurface, size: 19),
            ),
          ),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (effectiveLoading && name == null)
              SportoShimmer(
                width: 150 * scale,
                height: 18 * scale,
                borderRadius: 4 * scale,
              )
            else
              Text(
                name ?? 'Tournament Details',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: tt.titleLarge?.copyWith(
                  fontSize: 18 * scale,
                  fontWeight: FontWeight.w600,
                  color: cs.onSurface,
                ),
              ),
            SizedBox(height: 3 * scale),
            if (effectiveLoading && code == null)
              SportoShimmer(
                width: 75 * scale,
                height: 12 * scale,
                borderRadius: 3 * scale,
              )
            else if (code != null)
              Text(
                code,
                style: TextStyle(
                  fontSize: 12 * scale,
                  color: cs.onSurfaceVariant,
                ),
              ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        physics: const ClampingScrollPhysics(),
        padding: EdgeInsets.fromLTRB(
          20 * scale,
          _selectedTabIndex == 2 ? 24 * scale : 0,
          20 * scale,
          100 * scale,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (_error != null) ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: cs.errorContainer,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'Note: Failed to load latest details from API: $_error',
                  style: TextStyle(color: cs.onErrorContainer, fontSize: 12),
                ),
              ),
              const SizedBox(height: 16),
            ],

            // Dynamic Summary Card with Shimmer
            _buildSummaryCard(cs, tt, scale, effectiveLoading),
            SizedBox(height: 28 * scale),

            if (_selectedTabIndex == 0) ...[
              _buildOverviewStats(cs, scale, effectiveLoading),
              SizedBox(height: 28 * scale),
            ],

            // Tab Navigation (Horizontal Scroll)
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: List.generate(
                  _tabs.length,
                  (i) => Padding(
                    padding: EdgeInsets.only(right: 8 * scale),
                    child: SportoTabChip(
                      label: _tabs[i],
                      asset: _tabAssets[i],
                      active: _selectedTabIndex == i,
                      onTap: () => setState(() => _selectedTabIndex = i),
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(height: 20 * scale),

            // Search Bar
            if (_selectedTabIndex != 0) ...[
              _buildSearchBar(cs),
              SizedBox(height: 24 * scale),
            ],

            // Sub-screen Content
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: _buildCurrentTabContent(cs, tt, scale, effectiveLoading),
            ),
          ],
        ),
      ),
      floatingActionButton: _selectedTabIndex == 0
          ? FloatingActionButton.extended(
              backgroundColor: context.sporto.card,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(
                    color: context.sporto.info.withValues(alpha: .55),
                    width: 5),
              ),
              icon: const SportoAssetIcon(
                SportoAssets.announcement,
                color: Colors.white,
                size: 18,
              ),
              label: const Text('Create Announcement'),
              onPressed: () {},
            )
          : null,
    );
  }

  Widget _buildSummaryCard(
    ColorScheme cs,
    TextTheme tt,
    double scale,
    bool effectiveLoading,
  ) {
    if (effectiveLoading && _tournament == null) {
      return _buildSummaryCardShimmer(cs, scale);
    }
    final statusLabel = _tournament?.workflowStatus.label ?? 'Scheduled';
    final isLive = _tournament?.status == 6;
    final registered = _tournament?.registeredTeams ?? 0;
    final maxTeams = _tournament?.maximumTeams ?? 0;
    final sportName = _tournament?.sport?.name ?? 'Sport';

    return SportoCard(
      padding: EdgeInsets.all(12 * scale),
      backgroundColor: cs.surfaceContainerHigh,
      borderColor: cs.secondary.withValues(alpha: .16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _tournament?.name ?? 'Tournament',
            style: tt.titleLarge?.copyWith(
              color: cs.onSurface,
              fontWeight: FontWeight.w600,
              fontSize: 18 * scale,
            ),
          ),
          SizedBox(height: 8 * scale),
          Row(
            children: [
              Container(
                width: 8 * scale,
                height: 8 * scale,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isLive ? Colors.redAccent : cs.secondary,
                ),
              ),
              SizedBox(width: 6 * scale),
              Text(
                statusLabel,
                style: TextStyle(
                  color: cs.onSurface,
                  fontWeight: FontWeight.w500,
                  fontSize: 12 * scale,
                ),
              ),
            ],
          ),
          SizedBox(height: 12 * scale),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                sportName,
                style: TextStyle(
                  color: cs.secondary,
                  fontWeight: FontWeight.w500,
                  fontSize: 12 * scale,
                ),
              ),
              Expanded(
                child: RichText(
                  textAlign: TextAlign.end,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  text: TextSpan(
                    style: tt.bodySmall?.copyWith(fontSize: 12 * scale),
                    children: [
                      TextSpan(
                        text: '$registered / $maxTeams ',
                        style: TextStyle(
                          color: cs.secondary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      TextSpan(
                        text: 'Teams Registered',
                        style: TextStyle(color: cs.onSurfaceVariant),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCardShimmer(ColorScheme cs, double scale) {
    return SportoCard(
      padding: EdgeInsets.all(12 * scale),
      backgroundColor: cs.surfaceContainerHigh,
      borderColor: cs.secondary.withValues(alpha: .16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SportoShimmer(
            width: 180 * scale,
            height: 18 * scale,
            borderRadius: 4 * scale,
          ),
          SizedBox(height: 10 * scale),
          Row(
            children: [
              SportoShimmer(
                width: 8 * scale,
                height: 8 * scale,
                borderRadius: 4 * scale,
              ),
              SizedBox(width: 6 * scale),
              SportoShimmer(
                width: 80 * scale,
                height: 12 * scale,
                borderRadius: 3 * scale,
              ),
            ],
          ),
          SizedBox(height: 14 * scale),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              SportoShimmer(
                width: 90 * scale,
                height: 12 * scale,
                borderRadius: 3 * scale,
              ),
              SportoShimmer(
                width: 130 * scale,
                height: 12 * scale,
                borderRadius: 3 * scale,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar(ColorScheme cs) {
    final placeholder = _selectedTabIndex == 1
        ? 'Search Teams...'
        : _selectedTabIndex == 2
            ? 'Search referees...'
            : _selectedTabIndex == 3
                ? 'Search Match...'
                : _selectedTabIndex == 4
                    ? 'Search Venue...'
                    : 'Search...';
    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: SportoCard.defaultFill.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: SportoCard.defaultBorder),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          SportoAssetIcon(SportoAssets.searchNormal,
              color: cs.onSurfaceVariant, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              placeholder,
              style:
                  TextStyle(color: cs.onSurfaceVariant.withValues(alpha: 0.6)),
            ),
          ),
          Icon(Icons.sort_rounded, color: cs.onSurfaceVariant, size: 20),
        ],
      ),
    );
  }

  Widget _buildCurrentTabContent(
    ColorScheme cs,
    TextTheme tt,
    double scale,
    bool effectiveLoading,
  ) {
    switch (_selectedTabIndex) {
      case 0:
        return _buildOverviewTab(cs, tt, scale, effectiveLoading);
      case 1:
        return _buildTeamsTab(cs, tt, scale, effectiveLoading);
      case 2:
        return _buildRefereesTab(cs, tt, scale, effectiveLoading);
      case 3:
        return _buildScheduleTab(cs, tt, scale, effectiveLoading);
      case 4:
        return _buildVenuesTab(cs, tt, scale, effectiveLoading);
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildOverviewTab(
    ColorScheme cs,
    TextTheme tt,
    double scale,
    bool effectiveLoading,
  ) {
    if (effectiveLoading && _tournament == null) {
      return _buildOverviewTabShimmer(cs, scale);
    }
    final registered = _tournament?.registeredTeams ?? 0;
    final fee = _tournament?.registrationFee ?? '0';
    final prize = _tournament?.totalPrizeMoney ?? '0';
    final venues = _tournament?.tournamentVenues ?? [];
    final liveMatches = _apiMatches?.where((m) => m.isLive).toList() ?? [];

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text('Live Matches',
          style: TextStyle(
              color: cs.onSurfaceVariant,
              fontSize: 13 * scale,
              fontWeight: FontWeight.w500)),
      SizedBox(height: 12 * scale),
      if (liveMatches.isNotEmpty)
        ...liveMatches.map((m) => Padding(
              padding: EdgeInsets.only(bottom: 12 * scale),
              child: SportoCard(
                backgroundColor: cs.surfaceContainerHigh,
                borderColor: cs.secondary.withValues(alpha: .14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(m.displayTeamA,
                            style: TextStyle(
                                color: cs.tertiary,
                                fontWeight: FontWeight.w500,
                                fontSize: 13 * scale)),
                        Text('Vs',
                            style: TextStyle(
                                color: cs.onSurfaceVariant,
                                fontSize: 12 * scale)),
                        Text(m.displayTeamB,
                            style: TextStyle(
                                color: cs.onSurfaceVariant,
                                fontSize: 13 * scale)),
                      ],
                    ),
                    SizedBox(height: 12 * scale),
                    Center(
                      child: Text(
                        m.displayRound,
                        style: TextStyle(
                            color: cs.secondary,
                            fontSize: 14 * scale,
                            fontWeight: FontWeight.w600),
                      ),
                    ),
                    SizedBox(height: 8 * scale),
                    Center(
                      child: Text(
                        'Live Now',
                        style: TextStyle(
                            color: Colors.redAccent,
                            fontSize: 13 * scale,
                            fontWeight: FontWeight.w700),
                      ),
                    ),
                    const SportoDivider(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          m.displayVenue.isNotEmpty
                              ? m.displayVenue
                              : 'Venue TBD',
                          style: TextStyle(
                              color: cs.onSurface, fontSize: 13 * scale),
                        ),
                        Text(
                          m.displayTime.isNotEmpty
                              ? _formatApiDate(m.displayTime)
                              : 'In Progress',
                          style: TextStyle(
                              color: cs.onSurfaceVariant, fontSize: 12 * scale),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ))
      else
        SportoCard(
          backgroundColor: cs.surfaceContainerHigh,
          borderColor: cs.secondary.withValues(alpha: .14),
          padding: EdgeInsets.symmetric(
              vertical: 24 * scale, horizontal: 16 * scale),
          child: Center(
            child: Text(
              'No live matches currently in progress',
              style: TextStyle(
                color: cs.onSurfaceVariant,
                fontSize: 13 * scale,
              ),
            ),
          ),
        ),
      SizedBox(height: 20 * scale),
      Text('Registration Summary',
          style: TextStyle(
              color: cs.onSurfaceVariant,
              fontSize: 13 * scale,
              fontWeight: FontWeight.w500)),
      SizedBox(height: 12 * scale),
      GridView.count(
          crossAxisCount: 4,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 8 * scale,
          crossAxisSpacing: 8 * scale,
          childAspectRatio:
              MediaQuery.sizeOf(context).width < 350 ? 1.35 : 1.68,
          children: [
            SportoStatCard(
                label: 'Registered',
                value: '$registered',
                fontSize: 18 * scale,
                labelSize: 9 * scale,
                padding: EdgeInsets.symmetric(
                    horizontal: 4 * scale, vertical: 2 * scale),
                backgroundColor: cs.surfaceContainerHigh),
            SportoStatCard(
                label: 'Approved',
                value: '$registered',
                highlight: true,
                fontSize: 18 * scale,
                labelSize: 9 * scale,
                padding: EdgeInsets.symmetric(
                    horizontal: 4 * scale, vertical: 2 * scale),
                backgroundColor: cs.surfaceContainerHigh),
            SportoStatCard(
                label: 'Pending',
                value: '0',
                color: Colors.orange,
                fontSize: 18 * scale,
                labelSize: 9 * scale,
                padding: EdgeInsets.symmetric(
                    horizontal: 4 * scale, vertical: 2 * scale),
                backgroundColor: cs.surfaceContainerHigh),
            SportoStatCard(
                label: 'Rejected',
                value: '0',
                color: Colors.redAccent,
                fontSize: 18 * scale,
                labelSize: 9 * scale,
                padding: EdgeInsets.symmetric(
                    horizontal: 4 * scale, vertical: 2 * scale),
                backgroundColor: cs.surfaceContainerHigh),
          ]),
      SizedBox(height: 24 * scale),
      Text('Venue Status',
          style: TextStyle(
              color: cs.onSurfaceVariant, fontSize: 13 * scale)),
      SizedBox(height: 10 * scale),
      if (venues.isEmpty)
        SportoCard(
          backgroundColor: cs.surfaceContainerHigh,
          padding: EdgeInsets.symmetric(
              vertical: 16 * scale, horizontal: 16 * scale),
          child: Center(
            child: Text(
              'No venues assigned to this tournament',
              style: TextStyle(
                  color: cs.onSurfaceVariant, fontSize: 13 * scale),
            ),
          ),
        )
      else
        ...venues.map((v) => Padding(
              padding: EdgeInsets.only(bottom: 10 * scale),
              child: _overviewVenueStatus(
                cs,
                'Active',
                v.venueName,
                cs.secondary,
              ),
            )),
      SizedBox(height: 20 * scale),
      Text('Finance Summary',
          style: TextStyle(
              color: cs.onSurfaceVariant,
              fontSize: 13 * scale,
              fontWeight: FontWeight.w500)),
      SizedBox(height: 12 * scale),
      GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 8 * scale,
          crossAxisSpacing: 8 * scale,
          childAspectRatio: 3.25,
          children: [
            SportoCard(
                padding: EdgeInsets.all(10 * scale),
                backgroundColor: cs.surfaceContainerHigh,
                child: SportoSummaryRow(
                    label: 'Fee', value: '₹$fee', boldValue: true)),
            SportoCard(
                padding: EdgeInsets.all(10 * scale),
                backgroundColor: cs.surfaceContainerHigh,
                child: const SportoSummaryRow(
                    label: 'Expenses', value: '₹0', boldValue: true)),
            SportoCard(
                padding: EdgeInsets.all(10 * scale),
                backgroundColor: cs.surfaceContainerHigh,
                child: SportoSummaryRow(
                    label: 'Prize Pool', value: '₹$prize', boldValue: true)),
            SportoCard(
                padding: EdgeInsets.all(10 * scale),
                backgroundColor: cs.surfaceContainerHigh,
                child: SportoSummaryRow(
                    label: 'Status',
                    value: _tournament?.workflowStatus.label ?? 'Draft',
                    boldValue: true,
                    valueColor: cs.tertiary)),
          ]),
      SizedBox(height: 20 * scale),
      _overviewProgress(cs),
    ]);
  }

  Widget _buildOverviewTabShimmer(ColorScheme cs, double scale) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SportoShimmer(
          width: 90 * scale,
          height: 13 * scale,
          borderRadius: 3 * scale,
        ),
        SizedBox(height: 12 * scale),
        SportoCard(
          backgroundColor: cs.surfaceContainerHigh,
          borderColor: cs.secondary.withValues(alpha: .14),
          padding: EdgeInsets.all(16 * scale),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  SportoShimmer(
                      width: 80 * scale, height: 14 * scale, borderRadius: 3 * scale),
                  SportoShimmer(
                      width: 24 * scale, height: 12 * scale, borderRadius: 3 * scale),
                  SportoShimmer(
                      width: 80 * scale, height: 14 * scale, borderRadius: 3 * scale),
                ],
              ),
              SizedBox(height: 16 * scale),
              SportoShimmer(
                  width: 100 * scale, height: 28 * scale, borderRadius: 4 * scale),
              SizedBox(height: 8 * scale),
              SportoShimmer(
                  width: 60 * scale, height: 12 * scale, borderRadius: 3 * scale),
              SizedBox(height: 16 * scale),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  SportoShimmer(
                      width: 110 * scale, height: 12 * scale, borderRadius: 3 * scale),
                  SportoShimmer(
                      width: 90 * scale, height: 12 * scale, borderRadius: 3 * scale),
                ],
              ),
            ],
          ),
        ),
        SizedBox(height: 20 * scale),
        SportoShimmer(
          width: 140 * scale,
          height: 13 * scale,
          borderRadius: 3 * scale,
        ),
        SizedBox(height: 12 * scale),
        GridView.count(
          crossAxisCount: 4,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 8 * scale,
          crossAxisSpacing: 8 * scale,
          childAspectRatio:
              MediaQuery.sizeOf(context).width < 350 ? 1.35 : 1.68,
          children: List.generate(
            4,
            (i) => SportoCard(
              backgroundColor: cs.surfaceContainerHigh,
              padding: EdgeInsets.symmetric(
                  horizontal: 4 * scale, vertical: 2 * scale),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SportoShimmer(
                      width: 45 * scale, height: 9 * scale, borderRadius: 2 * scale),
                  SizedBox(height: 6 * scale),
                  SportoShimmer(
                      width: 25 * scale, height: 16 * scale, borderRadius: 3 * scale),
                ],
              ),
            ),
          ),
        ),
        SizedBox(height: 20 * scale),
        SportoCard(
          backgroundColor: cs.surfaceContainerHigh,
          padding: EdgeInsets.all(16 * scale),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SportoShimmer(
                  width: 130 * scale, height: 14 * scale, borderRadius: 3 * scale),
              SizedBox(height: 14 * scale),
              for (var i = 0; i < 4; i++) ...[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    SportoShimmer(
                        width: 110 * scale,
                        height: 12 * scale,
                        borderRadius: 3 * scale),
                    SportoShimmer(
                        width: 60 * scale,
                        height: 12 * scale,
                        borderRadius: 3 * scale),
                  ],
                ),
                if (i < 3) SizedBox(height: 10 * scale),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildOverviewStats(
    ColorScheme cs,
    double scale,
    bool effectiveLoading,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Today's Overview",
          style: TextStyle(
            color: cs.onSurfaceVariant,
            fontSize: 13 * scale,
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(height: 12 * scale),
        if (effectiveLoading && _tournament == null)
          GridView.count(
            crossAxisCount: 4,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 8 * scale,
            crossAxisSpacing: 8 * scale,
            childAspectRatio:
                MediaQuery.sizeOf(context).width < 350 ? 1.0 : 1.22,
            children: List.generate(
              4,
              (i) => SportoCard(
                backgroundColor: cs.surfaceContainerHigh,
                padding: EdgeInsets.symmetric(
                    horizontal: 6 * scale, vertical: 6 * scale),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SportoShimmer(
                      width: 42 * scale,
                      height: 9 * scale,
                      borderRadius: 2 * scale,
                    ),
                    SizedBox(height: 6 * scale),
                    SportoShimmer(
                      width: 24 * scale,
                      height: 16 * scale,
                      borderRadius: 3 * scale,
                    ),
                  ],
                ),
              ),
            ),
          )
        else
          GridView.count(
            crossAxisCount: 4,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 8 * scale,
            crossAxisSpacing: 8 * scale,
            childAspectRatio:
                MediaQuery.sizeOf(context).width < 350 ? 1.0 : 1.22,
            children: [
              SportoStatCard(
                label: "Today's\nMatches",
                value: '${_tournament?.tournamentVenues.length ?? 0}',
                fontSize: 18 * scale,
                labelSize: 9 * scale,
                padding: EdgeInsets.symmetric(
                    horizontal: 4 * scale, vertical: 2 * scale),
                backgroundColor: cs.surfaceContainerHigh,
              ),
              SportoStatCard(
                label: 'Live Now',
                value: '${_tournament?.status == 6 ? 1 : 0}',
                highlight: true,
                fontSize: 18 * scale,
                labelSize: 9 * scale,
                padding: EdgeInsets.symmetric(
                    horizontal: 4 * scale, vertical: 2 * scale),
                backgroundColor: cs.surfaceContainerHigh,
              ),
              SportoStatCard(
                label: 'Completed',
                value: '${_tournament?.status == 7 ? 1 : 0}',
                fontSize: 18 * scale,
                labelSize: 9 * scale,
                padding: EdgeInsets.symmetric(
                    horizontal: 4 * scale, vertical: 2 * scale),
                backgroundColor: cs.surfaceContainerHigh,
              ),
              SportoStatCard(
                label: 'Delayed',
                value: '0',
                fontSize: 18 * scale,
                labelSize: 9 * scale,
                padding: EdgeInsets.symmetric(
                    horizontal: 4 * scale, vertical: 2 * scale),
                backgroundColor: cs.surfaceContainerHigh,
              ),
            ],
          ),
      ],
    );
  }

  Widget _overviewVenueStatus(
          ColorScheme cs, String status, String ground, Color color) =>
      SizedBox(
        height: 54,
        child: SportoCard(
            padding: const EdgeInsets.all(10),
            backgroundColor: cs.surfaceContainerHigh,
            child: Row(children: [
              Container(
                  width: 8,
                  height: 8,
                  decoration:
                      BoxDecoration(color: color, shape: BoxShape.circle)),
              const SizedBox(width: 8),
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(status,
                    style: TextStyle(color: cs.onSurface, fontSize: 12)),
                Text(ground,
                    style: TextStyle(color: cs.secondary, fontSize: 11)),
              ]),
            ])),
      );

  Widget _overviewProgress(ColorScheme cs) {
    final maxTeams = _tournament?.maximumTeams ?? 128;
    final rows = [
      ('Registration Closed', '$maxTeams Teams'),
      ('Round of $maxTeams', '${maxTeams ~/ 2} Teams'),
      ('Quarter Finals', '🔒 Locked'),
      ('Semi Finals', '🔒 Locked'),
      ('Final', '🔒 Locked')
    ];
    return SportoCard(
        backgroundColor: cs.surfaceContainerHigh,
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Tournament Progress',
              style: TextStyle(color: cs.onSurfaceVariant)),
          const SizedBox(height: 14),
          for (final row in rows)
            Padding(
                padding: const EdgeInsets.only(bottom: 9),
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(row.$1,
                          style: TextStyle(color: cs.secondary, fontSize: 12)),
                      Text(row.$2,
                          style: TextStyle(
                              color: cs.onSurfaceVariant, fontSize: 11)),
                    ])),
        ]));
  }

  // ============================================================
  // TAB 2: TEAMS
  // ============================================================
  Widget _buildTeamsTab(
    ColorScheme cs,
    TextTheme tt,
    double scale,
    bool effectiveLoading,
  ) {
    if (effectiveLoading && _tournament == null) {
      return _buildTeamsTabShimmer(cs, scale);
    }
    final registered = _tournament?.registeredTeams ?? 0;
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(children: [
            const SportoFilterChip(label: 'All', active: true),
            SizedBox(width: 8 * scale),
            const SportoFilterChip(label: 'Approved'),
            SizedBox(width: 8 * scale),
            const SportoFilterChip(label: 'Pending'),
            SizedBox(width: 8 * scale),
            const SportoFilterChip(label: 'Payment Pending'),
            SizedBox(width: 8 * scale),
            const SportoFilterChip(label: 'Rejected'),
          ])),
      SizedBox(height: 16 * scale),
      SportoCard(
        backgroundColor: cs.surfaceContainerHigh,
        padding: EdgeInsets.symmetric(
            vertical: 24 * scale, horizontal: 16 * scale),
        child: Center(
          child: Text(
            registered > 0
                ? '$registered teams registered for this tournament'
                : 'No teams registered yet',
            style: TextStyle(
              color: cs.onSurfaceVariant,
              fontSize: 13 * scale,
            ),
          ),
        ),
      ),
    ]);
  }

  Widget _buildTeamsTabShimmer(ColorScheme cs, double scale) {
    return Column(
      children: [
        for (var i = 0; i < 3; i++) ...[
          SportoCard(
            padding: EdgeInsets.all(12 * scale),
            backgroundColor: cs.surfaceContainerHigh,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    SportoShimmer(
                        width: 40 * scale,
                        height: 40 * scale,
                        borderRadius: 10 * scale),
                    SizedBox(width: 12 * scale),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SportoShimmer(
                              width: 120 * scale,
                              height: 16 * scale,
                              borderRadius: 4 * scale),
                          SizedBox(height: 6 * scale),
                          SportoShimmer(
                              width: 90 * scale,
                              height: 12 * scale,
                              borderRadius: 3 * scale),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 12 * scale),
                Row(
                  children: [
                    SportoShimmer(
                        width: 50 * scale,
                        height: 20 * scale,
                        borderRadius: 6 * scale),
                    SizedBox(width: 8 * scale),
                    SportoShimmer(
                        width: 70 * scale,
                        height: 20 * scale,
                        borderRadius: 6 * scale),
                    const Spacer(),
                    SportoShimmer(
                        width: 80 * scale,
                        height: 16 * scale,
                        borderRadius: 4 * scale),
                  ],
                ),
              ],
            ),
          ),
          if (i < 2) SizedBox(height: 12 * scale),
        ],
      ],
    );
  }

  // ============================================================
  // TAB 3: REFEREES
  // ============================================================
  Widget _buildRefereesTab(
    ColorScheme cs,
    TextTheme tt,
    double scale,
    bool effectiveLoading,
  ) {
    return _buildApiRefereesTab(cs, scale, effectiveLoading);
  }

  Widget _buildApiRefereesTab(
    ColorScheme cs,
    double scale,
    bool effectiveLoading,
  ) {
    final loading = effectiveLoading || _isRefereeApiLoading;
    final assigned = _refereeAssignmentTab == 0;
    final matches = (_apiMatches ?? const <PartnerTournamentMatchResponse>[])
        .where((match) =>
            (_apiAssignments[match.id]?.isNotEmpty ?? false) == assigned)
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            _refereeTab('Assigned', 0, cs),
            const SizedBox(width: 34),
            _refereeTab('Pending', 1, cs),
          ],
        ),
        const SizedBox(height: 21),
        Row(
          children: [
            Text('Sort by |', style: TextStyle(color: cs.onSurfaceVariant)),
            const SizedBox(width: 8),
            Text('Venues', style: TextStyle(color: cs.secondary)),
            const SizedBox(width: 20),
            Text('Date', style: TextStyle(color: cs.onSurfaceVariant)),
          ],
        ),
        if (_refereeApiError != null) ...[
          const SizedBox(height: 16),
          SportoCard(
            child: Text(
              'Unable to load live referee data: $_refereeApiError',
              style: TextStyle(color: cs.error, fontSize: 12),
            ),
          ),
        ],
        const SizedBox(height: 24),
        if (loading && _apiMatches == null)
          _buildRefereesTabShimmer(cs, scale)
        else if (matches.isEmpty)
          SportoCard(
            child: Text(
              assigned
                  ? 'No assigned referees found.'
                  : 'No pending referee assignments found.',
              style: TextStyle(color: cs.onSurfaceVariant, fontSize: 12),
            ),
          )
        else
          for (var i = 0; i < matches.length; i++) ...[
            _apiRefereeMatchCard(matches[i], assigned: assigned, cs: cs),
            if (i != matches.length - 1) const SizedBox(height: 10),
          ],
      ],
    );
  }

  Widget _buildRefereesTabShimmer(ColorScheme cs, double scale) {
    return Column(
      children: [
        for (var i = 0; i < 3; i++) ...[
          SportoCard(
            radius: 15 * scale,
            padding: EdgeInsets.fromLTRB(
                14 * scale, 12 * scale, 14 * scale, 12 * scale),
            backgroundColor: const Color(0xE817191F),
            borderColor: const Color(0x192F3A48),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    SportoShimmer(
                        width: 14 * scale,
                        height: 14 * scale,
                        borderRadius: 3 * scale),
                    SizedBox(width: 6 * scale),
                    SportoShimmer(
                        width: 80 * scale,
                        height: 12 * scale,
                        borderRadius: 3 * scale),
                    const Spacer(),
                    SportoShimmer(
                        width: 90 * scale,
                        height: 11 * scale,
                        borderRadius: 3 * scale),
                  ],
                ),
                SizedBox(height: 6 * scale),
                Row(
                  children: [
                    SportoShimmer(
                        width: 12 * scale,
                        height: 12 * scale,
                        borderRadius: 2 * scale),
                    SizedBox(width: 6 * scale),
                    SportoShimmer(
                        width: 120 * scale,
                        height: 12 * scale,
                        borderRadius: 3 * scale),
                  ],
                ),
                const SportoDivider(height: 18),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    SportoShimmer(
                        width: 70 * scale,
                        height: 11 * scale,
                        borderRadius: 3 * scale),
                    SportoShimmer(
                        width: 20 * scale,
                        height: 10 * scale,
                        borderRadius: 2 * scale),
                    SportoShimmer(
                        width: 70 * scale,
                        height: 11 * scale,
                        borderRadius: 3 * scale),
                  ],
                ),
                SizedBox(height: 12 * scale),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    SportoShimmer(
                        width: 100 * scale,
                        height: 12 * scale,
                        borderRadius: 3 * scale),
                    SportoShimmer(
                        width: 90 * scale,
                        height: 28 * scale,
                        borderRadius: 14 * scale),
                  ],
                ),
              ],
            ),
          ),
          if (i < 2) SizedBox(height: 10 * scale),
        ],
      ],
    );
  }

  Widget _refereeTab(String label, int index, ColorScheme cs) {
    final active = _refereeAssignmentTab == index;
    return InkWell(
      onTap: () => setState(() => _refereeAssignmentTab = index),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
        child: Column(
          children: [
            Text(
              label,
              style: TextStyle(
                color: active ? cs.primary : cs.onSurfaceVariant,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 8),
            AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              width: active ? 20 : 0,
              height: 3,
              decoration: BoxDecoration(
                color: cs.primary,
                borderRadius: BorderRadius.circular(3),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _apiRefereeMatchCard(
    PartnerTournamentMatchResponse match, {
    required bool assigned,
    required ColorScheme cs,
  }) {
    final assignment = (_apiAssignments[match.id] ?? const []).isNotEmpty
        ? _apiAssignments[match.id]!.first
        : null;
    final isAssigned = assigned && assignment != null;
    return SportoCard(
      radius: 15,
      blur: 0,
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
      backgroundColor: const Color(0xE817191F),
      borderColor: const Color(0x192F3A48),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.sports_cricket_rounded,
                  color: cs.onSurfaceVariant, size: 15),
              const SizedBox(width: 4),
              Text(match.displayRound,
                  style: TextStyle(color: cs.onSurfaceVariant, fontSize: 12)),
              const Spacer(),
              if (match.displayTime.isNotEmpty)
                Text(_formatApiDate(match.displayTime),
                    style: TextStyle(color: cs.onSurfaceVariant, fontSize: 11)),
              Icon(Icons.more_vert_rounded,
                  color: cs.onSurfaceVariant, size: 20),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              SportoAssetIcon(SportoAssets.locationPin,
                  size: 13, color: cs.secondary),
              const SizedBox(width: 4),
              Expanded(
                child: Text(match.displayVenue,
                    style: TextStyle(color: cs.secondary, fontSize: 12)),
              ),
            ],
          ),
          const SportoDivider(height: 18),
          if (isAssigned) ...[
            Row(
              children: [
                Expanded(
                  child: Text(assignment.displayName,
                      style:
                          const TextStyle(color: Colors.white, fontSize: 13)),
                ),
                Text(assignment.displayRole,
                    style: TextStyle(color: cs.onSurfaceVariant, fontSize: 11)),
              ],
            ),
            const SportoDivider(height: 18),
          ],
          Row(
            children: [
              Text(match.displayTeamA,
                  style: TextStyle(color: cs.onSurfaceVariant, fontSize: 11)),
              const Spacer(),
              Text('Vs',
                  style: TextStyle(color: cs.onSurfaceVariant, fontSize: 10)),
              const Spacer(),
              Text(match.displayTeamB,
                  style: TextStyle(color: cs.onSurfaceVariant, fontSize: 11)),
            ],
          ),
          const SizedBox(height: 10),
          if (isAssigned)
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                SportoPillButton(
                  label: 'Reassign',
                  color: cs.primary,
                  height: 28,
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  fontSize: 11,
                  onTap: () => _openApiRefereePicker(match),
                ),
                const SizedBox(width: 12),
                SportoPillButton(
                  label: 'Remove Referee',
                  color: Colors.redAccent,
                  height: 28,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  fontSize: 11,
                  onTap: () => _removeApiAssignment(match, assignment),
                ),
              ],
            )
          else
            Row(
              children: [
                Text('Referee: ',
                    style: TextStyle(color: cs.onSurfaceVariant, fontSize: 12)),
                const Text('Not Assigned',
                    style: TextStyle(color: Colors.redAccent, fontSize: 12)),
                const Spacer(),
                SportoPillButton(
                  label: 'Assign Referee',
                  color: cs.primary,
                  gradient: LinearGradient(colors: [cs.primary, cs.tertiary]),
                  filled: true,
                  foregroundColor: Colors.black,
                  height: 28,
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  fontSize: 11,
                  onTap: () => _openApiRefereePicker(match),
                ),
              ],
            ),
        ],
      ),
    );
  }

  Future<void> _openApiRefereePicker(
    PartnerTournamentMatchResponse match,
  ) async {
    if (widget.tournamentId == null) return;
    final selected = await Navigator.of(context).push<String>(
      MaterialPageRoute(
        builder: (_) => AssignRefereeScreen(
          tournamentName: _tournament?.name ?? 'Tournament',
          tournamentCode: _tournament?.code ??
              (widget.tournamentId != null ? 'SPT-${widget.tournamentId}' : ''),
          tournamentId: widget.tournamentId,
          matchId: match.id,
          match: match,
        ),
      ),
    );
    if (selected == null || !mounted) return;
    await _fetchRefereeAssignments(_remoteDataSource, widget.tournamentId!);
    setState(() => _refereeAssignmentTab = 0);
  }

  Future<void> _removeApiAssignment(
    PartnerTournamentMatchResponse match,
    PartnerMatchRefereeAssignmentResponse assignment,
  ) async {
    if (widget.tournamentId == null) return;
    try {
      await _remoteDataSource.removeMatchRefereeAssignment(
        widget.tournamentId!,
        match.id,
        assignment.id,
      );
      await _fetchRefereeAssignments(_remoteDataSource, widget.tournamentId!);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Referee removed from match.')),
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Unable to remove referee: $error')),
      );
    }
  }

  // ============================================================
  // TAB 4: VENUES (DYNAMIC FROM API)
  // ============================================================
  Widget _buildVenuesTab(
    ColorScheme cs,
    TextTheme tt,
    double scale,
    bool effectiveLoading,
  ) {
    if (effectiveLoading && _tournament == null) {
      return _buildVenuesTabShimmer(cs, scale);
    }
    final venues = _tournament?.tournamentVenues ?? [];

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(children: [
            const SportoFilterChip(label: 'All', active: true),
            SizedBox(width: 8 * scale),
            const SportoFilterChip(label: 'Live'),
            SizedBox(width: 8 * scale),
            const SportoFilterChip(label: 'Preparing'),
            SizedBox(width: 8 * scale),
            const SportoFilterChip(label: 'Available'),
          ])),
      SizedBox(height: 16 * scale),
      if (venues.isEmpty)
        SportoCard(
          backgroundColor: cs.surfaceContainerHigh,
          padding: EdgeInsets.symmetric(
              vertical: 24 * scale, horizontal: 16 * scale),
          child: Center(
            child: Text(
              'No venues assigned to this tournament yet',
              style: TextStyle(
                color: cs.onSurfaceVariant,
                fontSize: 13 * scale,
              ),
            ),
          ),
        )
      else
        ...venues.map((v) => Padding(
              padding: EdgeInsets.only(bottom: 12 * scale),
              child: _VenueCard(
                name: v.venueName,
                subName: v.location ?? 'Ground Location',
                status: 'Active',
                statusColor: cs.secondary,
                startsIn: v.startTime,
                actionLabel: 'View Venue',
                actionColor: cs.tertiary,
              ),
            )),
    ]);
  }

  Widget _buildVenuesTabShimmer(ColorScheme cs, double scale) {
    return Column(
      children: [
        for (var i = 0; i < 2; i++) ...[
          SportoCard(
            backgroundColor: cs.surfaceContainerHigh,
            padding: EdgeInsets.all(12 * scale),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        SportoShimmer(
                            width: 14 * scale,
                            height: 14 * scale,
                            borderRadius: 2 * scale),
                        SizedBox(width: 6 * scale),
                        SportoShimmer(
                            width: 110 * scale,
                            height: 16 * scale,
                            borderRadius: 4 * scale),
                      ],
                    ),
                    SportoShimmer(
                        width: 60 * scale,
                        height: 14 * scale,
                        borderRadius: 4 * scale),
                  ],
                ),
                SizedBox(height: 6 * scale),
                SportoShimmer(
                    width: 140 * scale,
                    height: 12 * scale,
                    borderRadius: 3 * scale),
              ],
            ),
          ),
          if (i < 1) SizedBox(height: 12 * scale),
        ],
      ],
    );
  }

  Widget _VenueCard({
    required String name,
    required String subName,
    required String status,
    required Color statusColor,
    String? match,
    String? startsIn,
    required String actionLabel,
    required Color actionColor,
  }) {
    return Builder(builder: (context) {
      final cs = Theme.of(context).colorScheme;
      return SportoCard(
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Row(children: [
            SportoAssetIcon(SportoAssets.locationPin,
                color: cs.onSurfaceVariant, size: 18),
            const SizedBox(width: 6),
            Text(name,
                style: TextStyle(
                    color: cs.onSurface,
                    fontWeight: FontWeight.w600,
                    fontSize: 16)),
          ]),
          Row(children: [
            Container(
                width: 8,
                height: 8,
                decoration:
                    BoxDecoration(shape: BoxShape.circle, color: statusColor)),
            const SizedBox(width: 6),
            Text(status,
                style:
                    TextStyle(color: statusColor, fontWeight: FontWeight.w600)),
          ]),
        ]),
        const SizedBox(height: 4),
        Text(subName,
            style: TextStyle(color: cs.onSurfaceVariant, fontSize: 12)),
        if (match != null) ...[
          const SizedBox(height: 12),
          const SportoDivider(height: 1),
          const SizedBox(height: 12),
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text(match.split(' Vs ')[0],
                style:
                    TextStyle(color: cs.tertiary, fontWeight: FontWeight.w500)),
            Text('Vs', style: TextStyle(color: cs.onSurfaceVariant)),
            Text(match.split(' Vs ')[1],
                style: TextStyle(color: cs.onSurfaceVariant)),
          ]),
        ],
      ]));
    });
  }

  // ============================================================
  // TAB 5: SCHEDULE (DYNAMIC FROM API)
  // ============================================================
  Widget _buildScheduleTab(
    ColorScheme cs,
    TextTheme tt,
    double scale,
    bool effectiveLoading,
  ) {
    if (effectiveLoading && _apiMatches == null) {
      return _buildScheduleTabShimmer(cs, scale);
    }
    final matches = _apiMatches ?? const [];

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(children: [
            const SportoFilterChip(label: 'All', active: true),
            SizedBox(width: 8 * scale),
            const SportoFilterChip(label: 'Live'),
            SizedBox(width: 8 * scale),
            const SportoFilterChip(label: 'Upcoming'),
            SizedBox(width: 8 * scale),
            const SportoFilterChip(label: 'Completed'),
          ])),
      SizedBox(height: 16 * scale),
      if (matches.isEmpty)
        SportoCard(
          backgroundColor: cs.surfaceContainerHigh,
          padding: EdgeInsets.symmetric(
              vertical: 24 * scale, horizontal: 16 * scale),
          child: Center(
            child: Text(
              'No scheduled matches found for this tournament',
              style: TextStyle(
                color: cs.onSurfaceVariant,
                fontSize: 13 * scale,
              ),
            ),
          ),
        )
      else
        for (final m in matches) ...[
          Padding(
            padding: EdgeInsets.only(bottom: 12 * scale),
            child: _ScheduleCard(
              time: m.displayTime.isNotEmpty
                  ? _formatApiDate(m.displayTime)
                  : 'Schedule Pending',
              ground: m.displayVenue.isNotEmpty ? m.displayVenue : 'Venue TBD',
              match: '${m.displayTeamA} Vs ${m.displayTeamB}',
              captain: m.displayRound,
              action: 'View Details',
            ),
          ),
        ],
    ]);
  }

  Widget _buildScheduleTabShimmer(ColorScheme cs, double scale) {
    return Column(
      children: [
        for (var i = 0; i < 3; i++) ...[
          SportoCard(
            backgroundColor: cs.surfaceContainerHigh,
            padding: EdgeInsets.all(12 * scale),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    SportoShimmer(
                        width: 100 * scale,
                        height: 12 * scale,
                        borderRadius: 3 * scale),
                    SportoShimmer(
                        width: 80 * scale,
                        height: 12 * scale,
                        borderRadius: 3 * scale),
                  ],
                ),
                SizedBox(height: 12 * scale),
                SportoShimmer(
                    width: 160 * scale,
                    height: 15 * scale,
                    borderRadius: 4 * scale),
                SizedBox(height: 12 * scale),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    SportoShimmer(
                        width: 80 * scale,
                        height: 12 * scale,
                        borderRadius: 3 * scale),
                    SportoShimmer(
                        width: 80 * scale,
                        height: 26 * scale,
                        borderRadius: 12 * scale),
                  ],
                ),
              ],
            ),
          ),
          if (i < 2) SizedBox(height: 12 * scale),
        ],
      ],
    );
  }

  Widget _ScheduleCard({
    required String time,
    required String ground,
    required String match,
    required String captain,
    required String action,
    Color? actionColor,
  }) {
    return Builder(builder: (context) {
      final cs = Theme.of(context).colorScheme;
      return SportoCard(
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Row(children: [
            SportoAssetIcon(SportoAssets.locationPin,
                size: 14, color: cs.onSurfaceVariant),
            const SizedBox(width: 4),
            Text(ground, style: TextStyle(color: cs.onSurfaceVariant))
          ]),
          Text(time,
              style: TextStyle(color: cs.onSurfaceVariant, fontSize: 12)),
        ]),
        const SizedBox(height: 12),
        Text(match,
            style: TextStyle(
                color: cs.onSurface,
                fontWeight: FontWeight.w600,
                fontSize: 15)),
        const SizedBox(height: 12),
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text(captain,
              style: TextStyle(color: cs.onSurfaceVariant, fontSize: 12)),
          Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                  color: (actionColor ?? cs.secondary).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12)),
              child: Text(action,
                  style: TextStyle(
                      color: actionColor ?? cs.secondary,
                      fontWeight: FontWeight.w500,
                      fontSize: 12))),
        ]),
      ]));
    });
  }
}

String _formatApiDate(String value) {
  final parsed = DateTime.tryParse(value);
  if (parsed == null) return value;
  final hour = parsed.hour == 0
      ? 12
      : parsed.hour > 12
          ? parsed.hour - 12
          : parsed.hour;
  final minute = parsed.minute.toString().padLeft(2, '0');
  final suffix = parsed.hour >= 12 ? 'PM' : 'AM';
  return '${parsed.day} ${_monthName(parsed.month)}, $hour:$minute $suffix';
}

String _monthName(int month) {
  const names = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];
  return names[(month - 1).clamp(0, names.length - 1)];
}
