import 'package:flutter/material.dart';
import 'package:ui_kit/ui_kit.dart';

import 'assign_referee_screen.dart';

class RefereeManagementScreen extends StatefulWidget {
  const RefereeManagementScreen({super.key});

  @override
  State<RefereeManagementScreen> createState() =>
      _RefereeManagementScreenState();
}

class _RefereeManagementScreenState extends State<RefereeManagementScreen> {
  final _searchController = TextEditingController();
  final Set<String> _assignedMatchIds = {};
  int _filter = 0;

  static const _matches = <_RefereeScheduleMatch>[
    _RefereeScheduleMatch(
      id: 'round-64',
      round: 'Round of 64',
      date: '15 July, 10:00 AM',
    ),
    _RefereeScheduleMatch(
      id: 'final',
      badge: 'Final',
      round: 'Round of 64',
      date: '15 July, 10:00 AM',
    ),
  ];

  static const _referees = <_ManagedReferee>[
    _ManagedReferee(
      name: 'Amit Verma',
      phone: '+91 98765 43210',
      level: 3,
      rating: 4.8,
      matches: 34,
      assignedMatches: 3,
      status: 'Available Now',
    ),
    _ManagedReferee(
      name: 'Sandeep Rao',
      phone: '+91 98480 24680',
      level: 2,
      rating: 4.6,
      matches: 31,
      assignedMatches: 3,
      status: 'Available Now',
    ),
    _ManagedReferee(
      name: 'Divya Sri',
      phone: '+91 97000 11223',
      level: 2,
      rating: 4.9,
      matches: 45,
      assignedMatches: 4,
      status: 'Busy',
      conflict: 'Scheduling conflict - same-day matches too close together',
    ),
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _assign(_RefereeScheduleMatch match) async {
    final selected = await Navigator.of(context).push<String>(
      MaterialPageRoute(
        builder: (_) => const AssignRefereeScreen(
          tournamentName: 'Hyderabad Super Cup',
          tournamentCode: 'SPT-20481',
        ),
      ),
    );
    if (selected == null || !mounted) return;
    setState(() => _assignedMatchIds.add(match.id));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$selected assigned successfully.')),
    );
  }

