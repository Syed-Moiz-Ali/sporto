import 'package:flutter/material.dart';
import 'package:ui_kit/ui_kit.dart';
import 'team_details_screen.dart';

// ============================================================
// MAIN TOURNAMENT DETAIL SCREEN
// ============================================================
class TournamentDetailScreen extends StatefulWidget {
  final String? tournamentId;
  final int initialTabIndex;

  const TournamentDetailScreen({
    super.key,
    this.tournamentId,
    this.initialTabIndex = 0,
  });

  @override
  State<TournamentDetailScreen> createState() => _TournamentDetailScreenState();
}

class _TournamentDetailScreenState extends State<TournamentDetailScreen> {
  late int _selectedTabIndex;
  final List<String> _tabs = [
    'Overview',
    'Teams',
    'Referees',
    'Schedule',
    'Venues',
  ];
  final List<String?> _tabAssets = [
    null,
    SportoAssets.cricketAction,
    SportoAssets.soccer,
    SportoAssets.calendarTick,
    SportoAssets.soccer,
  ];

  @override
  void initState() {
    super.initState();
    _selectedTabIndex = widget.initialTabIndex.clamp(0, _tabs.length - 1);
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final scale = context.sportoScale;

    return SportoScreenShell(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.all(8),
          child: Material(
            color: cs.surfaceContainerHigh,
            borderRadius: BorderRadius.circular(11),
            child: InkWell(
              borderRadius: BorderRadius.circular(11),
              onTap: () => Navigator.maybePop(context),
              child: Icon(Icons.arrow_back_ios_new_rounded,
                  color: cs.onSurface, size: 19),
            ),
          ),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Hyderabad Super Cup',
                style: tt.titleLarge?.copyWith(
                    fontSize: 18 * scale,
                    fontWeight: FontWeight.w600,
                    color: cs.onSurface)),
            Text('SPT-20481',
                style: TextStyle(fontSize: 12, color: cs.onSurfaceVariant)),
          ],
        ),
      ),
      body: SingleChildScrollView(
        physics: const ClampingScrollPhysics(),
        padding: EdgeInsets.fromLTRB(20 * scale, 0, 20 * scale, 100 * scale),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Summary Card
            _buildSummaryCard(cs, tt),
            SizedBox(height: 28 * scale),

            if (_selectedTabIndex == 0) ...[
              _buildOverviewStats(cs),
              SizedBox(height: 28 * scale),
            ],

            // Tab Navigation (Horizontal Scroll)
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: List.generate(
                    _tabs.length,
                    (i) => Padding(
                          padding: EdgeInsets.only(right: 8 * scale),
                          child: SportoTabChip(
                            label: _tabs[i],
                            asset: _tabAssets[i],
                            active: _selectedTabIndex == i,
                            onTap: () => setState(() => _selectedTabIndex = i),
                          ),
                        )),
              ),
            ),
            SizedBox(height: 20 * scale),

            // Search Bar
            if (_selectedTabIndex != 0) ...[
              _buildSearchBar(cs),
              SizedBox(height: 24 * scale),
            ],

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
              backgroundColor: context.sporto.card,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(
                    color: context.sporto.info.withValues(alpha: .55),
                    width: 5),
              ),
              icon: const SportoAssetIcon(
                SportoAssets.announcement,
                color: Colors.white,
                size: 18,
              ),
              label: const Text('Create Announcement'),
              onPressed: () {},
            )
          : null,
    );
  }

  Widget _buildSummaryCard(ColorScheme cs, TextTheme tt) {
    return SportoCard(
      padding: const EdgeInsets.all(12),
      backgroundColor: cs.surfaceContainerHigh,
      borderColor: cs.secondary.withValues(alpha: .16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Hyderabad Super Cup',
              style: tt.titleLarge
                  ?.copyWith(color: cs.onSurface, fontWeight: FontWeight.w600)),
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
                      color: cs.onSurface, fontWeight: FontWeight.w500)),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Round of 128',
                  style: TextStyle(
                      color: cs.secondary, fontWeight: FontWeight.w500)),
              Expanded(
                child: RichText(
                  textAlign: TextAlign.end,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  text: TextSpan(
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          fontFamily: 'packages/ui_kit/Quicksand',
                          fontSize: 12,
                        ),
                    children: [
                      TextSpan(
                          text: '64 / 127 ',
                          style: TextStyle(
                              color: cs.secondary,
                              fontWeight: FontWeight.bold)),
                      TextSpan(
                          text: 'Matches Completed',
                          style: TextStyle(color: cs.onSurfaceVariant)),
                    ],
                  ),
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
                ? 'Search Match...'
                : _selectedTabIndex == 4
                    ? 'Search Venue...'
                    : 'Search...';
    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: SportoCard.defaultFill.withOpacity(0.6),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: SportoCard.defaultBorder),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          SportoAssetIcon(SportoAssets.searchNormal,
              color: cs.onSurfaceVariant, size: 20),
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
        return _buildScheduleTab(cs, tt);
      case 4:
        return _buildVenuesTab(cs, tt);
      default:
        return const SizedBox.shrink();
    }
  }

  // ============================================================
  // TAB 1: OVERVIEW (Condensed for brevity, logic remains same)
  // ============================================================
  Widget _buildOverviewTab(ColorScheme cs, TextTheme tt) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text('Live Matches',
          style: TextStyle(
              color: cs.onSurfaceVariant,
              fontSize: 13,
              fontWeight: FontWeight.w500)),
      const SizedBox(height: 12),
      SportoCard(
          backgroundColor: cs.surfaceContainerHigh,
          borderColor: cs.secondary.withValues(alpha: .14),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Text('Delhi Warriors',
                  style: TextStyle(
                      color: cs.tertiary, fontWeight: FontWeight.w500)),
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
                      fontWeight: FontWeight.w600)),
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
            const SportoDivider(height: 24),
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
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Text('Upcoming Matches',
            style: TextStyle(color: cs.onSurfaceVariant, fontSize: 13)),
        Text('View All  ›',
            style: TextStyle(color: context.sporto.info, fontSize: 12)),
      ]),
      const SizedBox(height: 10),
      SportoCard(
          backgroundColor: cs.surfaceContainerHigh,
          borderColor: cs.secondary.withValues(alpha: .12),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Venue 3 - Ground C', style: TextStyle(color: cs.onSurface)),
            const SportoDivider(height: 18),
            Text('Starts at 03:30 PM',
                style: TextStyle(color: cs.onSurface, fontSize: 12)),
          ])),
      const SizedBox(height: 20),
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
          childAspectRatio:
              MediaQuery.sizeOf(context).width < 350 ? 1.35 : 1.68,
          children: [
            SportoStatCard(
                label: 'Registered',
                value: '128',
                fontSize: 18,
                labelSize: 9,
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                backgroundColor: cs.surfaceContainerHigh),
            SportoStatCard(
                label: 'Approved',
                value: '126',
                highlight: true,
                fontSize: 18,
                labelSize: 9,
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                backgroundColor: cs.surfaceContainerHigh),
            SportoStatCard(
                label: 'Pending',
                value: '2',
                color: Colors.orange,
                fontSize: 18,
                labelSize: 9,
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                backgroundColor: cs.surfaceContainerHigh),
            SportoStatCard(
                label: 'Rejected',
                value: '0',
                color: Colors.redAccent,
                fontSize: 18,
                labelSize: 9,
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                backgroundColor: cs.surfaceContainerHigh),
          ]),
      const SizedBox(height: 24),
      Text('Venue Status',
          style: TextStyle(color: cs.onSurfaceVariant, fontSize: 13)),
      const SizedBox(height: 10),
      _overviewVenueStatus(cs, 'Running', 'Ground A', cs.secondary),
      const SizedBox(height: 10),
      _overviewVenueStatus(cs, 'Running', 'Ground B', cs.secondary),
      const SizedBox(height: 10),
      _overviewVenueStatus(cs, 'Preparing', 'Ground C', Colors.orange),
      const SizedBox(height: 10),
      _overviewVenueStatus(cs, 'Maintenance', 'Ground D', context.sporto.live),
      const SizedBox(height: 20),
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
          childAspectRatio: 3.25,
          children: [
            SportoCard(
                padding: const EdgeInsets.all(10),
                backgroundColor: cs.surfaceContainerHigh,
                child: SportoSummaryRow(
                    label: 'Revenue', value: '₹51,200', boldValue: true)),
            SportoCard(
                padding: const EdgeInsets.all(10),
                backgroundColor: cs.surfaceContainerHigh,
                child: SportoSummaryRow(
                    label: 'Expenses', value: '₹21,000', boldValue: true)),
            SportoCard(
                padding: const EdgeInsets.all(10),
                backgroundColor: cs.surfaceContainerHigh,
                child: SportoSummaryRow(
                    label: 'Prize Pool', value: '₹60,000', boldValue: true)),
            SportoCard(
                padding: const EdgeInsets.all(10),
                backgroundColor: cs.surfaceContainerHigh,
                child: SportoSummaryRow(
                    label: 'Net',
                    value: '-₹29,800',
                    boldValue: true,
                    valueColor: Colors.redAccent)),
          ]),
      const SizedBox(height: 20),
      _overviewProgress(cs),
      const SizedBox(height: 20),
      _overviewNotice(cs, '⚠ Action Required', 'Round of 64 cannot start.',
          'Ground C has no referee assigned.', Colors.deepOrange,
          actionLabel: 'Assign Referee'),
      const SizedBox(height: 20),
      _overviewNotice(cs, '⚑ Registration closes in 3 hours.',
          '12 teams are still in payment pending.', '', context.sporto.live,
          actionLabel: 'Send Reminder', centeredAction: true),
    ]);
  }

  Widget _buildOverviewStats(ColorScheme cs) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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
            childAspectRatio:
                MediaQuery.sizeOf(context).width < 350 ? 1.0 : 1.22,
            children: [
              SportoStatCard(
                  label: "Today's\nMatches",
                  value: '18',
                  fontSize: 18,
                  labelSize: 9,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                  backgroundColor: cs.surfaceContainerHigh),
              SportoStatCard(
                  label: 'Live Now',
                  value: '12',
                  highlight: true,
                  fontSize: 18,
                  labelSize: 9,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                  backgroundColor: cs.surfaceContainerHigh),
              SportoStatCard(
                  label: 'Completed',
                  value: '5',
                  fontSize: 18,
                  labelSize: 9,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                  backgroundColor: cs.surfaceContainerHigh),
              SportoStatCard(
                  label: 'Delayed',
                  value: '1',
                  fontSize: 18,
                  labelSize: 9,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                  backgroundColor: cs.surfaceContainerHigh),
            ],
          ),
        ],
      );

  Widget _overviewVenueStatus(
          ColorScheme cs, String status, String ground, Color color) =>
      SizedBox(
        height: 54,
        child: SportoCard(
            padding: const EdgeInsets.all(10),
            backgroundColor: cs.surfaceContainerHigh,
            child: Row(children: [
              Container(
                  width: 8,
                  height: 8,
                  decoration:
                      BoxDecoration(color: color, shape: BoxShape.circle)),
              const SizedBox(width: 8),
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(status,
                    style: TextStyle(color: cs.onSurface, fontSize: 12)),
                Text(ground,
                    style: TextStyle(color: cs.secondary, fontSize: 11)),
              ]),
            ])),
      );

  Widget _overviewProgress(ColorScheme cs) {
    const rows = [
      ('Registration Closed', '128 Teams'),
      ('Round 128', '64 Teams'),
      ('Round 64', '32 Teams'),
      ('Round 32', '16 Teams'),
      ('Quarter Finals', '🔒 Locked'),
      ('Semi Finals', '🔒 Locked'),
      ('Final', '🔒 Locked')
    ];
    return SportoCard(
        backgroundColor: cs.surfaceContainerHigh,
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Tournament Progress',
              style: TextStyle(color: cs.onSurfaceVariant)),
          const SizedBox(height: 14),
          for (final row in rows)
            Padding(
                padding: const EdgeInsets.only(bottom: 9),
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(row.$1,
                          style: TextStyle(color: cs.secondary, fontSize: 12)),
                      Text(row.$2,
                          style: TextStyle(
                              color: cs.onSurfaceVariant, fontSize: 11)),
                    ])),
        ]));
  }

  Widget _overviewNotice(ColorScheme cs, String title, String message,
          String detail, Color color,
          {String? actionLabel, bool centeredAction = false}) =>
      Container(
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(12, 11, 12, 10),
          decoration: BoxDecoration(
              color: color.withValues(alpha: .12),
              border: Border.all(color: color.withValues(alpha: .34)),
              borderRadius: BorderRadius.circular(16)),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(title,
                style: TextStyle(
                    color: cs.onSurface,
                    fontSize: 13,
                    fontWeight: FontWeight.w500)),
            Divider(height: 18, color: cs.outline),
            if (centeredAction) ...[
              Center(
                child: Text(message,
                    textAlign: TextAlign.center,
                    style: TextStyle(color: color, fontSize: 12)),
              ),
              const SizedBox(height: 8),
              Center(child: _noticeAction(actionLabel!)),
            ] else ...[
              Text(message,
                  style: TextStyle(
                      color: color, fontSize: 13, fontWeight: FontWeight.w500)),
              const SizedBox(height: 5),
              Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Reason:',
                          style: TextStyle(
                              color: cs.onSurfaceVariant, fontSize: 10)),
                      Text(detail,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(color: cs.onSurface, fontSize: 11)),
                    ],
                  ),
                ),
                if (actionLabel != null) ...[
                  const SizedBox(width: 8),
                  _noticeAction(actionLabel),
                ],
              ]),
            ],
          ]));

  Widget _noticeAction(String label) => SizedBox(
        width: label == 'Assign Referee' ? 108 : 110,
        child: SportoPillButton(
          label: label,
          color: context.sporto.info,
          fontSize: 11,
          height: 31,
          padding: const EdgeInsets.symmetric(horizontal: 8),
          bordered: false,
          onTap: () {},
        ),
      );

  // ============================================================
  // TAB 2: TEAMS
  // ============================================================
  Widget _buildTeamsTab(ColorScheme cs, TextTheme tt) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(children: [
            SportoFilterChip(label: 'All', active: true),
            const SizedBox(width: 8),
            SportoFilterChip(label: 'Approved'),
            const SizedBox(width: 8),
            SportoFilterChip(label: 'Pending'),
            const SizedBox(width: 8),
            SportoFilterChip(label: 'Payment Pending'),
            const SizedBox(width: 8),
            SportoFilterChip(label: 'Rejected'),
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
      return SportoCard(
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
                      color: cs.onSurface, fontWeight: FontWeight.w600))),
          const SizedBox(width: 12),
          Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                Text(name,
                    style: TextStyle(
                        color: cs.onSurface,
                        fontWeight: FontWeight.w600,
                        fontSize: 16)),
                RichText(
                    text: TextSpan(
                        style: DefaultTextStyle.of(context)
                            .style
                            .copyWith(fontSize: 12),
                        children: [
                      TextSpan(
                          text: 'Captain: ',
                          style: TextStyle(color: cs.onSurfaceVariant)),
                      TextSpan(
                          text: captain, style: TextStyle(color: cs.secondary))
                    ])),
                Text('$players • $joined',
                    style: TextStyle(color: cs.onSurfaceVariant, fontSize: 11)),
              ])),
          IconButton(
              icon: Icon(Icons.more_vert_rounded, color: cs.onSurfaceVariant),
              onPressed: () {}),
        ]),
        const SizedBox(height: 12),
        Row(children: [
          SportoBadge(
              text: paid ? 'Paid' : 'Unpaid',
              color: paid ? cs.secondary : Colors.redAccent,
              outlined: true),
          const SizedBox(width: 8),
          SportoBadge(text: 'Approved', color: cs.secondary),
          const Spacer(),
          TextButton(
              onPressed: () =>
                  Navigator.of(context).push(MaterialPageRoute<void>(
                    builder: (_) => const TeamDetailsScreen(),
                  )),
              child: Text('View Details',
                  style: TextStyle(
                      color: cs.onSurface,
                      fontSize: 12,
                      fontWeight: FontWeight.w500))),
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
            SportoFilterChip(label: 'All', active: true),
            const SizedBox(width: 8),
            SportoFilterChip(label: 'Assigned'),
            const SizedBox(width: 8),
            SportoFilterChip(label: 'Available'),
            const SizedBox(width: 8),
            SportoFilterChip(label: 'Live Match'),
            const SizedBox(width: 8),
            SportoFilterChip(label: 'Unavailable'),
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

      return SportoCard(
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
                        fontWeight: FontWeight.w600,
                        fontSize: 16)),
                Text('Level: $level referee',
                    style: TextStyle(color: cs.onSurfaceVariant, fontSize: 12)),
              ])),
          IconButton(
              icon: Icon(Icons.more_vert_rounded, color: cs.onSurfaceVariant),
              onPressed: () {}),
        ]),
        if (match != null) ...[
          const SizedBox(height: 12),
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text(match.split(' Vs ')[0],
                style:
                    TextStyle(color: cs.tertiary, fontWeight: FontWeight.w500)),
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
                SportoAssetIcon(SportoAssets.locationPin,
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
                    style: TextStyle(color: cs.onSurfaceVariant, fontSize: 12))
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
                    style: TextStyle(color: cs.onSurfaceVariant, fontSize: 12))
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
                        fontWeight: FontWeight.w500,
                        fontSize: 12)))
          else if (match != null)
            TextButton(
                onPressed: () {},
                child: Text('View Details',
                    style: TextStyle(
                        color: cs.onSurface,
                        fontSize: 12,
                        fontWeight: FontWeight.w500))),
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
            SportoFilterChip(label: 'All', active: true),
            const SizedBox(width: 8),
            SportoFilterChip(label: 'Live'),
            const SizedBox(width: 8),
            SportoFilterChip(label: 'Preparing'),
            const SizedBox(width: 8),
            SportoFilterChip(label: 'Available'),
            const SizedBox(width: 8),
            SportoFilterChip(label: 'Maintenance'),
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
        actionColor: cs.tertiary, // Gold/Yellow
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
      return SportoCard(
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // Header: Name + Status
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Row(children: [
            SportoAssetIcon(SportoAssets.locationPin,
                color: cs.onSurfaceVariant, size: 18),
            const SizedBox(width: 6),
            Text(name,
                style: TextStyle(
                    color: cs.onSurface,
                    fontWeight: FontWeight.w600,
                    fontSize: 16)),
          ]),
          Row(children: [
            Container(
                width: 8,
                height: 8,
                decoration:
                    BoxDecoration(shape: BoxShape.circle, color: statusColor)),
            const SizedBox(width: 6),
            Text(status,
                style:
                    TextStyle(color: statusColor, fontWeight: FontWeight.w600)),
          ]),
        ]),
        const SizedBox(height: 4),
        Text(subName,
            style: TextStyle(color: cs.onSurfaceVariant, fontSize: 12)),

        // Conditional Middle Content
        if (match != null) ...[
          const SizedBox(height: 12),
          const SportoDivider(height: 1),
          const SizedBox(height: 12),
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text(match.split(' Vs ')[0],
                style:
                    TextStyle(color: cs.tertiary, fontWeight: FontWeight.w500)),
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
                        fontWeight: FontWeight.w500,
                        fontSize: 12))),
          ]),
        ] else if (staffReady) ...[
          const SizedBox(height: 12),
          const SportoDivider(height: 1),
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
            Expanded(
                child: RichText(
                    text: TextSpan(
                        style: DefaultTextStyle.of(context)
                            .style
                            .copyWith(fontSize: 12),
                        children: [
                  TextSpan(
                      text: 'Starts In: ',
                      style: TextStyle(color: cs.onSurfaceVariant)),
                  TextSpan(
                      text: startsIn,
                      style: TextStyle(
                          color: cs.secondary, fontWeight: FontWeight.w500))
                ]))),
            Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                    color: actionColor.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12)),
                child: Text(actionLabel,
                    style: TextStyle(
                        color: actionColor,
                        fontWeight: FontWeight.w500,
                        fontSize: 12))),
          ]),
        ] else if (referee != null) ...[
          const SizedBox(height: 12),
          const SportoDivider(height: 1),
          const SizedBox(height: 12),
          Text('Referee: $referee',
              style:
                  TextStyle(color: refereeColor ?? cs.onSurface, fontSize: 12)),
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
                        fontWeight: FontWeight.w500,
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
            SportoFilterChip(label: 'Today', active: true),
            const SizedBox(width: 8),
            SportoFilterChip(label: 'Tomorrow'),
            const SizedBox(width: 8),
            SportoFilterChip(label: 'Round'),
            const SizedBox(width: 8),
            SportoFilterChip(label: 'Ground'),
            const SizedBox(width: 8),
            SportoFilterChip(label: 'Live'),
          ])),
      const SizedBox(height: 20),
      Text('09:00 AM',
          style: TextStyle(
              color: cs.onSurface, fontWeight: FontWeight.w600, fontSize: 16)),
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
              color: cs.onSurface, fontWeight: FontWeight.w600, fontSize: 16)),
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
              color: cs.onSurface, fontWeight: FontWeight.w600, fontSize: 16)),
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
      return SportoCard(
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
                      color: Colors.redAccent, fontWeight: FontWeight.w600))
            ])
          else
            Row(children: [
              SportoAssetIcon(SportoAssets.locationPin,
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
                      fontWeight: FontWeight.w600,
                      fontSize: 18)),
              Text(overs!,
                  style: TextStyle(color: cs.onSurfaceVariant, fontSize: 12))
            ])
          else if (startsIn != null)
            Text(startsIn,
                style: TextStyle(
                    color: cs.secondary,
                    fontWeight: FontWeight.w500,
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
            SportoAssetIcon(SportoAssets.locationPin,
                size: 14, color: cs.secondary),
            const SizedBox(width: 4),
            Text(ground, style: TextStyle(color: cs.secondary, fontSize: 12))
          ]),
        ],
        const SizedBox(height: 12),
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text(match.split(' Vs ')[0],
              style:
                  TextStyle(color: cs.tertiary, fontWeight: FontWeight.w500)),
          Text('Vs', style: TextStyle(color: cs.onSurfaceVariant)),
          Text(match.split(' Vs ')[1],
              style: TextStyle(color: cs.onSurfaceVariant)),
        ]),
        const SizedBox(height: 12),
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text('Captain: $captain',
              style: TextStyle(color: cs.onSurfaceVariant, fontSize: 12)),
          Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                  color: (actionColor ?? cs.secondary).withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12)),
              child: Text(action,
                  style: TextStyle(
                      color: actionColor ?? cs.secondary,
                      fontWeight: FontWeight.w500,
                      fontSize: 12))),
        ]),
      ]));
    });
  }
}
