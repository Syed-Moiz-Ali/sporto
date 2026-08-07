import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// ============================================================
// SHARED STYLING & HELPERS
// ============================================================
Color _cardFill(ColorScheme cs) => const Color(0xFF15171C).withOpacity(0.6);
Color _cardBorder(ColorScheme cs) => const Color(0x0FFFFFFF);
const double _cardRadius = 16;

Widget _refCard({
  required BuildContext context,
  required Widget child,
  EdgeInsetsGeometry padding = const EdgeInsets.all(16),
}) {
  final cs = Theme.of(context).colorScheme;
  return Container(
    decoration: BoxDecoration(
      color: _cardFill(cs),
      borderRadius: BorderRadius.circular(_cardRadius),
      border: Border.all(color: _cardBorder(cs)),
    ),
    padding: padding,
    child: child,
  );
}

// Custom Tab Chip
Widget _tabChip({
  required BuildContext context,
  required String label,
  IconData? icon,
  bool isActive = false,
  required VoidCallback onTap,
}) {
  final cs = Theme.of(context).colorScheme;
  return GestureDetector(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: isActive ? cs.secondary : _cardFill(cs),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isActive ? Colors.transparent : _cardBorder(cs),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon,
                size: 16, color: isActive ? Colors.white : cs.onSurfaceVariant),
            const SizedBox(width: 6),
          ],
          Text(
            label,
            style: TextStyle(
              color: isActive ? Colors.white : cs.onSurfaceVariant,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    ),
  );
}

// Status Badge
Widget _statusBadge({
  required BuildContext context,
  required String text,
  required Color color,
  bool outlined = false,
}) {
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    decoration: BoxDecoration(
      color: outlined ? Colors.transparent : color.withOpacity(0.15),
      borderRadius: BorderRadius.circular(6),
      border: outlined ? Border.all(color: color, width: 1) : null,
    ),
    child: Text(
      text,
      style: TextStyle(
        color: color,
        fontSize: 11,
        fontWeight: FontWeight.w600,
      ),
    ),
  );
}

// ============================================================
// MAIN TOURNAMENT DETAIL SCREEN
// ============================================================
class TournamentDetailScreen extends StatefulWidget {
  final String? tournamentId;

  const TournamentDetailScreen({super.key, this.tournamentId});

  @override
  State<TournamentDetailScreen> createState() => _TournamentDetailScreenState();
}

