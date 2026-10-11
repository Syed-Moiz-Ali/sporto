import 'referee_api_constants.dart';

int _intValue(Object? value) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse(value?.toString() ?? '') ?? 0;
}

String? _stringValue(Object? value) => value?.toString();

Map<String, dynamic> _mapValue(Object? value) {
  return value is Map ? Map<String, dynamic>.from(value) : const {};
}

abstract final class RefereeAssignmentStatus {
  static const assigned = 1;
  static const accepted = 2;
  static const rejected = 3;
  static const cancelled = 4;
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
  bool get isPendingReview => applicationStatus == 2 || applicationStatus == 3;
  bool get isApproved => applicationStatus == 4;

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

class RefereeProfileResponse {
  const RefereeProfileResponse(
      {required this.name,
      this.email,
      this.mobile,
      this.sports = const [],
      this.experienceYears});
  final String name;
  final String? email;
  final String? mobile;
  final List<String> sports;
  final int? experienceYears;

  factory RefereeProfileResponse.fromJson(Map<String, dynamic> json) {
    final profile =
        Map<String, dynamic>.from((json['profile'] as Map?) ?? const {});
    final sports = (json['sports'] as List? ?? const [])
        .whereType<Map>()
        .map((s) => _stringValue(s['name']) ?? '')
        .where((s) => s.isNotEmpty)
        .toList();
    final experience =
        Map<String, dynamic>.from((json['experience'] as Map?) ?? const {});
    return RefereeProfileResponse(
      name: _stringValue(profile['name']) ?? 'Referee',
      email: _stringValue(profile['email']),
      mobile: _stringValue(profile['mobile_number']),
      sports: sports,
      experienceYears: experience['experience_years'] == null
          ? null
          : _intValue(experience['experience_years']),
    );
  }
}

class RefereeMatchTeam {
  const RefereeMatchTeam({
    this.id,
    required this.name,
    this.score,
    this.logoUrl,
  });

  final int? id;
  final String name;
  final String? score;
  final String? logoUrl;

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
      logoUrl: _stringValue(json['team_logo_url'] ?? json['logo_url']),
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
    this.assignmentStatus,
    this.notes,
    this.teamA,
    this.teamB,
    this.canOfficiate = false,
    this.blockingCode,
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
  final int? assignmentStatus;
  final String? notes;
  final RefereeMatchTeam? teamA;
  final RefereeMatchTeam? teamB;
  final bool canOfficiate;
  final String? blockingCode;
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

  Map<String, dynamic> get tossData => _mapValue(raw['toss']);
  String? get tossState => _stringValue(tossData['state']);
  String? get tossNextAction => _stringValue(tossData['next_action']);
  bool get isTossCompleted =>
      tossData['is_completed'] == true ||
      _stringValue(tossData['state']) == RefereeTossStates.completed;

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
    final schedule = _mapValue(match['schedule'] ?? json['schedule']);
    final venue = _mapValue(
      match['venue'] ?? json['venue'] ?? schedule['venue'],
    );
    final participants = _mapValue(
      match['participants'] ?? json['participants'],
    );
    final teamA = _teamFromAny(
      match['team_a'] ??
          match['team1'] ??
          match['home_team'] ??
          json['team_a'] ??
          json['team1'] ??
          json['home_team'] ??
          participants['team_a'],
    );
    final teamB = _teamFromAny(
      match['team_b'] ??
          match['team2'] ??
          match['away_team'] ??
          json['team_b'] ??
          json['team2'] ??
          json['away_team'] ??
          participants['team_b'],
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
        match['round_name'] ??
            match['round']?['name'] ??
            match['stage']?['name'] ??
            match['round'] ??
            match['stage'],
      ),
      scheduledAt: _stringValue(
        match['scheduled_at'] ??
            match['match_start_at'] ??
            json['scheduled_at'] ??
            json['match_start_at'],
      ),
      matchDate: _stringValue(
        match['match_date'] ??
            match['date'] ??
            json['match_date'] ??
            schedule['date'],
      ),
      startTime: _stringValue(
        match['start_time'] ??
            match['time'] ??
            json['start_time'] ??
            schedule['start_time'],
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
      assignmentStatus: _nullableInt(
        assignment['status'] ?? json['assignment_status'],
      ),
      notes: _stringValue(json['notes'] ?? assignment['notes']),
      teamA: teamA,
      teamB: teamB,
      canOfficiate: match['can_officiate'] == true ||
          match['can_officiate']?.toString() == '1' ||
          json['can_officiate'] == true ||
          json['can_officiate']?.toString() == '1',
      blockingCode: _stringValue(
        match['blocking_code'] ?? json['blocking_code'],
      ),
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
    super.assignmentStatus,
    super.notes,
    super.teamA,
    super.teamB,
    super.canOfficiate,
    super.blockingCode,
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
      assignmentStatus: match.assignmentStatus,
      notes: match.notes,
      teamA: match.teamA,
      teamB: match.teamB,
      canOfficiate: match.canOfficiate,
      blockingCode: match.blockingCode,
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
    RefereeTossDecisions.batFirst: 'Bat First',
    RefereeTossDecisions.bowlFirst: 'Bowl First',
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
    this.nextAction,
    this.isResultDecided = false,
    this.isCompleted = false,
    this.allowedActions = const [],
    this.battingTeamId,
    this.bowlingTeamId,
  });

