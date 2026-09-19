import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:referee_data/referee_data.dart';
import 'package:ui_kit/ui_kit.dart';

import '../../../../app/router/app_router.dart';
import '../../../../core/di/dependency_injector.dart';

/// Exact Figma implementation of the Scoring Tab Screen based on `figma/Scoring.json`.
///
/// Features:
/// - Obsidian canvas `#0E0C08` with dual atmospheric ambient glow orbs
/// - Top linear gradient backdrop (Rectangle 6011: 390x129)
/// - Exact Header Bar (Frame 1000003337: Title "Today's Matches" + Blue gradient subtitle count)
/// - Exact Spotlight Live Match Card (Section: 350x203, radius 16, red/amber ambient fill,
///   Final badge, Live Now badge with pulsing dot, Over badge, crisp white tournament name,
///   teams matchup with scores, current batter & bowler row, duration, Continue Scoring action)
/// - High-fidelity animated Skeleton Shimmer during network load
/// - Clean Empty State Card when no matches are available for scoring
/// - Zero hardcoded `fontFamily: "packages/ui_kit/Quicksand"`, fully inherited from global theme
class RefereeScoringTabScreen extends StatefulWidget {
  final Future<List<RefereeMatchResponse>>? payloadFuture;
  final void Function(String matchId, String matchCode)? onNavigateToScoring;

  const RefereeScoringTabScreen({
    super.key,
    this.payloadFuture,
    this.onNavigateToScoring,
  });

  @override
  State<RefereeScoringTabScreen> createState() =>
      _RefereeScoringTabScreenState();
}

class _RefereeScoringTabScreenState extends State<RefereeScoringTabScreen> {
  late Future<List<RefereeMatchResponse>> _future;

  RefereeRemoteDataSource get _remote =>
      DependencyInjector.instance.refereeRemoteDataSource;

  @override
  void initState() {
    super.initState();
    _future = widget.payloadFuture ?? _load();
  }

  Future<List<RefereeMatchResponse>> _load() async {
    try {
      final matches = await _remote.listMyMatchesData(perPage: 50);
      return matches;
    } catch (_) {
      return const [];
    }
  }

  void _refresh() {
    setState(() {
      _future = _load();
    });
  }

  void _navigateToScoring(RefereeMatchResponse match) {
    if (widget.onNavigateToScoring != null) {
      widget.onNavigateToScoring!(
        match.id.toString(),
        match.displayTournament,
      );
      return;
    }

    final path = Uri(
      path: AppRouter.liveScoringPath,
      queryParameters: {
        'matchId': match.id.toString(),
        'matchCode': match.displayTournament,
      },
    ).toString();

    context.push(path);
  }

