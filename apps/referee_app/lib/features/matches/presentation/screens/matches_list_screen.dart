import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:referee_data/referee_data.dart';
import 'package:ui_kit/ui_kit.dart';

import '../../../../app/router/app_router.dart';
import '../../../../core/di/dependency_injector.dart';

/// Exact Figma implementation of the Matches List Screen based on `figma/matches.json`.
///
/// Features:
/// - Obsidian canvas `#0E0C08` with dual blurred atmospheric ambient glow orbs
/// - Top linear gradient backdrop (Rectangle 6011: 390x129)
/// - Exact Header Bar (Frame 1000003337: Title "Today's Matches" + Blue gradient subtitle count)
/// - Glassmorphic Filter Tab Bar (Frame 1261154332 -> Frame 43932) with All, Upcoming, Live, Completed, Requests
/// - Exact Live Match Card (Section 1: 350x203, radius 16, red ambient fill, pulsing dot, batter/bowler, duration, Continue Scoring)
/// - Exact Upcoming Match Card (Section 2: 350x180, radius 14, green stage, checklist status, countdown, Verify Teams)
/// - Exact Completed Match Card (Section 3: 350x168, radius 14, green stage, scores, winner banner, View Report)
/// - Exact Delayed Match Card (Section 4: 350x197, radius 14, weather alert banner, resume time, Update Status)
/// - Exact Request Card for referee match assignments with Accept/Reject actions
/// - High-fidelity animated Skeleton Shimmer during data loading
/// - Clean Empty State Card when no matches exist for selected filter
/// - Zero hardcoded `fontFamily: "packages/ui_kit/Quicksand"`, fully inherited from global theme
class MatchesListScreen extends StatefulWidget {
  final Future<RefereeMatchesPayload>? payloadFuture;

  const MatchesListScreen({
    super.key,
    this.payloadFuture,
  });

  @override
  State<MatchesListScreen> createState() => _MatchesListScreenState();
}

class _MatchesListScreenState extends State<MatchesListScreen> {
  static const List<String> _baseTabs = [
    'All',
    'Upcoming',
    'Live',
    'Completed',
  ];

  int _selectedTab =
      0; // 0: All, 1: Upcoming, 2: Live, 3: Completed, 4: Requests
  late Future<RefereeMatchesPayload> _future;
  int? _processingRequestId;

  RefereeRemoteDataSource get _remote =>
      DependencyInjector.instance.refereeRemoteDataSource;

  @override
  void initState() {
    super.initState();
    _future = widget.payloadFuture ?? _load();
  }

  Future<RefereeMatchesPayload> _load() async {
    final requests = await _remote.listMatchRequestsData();
    final matches = await _remote.listMyMatchesData(perPage: 50);
    return RefereeMatchesPayload(
      requests: requests,
      matches: matches,
    );
  }

  Future<void> _refresh() async {
    setState(() {
      _future = _load();
    });
    await _future;
  }

  Future<void> _accept(RefereeMatchRequestResponse request) async {
    final requestId = request.assignmentId ?? request.id;
    if (_processingRequestId != null) return;
    setState(() => _processingRequestId = requestId);
    try {
      await _remote.acceptMatchRequest(requestId);
      if (!mounted) return;
      _showSnack('Match request accepted.');
      setState(() => _selectedTab = 0);
      await _refresh();
    } catch (error) {
      if (mounted) _showSnack('Unable to accept match request: $error');
    } finally {
      if (mounted) setState(() => _processingRequestId = null);
    }
  }

  Future<void> _reject(RefereeMatchRequestResponse request) async {
    final requestId = request.assignmentId ?? request.id;
    if (_processingRequestId != null) return;
    setState(() => _processingRequestId = requestId);
    try {
      await _remote.rejectMatchRequest(requestId);
      if (!mounted) return;
      _showSnack('Match request rejected.');
      await _refresh();
    } catch (error) {
      if (mounted) _showSnack('Unable to reject match request: $error');
    } finally {
      if (mounted) setState(() => _processingRequestId = null);
    }
  }

  Future<void> _showMatchDetails(RefereeMatchResponse match) async {
    try {
      final detail = await _remote.showMyMatchData(match.id);
      if (!mounted) return;
      showModalBottomSheet<void>(
        context: context,
        backgroundColor: const Color(0xFF151B24),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        builder: (_) => _FigmaMatchDetailsSheet(match: detail),
      );
    } catch (error) {
      if (!mounted) return;
      _showSnack('Unable to open match details: $error');
    }
  }

