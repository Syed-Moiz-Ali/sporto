class TournamentPlanningRequest {
  const TournamentPlanningRequest(
      {required this.name,
      required this.sportId,
      required this.formatId,
      required this.typeId,
      required this.minimumTeams,
      required this.maximumTeams,
      required this.registrationEnd,
      required this.startAt});
  final String name, registrationEnd, startAt;
  final int sportId, formatId, typeId, minimumTeams, maximumTeams;
  Map<String, dynamic> toJson() => {
        'name': name,
        'sport_id': sportId,
        'sport_format_id': formatId,
        'tournament_type_id': typeId,
        'minimum_teams': minimumTeams,
        'maximum_teams': maximumTeams,
        'registration_end_at': registrationEnd,
        'tournament_start_at': startAt,
        'timezone': 'Asia/Kolkata',
        'visibility': 1
      };
}

String allocationDate(String value) => value.split('T').first;
String allocationTime(String value) => value.contains('T')
    ? value.split('T')[1].substring(0, 5)
    : value.length >= 5
        ? value.substring(0, 5)
        : value;

class VenueRoundPlan {
  const VenueRoundPlan(
      {required this.roundId,
      required this.date,
      required this.startTime,
      required this.capacity,
      this.endTime,
      this.priority = 1,
      this.isPrimary = false});
  final int roundId, capacity, priority;
  final String date, startTime;
  final String? endTime;
  final bool isPrimary;
  factory VenueRoundPlan.fromJson(Map<String, dynamic> json) => VenueRoundPlan(
      roundId: (json['round_id'] ?? json['tournament_round_id']) as int,
      date: allocationDate(json['date'] as String),
      startTime: allocationTime(json['start_time'] as String),
      endTime: json['end_time'] == null
          ? null
          : allocationTime(json['end_time'] as String),
      capacity: int.parse('${json['daily_match_capacity']}'),
      priority: int.tryParse('${json['priority']}') ?? 1,
      isPrimary: json['is_primary_for_round'] == true ||
          json['is_primary_for_round'] == 1);
  Map<String, dynamic> toJson() => {
        'round_id': roundId,
        'date': date,
        'start_time': startTime,
        if (endTime != null && endTime!.isNotEmpty) 'end_time': endTime,
        'daily_match_capacity': capacity,
        'priority': priority,
        'is_primary_for_round': isPrimary
      };
}

class PlannedTournamentVenue {
  const PlannedTournamentVenue(
      {this.id,
      required this.name,
      required this.location,
      required this.groundType,
      required this.capacity,
      required this.isPrimary,
      required this.allocations});
  final int? id;
  final String name, location, groundType;
  final int capacity;
  final bool isPrimary;
  final List<VenueRoundPlan> allocations;
  factory PlannedTournamentVenue.fromJson(Map<String, dynamic> json) =>
      PlannedTournamentVenue(
          id: json['id'] as int?,
          name: json['venue_name'] as String,
          location: json['location'] as String? ?? '',
          groundType: json['ground_type'] as String? ?? '',
          capacity: int.parse('${json['daily_match_capacity']}'),
          isPrimary: json['is_primary'] == true || json['is_primary'] == 1,
          allocations: (json['round_allocations'] as List? ?? [])
              .map((e) =>
                  VenueRoundPlan.fromJson(Map<String, dynamic>.from(e as Map)))
              .toList());
  Map<String, dynamic> toJson() => {
        'venue_name': name,
        'location': location,
        'ground_type': groundType,
        'daily_match_capacity': capacity,
        'is_primary': isPrimary,
        'round_allocations': allocations.map((e) => e.toJson()).toList()
      };
}
