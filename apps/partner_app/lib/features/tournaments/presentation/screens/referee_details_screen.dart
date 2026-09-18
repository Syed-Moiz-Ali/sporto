import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:partner_data/partner_data.dart';
import 'package:ui_kit/ui_kit.dart';

import 'assign_referee_screen.dart';

class RefereeDetailsScreen extends StatefulWidget {
  const RefereeDetailsScreen({
    super.key,
    required this.referee,
    this.onAssignmentChanged,
    this.remoteDataSource,
    this.loadRemote = true,
    this.initialMatches,
    this.tournamentId,
  });

  final ManagedReferee referee;
  final VoidCallback? onAssignmentChanged;
  final PartnerRemoteDataSource? remoteDataSource;
  final bool loadRemote;
  final List<RefereeAllottedMatch>? initialMatches;
  final Object? tournamentId;

  @override
  State<RefereeDetailsScreen> createState() => _RefereeDetailsScreenState();
}

class _RefereeDetailsScreenState extends State<RefereeDetailsScreen> {
  final Set<String> _removedMatchIds = {};
  late final PartnerRemoteDataSource _remoteDataSource =
      widget.remoteDataSource ??
          PartnerRemoteDataSource(
            apiClient:
                SportoApiClient(tokenProvider: AuthSessionStore().getToken),
          );