  final int? callingTeamId;
  final String? calledSide;
  final String? landedSide;
  final int? winnerTeamId;
  final String? decision;
  final Map<String, dynamic>? startingSetup;
  final String? completedAt;
  final String? nextAction;
  final bool isResultDecided;
  final bool isCompleted;
  final List<String> allowedActions;
  final int? battingTeamId;
  final int? bowlingTeamId;

  String? get decisionLabel =>
      decision == null ? null : RefereeTossDecisionLabels.labelFor(decision!);

  /// User id assigned to a starting role (e.g. `STRIKER`, `OPENING_BOWLER`).
  int? startingUserId(String roleKey) {
    final setup = startingSetup;
    if (setup == null) return null;
    final value = setup[roleKey];
    if (value is Map) {
      return _nullableInt(value['user_id'] ?? value['id']);
    }
    return _nullableInt(value);
  }

  factory RefereeTossRuntimeResponse.fromJson(Map<String, dynamic> json) {
    final startingSetup = json['starting_setup'];
    final battingTeam = _mapValue(json['batting_team']);
    final bowlingTeam = _mapValue(json['bowling_team']);
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
      nextAction: _stringValue(json['next_action']),
      isResultDecided: json['is_result_decided'] == true,
      isCompleted: json['is_completed'] == true,
      allowedActions: _listValue(json['allowed_actions'])
          .map((value) => value.toString())
          .toList(),
      battingTeamId: _nullableInt(
        json['batting_team_id'] ?? battingTeam['id'],
      ),
      bowlingTeamId: _nullableInt(
        json['bowling_team_id'] ?? bowlingTeam['id'],
      ),
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
    this.isStarted = false,
    this.isResultDecided = false,
    this.isCompletedState = false,
    this.nextActionValue,
    this.allowedActionsValue = const [],
  });

  final bool enabled;
  final String? method;
  final String? state;
  final List<RefereeTossOptionResponse> decisionOptions;
  final List<RefereeTossStartingRoleResponse> startingRoles;
  final RefereeTossRuntimeResponse runtime;
  final List<RefereeTossOptionResponse> resultMethods;
  final bool isStarted;
  final bool isResultDecided;
  final bool isCompletedState;
  final String? nextActionValue;
  final List<String> allowedActionsValue;

  bool get isPending => state == null || state == RefereeTossStates.pending;
  bool get isCalling => state == RefereeTossStates.calling;
  bool get isDecisionPending => state == RefereeTossStates.decisionPending;
  bool get isStartingSetupPending =>
      state == RefereeTossStates.startingSetupPending;
  bool get isDisabled => state == RefereeTossStates.disabled;
  bool get isCompleted =>
      isCompletedState ||
      state == RefereeTossStates.completed ||
      state == RefereeScoreRuntimeStates.completed ||
      runtime.isCompleted ||
      runtime.completedAt != null;

  String? get nextAction => nextActionValue ?? runtime.nextAction;

  List<String> get allowedActions => allowedActionsValue.isNotEmpty
      ? allowedActionsValue
      : runtime.allowedActions;

  factory RefereeTossStateResponse.fromJson(Map<String, dynamic> json) {
    final runtimeJson = _mapValue(json['runtime']);
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
        runtimeJson.isNotEmpty ? runtimeJson : json,
      ),
      resultMethods: _listValue(json['result_methods'])
          .whereType<Map>()
          .map((item) => RefereeTossOptionResponse.fromJson(
                Map<String, dynamic>.from(item),
              ))
          .toList(),
      isStarted: json['is_started'] == true ||
          runtimeJson['is_started'] == true,
      isResultDecided: json['is_result_decided'] == true ||
          runtimeJson['is_result_decided'] == true,
      isCompletedState: json['is_completed'] == true ||
          runtimeJson['is_completed'] == true,
      nextActionValue: _stringValue(json['next_action']),
      allowedActionsValue: _listValue(json['allowed_actions'])
          .map((value) => value.toString())
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
    this.teams = const [],
    this.raw = const {},
  });

  final int? sportId;
  final String? sportName;
  final int? formatId;
  final String? formatName;
  final RefereeTossStateResponse toss;
  final List<RefereeTossTeamResponse> teams;
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
      teams: _listValue(json['teams'])
          .whereType<Map>()
          .map((item) =>
              RefereeTossTeamResponse.fromJson(Map<String, dynamic>.from(item)))
          .toList(),
      raw: Map<String, dynamic>.from(json),
    );
  }
}

