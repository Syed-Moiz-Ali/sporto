import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_domain/shared_domain.dart';
import 'package:ui_kit/ui_kit.dart';

import '../../../../app/router/app_router.dart';
import '../../application/match_scoring_bloc.dart';

/// Exact Figma copy of the Match Verification Screen based on Match_Verification.json.
///
/// Implements:
/// - Obsidian #0E0C08 canvas with dual 200px blurred glow ellipses and top gradient
/// - Glassmorphic 36x36 back button with Quicksand typography header
/// - Section 0: Exact Figma Match Summary Card (Stage badge, upcoming gradient badge, divider, countdown)
/// - Section 1: Exact Split Team Verification Cards (Asymmetric 14-14-4-4 and 4-4-14-14 corners, roster, actions)
/// - Section 2: Exact Figma Final Checklist Card (17x17 custom checkboxes)
/// - Section 3: Exact Absent / Grace Period Expired Card with red gradient title
/// - Section 4: Exact 270x48 Centered Action Buttons (Dual drop shadows, amber gradient secondary)
/// - Skeleton Shimmer state during loading
class MatchVerificationScreen extends StatefulWidget {
  final String? matchId;
  final CricketMatchEntity? match;

  const MatchVerificationScreen({
    super.key,
    this.matchId,
    this.match,
  });

  @override
  State<MatchVerificationScreen> createState() =>
      _MatchVerificationScreenState();
}

class _MatchVerificationScreenState extends State<MatchVerificationScreen> {
  // Check-in states for teams
  bool _team1Present = true;
  bool _team2Present = true;
  final bool _tossDone = false;

  @override
  void initState() {
    super.initState();
    if (widget.match == null && widget.matchId != null) {
      try {
        context.read<MatchScoringBloc>().add(
              LoadMatchDetailEvent(widget.matchId!),
            );
      } catch (_) {}
    }
  }

  // ==========================================================
  // DERIVED STATE & ACTIONS
  // ==========================================================

  bool get _bothTeamsReady => _team1Present && _team2Present;
  bool get _hasAbsentTeam => !_team1Present || !_team2Present;