  List<RefereeAllottedMatch>? _matches;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.initialMatches != null) {
      _matches = List.of(widget.initialMatches!);
    } else if (widget.loadRemote) {
      _loadAllottedMatches();
    }
  }

  Future<void> _loadAllottedMatches() async {
    setState(() => _isLoading = true);
    try {
      final allotted = <RefereeAllottedMatch>[];
      final tournaments = widget.tournamentId != null
          ? [await _remoteDataSource.showTournamentData(widget.tournamentId!)]
          : await _remoteDataSource.listTournamentsData();

      for (final tournament in tournaments) {
        final matches =
            await _remoteDataSource.listTournamentMatchesData(tournament.id);
        for (final match in matches) {
          if (widget.referee.id != null) {
            try {
              final assignments = await _remoteDataSource
                  .listMatchRefereeAssignmentsData(tournament.id, match.id);
              final assignment = assignments
                  .where((a) => a.refereeId == widget.referee.id)
                  .firstOrNull;
              if (assignment != null) {
                allotted.add(
                  RefereeAllottedMatch.fromApi(
                    match,
                    tournament,
                    assignmentId: assignment.id,
                  ),
                );
              }
            } catch (_) {}
          }
        }
      }

      if (!mounted) return;
      setState(() {
        _matches = allotted;
        _isLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _matches ??= [];
        _isLoading = false;
      });
    }
  }

  Future<void> _reassign(RefereeAllottedMatch match) async {
    final selected = await Navigator.of(context).push<String>(
      MaterialPageRoute(
        builder: (_) => AssignRefereeScreen(
          tournamentName: match.tournamentName,
          tournamentCode: 'SPT-${match.tournamentId ?? 20481}',
          tournamentId: match.tournamentId,
          matchId: match.matchId,
        ),
      ),
    );
    if (selected == null || !mounted) return;
    setState(() => _removedMatchIds.add(match.id));
    widget.onAssignmentChanged?.call();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Match reassigned to $selected.')),
    );
  }

  Future<void> _remove(RefereeAllottedMatch match) async {
    if (match.tournamentId != null &&
        match.matchId != null &&
        match.assignmentId != null) {
      try {
        await _remoteDataSource.removeMatchRefereeAssignment(
          match.tournamentId!,
          match.matchId!,
          match.assignmentId!,
        );
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to remove assignment: $e')),
        );
        return;
      }
    }
    setState(() => _removedMatchIds.add(match.id));
    widget.onAssignmentChanged?.call();
  }

  @override
  Widget build(BuildContext context) {
    final activeMatches = (_matches ?? const <RefereeAllottedMatch>[])
        .where((m) => !_removedMatchIds.contains(m.id))
        .toList();
    final isLoading = _isLoading && _matches == null;

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
            'Referee Details',
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
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
            children: [
              _buildRefereeProfileCard(),
              const SizedBox(height: 22),
              const Text(
                'All Allotted Matches',
                style: TextStyle(
                  color: Color(0xFF4FA9D7),
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 16),
              if (isLoading) ...[
                _buildDateGroupShimmer(),
                const SizedBox(height: 18),
                _buildDateGroupShimmer(),
              ] else if (activeMatches.isEmpty)
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: const Color(0xFF13171E),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFF1F242C)),
                  ),
                  child: const Center(
                    child: Text(
                      'No allotted matches found for this referee.',
                      style: TextStyle(color: Color(0xFF8E95A2), fontSize: 13),
                    ),
                  ),
                )
              else
                for (var i = 0; i < activeMatches.length; i++) ...[
                  _buildDateGroup(activeMatches[i]),
                  if (i != activeMatches.length - 1)
                    const SizedBox(height: 18),
                ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRefereeProfileCard() {
    final ref = widget.referee;
    final isAvailable = ref.status.toLowerCase().contains('available') ||
        ref.status.toLowerCase().contains('active');
    final statusColor =
        isAvailable ? const Color(0xFF20C783) : const Color(0xFFFF7545);

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
          Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(21),
                child: Image.asset(
                  'assets/images/referee_avatar.png',
                  width: 42,
                  height: 42,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => CircleAvatar(
                    radius: 21,
                    backgroundColor: const Color(0xFF1C2026),
                    child: Text(
                      _initials(ref.name),
                      style: const TextStyle(
                        color: Color(0xFFCF9E24),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      ref.name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      ref.phone.isNotEmpty
                          ? ref.phone
                          : 'No contact number',
                      style: const TextStyle(
                        color: Color(0xFF8E95A2),
                        fontSize: 12,
                      ),
                    ),
                  ],
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
          const SizedBox(height: 12),
          Container(height: 1, color: const Color(0xFF1E232B)),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(
                Icons.sports_cricket_rounded,
                size: 13,
                color: Color(0xFF8E95A2),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  '${ref.sport ?? 'Cricket'}  •  Level: ${ref.level} referee',
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
          Text(
            'Assigned to ${ref.assignedMatches} matches',
            style: const TextStyle(
              color: Color(0xFF8E95A2),
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateGroupShimmer() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SportoShimmer(width: 130, height: 14, borderRadius: 4),
        const SizedBox(height: 10),
        Container(
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
                  const SizedBox(width: 6),
                  const SportoShimmer(width: 80, height: 12, borderRadius: 4),
                ],
              ),
              const SizedBox(height: 10),
              const SportoShimmer(width: 170, height: 16, borderRadius: 4),
              const SizedBox(height: 10),
              const Row(
                children: [
                  SportoShimmer(width: 90, height: 12, borderRadius: 4),
                  SizedBox(width: 12),
                  SportoShimmer(width: 100, height: 12, borderRadius: 4),
                ],
              ),
              const SizedBox(height: 8),
              const SportoShimmer(width: 80, height: 12, borderRadius: 4),
              const SizedBox(height: 12),
              const Row(
                children: [
                  Expanded(child: SportoShimmer(height: 12, borderRadius: 4)),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 10),
                    child: Text(
                      'Vs',
                      style: TextStyle(color: Color(0xFF2C313A), fontSize: 11),
                    ),
                  ),
                  Expanded(child: SportoShimmer(height: 12, borderRadius: 4)),
                ],
              ),
              const SizedBox(height: 14),
              const Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  SportoShimmer(width: 80, height: 30, borderRadius: 10),
                  SizedBox(width: 10),
                  SportoShimmer(width: 110, height: 30, borderRadius: 10),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDateGroup(RefereeAllottedMatch match) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: TextSpan(
            children: [
              TextSpan(
                text: match.dateHeader,
                style: const TextStyle(
                  color: Color(0xFFE1AF45),
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'packages/ui_kit/Quicksand',
                ),
              ),
              TextSpan(
                text: '  •  ${match.matchCount}',
                style: const TextStyle(
                  color: Color(0xFF8E95A2),
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                  fontFamily: 'packages/ui_kit/Quicksand',
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        Container(
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
                  if (match.badge != null && match.badge!.isNotEmpty) ...[
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
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
                    const SizedBox(width: 8),
                  ],
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
                    match.isLive ||
                            match.status == null ||
                            match.status!.isEmpty
                        ? 'Live Matches'
                        : (match.status![0].toUpperCase() +
                            match.status!.substring(1)),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                match.tournamentName,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 15,
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
                  if (match.date.isNotEmpty) ...[
                    const SizedBox(width: 8),
                    Text(
                      match.date,
                      style: const TextStyle(
                        color: Color(0xFF8E95A2),
                        fontSize: 11,
                      ),
                    ),
                  ],
                ],
              ),
              if (match.ground.isNotEmpty) ...[
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
              ],
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
                    onTap: () => _reassign(match),
                    child: Container(
                      height: 30,
                      padding: const EdgeInsets.symmetric(horizontal: 18),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: const Color(0xFF28251B),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: const Color(0xFF3D3823)),
                      ),
                      child: const Text(
                        'Reassign',
                        style: TextStyle(
                          color: Color(0xFFE1AF45),
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  GestureDetector(
                    onTap: () => _remove(match),
                    child: Container(
                      height: 30,
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: const Color(0xFF281618),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: const Color(0xFF3D1F23)),
                      ),
                      child: const Text(
                        'Remove Referee',
                        style: TextStyle(
                          color: Color(0xFFFF5265),
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
        ),
      ],
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

class RefereeAllottedMatch {
  const RefereeAllottedMatch({
    required this.id,
    required this.dateHeader,
    required this.matchCount,
    this.badge,
    required this.tournamentName,
    required this.round,
    required this.date,
    required this.ground,
    required this.teamA,
    required this.teamB,
    this.tournamentId,
    this.matchId,
    this.assignmentId,
    this.isLive = false,
    this.status,
  });

  final String id;
  final String dateHeader;
  final String matchCount;
  final String? badge;
  final String tournamentName;
  final String round;
  final String date;
  final String ground;
  final String teamA;
  final String teamB;
  final int? tournamentId;
  final int? matchId;
  final int? assignmentId;
  final bool isLive;
  final String? status;

  factory RefereeAllottedMatch.fromApi(
    PartnerTournamentMatchResponse match,
    PartnerTournamentResponse tournament, {
    int? assignmentId,
  }) {
    final parsedDate = DateTime.tryParse(match.displayTime);
    final dateHeader = parsedDate != null
        ? '${_monthName(parsedDate.month)} ${parsedDate.day}'
        : 'Scheduled';
    final badgeName = match.stage?.name ??
        (match.stageName.isNotEmpty ? match.stageName : null) ??
        match.group?.name;
    return RefereeAllottedMatch(
      id: match.id.toString(),
      dateHeader: dateHeader,
      matchCount: '1 match',
      badge: badgeName,
      tournamentName: tournament.name,
      round: match.displayRound,
      date: _formatApiDate(match.displayTime),
      ground: match.displayVenue,
      teamA: match.displayTeamA,
      teamB: match.displayTeamB,
      tournamentId: tournament.id,
      matchId: match.id,
      assignmentId: assignmentId,
      isLive: match.isLive,
      status: match.displayStatus,
    );
  }
}

class ManagedReferee {
  const ManagedReferee({
    this.id,
    required this.name,
    required this.phone,
    required this.level,
    required this.rating,
    required this.matches,
    required this.assignedMatches,
    required this.status,
    this.conflict,
    this.photoAsset,
    this.sport,
  });

  final int? id;
  final String name;
  final String phone;
  final int level;
  final double rating;
  final int matches;
  final int assignedMatches;
  final String status;
  final String? conflict;
  final String? photoAsset;
  final String? sport;
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