class RefereeTossTeamResponse {
  const RefereeTossTeamResponse(
      {required this.id,
      required this.name,
      this.logoUrl,
      this.members = const []});
  final int id;
  final String name;
  final String? logoUrl;
  final List<RefereeTossMemberResponse> members;
  factory RefereeTossTeamResponse.fromJson(Map<String, dynamic> json) =>
      RefereeTossTeamResponse(
        id: _intValue(json['id']),
        name: _stringValue(json['name']) ?? 'Team',
        logoUrl: _stringValue(json['logo_url'] ?? json['team_logo_url']),
        members: _listValue(
          json['members'] ??
              json['players'] ??
              json['roster'] ??
              json['playing_xi'],
        )
            .whereType<Map>()
            .map((m) => RefereeTossMemberResponse.fromJson(
                Map<String, dynamic>.from(m)))
            .toList(),
      );
}

class RefereeTossMemberResponse {
  const RefereeTossMemberResponse(
      {required this.userId, required this.name, this.isCaptain = false});
  final int userId;
  final String name;
  final bool isCaptain;
  factory RefereeTossMemberResponse.fromJson(Map<String, dynamic> json) {
    final user = _mapValue(json['user'] ?? json['player']);
    final role = _stringValue(json['role'] ?? user['role'])?.toLowerCase();
    return RefereeTossMemberResponse(
      userId: _intValue(
        json['user_id'] ?? json['player_id'] ?? user['id'] ?? json['id'],
      ),
      name: _stringValue(
            json['name'] ??
                json['player_name'] ??
                user['name'] ??
                user['full_name'],
          ) ??
          'Player',
      isCaptain: json['is_captain'] == true ||
          json['is_captain']?.toString() == '1' ||
          role == 'captain',
    );
  }
}

class RefereeTossUpdateRequest {
  const RefereeTossUpdateRequest._(this.body);

  final Map<String, dynamic> body;

  factory RefereeTossUpdateRequest.call({
    required String calledSide,
    required int callingTeamId,
  }) {
    return RefereeTossUpdateRequest._({
      'action': RefereeTossActions.call,
      'called_side': calledSide,
      'calling_team_id': callingTeamId,
    });
  }

  factory RefereeTossUpdateRequest.flip() {
    return const RefereeTossUpdateRequest._(
      {'action': RefereeTossActions.flip},
    );
  }

  factory RefereeTossUpdateRequest.enterResult({required int winnerTeamId}) {
    return RefereeTossUpdateRequest._({
      'action': RefereeTossActions.enterResult,
      'winner_team_id': winnerTeamId,
    });
  }

  factory RefereeTossUpdateRequest.setDecision({required String decision}) {
    return RefereeTossUpdateRequest._({
      'action': RefereeTossActions.setDecision,
      'decision': decision,
    });
  }

