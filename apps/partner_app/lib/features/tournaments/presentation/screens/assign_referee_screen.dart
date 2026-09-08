import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:partner_data/partner_data.dart';
import 'package:ui_kit/ui_kit.dart';

class AssignRefereeScreen extends StatefulWidget {
  const AssignRefereeScreen({
    super.key,
    required this.tournamentName,
    required this.tournamentCode,
    this.tournamentId,
    this.matchId,
    this.match,
  });

  final String tournamentName;
  final String tournamentCode;
  final Object? tournamentId;
  final Object? matchId;
  final PartnerTournamentMatchResponse? match;

  @override
  State<AssignRefereeScreen> createState() => _AssignRefereeScreenState();
}

class _AssignRefereeScreenState extends State<AssignRefereeScreen> {
  final _searchController = TextEditingController();
  int _sortIndex = 0;
  late final PartnerRemoteDataSource _remoteDataSource =
      PartnerRemoteDataSource(
    apiClient: SportoApiClient(tokenProvider: AuthSessionStore().getToken),
  );
  List<PartnerEligibleRefereeResponse>? _apiReferees;
  bool _isLoading = false;
  String? _error;

  static const _referees = <_AvailableReferee>[
    _AvailableReferee(
        name: 'Amit Verma',
        level: 3,
        status: 'Available Now',
        rating: 4.8,
        matches: 34,
        assigned: 3),
    _AvailableReferee(
        name: 'Sandeep Rao',
        level: 3,
        status: 'Available Now',
        rating: 4.6,
        matches: 31,
        assigned: 3),
    _AvailableReferee(
        name: 'Divya Sri',
        level: 2,
        status: 'Busy',
        rating: 4.9,
        matches: 45,
        assigned: 4,
        conflict: 'Scheduling conflict - same-day matches too close together'),
  ];

  @override
  void initState() {
    super.initState();
    _loadEligibleReferees();
  }

