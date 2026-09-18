int _intValue(Object? value) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse(value?.toString() ?? '') ?? 0;
}

String? _stringValue(Object? value) => value?.toString();

Map<String, dynamic> _mapValue(Object? value) {
  return value is Map ? Map<String, dynamic>.from(value) : const {};
}

List<dynamic> _listValue(Object? value) => value is List ? value : const [];

class RefereePersonalRequest {
  const RefereePersonalRequest({
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.dateOfBirth,
    required this.gender,
  });

  final String firstName;
  final String lastName;
  final String email;
  final String dateOfBirth;
  final String gender;

  Map<String, dynamic> toJson() => {
        'first_name': firstName,
        'last_name': lastName,
        'email': email,
        'date_of_birth': dateOfBirth,
        'gender': gender,
      };
}

class RefereeAddressRequest {
  const RefereeAddressRequest({
    required this.addressLine1,
    this.addressLine2,
    required this.city,
    required this.state,
    required this.pincode,
    required this.country,
  });

  final String addressLine1;
  final String? addressLine2;
  final String city;
  final String state;
  final String pincode;
  final String country;

  Map<String, dynamic> toJson() => {
        'address_line_1': addressLine1,
        if (addressLine2 != null) 'address_line_2': addressLine2,
        'city': city,
        'state': state,
        'pincode': pincode,
        'country': country,
      };
}

class RefereeSportsRequest {
  const RefereeSportsRequest({
    required this.sportIds,
    required this.experienceYears,
    required this.highestQualification,
  });

  final List<int> sportIds;
  final int experienceYears;
  final String highestQualification;

  Map<String, dynamic> toJson() => {
        'sport_ids': sportIds,
        'experience_years': experienceYears,
        'highest_qualification': highestQualification,
      };
}

class RefereeAvailabilityRequest {
  const RefereeAvailabilityRequest({
    required this.availability,
    required this.preferredCity,
    required this.travelRadius,
    required this.emergencyContactName,
    required this.emergencyContactNumber,
  });

  final List<String> availability;
  final String preferredCity;
  final int travelRadius;
  final String emergencyContactName;
  final String emergencyContactNumber;

  Map<String, dynamic> toJson() => {
        'availability': availability,
        'preferred_city': preferredCity,
        'travel_radius': travelRadius,
        'emergency_contact_name': emergencyContactName,
        'emergency_contact_number': emergencyContactNumber,
      };
}

class RefereeDocumentRequest {
  const RefereeDocumentRequest({
    required this.type,
    required this.filePath,
  });

  final int type;
  final String filePath;

  Map<String, dynamic> toJson() => {'type': type, 'file_path': filePath};
}

class RefereePersonalInformation {
  const RefereePersonalInformation({
    this.firstName,
    this.lastName,
    this.email,
    this.mobileNumber,
    this.dateOfBirth,
    this.gender,
  });

  final String? firstName;
  final String? lastName;
  final String? email;
  final String? mobileNumber;
  final String? dateOfBirth;
  final String? gender;

  factory RefereePersonalInformation.fromJson(Map<String, dynamic> json) =>
      RefereePersonalInformation(
        firstName: _stringValue(json['first_name']),
        lastName: _stringValue(json['last_name']),
        email: _stringValue(json['email']),
        mobileNumber: _stringValue(json['mobile_number']),
        dateOfBirth: _stringValue(json['date_of_birth']),
        gender: _stringValue(json['gender']),
      );
}

class RefereeAddress {
  const RefereeAddress({
    this.addressLine1,
    this.addressLine2,
    this.city,
    this.state,
    this.pincode,
    this.country,
  });

  final String? addressLine1;
  final String? addressLine2;
  final String? city;
  final String? state;
  final String? pincode;
  final String? country;