  factory RefereeTossUpdateRequest.setStartingPlayers({
    required int strikerUserId,
    required int nonStrikerUserId,
    required int openingBowlerUserId,
  }) {
    return RefereeTossUpdateRequest._({
      'action': RefereeTossActions.setStartingPlayers,
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
    this.variableValue = false,
    this.allowedValues = const [],
  });

  final String code;
  final String label;
  final String? type;
  final int? value;
  final bool requiresPlayer;
  final bool variableValue;
  final List<int> allowedValues;

  factory RefereeScoreEventResponse.fromJson(Map<String, dynamic> json) {
    final code = _stringValue(json['code'] ?? json['event_code']) ?? '';
    return RefereeScoreEventResponse(
      code: code,
      label: _stringValue(json['label'] ?? json['name']) ?? code,
      type: _stringValue(json['type']),
      value: _nullableInt(json['value']),
      requiresPlayer: json['requires_player'] == true ||
          json['requires_player']?.toString() == '1',
      variableValue: json['variable_value'] == true ||
          json['variable_value']?.toString() == '1',
      allowedValues: _listValue(json['allowed_values'])
          .map((value) => _nullableInt(value))
          .whereType<int>()
          .toList(),
    );
  }
}

class RefereeScoreTeamRuntime {
  const RefereeScoreTeamRuntime({this.id, this.name, this.logoUrl});

  final int? id;
  final String? name;
  final String? logoUrl;

  bool get isEmpty => id == null && name == null;

  factory RefereeScoreTeamRuntime.fromJson(Map<String, dynamic> json) {
    return RefereeScoreTeamRuntime(
      id: _nullableInt(json['id']),
      name: _stringValue(json['name']),
      logoUrl: _stringValue(json['logo_url']),
    );
  }
}

class RefereeScorePlayerRuntime {
  const RefereeScorePlayerRuntime({
    this.userId,
    this.name,
    this.profileImageUrl,
  });

  final int? userId;
  final String? name;
  final String? profileImageUrl;

  bool get isEmpty => userId == null && name == null;

  factory RefereeScorePlayerRuntime.fromJson(Map<String, dynamic> json) {
    return RefereeScorePlayerRuntime(
      userId: _nullableInt(json['user_id']),
      name: _stringValue(json['name']),
      profileImageUrl: _stringValue(json['profile_image_url']),
    );
  }
}

class RefereeScoreEvent {
  const RefereeScoreEvent({
    required this.type,
    this.sequence,
    this.occurredAt,
    this.data = const {},
  });

  final String type;
  final int? sequence;
  final String? occurredAt;
  final Map<String, dynamic> data;

  bool get isBallRecorded => type == RefereeScoreEventTypes.ballRecorded;
  bool get isOverComplete => type == RefereeScoreEventTypes.overComplete;
  bool get isStrikeRotated => type == RefereeScoreEventTypes.strikeRotated;
  bool get isWicketRecorded => type == RefereeScoreEventTypes.wicketRecorded;
  bool get isInningsComplete => type == RefereeScoreEventTypes.inningsComplete;
  bool get isInningsChanged => type == RefereeScoreEventTypes.inningsChanged;
  bool get isInningsStarted => type == RefereeScoreEventTypes.inningsStarted;
  bool get isMatchCompleted => type == RefereeScoreEventTypes.matchCompleted;
  bool get isEventUndone => type == RefereeScoreEventTypes.eventUndone;

  int? get overNumber => _nullableInt(data['over_number']);
  int? get ballInOver => _nullableInt(data['ball_in_over']);
  String? get eventCode => _stringValue(data['event_code']);
  bool get isLegalDelivery =>
      data['legal_delivery'] == true || data['legal'] == true;
  int? get strikerUserId => _nullableInt(data['striker_user_id']);
  int? get nonStrikerUserId => _nullableInt(data['non_striker_user_id']);
  int? get bowlerUserId => _nullableInt(data['bowler_user_id']);

  factory RefereeScoreEvent.fromJson(Map<String, dynamic> json) {
    return RefereeScoreEvent(
      type: _stringValue(json['type']) ?? '',
      sequence: _nullableInt(json['sequence']),
      occurredAt: _stringValue(json['occurred_at']),
      data: _mapValue(json['data']),
    );
  }
}

class RefereeScoreTeamTotals {
  const RefereeScoreTeamTotals({
    required this.teamId,
    this.score = 0,
    this.wickets = 0,
    this.legalBalls = 0,
    this.overs,
    this.extras = const {},
  });