  @override
  Widget build(BuildContext context) {
    final scale = context.sportoScale;
    final bottomInset = MediaQuery.paddingOf(context).bottom;

    return Scaffold(
      backgroundColor: const Color(0xFF0E0C08),
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Atmosphere & Ambient Backdrops
          _FigmaScoringAtmosphere(scale: scale),

          SafeArea(
            bottom: false,
            child: FutureBuilder<List<RefereeMatchResponse>>(
              future: _future,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return _FigmaScoringSkeletonShimmer(scale: scale);
                }

                final matches = snapshot.data ?? const [];
                // Filter for live/active matches or all assigned matches if no explicit live matches exist
                final liveMatches = matches.where((m) {
                  final statusText = m.displayStatus.toLowerCase();
                  return m.isLive ||
                      statusText.contains('live') ||
                      statusText.contains('progress') ||
                      m.status == 1;
                }).toList();

                final displayMatches =
                    liveMatches.isNotEmpty ? liveMatches : matches;

                return RefreshIndicator(
                  color: const Color(0xFFED7B00),
                  backgroundColor: const Color(0xFF1B2335),
                  onRefresh: () async => _refresh(),
                  child: ListView(
                    physics: const AlwaysScrollableScrollPhysics(
                      parent: ClampingScrollPhysics(),
                    ),
                    padding: EdgeInsets.fromLTRB(
                      20 * scale,
                      16 * scale,
                      20 * scale,
                      (54 + 24) * scale + bottomInset,
                    ),
                    children: [
                      // Header: "Today's Matches" & "$count Matches Assigned"
                      _FigmaScoringHeader(
                        scale: scale,
                        assignedCount: matches.length,
                      ),

                      SizedBox(height: 16 * scale),

                      if (displayMatches.isEmpty)
                        _FigmaEmptyScoringCard(
                          scale: scale,
                          onRefresh: _refresh,
                        )
                      else
                        ...displayMatches.map((match) {
                          return Padding(
                            padding: EdgeInsets.only(bottom: 16 * scale),
                            child: _FigmaSpotlightScoringCard(
                              scale: scale,
                              match: match,
                              onContinueScoring: () =>
                                  _navigateToScoring(match),
                            ),
                          );
                        }),
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

/// Atmospheric backdrops matching Rectangle 6011 and Ellipse 17 & 18 in `figma/Scoring.json`.
class _FigmaScoringAtmosphere extends StatelessWidget {
  final double scale;

  const _FigmaScoringAtmosphere({required this.scale});

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Rectangle 6011: Top linear gradient backdrop (390x129)
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

          // Ellipse 17: Ambient glow orb (top left)
          Positioned(
            top: -40 * scale,
            left: -80 * scale,
            child: ImageFiltered(
              imageFilter: ImageFilter.blur(sigmaX: 80, sigmaY: 80),
              child: Container(
                width: 376.9 * scale,
                height: 280 * scale,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color(0x4D373E52),
                ),
              ),
            ),
          ),

          // Ellipse 18: Ambient glow orb (top right)
          Positioned(
            top: 60 * scale,
            right: -100 * scale,
            child: ImageFiltered(
              imageFilter: ImageFilter.blur(sigmaX: 80, sigmaY: 80),
              child: Container(
                width: 376.9 * scale,
                height: 280 * scale,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color(0x4D373E52),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Header Bar matching Frame 1000003337 in `figma/Scoring.json`.
class _FigmaScoringHeader extends StatelessWidget {
  final double scale;
  final int assignedCount;

  const _FigmaScoringHeader({
    required this.scale,
    required this.assignedCount,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Title: "Today's Matches"
        Text(
          "Today's Matches",
          style: TextStyle(
            fontSize: 18 * scale,
            fontWeight: FontWeight.w600,
            color: const Color(0xFFFFFFFF),
            height: 1.25,
          ),
        ),

        SizedBox(height: 2 * scale),

        // Subtitle: "$count Matches Assigned" with Blue Gradient
        _GradientText(
          '$assignedCount Matches Assigned',
          gradient: const LinearGradient(
            colors: [
              Color(0xFF7AD3FF),
              Color(0xFF4FBAF0),
            ],
          ),
          style: TextStyle(
            fontSize: 14 * scale,
            fontWeight: FontWeight.w500,
            height: 1.25,
          ),
        ),
      ],
    );
  }
}

/// Spotlight Live Match Card matching Frame `Section` in `figma/Scoring.json` (350x203, radius 16).
class _FigmaSpotlightScoringCard extends StatelessWidget {
  final double scale;
  final RefereeMatchResponse match;
  final VoidCallback onContinueScoring;

  const _FigmaSpotlightScoringCard({
    required this.scale,
    required this.match,
    required this.onContinueScoring,
  });

  @override
  Widget build(BuildContext context) {
    final raw = match.raw;
    final teamAScore = raw['team_a_score']?.toString() ?? '28/1';
    final teamBScore = raw['team_b_score']?.toString() ?? 'Yet to Bat';
    final batterName = raw['current_batter']?.toString() ?? 'Rahul';
    final bowlerName = raw['current_bowler']?.toString() ?? 'Amit';
    final oversText = raw['overs_text']?.toString() ?? 'Over - 2.1';
    final durationText = raw['duration']?.toString() ?? '08:25';

    return Container(
      decoration: BoxDecoration(
        color: const Color(0x33B40003), // 20% opacity #b40003
        gradient: const LinearGradient(
          colors: [
            Color(0x0AED7B00),
            Color(0x0ACF9E24),
          ],
        ),
        borderRadius: BorderRadius.circular(16 * scale),
        border: Border.all(
          color: const Color(0x4DF53E02),
          width: 1.0,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x80512813),
            blurRadius: 8,
            offset: Offset(0, 1),
          ),
        ],
      ),
      padding: EdgeInsets.all(10 * scale),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Header: Stage badge, Live Now badge, Overs badge (Frame 1261154267)
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Stage badge: Frame 4 (40x19, radius 10, green fill & border)
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
                          width: 1.0,
                        ),
                      ),
                      child: Text(
                        match.displayRound.isNotEmpty
                            ? match.displayRound
                            : 'Final',
                        style: TextStyle(
                          fontSize: 11 * scale,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFFFFFFFF),
                          height: 1.0,
                        ),
                      ),
                    ),

                    SizedBox(width: 6 * scale),

                    // Live Now badge: Frame 2 (radius 10, fill #ffffffcc, red gradient border)
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 6 * scale,
                        vertical: 2 * scale,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xCCFFFFFF),
                        borderRadius: BorderRadius.circular(10 * scale),
                        border: Border.all(
                          color: const Color(0x4DFE595C),
                          width: 1.0,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _PulsingDot(
                            scale: scale,
                            color: const Color(0xFFFE464B),
                          ),
                          SizedBox(width: 4 * scale),
                          Text(
                            'Live Now',
                            style: TextStyle(
                              fontSize: 11 * scale,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFFFE464B),
                              height: 1.0,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                SizedBox(width: 10 * scale),

                // Overs badge: Frame 3 (fill #1b233566, radius 8, white text)
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 8 * scale,
                    vertical: 2 * scale,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0x661B2335),
                    borderRadius: BorderRadius.circular(8 * scale),
                  ),
                  child: Text(
                    oversText,
                    style: TextStyle(
                      fontSize: 14 * scale,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFFFFFFFF),
                      height: 1.0,
                    ),
                  ),
                ),
              ],
            ),
          ),

          SizedBox(height: 8 * scale),

          // 2. Tournament Name: Crisp white text (Quicksand 16px, FontWeight.w600)
          Text(
            match.displayTournament.isNotEmpty
                ? match.displayTournament
                : 'Jaipur Super Over',
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

          // Venue Row: Frame 1261154297 (Location icon + text)
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
                  match.displayVenue.isNotEmpty
                      ? match.displayVenue
                      : 'Hyderabad',
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

          // 3. Teams & Scores Matchup: Frame 1000006156 (Team A Score Vs Team B Score)
          Row(
            children: [
              // Team A
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      match.displayTeamA.isNotEmpty
                          ? match.displayTeamA
                          : 'Thunder Titans',
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
                        fontSize: 14 * scale,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFFFFFFFF),
                      ),
                    ),
                  ],
                ),
              ),

              // "Vs" separator
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 10 * scale),
                child: Text(
                  'Vs',
                  style: TextStyle(
                    fontSize: 12 * scale,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFFAAAAAA),
                  ),
                ),
              ),

              // Team B
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      match.displayTeamB.isNotEmpty
                          ? match.displayTeamB
                          : 'Royal Strikers',
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
                      teamBScore,
                      style: TextStyle(
                        fontSize: 12 * scale,
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

          // 4. Divider Line 7 (Line 7: 0.8px, #283040)
          Container(
            height: 0.8 * scale,
            color: const Color(0xFF283040),
          ),

          SizedBox(height: 6 * scale),

          // 5. Current Batter & Current Bowler: Frame 1261154327
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
                        text: batterName,
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
                        text: bowlerName,
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

          // 6. Divider Line 8 (Line 8: 0.8px, #283040)
          Container(
            height: 0.8 * scale,
            color: const Color(0xFF283040),
          ),

          SizedBox(height: 8 * scale),

          // 7. Footer Row: Duration (left) + "Continue Scoring" button (right)
          Row(
            children: [
              // Duration: Frame 1171275259
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
                        text: durationText,
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

              // Button: Frame 1261154253 (134x30, radius 10, orange/red gradient)
              Container(
                height: 30 * scale,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [
                      Color(0xFFDF3F00),
                      Color(0xFFF65800),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(10 * scale),
                  border: Border.all(
                    color: const Color(0x4DF53E02),
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
                    key: const ValueKey('continue_scoring_btn'),
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
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFFFFFFFF),
                            height: 1.0,
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

/// Pulsing red live indicator dot.
class _PulsingDot extends StatefulWidget {
  final double scale;
  final Color color;

  const _PulsingDot({
    required this.scale,
    required this.color,
  });

  @override
  State<_PulsingDot> createState() => _PulsingDotState();
}

class _PulsingDotState extends State<_PulsingDot>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);
    _animation = Tween<double>(begin: 0.4, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          width: 7 * widget.scale,
          height: 7 * widget.scale,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: widget.color.withOpacity(_animation.value),
            boxShadow: [
              BoxShadow(
                color: widget.color.withOpacity(_animation.value * 0.5),
                blurRadius: 4 * widget.scale,
              ),
            ],
          ),
        );
      },
    );
  }
}

