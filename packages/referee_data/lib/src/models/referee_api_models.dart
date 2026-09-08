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
