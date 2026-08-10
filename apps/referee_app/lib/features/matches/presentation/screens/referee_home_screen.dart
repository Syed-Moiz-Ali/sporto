import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
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
        backgroundColor: context.sporto.canvas,
        body: Stack(
          children: [
            const SportoAmbientBackground(),
            SafeArea(
              child: SingleChildScrollView(
                physics: const ClampingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(19, 20, 19, 22),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // --- Header ---
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                            child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                              Text('Good Evening',
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyMedium
                                      ?.copyWith(color: cs.primary)),
                              Text('Priya Agrawal',
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleLarge
                                      ?.copyWith(color: cs.onSurface)),
                            ])),
                        Row(children: [
                          ClipRRect(
                              borderRadius: BorderRadius.circular(6),
                              child: Row(children: [
                                Container(
                                    height: 24,
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 9),
                                    alignment: Alignment.center,
                                    color: context.sporto.field,
                                    child: Text('\u20B9 500',
                                        style: TextStyle(
                                            color: cs.onSurface,
                                            fontSize: 16,
                                            fontWeight: FontWeight.w700))),
                                Container(
                                    width: 25,
                                    height: 24,
                                    alignment: Alignment.center,
                                    color: cs.tertiary,
                                    child: const Icon(Icons.add_rounded,
                                        color: Color(0xFF252119), size: 20)),
                              ])),
                          const SizedBox(width: 12),
                          Icon(Icons.notifications_none_rounded,
                              color: cs.onSurface, size: 24),
                        ]),
                      ],
                    ),
                    const SizedBox(height: 15),

                    // --- Search Bar ---
                    Container(
                      height: 48,
                      decoration: BoxDecoration(
                          color: context.sporto.field,
                          borderRadius: BorderRadius.circular(15),
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
                        Container(
                            width: 1, height: 30, color: context.sporto.border),
                        const SizedBox(width: 13),
                        Icon(Icons.mic_none_rounded,
                            color: context.sporto.muted, size: 22),
                      ]),
                    ),
                    const SizedBox(height: 22),

                    // --- Stats Row ---
                    SizedBox(
                        height: 60,
                        child: Row(children: [
                          Expanded(
                            child: SportoStatCard(
                                value: _hasMatches ? '1' : '0',
                                label: 'Live Now',
                                dotColor: context.sporto.live,
                                fontSize: 20,
                                labelSize: 11,
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 7)),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: SportoStatCard(
                                value: _hasMatches ? '4' : '0',
                                label: 'Upcoming',
                                dotColor: context.sporto.upcoming,
                                fontSize: 20,
                                labelSize: 11,
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 7)),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: SportoStatCard(
                                value: _hasMatches ? '6' : '0',
                                label: 'Assigned',
                                dotColor: cs.secondary,
                                fontSize: 20,
                                labelSize: 11,
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 7)),
                          ),
                        ])),
                    const SizedBox(height: 12),

                    // Secondary Stats
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 8),
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
                            decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: context.sporto.live)),
                        const SizedBox(width: 8),
                        Text('Live Now',
                            style: TextStyle(
                                color: context.sporto.live,
                                fontSize: 16,
                                fontWeight: FontWeight.w700))
                      ]),
                      const SizedBox(height: 6),
                      _LiveMatchCard(),
                      const SizedBox(height: 19),

                      // NEXT MATCH SECTION
                      Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                                child: Row(children: [
                              Container(
                                  width: 8,
                                  height: 8,
                                  decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: context.sporto.upcoming)),
                              const SizedBox(width: 8),
                              Text('Next Match',
                                  style: TextStyle(
                                      color: context.sporto.upcoming,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700))
                            ])),
                            Icon(Icons.arrow_forward_ios_rounded,
                                color: cs.onSurfaceVariant, size: 14),
                          ]),
                      const SizedBox(height: 10),
                      _NextMatchCard(),
                      const SizedBox(height: 24),

                      // ASSIGNED MATCHES SECTION
                      SizedBox(
                          height: 20,
                          child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                    child: Row(children: [
                                  Container(
                                      width: 8,
                                      height: 8,
                                      decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: cs.secondary)),
                                  const SizedBox(width: 8),
                                  RichText(
                                      text: TextSpan(
                                          style: Theme.of(context)
                                              .textTheme
                                              .titleLarge,
                                          children: [
                                        TextSpan(
                                            text: 'Assigned Matches ',
                                            style:
                                                TextStyle(color: cs.secondary)),
                                        TextSpan(
                                            text: '(3)',
                                            style:
                                                TextStyle(color: cs.onSurface))
                                      ]))
                                ])),
                                GestureDetector(
                                  onTap: widget.onViewAll,
                                  child: Text(
                                    'View All  →',
                                    style: Theme.of(context)
                                        .textTheme
                                        .labelMedium
                                        ?.copyWith(color: cs.onSurfaceVariant),
                                  ),
                                ),
                              ])),
                      const SizedBox(height: 10),
                      _AssignedMatchCard(),
                    ] else ...[
                      // EMPTY STATE
                      Container(
                        height: 314,
                        width: double.infinity,
                        padding: const EdgeInsets.fromLTRB(20, 30, 20, 18),
                        decoration: BoxDecoration(
                            color: const Color(0xFF1B2027),
                            borderRadius: BorderRadius.circular(36)),
                        child: Column(children: [
                          Container(
                              width: 140,
                              height: 120,
                              decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: [
                                      Color(0xFF372B2D),
                                      Color(0xFF342526)
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(10))),
                          const SizedBox(height: 21),
                          Text('No Assigned Matches',
                              style: TextStyle(
                                  color: cs.onSurface,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600)),
                          const SizedBox(height: 7),
                          Text('Enjoy your day!',
                              style: TextStyle(
                                  color: cs.secondary,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600)),
                          const Spacer(),
                          Divider(
                              height: 1,
                              color: cs.outline.withValues(alpha: .18)),
                          const SizedBox(height: 20),
                          Text(
                              'We\'ll notify you when new matches are\nassigned.',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  color: cs.onSurfaceVariant,
                                  height: 1.2,
                                  fontSize: 13)),
                        ]),
                      ),
                    ],

                    const SizedBox(height: 20),

                    // --- Ads Banner ---
                    Container(
                      height: 56,
                      decoration: BoxDecoration(
                          gradient:
                              LinearGradient(colors: [cs.primary, cs.tertiary]),
                          borderRadius: BorderRadius.circular(17)),
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Ads Banner',
                                style: Theme.of(context)
                                    .textTheme
                                    .titleLarge
                                    ?.copyWith(color: cs.onPrimary)),
                            Container(
                                width: 32,
                                height: 32,
                                decoration: BoxDecoration(
                                    color: cs.onPrimary.withOpacity(0.2),
                                    shape: BoxShape.circle),
                                alignment: Alignment.center,
                                child: Icon(Icons.arrow_forward_ios_rounded,
                                    color: cs.onPrimary, size: 14)),
                          ]),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ));
  }

  // ============================================================
  // MATCH CARDS
  // ============================================================

  // ============================================================
  // MATCH CARDS (centralized SportoMatchCard)
  // ============================================================

  Widget _LiveMatchCard() {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [
          context.sporto.liveCardStart,
          context.sporto.liveCardEnd,
        ]),
        borderRadius: BorderRadius.circular(17),
        border: Border.all(color: const Color(0xFF98400D)),
        boxShadow: const [BoxShadow(color: Color(0x443B1B06), blurRadius: 18)],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('Jaipur Super Over',
            style: TextStyle(
                color: cs.tertiary, fontSize: 15, fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        Row(children: [
          Expanded(child: _team('Thunder Titans', '28/1')),
          Text('Vs',
              style: TextStyle(color: cs.onSurfaceVariant, fontSize: 11)),
          Expanded(
              child: _team('Royal Strikers', 'Waiting to Bat', right: true)),
        ]),
        const SizedBox(height: 9),
        Divider(height: 1, color: cs.onSurfaceVariant.withValues(alpha: .22)),
        const SizedBox(height: 9),
        Row(children: [
          Expanded(child: _metric('Current Batter', 'Rahul')),
          Expanded(child: _metric('Current Bowler', 'Amit', right: true)),
        ]),
        const SizedBox(height: 9),
        Divider(height: 1, color: cs.onSurfaceVariant.withValues(alpha: .22)),
        const SizedBox(height: 9),
        Row(children: [
          const Text('Over - 2.1/6',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
          const Spacer(),
          SizedBox(
              height: 31,
              child: FilledButton(
                onPressed: () => context.push(AppRouter.liveScoringRoute),
                style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFFFF3D00),
                    padding: const EdgeInsets.symmetric(horizontal: 13),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(11))),
                child: const Text('Continue Scoring',
                    style:
                        TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
              )),
        ]),
      ]),
    );
  }

  Widget _NextMatchCard() {
    return _upcomingCard(
        'Today, 08:00 PM', 'Thunder Titans', 'Royal Smashers', true);
  }

  Widget _AssignedMatchCard() {
    return _upcomingCard(
        'Tomorrow, 06:30 PM', 'Delhi Warriors', 'Hyd Highlanders', false);
  }

  Widget _upcomingCard(String time, String left, String right, bool countdown) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
          color: const Color(0xFF1B2027),
          borderRadius: BorderRadius.circular(14)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Container(
              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
              decoration: BoxDecoration(
                  color: const Color(0xFF382923),
                  borderRadius: BorderRadius.circular(8)),
              child: const Text('Upcoming',
                  style: TextStyle(
                      color: Color(0xFFFF663A),
                      fontSize: 11,
                      fontWeight: FontWeight.w600))),
          const Spacer(),
          Text(time,
              style: theme.textTheme.bodySmall
                  ?.copyWith(color: cs.onSurfaceVariant, fontSize: 12)),
        ]),
        const SizedBox(height: 8),
        Text('Asia Cup 2026',
            style: theme.textTheme.titleMedium
                ?.copyWith(fontSize: 16, fontWeight: FontWeight.w600)),
        Row(children: [
          Icon(Icons.location_on_outlined,
              size: 14, color: cs.onSurfaceVariant),
          const SizedBox(width: 2),
          Text('Hyderabad',
              style: theme.textTheme.bodySmall
                  ?.copyWith(color: cs.onSurfaceVariant, fontSize: 11))
        ]),
        const SizedBox(height: 9),
        Row(children: [
          Expanded(
              child: Text(left,
                  style: const TextStyle(
                      fontSize: 15, fontWeight: FontWeight.w700))),
          Text('Vs',
              style: TextStyle(color: cs.onSurfaceVariant, fontSize: 12)),
          Expanded(
              child: Text(right,
                  textAlign: TextAlign.end,
                  style: const TextStyle(
                      fontSize: 15, fontWeight: FontWeight.w700)))
        ]),
        const SizedBox(height: 9),
        Divider(height: 1, color: cs.outline.withValues(alpha: .22)),
        const SizedBox(height: 9),
        Row(children: [
          if (countdown)
            Expanded(
                child: RichText(
                    text: const TextSpan(
                        style: TextStyle(
                            fontSize: 15, fontWeight: FontWeight.w600),
                        children: [
                  TextSpan(
                      text: 'Starts in ',
                      style: TextStyle(color: Colors.white)),
                  TextSpan(
                      text: '00:28:35',
                      style: TextStyle(color: Color(0xFF42F58D))),
                ]))),
          if (!countdown) const Spacer(),
          SizedBox(
              height: 31,
              child: FilledButton(
                  onPressed: () =>
                      context.push(AppRouter.matchVerificationRoute),
                  style: FilledButton.styleFrom(
                      backgroundColor: const Color(0xFF65C9FA),
                      foregroundColor: const Color(0xFF10202A),
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(11))),
                  child: const Text('Verify Teams',
                      style: TextStyle(
                          fontSize: 13, fontWeight: FontWeight.w600)))),
        ]),
      ]),
    );
  }

  Widget _team(String name, String value, {bool right = false}) => Column(
          crossAxisAlignment:
              right ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            Text(name,
                style: const TextStyle(color: Color(0xFFD5C9C7), fontSize: 13)),
            Text(value,
                style:
                    const TextStyle(fontSize: 14, fontWeight: FontWeight.w700))
          ]);

  Widget _metric(String label, String value, {bool right = false}) => RichText(
      textAlign: right ? TextAlign.end : TextAlign.start,
      text: TextSpan(style: const TextStyle(fontSize: 12), children: [
        TextSpan(
            text: '$label ', style: const TextStyle(color: Color(0xFFB8ADB2))),
        TextSpan(
            text: value,
            style: const TextStyle(
                color: Colors.white, fontWeight: FontWeight.w700)),
      ]));
}