  factory RefereeAddress.fromJson(Map<String, dynamic> json) => RefereeAddress(
        addressLine1: _stringValue(json['address_line_1']),
        addressLine2: _stringValue(json['address_line_2']),
        city: _stringValue(json['city']),
        state: _stringValue(json['state']),
        pincode: _stringValue(json['pincode']),
        country: _stringValue(json['country']),
      );
}

class RefereeSportsInformation {
  const RefereeSportsInformation({
    this.sportIds = const [],
    this.experienceYears = 0,
    this.highestQualification,
  });

  final List<int> sportIds;
  final int experienceYears;
  final String? highestQualification;

  factory RefereeSportsInformation.fromJson(Map<String, dynamic> json) =>
      RefereeSportsInformation(
        sportIds: _listValue(json['sport_ids']).map(_intValue).toList(),
        experienceYears: _intValue(json['experience_years']),
        highestQualification: _stringValue(json['highest_qualification']),
      );
}

class RefereeAvailability {
  const RefereeAvailability({
    this.days = const [],
    this.preferredCity,
    this.travelRadius = 0,
    this.emergencyContactName,
    this.emergencyContactNumber,
  });

  final List<String> days;
  final String? preferredCity;
  final int travelRadius;
  final String? emergencyContactName;
  final String? emergencyContactNumber;

  factory RefereeAvailability.fromJson(Map<String, dynamic> json) =>
      RefereeAvailability(
        days: _listValue(json['availability'])
            .map((value) => value.toString())
            .toList(),
        preferredCity: _stringValue(json['preferred_city']),
        travelRadius: _intValue(json['travel_radius']),
        emergencyContactName: _stringValue(json['emergency_contact_name']),
        emergencyContactNumber: _stringValue(json['emergency_contact_number']),
      );
}

class RefereeDocument {
  const RefereeDocument({
    required this.id,
    required this.type,
    required this.fileUrl,
  });

  final int id;
  final int type;
  final String fileUrl;

  factory RefereeDocument.fromJson(Map<String, dynamic> json) =>
      RefereeDocument(
        id: _intValue(json['id']),
        type: _intValue(json['type']),
        fileUrl: _stringValue(json['file_url'] ?? json['file_path']) ?? '',
      );
}

class RefereeApplicationTimeline {
  const RefereeApplicationTimeline({
    required this.status,
    this.reason,
    this.date,
  });

  final int status;
  final String? reason;
  final String? date;

  factory RefereeApplicationTimeline.fromJson(Map<String, dynamic> json) =>
      RefereeApplicationTimeline(
        status: _intValue(json['status']),
        reason: _stringValue(json['reason']),
        date: _stringValue(json['date']),
      );
}

class RefereeApplicationResponse {
  const RefereeApplicationResponse({
    required this.applicationNumber,
    required this.applicationStatus,
    this.submittedAt,
    required this.personalInformation,
    required this.address,
    required this.sports,
    required this.availability,
    this.documents = const [],
    this.timeline = const [],
  });

  final String applicationNumber;
  final int applicationStatus;
  final String? submittedAt;
  final RefereePersonalInformation personalInformation;
  final RefereeAddress address;
  final RefereeSportsInformation sports;
  final RefereeAvailability availability;
  final List<RefereeDocument> documents;
  final List<RefereeApplicationTimeline> timeline;

  bool get isDraft => applicationStatus == 1;
  bool get isPendingReview => applicationStatus == 2;
  bool get isApproved => applicationStatus == 3;

  factory RefereeApplicationResponse.fromJson(Map<String, dynamic> json) =>
      RefereeApplicationResponse(
        applicationNumber: _stringValue(json['application_number']) ?? '',
        applicationStatus: _intValue(json['application_status']),
        submittedAt: _stringValue(json['submitted_at']),
        personalInformation: RefereePersonalInformation.fromJson(
          _mapValue(json['personal_information'] ?? json['personal']),
        ),
        address: RefereeAddress.fromJson(_mapValue(json['address'])),
        sports: RefereeSportsInformation.fromJson(_mapValue(json['sports'])),
        availability:
            RefereeAvailability.fromJson(_mapValue(json['availability'])),
        documents: _listValue(json['documents'])
            .whereType<Map>()
            .map((value) =>
                RefereeDocument.fromJson(Map<String, dynamic>.from(value)))
            .toList(),
        timeline: _listValue(json['timeline'])
            .whereType<Map>()
            .map((value) => RefereeApplicationTimeline.fromJson(
                Map<String, dynamic>.from(value)))
            .toList(),
      );
}