  void _showSnack(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  List<RefereeMatchResponse> _filterMatches(
    List<RefereeMatchResponse> matches,
    int tabIndex,
  ) {
    return switch (tabIndex) {
      1 => matches.where((m) => m.isUpcoming).toList(),
      2 => matches.where((m) => m.isLive).toList(),
      3 => matches.where((m) => m.isCompleted).toList(),
      _ => matches,
    };
  }

  @override
  Widget build(BuildContext context) {
    final scale = context.sportoScale;

    return Scaffold(
      backgroundColor: const Color(0xFF0E0C08),
      body: Stack(
        children: [
          // ====================================================
          // ATMOSPHERE & BACKGROUND GLOW (Figma exact tokens)
          // ====================================================

          // Top Linear Gradient Backdrop (Rectangle 6011: 390x129)
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: 129 * scale,
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0xFF090C10),
                    Color(0xFF1B2335),
                    Color(0xFF090C10),
                  ],
                  stops: [0.0, 0.5, 1.0],
                ),
              ),
            ),
          ),

          // Ambient Glow Ellipse 17 (Top)
          Positioned(
            top: -40 * scale,
            left: -40 * scale,
            width: 376.9 * scale,
            height: 280 * scale,
            child: ImageFiltered(
              imageFilter: ImageFilter.blur(
                sigmaX: 85 * scale,
                sigmaY: 85 * scale,
              ),
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFF363E51).withValues(alpha: 0.30),
                ),
              ),
            ),
          ),

          // Ambient Glow Ellipse 18 (Lower body)
          Positioned(
            top: 350 * scale,
            right: -50 * scale,
            width: 376.9 * scale,
            height: 280 * scale,
            child: ImageFiltered(
              imageFilter: ImageFilter.blur(
                sigmaX: 85 * scale,
                sigmaY: 85 * scale,
              ),
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFF363E51).withValues(alpha: 0.30),
                ),
              ),
            ),
          ),

          // ====================================================
          // FOREGROUND CONTENT
          // ====================================================
          SafeArea(
            bottom: false,
            child: FutureBuilder<RefereeMatchesPayload>(
              future: _future,
              builder: (context, snapshot) {
                final isLoading =
                    snapshot.connectionState == ConnectionState.waiting;
                final payload = snapshot.data ?? const RefereeMatchesPayload();

                // Compute dynamic tab labels
                final hasRequests = payload.requests.isNotEmpty;
                final tabs = [
                  ..._baseTabs,
                  if (hasRequests || _selectedTab == 4)
                    'Requests (${payload.requests.length})',
                ];

                final isRequestsTab = _selectedTab == 4 ||
                    (_selectedTab == tabs.length - 1 && hasRequests);
                final visibleMatches =
                    _filterMatches(payload.matches, _selectedTab);
                final count = isRequestsTab
                    ? payload.requests.length
                    : payload.matches.length;

                return RefreshIndicator(
                  onRefresh: () async => _refresh(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header Bar (Frame 1000003337: 350x43)
                      _FigmaMatchesHeader(
                        scale: scale,
                        isRequestsTab: isRequestsTab,
                        count: count,
                        onBack: Navigator.of(context).canPop()
                            ? () => context.pop()
                            : null,
                      ),

                      SizedBox(height: 12 * scale),

                      // Filter Tab Bar (Frame 1261154332 -> Frame 43932)
                      _FigmaFilterTabBar(
                        scale: scale,
                        tabs: tabs,
                        selectedIndex:
                            _selectedTab < tabs.length ? _selectedTab : 0,
                        onTabSelected: (index) {
                          setState(() => _selectedTab = index);
                        },
                      ),

                      SizedBox(height: 14 * scale),

                      // Scrollable Match List
                      Expanded(
                        child: Builder(
                          builder: (context) {
                            if (isLoading) {
                              return _FigmaMatchesListSkeletonShimmer(
                                scale: scale,
                              );
                            }

                            if (snapshot.hasError) {
                              return _FigmaErrorCard(
                                scale: scale,
                                message: snapshot.error.toString(),
                                onRetry: _refresh,
                              );
                            }

                            if (isRequestsTab) {
                              if (payload.requests.isEmpty) {
                                return _FigmaEmptyMatchesCard(
                                  scale: scale,
                                  title: 'No Match Requests',
                                  subtitle:
                                      'New assignment invitations will appear here.',
                                );
                              }

                              return ListView.separated(
                                physics: const AlwaysScrollableScrollPhysics(
                                  parent: BouncingScrollPhysics(),
                                ),
                                padding: EdgeInsets.fromLTRB(
                                  20 * scale,
                                  4 * scale,
                                  20 * scale,
                                  30 * scale,
                                ),
                                itemCount: payload.requests.length,
                                separatorBuilder: (_, __) =>
                                    SizedBox(height: 14 * scale),
                                itemBuilder: (context, index) {
                                  final req = payload.requests[index];
                                  return _FigmaRequestMatchCard(
                                    scale: scale,
                                    request: req,
                                    onAccept: () => _accept(req),
                                    onReject: () => _reject(req),
                                    isProcessing: _processingRequestId ==
                                        (req.assignmentId ?? req.id),
                                  );
                                },
                              );
                            }

                            if (visibleMatches.isEmpty) {
                              return _FigmaEmptyMatchesCard(
                                scale: scale,
                                title: 'No Assigned Matches',
                                subtitle: switch (_selectedTab) {
                                  1 => 'No upcoming matches scheduled.',
                                  2 => 'No matches currently live.',
                                  3 => 'No completed matches recorded yet.',
                                  _ =>
                                    'Enjoy your day! No matches assigned yet.',
                                },
                              );
                            }

                            return ListView.separated(
                              physics: const AlwaysScrollableScrollPhysics(
                                parent: BouncingScrollPhysics(),
                              ),
                              padding: EdgeInsets.fromLTRB(
                                20 * scale,
                                4 * scale,
                                20 * scale,
                                30 * scale,
                              ),
                              itemCount: visibleMatches.length,
                              separatorBuilder: (_, __) =>
                                  SizedBox(height: 14 * scale),
                              itemBuilder: (context, index) {
                                final match = visibleMatches[index];

                                // Determine card variation based on status
                                if (match.isLive) {
                                  return _FigmaLiveMatchCard(
                                    scale: scale,
                                    match: match,
                                    onContinueScoring: () {
                                      context.push(
                                        '${AppRouter.liveScoringRoute}?matchId=${match.id}&matchCode=SPT-${match.id}',
                                      );
                                    },
                                  );
                                } else if (match.isCompleted) {
                                  return _FigmaCompletedMatchCard(
                                    scale: scale,
                                    match: match,
                                    onViewReport: () =>
                                        _showMatchDetails(match),
                                  );
                                } else if (match.isDelayed) {
                                  return _FigmaDelayedMatchCard(
                                    scale: scale,
                                    match: match,
                                    onUpdateStatus: () {
                                      context.push(
                                        '${AppRouter.matchVerificationRoute}?matchId=${match.id}',
                                      );
                                    },
                                  );
                                } else {
                                  // Default: Upcoming / Pre-match card with status-driven actions
                                  return _FigmaUpcomingMatchCard(
                                    scale: scale,
                                    match: match,
                                    onVerifyTeams: () {
                                      context.push(
                                        '${AppRouter.matchVerificationRoute}?matchId=${match.id}',
                                      );
                                    },
                                    onConductToss: () {
                                      context.push(
                                        '${AppRouter.conductTossRoute}?matchId=${match.id}',
                                      );
                                    },
                                    onStartScoring: () {
                                      context.push(
                                        '${AppRouter.liveScoringRoute}?matchId=${match.id}&matchCode=SPT-${match.id}',
                                      );
                                    },
                                  );
                                }
                              },
                            );
                          },
                        ),
                      ),
                    ],
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

// =============================================================================
// HEADER BAR (Frame 1000003337: 350x43)
// =============================================================================
class _FigmaMatchesHeader extends StatelessWidget {
  final double scale;
  final bool isRequestsTab;
  final int count;
  final VoidCallback? onBack;

  const _FigmaMatchesHeader({
    required this.scale,
    required this.isRequestsTab,
    required this.count,
    this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        20 * scale,
        12 * scale,
        20 * scale,
        0,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            isRequestsTab ? 'Match Requests' : "Today's Matches",
            style: TextStyle(
              fontSize: 18 * scale,
              fontWeight: FontWeight.w600,
              color: const Color(0xFFFFFFFF),
              height: 1.15,
            ),
          ),
          SizedBox(height: 2 * scale),
          _GradientText(
            isRequestsTab
                ? '$count Pending Requests'
                : '$count Matches Assigned',
            gradient: const LinearGradient(
              colors: [
                Color(0xFF7AD2FF),
                Color(0xFF4FBAF0),
              ],
            ),
            style: TextStyle(
              fontSize: 14 * scale,
              fontWeight: FontWeight.w500,
              height: 1.15,
            ),
          ),
        ],
      ),
    );
  }
}

// =============================================================================
// GLASSMORHPIC FILTER TAB BAR (Frame 1261154332 -> Frame 43932)
// =============================================================================
class _FigmaFilterTabBar extends StatelessWidget {
  final double scale;
  final List<String> tabs;
  final int selectedIndex;
  final ValueChanged<int> onTabSelected;

  const _FigmaFilterTabBar({
    required this.scale,
    required this.tabs,
    required this.selectedIndex,
    required this.onTabSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 45 * scale,
      // decoration: const BoxDecoration(
      // gradient: LinearGradient(
      //   begin: Alignment.topCenter,
      //   end: Alignment.bottomCenter,
      //   colors: [
      //     Color(0x001B2335),
      //     Color(0x33394153),
      //   ],
      //   stops: [0.10, 1.0],
      // ),
      // border: Border(
      //   top: BorderSide(
      //     color: Color(0x33FFFFFF),
      //     width: 0.8,
      //   ),
      //   bottom: BorderSide(
      //     color: Color(0x33FFFFFF),
      //     width: 0.8,
      //   ),
      // ),
      // ),
      child: ClipRect(
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          padding: EdgeInsets.symmetric(horizontal: 20 * scale),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: List.generate(tabs.length, (index) {
              final isSelected = index == selectedIndex;
              return Padding(
                padding: EdgeInsets.only(
                  right: index < tabs.length - 1 ? 20 * scale : 0,
                ),
                child: GestureDetector(
                  key: ValueKey('filter_tab_${tabs[index]}'),
                  behavior: HitTestBehavior.opaque,
                  onTap: () => onTabSelected(index),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      isSelected
                          ? _GradientText(
                              tabs[index],
                              gradient: const LinearGradient(
                                colors: [
                                  Color(0xFF7AD2FF),
                                  Color(0xFF4FBAF0),
                                ],
                              ),
                              style: TextStyle(
                                fontSize: 13 * scale,
                                fontWeight: FontWeight.w700,
                                height: 1.0,
                              ),
                            )
                          : Text(
                              tabs[index],
                              style: TextStyle(
                                fontSize: 13 * scale,
                                fontWeight: FontWeight.w500,
                                color: const Color(0xFFAAAAAA),
                                height: 1.0,
                              ),
                            ),
                      SizedBox(height: 6 * scale),
                      if (isSelected)
                        Container(
                          height: 2.5 * scale,
                          width: 28 * scale,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(2 * scale),
                            gradient: const LinearGradient(
                              colors: [
                                Color(0xFF7AD2FF),
                                Color(0xFF4FBAF0),
                              ],
                            ),
                          ),
                        )
                      else
                        SizedBox(
                          height: 2.5 * scale,
                          width: 28 * scale,
                        ),
                    ],
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}

// =============================================================================
// CARD 1: LIVE NOW MATCH CARD (Section: 350x203, radius 16)
// =============================================================================
class _FigmaLiveMatchCard extends StatelessWidget {
  final double scale;
  final RefereeMatchResponse match;
  final VoidCallback onContinueScoring;

  const _FigmaLiveMatchCard({
    required this.scale,
    required this.match,
    required this.onContinueScoring,
  });

  @override
  Widget build(BuildContext context) {
    final teamAScore = match.raw['team_a_score']?.toString() ?? '28/1';
    final teamBScore =
        match.raw['team_b_score']?.toString() ?? 'Waiting to Bat';
    final currentBatter = match.raw['current_batter']?.toString() ?? 'Rahul';
    final currentBowler = match.raw['current_bowler']?.toString() ?? 'Amit';
    final oversText = match.raw['overs_text']?.toString() ?? 'Over - 2.1/6';
    final duration = match.raw['duration']?.toString() ?? '08:25';

    return Container(
      decoration: BoxDecoration(
        color: const Color(0x33B40003),
        borderRadius: BorderRadius.circular(16 * scale),
        border: Border.all(
          color: const Color(0x4DF53E02),
          width: 0.8,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x80512813),
            blurRadius: 8,
            offset: Offset(0, 1),
          ),
        ],
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16 * scale),
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0x0AED7B00),
              Color(0x0ACF9E24),
            ],
          ),
        ),
        padding: EdgeInsets.all(10 * scale),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Badge Row: Stage pill, Live Now pill, Overs pill
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Flexible(
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 6 * scale,
                            vertical: 2 * scale,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFF2BB673),
                            borderRadius: BorderRadius.circular(10 * scale),
                          ),
                          child: Text(
                            match.displayRound.isNotEmpty
                                ? match.displayRound
                                : 'Final',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 11 * scale,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFFFFFFFF),
                              height: 1.0,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 4 * scale),

                      // Live Now badge with red pulsing dot
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 6 * scale,
                          vertical: 2 * scale,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0x26FE464B),
                          borderRadius: BorderRadius.circular(10 * scale),
                          border: Border.all(
                            color: const Color(0x4DFE464B),
                            width: 0.8,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            _PulsingDot(
                              size: 6 * scale,
                              color: const Color(0xFFFE464B),
                            ),
                            SizedBox(width: 4 * scale),
                            Text(
                              'Live Now',
                              style: TextStyle(
                                fontSize: 11 * scale,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFFFE464B),
                                height: 1.0,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 6 * scale),

                // Overs Pill
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 8 * scale,
                    vertical: 3 * scale,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0x661B2335),
                    borderRadius: BorderRadius.circular(8 * scale),
                  ),
                  child: Text(
                    oversText,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 11 * scale,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFFFFFFFF),
                      height: 1.0,
                    ),
                  ),
                ),
              ],
            ),

            SizedBox(height: 8 * scale),

            // Tournament Name
            Text(
              match.displayTournament,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 16 * scale,
                fontWeight: FontWeight.w600,
                color: const Color(0xFFFFFFFF),
                height: 1.2,
              ),
            ),

            SizedBox(height: 2 * scale),

            // Venue with Location Pin
            Row(
              children: [
                SportoAssetIcon(
                  SportoAssets.locationPin,
                  size: 13 * scale,
                  color: const Color(0xFFAAAAAA),
                ),
                SizedBox(width: 4 * scale),
                Expanded(
                  child: Text(
                    match.displayVenue,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 12 * scale,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFFAAAAAA),
                    ),
                  ),
                ),
              ],
            ),

            SizedBox(height: 8 * scale),

            // Teams Row
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        match.displayTeamA,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 14 * scale,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFFFFFFFF),
                        ),
                      ),
                      SizedBox(height: 2 * scale),
                      Text(
                        teamAScore,
                        style: TextStyle(
                          fontSize: 13 * scale,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFFFFFFFF),
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8 * scale),
                  child: Text(
                    'Vs',
                    style: TextStyle(
                      fontSize: 12 * scale,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFFAAAAAA),
                    ),
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        match.displayTeamB,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.right,
                        style: TextStyle(
                          fontSize: 14 * scale,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFFFFFFFF),
                        ),
                      ),
                      SizedBox(height: 2 * scale),
                      Text(
                        teamBScore,
                        textAlign: TextAlign.right,
                        style: TextStyle(
                          fontSize: 13 * scale,
                          fontWeight: FontWeight.w500,
                          color: const Color(0xFFAAAAAA),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            SizedBox(height: 8 * scale),

            // Divider Line (0.8px, #283040)
            Container(
              height: 0.8 * scale,
              color: const Color(0xFF283040),
            ),

            SizedBox(height: 6 * scale),

            // Split Batter & Bowler Row
            Row(
              children: [
                Expanded(
                  child: Text.rich(
                    TextSpan(
                      style: TextStyle(
                        fontSize: 12 * scale,
                        color: const Color(0xFFAAAAAA),
                      ),
                      children: [
                        const TextSpan(text: 'Current Batter: '),
                        TextSpan(
                          text: currentBatter,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            color: Color(0xFFFFFFFF),
                          ),
                        ),
                      ],
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                SizedBox(width: 8 * scale),
                Expanded(
                  child: Text.rich(
                    TextSpan(
                      style: TextStyle(
                        fontSize: 12 * scale,
                        color: const Color(0xFFAAAAAA),
                      ),
                      children: [
                        const TextSpan(text: 'Current Bowler: '),
                        TextSpan(
                          text: currentBowler,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            color: Color(0xFFFFFFFF),
                          ),
                        ),
                      ],
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.right,
                  ),
                ),
              ],
            ),

            SizedBox(height: 6 * scale),

            // Divider Line
            Container(
              height: 0.8 * scale,
              color: const Color(0xFF283040),
            ),

            SizedBox(height: 8 * scale),

            // Action Row: Duration & Continue Scoring Action
            Row(
              children: [
                Expanded(
                  child: Text.rich(
                    TextSpan(
                      style: TextStyle(
                        fontSize: 12 * scale,
                        color: const Color(0xFFAAAAAA),
                      ),
                      children: [
                        const TextSpan(text: 'Duration: '),
                        TextSpan(
                          text: duration,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            color: Color(0xFFFFFFFF),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(width: 8 * scale),
                Container(
                  height: 30 * scale,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [
                        Color(0xFFDE3F00),
                        Color(0xFFF65800),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(10 * scale),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x1A4F0E00),
                        blurRadius: 6,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: onContinueScoring,
                      borderRadius: BorderRadius.circular(10 * scale),
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: 14 * scale,
                        ),
                        child: Center(
                          child: Text(
                            'Continue Scoring',
                            style: TextStyle(
                              fontSize: 12 * scale,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFFFFFFFF),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// =============================================================================
// CARD 2: UPCOMING MATCH CARD (Section: 350x180, radius 14)
// =============================================================================
class _FigmaUpcomingMatchCard extends StatelessWidget {
  final double scale;
  final RefereeMatchResponse match;
  final VoidCallback onVerifyTeams;
  final VoidCallback? onConductToss;
  final VoidCallback? onStartScoring;

  const _FigmaUpcomingMatchCard({
    required this.scale,
    required this.match,
    required this.onVerifyTeams,
    this.onConductToss,
    this.onStartScoring,
  });

  @override
  Widget build(BuildContext context) {
    final statusText = match.displayStatus.toLowerCase();
    final label = (match.statusLabel ?? '').toLowerCase();
    final rawTossDone = match.isTossCompleted ||
        match.raw['toss_done'] == true ||
        match.raw['toss_winner'] != null ||
        match.raw['toss_decision'] != null;
    final rawTeamsVerified =
        match.raw['teams_verified'] == true || match.raw['verified'] == true;

    // Check if Toss is completed (Ready to score)
    final isTossDone = statusText.contains('toss completed') ||
        statusText.contains('ready') ||
        label.contains('toss completed') ||
        label.contains('ready') ||
        rawTossDone;

    // Check if Teams verified and Toss is pending
    final isTossPending = !isTossDone &&
        (statusText.contains('toss pending') ||
            statusText.contains('conduct toss') ||
            statusText.contains('verified') ||
            label.contains('verified') ||
            label.contains('toss') ||
            rawTeamsVerified);

    final isPreVerification = !isTossDone &&
        !isTossPending &&
        (match.raw['needs_verification'] == true ||
            match.raw['teams_verified'] == false ||
            statusText.contains('unverified'));

    // Determine button label, gradient, and callback based on status
    final String buttonLabel;
    final Gradient buttonGradient;
    final VoidCallback buttonCallback;

    if (isTossDone) {
      buttonLabel = 'Start Scoring';
      buttonGradient = const LinearGradient(
        colors: [Color(0xFF2BB673), Color(0xFF01A34D)],
      );
      buttonCallback = onStartScoring ?? onVerifyTeams;
    } else if (isTossPending) {
      buttonLabel = 'Conduct Toss';
      buttonGradient = const LinearGradient(
        colors: [Color(0xFFFF9364), Color(0xFFF25F33)],
      );
      buttonCallback = onConductToss ?? onVerifyTeams;
    } else {
      buttonLabel = 'Verify Teams';
      buttonGradient = const LinearGradient(
        colors: [Color(0xFF7AD3FF), Color(0xFF4FBAF0)],
      );
      buttonCallback = onVerifyTeams;
    }

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1C2026),
        borderRadius: BorderRadius.circular(14 * scale),
        border: Border.all(
          color: const Color(0x1AFFFFFF),
          width: 0.8,
        ),
      ),
      padding: EdgeInsets.all(10 * scale),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: Stage badge, Schedule, Upcoming gradient badge
          Row(
            children: [
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: 6 * scale,
                  vertical: 2 * scale,
                ),
                decoration: BoxDecoration(
                  color: const Color(0x3301A34D),
                  borderRadius: BorderRadius.circular(10 * scale),
                  border: Border.all(
                    color: const Color(0xFF2BB673),
                    width: 0.8,
                  ),
                ),
                child: Text(
                  match.displayRound.isNotEmpty
                      ? match.displayRound
                      : 'Quarter Final',
                  style: TextStyle(
                    fontSize: 11 * scale,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFFFFFFFF),
                    height: 1.0,
                  ),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 6 * scale),
                  child: Text(
                    match.displaySchedule,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 12 * scale,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFFAAAAAA),
                    ),
                  ),
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: 6 * scale,
                  vertical: 2 * scale,
                ),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [
                      Color(0x26FF9364),
                      Color(0x26F25F33),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(10 * scale),
                ),
                child: Text(
                  'Upcoming',
                  style: TextStyle(
                    fontSize: 11 * scale,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFFFF9364),
                    height: 1.0,
                  ),
                ),
              ),
            ],
          ),

          SizedBox(height: 8 * scale),

          // Tournament Name (Crisp White Quicksand - never yellow)
          Text(
            match.displayTournament,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 16 * scale,
              fontWeight: FontWeight.w600,
              color: const Color(0xFFFFFFFF),
              height: 1.2,
            ),
          ),

          SizedBox(height: 2 * scale),

          // Venue
          Row(
            children: [
              SportoAssetIcon(
                SportoAssets.locationPin,
                size: 13 * scale,
                color: const Color(0xFFAAAAAA),
              ),
              SizedBox(width: 4 * scale),
              Expanded(
                child: Text(
                  match.displayVenue,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 12 * scale,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFFAAAAAA),
                  ),
                ),
              ),
            ],
          ),

          SizedBox(height: 8 * scale),

          // Teams Matchup
          Row(
            children: [
              Expanded(
                child: Text(
                  match.displayTeamA,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 14 * scale,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFFFFFFFF),
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 8 * scale),
                child: Text(
                  'Vs',
                  style: TextStyle(
                    fontSize: 12 * scale,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFFAAAAAA),
                  ),
                ),
              ),
              Expanded(
                child: Text(
                  match.displayTeamB,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.right,
                  style: TextStyle(
                    fontSize: 14 * scale,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFFFFFFFF),
                  ),
                ),
              ),
            ],
          ),

          SizedBox(height: 8 * scale),

          // Top Divider Line (Line 7: 0.8px, #283040)
          Container(
            height: 0.8 * scale,
            color: const Color(0xFF283040),
          ),

          SizedBox(height: 6 * scale),

          // Verification Checklist Row (Frame 1261154325)
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Item 1: Teams
                if (isPreVerification)
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 6 * scale,
                        height: 6 * scale,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Color(0xFFFF9364),
                        ),
                      ),
                      SizedBox(width: 4 * scale),
                      Text(
                        'Teams Pending',
                        style: TextStyle(
                          fontSize: 11 * scale,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFFFF9364),
                        ),
                      ),
                    ],
                  )
                else
                  Text(
                    '✓ Teams Verified',
                    style: TextStyle(
                      fontSize: 11 * scale,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF2BB673),
                    ),
                  ),
                SizedBox(width: 20 * scale),

                // Item 2: Ground
                Text(
                  '✓ Ground Ready',
                  style: TextStyle(
                    fontSize: 11 * scale,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF2BB673),
                  ),
                ),
                SizedBox(width: 20 * scale),

                // Item 3: Toss
                if (isTossDone)
                  Text(
                    '✓ Toss Completed',
                    style: TextStyle(
                      fontSize: 11 * scale,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF2BB673),
                    ),
                  )
                else
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 6 * scale,
                        height: 6 * scale,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Color(0xFFFF9364),
                        ),
                      ),
                      SizedBox(width: 4 * scale),
                      Text(
                        'Toss Pending',
                        style: TextStyle(
                          fontSize: 11 * scale,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFFFF9364),
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),

          SizedBox(height: 6 * scale),

          // Bottom Divider Line (Line 8: 0.8px, #283040)
          Container(
            height: 0.8 * scale,
            color: const Color(0xFF283040),
          ),

          SizedBox(height: 8 * scale),

          // Footer Action Row (Frame 1171275259: 330x30, align MAX/CENTER)
          Row(
            children: [
              Expanded(
                child: Text(
                  match.scheduledAt != null && match.scheduledAt!.isNotEmpty
                      ? 'Starts at ${match.scheduledAt}'
                      : 'Starts in 24 mins',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 12 * scale,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFFAAAAAA),
                  ),
                ),
              ),
              SizedBox(width: 8 * scale),
              Container(
                height: 30 * scale,
                decoration: BoxDecoration(
                  gradient: buttonGradient,
                  borderRadius: BorderRadius.circular(10 * scale),
                  border: Border.all(
                    color: const Color(0x4D7BD0FA),
                    width: 0.8,
                  ),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x1A4F0E00),
                      blurRadius: 6,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: buttonCallback,
                    borderRadius: BorderRadius.circular(10 * scale),
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 14 * scale,
                      ),
                      child: Center(
                        child: Text(
                          buttonLabel,
                          style: TextStyle(
                            fontSize: 12 * scale,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFFFFFFFF),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// =============================================================================
// CARD 3: COMPLETED MATCH CARD (Section: 350x168, radius 14)
// =============================================================================
class _FigmaCompletedMatchCard extends StatelessWidget {
  final double scale;
  final RefereeMatchResponse match;
  final VoidCallback onViewReport;

  const _FigmaCompletedMatchCard({
    required this.scale,
    required this.match,
    required this.onViewReport,
  });

  @override
  Widget build(BuildContext context) {
    final teamAScore = match.raw['team_a_score']?.toString() ?? '90/2';
    final teamBScore = match.raw['team_b_score']?.toString() ?? '85/3';
    final winnerSummary =
        match.raw['result_summary']?.toString() ?? '${match.displayTeamA} Won';

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1C2026),
        borderRadius: BorderRadius.circular(14 * scale),
        border: Border.all(
          color: const Color(0x1AFFFFFF),
          width: 0.8,
        ),
      ),
      padding: EdgeInsets.all(10 * scale),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: Stage badge, Schedule, Completed gradient badge
          Row(
            children: [
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: 6 * scale,
                  vertical: 2 * scale,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFF2BB673),
                  borderRadius: BorderRadius.circular(10 * scale),
                  border: Border.all(
                    color: const Color(0xFF2BB673),
                    width: 0.8,
                  ),
                ),
                child: Text(
                  match.displayRound.isNotEmpty ? match.displayRound : 'Final',
                  style: TextStyle(
                    fontSize: 11 * scale,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFFFFFFFF),
                    height: 1.0,
                  ),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 6 * scale),
                  child: Text(
                    match.displaySchedule,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 12 * scale,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFFAAAAAA),
                    ),
                  ),
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: 6 * scale,
                  vertical: 2 * scale,
                ),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [
                      Color(0x267AD3FF),
                      Color(0x264FBAF0),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(10 * scale),
                  border: Border.all(
                    color: const Color(0x4D7AD3FF),
                    width: 0.8,
                  ),
                ),
                child: Text(
                  'Completed',
                  style: TextStyle(
                    fontSize: 11 * scale,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF7AD3FF),
                    height: 1.0,
                  ),
                ),
              ),
            ],
          ),

          SizedBox(height: 8 * scale),

          // Tournament Name (Crisp White Quicksand - never yellow)
          Text(
            match.displayTournament,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 16 * scale,
              fontWeight: FontWeight.w600,
              color: const Color(0xFFFFFFFF),
              height: 1.2,
            ),
          ),

          SizedBox(height: 2 * scale),

          // Venue
          Row(
            children: [
              SportoAssetIcon(
                SportoAssets.locationPin,
                size: 13 * scale,
                color: const Color(0xFFAAAAAA),
              ),
              SizedBox(width: 4 * scale),
              Expanded(
                child: Text(
                  match.displayVenue,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 12 * scale,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFFAAAAAA),
                  ),
                ),
              ),
            ],
          ),

          SizedBox(height: 8 * scale),

          // Teams & Final Scores
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      match.displayTeamA,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 14 * scale,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFFFFFFFF),
                      ),
                    ),
                    SizedBox(height: 2 * scale),
                    Text(
                      teamAScore,
                      style: TextStyle(
                        fontSize: 13 * scale,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFFFFFFFF),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 8 * scale),
                child: Text(
                  'Vs',
                  style: TextStyle(
                    fontSize: 12 * scale,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFFAAAAAA),
                  ),
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      match.displayTeamB,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.right,
                      style: TextStyle(
                        fontSize: 14 * scale,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFFFFFFFF),
                      ),
                    ),
                    SizedBox(height: 2 * scale),
                    Text(
                      teamBScore,
                      textAlign: TextAlign.right,
                      style: TextStyle(
                        fontSize: 13 * scale,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFFFFFFFF),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          SizedBox(height: 8 * scale),

          // Divider Line (Line 7: 0.8px, #283040)
          Container(
            height: 0.8 * scale,
            color: const Color(0xFF283040),
          ),

          SizedBox(height: 8 * scale),

          // Winner Summary & View Report Action
          Row(
            children: [
              Icon(
                Icons.emoji_events_rounded,
                size: 15 * scale,
                color: const Color(0xFF2BB673),
              ),
              SizedBox(width: 4 * scale),
              Expanded(
                child: Text(
                  winnerSummary,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 13 * scale,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF2BB673),
                  ),
                ),
              ),
              SizedBox(width: 8 * scale),
              Container(
                height: 30 * scale,
                decoration: BoxDecoration(
                  color: const Color(0x66283040),
                  borderRadius: BorderRadius.circular(10 * scale),
                  border: Border.all(
                    color: const Color(0xFF283040),
                    width: 1,
                  ),
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: onViewReport,
                    borderRadius: BorderRadius.circular(10 * scale),
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 14 * scale,
                      ),
                      child: Center(
                        child: Text(
                          'View Report',
                          style: TextStyle(
                            fontSize: 12 * scale,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFFFFFFFF),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// =============================================================================
// CARD 4: DELAYED / WEATHER MATCH CARD (Section: 350x197, radius 14)
// =============================================================================
class _FigmaDelayedMatchCard extends StatelessWidget {
  final double scale;
  final RefereeMatchResponse match;
  final VoidCallback onUpdateStatus;

  const _FigmaDelayedMatchCard({
    required this.scale,
    required this.match,
    required this.onUpdateStatus,
  });

  @override
  Widget build(BuildContext context) {
    final teamAScore = match.raw['team_a_score']?.toString() ?? '28/1';
    final teamBScore = match.raw['team_b_score']?.toString() ?? 'Yet to Bat';
    final delayReason = match.raw['delay_reason']?.toString() ?? 'Heavy Rain';
    final resumeTime = match.raw['resume_time']?.toString() ?? '4:00 PM';

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1C2026),
        borderRadius: BorderRadius.circular(14 * scale),
        border: Border.all(
          color: const Color(0x1AFFFFFF),
          width: 0.8,
        ),
      ),
      padding: EdgeInsets.all(10 * scale),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: Stage badge, Schedule, Delayed gradient badge
          Row(
            children: [
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: 6 * scale,
                  vertical: 2 * scale,
                ),
                decoration: BoxDecoration(
                  color: const Color(0x3301A34D),
                  borderRadius: BorderRadius.circular(10 * scale),
                  border: Border.all(
                    color: const Color(0xFF2BB673),
                    width: 0.8,
                  ),
                ),
                child: Text(
                  match.displayRound.isNotEmpty ? match.displayRound : 'Final',
                  style: TextStyle(
                    fontSize: 11 * scale,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFFFFFFFF),
                    height: 1.0,
                  ),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 6 * scale),
                  child: Text(
                    match.displaySchedule,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 12 * scale,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFFAAAAAA),
                    ),
                  ),
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: 6 * scale,
                  vertical: 2 * scale,
                ),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [
                      Color(0x26FFD572),
                      Color(0x26FEBD38),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(10 * scale),
                  border: Border.all(
                    color: const Color(0x4DFEBD38),
                    width: 0.8,
                  ),
                ),
                child: Text(
                  'Delayed',
                  style: TextStyle(
                    fontSize: 11 * scale,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFFFEBD38),
                    height: 1.0,
                  ),
                ),
              ),
            ],
          ),

          SizedBox(height: 8 * scale),

          // Weather alert banner (Frame 1261154336: 330x18, itemSpacing 4)
          Row(
            children: [
              Container(
                width: 8 * scale,
                height: 8 * scale,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [
                      Color(0xFFFE6C6C),
                      Color(0xFFFE464B),
                    ],
                  ),
                ),
              ),
              SizedBox(width: 4 * scale),
              _GradientText(
                delayReason,
                gradient: const LinearGradient(
                  colors: [
                    Color(0xFFFE6C6C),
                    Color(0xFFFE464B),
                  ],
                ),
                style: TextStyle(
                  fontSize: 14 * scale,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),

          SizedBox(height: 8 * scale),

          // Tournament Name (Crisp White Quicksand - never yellow)
          Text(
            match.displayTournament,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 16 * scale,
              fontWeight: FontWeight.w600,
              color: const Color(0xFFFFFFFF),
              height: 1.2,
            ),
          ),

          SizedBox(height: 2 * scale),

          // Venue
          Row(
            children: [
              SportoAssetIcon(
                SportoAssets.locationPin,
                size: 13 * scale,
                color: const Color(0xFFAAAAAA),
              ),
              SizedBox(width: 4 * scale),
              Expanded(
                child: Text(
                  match.displayVenue,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 12 * scale,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFFAAAAAA),
                  ),
                ),
              ),
            ],
          ),

          SizedBox(height: 8 * scale),

          // Teams & Scores
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      match.displayTeamA,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 14 * scale,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFFFFFFFF),
                      ),
                    ),
                    SizedBox(height: 2 * scale),
                    Text(
                      teamAScore,
                      style: TextStyle(
                        fontSize: 13 * scale,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFFFFFFFF),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 8 * scale),
                child: Text(
                  'Vs',
                  style: TextStyle(
                    fontSize: 12 * scale,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFFAAAAAA),
                  ),
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      match.displayTeamB,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.right,
                      style: TextStyle(
                        fontSize: 14 * scale,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFFFFFFFF),
                      ),
                    ),
                    SizedBox(height: 2 * scale),
                    Text(
                      teamBScore,
                      textAlign: TextAlign.right,
                      style: TextStyle(
                        fontSize: 13 * scale,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFFAAAAAA),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          SizedBox(height: 8 * scale),

          // Divider Line (Line 7: 0.8px, #283040)
          Container(
            height: 0.8 * scale,
            color: const Color(0xFF283040),
          ),

          SizedBox(height: 8 * scale),

          // Resume Time & Update Status Action
          Row(
            children: [
              Expanded(
                child: Text.rich(
                  TextSpan(
                    style: TextStyle(
                      fontSize: 12 * scale,
                      color: const Color(0xFFAAAAAA),
                    ),
                    children: [
                      const TextSpan(text: 'Resume Time: '),
                      TextSpan(
                        text: resumeTime,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          color: Color(0xFFFFFFFF),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(width: 8 * scale),
              Container(
                height: 30 * scale,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [
                      Color(0x1AFFD572),
                      Color(0x1AFEBD38),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(10 * scale),
                  border: Border.all(
                    color: const Color(0x4DF4B41A),
                    width: 1,
                  ),
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: onUpdateStatus,
                    borderRadius: BorderRadius.circular(10 * scale),
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 14 * scale,
                      ),
                      child: Center(
                        child: Text(
                          'Update Status',
                          style: TextStyle(
                            fontSize: 12 * scale,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFFFEBD38),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// =============================================================================
// CARD 5: REQUEST MATCH CARD (for Requests tab)
// =============================================================================
class _FigmaRequestMatchCard extends StatelessWidget {
  final double scale;
  final RefereeMatchRequestResponse request;
  final VoidCallback onAccept;
  final VoidCallback onReject;
  final bool isProcessing;

  const _FigmaRequestMatchCard({
    required this.scale,
    required this.request,
    required this.onAccept,
    required this.onReject,
    this.isProcessing = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1C2026),
        borderRadius: BorderRadius.circular(14 * scale),
        border: Border.all(
          color: const Color(0x33ED7B00),
          width: 0.8,
        ),
      ),
      padding: EdgeInsets.all(12 * scale),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: 8 * scale,
                  vertical: 3 * scale,
                ),
                decoration: BoxDecoration(
                  color: const Color(0x26ED7B00),
                  borderRadius: BorderRadius.circular(8 * scale),
                ),
                child: Text(
                  'Assignment Request',
                  style: TextStyle(
                    fontSize: 11 * scale,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFFED7B00),
                    height: 1.0,
                  ),
                ),
              ),
              const Spacer(),
              Text(
                request.displaySchedule,
                style: TextStyle(
                  fontSize: 12 * scale,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFFAAAAAA),
                ),
              ),
            ],
          ),
          SizedBox(height: 8 * scale),
          Text(
            request.displayTournament,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 16 * scale,
              fontWeight: FontWeight.w600,
              color: const Color(0xFFFFFFFF),
              height: 1.2,
            ),
          ),
          SizedBox(height: 2 * scale),
          Row(
            children: [
              SportoAssetIcon(
                SportoAssets.locationPin,
                size: 13 * scale,
                color: const Color(0xFFAAAAAA),
              ),
              SizedBox(width: 4 * scale),
              Expanded(
                child: Text(
                  request.displayVenue,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 12 * scale,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFFAAAAAA),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 8 * scale),
          Row(
            children: [
              Expanded(
                child: Text(
                  request.displayTeamA,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 14 * scale,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFFFFFFFF),
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 8 * scale),
                child: Text(
                  'Vs',
                  style: TextStyle(
                    fontSize: 12 * scale,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFFAAAAAA),
                  ),
                ),
              ),
              Expanded(
                child: Text(
                  request.displayTeamB,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.right,
                  style: TextStyle(
                    fontSize: 14 * scale,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFFFFFFFF),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 12 * scale),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: isProcessing ? null : onReject,
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Color(0xFFFE464B)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10 * scale),
                    ),
                    padding: EdgeInsets.symmetric(vertical: 8 * scale),
                  ),
                  child: isProcessing
                      ? SizedBox(
                          width: 16 * scale,
                          height: 16 * scale,
                          child: const CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Color(0xFFFE464B),
                          ),
                        )
                      : Text(
                          'Reject',
                          style: TextStyle(
                            fontSize: 12 * scale,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFFFE464B),
                          ),
                        ),
                ),
              ),
              SizedBox(width: 10 * scale),
              Expanded(
                child: Container(
                  height: 36 * scale,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [
                        Color(0xFF7AD2FF),
                        Color(0xFF4FBAF0),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(10 * scale),
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: isProcessing ? null : onAccept,
                      borderRadius: BorderRadius.circular(10 * scale),
                      child: Center(
                        child: isProcessing
                            ? SizedBox(
                                width: 16 * scale,
                                height: 16 * scale,
                                child: const CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Color(0xFF000000),
                                ),
                              )
                            : Text(
                                'Accept',
                                style: TextStyle(
                                  fontSize: 12 * scale,
                                  fontWeight: FontWeight.w700,
                                  color: const Color(0xFF000000),
                                ),
                              ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// =============================================================================
// SKELETON SHIMMER (Replaces CircularProgressIndicator)
// =============================================================================
class _FigmaMatchesListSkeletonShimmer extends StatefulWidget {
  final double scale;

  const _FigmaMatchesListSkeletonShimmer({required this.scale});

  @override
  State<_FigmaMatchesListSkeletonShimmer> createState() =>
      _FigmaMatchesListSkeletonShimmerState();
}

class _FigmaMatchesListSkeletonShimmerState
    extends State<_FigmaMatchesListSkeletonShimmer>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scale = widget.scale;

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final shimmerGradient = LinearGradient(
          begin: Alignment(-1.0 + 2.0 * _controller.value, -0.3),
          end: Alignment(1.0 + 2.0 * _controller.value, 0.3),
          colors: const [
            Color(0x1A1B2335),
            Color(0x335C93FF),
            Color(0x1A1B2335),
          ],
        );

        return ListView(
          physics: const NeverScrollableScrollPhysics(),
          padding: EdgeInsets.fromLTRB(
            20 * scale,
            4 * scale,
            20 * scale,
            30 * scale,
          ),
          children: [
            _buildCardShimmer(scale, shimmerGradient, 203 * scale),
            SizedBox(height: 14 * scale),
            _buildCardShimmer(scale, shimmerGradient, 180 * scale),
            SizedBox(height: 14 * scale),
            _buildCardShimmer(scale, shimmerGradient, 168 * scale),
          ],
        );
      },
    );
  }

  Widget _buildCardShimmer(
    double scale,
    LinearGradient shimmerGradient,
    double height,
  ) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        gradient: shimmerGradient,
        borderRadius: BorderRadius.circular(14 * scale),
        border: Border.all(
          color: const Color(0x265C93FF),
          width: 0.8,
        ),
      ),
    );
  }
}