  final String teamId;
  final int score;
  final int wickets;
  final int legalBalls;
  final String? overs;
  final Map<String, dynamic> extras;

  String get scoreText => '$score/$wickets';

  factory RefereeScoreTeamTotals.fromJson(String teamId, Object? value) {
    final json = _mapValue(value);
    return RefereeScoreTeamTotals(
      teamId: teamId,
      score: _nullableInt(json['score']) ?? 0,
      wickets: _nullableInt(json['wickets']) ?? 0,
      legalBalls: _nullableInt(json['legal_balls']) ?? 0,
      overs: _stringValue(json['overs']),
      extras: _mapValue(json['extras']),
    );
  }
}

class RefereeScoreRuntimeResponse {
  const RefereeScoreRuntimeResponse({
    this.state,
    this.currentOver,
    this.currentBall,
    this.currentInning,
    this.currentBattingTeamId,
    this.currentBowlingTeamId,
    this.currentBattingTeam = const RefereeScoreTeamRuntime(),
    this.currentBowlingTeam = const RefereeScoreTeamRuntime(),
    this.currentStriker = const RefereeScorePlayerRuntime(),
    this.currentNonStriker = const RefereeScorePlayerRuntime(),
    this.currentBowler = const RefereeScorePlayerRuntime(),
    this.currentWicketKeeper = const RefereeScorePlayerRuntime(),
    this.awaitingBatter = false,
    this.awaitingBowler = false,
    this.inningsComplete = false,
    this.isSuperOver = false,
    this.superOverRound,
    this.dismissedBatters = const [],
    this.currentOverDeliveries = const [],
    this.target,
    this.runsRequired,
    this.events = const [],
    this.lastEvent,
  });

  final String? state;
  final int? currentOver;
  final int? currentBall;
  final int? currentInning;
  final int? currentBattingTeamId;
  final int? currentBowlingTeamId;
  final RefereeScoreTeamRuntime currentBattingTeam;
  final RefereeScoreTeamRuntime currentBowlingTeam;
  final RefereeScorePlayerRuntime currentStriker;
  final RefereeScorePlayerRuntime currentNonStriker;
  final RefereeScorePlayerRuntime currentBowler;
  final RefereeScorePlayerRuntime currentWicketKeeper;
  final bool awaitingBatter;
  final bool awaitingBowler;
  final bool inningsComplete;
  final bool isSuperOver;
  final int? superOverRound;
  final List<int> dismissedBatters;
  final List<Map<String, dynamic>> currentOverDeliveries;
  final int? target;
  final int? runsRequired;
  final List<RefereeScoreEvent> events;
  final RefereeScoreEvent? lastEvent;

  factory RefereeScoreRuntimeResponse.fromJson(Map<String, dynamic> json) {
    final lastEvent = _mapValue(json['last_event']);
    return RefereeScoreRuntimeResponse(
      state: _stringValue(json['state']),
      currentOver: _nullableInt(json['current_over']),
      currentBall: _nullableInt(json['current_ball']),
      currentInning: _nullableInt(json['current_inning']),
      currentBattingTeamId: _nullableInt(json['current_batting_team_id']),
      currentBowlingTeamId: _nullableInt(json['current_bowling_team_id']),
      currentBattingTeam: RefereeScoreTeamRuntime.fromJson(
        _mapValue(json['current_batting_team']),
      ),
      currentBowlingTeam: RefereeScoreTeamRuntime.fromJson(
        _mapValue(json['current_bowling_team']),
      ),
      currentStriker: RefereeScorePlayerRuntime.fromJson(
        _mapValue(json['current_striker']),
      ),
      currentNonStriker: RefereeScorePlayerRuntime.fromJson(
        _mapValue(json['current_non_striker']),
      ),
      currentBowler: RefereeScorePlayerRuntime.fromJson(
        _mapValue(json['current_bowler']),
      ),
      currentWicketKeeper: RefereeScorePlayerRuntime.fromJson(
        _mapValue(json['current_wicket_keeper']),
      ),
      awaitingBatter: json['awaiting_batter'] == true,
      awaitingBowler: json['awaiting_bowler'] == true,
      inningsComplete: json['innings_complete'] == true,
      isSuperOver: json['is_super_over'] == true,
      superOverRound: _nullableInt(json['super_over_round']),
      dismissedBatters: _listValue(json['dismissed_batters'])
          .map((value) => _nullableInt(value))
          .whereType<int>()
          .toList(),
      currentOverDeliveries: _listValue(json['current_over_deliveries'])
          .whereType<Map>()
          .map((item) => Map<String, dynamic>.from(item))
          .toList(),
      target: _nullableInt(json['target']),
      runsRequired: _nullableInt(json['runs_required']),
      events: _listValue(json['events'])
          .whereType<Map>()
          .map((item) => RefereeScoreEvent.fromJson(
                Map<String, dynamic>.from(item),
              ))
          .toList(),
      lastEvent:
          lastEvent.isEmpty ? null : RefereeScoreEvent.fromJson(lastEvent),
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
    this.oversPerInnings,
    this.availableEvents = const [],
    this.runtime = const RefereeScoreRuntimeResponse(),
    this.score = const {},
    this.allowedActions = const [],
    this.nextAction,
  });