class RefereeApplicationStatusResponse {
  const RefereeApplicationStatusResponse({
    required this.applicationNumber,
    required this.applicationStatus,
    this.statusLabel,
    this.submittedAt,
    this.timeline = const [],
  });

  final String applicationNumber;
  final int applicationStatus;
  final String? statusLabel;
  final String? submittedAt;
  final List<RefereeApplicationTimeline> timeline;

  factory RefereeApplicationStatusResponse.fromJson(
    Map<String, dynamic> json,
  ) =>
      RefereeApplicationStatusResponse(
        applicationNumber: _stringValue(json['application_number']) ?? '',
        applicationStatus:
            _intValue(json['application_status'] ?? json['status']),
        statusLabel: _stringValue(json['status_label']),
        submittedAt: _stringValue(json['submitted_at']),
        timeline: _listValue(json['timeline'])
            .whereType<Map>()
            .map((value) => RefereeApplicationTimeline.fromJson(
                Map<String, dynamic>.from(value)))
            .toList(),
      );
}

class RefereeMatchTeam {
  const RefereeMatchTeam({
    this.id,
    required this.name,
    this.score,
  });

  final int? id;
  final String name;
  final String? score;

  factory RefereeMatchTeam.fromJson(Map<String, dynamic> json) {
    return RefereeMatchTeam(
      id: json['id'] == null ? null : _intValue(json['id']),
      name: _stringValue(
            json['name'] ??
                json['team_name'] ??
                json['display_name'] ??
                json['title'],
          ) ??
          'Team',
      score: _stringValue(json['score'] ?? json['runs']),
    );
  }
}

class RefereeMatchResponse {
  const RefereeMatchResponse({
    required this.id,
    this.assignmentId,
    this.tournamentId,
    this.tournamentName,
    this.matchNumber,
    this.roundName,
    this.scheduledAt,
    this.matchDate,
    this.startTime,
    this.venueName,
    this.location,
    this.status,
    this.statusLabel,
    this.role,
    this.notes,
    this.teamA,
    this.teamB,
    this.raw = const {},
  });

  final int id;
  final int? assignmentId;
  final int? tournamentId;
  final String? tournamentName;
  final String? matchNumber;
  final String? roundName;
  final String? scheduledAt;
  final String? matchDate;
  final String? startTime;
  final String? venueName;
  final String? location;
  final int? status;
  final String? statusLabel;
  final String? role;
  final String? notes;
  final RefereeMatchTeam? teamA;
  final RefereeMatchTeam? teamB;
  final Map<String, dynamic> raw;

  String get displayTournament =>
      _firstText([tournamentName, raw['competition_name']]) ?? 'Tournament';
  String get displayRound => _firstText([roundName, matchNumber]) ?? 'Match';
  String get displaySchedule =>
      _firstText([scheduledAt, _joinDateTime(matchDate, startTime)]) ??
      'Schedule not set';
  String get displayVenue =>
      _firstText([venueName, location]) ?? 'Venue not set';
  String get displayTeamA => teamA?.name ?? 'Team A';
  String get displayTeamB => teamB?.name ?? 'Team B';
  String get displayStatus =>
      _firstText([statusLabel, raw['status_text'], raw['state']]) ??
      _statusFromValue(status);

  bool get isLive {
    final value = displayStatus.toLowerCase();
    return value.contains('live') || value.contains('progress');
  }