class _TournamentDetailScreenState extends State<TournamentDetailScreen> {
  // Updated tabs: Venues is now index 3, Schedule is index 4
  int _selectedTabIndex = 0;
  final List<String> _tabs = [
    'Overview',
    'Teams',
    'Referees',
    'Venues',
    'Schedule'
  ];
  final List<IconData> _tabIcons = [
    Icons.dashboard_outlined,
    Icons.sports_cricket_outlined,
    Icons.people_outline_rounded,
    Icons.location_on_outlined, // Venues icon
    Icons.calendar_today_outlined,
  ];

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: cs.onSurface),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Hyderabad Super Cup',
                style: GoogleFonts.spaceGrotesk(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: cs.onSurface)),
            Text('SPT-20481',
                style: TextStyle(fontSize: 12, color: cs.onSurfaceVariant)),
          ],
        ),
      ),
      body: SingleChildScrollView(
        physics: const ClampingScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Summary Card
            _buildSummaryCard(cs, tt),
            const SizedBox(height: 20),

            // Tab Navigation (Horizontal Scroll)
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: List.generate(
                    _tabs.length,
                    (i) => Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: _tabChip(
                            context: context,
                            label: _tabs[i],
                            icon: _tabIcons[i],
                            isActive: _selectedTabIndex == i,
                            onTap: () => setState(() => _selectedTabIndex = i),
                          ),
                        )),
              ),
            ),
            const SizedBox(height: 16),

            // Search Bar
            _buildSearchBar(cs),
            const SizedBox(height: 16),

            // Sub-screen Content
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: _buildCurrentTabContent(cs, tt),
            ),
          ],
        ),
      ),
      floatingActionButton: _selectedTabIndex == 0
          ? FloatingActionButton.extended(
              backgroundColor: cs.primary,
              foregroundColor: Colors.white,
              icon: const Icon(Icons.campaign_rounded),
              label: const Text('Create Announcement'),
              onPressed: () {},
            )
          : null,
    );
  }

  Widget _buildSummaryCard(ColorScheme cs, TextTheme tt) {
    return _refCard(
      context: context,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Hyderabad Super Cup',
              style: tt.titleLarge
                  ?.copyWith(color: cs.onSurface, fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          Row(
            children: [
              Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                      shape: BoxShape.circle, color: Colors.redAccent)),
              const SizedBox(width: 6),
              Text('Live Matches',
                  style: TextStyle(
                      color: cs.onSurface, fontWeight: FontWeight.w600)),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Round of 128',
                  style: TextStyle(
                      color: cs.secondary, fontWeight: FontWeight.w600)),
              RichText(
                text: TextSpan(
                  style: TextStyle(fontSize: 13),
                  children: [
                    TextSpan(
                        text: '64 / 127 ',
                        style: TextStyle(
                            color: cs.secondary, fontWeight: FontWeight.bold)),
                    TextSpan(
                        text: 'Matches Completed',
                        style: TextStyle(color: cs.onSurfaceVariant)),
                  ],
                ),
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
                ? 'Search Venue...'
                : _selectedTabIndex == 4
                    ? 'Search Match...'
                    : 'Search...';
    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: _cardFill(cs),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _cardBorder(cs)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Icon(Icons.search_rounded, color: cs.onSurfaceVariant, size: 20),
          const SizedBox(width: 12),
          Expanded(
              child: Text(placeholder,
                  style:
                      TextStyle(color: cs.onSurfaceVariant.withOpacity(0.6)))),
          Icon(Icons.sort_rounded, color: cs.onSurfaceVariant, size: 20),
        ],
      ),
    );
  }

  Widget _buildCurrentTabContent(ColorScheme cs, TextTheme tt) {
    switch (_selectedTabIndex) {
      case 0:
        return _buildOverviewTab(cs, tt);
      case 1:
        return _buildTeamsTab(cs, tt);
      case 2:
        return _buildRefereesTab(cs, tt);
      case 3:
        return _buildVenuesTab(cs, tt); // New Venues Tab
      case 4:
        return _buildScheduleTab(cs, tt);
      default:
        return const SizedBox.shrink();
    }
  }

  // ============================================================
  // TAB 1: OVERVIEW (Condensed for brevity, logic remains same)
  // ============================================================
  Widget _buildOverviewTab(ColorScheme cs, TextTheme tt) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text("Today's Overview",
          style: TextStyle(
              color: cs.onSurfaceVariant,
              fontSize: 13,
              fontWeight: FontWeight.w500)),
      const SizedBox(height: 12),
      GridView.count(
          crossAxisCount: 4,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 8,
          crossAxisSpacing: 8,
          childAspectRatio: 1.1,
          children: [
            _StatBox(label: "Today's\nMatches", value: '18'),
            _StatBox(label: 'Live Now', value: '12', highlight: true),
            _StatBox(label: 'Completed', value: '5'),
            _StatBox(label: 'Delayed', value: '1'),
          ]),
      const SizedBox(height: 24),
      Text('Live Matches',
          style: TextStyle(
              color: cs.onSurfaceVariant,
              fontSize: 13,
              fontWeight: FontWeight.w500)),
      const SizedBox(height: 12),
      _refCard(
          context: context,
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Text('Delhi Warriors',
                  style: TextStyle(
                      color: cs.tertiary, fontWeight: FontWeight.w600)),
              Text('Vs', style: TextStyle(color: cs.onSurfaceVariant)),
              Text('Hyd Highlanders',
                  style: TextStyle(color: cs.onSurfaceVariant)),
            ]),
            const SizedBox(height: 12),
            Center(
                child: Column(children: [
              Text('80/2',
                  style: TextStyle(
                      color: cs.tertiary,
                      fontSize: 32,
                      fontWeight: FontWeight.w700)),
              Text('4.3 Overs',
                  style: TextStyle(color: cs.onSurfaceVariant, fontSize: 13)),
            ])),
            const SizedBox(height: 12),
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Text('Required Run Rate: 8.5',
                  style: TextStyle(color: cs.onSurfaceVariant, fontSize: 12)),
              Text('Current RR: 9.1',
                  style: TextStyle(color: cs.onSurfaceVariant, fontSize: 12)),
            ]),
            const Divider(height: 24, color: Color(0x0FFFFFFF)),
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('Venue A - Ground A',
                    style: TextStyle(color: cs.onSurface, fontSize: 13)),
                Text('09:15 AM',
                    style: TextStyle(color: cs.onSurfaceVariant, fontSize: 12)),
              ]),
              TextButton(
                  onPressed: () {},
                  child:
                      Text('Manage →', style: TextStyle(color: cs.secondary))),
            ]),
          ])),
      const SizedBox(height: 24),
      Text('Registration Summary',
          style: TextStyle(
              color: cs.onSurfaceVariant,
              fontSize: 13,
              fontWeight: FontWeight.w500)),
      const SizedBox(height: 12),
      GridView.count(
          crossAxisCount: 4,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 8,
          crossAxisSpacing: 8,
          childAspectRatio: 1.1,
          children: [
            _StatBox(label: 'Registered', value: '128'),
            _StatBox(label: 'Approved', value: '126', highlight: true),
            _StatBox(label: 'Pending', value: '2', color: Colors.orange),
            _StatBox(label: 'Rejected', value: '0', color: Colors.redAccent),
          ]),
      const SizedBox(height: 24),
      Text('Finance Summary',
          style: TextStyle(
              color: cs.onSurfaceVariant,
              fontSize: 13,
              fontWeight: FontWeight.w500)),
      const SizedBox(height: 12),
      GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 8,
          crossAxisSpacing: 8,
          childAspectRatio: 2.5,
          children: [
            _FinanceBox(label: 'Revenue', value: '₹51,200'),
            _FinanceBox(label: 'Expenses', value: '21,000'),
            _FinanceBox(label: 'Prize Pool', value: '60,000'),
            _FinanceBox(label: 'Net', value: '-₹29,800', negative: true),
          ]),
    ]);
  }

  Widget _StatBox(
      {required String label,
      required String value,
      bool highlight = false,
      Color? color}) {
    return Builder(builder: (context) {
      final cs = Theme.of(context).colorScheme;
      return _refCard(
          context: context,
          padding: const EdgeInsets.all(12),
          child: Center(
            child:
                Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              Text(value,
                  style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color:
                          highlight ? cs.secondary : (color ?? cs.onSurface))),
              const SizedBox(height: 4),
              Text(label,
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 10, color: cs.onSurfaceVariant)),
            ]),
          ));
    });
  }

  Widget _FinanceBox(
      {required String label, required String value, bool negative = false}) {
    return Builder(builder: (context) {
      final cs = Theme.of(context).colorScheme;
      return _refCard(
          context: context,
          padding: const EdgeInsets.all(12),
          child:
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text(label,
                style: TextStyle(color: cs.onSurfaceVariant, fontSize: 12)),
            Text(value,
                style: TextStyle(
                    color: negative ? Colors.redAccent : cs.onSurface,
                    fontWeight: FontWeight.w700)),
          ]));
    });
  }

  // ============================================================
  // TAB 2: TEAMS
  // ============================================================
  Widget _buildTeamsTab(ColorScheme cs, TextTheme tt) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(children: [
            _FilterChip(label: 'All', active: true),
            const SizedBox(width: 8),
            _FilterChip(label: 'Approved'),
            const SizedBox(width: 8),
            _FilterChip(label: 'Pending'),
            const SizedBox(width: 8),
            _FilterChip(label: 'Payment Pending'),
            const SizedBox(width: 8),
            _FilterChip(label: 'Rejected'),
          ])),
      const SizedBox(height: 16),
      _TeamCard(
          name: 'Zoto Warrior',
          initials: 'ZW',
          captain: 'Shravan Prajapati',
          players: '5/5 Players',
          joined: 'Joined: 15 July 2026',
          paid: true,
          approved: true),
      const SizedBox(height: 12),
      _TeamCard(
          name: 'Delhi Warriors',
          initials: 'TT',
          captain: 'Amit Kumar',
          players: '5/5 Players',
          joined: 'Joined: 15 July 2026',
          paid: true,
          approved: true),
    ]);
  }

  Widget _FilterChip({required String label, bool active = false}) {
    return Builder(builder: (context) {
      final cs = Theme.of(context).colorScheme;
      return Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border:
                  Border.all(color: active ? cs.secondary : _cardBorder(cs))),
          child: Text(label,
              style: TextStyle(
                  color: active ? cs.secondary : cs.onSurfaceVariant,
                  fontSize: 12,
                  fontWeight: FontWeight.w500)));
    });
  }

  Widget _TeamCard(
      {required String name,
      required String initials,
      required String captain,
      required String players,
      required String joined,
      required bool paid,
      required bool approved}) {
    return Builder(builder: (context) {
      final cs = Theme.of(context).colorScheme;
      return _refCard(
          context: context,
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                      color: cs.surfaceContainerHigh,
                      borderRadius: BorderRadius.circular(10)),
                  alignment: Alignment.center,
                  child: Text(initials,
                      style: TextStyle(
                          color: cs.onSurface, fontWeight: FontWeight.w700))),
              const SizedBox(width: 12),
              Expanded(
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                    Text(name,
                        style: TextStyle(
                            color: cs.onSurface,
                            fontWeight: FontWeight.w700,
                            fontSize: 16)),
                    RichText(
                        text:
                            TextSpan(style: TextStyle(fontSize: 12), children: [
                      TextSpan(
                          text: 'Captain: ',
                          style: TextStyle(color: cs.onSurfaceVariant)),
                      TextSpan(
                          text: captain, style: TextStyle(color: cs.secondary))
                    ])),
                    Text('$players • $joined',
                        style: TextStyle(
                            color: cs.onSurfaceVariant, fontSize: 11)),
                  ])),
              IconButton(
                  icon:
                      Icon(Icons.more_vert_rounded, color: cs.onSurfaceVariant),
                  onPressed: () {}),
            ]),
            const SizedBox(height: 12),
            Row(children: [
              _statusBadge(
                  context: context,
                  text: paid ? 'Paid' : 'Unpaid',
                  color: paid ? cs.secondary : Colors.redAccent,
                  outlined: true),
              const SizedBox(width: 8),
              _statusBadge(
                  context: context, text: 'Approved', color: cs.secondary),
              const Spacer(),
              TextButton(
                  onPressed: () {},
                  child: Text('View Details',
                      style: TextStyle(
                          color: cs.onSurface,
                          fontSize: 12,
                          fontWeight: FontWeight.w600))),
            ]),
          ]));
    });
  }

  // ============================================================
  // TAB 3: REFEREES
  // ============================================================
  Widget _buildRefereesTab(ColorScheme cs, TextTheme tt) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(children: [
            _FilterChip(label: 'All', active: true),
            const SizedBox(width: 8),
            _FilterChip(label: 'Assigned'),
            const SizedBox(width: 8),
            _FilterChip(label: 'Available'),
            const SizedBox(width: 8),
            _FilterChip(label: 'Live Match'),
            const SizedBox(width: 8),
            _FilterChip(label: 'Unavailable'),
          ])),
      const SizedBox(height: 16),
      _RefereeCard(
          name: 'Rohit Sharma',
          level: 2,
          match: 'Delhi Warriors Vs Hyd Highlanders',
          ground: 'Ground A',
          round: 'Round of 64',
          status: 'live'),
      const SizedBox(height: 12),
      _RefereeCard(
          name: 'Amit Verma',
          level: 3,
          lastMatch: 'Last Match Finished 1 hr ago',
          status: 'available'),
    ]);
  }

  Widget _RefereeCard(
      {required String name,
      required int level,
      String? match,
      String? ground,
      String? round,
      String? lastMatch,
      required String status}) {
    return Builder(builder: (context) {
      final cs = Theme.of(context).colorScheme;
      final isAssignable = status == 'available';

      Color statusColor = status == 'live'
          ? Colors.redAccent
          : status == 'available'
              ? cs.secondary
              : status == 'break'
                  ? Colors.orange
                  : cs.onTertiary;

      return _refCard(
          context: context,
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Expanded(
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                    Text(name,
                        style: TextStyle(
                            color: cs.onSurface,
                            fontWeight: FontWeight.w700,
                            fontSize: 16)),
                    Text('Level: $level referee',
                        style: TextStyle(
                            color: cs.onSurfaceVariant, fontSize: 12)),
                  ])),
              IconButton(
                  icon:
                      Icon(Icons.more_vert_rounded, color: cs.onSurfaceVariant),
                  onPressed: () {}),
            ]),
            if (match != null) ...[
              const SizedBox(height: 12),
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Text(match.split(' Vs ')[0],
                    style: TextStyle(
                        color: cs.tertiary, fontWeight: FontWeight.w600)),
                Text('Vs', style: TextStyle(color: cs.onSurfaceVariant)),
                Text(match.split(' Vs ')[1],
                    style: TextStyle(color: cs.onSurfaceVariant)),
              ]),
            ],
            const SizedBox(height: 12),
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                if (ground != null)
                  Row(children: [
                    Icon(Icons.location_on_outlined,
                        size: 14, color: cs.secondary),
                    const SizedBox(width: 4),
                    Text(ground,
                        style: TextStyle(color: cs.secondary, fontSize: 12))
                  ]),
                if (round != null)
                  Row(children: [
                    Icon(Icons.edit_note_outlined,
                        size: 14, color: cs.onSurfaceVariant),
                    const SizedBox(width: 4),
                    Text(round,
                        style:
                            TextStyle(color: cs.onSurfaceVariant, fontSize: 12))
                  ]),
                if (lastMatch != null)
                  Row(children: [
                    Container(
                        width: 6,
                        height: 6,
                        decoration: BoxDecoration(
                            shape: BoxShape.circle, color: statusColor)),
                    const SizedBox(width: 6),
                    Text(lastMatch,
                        style:
                            TextStyle(color: cs.onSurfaceVariant, fontSize: 12))
                  ]),
              ]),
              if (isAssignable)
                Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                        color: cs.tertiary,
                        borderRadius: BorderRadius.circular(20)),
                    child: Text('Assign',
                        style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.w600,
                            fontSize: 12)))
              else if (match != null)
                TextButton(
                    onPressed: () {},
                    child: Text('View Details',
                        style: TextStyle(
                            color: cs.onSurface,
                            fontSize: 12,
                            fontWeight: FontWeight.w600))),
            ]),
          ]));
    });
  }

  // ============================================================
  // TAB 4: VENUES (NEW)
  // ============================================================
  Widget _buildVenuesTab(ColorScheme cs, TextTheme tt) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      // Venue Filters
      SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(children: [
            _FilterChip(label: 'All', active: true),
            const SizedBox(width: 8),
            _FilterChip(label: 'Live'),
            const SizedBox(width: 8),
            _FilterChip(label: 'Preparing'),
            const SizedBox(width: 8),
            _FilterChip(label: 'Available'),
            const SizedBox(width: 8),
            _FilterChip(label: 'Maintenance'),
          ])),
      const SizedBox(height: 16),

      // Venue Cards
      _VenueCard(
        name: 'Ground B',
        subName: 'Hyderabad Cricket Stadium',
        status: 'LIVE',
        statusColor: Colors.redAccent,
        match: 'Delhi Warriors Vs Hyd Highlanders',
        captain: 'Shravan Prajapati',
        actionLabel: 'Open Live Match',
        actionColor: Colors.redAccent,
      ),
      const SizedBox(height: 12),

      _VenueCard(
        name: 'Ground B',
        subName: 'Community Ground',
        status: 'Preparing',
        statusColor: Colors.orange,
        staffReady: true,
        referee: 'Amit Verma',
        startsIn: '18 Minutes',
        actionLabel: 'Open Match',
        actionColor: Colors.blue,
      ),
      const SizedBox(height: 12),

      _VenueCard(
        name: 'Ground B',
        subName: 'Indoor Arena',
        status: 'Available',
        statusColor: Colors.blue,
        referee: 'Not Assigned',
        refereeColor: Colors.redAccent,
        nextMatch: '05:30 PM',
        actionLabel: 'Assign Referee',
        actionColor: const Color(0xFFF4B41A), // Gold/Yellow
      ),
      const SizedBox(height: 12),

      _VenueCard(
        name: 'Ground D',
        subName: 'Practice Ground',
        status: 'Maintenance',
        statusColor: Colors.redAccent,
        referee: 'Flood Lights Repair',
        refereeColor: Colors.redAccent,
        available: 'Tomorrow',
        actionLabel: 'View Details',
        actionColor: cs.onSurfaceVariant,
      ),
    ]);
  }

  Widget _VenueCard({
    required String name,
    required String subName,
    required String status,
    required Color statusColor,
    String? match,
    String? captain,
    bool staffReady = false,
    String? referee,
    Color? refereeColor,
    String? startsIn,
    String? nextMatch,
    String? available,
    required String actionLabel,
    required Color actionColor,
  }) {
    return Builder(builder: (context) {
      final cs = Theme.of(context).colorScheme;
      return _refCard(
          context: context,
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            // Header: Name + Status
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Row(children: [
                Icon(Icons.location_on_outlined,
                    color: cs.onSurfaceVariant, size: 18),
                const SizedBox(width: 6),
                Text(name,
                    style: TextStyle(
                        color: cs.onSurface,
                        fontWeight: FontWeight.w700,
                        fontSize: 16)),
              ]),
              Row(children: [
                Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                        shape: BoxShape.circle, color: statusColor)),
                const SizedBox(width: 6),
                Text(status,
                    style: TextStyle(
                        color: statusColor, fontWeight: FontWeight.w700)),
              ]),
            ]),
            const SizedBox(height: 4),
            Text(subName,
                style: TextStyle(color: cs.onSurfaceVariant, fontSize: 12)),

            // Conditional Middle Content
            if (match != null) ...[
              const SizedBox(height: 12),
              const Divider(height: 1, color: Color(0x0FFFFFFF)),
              const SizedBox(height: 12),
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Text(match.split(' Vs ')[0],
                    style: TextStyle(
                        color: cs.tertiary, fontWeight: FontWeight.w600)),
                Text('Vs', style: TextStyle(color: cs.onSurfaceVariant)),
                Text(match.split(' Vs ')[1],
                    style: TextStyle(color: cs.onSurfaceVariant)),
              ]),
              const SizedBox(height: 12),
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Text('Captain: $captain',
                    style: TextStyle(color: cs.onSurfaceVariant, fontSize: 12)),
                Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                        color: actionColor.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(12)),
                    child: Text(actionLabel,
                        style: TextStyle(
                            color: actionColor,
                            fontWeight: FontWeight.w600,
                            fontSize: 12))),
              ]),
            ] else if (staffReady) ...[
              const SizedBox(height: 12),
              const Divider(height: 1, color: Color(0x0FFFFFFF)),
              const SizedBox(height: 12),
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Row(children: [
                  Icon(Icons.check_circle_outline_rounded,
                      color: cs.secondary, size: 16),
                  const SizedBox(width: 6),
                  Text('Staff Ready',
                      style: TextStyle(color: cs.onSurface, fontSize: 12))
                ]),
                Text('Referee: $referee',
                    style: TextStyle(color: cs.onSurfaceVariant, fontSize: 12)),
              ]),
              const SizedBox(height: 12),
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                RichText(
                    text: TextSpan(style: TextStyle(fontSize: 12), children: [
                  TextSpan(
                      text: 'Starts In: ',
                      style: TextStyle(color: cs.onSurfaceVariant)),
                  TextSpan(
                      text: startsIn,
                      style: TextStyle(
                          color: cs.secondary, fontWeight: FontWeight.w600))
                ])),
                Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                        color: actionColor.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(12)),
                    child: Text(actionLabel,
                        style: TextStyle(
                            color: actionColor,
                            fontWeight: FontWeight.w600,
                            fontSize: 12))),
              ]),
            ] else if (referee != null) ...[
              const SizedBox(height: 12),
              const Divider(height: 1, color: Color(0x0FFFFFFF)),
              const SizedBox(height: 12),
              Text('Referee: $referee',
                  style: TextStyle(
                      color: refereeColor ?? cs.onSurface, fontSize: 12)),
              const SizedBox(height: 12),
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Text(
                    nextMatch != null
                        ? 'Next Match: $nextMatch'
                        : 'Available : $available',
                    style: TextStyle(color: cs.onSurfaceVariant, fontSize: 12)),
                Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                        color: actionColor.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(12)),
                    child: Text(actionLabel,
                        style: TextStyle(
                            color: actionColor,
                            fontWeight: FontWeight.w600,
                            fontSize: 12))),
              ]),
            ],
          ]));
    });
  }

  // ============================================================
  // TAB 5: SCHEDULE (Fixed startsIn parameter)
  // ============================================================
  Widget _buildScheduleTab(ColorScheme cs, TextTheme tt) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(children: [
            _FilterChip(label: 'Today', active: true),
            const SizedBox(width: 8),
            _FilterChip(label: 'Tomorrow'),
            const SizedBox(width: 8),
            _FilterChip(label: 'Round'),
            const SizedBox(width: 8),
            _FilterChip(label: 'Ground'),
            const SizedBox(width: 8),
            _FilterChip(label: 'Live'),
          ])),
      const SizedBox(height: 20),
      Text('09:00 AM',
          style: TextStyle(
              color: cs.onSurface, fontWeight: FontWeight.w700, fontSize: 16)),
      const SizedBox(height: 12),
      _ScheduleCard(
          time: '09:00 AM',
          isLive: true,
          score: '82/3',
          overs: 'Overs: 4.2',
          ground: 'Ground A',
          match: 'Delhi Warriors Vs Hyd Highlanders',
          captain: 'Shravan Prajapati',
          action: 'Open Live Match',
          actionColor: Colors.redAccent),
      const SizedBox(height: 20),
      Text('09:30 AM',
          style: TextStyle(
              color: cs.onSurface, fontWeight: FontWeight.w700, fontSize: 16)),
      const SizedBox(height: 12),
      _ScheduleCard(
          time: '09:30 AM',
          ground: 'Ground A',
          startsIn: 'Starts in 18m',
          match: 'Delhi Warriors Vs Hyd Highlanders',
          round: 'Round of 64',
          captain: 'Shravan Prajapati',
          action: 'Manage Match'),
      const SizedBox(height: 20),
      Text('Mon 02 Aug, 09:30 AM',
          style: TextStyle(
              color: cs.onSurface, fontWeight: FontWeight.w700, fontSize: 16)),
      const SizedBox(height: 12),
      _ScheduleCard(
          time: 'Mon 02 Aug, 09:30 AM',
          ground: 'Ground B',
          match: 'Delhi Warriors Vs Hyd Highlanders',
          captain: 'Shravan Prajapati',
          action: 'Manage Match'),
    ]);
  }

  Widget _ScheduleCard({
    required String time,
    bool isLive = false,
    String? score,
    String? overs,
    required String ground,
    required String match,
    String? round,
    String? startsIn, // Fixed: Added this parameter
    required String captain,
    required String action,
    Color? actionColor,
  }) {
    return Builder(builder: (context) {
      final cs = Theme.of(context).colorScheme;
      return _refCard(
          context: context,
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              if (isLive)
                Row(children: [
                  Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                          shape: BoxShape.circle, color: Colors.redAccent)),
                  const SizedBox(width: 6),
                  Text('LIVE',
                      style: TextStyle(
                          color: Colors.redAccent, fontWeight: FontWeight.w700))
                ])
              else
                Row(children: [
                  Icon(Icons.location_on_outlined,
                      size: 14, color: cs.onSurfaceVariant),
                  const SizedBox(width: 4),
                  Text(ground, style: TextStyle(color: cs.onSurfaceVariant))
                ]),

              // Fixed: Logic to display score, startsIn, or time
              if (score != null)
                Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                  Text(score,
                      style: TextStyle(
                          color: cs.onSurface,
                          fontWeight: FontWeight.w700,
                          fontSize: 18)),
                  Text(overs!,
                      style:
                          TextStyle(color: cs.onSurfaceVariant, fontSize: 12))
                ])
              else if (startsIn != null)
                Text(startsIn,
                    style: TextStyle(
                        color: cs.secondary,
                        fontWeight: FontWeight.w600,
                        fontSize: 12))
              else if (round != null)
                Text(round,
                    style: TextStyle(color: cs.onSurfaceVariant, fontSize: 12))
              else
                Text(time,
                    style: TextStyle(color: cs.onSurfaceVariant, fontSize: 12)),
            ]),
            if (isLive) ...[
              const SizedBox(height: 8),
              Row(children: [
                Icon(Icons.location_on_outlined, size: 14, color: cs.secondary),
                const SizedBox(width: 4),
                Text(ground,
                    style: TextStyle(color: cs.secondary, fontSize: 12))
              ]),
            ],
            const SizedBox(height: 12),
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Text(match.split(' Vs ')[0],
                  style: TextStyle(
                      color: cs.tertiary, fontWeight: FontWeight.w600)),
              Text('Vs', style: TextStyle(color: cs.onSurfaceVariant)),
              Text(match.split(' Vs ')[1],
                  style: TextStyle(color: cs.onSurfaceVariant)),
            ]),
            const SizedBox(height: 12),
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Text('Captain: $captain',
                  style: TextStyle(color: cs.onSurfaceVariant, fontSize: 12)),
              Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                      color: (actionColor ?? cs.secondary).withOpacity(0.15),
                      borderRadius: BorderRadius.circular(12)),
                  child: Text(action,
                      style: TextStyle(
                          color: actionColor ?? cs.secondary,
                          fontWeight: FontWeight.w600,
                          fontSize: 12))),
            ]),
          ]));
    });
  }
}