  final bool enabled;
  final String? method;
  final String? periodType;
  final int? periodsCount;
  final int? currentPeriod;
  final int? oversPerInnings;
  final List<RefereeScoreEventResponse> availableEvents;
  final RefereeScoreRuntimeResponse runtime;
  final Map<String, dynamic> score;
  final List<String> allowedActions;
  final String? nextAction;

  String? get runtimeState => runtime.state;

  /// Regulation innings totals snapshotted inside `score.super_over`.
  Map<String, int> get regulationTeamScores {
    final superOver = _mapValue(score['super_over']);
    final regulation = _mapValue(superOver['regulation_teams']);
    final result = <String, int>{};
    regulation.forEach((key, value) {
      result[key] = _nullableInt(_mapValue(value)['score']) ?? 0;
    });
    return result;
  }

  bool isActionAllowed(String action) =>
      allowedActions.isEmpty || allowedActions.contains(action);

  /// Runs scored by [teamId] from the authoritative score payload.
  int teamScore(Object teamId) => teamTotals(teamId).score;

  /// Full authoritative totals (score, wickets, overs, extras) for [teamId].
  RefereeScoreTeamTotals teamTotals(Object teamId) {
    final teams = _mapValue(score['teams']);
    return RefereeScoreTeamTotals.fromJson(
      '$teamId',
      teams['$teamId'] ?? teams[teamId],
    );
  }

  factory RefereeScoreStateResponse.fromJson(Map<String, dynamic> json) {
    return RefereeScoreStateResponse(
      enabled: json['enabled'] == true || json['enabled']?.toString() == '1',
      method: _stringValue(json['method']),
      periodType: _stringValue(json['period_type']),
      periodsCount: _nullableInt(json['periods_count']),
      currentPeriod: _nullableInt(json['current_period']),
      oversPerInnings: _nullableInt(
        json['overs_per_innings'] ?? json['overs'] ?? json['total_overs'],
      ),
      availableEvents: _listValue(json['available_events'])
          .whereType<Map>()
          .map((item) => RefereeScoreEventResponse.fromJson(
                Map<String, dynamic>.from(item),
              ))
          .toList(),
      runtime: RefereeScoreRuntimeResponse.fromJson(
        _mapValue(json['runtime']),
      ),
      score: _mapValue(json['score']),
      allowedActions: _listValue(json['allowed_actions'])
          .map((value) => value.toString())
          .toList(),
      nextAction: _stringValue(json['next_action']),
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
    this.tournamentId,
    this.tournamentName,
    this.venueId,
    this.venueName,
    this.venueLocation,
    this.resultStatus,
    this.teams = const [],
    required this.scoring,
    this.toss,
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
  final int? tournamentId;
  final String? tournamentName;
  final int? venueId;
  final String? venueName;
  final String? venueLocation;
  final String? resultStatus;
  final List<RefereeScoreTeamResponse> teams;
  final RefereeScoreStateResponse scoring;
  final RefereeTossStateResponse? toss;
  final Map<String, dynamic> raw;

  String? get statusText {
    final rawStatus = _mapValue(raw['match'])['status'];
    if (rawStatus is String && rawStatus.trim().isNotEmpty) return rawStatus;
    return switch (matchStatus) {
      1 => RefereeMatchStatusLabels.pending,
      2 => RefereeMatchStatusLabels.live,
      3 => RefereeMatchStatusLabels.completed,
      4 => RefereeMatchStatusLabels.cancelled,
      _ => _stringValue(rawStatus),
    };
  }

  bool get isReadOnly =>
      statusText == RefereeMatchStatusLabels.completed ||
      statusText == RefereeMatchStatusLabels.cancelled;
  bool get isLive => statusText == RefereeMatchStatusLabels.live;

  factory RefereeScoreResponse.fromJson(Map<String, dynamic> json) {
    final match = _mapValue(json['match']);
    final sport = _mapValue(json['sport']);
    final format = _mapValue(json['format']);
    final tournament = _mapValue(json['tournament']);
    final schedule = _mapValue(json['schedule']);
    final venue = _mapValue(schedule['venue'] ?? json['venue']);
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
      tournamentId: _nullableInt(tournament['id'] ?? json['tournament_id']),
      tournamentName:
          _stringValue(tournament['name'] ?? json['tournament_name']),
      venueId: _nullableInt(venue['id'] ?? json['venue_id']),
      venueName: _stringValue(venue['name'] ?? venue['venue_name']),
      venueLocation: _stringValue(venue['location']),
      resultStatus: _stringValue(_mapValue(json['result'])['status']),
      teams: _listValue(json['teams'])
          .whereType<Map>()
          .map((item) => RefereeScoreTeamResponse.fromJson(
                Map<String, dynamic>.from(item),
              ))
          .toList(),
      scoring: RefereeScoreStateResponse.fromJson(_mapValue(json['scoring'])),
      toss: _mapValue(json['toss']).isEmpty
          ? null
          : RefereeTossStateResponse.fromJson(_mapValue(json['toss'])),
      raw: Map<String, dynamic>.from(json),
    );
  }
}

class RefereeScoreUpdateRequest {
  const RefereeScoreUpdateRequest._(this.body);

