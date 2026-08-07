import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:ui_kit/ui_kit.dart';
import '../../../../app/router/app_router.dart';
import '../../application/tournament_bloc.dart';
import '../widgets/live_tournament_card.dart';

// ============================================================
// SHARED REFERENCE STYLING (Dark Glass Cards)
// ============================================================
Color _cardFill(ColorScheme cs) => const Color(0xFF15171C).withOpacity(0.6);
Color _cardBorder(ColorScheme cs) =>
    const Color(0x0FFFFFFF); // white 6% hairline
const double _cardRadius = 16;
const double _cardBlur = 14;

Widget _refCard({
  required BuildContext context,
  required Widget child,
  EdgeInsetsGeometry padding = const EdgeInsets.all(16),
}) {
  final cs = Theme.of(context).colorScheme;
  return GlassContainer(
    borderRadius: _cardRadius,
    blur: _cardBlur,
    borderWidth: 1,
    borderColor: _cardBorder(cs),
    backgroundColor: _cardFill(cs),
    padding: padding,
    child: child,
  );
}

// Ambient background for partner dashboard
Widget _partnerAmbientBg(ColorScheme cs) {
  final base = Scaffold().backgroundColor ?? Colors.black;
  return IgnorePointer(
    child: Stack(children: [
      Container(color: base),
      Container(
        decoration: BoxDecoration(
          gradient: RadialGradient(
            center: const Alignment(0.9, -0.85),
            radius: 0.9,
            colors: [cs.primary.withOpacity(0.12), Colors.transparent],
          ),
        ),
      ),
    ]),
  );
}

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
          _partnerAmbientBg(colorScheme),
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
                          GlassContainer(
                            borderRadius: 12,
                            blur: 10,
                            borderWidth: 1,
                            borderColor: _cardBorder(colorScheme),
                            backgroundColor: _cardFill(colorScheme),
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
                  child: _PartnerBottomNav(
                    currentIndex: _currentIndex,
                    onTap: (idx) => setState(() => _currentIndex = idx),
                  ),
                ),
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
            _OverviewCard(label: 'Revenue', value: '₹12,850', highlight: true),
            _OverviewCard(label: 'Live Tournaments', value: '2'),
            _OverviewCard(label: 'Registered Players', value: '50'),
            _OverviewCard(label: 'Active Tournaments', value: '10'),
          ],
        ),
      ],
    );
  }

  Widget _OverviewCard(
      {required String label, required String value, bool highlight = false}) {
    return Builder(builder: (context) {
      final cs = Theme.of(context).colorScheme;
      return _refCard(
        context: context,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(value,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: highlight ? cs.tertiary : cs.onSurface,
                )),
            const SizedBox(height: 4),
            Text(label,
                style: TextStyle(color: cs.onSurfaceVariant, fontSize: 12)),
          ],
        ),
      );
    });
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
            _QuickActionBtn(
                icon: Icons.add_circle_outline_rounded,
                label: 'Create\nTournament',
                onTap: () => context.push(AppRouter.createTournamentRoute)),
            _QuickActionBtn(
                icon: Icons.location_on_outlined, label: 'Manage\nVenue'),
            _QuickActionBtn(
                icon: Icons.people_outline_rounded, label: 'Registrations'),
            _QuickActionBtn(
                icon: Icons.calendar_today_outlined,
                label: 'Schedule\nMatches'),
          ],
        ),
      ],
    );
  }

  Widget _QuickActionBtn(
      {required IconData icon,
      required String label,
      VoidCallback? onTap}) {
    return Builder(builder: (context) {
      final cs = Theme.of(context).colorScheme;
      return GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Column(
          children: [
            GlassContainer(
              width: 64,
              height: 64,
              borderRadius: 16,
              blur: 14,
              borderWidth: 1,
              borderColor: _cardBorder(cs),
              backgroundColor: _cardFill(cs),
              padding: EdgeInsets.zero,
              child: Center(
                child: Icon(icon, color: cs.tertiary, size: 26),
              ),
            ),
            const SizedBox(height: 8),
            Text(label,
                textAlign: TextAlign.center,
                style:
                    TextStyle(color: cs.onSurface, fontSize: 11, height: 1.3)),
          ],
        ),
      );
    });
  }

  // ============================================================
  // ANNOUNCEMENTS BANNER
  // ============================================================
  Widget _buildAnnouncementsBanner(ColorScheme cs) {
    return GlassContainer(
      borderRadius: 14,
      blur: 14,
      borderWidth: 1,
      borderColor: _cardBorder(cs),
      backgroundColor: _cardFill(cs),
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
      return _refCard(
        context: context,
        padding: const EdgeInsets.all(16),
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
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    border: Border.all(color: cs.secondary, width: 1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text('Quarter Final',
                      style: TextStyle(
                          color: cs.secondary,
                          fontSize: 11,
                          fontWeight: FontWeight.w600)),
                ),
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

// ============================================================
// CUSTOM BOTTOM NAVIGATION (Glass + Active Glow)
// ============================================================
class _PartnerBottomNav extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const _PartnerBottomNav({required this.currentIndex, required this.onTap});

  static const List<_NavItem> _items = [
    _NavItem(Icons.home_rounded, 'Home'),
    _NavItem(Icons.calendar_month_rounded, 'Matches'),
    _NavItem(Icons.sports_cricket_rounded, 'Scoring'),
    _NavItem(Icons.person_outline_rounded, 'Profile'),
  ];

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      height: 60,
      decoration: BoxDecoration(
        color: const Color(0xFF0E0C08).withOpacity(0.95),
        border: Border(top: BorderSide(color: _cardBorder(cs))),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: List.generate(_items.length, (i) {
          final item = _items[i];
          final isActive = i == currentIndex;
          return GestureDetector(
            onTap: () => onTap(i),
            behavior: HitTestBehavior.opaque,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(item.icon,
                    color: isActive ? cs.tertiary : cs.onSurfaceVariant,
                    size: 24),
                const SizedBox(height: 4),
                Text(item.label,
                    style: TextStyle(
                      color: isActive ? cs.tertiary : cs.onSurfaceVariant,
                      fontSize: 11,
                      fontWeight:
                          isActive ? FontWeight.w600 : FontWeight.normal,
                    )),
                if (isActive)
                  Container(
                    margin: const EdgeInsets.only(top: 2),
                    width: 20,
                    height: 3,
                    decoration: BoxDecoration(
                      color: cs.tertiary,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  )
                else
                  const SizedBox(height: 5),
              ],
            ),
          );
        }),
      ),
    );
  }
}

class _NavItem {
  final IconData icon;
  final String label;
  const _NavItem(this.icon, this.label);
}