  bool get isCompleted {
    final value = displayStatus.toLowerCase();
    return value.contains('complete') || value.contains('finish');
  }

  bool get isUpcoming => !isLive && !isCompleted;

  factory RefereeMatchResponse.fromJson(Map<String, dynamic> json) {
    final assignment = _mapValue(json['assignment']);
    final match = _mapValue(json['match']).isNotEmpty
        ? _mapValue(json['match'])
        : Map<String, dynamic>.from(json);
    final tournament = _mapValue(
      match['tournament'] ?? json['tournament'] ?? assignment['tournament'],
    );
    final venue = _mapValue(match['venue'] ?? json['venue']);
    final teamA = _teamFromAny(
      match['team_a'] ??
          match['team1'] ??
          match['home_team'] ??
          json['team_a'] ??
          json['team1'] ??
          json['home_team'],
    );
    final teamB = _teamFromAny(
      match['team_b'] ??
          match['team2'] ??
          match['away_team'] ??
          json['team_b'] ??
          json['team2'] ??
          json['away_team'],
    );

    return RefereeMatchResponse(
      id: _intValue(match['id'] ?? json['match_id'] ?? json['id']),
      assignmentId:
          _nullableInt(json['assignment_id'] ?? assignment['id'] ?? json['id']),
      tournamentId: _nullableInt(
        match['tournament_id'] ?? json['tournament_id'] ?? tournament['id'],
      ),
      tournamentName: _firstText([
        match['tournament_name'],
        json['tournament_name'],
        tournament['name'],
      ]),
      matchNumber: _stringValue(
        match['match_number'] ??
            match['match_no'] ??
            match['fixture_code'] ??
            match['code'],
      ),
      roundName: _stringValue(
        match['round_name'] ?? match['round'] ?? match['stage'],
      ),
      scheduledAt: _stringValue(
        match['scheduled_at'] ??
            match['match_start_at'] ??
            json['scheduled_at'] ??
            json['match_start_at'],
      ),
      matchDate: _stringValue(
        match['match_date'] ?? match['date'] ?? json['match_date'],
      ),
      startTime: _stringValue(
        match['start_time'] ?? match['time'] ?? json['start_time'],
      ),
      venueName: _firstText([
        match['venue_name'],
        json['venue_name'],
        venue['venue_name'],
        venue['name'],
      ]),
      location: _firstText([
        match['location'],
        json['location'],
        venue['location'],
        venue['address'],
        venue['venue_address'],
      ]),
      status: _nullableInt(match['status'] ?? json['status']),
      statusLabel: _stringValue(
        match['status_label'] ?? json['status_label'] ?? match['status_text'],
      ),
      role: _stringValue(json['role'] ?? assignment['role']),
      notes: _stringValue(json['notes'] ?? assignment['notes']),
      teamA: teamA,
      teamB: teamB,
      raw: Map<String, dynamic>.from(json),
    );
  }

  static RefereeMatchTeam? _teamFromAny(Object? value) {
    if (value is Map) {
      return RefereeMatchTeam.fromJson(Map<String, dynamic>.from(value));
    }
    final text = _stringValue(value);
    if (text == null || text.trim().isEmpty) return null;
    return RefereeMatchTeam(name: text);
  }
}

class RefereeMatchRequestResponse extends RefereeMatchResponse {
  const RefereeMatchRequestResponse({
    required super.id,
    super.assignmentId,
    super.tournamentId,
    super.tournamentName,
    super.matchNumber,
    super.roundName,
    super.scheduledAt,
    super.matchDate,
    super.startTime,
    super.venueName,
    super.location,
    super.status,
    super.statusLabel,
    super.role,
    super.notes,
    super.teamA,
    super.teamB,
    super.raw,
  });