  final Map<String, dynamic> body;

  factory RefereeScoreUpdateRequest.start() {
    return const RefereeScoreUpdateRequest._(
      {'action': RefereeScoreActions.start},
    );
  }

  factory RefereeScoreUpdateRequest.undoLast() {
    return const RefereeScoreUpdateRequest._(
      {'action': RefereeScoreActions.undoLast},
    );
  }

  factory RefereeScoreUpdateRequest.endPeriod() {
    return const RefereeScoreUpdateRequest._(
      {'action': RefereeScoreActions.endPeriod},
    );
  }

  factory RefereeScoreUpdateRequest.complete() {
    return const RefereeScoreUpdateRequest._(
      {'action': RefereeScoreActions.complete},
    );
  }

  factory RefereeScoreUpdateRequest.startSuperOver() {
    return const RefereeScoreUpdateRequest._(
      {'action': RefereeScoreActions.startSuperOver},
    );
  }

  factory RefereeScoreUpdateRequest.setBowler({required int bowlerUserId}) {
    return RefereeScoreUpdateRequest._({
      'action': RefereeScoreActions.setBowler,
      'bowler_user_id': bowlerUserId,
    });
  }

  factory RefereeScoreUpdateRequest.setBatters({
    required int strikerUserId,
    required int nonStrikerUserId,
  }) {
    return RefereeScoreUpdateRequest._({
      'action': RefereeScoreActions.setBatters,
      'striker_user_id': strikerUserId,
      'non_striker_user_id': nonStrikerUserId,
    });
  }

  factory RefereeScoreUpdateRequest.setWicketKeeper({
    required int wicketKeeperUserId,
  }) {
    return RefereeScoreUpdateRequest._({
      'action': RefereeScoreActions.setWicketKeeper,
      'wicket_keeper_user_id': wicketKeeperUserId,
    });
  }

  factory RefereeScoreUpdateRequest.addEvent({
    required String eventCode,
    required int teamId,
    int? playerId,
    int? value,
    String? wicketType,
  }) {
    return RefereeScoreUpdateRequest._({
      'action': RefereeScoreActions.addEvent,
      'event_code': eventCode,
      'team_id': teamId,
      if (playerId != null) 'player_id': playerId,
      if (value != null) 'value': value,
      if (wicketType != null && wicketType.isNotEmpty)
        'wicket_type': wicketType,
    });
  }

  Map<String, dynamic> toJson() => body;
}
