import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ui_kit/ui_kit.dart';
import '../../../../app/router/app_router.dart';
import '../../application/match_scoring_bloc.dart';

// ============================================================
// REFEREE HOME SCREEN
// ============================================================
class RefereeHomeScreen extends StatefulWidget {
  final VoidCallback? onViewAll;

  const RefereeHomeScreen({super.key, this.onViewAll});

  @override
  State<RefereeHomeScreen> createState() => _RefereeHomeScreenState();
}

class _RefereeHomeScreenState extends State<RefereeHomeScreen> {
  @override
  void initState() {
    super.initState();
    context.read<MatchScoringBloc>().add(LoadMatchesEvent());
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final blocState = context.watch<MatchScoringBloc>().state;
    final _hasMatches = blocState is MatchScoringListLoadedState &&
        blocState.matches.isNotEmpty;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const ClampingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- Header ---
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Good Evening',
                            style: TextStyle(
                                color: cs.tertiary,
                                fontSize: 14,
                                fontWeight: FontWeight.w500)),
                        Text('Priya Agrawal',
                            style: GoogleFonts.spaceGrotesk(
                                fontSize: 22,
                                fontWeight: FontWeight.w700,
                                color: cs.onSurface)),
                      ]),
                  Row(children: [
                    Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                            color: SportoTextField.inputFill,
                            borderRadius: BorderRadius.circular(20),
                            border:
                                Border.all(color: SportoCard.defaultBorder)),
                        child: Row(children: [
                          Text('₹ 500',
                              style: TextStyle(
                                  color: cs.onSurface,
                                  fontWeight: FontWeight.w700)),
                          const SizedBox(width: 8),
                          Icon(Icons.add, color: cs.tertiary, size: 16)
                        ])),
                    const SizedBox(width: 12),
                    Icon(Icons.notifications_none_rounded,
                        color: cs.onSurface, size: 24),
                  ]),
                ],
              ),
              const SizedBox(height: 24),

              // --- Search Bar ---
              Container(
                height: 52,
                decoration: BoxDecoration(
                    color: SportoTextField.inputFill,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: SportoCard.defaultBorder)),
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(children: [
                  Icon(Icons.search_rounded,
                      color: cs.onSurfaceVariant, size: 20),
                  const SizedBox(width: 12),
                  Expanded(
                      child: Text('Search cricket, football..',
                          style: TextStyle(
                              color: cs.onSurfaceVariant.withOpacity(0.6),
                              fontSize: 14))),
                  Icon(Icons.mic_none_rounded, color: cs.tertiary, size: 20),
                ]),
              ),
              const SizedBox(height: 24),

              // --- Stats Row ---
              Row(children: [
                Expanded(
                  child: SportoStatCard(
                      value: _hasMatches ? '1' : '0',
                      label: 'Live Now',
                      dotColor: Colors.redAccent,
                      fontSize: 20,
                      labelSize: 11),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: SportoStatCard(
                      value: _hasMatches ? '4' : '0',
                      label: 'Upcoming',
                      dotColor: Colors.orange,
                      fontSize: 20,
                      labelSize: 11),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: SportoStatCard(
                      value: _hasMatches ? '6' : '0',
                      label: 'Assigned',
                      dotColor: cs.secondary,
                      fontSize: 20,
                      labelSize: 11),
                ),
              ]),
              const SizedBox(height: 12),

              // Secondary Stats
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                    color: SportoCard.defaultFill.withOpacity(0.6),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: SportoCard.defaultBorder)),
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Text('Completed ${_hasMatches ? '1' : '0'}',
                          style: TextStyle(
                              color: cs.onSurfaceVariant, fontSize: 13)),
                      Text('Cancelled ${_hasMatches ? '0' : '0'}',
                          style: TextStyle(
                              color: cs.onSurfaceVariant, fontSize: 13)),
                    ]),
              ),
              const SizedBox(height: 24),

              // --- Main Content Area ---
              if (_hasMatches) ...[
                // LIVE NOW SECTION
                Row(children: [
                  Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                          shape: BoxShape.circle, color: Colors.redAccent)),
                  const SizedBox(width: 8),
                  Text('Live Now',
                      style: TextStyle(
                          color: Colors.redAccent,
                          fontSize: 16,
                          fontWeight: FontWeight.w700))
                ]),
                const SizedBox(height: 16),
                _LiveMatchCard(),
                const SizedBox(height: 24),

                // NEXT MATCH SECTION
                Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(children: [
                        Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                                shape: BoxShape.circle, color: Colors.orange)),
                        const SizedBox(width: 8),
                        Text('Next Match',
                            style: TextStyle(
                                color: Colors.orange,
                                fontSize: 16,
                                fontWeight: FontWeight.w700))
                      ]),
                      Icon(Icons.arrow_forward_ios_rounded,
                          color: cs.onSurfaceVariant, size: 14),
                    ]),
                const SizedBox(height: 16),
                _NextMatchCard(),
                const SizedBox(height: 24),

                // ASSIGNED MATCHES SECTION
                Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(children: [
                        Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                                shape: BoxShape.circle, color: cs.secondary)),
                        const SizedBox(width: 8),
                        RichText(
                            text: TextSpan(
                                style: TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.w700),
                                children: [
                              TextSpan(
                                  text: 'Assigned Matches ',
                                  style: TextStyle(color: cs.secondary)),
                              TextSpan(
                                  text: '(3)',
                                  style: TextStyle(color: cs.onSurface))
                            ]))
                      ]),
                      TextButton(
                          onPressed: widget.onViewAll,
                          child: Text('View All ?��',
                              style: TextStyle(
                                  color: cs.onSurfaceVariant, fontSize: 12))),
                    ]),
                const SizedBox(height: 16),
                _AssignedMatchCard(),
              ] else ...[
                // EMPTY STATE
                Container(
                  height: 300,
                  decoration: BoxDecoration(
                      color: SportoCard.defaultFill.withOpacity(0.6),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: SportoCard.defaultBorder)),
                  child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                            width: 120,
                            height: 120,
                            decoration: BoxDecoration(
                                color: const Color(0xFF2A2020),
                                borderRadius: BorderRadius.circular(24))),
                        const SizedBox(height: 24),
                        Text('No Assigned Matches',
                            style: TextStyle(
                                color: cs.onSurface,
                                fontSize: 18,
                                fontWeight: FontWeight.w700)),
                        const SizedBox(height: 8),
                        Text('Enjoy your day!',
                            style: TextStyle(
                                color: cs.secondary,
                                fontSize: 16,
                                fontWeight: FontWeight.w600)),
                        const SizedBox(height: 24),
                        Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 32),
                            child: Text(
                                'We\'ll notify you when new matches are assigned.',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    color: cs.onSurfaceVariant, fontSize: 13))),
                      ]),
                ),
              ],

              const SizedBox(height: 24),

              // --- Ads Banner ---
              Container(
                height: 60,
                decoration: BoxDecoration(
                    gradient: LinearGradient(colors: [cs.primary, cs.tertiary]),
                    borderRadius: BorderRadius.circular(16)),
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Ads Banner',
                          style: TextStyle(
                              color: Colors.black,
                              fontSize: 16,
                              fontWeight: FontWeight.w700)),
                      Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              shape: BoxShape.circle),
                          alignment: Alignment.center,
                          child: Icon(Icons.arrow_forward_ios_rounded,
                              color: Colors.white, size: 14)),
                    ]),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ============================================================
  // MATCH CARDS
  // ============================================================

  // ============================================================
  // MATCH CARDS (centralized SportoMatchCard)
  // ============================================================

  Widget _LiveMatchCard() {
    final cs = Theme.of(context).colorScheme;
    return SportoMatchCard(
      variant: SportoMatchCardVariant.live,
      tournamentName: 'Jaipur Super Over',
      stage: 'Final',
      overLabel: 'Over - 2.1/6',
      teamA: 'Thunder Titans',
      scoreA: '28/1',
      teamB: 'Royal Strikers',
      scoreB: 'Waiting to Bat',
      gradientColors: const [Color(0xFF4A2515), Color(0xFF2A1510)],
      middle: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          RichText(
              text: TextSpan(style: TextStyle(fontSize: 12), children: [
            TextSpan(
                text: 'Current Batter ',
                style: TextStyle(color: cs.onSurfaceVariant)),
            TextSpan(
                text: 'Rahul',
                style:
                    TextStyle(color: cs.onSurface, fontWeight: FontWeight.w600))
          ])),
          RichText(
              text: TextSpan(style: TextStyle(fontSize: 12), children: [
            TextSpan(
                text: 'Current Bowler ',
                style: TextStyle(color: cs.onSurfaceVariant)),
            TextSpan(
                text: 'Amit',
                style:
                    TextStyle(color: cs.onSurface, fontWeight: FontWeight.w600))
          ])),
        ],
      ),
      actionLabel: 'Continue Scoring',
      actionColor: Colors.redAccent,
      onAction: () => context.push(AppRouter.liveScoringRoute),
    );
  }

  Widget _NextMatchCard() {
    return SportoMatchCard(
      variant: SportoMatchCardVariant.upcoming,
      tournamentName: 'Asia Cup 2026',
      location: 'Hyderabad',
      timeLabel: 'Today, 08:00 PM',
      teamA: 'Thunder Titans',
      teamB: 'Royal Smashers',
      startsInLabel: '00:28:35',
      actionLabel: 'Verify Teams',
      actionColor: Colors.blue,
      onAction: () => context.push(AppRouter.matchVerificationRoute),
    );
  }

  Widget _AssignedMatchCard() {
    return SportoMatchCard(
      variant: SportoMatchCardVariant.upcoming,
      tournamentName: 'Asia Cup 2026',
      location: 'Hyderabad',
      timeLabel: 'Tomorrow, 06:30 PM',
      teamA: 'Delhi Warriors',
      teamB: 'Hyd Highlanders',
      actionLabel: 'Verify Teams',
      actionColor: Colors.blue,
      onAction: () => context.push(AppRouter.matchVerificationRoute),
    );
  }
}