  factory RefereeMatchRequestResponse.fromJson(Map<String, dynamic> json) {
    final match = RefereeMatchResponse.fromJson(json);
    return RefereeMatchRequestResponse(
      id: match.id,
      assignmentId: match.assignmentId,
      tournamentId: match.tournamentId,
      tournamentName: match.tournamentName,
      matchNumber: match.matchNumber,
      roundName: match.roundName,
      scheduledAt: match.scheduledAt,
      matchDate: match.matchDate,
      startTime: match.startTime,
      venueName: match.venueName,
      location: match.location,
      status: match.status,
      statusLabel: match.statusLabel,
      role: match.role,
      notes: match.notes,
      teamA: match.teamA,
      teamB: match.teamB,
      raw: match.raw,
    );
  }
}

int? _nullableInt(Object? value) {
  if (value == null) return null;
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse(value.toString());
}

String? _firstText(Iterable<Object?> values) {
  for (final value in values) {
    final text = _stringValue(value)?.trim();
    if (text != null && text.isNotEmpty) return text;
  }
  return null;
}

String? _joinDateTime(String? date, String? time) {
  final cleanDate = date?.trim();
  final cleanTime = time?.trim();
  if (cleanDate == null || cleanDate.isEmpty) return cleanTime;
  if (cleanTime == null || cleanTime.isEmpty) return cleanDate;
  return '$cleanDate, $cleanTime';
}

String _statusFromValue(int? value) {
  return switch (value) {
    2 => 'Live',
    3 => 'Completed',
    4 => 'Cancelled',
    _ => 'Scheduled',
  };
}

class RefereeTossDecisionLabels {
  const RefereeTossDecisionLabels._();

  static const Map<String, String> values = {
    'BAT_FIRST': 'Bat First',
    'BOWL_FIRST': 'Bowl First',
    'KICK_OFF': 'Kick Off',
    'CHOOSE_SIDE': 'Choose Side',
    'SERVE': 'Serve',
    'RECEIVE': 'Receive',
    'COURT_SIDE': 'Choose Court Side',
    'INITIAL_POSSESSION': 'Initial Possession',
    'RAID_FIRST': 'Raid First',
    'CHASE_FIRST': 'Chase First',
    'DEFEND_FIRST': 'Defend First',
    'STARTING_POSSESSION': 'Starting Possession',
    'OFFENSE_FIRST': 'Offense First',
    'DEFENSE_FIRST': 'Defense First',
    'FIRST_BREAK': 'First Break',
    'FIRST_MOVE': 'First Move',
    'KICK_FIRST': 'Kick First',
  };

  static String labelFor(String value) => values[value] ?? value;
}

class RefereeTossOptionResponse {
  const RefereeTossOptionResponse({
    required this.value,
    required this.label,
  });

  final String value;
  final String label;

  factory RefereeTossOptionResponse.fromJson(Map<String, dynamic> json) {
    final value = _stringValue(json['value']) ?? '';
    return RefereeTossOptionResponse(
      value: value,
      label: _stringValue(json['label']) ??
          RefereeTossDecisionLabels.labelFor(value),
    );
  }
}

class RefereeTossStartingRoleResponse {
  const RefereeTossStartingRoleResponse({
    required this.key,
    required this.label,
    required this.isOpponent,
  });

  final String key;
  final String label;
  final bool isOpponent;

  factory RefereeTossStartingRoleResponse.fromJson(
    Map<String, dynamic> json,
  ) {
    return RefereeTossStartingRoleResponse(
      key: _stringValue(json['key']) ?? '',
      label: _stringValue(json['label']) ?? '',
      isOpponent:
          json['is_opponent'] == true || json['is_opponent']?.toString() == '1',
    );
  }
}

class RefereeTossRuntimeResponse {
  const RefereeTossRuntimeResponse({
    this.callingTeamId,
    this.calledSide,
    this.landedSide,
    this.winnerTeamId,
    this.decision,
    this.startingSetup,
    this.completedAt,
  });

