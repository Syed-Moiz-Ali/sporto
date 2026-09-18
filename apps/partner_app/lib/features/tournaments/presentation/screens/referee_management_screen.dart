import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:partner_data/partner_data.dart';
import 'package:ui_kit/ui_kit.dart';

import 'assign_referee_screen.dart';
import 'referee_details_screen.dart';

class RefereeManagementScreen extends StatefulWidget {
  const RefereeManagementScreen({
    super.key,
    this.remoteDataSource,
    this.loadRemote = true,
    this.initialMatches,
    this.initialReferees,
  });

  final PartnerRemoteDataSource? remoteDataSource;
  final bool loadRemote;
  final List<RefereeScheduleMatch>? initialMatches;
  final List<ManagedReferee>? initialReferees;

  @override
  State<RefereeManagementScreen> createState() =>
      _RefereeManagementScreenState();
}

class _RefereeManagementScreenState extends State<RefereeManagementScreen> {
  final _searchController = TextEditingController();
  final Set<String> _assignedMatchIds = {};
  late final PartnerRemoteDataSource _remoteDataSource =
      widget.remoteDataSource ??
          PartnerRemoteDataSource(
            apiClient:
                SportoApiClient(tokenProvider: AuthSessionStore().getToken),
          );
  List<RefereeScheduleMatch>? _apiMatches;
  List<ManagedReferee>? _apiReferees;
  bool _isLoading = false;
  int _filter = 0; // 0 = By Match, 1 = By Date, 2 = By Venue

  @override
  void initState() {
    super.initState();
    if (widget.initialMatches != null) {
      _apiMatches = List.of(widget.initialMatches!);
    }
    if (widget.initialReferees != null) {
      _apiReferees = List.of(widget.initialReferees!);
    }
    if (widget.loadRemote) {
      _loadLiveData();
    }
  }

  Future<void> _loadLiveData() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final tournaments = await _remoteDataSource.listTournamentsData();
      final liveMatches = <RefereeScheduleMatch>[];
      for (final tournament in tournaments) {
        final matches =
            await _remoteDataSource.listTournamentMatchesData(tournament.id);
        liveMatches.addAll(matches.map(
          (match) => RefereeScheduleMatch.fromApi(match, tournament),
        ));
      }

      final referees = await _remoteDataSource.listPartnerRefereesData();