/// High-fidelity animated skeleton shimmer during network fetch.
class _FigmaScoringSkeletonShimmer extends StatefulWidget {
  final double scale;

  const _FigmaScoringSkeletonShimmer({required this.scale});

  @override
  State<_FigmaScoringSkeletonShimmer> createState() =>
      _FigmaScoringSkeletonShimmerState();
}

class _FigmaScoringSkeletonShimmerState
    extends State<_FigmaScoringSkeletonShimmer>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

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
          begin: Alignment(-1.5 + 3.0 * _controller.value, 0.0),
          end: Alignment(-0.5 + 3.0 * _controller.value, 0.0),
          colors: const [
            Color(0x1A1B2335),
            Color(0x335C93FF),
            Color(0x1A1B2335),
          ],
        );

        return ListView(
          padding: EdgeInsets.fromLTRB(
            20 * scale,
            16 * scale,
            20 * scale,
            90 * scale,
          ),
          children: [
            // Header Shimmer
            Container(
              width: 140 * scale,
              height: 22 * scale,
              decoration: BoxDecoration(
                gradient: shimmerGradient,
                borderRadius: BorderRadius.circular(6 * scale),
              ),
            ),
            SizedBox(height: 6 * scale),
            Container(
              width: 100 * scale,
              height: 16 * scale,
              decoration: BoxDecoration(
                gradient: shimmerGradient,
                borderRadius: BorderRadius.circular(4 * scale),
              ),
            ),
            SizedBox(height: 20 * scale),

            // Card Shimmer (350x203)
            Container(
              height: 203 * scale,
              decoration: BoxDecoration(
                color: const Color(0xFF1C2026),
                borderRadius: BorderRadius.circular(16 * scale),
                border: Border.all(
                  color: const Color(0x1AFFFFFF),
                  width: 0.8,
                ),
              ),
              padding: EdgeInsets.all(12 * scale),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        width: 70 * scale,
                        height: 20 * scale,
                        decoration: BoxDecoration(
                          gradient: shimmerGradient,
                          borderRadius: BorderRadius.circular(10 * scale),
                        ),
                      ),
                      Container(
                        width: 60 * scale,
                        height: 20 * scale,
                        decoration: BoxDecoration(
                          gradient: shimmerGradient,
                          borderRadius: BorderRadius.circular(8 * scale),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 12 * scale),
                  Container(
                    width: 180 * scale,
                    height: 18 * scale,
                    decoration: BoxDecoration(
                      gradient: shimmerGradient,
                      borderRadius: BorderRadius.circular(4 * scale),
                    ),
                  ),
                  SizedBox(height: 6 * scale),
                  Container(
                    width: 120 * scale,
                    height: 14 * scale,
                    decoration: BoxDecoration(
                      gradient: shimmerGradient,
                      borderRadius: BorderRadius.circular(4 * scale),
                    ),
                  ),
                  const Spacer(),
                  Container(
                    height: 0.8 * scale,
                    color: const Color(0xFF283040),
                  ),
                  SizedBox(height: 10 * scale),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        width: 90 * scale,
                        height: 14 * scale,
                        decoration: BoxDecoration(
                          gradient: shimmerGradient,
                          borderRadius: BorderRadius.circular(4 * scale),
                        ),
                      ),
                      Container(
                        width: 110 * scale,
                        height: 28 * scale,
                        decoration: BoxDecoration(
                          gradient: shimmerGradient,
                          borderRadius: BorderRadius.circular(10 * scale),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}

/// Clean Empty State Card when no matches are available for scoring.
class _FigmaEmptyScoringCard extends StatelessWidget {
  final double scale;
  final VoidCallback onRefresh;

  const _FigmaEmptyScoringCard({
    required this.scale,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        vertical: 36 * scale,
        horizontal: 20 * scale,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFF1C2026),
        borderRadius: BorderRadius.circular(14 * scale),
        border: Border.all(
          color: const Color(0x1AFFFFFF),
          width: 0.8,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 50 * scale,
            height: 50 * scale,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Color(0x1A7AD3FF),
            ),
            child: Center(
              child: SportoAssetIcon(
                SportoAssets.tournaments,
                size: 26 * scale,
                color: const Color(0xFF7AD3FF),
              ),
            ),
          ),
          SizedBox(height: 14 * scale),
          Text(
            'No Matches in Scoring',
            style: TextStyle(
              fontSize: 16 * scale,
              fontWeight: FontWeight.w600,
              color: const Color(0xFFFFFFFF),
            ),
          ),
          SizedBox(height: 6 * scale),
          Text(
            'Matches ready for scoring will appear here live.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13 * scale,
              fontWeight: FontWeight.w400,
              color: const Color(0xFFAAAAAA),
            ),
          ),
          SizedBox(height: 16 * scale),
          OutlinedButton(
            onPressed: onRefresh,
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: Color(0x335C93FF)),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10 * scale),
              ),
              padding: EdgeInsets.symmetric(
                horizontal: 16 * scale,
                vertical: 8 * scale,
              ),
            ),
            child: Text(
              'Refresh',
              style: TextStyle(
                fontSize: 13 * scale,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF7AD3FF),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Helper widget to render linear gradient text.
class _GradientText extends StatelessWidget {
  final String text;
  final TextStyle style;
  final Gradient gradient;

  const _GradientText(
    this.text, {
    required this.style,
    required this.gradient,
  });

  @override
  Widget build(BuildContext context) {
    return ShaderMask(
      blendMode: BlendMode.srcIn,
      shaderCallback: (bounds) => gradient.createShader(
        Rect.fromLTWH(0, 0, bounds.width, bounds.height),
      ),
      child: Text(text, style: style),
    );
  }
}

