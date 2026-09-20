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
    this.remoteDataSource,
    this.loadRemote = true,
    this.initialReferees,
  });

  final String tournamentName;
  final String tournamentCode;
  final Object? tournamentId;
  final Object? matchId;
  final PartnerTournamentMatchResponse? match;
  final PartnerRemoteDataSource? remoteDataSource;
  final bool loadRemote;
  final List<PartnerEligibleRefereeResponse>? initialReferees;

  @override
  State<AssignRefereeScreen> createState() => _AssignRefereeScreenState();
}

class _AssignRefereeScreenState extends State<AssignRefereeScreen> {
  final _searchController = TextEditingController();
  int _sortIndex = 0; // 0 = Matches, 1 = Rating
  late final PartnerRemoteDataSource _remoteDataSource =
      widget.remoteDataSource ??
          PartnerRemoteDataSource(
            apiClient:
                SportoApiClient(tokenProvider: AuthSessionStore().getToken),
          );
  PartnerTournamentMatchResponse? _match;
  List<PartnerEligibleRefereeResponse>? _apiReferees;
  bool _isLoading = false;
  bool _isLoadingMatch = false;
  int? _assigningRefereeId;

  @override
  void initState() {
    super.initState();
    _match = widget.match;
    if (widget.initialReferees != null) {
      _apiReferees = List.of(widget.initialReferees!);
    }
    if (widget.loadRemote) {
      if (_match == null &&
          widget.tournamentId != null &&
          widget.matchId != null) {
        _loadMatchDetails();
      }
      _loadEligibleReferees();
    }
  }

