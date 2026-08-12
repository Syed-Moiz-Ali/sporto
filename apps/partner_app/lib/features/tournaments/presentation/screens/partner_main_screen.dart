import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:ui_kit/ui_kit.dart';
import '../../../../app/router/app_router.dart';
import '../../application/tournament_bloc.dart';
import '../widgets/live_tournament_card.dart';
import 'profile_screen.dart';

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
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final scale = context.sportoScale;

    return SportoScreenShell(
      body: Stack(
        children: [
          IndexedStack(
            index: _currentIndex,
            children: [
              SafeArea(
                bottom: false,
                child: Column(
                  children: [
                    // ---- Header ----
                    Padding(
                      padding: EdgeInsets.fromLTRB(
                        20 * scale,
                        10 * scale,
                        20 * scale,
                        8 * scale,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Shrvn's Sporto",
                                style: theme.textTheme.titleLarge?.copyWith(
                                  fontSize: 18 * scale,
                                  fontWeight: FontWeight.w700,
                                  color: colorScheme.onSurface,
                                ),
                              ),
                              Text(
                                'Good Morning',
                                style: TextStyle(
                                  fontSize: 13 * scale,
                                  color: colorScheme.tertiary, // gold subtitle
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              IconButton(
                                padding: EdgeInsets.all(6 * scale),
                                constraints: BoxConstraints.tightFor(
                                  width: 36 * scale,
                                  height: 36 * scale,
                                ),
                                icon: Icon(
                                  Icons.notifications_none_rounded,
                                  color: colorScheme.onSurface,
                                  size: 22 * scale,
                                ),
                                onPressed: () {},
                              ),
                              SizedBox(width: 4 * scale),
                              SportoCard(
                                radius: 7 * scale,
                                blur: 10 * scale,
                                padding: EdgeInsets.fromLTRB(
                                  8 * scale,
                                  3 * scale,
                                  2 * scale,
                                  3 * scale,
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text('₹ 500',
                                        style: theme.textTheme.titleMedium
                                            ?.copyWith(
                                                color: colorScheme.onSurface,
                                                fontSize: 14 * scale,
                                                fontWeight: FontWeight.w700)),
                                    SizedBox(width: 5 * scale),
                                    Container(
                                      width: 22 * scale,
                                      height: 22 * scale,
                                      decoration: BoxDecoration(
                                        color: colorScheme.tertiary,
                                        borderRadius:
                                            BorderRadius.circular(5 * scale),
                                      ),
                                      alignment: Alignment.center,
                                      child: Icon(Icons.add_rounded,
                                          color: Colors.black,
                                          size: 16 * scale),
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
                        padding: EdgeInsets.fromLTRB(
                          20 * scale,
                          8 * scale,
                          20 * scale,
                          100 * scale,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildOverviewSection(colorScheme),
                            SizedBox(height: 20 * scale),
                            _buildQuickActions(colorScheme),
                            SizedBox(height: 12 * scale),
                            _buildAnnouncementsBanner(colorScheme),
                            SizedBox(height: 22 * scale),
                            _buildLiveTournaments(colorScheme),
                            SizedBox(height: 20 * scale),
                            _buildTodaysSchedule(colorScheme),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox.shrink(),
              const SizedBox.shrink(),
              const SafeArea(
                bottom: false,
                child: ProfileScreen(),
              ),
            ],
          ),

          // ---- Bottom Gradient CTA Bar (Using PrimaryButton) ----
          if (_currentIndex == 0)
            Positioned(
              left: 0,
              right: 0,
              bottom: 54 * scale,
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 20 * scale),
                child: PrimaryButton(
                  label: 'Create New Tournament',
                  widthFactor: 1.0, // Full width within padding
                  height: 48 * scale,
                  radius: 14 * scale,
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
                  case 2:
                    context.push(AppRouter.scheduleRoute);
                  case 3:
                    break;
                }
              },
              items: const [
                SportoNavItem(Icons.home_rounded, 'Home'),
                SportoNavItem(Icons.emoji_events_outlined, 'Tournaments'),
                SportoNavItem(Icons.calendar_month_rounded, 'Schedules'),
                SportoNavItem(Icons.person_outline_rounded, 'Profile'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // TODAY'S OVERVIEW (2x2 grid)
  // ============================================================
  Widget _buildOverviewSection(ColorScheme cs) {
    final scale = context.sportoScale;
    final gridWidth = MediaQuery.sizeOf(context).width - 40 * scale;
    final tileWidth = (gridWidth - 12 * scale) / 2;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Today's Overview",
            style: TextStyle(
                color: cs.onSurfaceVariant,
                fontSize: 13 * scale,
                fontWeight: FontWeight.w500)),
        SizedBox(height: 12 * scale),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 12 * scale,
          crossAxisSpacing: 12 * scale,
          childAspectRatio: tileWidth / (61 * scale),
          children: [
            SportoStatCard(
              label: 'Revenue',
              value: '₹12,850',
              highlight: true,
              highlightColor: cs.tertiary,
              fontSize: 16 * scale,
              labelSize: 11 * scale,
              alignment: CrossAxisAlignment.start,
              padding: EdgeInsets.symmetric(
                horizontal: 14 * scale,
                vertical: 8 * scale,
              ),
            ),
            SportoStatCard(
              label: 'Live Tournaments',
              value: '2',
              fontSize: 16 * scale,
              labelSize: 11 * scale,
              alignment: CrossAxisAlignment.start,
              padding: EdgeInsets.symmetric(
                horizontal: 14 * scale,
                vertical: 8 * scale,
              ),
            ),
            SportoStatCard(
              label: 'Registered Players',
              value: '50',
              fontSize: 16 * scale,
              labelSize: 11 * scale,
              alignment: CrossAxisAlignment.start,
              padding: EdgeInsets.symmetric(
                horizontal: 14 * scale,
                vertical: 8 * scale,
              ),
            ),
            SportoStatCard(
              label: 'Active Tournaments',
              value: '10',
              fontSize: 16 * scale,
              labelSize: 11 * scale,
              alignment: CrossAxisAlignment.start,
              padding: EdgeInsets.symmetric(
                horizontal: 14 * scale,
                vertical: 8 * scale,
              ),
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
    final scale = context.sportoScale;
    final availableWidth = MediaQuery.sizeOf(context).width - 40 * scale;
    final gap = 12 * scale;
    final tileWidth = (availableWidth - gap * 3) / 4;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Quick Actions',
            style: TextStyle(
                color: cs.onSurfaceVariant,
                fontSize: 13 * scale,
                fontWeight: FontWeight.w500)),
        SizedBox(height: 12 * scale),
        Row(
          children: [
            SportoQuickAction(
              width: tileWidth,
              icon: Icons.add_circle_outline_rounded,
              label: 'Create\nTournament',
              onTap: () => context.push(AppRouter.createTournamentRoute),
            ),
            SizedBox(width: gap),
            SportoQuickAction(
                width: tileWidth,
                icon: Icons.location_on_outlined,
                label: 'Manage\nVenue'),
            SizedBox(width: gap),
            SportoQuickAction(
                width: tileWidth,
                icon: Icons.people_outline_rounded,
                label: 'Registrations'),
            SizedBox(width: gap),
            SportoQuickAction(
                width: tileWidth,
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
    final scale = context.sportoScale;
    return SportoCard(
      radius: 8 * scale,
      padding: EdgeInsets.symmetric(vertical: 7 * scale),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.campaign_rounded,
              color: cs.onSurfaceVariant, size: 14 * scale),
          SizedBox(width: 5 * scale),
          Text('Announcements',
              style: TextStyle(
                  color: cs.onSurface,
                  fontSize: 11 * scale,
                  fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  // ============================================================
  // LIVE TOURNAMENT CARDS
  // ============================================================
  Widget _buildLiveTournaments(ColorScheme cs) {
    final scale = context.sportoScale;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
                width: 8 * scale,
                height: 8 * scale,
                decoration: BoxDecoration(
                    shape: BoxShape.circle, color: Colors.redAccent)),
            SizedBox(width: 6 * scale),
            Text('Live Tournament',
                style: TextStyle(
                    color: cs.onSurfaceVariant,
                    fontSize: 13 * scale,
                    fontWeight: FontWeight.w500)),
          ],
        ),
        SizedBox(height: 12 * scale),
        LiveTournamentCard(
          name: 'Hyderabad Super Cup',
          stage: 'Quarter Final',
          sport: 'Cricket',
          teams: '128 Teams',
          liveNow: true,
          onViewTournament: () => context
              .push(AppRouter.tournamentDetailRoute('t-hyderabad-super-cup')),
        ),
        SizedBox(height: 12 * scale),
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
    final scale = context.sportoScale;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text("Today's Schedule (4)",
                style: TextStyle(
                    color: cs.onSurfaceVariant,
                    fontSize: 13 * scale,
                    fontWeight: FontWeight.w500)),
            GestureDetector(
              onTap: () {},
              child: Row(
                children: [
                  Text('View All',
                      style: TextStyle(
                          color: cs.tertiary,
                          fontSize: 12 * scale,
                          fontWeight: FontWeight.w600)),
                  SizedBox(width: 4 * scale),
                  Icon(Icons.chevron_right_rounded,
                      color: cs.onTertiary, size: 16 * scale),
                ],
              ),
            ),
          ],
        ),
        SizedBox(height: 12 * scale),
        _ScheduleCard(time: '10:00 AM, 26 July 2026', startIn: '25 mins'),
        SizedBox(height: 12 * scale),
        _ScheduleCard(time: '10:00 AM, 26 July 2026', startIn: '25 mins'),
      ],
    );
  }

  Widget _ScheduleCard({required String time, required String startIn}) {
    return Builder(builder: (context) {
      final cs = Theme.of(context).colorScheme;
      final scale = context.sportoScale;
      return SportoCard(
        padding: EdgeInsets.all(10 * scale),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(time,
                style: TextStyle(
                    color: cs.onSurfaceVariant, fontSize: 11 * scale)),
            SizedBox(height: 10 * scale),
            Row(
              children: [
                Container(
                  width: 56 * scale,
                  height: 56 * scale,
                  decoration: BoxDecoration(
                    color: cs.secondary.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10 * scale),
                  ),
                  alignment: Alignment.center,
                  child: Text('HS',
                      style: TextStyle(
                          color: cs.secondary,
                          fontSize: 24 * scale,
                          fontWeight: FontWeight.w700)),
                ),
                SizedBox(width: 10 * scale),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Hyderabad Super Cup',
                          style: TextStyle(
                              color: cs.onSurface,
                              fontSize: 14 * scale,
                              fontWeight: FontWeight.w600)),
                      SizedBox(height: 4 * scale),
                      RichText(
                        text: TextSpan(
                          style: TextStyle(fontSize: 11 * scale),
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
            SizedBox(height: 10 * scale),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: RichText(
                    text: TextSpan(
                      style: TextStyle(fontSize: 11 * scale),
                      children: [
                        TextSpan(
                            text: 'Start in ',
                            style: TextStyle(color: cs.onSurfaceVariant)),
                        TextSpan(
                            text: startIn,
                            style: TextStyle(
                                color: cs.tertiary,
                                fontWeight: FontWeight.w600)),
                      ],
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () {},
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('View Tournament',
                          style: TextStyle(
                              color: cs.onSurfaceVariant,
                              fontSize: 11 * scale)),
                      SizedBox(width: 4 * scale),
                      Icon(Icons.arrow_forward_ios_rounded,
                          color: cs.onSurfaceVariant, size: 12 * scale),
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