      if (!mounted) return;
      setState(() {
        _apiMatches = liveMatches;
        _apiReferees =
            referees.map(_managedRefereeFromPartnerReferee).toList();
        _isLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _apiMatches ??= [];
        _apiReferees ??= [];
        _isLoading = false;
      });
    }
  }

  ManagedReferee _managedRefereeFromPartnerReferee(
      PartnerRefereeResponse referee) {
    return ManagedReferee(
      id: referee.id,
      name: referee.name,
      phone: referee.mobileNumber ?? '',
      level: referee.level ?? 1,
      rating: referee.rating ?? 0.0,
      matches: referee.matches ?? 0,
      assignedMatches: referee.assignedMatches ?? 0,
      status: referee.displayStatus,
      conflict: referee.conflict,
      sport: referee.displaySport,
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _assign(RefereeScheduleMatch match) async {
    final selected = await Navigator.of(context).push<String>(
      MaterialPageRoute(
        builder: (_) => AssignRefereeScreen(
          tournamentName: match.tournamentName,
          tournamentCode: match.tournamentCode,
          tournamentId: match.tournamentId,
          matchId: match.matchId,
          match: match.rawMatch,
        ),
      ),
    );
    if (selected == null || !mounted) return;
    setState(() => _assignedMatchIds.add(match.id));
    if (match.tournamentId != null) {
      await _loadLiveData();
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$selected assigned successfully.')),
    );
  }

  void _openDetails(ManagedReferee referee) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => RefereeDetailsScreen(
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
    final query = _searchController.text.trim().toLowerCase();
    final isLoading = _isLoading && (_apiMatches == null || _apiReferees == null);
    final sourceReferees = _apiReferees ?? const <ManagedReferee>[];
    final sourceMatches = _apiMatches ?? const <RefereeScheduleMatch>[];

    final visibleReferees = sourceReferees
        .where((referee) =>
            query.isEmpty || referee.name.toLowerCase().contains(query))
        .toList();
    final pending = sourceMatches
        .where((match) => !_assignedMatchIds.contains(match.id))
        .toList();

    return MediaQuery.withNoTextScaling(
      child: Scaffold(
        backgroundColor: const Color(0xFF090C10),
        body: SafeArea(
          bottom: false,
          child: Column(
            children: [
              // Custom Header Bar
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
                child: Row(
                  children: [
                    const Text(
                      'Referee',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const Spacer(),
                    Container(
                      width: 36,
                      height: 36,
                      decoration: const BoxDecoration(
                        color: Color(0xFF161B22),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.light_mode_outlined,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView(
                  physics: const ClampingScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(20, 10, 20, 32),
                  children: [
                    // Search Bar
                    _buildSearchBar(),
                    const SizedBox(height: 24),
                    // Filter Chips Row
                    Row(
                      children: [
                        Expanded(child: _buildFilterChip('By Match', 0)),
                        const SizedBox(width: 10),
                        Expanded(child: _buildFilterChip('By Date', 1)),
                        const SizedBox(width: 10),
                        Expanded(child: _buildFilterChip('By Venue', 2)),
                      ],
                    ),
                    const SizedBox(height: 28),
                    // Section: Needs Your Attention
                    Row(
                      children: [
                        const Expanded(
                          child: Text(
                            'Needs Your Attention',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        if (isLoading)
                          const SportoShimmer(
                            width: 70,
                            height: 22,
                            borderRadius: 100,
                          )
                        else
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFF231715),
                              borderRadius: BorderRadius.circular(100),
                              border: Border.all(color: const Color(0xFF3D221D)),
                            ),
                            child: Text(
                              '${pending.length} Pending',
                              style: const TextStyle(
                                color: Color(0xFFFF7545),
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    if (isLoading) ...[
                      _buildPendingMatchShimmer(),
                      const SizedBox(height: 14),
                      _buildPendingMatchShimmer(),
                    ] else if (pending.isEmpty)
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFF13171E),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: const Color(0xFF1F242C)),
                        ),
                        child: const Row(
                          children: [
                            Icon(
                              Icons.check_circle_rounded,
                              color: Color(0xFF20C783),
                              size: 20,
                            ),
                            SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                'All matches have referees assigned.',
                                style: TextStyle(
                                  color: Color(0xFF8E95A2),
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ],
                        ),
                      )
                    else
                      for (var i = 0; i < pending.length; i++) ...[
                        _buildPendingMatchCard(pending[i]),
                        if (i != pending.length - 1) const SizedBox(height: 14),
                      ],
                    const SizedBox(height: 28),
                    // Section: Referee Roster
                    const Text(
                      'Referee Roster',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 14),
                    if (isLoading) ...[
                      _buildRefereeCardShimmer(),
                      const SizedBox(height: 12),
                      _buildRefereeCardShimmer(),
                      const SizedBox(height: 12),
                      _buildRefereeCardShimmer(),
                    ] else if (visibleReferees.isEmpty)
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFF13171E),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: const Color(0xFF1F242C)),
                        ),
                        child: const Center(
                          child: Text(
                            'No referees found.',
                            style: TextStyle(
                              color: Color(0xFF8E95A2),
                              fontSize: 12,
                            ),
                          ),
                        ),
                      )
                    else
                      for (var i = 0; i < visibleReferees.length; i++) ...[
                        _buildRefereeCard(visibleReferees[i]),
                        if (i != visibleReferees.length - 1)
                          const SizedBox(height: 12),
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

  Widget _buildPendingMatchShimmer() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF13171E),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF1F242C)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 7,
                height: 7,
                decoration: const BoxDecoration(
                  color: Color(0xFF2C313A),
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              const SportoShimmer(width: 100, height: 13, borderRadius: 4),
            ],
          ),
          const SizedBox(height: 12),
          const SportoShimmer(width: 180, height: 16, borderRadius: 4),
          const SizedBox(height: 10),
          const Row(
            children: [
              SportoShimmer(width: 90, height: 12, borderRadius: 4),
              SizedBox(width: 10),
              SportoShimmer(width: 100, height: 12, borderRadius: 4),
            ],
          ),
          const SizedBox(height: 8),
          const SportoShimmer(width: 80, height: 12, borderRadius: 4),
          const SizedBox(height: 12),
          const Row(
            children: [
              Expanded(child: SportoShimmer(height: 11, borderRadius: 4)),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 10),
                child: Text(
                  'Vs',
                  style: TextStyle(color: Color(0xFF2C313A), fontSize: 11),
                ),
              ),
              Expanded(child: SportoShimmer(height: 11, borderRadius: 4)),
            ],
          ),
          const SizedBox(height: 14),
          const Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              SportoShimmer(width: 115, height: 32, borderRadius: 10),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRefereeCardShimmer() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF13171E),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF1F242C)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Expanded(
                child: SportoShimmer(width: 130, height: 16, borderRadius: 4),
              ),
              SizedBox(width: 10),
              SportoShimmer(width: 80, height: 12, borderRadius: 4),
            ],
          ),
          const SizedBox(height: 10),
          const SportoShimmer(width: 150, height: 12, borderRadius: 4),
          const SizedBox(height: 6),
          const SportoShimmer(width: 110, height: 12, borderRadius: 4),
          const SizedBox(height: 12),
          Container(height: 1, color: const Color(0xFF1E232B)),
          const SizedBox(height: 12),
          const Row(
            children: [
              Expanded(
                child: SportoShimmer(width: 130, height: 11, borderRadius: 4),
              ),
              SportoShimmer(width: 55, height: 11, borderRadius: 4),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return SizedBox(
      height: 44,
      child: TextField(
        controller: _searchController,
        onChanged: (_) => setState(() {}),
        textAlignVertical: TextAlignVertical.center,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 14,
          fontWeight: FontWeight.w400,
        ),
        cursorColor: const Color(0xFF20C783),
        decoration: InputDecoration(
          isDense: true,
          filled: true,
          fillColor: const Color(0xFF101317),
          hintText: 'Search referee or tournament...',
          hintStyle: const TextStyle(
            color: Color(0xFF6B7280),
            fontSize: 14,
            fontWeight: FontWeight.w400,
          ),
          prefixIcon: const Padding(
            padding: EdgeInsets.only(left: 14, right: 10),
            child: SportoAssetIcon(
              SportoAssets.searchNormal,
              size: 20,
              color: Color(0xFF6B7280),
            ),
          ),
          prefixIconConstraints: const BoxConstraints(
            minWidth: 44,
            minHeight: 44,
          ),
          suffixIcon: Padding(
            padding: const EdgeInsets.only(right: 14),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 1,
                  height: 20,
                  color: const Color(0xFF2C313A),
                ),
                const SizedBox(width: 12),
                const Icon(
                  Icons.sort_rounded,
                  color: Color(0xFF6B7280),
                  size: 20,
                ),
              ],
            ),
          ),
          suffixIconConstraints: const BoxConstraints(
            minWidth: 48,
            minHeight: 44,
          ),
          contentPadding: EdgeInsets.zero,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(100),
            borderSide: const BorderSide(color: Color(0xFF1B1E24)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(100),
            borderSide: const BorderSide(color: Color(0xFF1B1E24)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(100),
            borderSide: const BorderSide(color: Color(0xFF20C783), width: 1.2),
          ),
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label, int index) {
    final active = _filter == index;
    return GestureDetector(
      onTap: () => setState(() => _filter = index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        height: 36,
        decoration: BoxDecoration(
          color: active ? const Color(0xFF20C783) : const Color(0xFF16191E),
          borderRadius: BorderRadius.circular(100),
          border: Border.all(
            color: active ? const Color(0xFF20C783) : const Color(0xFF2C313A),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.sports_cricket_rounded,
              size: 14,
              color: active ? Colors.black : Colors.white,
            ),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                label,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: active ? Colors.black : Colors.white,
                  fontSize: 12,
                  fontWeight: active ? FontWeight.w600 : FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPendingMatchCard(RefereeScheduleMatch match) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF13171E),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF1F242C)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 7,
                height: 7,
                decoration: BoxDecoration(
                  color: const Color(0xFFFF334A),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFFF334A).withValues(alpha: 0.6),
                      blurRadius: 6,
                      spreadRadius: 1,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              const Text(
                'Referee Needed',
                style: TextStyle(
                  color: Color(0xFFFF5265),
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          if (match.badge != null) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: const Color(0xFF112E23),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                match.badge!,
                style: const TextStyle(
                  color: Color(0xFF20C783),
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
          const SizedBox(height: 8),
          Text(
            match.tournamentName,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(
                Icons.sports_cricket_rounded,
                size: 14,
                color: Color(0xFF8E95A2),
              ),
              const SizedBox(width: 5),
              Expanded(
                child: Text(
                  match.round,
                  style: const TextStyle(
                    color: Color(0xFF8E95A2),
                    fontSize: 12,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                match.date,
                style: const TextStyle(
                  color: Color(0xFF8E95A2),
                  fontSize: 11,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              const SportoAssetIcon(
                SportoAssets.locationPin,
                size: 13,
                color: Color(0xFF20C783),
              ),
              const SizedBox(width: 4),
              Text(
                match.ground,
                style: const TextStyle(
                  color: Color(0xFF20C783),
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Text(
                  match.teamA,
                  style: const TextStyle(
                    color: Color(0xFF8E95A2),
                    fontSize: 11,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 8),
                child: Text(
                  'Vs',
                  style: TextStyle(
                    color: Color(0xFF6B7280),
                    fontSize: 11,
                  ),
                ),
              ),
              Expanded(
                child: Text(
                  match.teamB,
                  textAlign: TextAlign.end,
                  style: const TextStyle(
                    color: Color(0xFF8E95A2),
                    fontSize: 11,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              GestureDetector(
                onTap: () => _assign(match),
                child: Container(
                  height: 32,
                  padding: const EdgeInsets.symmetric(horizontal: 18),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFB817),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Text(
                    'Assign Referee',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRefereeCard(ManagedReferee referee) {
    final status = referee.status.toLowerCase();
    final available = status == 'available now' || status == 'active';
    final statusColor =
        available ? const Color(0xFF20C783) : const Color(0xFFFF7545);

    return GestureDetector(
      onTap: () => _openDetails(referee),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF13171E),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFF1F242C)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    referee.name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Container(
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: statusColor,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: statusColor.withValues(alpha: 0.6),
                        blurRadius: 6,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  referee.status,
                  style: TextStyle(
                    color: statusColor,
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                const Icon(
                  Icons.sports_cricket_rounded,
                  size: 13,
                  color: Color(0xFF8E95A2),
                ),
                const SizedBox(width: 5),
                Expanded(
                  child: Text(
                    'Cricket  •  Level: ${referee.level} referee',
                    style: const TextStyle(
                      color: Color(0xFF8E95A2),
                      fontSize: 12,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(
                  Icons.star_rounded,
                  size: 14,
                  color: Color(0xFFFEC03F),
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    '${referee.rating}  •  ${referee.matches} matches',
                    style: const TextStyle(
                      color: Color(0xFF8E95A2),
                      fontSize: 11,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(height: 1, color: const Color(0xFF1E232B)),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Assigned to ${referee.assignedMatches} matches',
                    style: const TextStyle(
                      color: Color(0xFF8E95A2),
                      fontSize: 11,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const Spacer(),
                GestureDetector(
                  onTap: () => _openDetails(referee),
                  child: const Row(
                    children: [
                      Text(
                        'View All',
                        style: TextStyle(
                          color: Color(0xFF4EA1CA),
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      SizedBox(width: 4),
                      Icon(
                        Icons.chevron_right_rounded,
                        size: 16,
                        color: Color(0xFF4EA1CA),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (referee.conflict != null) ...[
              const SizedBox(height: 6),
              Text(
                referee.conflict!,
                style: const TextStyle(
                  color: Color(0xFFFF7545),
                  fontSize: 10,
                  height: 1.2,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class RefereeScheduleMatch {
  const RefereeScheduleMatch({
    required this.id,
    required this.tournamentName,
    required this.tournamentCode,
    required this.round,
    required this.date,
    this.badge,
    required this.ground,
    required this.teamA,
    required this.teamB,
    this.tournamentId,
    this.matchId,
    this.rawMatch,
  });

  final String id;
  final String tournamentName;
  final String tournamentCode;
  final String round;
  final String date;
  final String? badge;
  final String ground;
  final String teamA;
  final String teamB;
  final int? tournamentId;
  final int? matchId;
  final PartnerTournamentMatchResponse? rawMatch;

  factory RefereeScheduleMatch.fromApi(
    PartnerTournamentMatchResponse match,
    PartnerTournamentResponse tournament,
  ) {
    final rawDate = match.displayTime;
    final formattedDate = _formatApiDate(rawDate);
    final displayDate = formattedDate.isNotEmpty
        ? formattedDate
        : (match.isNeedsReview ? 'Schedule Pending' : '');
    final badgeName = match.stage?.name ??
        (match.stageName.isNotEmpty ? match.stageName : null) ??
        match.group?.name;

    return RefereeScheduleMatch(
      id: match.id.toString(),
      tournamentName: tournament.name,
      tournamentCode: tournament.code ?? 'SPT-${tournament.id}',
      round: match.displayRound,
      date: displayDate,
      badge: badgeName,
      ground: match.displayVenue,
      teamA: match.displayTeamA,
      teamB: match.displayTeamB,
      tournamentId: tournament.id,
      matchId: match.id,
      rawMatch: match,
    );
  }
}

String _formatApiDate(String value) {
  if (value.trim().isEmpty) return '';
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