  void _awardWalkover(String winner) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(
            'Walkover awarded to $winner',
            style: const TextStyle(
              fontWeight: FontWeight.w600,
            ),
          ),
          backgroundColor: const Color(0xFF2BB673),
        ),
      );
  }

  void _confirmAbsent(String absentTeam) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(
            '$absentTeam marked absent',
            style: const TextStyle(
              fontWeight: FontWeight.w600,
            ),
          ),
          backgroundColor: const Color(0xFFFE464B),
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    final scale = context.sportoScale;

    if (widget.match != null) {
      return _buildScaffold(context, scale, widget.match, false);
    }

    return BlocBuilder<MatchScoringBloc, MatchScoringState>(
      builder: (context, state) {
        final isLoading = state is MatchScoringLoadingState;
        final currentMatch =
            state is MatchScoringLoadedState ? state.match : null;
        return _buildScaffold(context, scale, currentMatch, isLoading);
      },
    );
  }

  Widget _buildScaffold(
    BuildContext context,
    double scale,
    CricketMatchEntity? currentMatch,
    bool isLoading,
  ) {

        // Match properties with fallbacks matching Figma JSON
        final matchCode = currentMatch != null
            ? 'SPT-${currentMatch.id}'
            : (widget.matchId != null ? 'SPT-${widget.matchId}' : 'SPT-20481');

        final tournamentName =
            currentMatch?.tournamentName ?? 'Asia Cup 2026';
        final venueName = currentMatch?.venue ?? 'Hyderabad';

        final team1Name = currentMatch?.teamA.name ?? 'Delhi Warriors';
        final team2Name = currentMatch?.teamB.name ?? 'Hyd Highlanders';

        // Extract players or fallback to Figma design list
        final List<String> team1Players = (currentMatch?.teamA.players != null &&
                currentMatch!.teamA.players.isNotEmpty)
            ? currentMatch.teamA.players.map((p) {
                final isCap = p.role.toLowerCase() == 'captain';
                return isCap ? '${p.name} (Captain)' : p.name;
              }).toList()
            : const [
                'Shrvn Prajapati (Captain)',
                'Amit Kumar',
                'Manish K',
                'Sumit Nai',
                'Mayank S',
              ];

        final List<String> team2Players = (currentMatch?.teamB.players != null &&
                currentMatch!.teamB.players.isNotEmpty)
            ? currentMatch.teamB.players.map((p) {
                final isCap = p.role.toLowerCase() == 'captain';
                return isCap ? '${p.name} (Captain)' : p.name;
              }).toList()
            : const [
                'Vikram Reddy (Captain)',
                'Dev Kumar',
                'Pankaj S',
                'Rohan A',
                'Vinayak L',
              ];

        final absentTeamLabel = !_team1Present ? 'Team 1' : 'Team 2';
        final absentTeamName = !_team1Present ? team1Name : team2Name;
        final walkoverWinner = !_team1Present ? team2Name : team1Name;

        return Scaffold(
          backgroundColor: const Color(0xFF0E0C08),
          body: Stack(
            children: [
              // ====================================================
              // FIGMA ATMOSPHERE & BACKGROUND
              // ====================================================

              // Ambient Top Header Gradient (Rectangle 6011: 390x129)
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
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: const Color(0xFF373E52).withValues(alpha: 0.30),
                    ),
                  ),
                ),
              ),

              // Ambient Glow Ellipse 18 (Lower body)
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
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: const Color(0xFF373E52).withValues(alpha: 0.30),
                    ),
                  ),
                ),
              ),

              // ====================================================
              // FOREGROUND CONTENT
              // ====================================================
              SafeArea(
                bottom: false,
                child: Column(
                  children: [
                    // Figma AppBar Header (Frame 1000003336: 390x46)
                    _FigmaAppBar(
                      scale: scale,
                      matchCode: matchCode,
                      onBack: () {
                        if (context.canPop()) {
                          context.pop();
                        }
                      },
                    ),

                    // Scrollable Body (Frame 1261154190: padding 20, gap 20)
                    Expanded(
                      child: isLoading
                          ? _FigmaSkeletonShimmer(scale: scale)
                          : SingleChildScrollView(
                              physics: const ClampingScrollPhysics(),
                              padding: EdgeInsets.fromLTRB(
                                20 * scale,
                                16 * scale,
                                20 * scale,
                                40 * scale,
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // SECTION 0: Match Summary Card
                                  _FigmaMatchSummaryCard(
                                    scale: scale,
                                    tournamentName: tournamentName,
                                    venueName: venueName,
                                    team1: team1Name,
                                    team2: team2Name,
                                  ),

                                  SizedBox(height: 20 * scale),

                                  // SECTION 1: Team Verification Title
                                  Text(
                                    'Team Verification',
                                    style: TextStyle(
                                      fontSize: 16 * scale,
                                      fontWeight: FontWeight.w600,
                                      color: const Color(0xFFA0A0A0),
                                    ),
                                  ),

                                  SizedBox(height: 10 * scale),

                                  // Team 1 Split Card
                                  _FigmaSplitTeamCard(
                                    scale: scale,
                                    teamLabel: 'Team 1',
                                    teamName: team1Name,
                                    players: team1Players,
                                    isPresent: _team1Present,
                                    onMarkPresent: () {
                                      setState(() {
                                        _team1Present = true;
                                      });
                                    },
                                    onMarkAbsent: () {
                                      setState(() {
                                        _team1Present = false;
                                      });
                                    },
                                  ),

                                  SizedBox(height: 10 * scale),

                                  // Team 2 Split Card
                                  _FigmaSplitTeamCard(
                                    scale: scale,
                                    teamLabel: 'Team 2',
                                    teamName: team2Name,
                                    players: team2Players,
                                    isPresent: _team2Present,
                                    onMarkPresent: () {
                                      setState(() {
                                        _team2Present = true;
                                      });
                                    },
                                    onMarkAbsent: () {
                                      setState(() {
                                        _team2Present = false;
                                      });
                                    },
                                  ),

                                  SizedBox(height: 20 * scale),

                                  // SECTION 2: Final Checklist Title
                                  Text(
                                    'Final Checklist',
                                    style: TextStyle(
                                      fontSize: 16 * scale,
                                      fontWeight: FontWeight.w600,
                                      color: const Color(0xFFA0A0A0),
                                    ),
                                  ),

                                  SizedBox(height: 10 * scale),

                                  // Final Checklist Card
                                  _FigmaFinalChecklistCard(
                                    scale: scale,
                                    team1Checked: _team1Present,
                                    team2Checked: _team2Present,
                                    tossChecked: _tossDone,
                                  ),

                                  // SECTION 3: Absent Decision Card (If any team absent)
                                  if (_hasAbsentTeam) ...[
                                    SizedBox(height: 20 * scale),
                                    _FigmaAbsentDecisionCard(
                                      scale: scale,
                                      absentTeamLabel: absentTeamLabel,
                                      absentTeamName: absentTeamName,
                                      team1Checked: _team1Present,
                                      team2Checked: _team2Present,
                                    ),
                                  ],

                                  SizedBox(height: 24 * scale),

                                  // SECTION 4: Bottom Action Buttons
                                  _FigmaBottomActionButtons(
                                    scale: scale,
                                    bothTeamsReady: _bothTeamsReady,
                                    hasAbsentTeam: _hasAbsentTeam,
                                    walkoverWinner: walkoverWinner,
                                    absentTeamName: absentTeamName,
                                    onReadyToToss: () {
                                      context.push(
                                        '${AppRouter.conductTossRoute}?matchId=${widget.matchId ?? ''}',
                                      );
                                    },
                                    onAwardWalkover: () {
                                      _awardWalkover(walkoverWinner);
                                    },
                                    onMarkAbsent: () {
                                      _confirmAbsent(absentTeamName);
                                    },
                                  ),
                                ],
                              ),
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
// FIGMA APP BAR (Frame 1000003336: 390x46)
// =============================================================================
class _FigmaAppBar extends StatelessWidget {
  final double scale;
  final String matchCode;
  final VoidCallback onBack;

  const _FigmaAppBar({
    required this.scale,
    required this.matchCode,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      constraints: BoxConstraints(minHeight: 46 * scale),
      padding: EdgeInsets.symmetric(
        horizontal: 20 * scale,
        vertical: 4 * scale,
      ),
      child: Row(
        children: [
          // Glassmorphic Back Button (36x36, cornerRadius: 10)
          Container(
            width: 36 * scale,
            height: 36 * scale,
            decoration: BoxDecoration(
              color: const Color(0x1AFFFFFF),
              borderRadius: BorderRadius.circular(10 * scale),
              boxShadow: [
                BoxShadow(
                  color: const Color(0x1F000000),
                  blurRadius: 4 * scale,
                  offset: Offset(0, 2 * scale),
                ),
              ],
            ),
            clipBehavior: Clip.antiAlias,
            child: BackdropFilter(
              filter: ImageFilter.blur(
                sigmaX: 10 * scale,
                sigmaY: 10 * scale,
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: onBack,
                  child: Center(
                    child: Icon(
                      Icons.chevron_left_rounded,
                      size: 24 * scale,
                      color: const Color(0xFFFFFFFF),
                      shadows: [
                        Shadow(
                          color: const Color(0x33000000),
                          blurRadius: 2 * scale,
                          offset: Offset(0, 1 * scale),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),

          SizedBox(width: 10 * scale),

          // Header Title & Subtitle Column (Frame 1000003337)
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Match Verification',
                  style: TextStyle(
                    fontSize: 18 * scale,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFFFFFFFF),
                    height: 1.2,
                  ),
                ),
                Text(
                  'Match #$matchCode',
                  style: TextStyle(
                    fontSize: 12 * scale,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFFFFFFFF),
                    height: 1.2,
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
// SECTION 0: FIGMA MATCH SUMMARY CARD (Section: 350x141)
// =============================================================================
class _FigmaMatchSummaryCard extends StatelessWidget {
  final double scale;
  final String tournamentName;
  final String venueName;
  final String team1;
  final String team2;

  const _FigmaMatchSummaryCard({
    required this.scale,
    required this.tournamentName,
    required this.venueName,
    required this.team1,
    required this.team2,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(10 * scale),
      decoration: BoxDecoration(
        color: const Color(0xFF1C2026),
        borderRadius: BorderRadius.circular(14 * scale),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Row 1: Stage Badge + Date/Time + Upcoming Badge
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Quarter Final Pill (Frame 2: 88x19, radius 10)
              Container(
                height: 19 * scale,
                padding: EdgeInsets.symmetric(
                  horizontal: 6 * scale,
                  vertical: 2 * scale,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFF01A34D).withValues(alpha: 0.20),
                  borderRadius: BorderRadius.circular(10 * scale),
                  border: Border.all(
                    color: const Color(0xFF2BB673),
                    width: 1,
                  ),
                ),
                child: Center(
                  child: Text(
                    'Quarter Final',
                    style: TextStyle(
                      fontSize: 12 * scale,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFFFFFFFF),
                      height: 1.0,
                    ),
                  ),
                ),
              ),

              // Date & Time
              Flexible(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 4 * scale),
                  child: Text(
                    'Today, 06:30 PM',
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

              // Upcoming Gradient Pill (Frame 3: 70x19, radius 10)
              Container(
                height: 19 * scale,
                padding: EdgeInsets.symmetric(
                  horizontal: 6 * scale,
                  vertical: 2 * scale,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10 * scale),
                  gradient: LinearGradient(
                    colors: [
                      const Color(0xFFFF9364).withValues(alpha: 0.10),
                      const Color(0xFFF25F33).withValues(alpha: 0.10),
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
                      fontSize: 12 * scale,
                      fontWeight: FontWeight.w500,
                      height: 1.0,
                    ),
                  ),
                ),
              ),
            ],
          ),

          SizedBox(height: 8 * scale),

          // Row 2: Tournament Name + Venue
          Text(
            tournamentName,
            style: TextStyle(
              fontSize: 16 * scale,
              fontWeight: FontWeight.w600,
              color: const Color(0xFFFFFFFF),
            ),
          ),

          SizedBox(height: 2 * scale),

          // Location Row (Frame 1261154297)
          Row(
            children: [
              SportoAssetIcon(
                SportoAssets.locationPin,
                size: 13 * scale,
                color: const Color(0xFFA0A0A0),
              ),
              SizedBox(width: 4 * scale),
              Text(
                venueName,
                style: TextStyle(
                  fontSize: 12 * scale,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFFA0A0A0),
                ),
              ),
            ],
          ),

          SizedBox(height: 6 * scale),

          // Teams Row (Frame 1000006156)
          Row(
            children: [
              Expanded(
                child: Text(
                  team1,
                  style: TextStyle(
                    fontSize: 14 * scale,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFFFFFFFF),
                  ),
                ),
              ),
              Text(
                'Vs',
                style: TextStyle(
                  fontSize: 12 * scale,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFFA0A0A0),
                ),
              ),
              Expanded(
                child: Text(
                  team2,
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

          // Divider Line 8 (0.8px, #283040)
          Container(
            height: 0.8 * scale,
            color: const Color(0xFF283040),
          ),

          SizedBox(height: 8 * scale),

          // Countdown Row (Frame 1171275259: 330x18)
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                RichText(
                  text: TextSpan(
                    style: TextStyle(
                      fontSize: 14 * scale,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFFA0A0A0),
                    ),
                    children: [
                      const TextSpan(text: 'Starts in '),
                      TextSpan(
                        text: '24 mins',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF2BB673),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 6 * scale),
                Container(
                  width: 2.5 * scale,
                  height: 2.5 * scale,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Color(0xFFA0A0A0),
                  ),
                ),
                SizedBox(width: 6 * scale),
                Text(
                  'at 06:30 PM',
                  style: TextStyle(
                    fontSize: 14 * scale,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFFFFFFFF),
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
// SECTION 1: FIGMA SPLIT TEAM CARD (Asymmetric 14-14-4-4 & 4-4-14-14)
// =============================================================================
class _FigmaSplitTeamCard extends StatelessWidget {
  final double scale;
  final String teamLabel;
  final String teamName;
  final List<String> players;
  final bool isPresent;
  final VoidCallback onMarkPresent;
  final VoidCallback onMarkAbsent;

  const _FigmaSplitTeamCard({
    required this.scale,
    required this.teamLabel,
    required this.teamName,
    required this.players,
    required this.isPresent,
    required this.onMarkPresent,
    required this.onMarkAbsent,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // PART 1: Top Header Card (350x64, radius 14-14-4-4)
        Container(
          width: double.infinity,
          padding: EdgeInsets.all(10 * scale),
          decoration: BoxDecoration(
            color: const Color(0xFF1C2026),
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(14 * scale),
              topRight: Radius.circular(14 * scale),
              bottomLeft: Radius.circular(4 * scale),
              bottomRight: Radius.circular(4 * scale),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Row: Team Label + Team Ready/Not Ready Badge
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    teamLabel,
                    style: TextStyle(
                      fontSize: 14 * scale,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF5C93FF),
                    ),
                  ),
                  Row(
                    children: [
                      // 17x17 status icon indicator
                      Container(
                        width: 17 * scale,
                        height: 17 * scale,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isPresent
                              ? const Color(0xFF2BB673)
                              : const Color(0xFFFE464B),
                        ),
                        child: Icon(
                          isPresent
                              ? Icons.check_rounded
                              : Icons.priority_high_rounded,
                          size: 11 * scale,
                          color: const Color(0xFFFFFFFF),
                        ),
                      ),
                      SizedBox(width: 6 * scale),
                      Text(
                        isPresent ? 'Team Ready' : 'Team Not Ready',
                        style: TextStyle(
                          fontSize: 12 * scale,
                          fontWeight: FontWeight.w500,
                          color: isPresent
                              ? const Color(0xFF2BB673)
                              : const Color(0xFFFE464B),
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              SizedBox(height: 4 * scale),

              // Team Name
              Text(
                teamName,
                style: TextStyle(
                  fontSize: 16 * scale,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFFFFFFFF),
                ),
              ),
            ],
          ),
        ),

        // 2px Gap matching Figma layout
        SizedBox(height: 2 * scale),

        // PART 2: Bottom Squad & Actions Card (350x160, radius 4-4-14-14)
        Container(
          width: double.infinity,
          padding: EdgeInsets.all(10 * scale),
          decoration: BoxDecoration(
            color: const Color(0xFF1C2026),
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(4 * scale),
              topRight: Radius.circular(4 * scale),
              bottomLeft: Radius.circular(14 * scale),
              bottomRight: Radius.circular(14 * scale),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Squad List (Frame 1261154353)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  for (int i = 0; i < players.take(5).length; i++) ...[
                    if (i > 0) SizedBox(height: 5 * scale),
                    _buildPlayerRow(players[i]),
                  ],
                ],
              ),

              SizedBox(height: 6 * scale),

              // Divider Line 8 (0.8px, #283040)
              Container(
                height: 0.8 * scale,
                color: const Color(0xFF283040),
              ),

              SizedBox(height: 8 * scale),

              // Action Buttons Row (Frame 1261154321: height 38, gap 12)
              Row(
                children: [
                  // Present Button (159x38)
                  Expanded(
                    child: SizedBox(
                      height: 38 * scale,
                      child: Material(
                        color: isPresent
                            ? const Color(0xFF2BB673)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(16 * scale),
                        child: InkWell(
                          onTap: isPresent ? null : onMarkPresent,
                          borderRadius: BorderRadius.circular(16 * scale),
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16 * scale),
                              border: isPresent
                                  ? null
                                  : Border.all(
                                      color: const Color(0xFF283040),
                                      width: 1,
                                    ),
                            ),
                            child: Center(
                              child: Text(
                                isPresent ? '✓  Present' : 'Mark As Present',
                                style: TextStyle(
                                  fontSize: 14 * scale,
                                  fontWeight: FontWeight.w700,
                                  color: isPresent
                                      ? const Color(0xFFFFFFFF)
                                      : const Color(0xFFA0A0A0),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),

                  SizedBox(width: 12 * scale),

                  // Absent Button (159x38)
                  Expanded(
                    child: SizedBox(
                      height: 38 * scale,
                      child: Material(
                        color: isPresent
                            ? Colors.transparent
                            : const Color(0x26FE464B),
                        borderRadius: BorderRadius.circular(16 * scale),
                        child: InkWell(
                          onTap: isPresent ? onMarkAbsent : null,
                          borderRadius: BorderRadius.circular(16 * scale),
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16 * scale),
                              border: Border.all(
                                color: isPresent
                                    ? const Color(0xFF283040)
                                    : const Color(0xFFFE464B),
                                width: 1,
                              ),
                            ),
                            child: Center(
                              child: Text(
                                isPresent ? 'Mark As Absent' : '✓  Absent',
                                style: TextStyle(
                                  fontSize: 14 * scale,
                                  fontWeight: FontWeight.w700,
                                  color: isPresent
                                      ? const Color(0xFFA0A0A0)
                                      : const Color(0xFFFE464B),
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
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPlayerRow(String player) {
    final hasCaptain = player.contains('(Captain)');
    final cleanName = player.replaceAll('(Captain)', '').trim();

    return Text.rich(
      TextSpan(
        style: TextStyle(
          fontSize: 12 * scale,
          fontWeight: FontWeight.w500,
          color: const Color(0xFFFFFFFF),
        ),
        children: [
          TextSpan(text: cleanName),
          if (hasCaptain) ...[
            const TextSpan(text: ' '),
            const TextSpan(
              text: '(Captain)',
              style: TextStyle(
                color: Color(0xFF5C93FF),
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// =============================================================================
// SECTION 2: FIGMA FINAL CHECKLIST CARD (350x106, radius 14, gap 16)
// =============================================================================
class _FigmaFinalChecklistCard extends StatelessWidget {
  final double scale;
  final bool team1Checked;
  final bool team2Checked;
  final bool tossChecked;

  const _FigmaFinalChecklistCard({
    required this.scale,
    required this.team1Checked,
    required this.team2Checked,
    required this.tossChecked,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(10 * scale),
      decoration: BoxDecoration(
        color: const Color(0xFF1C2026),
        borderRadius: BorderRadius.circular(14 * scale),
      ),
      child: Column(
        children: [
          _buildChecklistItem('Team 1', team1Checked),
          SizedBox(height: 16 * scale),
          _buildChecklistItem('Team 2', team2Checked),
          SizedBox(height: 16 * scale),
          _buildChecklistItem('Toss', tossChecked),
        ],
      ),
    );
  }

  Widget _buildChecklistItem(String label, bool checked) {
    return SizedBox(
      height: 18 * scale,
      child: Row(
        children: [
          // 17x17 Figma Checkbox
          Container(
            width: 17 * scale,
            height: 17 * scale,
            decoration: BoxDecoration(
              color: checked ? const Color(0xFF2BB673) : Colors.transparent,
              borderRadius: BorderRadius.circular(4 * scale),
              border: checked
                  ? null
                  : Border.all(
                      color: const Color(0xFF283040),
                      width: 1.5,
                    ),
            ),
            child: checked
                ? Icon(
                    Icons.check_rounded,
                    size: 12 * scale,
                    color: const Color(0xFFFFFFFF),
                  )
                : null,
          ),
          SizedBox(width: 8 * scale),
          Text(
            label,
            style: TextStyle(
              fontSize: 14 * scale,
              fontWeight: FontWeight.w500,
              color: checked
                  ? const Color(0xFFFFFFFF)
                  : const Color(0xFFA0A0A0),
            ),
          ),
        ],
      ),
    );
  }
}

// =============================================================================
// SECTION 3: FIGMA ABSENT DECISION CARD (350x162, gradient title)
// =============================================================================
class _FigmaAbsentDecisionCard extends StatelessWidget {
  final double scale;
  final String absentTeamLabel;
  final String absentTeamName;
  final bool team1Checked;
  final bool team2Checked;

  const _FigmaAbsentDecisionCard({
    required this.scale,
    required this.absentTeamLabel,
    required this.absentTeamName,
    required this.team1Checked,
    required this.team2Checked,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(10 * scale),
      decoration: BoxDecoration(
        color: const Color(0xFF1C2026),
        borderRadius: BorderRadius.circular(14 * scale),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Red Gradient Title (Frame 1261154343)
          _GradientText(
            '$absentTeamLabel - $absentTeamName\nhasn\'t checked in.',
            textAlign: TextAlign.center,
            gradient: const LinearGradient(
              colors: [
                Color(0xFFFE6C6C),
                Color(0xFFFE464B),
              ],
            ),
            style: TextStyle(
              fontSize: 16 * scale,
              fontWeight: FontWeight.w600,
              height: 1.25,
            ),
          ),

          SizedBox(height: 8 * scale),

          // Subtitle
          Text(
            'Grace period expired. Choose how to handle\nthis match.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14 * scale,
              fontWeight: FontWeight.w500,
              color: const Color(0xFFA0A0A0),
              height: 1.25,
            ),
          ),

          SizedBox(height: 14 * scale),

          // Absent Card Checklist
          _buildCheckRow('Team 1', team1Checked),
          SizedBox(height: 10 * scale),
          _buildCheckRow('Team 2', team2Checked),
        ],
      ),
    );
  }

  Widget _buildCheckRow(String label, bool checked) {
    return Row(
      children: [
        Container(
          width: 17 * scale,
          height: 17 * scale,
          decoration: BoxDecoration(
            color: checked ? const Color(0xFF2BB673) : Colors.transparent,
            borderRadius: BorderRadius.circular(4 * scale),
            border: checked
                ? null
                : Border.all(
                    color: const Color(0xFF283040),
                    width: 1.5,
                  ),
          ),
          child: checked
              ? Icon(
                  Icons.check_rounded,
                  size: 12 * scale,
                  color: const Color(0xFFFFFFFF),
                )
              : null,
        ),
        SizedBox(width: 8 * scale),
        Text(
          label,
          style: TextStyle(
            fontSize: 14 * scale,
            fontWeight: FontWeight.w500,
            color: checked
                ? const Color(0xFFFFFFFF)
                : const Color(0xFFA0A0A0),
          ),
        ),
      ],
    );
  }
}

// =============================================================================
// SECTION 4: FIGMA BOTTOM ACTION BUTTONS (270x48, dual drop shadows)
// =============================================================================
class _FigmaBottomActionButtons extends StatelessWidget {
  final double scale;
  final bool bothTeamsReady;
  final bool hasAbsentTeam;
  final String walkoverWinner;
  final String absentTeamName;
  final VoidCallback onReadyToToss;
  final VoidCallback onAwardWalkover;
  final VoidCallback onMarkAbsent;

  const _FigmaBottomActionButtons({
    required this.scale,
    required this.bothTeamsReady,
    required this.hasAbsentTeam,
    required this.walkoverWinner,
    required this.absentTeamName,
    required this.onReadyToToss,
    required this.onAwardWalkover,
    required this.onMarkAbsent,
  });

  @override
  Widget build(BuildContext context) {
    if (bothTeamsReady) {
      // Both Teams Ready -> Single Centered 270x48 Green Button
      return Center(
        child: Container(
          width: 270 * scale,
          height: 48 * scale,
          decoration: BoxDecoration(
            color: const Color(0xFF2BB673),
            borderRadius: BorderRadius.circular(16 * scale),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF01A34D).withValues(alpha: 0.20),
                blurRadius: 3 * scale,
                offset: Offset(1 * scale, 1 * scale),
              ),
              BoxShadow(
                color: const Color(0x1A000000),
                blurRadius: 8 * scale,
                offset: Offset(0, 2 * scale),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onReadyToToss,
              borderRadius: BorderRadius.circular(16 * scale),
              child: Center(
                child: Text(
                  'Ready To Toss',
                  style: TextStyle(
                    fontSize: 16 * scale,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFFFFFFFF),
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    }

    if (hasAbsentTeam) {
      // Team Absent -> Walkover & Mark As Absent Buttons (270x48, gap 14)
      return Center(
        child: Column(
          children: [
            // Button 1: Award Walkover
            Container(
              width: 270 * scale,
              height: 48 * scale,
              decoration: BoxDecoration(
                color: const Color(0xFF2BB673),
                borderRadius: BorderRadius.circular(16 * scale),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF01A34D).withValues(alpha: 0.20),
                    blurRadius: 3 * scale,
                    offset: Offset(1 * scale, 1 * scale),
                  ),
                  BoxShadow(
                    color: const Color(0x1A000000),
                    blurRadius: 8 * scale,
                    offset: Offset(0, 2 * scale),
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: onAwardWalkover,
                  borderRadius: BorderRadius.circular(16 * scale),
                  child: Center(
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 10 * scale),
                      child: Text(
                        'Award Walkover to $walkoverWinner',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 15 * scale,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFFFFFFFF),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),

            SizedBox(height: 14 * scale),

            // Button 2: Mark As Absent (Gradient 10% fill + 1px gradient border + gradient text)
            Container(
              width: 270 * scale,
              height: 48 * scale,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16 * scale),
                gradient: const LinearGradient(
                  colors: [
                    Color(0xFFFFD572),
                    Color(0xFFFEBD38),
                  ],
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF1B2335).withValues(alpha: 0.20),
                    blurRadius: 3 * scale,
                    offset: Offset(1 * scale, 1 * scale),
                  ),
                  BoxShadow(
                    color: const Color(0x1A000000),
                    blurRadius: 8 * scale,
                    offset: Offset(0, 2 * scale),
                  ),
                ],
              ),
              padding: const EdgeInsets.all(1), // 1px gradient border
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15 * scale),
                  gradient: LinearGradient(
                    colors: [
                      const Color(0xFFFFD572).withValues(alpha: 0.10),
                      const Color(0xFFFEBD38).withValues(alpha: 0.10),
                    ],
                  ),
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: onMarkAbsent,
                    borderRadius: BorderRadius.circular(15 * scale),
                    child: Center(
                      child: _GradientText(
                        'Mark As Absent',
                        gradient: const LinearGradient(
                          colors: [
                            Color(0xFFFFD572),
                            Color(0xFFFEBD38),
                          ],
                        ),
                        style: TextStyle(
                          fontSize: 16 * scale,
                          fontWeight: FontWeight.w700,
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

    return const SizedBox.shrink();
  }
}

// =============================================================================
// SKELETON SHIMMER (During API Loading)
// =============================================================================
class _FigmaSkeletonShimmer extends StatelessWidget {
  final double scale;

  const _FigmaSkeletonShimmer({required this.scale});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const NeverScrollableScrollPhysics(),
      padding: EdgeInsets.fromLTRB(
        20 * scale,
        16 * scale,
        20 * scale,
        40 * scale,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Match Card Shimmer
          SportoShimmer(
            width: double.infinity,
            height: 141 * scale,
            borderRadius: 14 * scale,
          ),

          SizedBox(height: 20 * scale),

          // Title Shimmer
          SportoShimmer(
            width: 150 * scale,
            height: 18 * scale,
            borderRadius: 6 * scale,
          ),

          SizedBox(height: 10 * scale),

          // Team 1 Split Card Shimmer
          SportoShimmer(
            width: double.infinity,
            height: 64 * scale,
            borderRadius: 14 * scale,
          ),
          SizedBox(height: 2 * scale),
          SportoShimmer(
            width: double.infinity,
            height: 160 * scale,
            borderRadius: 14 * scale,
          ),

          SizedBox(height: 10 * scale),

          // Team 2 Split Card Shimmer
          SportoShimmer(
            width: double.infinity,
            height: 64 * scale,
            borderRadius: 14 * scale,
          ),
          SizedBox(height: 2 * scale),
          SportoShimmer(
            width: double.infinity,
            height: 160 * scale,
            borderRadius: 14 * scale,
          ),

          SizedBox(height: 20 * scale),

          // Final Checklist Shimmer
          SportoShimmer(
            width: 130 * scale,
            height: 18 * scale,
            borderRadius: 6 * scale,
          ),
          SizedBox(height: 10 * scale),
          SportoShimmer(
            width: double.infinity,
            height: 106 * scale,
            borderRadius: 14 * scale,
          ),

          SizedBox(height: 24 * scale),

          // Bottom Button Shimmer
          Center(
            child: SportoShimmer(
              width: 270 * scale,
              height: 48 * scale,
              borderRadius: 16 * scale,
            ),
          ),
        ],
      ),
    );
  }
}

// =============================================================================
// HELPER: GRADIENT TEXT
// =============================================================================
class _GradientText extends StatelessWidget {
  final String text;
  final TextStyle? style;
  final Gradient gradient;
  final TextAlign? textAlign;

  const _GradientText(
    this.text, {
    required this.gradient,
    this.style,
    this.textAlign,
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
        textAlign: textAlign,
      ),
    );
  }
}