  final int? callingTeamId;
  final String? calledSide;
  final String? landedSide;
  final int? winnerTeamId;
  final String? decision;
  final Map<String, dynamic>? startingSetup;
  final String? completedAt;

  String? get decisionLabel =>
      decision == null ? null : RefereeTossDecisionLabels.labelFor(decision!);

  factory RefereeTossRuntimeResponse.fromJson(Map<String, dynamic> json) {
    final startingSetup = json['starting_setup'];
    return RefereeTossRuntimeResponse(
      callingTeamId: _nullableInt(json['calling_team_id']),
      calledSide: _stringValue(json['called_side']),
      landedSide: _stringValue(json['landed_side']),
      winnerTeamId: _nullableInt(json['winner_team_id']),
      decision: _stringValue(json['decision']),
      startingSetup: startingSetup is Map
          ? Map<String, dynamic>.from(startingSetup)
          : null,
      completedAt: _stringValue(json['completed_at']),
    );
  }
}

class RefereeTossStateResponse {
  const RefereeTossStateResponse({
    required this.enabled,
    this.method,
    this.state,
    this.decisionOptions = const [],
    this.startingRoles = const [],
    required this.runtime,
    this.resultMethods = const [],
  });

  final bool enabled;
  final String? method;
  final String? state;
  final List<RefereeTossOptionResponse> decisionOptions;
  final List<RefereeTossStartingRoleResponse> startingRoles;
  final RefereeTossRuntimeResponse runtime;
  final List<RefereeTossOptionResponse> resultMethods;

  bool get isPending => state == null || state == 'TOSS_PENDING';
  bool get isCalling => state == 'TOSS_CALLING';
  bool get isDecisionPending => state == 'DECISION_PENDING';
  bool get isCompleted => runtime.completedAt != null || state == 'COMPLETED';

  factory RefereeTossStateResponse.fromJson(Map<String, dynamic> json) {
    return RefereeTossStateResponse(
      enabled: json['enabled'] != false,
      method: _stringValue(json['method']),
      state: _stringValue(json['state']),
      decisionOptions: _listValue(json['decision_options'])
          .whereType<Map>()
          .map((item) => RefereeTossOptionResponse.fromJson(
                Map<String, dynamic>.from(item),
              ))
          .toList(),
      startingRoles: _listValue(json['starting_roles'])
          .whereType<Map>()
          .map((item) => RefereeTossStartingRoleResponse.fromJson(
                Map<String, dynamic>.from(item),
              ))
          .toList(),
      runtime: RefereeTossRuntimeResponse.fromJson(
        _mapValue(json['runtime']),
      ),
      resultMethods: _listValue(json['result_methods'])
          .whereType<Map>()
          .map((item) => RefereeTossOptionResponse.fromJson(
                Map<String, dynamic>.from(item),
              ))
          .toList(),
    );
  }
}

class RefereeTossResponse {
  const RefereeTossResponse({
    this.sportId,
    this.sportName,
    this.formatId,
    this.formatName,
    required this.toss,
    this.raw = const {},
  });

  final int? sportId;
  final String? sportName;
  final int? formatId;
  final String? formatName;
  final RefereeTossStateResponse toss;
  final Map<String, dynamic> raw;

  factory RefereeTossResponse.fromJson(Map<String, dynamic> json) {
    final sport = _mapValue(json['sport']);
    final format = _mapValue(json['format']);
    return RefereeTossResponse(
      sportId: _nullableInt(sport['id']),
      sportName: _stringValue(sport['name']),
      formatId: _nullableInt(format['id']),
      formatName: _stringValue(format['name']),
      toss: RefereeTossStateResponse.fromJson(_mapValue(json['toss'])),
      raw: Map<String, dynamic>.from(json),
    );
  }
}

class RefereeTossUpdateRequest {
  const RefereeTossUpdateRequest._(this.body);

  final Map<String, dynamic> body;