// =============================================================================
// EMPTY STATE CARD
// =============================================================================
class _FigmaEmptyMatchesCard extends StatelessWidget {
  final double scale;
  final String title;
  final String subtitle;

  const _FigmaEmptyMatchesCard({
    required this.scale,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: EdgeInsets.symmetric(
        horizontal: 20 * scale,
        vertical: 40 * scale,
      ),
      children: [
        Container(
          padding: EdgeInsets.symmetric(
            horizontal: 20 * scale,
            vertical: 24 * scale,
          ),
          decoration: BoxDecoration(
            color: const Color(0xFF1C2026),
            borderRadius: BorderRadius.circular(16 * scale),
            border: Border.all(
              color: const Color(0x265C93FF),
              width: 0.8,
            ),
          ),
          child: Column(
            children: [
              Icon(
                Icons.sports_cricket_rounded,
                size: 40 * scale,
                color: const Color(0xFF7AD2FF),
              ),
              SizedBox(height: 12 * scale),
              Text(
                title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16 * scale,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFFFFFFFF),
                ),
              ),
              SizedBox(height: 6 * scale),
              Text(
                subtitle,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13 * scale,
                  fontWeight: FontWeight.w400,
                  color: const Color(0xFFAAAAAA),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// =============================================================================
// ERROR STATE CARD
// =============================================================================
class _FigmaErrorCard extends StatelessWidget {
  final double scale;
  final String message;
  final VoidCallback onRetry;

  const _FigmaErrorCard({
    required this.scale,
    required this.message,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: EdgeInsets.symmetric(
        horizontal: 20 * scale,
        vertical: 40 * scale,
      ),
      children: [
        Container(
          padding: EdgeInsets.all(20 * scale),
          decoration: BoxDecoration(
            color: const Color(0xFF1C2026),
            borderRadius: BorderRadius.circular(16 * scale),
            border: Border.all(
              color: const Color(0x33FE464B),
              width: 0.8,
            ),
          ),
          child: Column(
            children: [
              Icon(
                Icons.error_outline_rounded,
                size: 36 * scale,
                color: const Color(0xFFFE464B),
              ),
              SizedBox(height: 10 * scale),
              Text(
                'Unable to load matches',
                style: TextStyle(
                  fontSize: 16 * scale,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFFFFFFFF),
                ),
              ),
              SizedBox(height: 6 * scale),
              Text(
                message,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12 * scale,
                  color: const Color(0xFFAAAAAA),
                ),
              ),
              SizedBox(height: 14 * scale),
              TextButton.icon(
                onPressed: onRetry,
                icon: Icon(
                  Icons.refresh_rounded,
                  size: 16 * scale,
                  color: const Color(0xFF7AD2FF),
                ),
                label: Text(
                  'Retry',
                  style: TextStyle(
                    fontSize: 13 * scale,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF7AD2FF),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// =============================================================================
// MATCH DETAILS SHEET
// =============================================================================
class _FigmaMatchDetailsSheet extends StatelessWidget {
  final RefereeMatchResponse match;

  const _FigmaMatchDetailsSheet({required this.match});

  @override
  Widget build(BuildContext context) {
    final scale = context.sportoScale;

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          20 * scale,
          18 * scale,
          20 * scale,
          26 * scale,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 42 * scale,
                height: 4 * scale,
                decoration: BoxDecoration(
                  color: const Color(0x40FFFFFF),
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
            ),
            SizedBox(height: 18 * scale),
            Text(
              match.displayTournament,
              style: TextStyle(
                fontSize: 18 * scale,
                fontWeight: FontWeight.w700,
                color: const Color(0xFFFFFFFF),
              ),
            ),
            SizedBox(height: 4 * scale),
            _GradientText(
              match.displayRound.isNotEmpty ? match.displayRound : 'Final',
              gradient: const LinearGradient(
                colors: [
                  Color(0xFFFFD572),
                  Color(0xFFFDBD38),
                ],
              ),
              style: TextStyle(
                fontSize: 14 * scale,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 16 * scale),
            _DetailRow(
              scale: scale,
              label: 'Teams',
              value: '${match.displayTeamA} vs ${match.displayTeamB}',
            ),
            _DetailRow(
              scale: scale,
              label: 'Schedule',
              value: match.displaySchedule,
            ),
            _DetailRow(
              scale: scale,
              label: 'Venue',
              value: match.displayVenue,
            ),
            _DetailRow(
              scale: scale,
              label: 'Status',
              value: match.displayStatus,
            ),
            if (match.role != null)
              _DetailRow(
                scale: scale,
                label: 'Role',
                value: match.role!,
              ),
            if (match.notes != null)
              _DetailRow(
                scale: scale,
                label: 'Notes',
                value: match.notes!,
              ),
          ],
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final double scale;
  final String label;
  final String value;

  const _DetailRow({
    required this.scale,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 10 * scale),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 86 * scale,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 12 * scale,
                fontWeight: FontWeight.w500,
                color: const Color(0xFFAAAAAA),
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 13 * scale,
                fontWeight: FontWeight.w600,
                color: const Color(0xFFFFFFFF),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// =============================================================================
// HELPER EXTENSIONS & WIDGETS
// =============================================================================

class RefereeMatchesPayload {
  const RefereeMatchesPayload({
    this.requests = const [],
    this.matches = const [],
  });

  final List<RefereeMatchRequestResponse> requests;
  final List<RefereeMatchResponse> matches;
}

extension _RefereeMatchStatusExt on RefereeMatchResponse {
  bool get isDelayed =>
      (statusLabel?.toLowerCase().contains('delay') ?? false) ||
      (status == 3 &&
          (statusLabel?.toLowerCase() == 'delayed' ||
              raw['state'] == 'delayed')) ||
      raw['delay_reason'] != null;
}

class _GradientText extends StatelessWidget {
  final String text;
  final Gradient gradient;
  final TextStyle? style;

  const _GradientText(
    this.text, {
    required this.gradient,
    this.style,
  });

  @override
  Widget build(BuildContext context) {
    return ShaderMask(
      blendMode: BlendMode.srcIn,
      shaderCallback: (bounds) => gradient.createShader(
        Rect.fromLTWH(0, 0, bounds.width, bounds.height),
      ),
      child: Text(
        text,
        style: style,
      ),
    );
  }
}

class _PulsingDot extends StatefulWidget {
  final double size;
  final Color color;

  const _PulsingDot({
    required this.size,
    required this.color,
  });

  @override
  State<_PulsingDot> createState() => _PulsingDotState();
}

class _PulsingDotState extends State<_PulsingDot>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Opacity(
          opacity: 0.4 + 0.6 * _controller.value,
          child: Container(
            width: widget.size,
            height: widget.size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: widget.color,
            ),
          ),
        );
      },
    );
  }
}