  Future<void> _loadMatchDetails() async {
    setState(() => _isLoadingMatch = true);
    try {
      final match = await _remoteDataSource.showTournamentMatchData(
        widget.tournamentId!,
        widget.matchId!,
      );
      if (!mounted) return;
      setState(() {
        _match = match;
        _isLoadingMatch = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _isLoadingMatch = false);
    }
  }

  Future<void> _loadEligibleReferees() async {
    setState(() {
      _isLoading = true;
    });
    try {
      List<PartnerEligibleRefereeResponse> list = [];
      if (widget.tournamentId != null) {
        try {
          list = await _remoteDataSource
              .getEligibleRefereesData(widget.tournamentId!);
        } catch (_) {}
      }
      if (list.isEmpty) {
        final referees = await _remoteDataSource.listPartnerRefereesData();
        list = referees
            .map(
              (r) => PartnerEligibleRefereeResponse(
                id: r.id,
                name: r.name,
                status: r.displayStatus,
                available: r.isActive,
                mobileNumber: r.mobileNumber,
                sportName: r.displaySport,
                level: r.level,
                rating: r.rating,
                matches: r.matches,
                assignedMatches: r.assignedMatches,
                conflict: r.conflict,
              ),
            )
            .toList();
      }
      if (!mounted) return;
      setState(() {
        _apiReferees = list;
        _isLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _apiReferees ??= [];
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _onAssign(String refereeName, [int? refereeId]) async {
    if (_assigningRefereeId != null) return;
    if (refereeId != null) setState(() => _assigningRefereeId = refereeId);
    if (widget.tournamentId != null &&
        widget.matchId != null &&
        refereeId != null) {
      try {
        await _remoteDataSource.assignMatchRefereeData(
          widget.tournamentId!,
          widget.matchId!,
          PartnerMatchRefereeAssignmentRequest(refereeId: refereeId),
        );
      } catch (error) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Unable to assign referee: $error')),
        );
        if (mounted) setState(() => _assigningRefereeId = null);
        return;
      }
    }
    if (!mounted) return;
    setState(() => _assigningRefereeId = null);
    Navigator.pop(context, refereeName);
  }

  @override
  Widget build(BuildContext context) {
    final query = _searchController.text.trim().toLowerCase();
    final isLoadingReferees = _isLoading && _apiReferees == null;
    final sourceReferees =
        _apiReferees ?? const <PartnerEligibleRefereeResponse>[];

    var items = sourceReferees.map((api) {
      final available = api.available != false &&
          !api.displayStatus.toLowerCase().contains('busy');
      return _AssignRefereeItem(
        id: api.id,
        name: api.displayName,
        level: api.level ?? 3,
        rating: api.rating ?? 4.8,
        matches: api.matches ?? 0,
        assignedMatches: api.assignedMatches ?? 0,
        status: available ? 'Available Now' : 'Busy',
        conflict: api.conflict,
      );
    }).toList();

    if (query.isNotEmpty) {
      items = items.where((r) => r.name.toLowerCase().contains(query)).toList();
    }

    if (_sortIndex == 0) {
      items.sort((a, b) => b.matches.compareTo(a.matches));
    } else {
      items.sort((a, b) => b.rating.compareTo(a.rating));
    }

    return MediaQuery.withNoTextScaling(
      child: Scaffold(
        backgroundColor: const Color(0xFF090C10),
        appBar: AppBar(
          backgroundColor: const Color(0xFF090C10),
          elevation: 0,
          scrolledUnderElevation: 0,
          leading: Center(
            child: GestureDetector(
              onTap: () => Navigator.maybePop(context),
              child: Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: const Color(0xFF161B22),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFF222832)),
                ),
                alignment: Alignment.center,
                child: const Icon(
                  Icons.arrow_back_ios_new_rounded,
                  color: Colors.white,
                  size: 16,
                ),
              ),
            ),
          ),
          title: const Text(
            'Assign Referee',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        body: SafeArea(
          top: false,
          child: ListView(
            physics: const ClampingScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(20, 10, 20, 32),
            children: [
              _buildMatchSummaryCard(),
              const SizedBox(height: 24),
              _buildSearchBar(),
              const SizedBox(height: 20),
              _buildSortRow(),
              const SizedBox(height: 24),
              const Text(
                'Select a referee',
                style: TextStyle(
                  color: Color(0xFF4FA1CA),
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 12),
              if (isLoadingReferees) ...[
                _buildRefereeCardShimmer(),
                const SizedBox(height: 12),
                _buildRefereeCardShimmer(),
                const SizedBox(height: 12),
                _buildRefereeCardShimmer(),
              ] else if (items.isEmpty)
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: const Color(0xFF13171E),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFF1F242C)),
                  ),
                  child: const Center(
                    child: Text(
                      'No eligible referees found.',
                      style: TextStyle(color: Color(0xFF8E95A2), fontSize: 13),
                    ),
                  ),
                )
              else
                for (var i = 0; i < items.length; i++) ...[
                  _buildRefereeCard(items[i]),
                  if (i != items.length - 1) const SizedBox(height: 12),
                ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMatchSummaryShimmer() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF13171E),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF182824)),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SportoShimmer(width: 80, height: 11, borderRadius: 4),
          SizedBox(height: 8),
          SportoShimmer(width: 170, height: 16, borderRadius: 4),
          SizedBox(height: 10),
          Row(
            children: [
              SportoShimmer(width: 90, height: 12, borderRadius: 4),
              SizedBox(width: 12),
              SportoShimmer(width: 100, height: 12, borderRadius: 4),
            ],
          ),
          SizedBox(height: 8),
          SportoShimmer(width: 75, height: 12, borderRadius: 4),
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
      child: const Row(
        children: [
          SportoShimmer(width: 44, height: 44, borderRadius: 22),
          SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SportoShimmer(width: 120, height: 15, borderRadius: 4),
                SizedBox(height: 6),
                SportoShimmer(width: 85, height: 12, borderRadius: 4),
                SizedBox(height: 6),
                SportoShimmer(width: 140, height: 11, borderRadius: 4),
              ],
            ),
          ),
          SizedBox(width: 12),
          SportoShimmer(width: 68, height: 32, borderRadius: 10),
        ],
      ),
    );
  }

  Widget _buildMatchSummaryCard() {
    if (_isLoadingMatch && _match == null) {
      return _buildMatchSummaryShimmer();
    }
    final match = _match;
    final rawDate = match?.displayTime;
    final formattedDate = _formatApiDate(rawDate);
    final displayDate = formattedDate != null && formattedDate.isNotEmpty
        ? formattedDate
        : (match?.isNeedsReview == true
            ? 'Schedule Pending'
            : (formattedDate ?? ''));
    final displayRound = match?.displayRound ?? '';
    final displayVenue = match?.displayVenue ?? '';
    final statusText = match?.isLive == true
        ? 'Live Matches'
        : (match?.isNeedsReview == true
            ? 'Referee Needed'
            : (match?.displayStatus.isNotEmpty == true
                ? (match!.displayStatus.substring(0, 1).toUpperCase() +
                    match.displayStatus.substring(1))
                : 'Live Matches'));

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF13171E),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF182824)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.tournamentCode,
            style: const TextStyle(
              color: Color(0xFF8E95A2),
              fontSize: 11,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            widget.tournamentName,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
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
              const SizedBox(width: 6),
              Text(
                statusText,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          if (displayRound.isNotEmpty || displayDate.isNotEmpty) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                if (displayRound.isNotEmpty) ...[
                  const Icon(
                    Icons.sports_cricket_rounded,
                    size: 14,
                    color: Color(0xFF8E95A2),
                  ),
                  const SizedBox(width: 5),
                  Expanded(
                    child: Text(
                      displayRound,
                      style: const TextStyle(
                        color: Color(0xFF8E95A2),
                        fontSize: 12,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
                if (displayDate.isNotEmpty) ...[
                  const SizedBox(width: 8),
                  Text(
                    displayDate,
                    style: const TextStyle(
                      color: Color(0xFF8E95A2),
                      fontSize: 11,
                    ),
                  ),
                ],
              ],
            ),
          ],
          if (displayVenue.isNotEmpty) ...[
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
                  displayVenue,
                  style: const TextStyle(
                    color: Color(0xFF20C783),
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
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
          hintText: 'Search referees...',
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
          contentPadding: const EdgeInsets.symmetric(horizontal: 14),
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

  Widget _buildSortRow() {
    return Row(
      children: [
        const Text(
          'Sort by  |',
          style: TextStyle(
            color: Color(0xFF6B7280),
            fontSize: 13,
          ),
        ),
        const SizedBox(width: 14),
        GestureDetector(
          onTap: () => setState(() => _sortIndex = 0),
          child: Text(
            'Matches',
            style: TextStyle(
              color: _sortIndex == 0 ? Colors.white : const Color(0xFF6B7280),
              fontSize: 13,
              fontWeight: _sortIndex == 0 ? FontWeight.w600 : FontWeight.w400,
            ),
          ),
        ),
        const SizedBox(width: 18),
        GestureDetector(
          onTap: () => setState(() => _sortIndex = 1),
          child: Text(
            'Rating',
            style: TextStyle(
              color: _sortIndex == 1 ? Colors.white : const Color(0xFF6B7280),
              fontSize: 13,
              fontWeight: _sortIndex == 1 ? FontWeight.w600 : FontWeight.w400,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRefereeCard(_AssignRefereeItem ref) {
    final isAvailable = ref.status.toLowerCase().contains('available');
    final statusColor =
        isAvailable ? const Color(0xFF20C783) : const Color(0xFFFF7545);

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
              Expanded(
                child: Text(
                  ref.name,
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
                ref.status,
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
                  'Cricket  •  Level: ${ref.level} referee',
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
                  '${ref.rating}  •  ${ref.matches} matches',
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
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Assigned to ${ref.assignedMatches} matches',
                      style: const TextStyle(
                        color: Color(0xFF8E95A2),
                        fontSize: 11,
                      ),
                    ),
                    if (ref.conflict != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        ref.conflict!,
                        style: const TextStyle(
                          color: Color(0xFFFF7545),
                          fontSize: 9,
                          height: 1.2,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              if (isAvailable) ...[
                const SizedBox(width: 10),
                GestureDetector(
                  onTap: _assigningRefereeId == ref.id
                      ? null
                      : () => _onAssign(ref.name, ref.id),
                  child: Container(
                    height: 30,
                    padding: const EdgeInsets.symmetric(horizontal: 26),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: const Color(0xFFFEC144),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: _assigningRefereeId == ref.id
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.black,
                            ),
                          )
                        : const Text(
                            'Assign',
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

class _AssignRefereeItem {
  const _AssignRefereeItem({
    this.id,
    required this.name,
    required this.level,
    required this.rating,
    required this.matches,
    required this.assignedMatches,
    required this.status,
    this.conflict,
  });

  final int? id;
  final String name;
  final int level;
  final double rating;
  final int matches;
  final int assignedMatches;
  final String status;
  final String? conflict;
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