  factory RefereeTossUpdateRequest.call({required String calledSide}) {
    return RefereeTossUpdateRequest._({
      'action': 'CALL',
      'called_side': calledSide,
    });
  }

  factory RefereeTossUpdateRequest.flip() {
    return const RefereeTossUpdateRequest._({'action': 'FLIP'});
  }

  factory RefereeTossUpdateRequest.enterResult({required int winnerTeamId}) {
    return RefereeTossUpdateRequest._({
      'action': 'ENTER_RESULT',
      'winner_team_id': winnerTeamId,
    });
  }

  factory RefereeTossUpdateRequest.setDecision({required String decision}) {
    return RefereeTossUpdateRequest._({
      'action': 'SET_DECISION',
      'decision': decision,
    });
  }

  factory RefereeTossUpdateRequest.setStartingPlayers({
    required int strikerUserId,
    required int nonStrikerUserId,
    required int openingBowlerUserId,
  }) {
    return RefereeTossUpdateRequest._({
      'action': 'SET_STARTING_PLAYERS',
      'striker_user_id': strikerUserId,
      'non_striker_user_id': nonStrikerUserId,
      'opening_bowler_user_id': openingBowlerUserId,
    });
  }

  Map<String, dynamic> toJson() => body;
}

class RefereeScorePlayerResponse {
  const RefereeScorePlayerResponse({
    required this.userId,
    required this.name,
  });

  final int userId;
  final String name;

  factory RefereeScorePlayerResponse.fromJson(Map<String, dynamic> json) {
    return RefereeScorePlayerResponse(
      userId: _intValue(json['user_id'] ?? json['id']),
      name: _stringValue(json['name'] ?? json['player_name']) ?? 'Player',
    );
  }
}

class RefereeScoreTeamResponse {
  const RefereeScoreTeamResponse({
    required this.id,
    required this.name,
    this.logoUrl,
    this.players = const [],
  });

  final int id;
  final String name;
  final String? logoUrl;
  final List<RefereeScorePlayerResponse> players;

  factory RefereeScoreTeamResponse.fromJson(Map<String, dynamic> json) {
    return RefereeScoreTeamResponse(
      id: _intValue(json['id'] ?? json['team_id']),
      name: _stringValue(
            json['team_name'] ?? json['name'] ?? json['display_name'],
          ) ??
          'Team',
      logoUrl: _stringValue(json['team_logo_url'] ?? json['logo_url']),
      players: _listValue(json['players'])
          .whereType<Map>()
          .map((item) => RefereeScorePlayerResponse.fromJson(
                Map<String, dynamic>.from(item),
              ))
          .toList(),
    );
  }
}

class RefereeScoreEventResponse {
  const RefereeScoreEventResponse({
    required this.code,
    required this.label,
    this.type,
    this.value,
    this.requiresPlayer = false,
  });

  final String code;
  final String label;
  final String? type;
  final int? value;
  final bool requiresPlayer;

  factory RefereeScoreEventResponse.fromJson(Map<String, dynamic> json) {
    final code = _stringValue(json['code'] ?? json['event_code']) ?? '';
    return RefereeScoreEventResponse(
      code: code,
      label: _stringValue(json['label'] ?? json['name']) ?? code,
      type: _stringValue(json['type']),
      value: _nullableInt(json['value']),
      requiresPlayer: json['requires_player'] == true ||
          json['requires_player']?.toString() == '1',
    );
  }
}

class RefereeScoreStateResponse {
  const RefereeScoreStateResponse({
    required this.enabled,
    this.method,
    this.periodType,
    this.periodsCount,
    this.currentPeriod,
    this.availableEvents = const [],
    this.runtime = const {},
    this.score = const {},
  });

  final bool enabled;
  final String? method;
  final String? periodType;
  final int? periodsCount;
  final int? currentPeriod;
  final List<RefereeScoreEventResponse> availableEvents;
  final Map<String, dynamic> runtime;
  final Map<String, dynamic> score;

