import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:referee_data/referee_data.dart';
import 'package:ui_kit/ui_kit.dart';

import '../../../../app/router/app_router.dart';
import '../../../../core/di/dependency_injector.dart';

/// Pixel-perfect implementation of the Referee Home Screen matching Home.json
/// (Canvas: 390x1097, Atmosphere, Stats Overview, Live Match with scoring,
/// Next Match with countdown, Assigned Matches with View All, and Ads Banner).
///
/// Typography cleanly inherits Quicksand from SportoTheme.darkTheme without
/// redundant hardcoded fontFamily strings.
class RefereeHomeScreen extends StatefulWidget {
  final VoidCallback? onViewAll;
  final Future<List<RefereeMatchResponse>>? matchesFuture;

  const RefereeHomeScreen({
    super.key,
    this.onViewAll,
    this.matchesFuture,
  });

  @override
  State<RefereeHomeScreen> createState() => _RefereeHomeScreenState();
}

class _RefereeHomeScreenState extends State<RefereeHomeScreen> {
  late Future<List<RefereeMatchResponse>> _matchesFuture;

  @override
  void initState() {
    super.initState();
    _fetchMatches();
  }

  void _fetchMatches() {
    _matchesFuture = widget.matchesFuture ??
        DependencyInjector.instance.refereeRemoteDataSource
            .listMyMatchesData(perPage: 50);
  }

  @override
  Widget build(BuildContext context) {
    final scale = context.sportoScale;

    return Scaffold(
      backgroundColor: const Color(0xFF0E0C08),
      body: Stack(
        children: [
          // ====================================================
          // FIGMA ATMOSPHERE & BACKGROUND (Home.json)
          // ====================================================

          // Top ambient gradient backdrop (Rectangle 6011: 390x200)
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: 200 * scale,
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
            top: -80 * scale,
            left: 6.5 * scale,
            width: 376.9 * scale,
            height: 280 * scale,
            child: ImageFiltered(
              imageFilter: ImageFilter.blur(
                sigmaX: 70 * scale,
                sigmaY: 70 * scale,
              ),
              child: Container(
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color(0x4D373E52),
                ),
              ),
            ),
          ),

          // Ambient Glow Ellipse 18 (Middle)
          Positioned(
            top: 450 * scale,
            right: -50 * scale,
            width: 376.9 * scale,
            height: 280 * scale,
            child: ImageFiltered(
              imageFilter: ImageFilter.blur(
                sigmaX: 80 * scale,
                sigmaY: 80 * scale,
              ),
              child: Container(
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color(0x4D373E52),
                ),
              ),
            ),
          ),

          // Ambient Glow Ellipse 19 (Lower)
          Positioned(
            top: 850 * scale,
            left: -50 * scale,
            width: 376.9 * scale,
            height: 280 * scale,
            child: ImageFiltered(
              imageFilter: ImageFilter.blur(
                sigmaX: 80 * scale,
                sigmaY: 80 * scale,
              ),
              child: Container(
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color(0x4D373E52),
                ),
              ),
            ),
          ),