  Future<void> _loadEligibleReferees() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final referees = await _remoteDataSource.listPartnerRefereesData();
      if (!mounted) return;
      setState(() {
        _apiReferees = referees
            .map(
              (referee) => PartnerEligibleRefereeResponse(
                id: referee.id,
                name: referee.name,
                status: referee.status,
                available: referee.isActive,
              ),
            )
            .toList();
        _isLoading = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _error = error.toString();
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final query = _searchController.text.trim().toLowerCase();
    final apiReferees = _apiReferees
        ?.where((referee) =>
            query.isEmpty || referee.displayName.toLowerCase().contains(query))
        .toList();
    final referees = _referees
        .where((referee) =>
            query.isEmpty || referee.name.toLowerCase().contains(query))
        .toList();

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
          title: const Text('Assign Referee',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
        ),
        body: SafeArea(
          top: false,
          child: SportoResponsiveContent(
            padding: EdgeInsets.zero,
            child: ListView(
              physics: const ClampingScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(20, 6, 20, 28),
              children: [
                _matchSummary(context),
                if (_isLoading) ...[
                  const SizedBox(height: 14),
                  const LinearProgressIndicator(),
                ],
                if (_error != null) ...[
                  const SizedBox(height: 14),
                  SportoCard(
                    child: Text(
                      'Unable to load live referees: $_error',
                      style: TextStyle(color: cs.error, fontSize: 12),
                    ),
                  ),
                ],
                const SizedBox(height: 30),
                SportoTextField(
                  controller: _searchController,
                  height: 42,
                  hint: 'Search referees...',
                  prefix: SportoAssetIcon(SportoAssets.searchNormal,
                      size: 20, color: cs.onSurfaceVariant),
                  onChanged: (_) => setState(() {}),
                ),
                const SizedBox(height: 24),
                Row(children: [
                  Text('Sort by |',
                      style: TextStyle(color: cs.onSurfaceVariant)),
                  const SizedBox(width: 8),
                  _sortButton('Matches', 0),
                  const SizedBox(width: 20),
                  _sortButton('Rating', 1),
                ]),
                const SizedBox(height: 25),
                Text('Select a referee',
                    style: TextStyle(color: context.sporto.info, fontSize: 16)),
                const SizedBox(height: 10),
                if (apiReferees != null)
                  if (apiReferees.isEmpty)
                    const SportoCard(child: Text('No eligible referees found.'))
                  else
                    for (var i = 0; i < apiReferees.length; i++) ...[
                      _apiRefereeCard(context, apiReferees[i]),
                      if (i != apiReferees.length - 1)
                        const SizedBox(height: 10),
                    ]
                else if (referees.isEmpty)
                  const SportoCard(child: Text('No referees found.'))
                else
                  for (var i = 0; i < referees.length; i++) ...[
                    _refereeCard(context, referees[i]),
                    if (i != referees.length - 1) const SizedBox(height: 10),
                  ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _sortButton(String label, int index) {
    final cs = Theme.of(context).colorScheme;
    final active = _sortIndex == index;
    return InkWell(
      onTap: () => setState(() => _sortIndex = index),
      child: Text(label,
          style: TextStyle(
              color: active ? cs.onSurface : cs.onSurfaceVariant,
              fontSize: 13)),
    );
  }

  Widget _matchSummary(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final match = widget.match;
    return SportoCard(
      radius: 15,
      blur: 0,
      padding: const EdgeInsets.all(12),
      backgroundColor: context.sporto.card,
      borderColor: cs.secondary.withValues(alpha: .16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(widget.tournamentCode,
            style: TextStyle(color: cs.onSurfaceVariant, fontSize: 11)),
        const SizedBox(height: 8),
        Text(widget.tournamentName,
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
        const SizedBox(height: 7),
        const Row(children: [
          _StatusDot(color: Color(0xFFFF334A)),
          SizedBox(width: 6),
          Text('Live Matches', style: TextStyle(fontSize: 13))
        ]),
        const SportoDivider(height: 18),
        Row(children: [
          Icon(Icons.sports_cricket_rounded,
              color: cs.onSurfaceVariant, size: 14),
          const SizedBox(width: 5),
          Text(match?.displayRound ?? 'Round of 64',
              style: TextStyle(color: cs.onSurfaceVariant, fontSize: 12)),
          const Spacer(),
          Text(_formatApiDate(match?.displayTime) ?? '15 July, 10:00 AM',
              style: TextStyle(color: cs.onSurfaceVariant, fontSize: 11)),
        ]),
        const SizedBox(height: 5),
        Row(children: [
          SportoAssetIcon(SportoAssets.locationPin,
              size: 13, color: cs.secondary),
          const SizedBox(width: 4),
          Text(match?.displayVenue ?? 'Ground A',
              style: TextStyle(color: cs.secondary, fontSize: 12)),
        ]),
      ]),
    );
  }

  Widget _apiRefereeCard(
    BuildContext context,
    PartnerEligibleRefereeResponse referee,
  ) {
    final cs = Theme.of(context).colorScheme;
    final available = referee.available != false &&
        !referee.displayStatus.toLowerCase().contains('busy');
    final statusColor = available ? cs.secondary : const Color(0xFFFF7545);
    return SportoCard(
      radius: 15,
      blur: 0,
      padding: const EdgeInsets.fromLTRB(14, 13, 14, 11),
      backgroundColor: context.sporto.card,
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Expanded(
              child: Text(referee.displayName,
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.w600))),
          _StatusDot(color: statusColor, size: 6),
          const SizedBox(width: 4),
          Text(referee.displayStatus,
              style: TextStyle(color: statusColor, fontSize: 11)),
        ]),
        const SizedBox(height: 3),
        Row(children: [
          Icon(Icons.sports_rounded, color: cs.onSurfaceVariant, size: 12),
          const SizedBox(width: 4),
          Text(
            '${referee.displaySport}  •  Level: ${referee.level ?? 1} referee',
            style: TextStyle(color: cs.onSurfaceVariant, fontSize: 12),
          ),
        ]),
        Row(children: [
          Icon(Icons.star_rounded, color: cs.tertiary, size: 12),
          const SizedBox(width: 3),
          Text(
            '${(referee.rating ?? 0).toStringAsFixed(1)}  •  ${referee.matches ?? 0} matches',
            style: TextStyle(color: cs.onSurfaceVariant, fontSize: 11),
          ),
        ]),
        const SportoDivider(height: 18),
        Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
          Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                Text('Assigned to ${referee.assignedMatches ?? 0} matches',
                    style: TextStyle(color: cs.onSurfaceVariant, fontSize: 11)),
                if (referee.conflict != null) ...[
                  const SizedBox(height: 4),
                  Text(referee.conflict!,
                      style: const TextStyle(
                          color: Color(0xFFFF7545), fontSize: 9, height: 1.2)),
                ],
              ])),
          if (available) ...[
            const SizedBox(width: 10),
            SportoPillButton(
              label: 'Assign',
              color: cs.primary,
              gradient: context.sporto.primaryGradient,
              filled: true,
              foregroundColor: Colors.black,
              height: 28,
              padding: const EdgeInsets.symmetric(horizontal: 29),
              fontSize: 11,
              onTap: () => _assignApiReferee(referee),
            ),
          ],
        ]),
      ]),
    );
  }

  Future<void> _assignApiReferee(PartnerEligibleRefereeResponse referee) async {
    if (widget.tournamentId == null || widget.matchId == null) {
      Navigator.pop(context, referee.displayName);
      return;
    }
    try {
      await _remoteDataSource.assignMatchRefereeData(
        widget.tournamentId!,
        widget.matchId!,
        PartnerMatchRefereeAssignmentRequest(refereeId: referee.id),
      );
      if (!mounted) return;
      Navigator.pop(context, referee.displayName);
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Unable to assign referee: $error')),
      );
    }
  }

  Widget _refereeCard(BuildContext context, _AvailableReferee referee) {
    final cs = Theme.of(context).colorScheme;
    final available = referee.status == 'Available Now';
    final statusColor = available ? cs.secondary : const Color(0xFFFF7545);
    return SportoCard(
      radius: 15,
      blur: 0,
      padding: const EdgeInsets.fromLTRB(14, 13, 14, 11),
      backgroundColor: context.sporto.card,
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Expanded(
              child: Text(referee.name,
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.w600))),
          _StatusDot(color: statusColor, size: 6),
          const SizedBox(width: 4),
          Text(referee.status,
              style: TextStyle(color: statusColor, fontSize: 11)),
        ]),
        const SizedBox(height: 3),
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
        Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
          Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                Text('Assigned to ${referee.assigned} matches',
                    style: TextStyle(color: cs.onSurfaceVariant, fontSize: 11)),
                if (referee.conflict != null) ...[
                  const SizedBox(height: 4),
                  Text(referee.conflict!,
                      style: const TextStyle(
                          color: Color(0xFFFF7545), fontSize: 9, height: 1.2)),
                ],
              ])),
          if (available) ...[
            const SizedBox(width: 10),
            SportoPillButton(
              label: 'Assign',
              color: cs.primary,
              gradient: context.sporto.primaryGradient,
              filled: true,
              foregroundColor: Colors.black,
              height: 28,
              padding: const EdgeInsets.symmetric(horizontal: 29),
              fontSize: 11,
              onTap: () => Navigator.pop(context, referee.name),
            ),
          ],
        ]),
      ]),
    );
  }
}

String? _formatApiDate(String? value) {
  if (value == null || value.trim().isEmpty) return null;
  final parsed = DateTime.tryParse(value);
  if (parsed == null) return value;
  final hour = parsed.hour == 0
      ? 12
      : parsed.hour > 12
          ? parsed.hour - 12
          : parsed.hour;
  final minute = parsed.minute.toString().padLeft(2, '0');
  final suffix = parsed.hour >= 12 ? 'PM' : 'AM';
  return '${parsed.day} ${_monthName(parsed.month)}, $hour:$minute $suffix';
}

String _monthName(int month) {
  const names = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];
  return names[(month - 1).clamp(0, names.length - 1)];
}

class _AvailableReferee {
  const _AvailableReferee(
      {required this.name,
      required this.level,
      required this.status,
      required this.rating,
      required this.matches,
      required this.assigned,
      this.conflict});
  final String name;
  final int level;
  final String status;
  final double rating;
  final int matches;
  final int assigned;
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
            boxShadow: [BoxShadow(color: color, blurRadius: 7)]),
      );
}