  factory RefereeScoreStateResponse.fromJson(Map<String, dynamic> json) {
    return RefereeScoreStateResponse(
      enabled: json['enabled'] == true || json['enabled']?.toString() == '1',
      method: _stringValue(json['method']),
      periodType: _stringValue(json['period_type']),
      periodsCount: _nullableInt(json['periods_count']),
      currentPeriod: _nullableInt(json['current_period']),
      availableEvents: _listValue(json['available_events'])
          .whereType<Map>()
          .map((item) => RefereeScoreEventResponse.fromJson(
                Map<String, dynamic>.from(item),
              ))
          .toList(),
      runtime: _mapValue(json['runtime']),
      score: _mapValue(json['score']),
    );
  }
}

class RefereeScoreResponse {
  const RefereeScoreResponse({
    required this.matchId,
    this.matchStatus,
    this.matchNumber,
    this.winnerTeamId,
    this.isWalkover = false,
    this.sportId,
    this.sportName,
    this.formatId,
    this.formatName,
    this.teams = const [],
    required this.scoring,
    this.raw = const {},
  });

  final int matchId;
  final int? matchStatus;
  final int? matchNumber;
  final int? winnerTeamId;
  final bool isWalkover;
  final int? sportId;
  final String? sportName;
  final int? formatId;
  final String? formatName;
  final List<RefereeScoreTeamResponse> teams;
  final RefereeScoreStateResponse scoring;
  final Map<String, dynamic> raw;

  factory RefereeScoreResponse.fromJson(Map<String, dynamic> json) {
    final match = _mapValue(json['match']);
    final sport = _mapValue(json['sport']);
    final format = _mapValue(json['format']);
    return RefereeScoreResponse(
      matchId: _intValue(match['id'] ?? json['match_id'] ?? json['id']),
      matchStatus: _nullableInt(match['status'] ?? json['status']),
      matchNumber: _nullableInt(match['match_number']),
      winnerTeamId: _nullableInt(match['winner_team_id']),
      isWalkover: match['is_walkover'] == true ||
          match['is_walkover']?.toString() == '1',
      sportId: _nullableInt(sport['id']),
      sportName: _stringValue(sport['name']),
      formatId: _nullableInt(format['id']),
      formatName: _stringValue(format['name']),
      teams: _listValue(json['teams'])
          .whereType<Map>()
          .map((item) => RefereeScoreTeamResponse.fromJson(
                Map<String, dynamic>.from(item),
              ))
          .toList(),
      scoring: RefereeScoreStateResponse.fromJson(_mapValue(json['scoring'])),
      raw: Map<String, dynamic>.from(json),
    );
  }
}

class RefereeScoreUpdateRequest {
  const RefereeScoreUpdateRequest._(this.body);

  final Map<String, dynamic> body;

  factory RefereeScoreUpdateRequest.start() {
    return const RefereeScoreUpdateRequest._({'action': 'START'});
  }

  factory RefereeScoreUpdateRequest.undoLast() {
    return const RefereeScoreUpdateRequest._({'action': 'UNDO_LAST'});
  }

  factory RefereeScoreUpdateRequest.endPeriod() {
    return const RefereeScoreUpdateRequest._({'action': 'END_PERIOD'});
  }

  factory RefereeScoreUpdateRequest.complete() {
    return const RefereeScoreUpdateRequest._({'action': 'COMPLETE'});
  }

  factory RefereeScoreUpdateRequest.addEvent({
    required String eventCode,
    required int teamId,
    int? playerId,
    int? value,
  }) {
    return RefereeScoreUpdateRequest._({
      'action': 'ADD_EVENT',
      'event_code': eventCode,
      'team_id': teamId,
      if (playerId != null) 'player_id': playerId,
      if (value != null) 'value': value,
    });
  }

  Map<String, dynamic> toJson() => body;
}
