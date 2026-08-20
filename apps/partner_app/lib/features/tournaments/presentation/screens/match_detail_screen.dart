import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:partner_data/partner_data.dart';
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

  PartnerTournamentResponse? _tournament;
  bool _isLoading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _selectedTabIndex = widget.initialTabIndex.clamp(0, _tabs.length - 1);
    if (widget.tournamentId != null && widget.tournamentId!.isNotEmpty) {
      _fetchTournamentDetails(widget.tournamentId!);
    }
  }

  Future<void> _fetchTournamentDetails(String id) async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final ds = PartnerRemoteDataSource(
        apiClient: SportoApiClient(tokenProvider: AuthSessionStore().getToken),
      );
      final data = await ds.showTournamentData(id);
      if (mounted) {
        setState(() {
          _tournament = data;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final scale = context.sportoScale;

    final name = _tournament?.name ?? 'Hyderabad Super Cup';
    final code = _tournament?.code ??
        (widget.tournamentId != null ? 'SPT-${widget.tournamentId}' : 'SPT-20481');

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
            Text(
              name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: tt.titleLarge?.copyWith(
                fontSize: 18 * scale,
                fontWeight: FontWeight.w600,
                color: cs.onSurface,
              ),
            ),
            Text(
              code,
              style: TextStyle(fontSize: 12, color: cs.onSurfaceVariant),
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        physics: const ClampingScrollPhysics(),
        padding: EdgeInsets.fromLTRB(
            20 * scale, 0, 20 * scale, 100 * scale),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (_isLoading) ...[
              const LinearProgressIndicator(),
              const SizedBox(height: 12),
            ],
            if (_error != null) ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: cs.errorContainer,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'Note: Failed to load latest details from API: $_error',
                  style: TextStyle(color: cs.onErrorContainer, fontSize: 12),
                ),
              ),
              const SizedBox(height: 16),
            ],

            // Dynamic Summary Card with static fallbacks
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
                  ),
                ),
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
    final statusLabel = _tournament?.workflowStatus.label ?? 'Live Matches';
    final isLive = _tournament?.status == 6;
    final registered = _tournament?.registeredTeams ?? 64;
    final maxTeams = _tournament?.maximumTeams ?? 127;

    return SportoCard(
      padding: const EdgeInsets.all(12),
      backgroundColor: cs.surfaceContainerHigh,
      borderColor: cs.secondary.withValues(alpha: .16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _tournament?.name ?? 'Hyderabad Super Cup',
            style: tt.titleLarge
                ?.copyWith(color: cs.onSurface, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isLive ? Colors.redAccent : cs.secondary,
                ),
              ),
              const SizedBox(width: 6),
              Text(
                statusLabel,
                style: TextStyle(
                    color: cs.onSurface, fontWeight: FontWeight.w500),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _tournament?.sport?.name ?? 'Cricket',
                style: TextStyle(
                    color: cs.secondary, fontWeight: FontWeight.w500),
              ),
              Expanded(
                child: RichText(
                  textAlign: TextAlign.end,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  text: TextSpan(
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          fontSize: 12,
                        ),
                    children: [
                      TextSpan(
                        text: '$registered / $maxTeams ',
                        style: TextStyle(
                          color: cs.secondary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      TextSpan(
                        text: 'Matches Completed',
                        style: TextStyle(color: cs.onSurfaceVariant),
                      ),
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
        color: SportoCard.defaultFill.withValues(alpha: 0.6),
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
            child: Text(
              placeholder,
              style: TextStyle(
                  color: cs.onSurfaceVariant.withValues(alpha: 0.6)),
            ),
          ),
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

  Widget _buildOverviewTab(ColorScheme cs, TextTheme tt) {
    final registered = _tournament?.registeredTeams ?? 128;
    final fee = _tournament?.registrationFee ?? '51,200';
    final prize = _tournament?.totalPrizeMoney ?? '60,000';
    final venues = _tournament?.tournamentVenues ?? [];

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
              Text('Team A',
                  style: TextStyle(
                      color: cs.tertiary, fontWeight: FontWeight.w500)),
              Text('Vs', style: TextStyle(color: cs.onSurfaceVariant)),
              Text('Team B',
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
                Text(venues.isNotEmpty ? venues.first.venueName : 'Ground A',
                    style: TextStyle(color: cs.onSurface, fontSize: 13)),
                Text(venues.isNotEmpty ? (venues.first.startTime ?? '09:15 AM') : '09:15 AM',
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
            Text(venues.length > 1 ? venues[1].venueName : 'Main Court', style: TextStyle(color: cs.onSurface)),
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
                value: '$registered',
                fontSize: 18,
                labelSize: 9,
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                backgroundColor: cs.surfaceContainerHigh),
            SportoStatCard(
                label: 'Approved',
                value: '$registered',
                highlight: true,
                fontSize: 18,
                labelSize: 9,
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                backgroundColor: cs.surfaceContainerHigh),
            SportoStatCard(
                label: 'Pending',
                value: '0',
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
      if (venues.isEmpty) ...[
        _overviewVenueStatus(cs, 'Available', 'Ground A', cs.secondary),
        const SizedBox(height: 10),
        _overviewVenueStatus(cs, 'Available', 'Ground B', cs.secondary),
      ] else
        ...venues.map((v) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _overviewVenueStatus(
                cs,
                'Active',
                v.venueName,
                cs.secondary,
              ),
            )),
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
                    label: 'Fee', value: '₹$fee', boldValue: true)),
            SportoCard(
                padding: const EdgeInsets.all(10),
                backgroundColor: cs.surfaceContainerHigh,
                child: SportoSummaryRow(
                    label: 'Expenses', value: '₹0', boldValue: true)),
            SportoCard(
                padding: const EdgeInsets.all(10),
                backgroundColor: cs.surfaceContainerHigh,
                child: SportoSummaryRow(
                    label: 'Prize Pool', value: '₹$prize', boldValue: true)),
            SportoCard(
                padding: const EdgeInsets.all(10),
                backgroundColor: cs.surfaceContainerHigh,
                child: SportoSummaryRow(
                    label: 'Status',
                    value: _tournament?.workflowStatus.label ?? 'Draft',
                    boldValue: true,
                    valueColor: cs.tertiary)),
          ]),
      const SizedBox(height: 20),
      _overviewProgress(cs),
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
                  value: '${_tournament?.tournamentVenues.length ?? 8}',
                  fontSize: 18,
                  labelSize: 9,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                  backgroundColor: cs.surfaceContainerHigh),
              SportoStatCard(
                  label: 'Live Now',
                  value: _tournament?.status == 6 ? '1' : '2',
                  highlight: true,
                  fontSize: 18,
                  labelSize: 9,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                  backgroundColor: cs.surfaceContainerHigh),
              SportoStatCard(
                  label: 'Completed',
                  value: _tournament?.status == 7 ? '1' : '4',
                  fontSize: 18,
                  labelSize: 9,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                  backgroundColor: cs.surfaceContainerHigh),
              SportoStatCard(
                  label: 'Delayed',
                  value: '0',
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
    final maxTeams = _tournament?.maximumTeams ?? 128;
    final rows = [
      ('Registration Closed', '$maxTeams Teams'),
      ('Round of $maxTeams', '${maxTeams ~/ 2} Teams'),
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
          name: 'Thunder Titans',
          initials: 'TT',
          captain: 'Captain A',
          players: '5/5 Players',
          joined: 'Joined: 15 July 2026',
          paid: true,
          approved: true),
      const SizedBox(height: 12),
      _TeamCard(
          name: 'Delhi Warriors',
          initials: 'DW',
          captain: 'Captain B',
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
          name: 'Referee A',
          level: 2,
          match: 'Thunder Titans Vs Delhi Warriors',
          ground: 'Ground A',
          round: 'Round of 64',
          status: 'live'),
      const SizedBox(height: 12),
      _RefereeCard(
          name: 'Referee B',
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
  // TAB 4: VENUES (DYNAMIC FROM API IF PRESENT, FALLBACK TO STATIC)
  // ============================================================
  Widget _buildVenuesTab(ColorScheme cs, TextTheme tt) {
    final venues = _tournament?.tournamentVenues ?? [];

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
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
          ])),
      const SizedBox(height: 16),
      if (venues.isEmpty) ...[
        _VenueCard(
          name: 'Main Venue',
          subName: 'Gachibowli Stadium',
          status: 'Available',
          statusColor: Colors.blue,
          actionLabel: 'View Details',
          actionColor: cs.tertiary,
        ),
        const SizedBox(height: 12),
        _VenueCard(
          name: 'Turf Pitch B',
          subName: 'Sporto Arena',
          status: 'Available',
          statusColor: Colors.blue,
          actionLabel: 'View Details',
          actionColor: cs.tertiary,
        ),
      ] else
        ...venues.map((v) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _VenueCard(
                name: v.venueName,
                subName: v.location ?? 'Ground Location',
                status: 'Active',
                statusColor: cs.secondary,
                startsIn: v.startTime,
                actionLabel: 'View Venue',
                actionColor: cs.tertiary,
              ),
            )),
    ]);
  }

  Widget _VenueCard({
    required String name,
    required String subName,
    required String status,
    required Color statusColor,
    String? match,
    String? startsIn,
    required String actionLabel,
    required Color actionColor,
  }) {
    return Builder(builder: (context) {
      final cs = Theme.of(context).colorScheme;
      return SportoCard(
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
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
        ],
      ]));
    });
  }

  // ============================================================
  // TAB 5: SCHEDULE
  // ============================================================
  Widget _buildScheduleTab(ColorScheme cs, TextTheme tt) {
    final startAt = _tournament?.tournamentStartAt ?? 'Today 09:00 AM';

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(children: [
            SportoFilterChip(label: 'Today', active: true),
            const SizedBox(width: 8),
            SportoFilterChip(label: 'Tomorrow'),
            const SizedBox(width: 8),
            SportoFilterChip(label: 'Live'),
          ])),
      const SizedBox(height: 20),
      Text(startAt,
          style: TextStyle(
              color: cs.onSurface, fontWeight: FontWeight.w600, fontSize: 16)),
      const SizedBox(height: 12),
      _ScheduleCard(
          time: startAt,
          ground: _tournament?.tournamentVenues.isNotEmpty == true
              ? _tournament!.tournamentVenues.first.venueName
              : 'Main Ground',
          match: '${_tournament?.name ?? "Hyderabad Super Cup"} Match 1',
          captain: 'Organized Match',
          action: 'View Details'),
    ]);
  }

  Widget _ScheduleCard({
    required String time,
    required String ground,
    required String match,
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
          Row(children: [
            SportoAssetIcon(SportoAssets.locationPin,
                size: 14, color: cs.onSurfaceVariant),
            const SizedBox(width: 4),
            Text(ground, style: TextStyle(color: cs.onSurfaceVariant))
          ]),
          Text(time,
              style: TextStyle(color: cs.onSurfaceVariant, fontSize: 12)),
        ]),
        const SizedBox(height: 12),
        Text(match,
            style: TextStyle(
                color: cs.onSurface,
                fontWeight: FontWeight.w600,
                fontSize: 15)),
        const SizedBox(height: 12),
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text(captain,
              style: TextStyle(color: cs.onSurfaceVariant, fontSize: 12)),
          Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                  color: (actionColor ?? cs.secondary).withValues(alpha: 0.15),
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
