Map<String, dynamic> _object(Object? value) =>
    value is Map ? Map<String, dynamic>.from(value) : {};
int? _number(Object? value) => int.tryParse('$value');
List<T> workflowList<T>(Object? value, T Function(Map<String, dynamic>) parse) {
  if (value is Map)
    value = value['items'] ??
        value['data'] ??
        value['rounds'] ??
        value['allocations'] ??
        value['matches'];
  return value is List
      ? value
          .whereType<Map>()
          .map((e) => parse(Map<String, dynamic>.from(e)))
          .toList()
      : [];
}

class TournamentRegistrationPlayer {
  TournamentRegistrationPlayer.fromJson(Map<String, dynamic> json)
      : userId = _number(json['user_id'] ?? _object(json['user'])['id']),
        name = '${json['name'] ?? _object(json['user'])['name'] ?? 'Player'}';
  final int? userId;
  final String name;
}

class TournamentRegistration {
  TournamentRegistration.fromJson(Map<String, dynamic> json)
      : id = _number(json['id'])!,
        name =
            '${json['name'] ?? _object(json['team'])['name'] ?? 'Registration ${json['id']}'}',
        status = '${json['status'] ?? ''}',
        players = workflowList(json['registration_players'] ?? json['players'],
            TournamentRegistrationPlayer.fromJson);
  final int id;
  final String name, status;
  final List<TournamentRegistrationPlayer> players;
}

class TournamentRound {
  TournamentRound.fromJson(Map<String, dynamic> json)
      : id = _number(json['id'])!,
        name = '${json['name'] ?? ''}',
        sequence = _number(json['sequence']) ?? 0,
        matchCount = _number(json['match_count']) ?? 0,
        expectedMatchCount = _number(json['expected_match_count']) ?? 0,
        venueSummary = TournamentRoundVenueSummary.fromJson(
            _object(json['venue_summary']));
  final int id, sequence, matchCount;
  final String name;
  final int expectedMatchCount;
  final TournamentRoundVenueSummary venueSummary;
  int get requiredCapacity => venueSummary.requiredMatches > 0
      ? venueSummary.requiredMatches
      : expectedMatchCount > 0 ? expectedMatchCount : matchCount;
  int remainingCapacity({int editingCapacity = 0}) => requiredCapacity <= 0
      ? 0
      : (requiredCapacity - venueSummary.capacity + editingCapacity).clamp(0, requiredCapacity);
  bool get capacityComplete => requiredCapacity > 0 && remainingCapacity() == 0;
}

class TournamentRoundVenueSummary {
  TournamentRoundVenueSummary.fromJson(Map<String, dynamic> json)
      : configuredVenues = _number(json['configured_venues']) ?? 0,
        capacity = _number(json['configured_capacity']) ?? 0,
        requiredMatches = _number(json['required_matches']) ?? 0,
        shortfall = _number(json['capacity_shortfall']) ??
            _number(json['remaining_capacity']) ??
            0,
        sufficient = json['is_capacity_sufficient'] == true;
  final int configuredVenues, capacity, requiredMatches, shortfall;
  final bool sufficient;
}

class TournamentRoundAllocation {
  TournamentRoundAllocation.fromJson(Map<String, dynamic> json)
      : id = _number(json['id'] ?? json['allocation_id'])!,
        venueId = _number(json['tournament_venue_id'])!,
        date = '${json['date'] ?? ''}',
        startTime = '${json['start_time'] ?? ''}',
        endTime = json['end_time']?.toString(),
        capacity = _number(json['daily_match_capacity']) ?? 0,
        isPrimary = json['is_primary_for_round'] == true ||
            json['is_primary_for_round'] == 1;
  final int id, venueId, capacity;
  final String date, startTime;
  final String? endTime;
  final bool isPrimary;
}

class TournamentAllocationRequest {
  const TournamentAllocationRequest(
      {required this.venueId,
      required this.date,
      required this.startTime,
      required this.capacity,
      this.isPrimary});
  final int venueId, capacity;
  final String date, startTime;
  final bool? isPrimary;
  Map<String, dynamic> toJson() => {
        'tournament_venue_id': venueId,
        'date': date,
        'start_time': startTime,
        'daily_match_capacity': capacity,
        if (isPrimary != null) 'is_primary_for_round': isPrimary,
      };
}

class TournamentScheduledMatch {
  TournamentScheduledMatch.fromJson(Map<String, dynamic> json)
      : id = _number(json['id'] ?? json['match_id']),
        name =
            '${json['name'] ?? 'Match ${json['match_number'] ?? json['id']}'}',
        startAt = json['scheduled_start_at']?.toString(),
        endAt = json['scheduled_end_at']?.toString();
  final int? id;
  final String name;
  final String? startAt, endAt;
}

class TournamentSchedule {
  TournamentSchedule.fromJson(Map<String, dynamic> json)
      : versionId = _number(
            json['version_id'] ?? _object(json['schedule'])['version_id']),
        status =
            '${json['status'] ?? _object(json['schedule'])['status'] ?? ''}',
        matches = workflowList(
            json['matches'] ?? _object(json['schedule'])['matches'],
            TournamentScheduledMatch.fromJson);
  final int? versionId;
  final String status;
  final List<TournamentScheduledMatch> matches;
}