  void _openDetails(_ManagedReferee referee) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => _RefereeDetailsScreen(
          referee: referee,
          onAssignmentChanged: () {
            if (mounted) setState(() {});
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final scale = context.sportoScale;
    final query = _searchController.text.trim().toLowerCase();
    final visibleReferees = _referees
        .where((referee) =>
            query.isEmpty || referee.name.toLowerCase().contains(query))
        .toList();
    final pending = _matches
        .where((match) => !_assignedMatchIds.contains(match.id))
        .toList();

    return MediaQuery.withNoTextScaling(
      child: SafeArea(
        bottom: false,
        child: SportoResponsiveContent(
          padding: EdgeInsets.zero,
          child: Column(
            children: [
              SizedBox(
                height: 50 * scale,
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20 * scale),
                  child: Row(
                    children: [
                      Text('Referee',
                          style: Theme.of(context).textTheme.titleLarge),
                      const Spacer(),
                      IconButton(
                        onPressed: () {},
                        icon: Icon(Icons.light_mode_outlined,
                            color: cs.onSurface, size: 20),
                        style: IconButton.styleFrom(
                          backgroundColor: context.sporto.cardElevated
                              .withValues(alpha: .55),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Expanded(
                child: ListView(
                  physics: const ClampingScrollPhysics(),
                  padding: EdgeInsets.fromLTRB(
                    20 * scale,
                    20 * scale,
                    20 * scale,
                    context.sportoResponsive.bottomContentPadding(context) +
                        18 * scale,
                  ),
                  children: [
                    SportoTextField(
                      controller: _searchController,
                      hint: 'Search referee or tournament...',
                      height: 42 * scale,
                      prefix: SportoAssetIcon(
                        SportoAssets.searchNormal,
                        size: 20,
                        color: cs.onSurfaceVariant,
                      ),
                      suffixIcon: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 1,
                            height: 26 * scale,
                            color: context.sporto.border,
                          ),
                          SizedBox(width: 12 * scale),
                          Icon(Icons.sort_rounded,
                              color: cs.onSurfaceVariant, size: 20),
                        ],
                      ),
                      onChanged: (_) => setState(() {}),
                    ),
                    SizedBox(height: 29 * scale),
                    Row(
                      children: [
                        Expanded(child: _filterChip('By Match', 0)),
                        SizedBox(width: 10 * scale),
                        Expanded(child: _filterChip('By Date', 1)),
                        SizedBox(width: 10 * scale),
                        Expanded(child: _filterChip('By Venue', 2)),
                      ],
                    ),
                    SizedBox(height: 37 * scale),
                    Row(
                      children: [
                        Text('Needs Your Attention',
                            style: Theme.of(context).textTheme.bodyMedium),
                        const SizedBox(width: 8),
                        SportoBadge(
                          text: '${pending.length} Pending',
                          color: cs.primary,
                          outlined: true,
                          fontSize: 11,
                        ),
                      ],
                    ),
                    SizedBox(height: 12 * scale),
                    if (pending.isEmpty)
                      SportoCard(
                        child: Row(
                          children: [
                            Icon(Icons.check_circle_rounded,
                                color: cs.secondary),
                            const SizedBox(width: 10),
                            const Expanded(
                              child:
                                  Text('All matches have referees assigned.'),
                            ),
                          ],
                        ),
                      )
                    else
                      for (var i = 0; i < pending.length; i++) ...[
                        _pendingMatchCard(pending[i]),
                        if (i != pending.length - 1)
                          SizedBox(height: 10 * scale),
                      ],
                    SizedBox(height: 26 * scale),
                    Text('Referee Roster',
                        style: Theme.of(context).textTheme.bodyMedium),
                    SizedBox(height: 12 * scale),
                    if (visibleReferees.isEmpty)
                      SportoCard(
                        child: Text('No referees found.',
                            style: Theme.of(context).textTheme.bodyMedium),
                      )
                    else
                      for (var i = 0; i < visibleReferees.length; i++) ...[
                        _refereeCard(visibleReferees[i]),
                        if (i != visibleReferees.length - 1)
                          SizedBox(height: 10 * scale),
                      ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _filterChip(String label, int index) {
    final cs = Theme.of(context).colorScheme;
    return SportoFilterChip(
      type: SportoFilterChipType.filter,
      label: label,
      icon: Icons.sports_rounded,
      active: _filter == index,
      activeColor: cs.tertiary,
      inactiveFill: true,
      height: 42 * context.sportoScale,
      onTap: () => setState(() => _filter = index),
    );
  }

  Widget _pendingMatchCard(_RefereeScheduleMatch match) {
    final cs = Theme.of(context).colorScheme;
    return SportoCard(
      padding: const EdgeInsets.fromLTRB(14, 13, 14, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const _StatusDot(color: Color(0xFFFF334A)),
              const SizedBox(width: 7),
              const Text('Referee Needed',
                  style: TextStyle(color: Color(0xFFFF5265), fontSize: 13)),
            ],
          ),
          const SportoDivider(height: 18),
          if (match.badge != null) ...[
            SportoBadge(
              text: match.badge!,
              color: cs.secondary,
              fontSize: 10,
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            ),
            const SizedBox(height: 5),
          ],
          const Text('Hyderabad Super Cup',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(Icons.sports_cricket_rounded,
                  color: cs.onSurfaceVariant, size: 14),
              const SizedBox(width: 5),
              Text(match.round,
                  style: TextStyle(color: cs.onSurfaceVariant, fontSize: 12)),
              const Spacer(),
              Text(match.date,
                  style: TextStyle(color: cs.onSurfaceVariant, fontSize: 11)),
            ],
          ),
          const SizedBox(height: 5),
          Row(
            children: [
              SportoAssetIcon(SportoAssets.locationPin,
                  color: cs.secondary, size: 13),
              const SizedBox(width: 4),
              Text('Ground A',
                  style: TextStyle(color: cs.secondary, fontSize: 12)),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Text('Delhi Warriors',
                  style: TextStyle(color: cs.onSurfaceVariant, fontSize: 11)),
              const Spacer(),
              Text('Vs',
                  style: TextStyle(color: cs.onSurfaceVariant, fontSize: 10)),
              const Spacer(),
              Text('Hyd Highlanders',
                  style: TextStyle(color: cs.onSurfaceVariant, fontSize: 11)),
            ],
          ),
          const SportoDivider(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              SportoPillButton(
                label: 'Assign Referee',
                color: cs.primary,
                gradient: context.sporto.primaryGradient,
                foregroundColor: Colors.black,
                filled: true,
                height: 28,
                fontSize: 11,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                onTap: () => _assign(match),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _refereeCard(_ManagedReferee referee) {
    final cs = Theme.of(context).colorScheme;
    final available = referee.status == 'Available Now';
    final statusColor = available ? cs.secondary : const Color(0xFFFF7545);
    return SportoCard(
      onTap: () => _openDetails(referee),
      padding: const EdgeInsets.fromLTRB(14, 13, 14, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(referee.name,
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.w600)),
              ),
              _StatusDot(color: statusColor, size: 6),
              const SizedBox(width: 4),
              Text(referee.status,
                  style: TextStyle(color: statusColor, fontSize: 11)),
            ],
          ),
          const SizedBox(height: 4),
          Row(children: [
            Icon(Icons.sports_rounded, color: cs.onSurfaceVariant, size: 12),
            const SizedBox(width: 4),
            Text('Cricket  •  Level: ${referee.level} referee',
                style: TextStyle(color: cs.onSurfaceVariant, fontSize: 12)),
          ]),
          Row(children: [
            Icon(Icons.star_rounded, color: cs.tertiary, size: 12),
            const SizedBox(width: 3),
            Text('${referee.rating}  •  ${referee.matches} matches',
                style: TextStyle(color: cs.onSurfaceVariant, fontSize: 11)),
          ]),
          const SportoDivider(height: 18),
          Row(
            children: [
              Text('Assigned to ${referee.assignedMatches} matches',
                  style: TextStyle(color: cs.onSurfaceVariant, fontSize: 11)),
              const Spacer(),
              Text('View All  ›',
                  style: TextStyle(color: context.sporto.info, fontSize: 11)),
            ],
          ),
          if (referee.conflict != null) ...[
            const SizedBox(height: 5),
            Text(referee.conflict!,
                style: const TextStyle(color: Color(0xFFFF7545), fontSize: 10)),
          ],
        ],
      ),
    );
  }
}

class _RefereeDetailsScreen extends StatefulWidget {
  const _RefereeDetailsScreen({
    required this.referee,
    this.onAssignmentChanged,
  });

  final _ManagedReferee referee;
  final VoidCallback? onAssignmentChanged;

  @override
  State<_RefereeDetailsScreen> createState() => _RefereeDetailsScreenState();
}

class _RefereeDetailsScreenState extends State<_RefereeDetailsScreen> {
  final Set<String> _removed = {};

  Future<void> _reassign(String matchId) async {
    final selected = await Navigator.of(context).push<String>(
      MaterialPageRoute(
        builder: (_) => const AssignRefereeScreen(
          tournamentName: 'Hyderabad Super Cup',
          tournamentCode: 'SPT-20481',
        ),
      ),
    );
    if (selected == null || !mounted) return;
    widget.onAssignmentChanged?.call();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Match reassigned to $selected.')),
    );
  }

  void _remove(String id) {
    setState(() => _removed.add(id));
    widget.onAssignmentChanged?.call();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final matches = const [
      _RefereeScheduleMatch(
          id: 'detail-1',
          badge: 'Final',
          round: 'Round of 64',
          date: '15 July, 10:00 AM'),
      _RefereeScheduleMatch(
          id: 'detail-2',
          badge: 'Final',
          round: 'Round of 64',
          date: '15 July, 10:00 AM'),
    ].where((match) => !_removed.contains(match.id)).toList();

    return MediaQuery.withNoTextScaling(
      child: SportoScreenShell(
        appBar: AppBar(
          leading: Padding(
            padding: const EdgeInsets.all(8),
            child: IconButton(
              onPressed: () => Navigator.maybePop(context),
              icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
              style: IconButton.styleFrom(
                backgroundColor: context.sporto.cardElevated,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ),
          title: const Text('Referee Details'),
        ),
        body: SafeArea(
          top: false,
          child: SportoResponsiveContent(
            padding: EdgeInsets.zero,
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 5, 20, 32),
              children: [
                SportoCard(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 20,
                            backgroundColor: cs.surfaceContainerHigh,
                            child: Text(_initials(widget.referee.name),
                                style: TextStyle(color: cs.tertiary)),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(widget.referee.name,
                                    style: const TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w600)),
                                Text(widget.referee.phone,
                                    style: const TextStyle(fontSize: 11)),
                              ],
                            ),
                          ),
                          _StatusDot(color: cs.secondary, size: 6),
                          const SizedBox(width: 4),
                          Text(widget.referee.status,
                              style:
                                  TextStyle(color: cs.secondary, fontSize: 11)),
                        ],
                      ),
                      const SportoDivider(height: 18),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(children: [
                              Icon(Icons.sports_rounded,
                                  color: cs.onSurfaceVariant, size: 12),
                              const SizedBox(width: 4),
                              Text(
                                'Cricket  •  Level: ${widget.referee.level} referee',
                                style: TextStyle(
                                    color: cs.onSurfaceVariant, fontSize: 12),
                              ),
                            ]),
                            Row(children: [
                              Icon(Icons.star_rounded,
                                  color: cs.tertiary, size: 12),
                              const SizedBox(width: 3),
                              Text(
                                '${widget.referee.rating}  •  ${widget.referee.matches} matches',
                                style: TextStyle(
                                    color: cs.onSurfaceVariant, fontSize: 12),
                              ),
                            ]),
                          ],
                        ),
                      ),
                      const SportoDivider(height: 18),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Assigned to ${widget.referee.assignedMatches} matches',
                          style: TextStyle(
                              color: cs.onSurfaceVariant, fontSize: 11),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Text('All Allotted Matches',
                    style: TextStyle(color: context.sporto.info, fontSize: 14)),
                const SizedBox(height: 16),
                if (matches.isEmpty)
                  const SportoCard(child: Text('No allotted matches.'))
                else
                  for (var i = 0; i < matches.length; i++) ...[
                    Text('Aug ${30 + i}  •  1 match',
                        style: TextStyle(color: cs.tertiary, fontSize: 12)),
                    const SizedBox(height: 10),
                    _detailsMatchCard(matches[i]),
                    const SizedBox(height: 16),
                  ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _detailsMatchCard(_RefereeScheduleMatch match) {
    final cs = Theme.of(context).colorScheme;
    return SportoCard(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              SportoBadge(
                  text: match.badge!, color: cs.secondary, fontSize: 10),
              const SizedBox(width: 8),
              const _StatusDot(color: Color(0xFFFF334A)),
              const SizedBox(width: 5),
              const Text('Live Matches', style: TextStyle(fontSize: 12)),
            ],
          ),
          const SizedBox(height: 8),
          const Text('Hyderabad Super Cup',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(Icons.sports_cricket_rounded,
                  color: cs.onSurfaceVariant, size: 14),
              const SizedBox(width: 5),
              Text(match.round,
                  style: TextStyle(color: cs.onSurfaceVariant, fontSize: 12)),
              const Spacer(),
              Text(match.date,
                  style: TextStyle(color: cs.onSurfaceVariant, fontSize: 11)),
            ],
          ),
          const SizedBox(height: 5),
          Text('⌖ Ground A',
              style: TextStyle(color: cs.secondary, fontSize: 12)),
          const SportoDivider(height: 18),
          Row(
            children: [
              Text('Delhi Warriors',
                  style: TextStyle(color: cs.onSurfaceVariant, fontSize: 11)),
              const Spacer(),
              Text('Vs',
                  style: TextStyle(color: cs.onSurfaceVariant, fontSize: 10)),
              const Spacer(),
              Text('Hyd Highlanders',
                  style: TextStyle(color: cs.onSurfaceVariant, fontSize: 11)),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              SportoPillButton(
                label: 'Reassign',
                color: cs.tertiary,
                height: 28,
                fontSize: 11,
                padding: const EdgeInsets.symmetric(horizontal: 15),
                onTap: () => _reassign(match.id),
              ),
              const SizedBox(width: 10),
              SportoPillButton(
                label: 'Remove Referee',
                color: cs.error,
                height: 28,
                fontSize: 11,
                padding: const EdgeInsets.symmetric(horizontal: 13),
                onTap: () => _remove(match.id),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _initials(String name) => name
      .trim()
      .split(RegExp(r'\s+'))
      .take(2)
      .map((part) => part.isEmpty ? '' : part[0])
      .join()
      .toUpperCase();
}

class _RefereeScheduleMatch {
  const _RefereeScheduleMatch({
    required this.id,
    required this.round,
    required this.date,
    this.badge,
  });

  final String id;
  final String round;
  final String date;
  final String? badge;
}

class _ManagedReferee {
  const _ManagedReferee({
    required this.name,
    required this.phone,
    required this.level,
    required this.rating,
    required this.matches,
    required this.assignedMatches,
    required this.status,
    this.conflict,
  });

  final String name;
  final String phone;
  final int level;
  final double rating;
  final int matches;
  final int assignedMatches;
  final String status;
  final String? conflict;
}

class _StatusDot extends StatelessWidget {
  const _StatusDot({required this.color, this.size = 8});

  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) => Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          boxShadow: [BoxShadow(color: color, blurRadius: 7)],
        ),
      );
}