          // ====================================================
          // FOREGROUND SCROLLABLE CONTENT
          // ====================================================
          SafeArea(
            bottom: false,
            child: FutureBuilder<List<RefereeMatchResponse>>(
              future: _matchesFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return _RefereeHomeSkeletonShimmer(scale: scale);
                }

                if (snapshot.hasError) {
                  return RefreshIndicator(
                    onRefresh: () async {
                      setState(_fetchMatches);
                    },
                    child: SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: EdgeInsets.symmetric(
                        horizontal: 20 * scale,
                        vertical: 16 * scale,
                      ),
                      child: Column(
                        children: [
                          _FigmaHomeHeader(scale: scale),
                          SizedBox(height: 24 * scale),
                          _HomeErrorCard(
                            scale: scale,
                            message: snapshot.error.toString(),
                            onRetry: () => setState(_fetchMatches),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                final matches = snapshot.data ?? const <RefereeMatchResponse>[];
                final liveCount = matches.where((m) => m.isLive).length;
                final upcomingCount = matches.where((m) => m.isUpcoming).length;
                final completedCount =
                    matches.where((m) => m.isCompleted).length;

                final liveMatch = matches.firstLiveOrNull;
                final nextMatch = matches.firstUpcomingOrNull;
                final assignedMatches = matches
                    .where((m) => m.id != liveMatch?.id && m.id != nextMatch?.id)
                    .take(3)
                    .toList();

                return RefreshIndicator(
                  onRefresh: () async {
                    setState(_fetchMatches);
                  },
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(
                      parent: BouncingScrollPhysics(),
                    ),
                    padding: EdgeInsets.fromLTRB(
                      20 * scale,
                      12 * scale,
                      20 * scale,
                      40 * scale,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Header Bar (Frame 1000003336: 390x49)
                        _FigmaHomeHeader(scale: scale),

                        SizedBox(height: 14 * scale),

                        // Search Bar (Frame 1000003337: 358x50)
                        _FigmaHomeSearchBar(scale: scale),

                        SizedBox(height: 18 * scale),

                        // Overview Stats Section (Frame 1261154190: 350x120)
                        _FigmaOverviewStats(
                          scale: scale,
                          liveCount: liveCount,
                          upcomingCount: upcomingCount,
                          assignedCount: matches.length,
                          completedCount: completedCount,
                          cancelledCount: 0,
                        ),

                        SizedBox(height: 20 * scale),

                        // Section 1: Live Now Match (Frame 1261154188: 350x206)
                        if (liveMatch != null) ...[
                          _FigmaLiveMatchCard(
                            scale: scale,
                            match: liveMatch,
                          ),
                          SizedBox(height: 20 * scale),
                        ],

                        // Section 2: Next Match (Frame 1261154189: 350x197)
                        if (nextMatch != null) ...[
                          _FigmaNextMatchCard(
                            scale: scale,
                            match: nextMatch,
                          ),
                          SizedBox(height: 20 * scale),
                        ],

                        // Section 3: Assigned Matches (Frame 1261154191: 350x197)
                        if (assignedMatches.isNotEmpty) ...[
                          _FigmaAssignedSectionHeader(
                            scale: scale,
                            count: matches.length,
                            onViewAll: widget.onViewAll,
                          ),
                          SizedBox(height: 10 * scale),
                          for (final match in assignedMatches)
                            Padding(
                              padding: EdgeInsets.only(bottom: 12 * scale),
                              child: _FigmaAssignedMatchCard(
                                scale: scale,
                                match: match,
                              ),
                            ),
                          SizedBox(height: 10 * scale),
                        ] else if (liveMatch == null && nextMatch == null) ...[
                          // Clean Empty State Card
                          _FigmaEmptyMatchesCard(scale: scale),
                          SizedBox(height: 20 * scale),
                        ],

                        // Section 4: Ads Banner (Frame 1171275266: 350x60)
                        _FigmaAdsBanner(scale: scale),
                      ],
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

// =============================================================================
// EXTENSIONS
// =============================================================================
extension _RefereeHomeMatchPickers on List<RefereeMatchResponse> {
  RefereeMatchResponse? get firstLiveOrNull {
    for (final match in this) {
      if (match.isLive) return match;
    }
    return null;
  }

  RefereeMatchResponse? get firstUpcomingOrNull {
    for (final match in this) {
      if (match.isUpcoming) return match;
    }
    return null;
  }

}

// =============================================================================
// HEADER BAR (Frame 1000003336: 390x49)
// =============================================================================
class _FigmaHomeHeader extends StatelessWidget {
  final double scale;

  const _FigmaHomeHeader({
    required this.scale,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 49 * scale,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // User Avatar (38x38)
          Container(
            width: 38 * scale,
            height: 38 * scale,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFF252B38),
              border: Border.all(
                color: const Color(0xFF373E52),
                width: 1.2 * scale,
              ),
            ),
            child: Icon(
              Icons.person_rounded,
              size: 22 * scale,
              color: const Color(0xFFA0A0A0),
            ),
          ),

          SizedBox(width: 10 * scale),

          // Greeting Column (Frame 1000003337)
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _GradientText(
                  'Good Evening',
                  gradient: const LinearGradient(
                    colors: [
                      Color(0xFFED7B00),
                      Color(0xFFCF9E24),
                    ],
                  ),
                  style: TextStyle(
                    fontSize: 12 * scale,
                    fontWeight: FontWeight.w500,
                    height: 1.1,
                  ),
                ),
                SizedBox(height: 2 * scale),
                Text(
                  'Priya Agrawal',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 16 * scale,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFFFFFFFF),
                    height: 1.1,
                  ),
                ),
              ],
            ),
          ),

          // Wallet & Bell Container (Frame 1000003338: 123x41)
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Wallet Pill (Frame 1261154256: 85x24)
              ClipRRect(
                borderRadius: BorderRadius.circular(6 * scale),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Balance container (Frame 1000003340: 60x24)
                    Container(
                      height: 24 * scale,
                      padding: EdgeInsets.symmetric(horizontal: 8 * scale),
                      alignment: Alignment.center,
                      color: const Color(0x33767680),
                      child: Text(
                        '₹ 500',
                        style: TextStyle(
                          fontSize: 13 * scale,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFFFFFFFF),
                        ),
                      ),
                    ),
                    // Add button container (Frame 1000003341: 25x24)
                    Container(
                      width: 25 * scale,
                      height: 24 * scale,
                      alignment: Alignment.center,
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Color(0xFFED7B00),
                            Color(0xFFCF9E24),
                          ],
                        ),
                      ),
                      child: Icon(
                        Icons.add_rounded,
                        size: 16 * scale,
                        color: const Color(0xFFFFFFFF),
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(width: 12 * scale),

              // Notification Bell (28x28)
              Container(
                width: 28 * scale,
                height: 28 * scale,
                alignment: Alignment.center,
                child: Icon(
                  Icons.notifications_none_rounded,
                  size: 24 * scale,
                  color: const Color(0xFFFFFFFF),
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
// SEARCH BAR (Frame 1000003337 -> Shape: 358x50, radius 16)
// =============================================================================
class _FigmaHomeSearchBar extends StatelessWidget {
  final double scale;

  const _FigmaHomeSearchBar({required this.scale});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 50 * scale,
      padding: EdgeInsets.symmetric(horizontal: 14 * scale),
      decoration: BoxDecoration(
        color: const Color(0x1F767680),
        borderRadius: BorderRadius.circular(16 * scale),
        border: Border.all(
          color: const Color(0x33767680),
          width: 1.0,
        ),
      ),
      child: Row(
        children: [
          // Search Icon (22x22)
          SportoAssetIcon(
            SportoAssets.searchNormal,
            size: 22 * scale,
            color: const Color(0xFFA0A0A0),
          ),

          SizedBox(width: 10 * scale),

          // Hint text
          Expanded(
            child: Text(
              'Search cricket, football..',
              style: TextStyle(
                fontSize: 14 * scale,
                fontWeight: FontWeight.w500,
                color: const Color(0xFFA0A0A0),
              ),
            ),
          ),

          // Divider (1x24)
          Container(
            width: 1 * scale,
            height: 24 * scale,
            color: const Color(0x33767680),
          ),

          SizedBox(width: 10 * scale),

          // Mic Icon
          SportoAssetIcon(
            SportoAssets.mic,
            size: 20 * scale,
            color: const Color(0xFFA0A0A0),
          ),
        ],
      ),
    );
  }
}

// =============================================================================
// OVERVIEW STATS (Frame 1261154190: 350x120)
// =============================================================================
class _FigmaOverviewStats extends StatelessWidget {
  final double scale;
  final int liveCount;
  final int upcomingCount;
  final int assignedCount;
  final int completedCount;
  final int cancelledCount;

  const _FigmaOverviewStats({
    required this.scale,
    required this.liveCount,
    required this.upcomingCount,
    required this.assignedCount,
    required this.completedCount,
    required this.cancelledCount,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Row 1: 3 Metric Cards (each 108x65, radius 12, fill #1B233599)
        Row(
          children: [
            Expanded(
              child: _buildMetricCard(
                count: liveCount.toString(),
                label: 'Live Now',
                dotColor: const Color(0xFF2BB673),
              ),
            ),
            SizedBox(width: 10 * scale),
            Expanded(
              child: _buildMetricCard(
                count: upcomingCount.toString(),
                label: 'Upcoming',
                dotColor: const Color(0xFFFEBD38),
              ),
            ),
            SizedBox(width: 10 * scale),
            Expanded(
              child: _buildMetricCard(
                count: assignedCount.toString(),
                label: 'Assigned',
                dotColor: const Color(0xFF5C93FF),
              ),
            ),
          ],
        ),

        SizedBox(height: 8 * scale),

        // Row 2: Bottom Completed & Cancelled Strip (350x34, radius 12, fill #1B233599)
        Container(
          width: double.infinity,
          height: 34 * scale,
          padding: EdgeInsets.symmetric(horizontal: 14 * scale),
          decoration: BoxDecoration(
            color: const Color(0x991B2335),
            borderRadius: BorderRadius.circular(12 * scale),
            border: Border.all(
              color: const Color(0x265C93FF),
              width: 0.8,
            ),
          ),
          child: Row(
            children: [
              // Completed
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 6 * scale,
                    height: 6 * scale,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Color(0xFF2BB673),
                    ),
                  ),
                  SizedBox(width: 6 * scale),
                  Text.rich(
                    TextSpan(
                      style: TextStyle(
                        fontSize: 12 * scale,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFFA0A0A0),
                      ),
                      children: [
                        const TextSpan(text: 'Completed  '),
                        TextSpan(
                          text: completedCount.toString(),
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            color: Color(0xFFFFFFFF),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const Spacer(),

              // Cancelled
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 6 * scale,
                    height: 6 * scale,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Color(0xFFFE464B),
                    ),
                  ),
                  SizedBox(width: 6 * scale),
                  Text.rich(
                    TextSpan(
                      style: TextStyle(
                        fontSize: 12 * scale,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFFA0A0A0),
                      ),
                      children: [
                        const TextSpan(text: 'Cancelled  '),
                        TextSpan(
                          text: cancelledCount.toString(),
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            color: Color(0xFFFFFFFF),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMetricCard({
    required String count,
    required String label,
    required Color dotColor,
  }) {
    return Container(
      height: 65 * scale,
      padding: EdgeInsets.symmetric(
        horizontal: 8 * scale,
        vertical: 8 * scale,
      ),
      decoration: BoxDecoration(
        color: const Color(0x991B2335),
        borderRadius: BorderRadius.circular(12 * scale),
        border: Border.all(
          color: const Color(0x265C93FF),
          width: 0.8,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            count,
            style: TextStyle(
              fontSize: 22 * scale,
              fontWeight: FontWeight.w700,
              color: const Color(0xFFFFFFFF),
              height: 1.0,
            ),
          ),
          SizedBox(height: 4 * scale),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 6 * scale,
                  height: 6 * scale,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: dotColor,
                  ),
                ),
                SizedBox(width: 4 * scale),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 11 * scale,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFFA0A0A0),
                    height: 1.0,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// =============================================================================
// SECTION 1: LIVE NOW MATCH CARD (Frame 1261154188: 350x206, radius 16)
// =============================================================================
class _FigmaLiveMatchCard extends StatelessWidget {
  final double scale;
  final RefereeMatchResponse match;

  const _FigmaLiveMatchCard({
    required this.scale,
    required this.match,
  });

  @override
  Widget build(BuildContext context) {
    final team1Score =
        match.raw['team_a_score'] ?? match.raw['current_score'] ?? '28/1';
    final team2Score = match.raw['team_b_score'] ?? 'Waiting to Bat';
    final batter = match.raw['current_batter'] ?? 'Rahul';
    final bowler = match.raw['current_bowler'] ?? 'Amit';
    final overs = match.raw['overs_text'] ?? 'Over - 2.1/6';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Live Now Section Header (Red Pulsing Dot + Gradient Text)
        Row(
          children: [
            Container(
              width: 10 * scale,
              height: 10 * scale,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const LinearGradient(
                  colors: [Color(0xFFFF4444), Color(0xFFFF1919)],
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFFF1919).withValues(alpha: 0.5),
                    blurRadius: 6 * scale,
                  ),
                ],
              ),
            ),
            SizedBox(width: 6 * scale),
            _GradientText(
              'Live Now',
              gradient: const LinearGradient(
                colors: [Color(0xFFFE6C6C), Color(0xFFFE464B)],
              ),
              style: TextStyle(
                fontSize: 16 * scale,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),

        SizedBox(height: 10 * scale),

        // Live Card (350x176, radius 16, dual gradient & border)
        Container(
          width: double.infinity,
          padding: EdgeInsets.all(12 * scale),
          decoration: BoxDecoration(
            color: const Color(0x33B40003),
            borderRadius: BorderRadius.circular(16 * scale),
            border: Border.all(
              color: const Color(0x4DF53E02),
              width: 1.0,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0x22B40003),
                blurRadius: 16 * scale,
                offset: Offset(0, 4 * scale),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Tournament Name
              Text(
                match.displayTournament,
                style: TextStyle(
                  fontSize: 14 * scale,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFFFFFFFF),
                ),
              ),

              SizedBox(height: 8 * scale),

              // Matchup & Scores Row
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
                          team1Score,
                          style: TextStyle(
                            fontSize: 15 * scale,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF2BB673),
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
                        color: const Color(0xFFA0A0A0),
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
                          team2Score,
                          textAlign: TextAlign.right,
                          style: TextStyle(
                            fontSize: 12 * scale,
                            fontWeight: FontWeight.w500,
                            color: const Color(0xFFA0A0A0),
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

              SizedBox(height: 8 * scale),

              // Batter & Bowler Row
              Row(
                children: [
                  Expanded(
                    child: Text.rich(
                      TextSpan(
                        style: TextStyle(
                          fontSize: 11 * scale,
                          fontWeight: FontWeight.w500,
                          color: const Color(0xFFA0A0A0),
                        ),
                        children: [
                          const TextSpan(text: 'Current Batter: '),
                          TextSpan(
                            text: batter,
                            style: const TextStyle(
                              fontWeight: FontWeight.w700,
                              color: Color(0xFFFFFFFF),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Expanded(
                    child: Text.rich(
                      textAlign: TextAlign.right,
                      TextSpan(
                        style: TextStyle(
                          fontSize: 11 * scale,
                          fontWeight: FontWeight.w500,
                          color: const Color(0xFFA0A0A0),
                        ),
                        children: [
                          const TextSpan(text: 'Current Bowler: '),
                          TextSpan(
                            text: bowler,
                            style: const TextStyle(
                              fontWeight: FontWeight.w700,
                              color: Color(0xFFFFFFFF),
                            ),
                          ),
                        ],
                      ),
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

              SizedBox(height: 8 * scale),

              // Overs & Continue Scoring Action
              Row(
                children: [
                  Expanded(
                    child: Text(
                      overs,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 13 * scale,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFFA0A0A0),
                      ),
                    ),
                  ),
                  SizedBox(width: 8 * scale),
                  Container(
                    height: 30 * scale,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [
                          Color(0xFF7AD3FF),
                          Color(0xFF4FBAF0),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(10 * scale),
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () {
                          context.push(
                            '${AppRouter.liveScoringRoute}?matchId=${match.id}&matchCode=SPT-${match.id}',
                          );
                        },
                        borderRadius: BorderRadius.circular(10 * scale),
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: 12 * scale,
                          ),
                          child: Center(
                            child: Text(
                              'Continue Scoring',
                              style: TextStyle(
                                fontSize: 12 * scale,
                                fontWeight: FontWeight.w700,
                                color: const Color(0xFF082234),
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
      ],
    );
  }
}

// =============================================================================
// SECTION 2: NEXT MATCH CARD (Frame 1261154189: 350x197, radius 14)
// =============================================================================
class _FigmaNextMatchCard extends StatelessWidget {
  final double scale;
  final RefereeMatchResponse match;

  const _FigmaNextMatchCard({
    required this.scale,
    required this.match,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Next Match Section Header
        Row(
          children: [
            Container(
              width: 10 * scale,
              height: 10 * scale,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Color(0xFFFEBD38),
              ),
            ),
            SizedBox(width: 6 * scale),
            Text(
              'Next Match',
              style: TextStyle(
                fontSize: 16 * scale,
                fontWeight: FontWeight.w600,
                color: const Color(0xFFFEBD38),
              ),
            ),
          ],
        ),

        SizedBox(height: 10 * scale),

        // Match Card (350x167, radius 14, fill #1C2026)
        Container(
          width: double.infinity,
          padding: EdgeInsets.all(12 * scale),
          decoration: BoxDecoration(
            color: const Color(0xFF1C2026),
            borderRadius: BorderRadius.circular(14 * scale),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top Row: Upcoming Pill + Schedule
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    height: 19 * scale,
                    padding: EdgeInsets.symmetric(
                      horizontal: 6 * scale,
                      vertical: 2 * scale,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10 * scale),
                      gradient: const LinearGradient(
                        colors: [
                          Color(0x1AFF9364),
                          Color(0x1AF25F33),
                        ],
                      ),
                    ),
                    child: Center(
                      child: _GradientText(
                        'Upcoming',
                        gradient: const LinearGradient(
                          colors: [
                            Color(0xFFFF9364),
                            Color(0xFFF25F33),
                          ],
                        ),
                        style: TextStyle(
                          fontSize: 11 * scale,
                          fontWeight: FontWeight.w600,
                          height: 1.0,
                        ),
                      ),
                    ),
                  ),
                  Flexible(
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 4 * scale),
                      child: Text(
                        match.displaySchedule,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.right,
                        style: TextStyle(
                          fontSize: 12 * scale,
                          fontWeight: FontWeight.w500,
                          color: const Color(0xFFAAAAAA),
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              SizedBox(height: 8 * scale),

              // Tournament Name
              Text(
                match.displayTournament,
                style: TextStyle(
                  fontSize: 15 * scale,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFFFFFFFF),
                ),
              ),

              SizedBox(height: 2 * scale),

              // Location Row
              Row(
                children: [
                  SportoAssetIcon(
                    SportoAssets.locationPin,
                    size: 13 * scale,
                    color: const Color(0xFFA0A0A0),
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
                        color: const Color(0xFFA0A0A0),
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
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFFA0A0A0),
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

              // Divider
              Container(
                height: 0.8 * scale,
                color: const Color(0xFF283040),
              ),

              SizedBox(height: 8 * scale),

              // Countdown & Verify Teams Action
              Row(
                children: [
                  Expanded(
                    child: FittedBox(
                      alignment: Alignment.centerLeft,
                      fit: BoxFit.scaleDown,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Starts in ',
                            style: TextStyle(
                              fontSize: 13 * scale,
                              fontWeight: FontWeight.w500,
                              color: const Color(0xFFA0A0A0),
                            ),
                          ),
                          Text(
                            '00:28:35',
                            style: TextStyle(
                              fontSize: 13 * scale,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF2BB673),
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
                          Color(0xFF7AD3FF),
                          Color(0xFF4FBAF0),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(10 * scale),
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () {
                          context.push(
                            '${AppRouter.matchVerificationRoute}?matchId=${match.id}',
                          );
                        },
                        borderRadius: BorderRadius.circular(10 * scale),
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: 12 * scale,
                          ),
                          child: Center(
                            child: Text(
                              'Verify Teams',
                              style: TextStyle(
                                fontSize: 12 * scale,
                                fontWeight: FontWeight.w700,
                                color: const Color(0xFF082234),
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
      ],
    );
  }
}

// =============================================================================
// SECTION 3: ASSIGNED MATCHES (Frame 1261154191: 350x197, radius 14)
// =============================================================================
class _FigmaAssignedSectionHeader extends StatelessWidget {
  final double scale;
  final int count;
  final VoidCallback? onViewAll;

  const _FigmaAssignedSectionHeader({
    required this.scale,
    required this.count,
    this.onViewAll,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 10 * scale,
          height: 10 * scale,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: Color(0xFF2BB673),
          ),
        ),
        SizedBox(width: 6 * scale),
        Text(
          'Assigned Matches ($count)',
          style: TextStyle(
            fontSize: 16 * scale,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF2BB673),
          ),
        ),
        const Spacer(),
        if (onViewAll != null)
          GestureDetector(
            onTap: onViewAll,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'View All',
                  style: TextStyle(
                    fontSize: 12 * scale,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFFA0A0A0),
                  ),
                ),
                SizedBox(width: 4 * scale),
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 11 * scale,
                  color: const Color(0xFFA0A0A0),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

class _FigmaAssignedMatchCard extends StatelessWidget {
  final double scale;
  final RefereeMatchResponse match;

  const _FigmaAssignedMatchCard({
    required this.scale,
    required this.match,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(12 * scale),
      decoration: BoxDecoration(
        color: const Color(0xFF1C2026),
        borderRadius: BorderRadius.circular(14 * scale),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top Row: Upcoming Pill + Schedule
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                height: 19 * scale,
                padding: EdgeInsets.symmetric(
                  horizontal: 6 * scale,
                  vertical: 2 * scale,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10 * scale),
                  gradient: const LinearGradient(
                    colors: [
                      Color(0x1AFF9364),
                      Color(0x1AF25F33),
                    ],
                  ),
                ),
                child: Center(
                  child: _GradientText(
                    'Upcoming',
                    gradient: const LinearGradient(
                      colors: [
                        Color(0xFFFF9364),
                        Color(0xFFF25F33),
                      ],
                    ),
                    style: TextStyle(
                      fontSize: 11 * scale,
                      fontWeight: FontWeight.w600,
                      height: 1.0,
                    ),
                  ),
                ),
              ),
              Flexible(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 4 * scale),
                  child: Text(
                    match.displaySchedule,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.right,
                    style: TextStyle(
                      fontSize: 12 * scale,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFFAAAAAA),
                    ),
                  ),
                ),
              ),
            ],
          ),

          SizedBox(height: 8 * scale),

          // Tournament Name
          Text(
            match.displayTournament,
            style: TextStyle(
              fontSize: 15 * scale,
              fontWeight: FontWeight.w600,
              color: const Color(0xFFFFFFFF),
            ),
          ),

          SizedBox(height: 2 * scale),

          // Location
          Row(
            children: [
              SportoAssetIcon(
                SportoAssets.locationPin,
                size: 13 * scale,
                color: const Color(0xFFA0A0A0),
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
                    color: const Color(0xFFA0A0A0),
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
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFFA0A0A0),
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

          // Divider Line
          Container(
            height: 0.8 * scale,
            color: const Color(0xFF283040),
          ),

          SizedBox(height: 8 * scale),

          // Action Button Row
          Align(
            alignment: Alignment.centerRight,
            child: Container(
              height: 30 * scale,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [
                    Color(0xFF7AD3FF),
                    Color(0xFF4FBAF0),
                  ],
                ),
                borderRadius: BorderRadius.circular(10 * scale),
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () {
                    context.push(
                      '${AppRouter.matchVerificationRoute}?matchId=${match.id}',
                    );
                  },
                  borderRadius: BorderRadius.circular(10 * scale),
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: 14 * scale,
                    ),
                    child: Center(
                      child: Text(
                        'Verify Teams',
                        style: TextStyle(
                          fontSize: 12 * scale,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF082234),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// =============================================================================
// SECTION 4: ADS BANNER (Frame 1171275266: 350x60, radius 20)
// =============================================================================
class _FigmaAdsBanner extends StatelessWidget {
  final double scale;

  const _FigmaAdsBanner({required this.scale});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 60 * scale,
      padding: EdgeInsets.symmetric(horizontal: 20 * scale),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFFED7B00),
            Color(0xFFCF9E24),
          ],
        ),
        borderRadius: BorderRadius.circular(20 * scale),
      ),
      child: Row(
        children: [
          Text(
            'Ads Banner',
            style: TextStyle(
              fontSize: 16 * scale,
              fontWeight: FontWeight.w700,
              color: const Color(0xFFFFFFFF),
            ),
          ),
          const Spacer(),
          Container(
            width: 36 * scale,
            height: 36 * scale,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: const Color(0x1AFFFFFF),
              borderRadius: BorderRadius.circular(10 * scale),
            ),
            child: Icon(
              Icons.chevron_right_rounded,
              size: 22 * scale,
              color: const Color(0xFFFFFFFF),
            ),
          ),
        ],
      ),
    );
  }
}

// =============================================================================
// CLEAN EMPTY STATE CARD
// =============================================================================
class _FigmaEmptyMatchesCard extends StatelessWidget {
  final double scale;

  const _FigmaEmptyMatchesCard({required this.scale});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(
        20 * scale,
        24 * scale,
        20 * scale,
        20 * scale,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFF1C2026),
        borderRadius: BorderRadius.circular(24 * scale),
      ),
      child: Column(
        children: [
          Container(
            width: 64 * scale,
            height: 64 * scale,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFF252B38),
              border: Border.all(
                color: const Color(0xFF373E52),
                width: 1.5,
              ),
            ),
            child: Icon(
              Icons.sports_cricket_rounded,
              size: 32 * scale,
              color: const Color(0xFFFEBD38),
            ),
          ),
          SizedBox(height: 14 * scale),
          Text(
            'No Assigned Matches',
            style: TextStyle(
              fontSize: 16 * scale,
              fontWeight: FontWeight.w700,
              color: const Color(0xFFFFFFFF),
            ),
          ),
          SizedBox(height: 6 * scale),
          Text(
            'Enjoy your day!',
            style: TextStyle(
              fontSize: 13 * scale,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF2BB673),
            ),
          ),
          SizedBox(height: 16 * scale),
          Container(
            height: 0.8 * scale,
            color: const Color(0xFF283040),
          ),
          SizedBox(height: 14 * scale),
          Text(
            'We\'ll notify you when new matches are assigned.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12 * scale,
              fontWeight: FontWeight.w500,
              color: const Color(0xFFA0A0A0),
            ),
          ),
        ],
      ),
    );
  }
}

// =============================================================================
// ERROR CARD
// =============================================================================
class _HomeErrorCard extends StatelessWidget {
  final double scale;
  final String message;
  final VoidCallback onRetry;

  const _HomeErrorCard({
    required this.scale,
    required this.message,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(18 * scale),
      decoration: BoxDecoration(
        color: const Color(0xFF1C2026),
        borderRadius: BorderRadius.circular(16 * scale),
        border: Border.all(
          color: const Color(0xFFFE464B).withValues(alpha: 0.4),
        ),
      ),
      child: Column(
        children: [
          Text(
            'Unable to load assigned matches',
            style: TextStyle(
              fontSize: 15 * scale,
              fontWeight: FontWeight.w700,
              color: const Color(0xFFFFFFFF),
            ),
          ),
          SizedBox(height: 8 * scale),
          Text(
            message,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12 * scale,
              color: const Color(0xFFA0A0A0),
            ),
          ),
          SizedBox(height: 14 * scale),
          FilledButton(
            onPressed: onRetry,
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFF2BB673),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10 * scale),
              ),
            ),
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }
}

// =============================================================================
// HIGH-FIDELITY SKELETON SHIMMER (Matching Figma Layout)
// =============================================================================
class _RefereeHomeSkeletonShimmer extends StatefulWidget {
  final double scale;

  const _RefereeHomeSkeletonShimmer({required this.scale});

  @override
  State<_RefereeHomeSkeletonShimmer> createState() =>
      _RefereeHomeSkeletonShimmerState();
}

class _RefereeHomeSkeletonShimmerState
    extends State<_RefereeHomeSkeletonShimmer>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);
    _animation = Tween<double>(begin: 0.25, end: 0.65).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Widget _shimmerBox({
    required double width,
    required double height,
    double radius = 8,
  }) {
    final s = widget.scale;
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, _) {
        return Container(
          width: width * s,
          height: height * s,
          decoration: BoxDecoration(
            color: Color(0xFF283040).withValues(alpha: _animation.value),
            borderRadius: BorderRadius.circular(radius * s),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final s = widget.scale;

    return SingleChildScrollView(
      physics: const NeverScrollableScrollPhysics(),
      padding: EdgeInsets.fromLTRB(20 * s, 12 * s, 20 * s, 40 * s),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Shimmer
          Row(
            children: [
              _shimmerBox(width: 38, height: 38, radius: 19),
              SizedBox(width: 10 * s),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _shimmerBox(width: 80, height: 12),
                  SizedBox(height: 6 * s),
                  _shimmerBox(width: 120, height: 16),
                ],
              ),
              const Spacer(),
              _shimmerBox(width: 85, height: 24, radius: 6),
            ],
          ),

          SizedBox(height: 14 * s),

          // Search Bar Shimmer
          _shimmerBox(width: 350, height: 50, radius: 16),

          SizedBox(height: 18 * s),

          // Stats Shimmer (3 cards)
          Row(
            children: [
              Expanded(child: _shimmerBox(width: 108, height: 65, radius: 12)),
              SizedBox(width: 10 * s),
              Expanded(child: _shimmerBox(width: 108, height: 65, radius: 12)),
              SizedBox(width: 10 * s),
              Expanded(child: _shimmerBox(width: 108, height: 65, radius: 12)),
            ],
          ),

          SizedBox(height: 8 * s),

          _shimmerBox(width: 350, height: 34, radius: 12),

          SizedBox(height: 20 * s),

          // Section Title Shimmer
          _shimmerBox(width: 100, height: 18),

          SizedBox(height: 10 * s),

          // Live / Next Match Card Shimmer
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(12 * s),
            decoration: BoxDecoration(
              color: const Color(0xFF1C2026),
              borderRadius: BorderRadius.circular(14 * s),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _shimmerBox(width: 70, height: 19, radius: 10),
                    _shimmerBox(width: 90, height: 14),
                  ],
                ),
                SizedBox(height: 10 * s),
                _shimmerBox(width: 160, height: 16),
                SizedBox(height: 8 * s),
                _shimmerBox(width: 100, height: 12),
                SizedBox(height: 12 * s),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _shimmerBox(width: 100, height: 16),
                    _shimmerBox(width: 20, height: 14),
                    _shimmerBox(width: 100, height: 16),
                  ],
                ),
                SizedBox(height: 12 * s),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _shimmerBox(width: 120, height: 14),
                    _shimmerBox(width: 108, height: 30, radius: 10),
                  ],
                ),
              ],
            ),
          ),

          SizedBox(height: 20 * s),

          // Banner Shimmer
          _shimmerBox(width: 350, height: 60, radius: 20),
        ],
      ),
    );
  }
}

// =============================================================================
// REUSABLE GRADIENT TEXT (Inherits Theme Quicksand)
// =============================================================================
class _GradientText extends StatelessWidget {
  final String text;
  final TextStyle? style;
  final Gradient gradient;

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
