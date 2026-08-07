import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:ui_kit/ui_kit.dart';
import '../../../../app/router/app_router.dart';
import '../../application/tournament_bloc.dart';
import '../widgets/live_tournament_card.dart';

class PartnerMainScreen extends StatefulWidget {
  const PartnerMainScreen({super.key});

  @override
  State<PartnerMainScreen> createState() => _PartnerMainScreenState();
}

class _PartnerMainScreenState extends State<PartnerMainScreen> {
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    context.read<TournamentBloc>().add(const LoadTournamentsEvent());
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body: Stack(
          children: [
            const SportoAmbientBackground(),
            SafeArea(
              bottom: false,
              child: Column(
                children: [
                  // ---- Header ----
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Shrvn's Sporto",
                              style: GoogleFonts.spaceGrotesk(
                                fontSize: 22,
                                fontWeight: FontWeight.w700,
                                color: colorScheme.onSurface,
                              ),
                            ),
                            Text(
                              'Good Morning',
                              style: TextStyle(
                                fontSize: 13,
                                color: colorScheme.tertiary, // gold subtitle
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            IconButton(
                              icon: Icon(Icons.notifications_none_rounded,
                                  color: colorScheme.onSurface, size: 24),
                              onPressed: () {},
                            ),
                            const SizedBox(width: 4),
                            SportoCard(
                              radius: 12,
                              blur: 10,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 8),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(' 500',
                                      style: TextStyle(
                                          color: colorScheme.onSurface,
                                          fontWeight: FontWeight.w700)),
                                  const SizedBox(width: 6),
                                  Container(
                                    width: 24,
                                    height: 24,
                                    decoration: BoxDecoration(
                                      color: colorScheme.tertiary,
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    alignment: Alignment.center,
                                    child: Icon(Icons.add_rounded,
                                        color: Colors.black, size: 16),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // ---- Body content ----
                  Expanded(
                    child: SingleChildScrollView(
                      physics: const ClampingScrollPhysics(),
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildOverviewSection(colorScheme),
                          const SizedBox(height: 24),
                          _buildQuickActions(colorScheme),
                          const SizedBox(height: 24),
                          _buildAnnouncementsBanner(colorScheme),
                          const SizedBox(height: 24),
                          _buildLiveTournaments(colorScheme),
                          const SizedBox(height: 24),
                          _buildTodaysSchedule(colorScheme),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // ---- Bottom Gradient CTA Bar (Using PrimaryButton) ----
            Positioned(
              left: 0,
              right: 0,
              bottom: 60,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: PrimaryButton(
                  label: 'Create New Tournament',
                  widthFactor: 1.0, // Full width within padding
                  height: 56,
                  radius: 16,
                  onPressed: () {
                    context.push(AppRouter.createTournamentRoute);
                  },
                ),
              ),
            ),

            // ---- Bottom Navigation ----
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: SportoBottomNav(
                currentIndex: _currentIndex,
                onTap: (idx) {
                  setState(() => _currentIndex = idx);
                  switch (idx) {
                    case 1:
                      context.push(AppRouter.matchHistoryRoute);
                    case 3:
                      context.push(AppRouter.profileRoute);
                  }
                },
                items: const [
                  SportoNavItem(Icons.home_rounded, 'Home'),
                  SportoNavItem(Icons.calendar_month_rounded, 'Matches'),
                  SportoNavItem(Icons.sports_cricket_rounded, 'Scoring'),
                  SportoNavItem(Icons.person_outline_rounded, 'Profile'),
                ],
              ),
            ),
          ],
        ));
  }

  // ============================================================
  // TODAY'S OVERVIEW (2x2 grid)
  // ============================================================
  Widget _buildOverviewSection(ColorScheme cs) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Today's Overview",
            style: TextStyle(
                color: cs.onSurfaceVariant,
                fontSize: 13,
                fontWeight: FontWeight.w500)),
        const SizedBox(height: 12),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 2.2,
          children: [
            SportoStatCard(
              label: 'Revenue',
              value: '₹12,850',
              highlight: true,
              highlightColor: cs.tertiary,
              fontSize: 22,
              labelSize: 12,
              alignment: CrossAxisAlignment.start,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
            SportoStatCard(
              label: 'Live Tournaments',
              value: '2',
              fontSize: 22,
              labelSize: 12,
              alignment: CrossAxisAlignment.start,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
            SportoStatCard(
              label: 'Registered Players',
              value: '50',
              fontSize: 22,
              labelSize: 12,
              alignment: CrossAxisAlignment.start,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
            SportoStatCard(
              label: 'Active Tournaments',
              value: '10',
              fontSize: 22,
              labelSize: 12,
              alignment: CrossAxisAlignment.start,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
          ],
        ),
      ],
    );
  }

  // ============================================================
  // QUICK ACTIONS (4 icon buttons)
  // ============================================================
  Widget _buildQuickActions(ColorScheme cs) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Quick Actions',
            style: TextStyle(
                color: cs.onSurfaceVariant,
                fontSize: 13,
                fontWeight: FontWeight.w500)),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            SportoQuickAction(
              icon: Icons.add_circle_outline_rounded,
              label: 'Create\nTournament',
              onTap: () => context.push(AppRouter.createTournamentRoute),
            ),
            const SportoQuickAction(
                icon: Icons.location_on_outlined, label: 'Manage\nVenue'),
            const SportoQuickAction(
                icon: Icons.people_outline_rounded, label: 'Registrations'),
            const SportoQuickAction(
                icon: Icons.calendar_today_outlined,
                label: 'Schedule\nMatches'),
          ],
        ),
      ],
    );
  }

  // ============================================================
  // ANNOUNCEMENTS BANNER
  // ============================================================
  Widget _buildAnnouncementsBanner(ColorScheme cs) {
    return SportoCard(
      radius: 14,
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.campaign_rounded, color: cs.onSurfaceVariant, size: 18),
          const SizedBox(width: 8),
          Text('Announcements',
              style: TextStyle(
                  color: cs.onSurface,
                  fontSize: 14,
                  fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  // ============================================================
  // LIVE TOURNAMENT CARDS
  // ============================================================
  Widget _buildLiveTournaments(ColorScheme cs) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                    shape: BoxShape.circle, color: Colors.redAccent)),
            const SizedBox(width: 8),
            Text('Live Tournament',
                style: TextStyle(
                    color: cs.onSurfaceVariant,
                    fontSize: 13,
                    fontWeight: FontWeight.w500)),
          ],
        ),
        const SizedBox(height: 12),
        LiveTournamentCard(
          name: 'Hyderabad Super Cup',
          stage: 'Quarter Final',
          sport: 'Cricket',
          teams: '128 Teams',
          liveNow: true,
          onViewTournament: () => context
              .push(AppRouter.tournamentDetailRoute('t-hyderabad-super-cup')),
        ),
        const SizedBox(height: 12),
        LiveTournamentCard(
          name: 'Royal Smashers',
          stage: 'Final',
          sport: 'Cricket',
          teams: '18 Teams',
          liveNow: true,
          onViewTournament: () =>
              context.push(AppRouter.tournamentDetailRoute('t-royal-smashers')),
        ),
      ],
    );
  }

  // ============================================================
  // TODAY'S SCHEDULE
  // ============================================================
  Widget _buildTodaysSchedule(ColorScheme cs) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text("Today's Schedule (4)",
                style: TextStyle(
                    color: cs.onSurfaceVariant,
                    fontSize: 13,
                    fontWeight: FontWeight.w500)),
            GestureDetector(
              onTap: () {},
              child: Row(
                children: [
                  Text('View All',
                      style: TextStyle(
                          color: cs.tertiary,
                          fontSize: 12,
                          fontWeight: FontWeight.w600)),
                  const SizedBox(width: 4),
                  Icon(Icons.chevron_right_rounded,
                      color: cs.tertiary, size: 16),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        _ScheduleCard(time: '10:00 AM, 26 July 2026', startIn: '25 mins'),
        const SizedBox(height: 12),
        _ScheduleCard(time: '10:00 AM, 26 July 2026', startIn: '25 mins'),
      ],
    );
  }

  Widget _ScheduleCard({required String time, required String startIn}) {
    return Builder(builder: (context) {
      final cs = Theme.of(context).colorScheme;
      return SportoCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(time,
                style: TextStyle(color: cs.onSurfaceVariant, fontSize: 12)),
            const SizedBox(height: 10),
            Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: cs.secondary.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  alignment: Alignment.center,
                  child: Text('HS',
                      style: TextStyle(
                          color: cs.secondary,
                          fontSize: 18,
                          fontWeight: FontWeight.w700)),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Hyderabad Super Cup',
                          style: TextStyle(
                              color: cs.onSurface,
                              fontSize: 16,
                              fontWeight: FontWeight.w600)),
                      const SizedBox(height: 4),
                      RichText(
                        text: TextSpan(
                          style: TextStyle(fontSize: 13),
                          children: [
                            TextSpan(
                                text: 'Cricket • ',
                                style: TextStyle(color: cs.tertiary)),
                            TextSpan(
                                text: '18 Teams',
                                style: TextStyle(color: cs.secondary)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                SportoBadge(
                    text: 'Quarter Final', color: cs.secondary, outlined: true),
              ],
            ),
            const SizedBox(height: 14),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                RichText(
                  text: TextSpan(
                    style: TextStyle(fontSize: 12),
                    children: [
                      TextSpan(
                          text: 'Start in ',
                          style: TextStyle(color: cs.onSurfaceVariant)),
                      TextSpan(
                          text: startIn,
                          style: TextStyle(
                              color: cs.tertiary, fontWeight: FontWeight.w600)),
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: () {},
                  child: Row(
                    children: [
                      Text('View Tournament',
                          style: TextStyle(
                              color: cs.onSurfaceVariant, fontSize: 12)),
                      const SizedBox(width: 4),
                      Icon(Icons.arrow_forward_ios_rounded,
                          color: cs.onSurfaceVariant, size: 12),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    });
  }
}
