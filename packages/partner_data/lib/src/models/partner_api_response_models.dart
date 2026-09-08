// ignore_for_file: invalid_annotation_target

import 'package:freezed_annotation/freezed_annotation.dart';

part 'partner_api_response_models.freezed.dart';
part 'partner_api_response_models.g.dart';

int _intFromJson(Object? value) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse(value?.toString() ?? '') ?? 0;
}

int? _nullableIntFromJson(Object? value) {
  if (value == null) return null;
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse(value.toString());
}

String? _nullableStringFromJson(Object? value) => value?.toString();

String _stringFromJson(Object? value) => value?.toString() ?? '';

Object? _readDocumentPath(Map json, String key) {
  return json['document_path'] ?? json['document_url'];
}

Object? _readRegisteredTeams(Map map, String key) {
  if (map['registered_teams'] != null) return map['registered_teams'];
  if (map['registration_summary'] is Map) {
    return map['registration_summary']['registered_teams'];
  }
  return null;
}

Object? _readVenues(Map map, String key) {
  return map['tournament_venues'] ?? map['venues'];
}

Object? _readPrizes(Map map, String key) {
  return map['tournament_prizes'] ?? map['prizes'];
}

Object? _readSponsors(Map map, String key) {
  return map['tournament_sponsors'] ?? map['sponsors'];
}

enum PartnerTournamentStatus {
  draft(1, 'Draft'),
  published(2, 'Published'),
  registrationOpen(3, 'Registration Open'),
  registrationClosed(4, 'Registration Closed'),
  checkIn(5, 'Check In'),
  inProgress(6, 'In Progress'),
  completed(7, 'Completed'),
  cancelled(8, 'Cancelled'),
  archived(9, 'Archived');

  const PartnerTournamentStatus(this.value, this.label);

  final int value;
  final String label;

  static PartnerTournamentStatus fromValue(int value) {
    return PartnerTournamentStatus.values.firstWhere(
      (status) => status.value == value,
      orElse: () => PartnerTournamentStatus.draft,
    );
  }
}

enum PartnerTournamentApprovalStatus {
  pending(2, 'Pending Approval'),
  approved(4, 'Approved'),
  rejected(5, 'Rejected');

  const PartnerTournamentApprovalStatus(this.value, this.label);

  final int value;
  final String label;

  static PartnerTournamentApprovalStatus? fromValue(int? value) {
    if (value == null) return null;
    return PartnerTournamentApprovalStatus.values.firstWhere(
      (status) => status.value == value,
      orElse: () => PartnerTournamentApprovalStatus.pending,
    );
  }
}

enum PartnerTournamentVisibility {
  public(1, 'Public'),
  private(2, 'Private'),
  inviteOnly(3, 'Invite Only');

  const PartnerTournamentVisibility(this.value, this.label);

  final int value;
  final String label;

  static PartnerTournamentVisibility fromValue(int? value) {
    return PartnerTournamentVisibility.values.firstWhere(
      (v) => v.value == value,
      orElse: () => PartnerTournamentVisibility.public,
    );
  }
}

enum PartnerApplicationWorkflowStatus {
  draft(1, 'Draft'),
  published(2, 'Published'),
  registrationOpen(3, 'Registration Open'),
  registrationClosed(4, 'Registration Closed'),
  checkIn(5, 'Check In'),
  inProgress(6, 'In Progress'),
  completed(7, 'Completed'),
  cancelled(8, 'Cancelled'),
  archived(9, 'Archived');

  const PartnerApplicationWorkflowStatus(this.value, this.label);

  final int value;
  final String label;

  static PartnerApplicationWorkflowStatus fromValue(int value) {
    return PartnerApplicationWorkflowStatus.values.firstWhere(
      (status) => status.value == value,
      orElse: () => PartnerApplicationWorkflowStatus.draft,
    );
  }
}

@freezed
class PartnerProfileResponseData with _$PartnerProfileResponseData {
  const factory PartnerProfileResponseData({
    @JsonKey(name: 'personal_information')
    required PartnerPersonalInformation personalInformation,
    required PartnerAddress address,
    @JsonKey(name: 'professional_information')
    required PartnerProfessionalInformation professionalInformation,
    required PartnerApplicationSummary application,
  }) = _PartnerProfileResponseData;

  factory PartnerProfileResponseData.fromJson(Map<String, dynamic> json) =>
      _$PartnerProfileResponseDataFromJson(json);
}

@freezed
class PartnerPersonalInformation with _$PartnerPersonalInformation {
  const factory PartnerPersonalInformation({
    @JsonKey(name: 'first_name') String? firstName,
    @JsonKey(name: 'last_name') String? lastName,
    String? email,
    @JsonKey(name: 'mobile_number') String? mobileNumber,
    @JsonKey(name: 'date_of_birth') String? dateOfBirth,
    String? gender,
  }) = _PartnerPersonalInformation;

  factory PartnerPersonalInformation.fromJson(Map<String, dynamic> json) =>
      _$PartnerPersonalInformationFromJson(json);
}

@freezed
class PartnerAddress with _$PartnerAddress {
  const factory PartnerAddress({
    @JsonKey(name: 'address_line_1') String? addressLine1,
    @JsonKey(name: 'address_line_2') String? addressLine2,
    String? city,
    String? state,
    String? pincode,
    String? country,
  }) = _PartnerAddress;

  factory PartnerAddress.fromJson(Map<String, dynamic> json) =>
      _$PartnerAddressFromJson(json);
}

@freezed
class PartnerProfessionalInformation with _$PartnerProfessionalInformation {
  const factory PartnerProfessionalInformation({
    @JsonKey(name: 'highest_qualification') String? highestQualification,
    @JsonKey(name: 'present_occupation') String? presentOccupation,
  }) = _PartnerProfessionalInformation;

  factory PartnerProfessionalInformation.fromJson(Map<String, dynamic> json) =>
      _$PartnerProfessionalInformationFromJson(json);
}

@freezed
class PartnerApplicationSummary with _$PartnerApplicationSummary {
  const factory PartnerApplicationSummary({
    @JsonKey(fromJson: _intFromJson) required int id,
    @JsonKey(name: 'application_number') String? applicationNumber,
    @JsonKey(name: 'application_status', fromJson: _intFromJson)
    required int applicationStatus,
    @JsonKey(fromJson: _intFromJson) required int status,
  }) = _PartnerApplicationSummary;

  factory PartnerApplicationSummary.fromJson(Map<String, dynamic> json) =>
      _$PartnerApplicationSummaryFromJson(json);
}

@freezed
class SportMasterResponse with _$SportMasterResponse {
  const factory SportMasterResponse({
    required int id,
    required String name,
    required String code,
    required String slug,
    required String description,
    @JsonKey(name: 'icon_path') String? iconPath,
    int? status,
    @JsonKey(name: 'display_order') required int displayOrder,
    @JsonKey(name: 'created_at') String? createdAt,
    @JsonKey(name: 'updated_at') String? updatedAt,
    @JsonKey(name: 'deleted_at') String? deletedAt,
  }) = _SportMasterResponse;

  factory SportMasterResponse.fromJson(Map<String, dynamic> json) =>
      _$SportMasterResponseFromJson(json);
}

@freezed
class PartnerSportResponse with _$PartnerSportResponse {
  const factory PartnerSportResponse({
    required int id,
    @JsonKey(name: 'partner_profile_id') int? partnerProfileId,
    @JsonKey(name: 'sport_id') required int sportId,
    @JsonKey(name: 'sport_name') String? sportName,
    @JsonKey(name: 'experience_years') required int experienceYears,
    @JsonKey(name: 'created_at') String? createdAt,
    @JsonKey(name: 'updated_at') String? updatedAt,
  }) = _PartnerSportResponse;

  factory PartnerSportResponse.fromJson(Map<String, dynamic> json) =>
      _$PartnerSportResponseFromJson(json);
}

@freezed
class PartnerDocumentResponse with _$PartnerDocumentResponse {
  const factory PartnerDocumentResponse({
    required int id,
    @JsonKey(name: 'partner_profile_id', fromJson: _nullableIntFromJson)
    int? partnerProfileId,
    @JsonKey(name: 'document_type') required String documentType,
    @JsonKey(
      name: 'document_path',
      readValue: _readDocumentPath,
      fromJson: _stringFromJson,
    )
    required String documentPath,
    @JsonKey(name: 'verification_status', fromJson: _intFromJson)
    required int verificationStatus,
    @JsonKey(name: 'rejection_reason') String? rejectionReason,
    @JsonKey(name: 'created_at') String? createdAt,
    @JsonKey(name: 'updated_at') String? updatedAt,
  }) = _PartnerDocumentResponse;

  factory PartnerDocumentResponse.fromJson(Map<String, dynamic> json) =>
      _$PartnerDocumentResponseFromJson(json);
}

@freezed
class PartnerApplicationStateResponse with _$PartnerApplicationStateResponse {
  const factory PartnerApplicationStateResponse({
    @JsonKey(name: 'application_number') String? applicationNumber,
    @JsonKey(name: 'application_status') required int applicationStatus,
    @JsonKey(name: 'can_submit') required bool canSubmit,
    @JsonKey(name: 'personal_information')
    required PartnerPersonalInformation personalInformation,
    required PartnerAddress address,
    @JsonKey(name: 'professional_information')
    required PartnerProfessionalInformation professionalInformation,
    required List<PartnerSportResponse> sports,
    required List<PartnerDocumentResponse> documents,
    required List<dynamic> timeline,
  }) = _PartnerApplicationStateResponse;

  factory PartnerApplicationStateResponse.fromJson(Map<String, dynamic> json) =>
      _$PartnerApplicationStateResponseFromJson(json);
}

@freezed
class PartnerApplicationSubmitResponse with _$PartnerApplicationSubmitResponse {
  const factory PartnerApplicationSubmitResponse({
    @JsonKey(name: 'application_number') String? applicationNumber,
    @JsonKey(name: 'application_status', fromJson: _intFromJson)
    required int applicationStatus,
  }) = _PartnerApplicationSubmitResponse;

  factory PartnerApplicationSubmitResponse.fromJson(
    Map<String, dynamic> json,
  ) =>
      _$PartnerApplicationSubmitResponseFromJson(json);
}

@freezed
class TournamentTypeResponse with _$TournamentTypeResponse {
  const factory TournamentTypeResponse({
    required int id,
    required String name,
    required String code,
    required String slug,
    required String description,
    @JsonKey(name: 'display_order') required int displayOrder,
    required int status,
    @JsonKey(name: 'created_at') required String createdAt,
    @JsonKey(name: 'updated_at') required String updatedAt,
    @JsonKey(name: 'deleted_at') String? deletedAt,
  }) = _TournamentTypeResponse;

  factory TournamentTypeResponse.fromJson(Map<String, dynamic> json) =>
      _$TournamentTypeResponseFromJson(json);
}

@freezed
class SportFormatResponse with _$SportFormatResponse {
  const factory SportFormatResponse({
    required int id,
    @JsonKey(name: 'sport_id') required int sportId,
    required String name,
    required String slug,
    required String description,
    required int status,
    @JsonKey(name: 'created_at') required String createdAt,
    @JsonKey(name: 'updated_at') required String updatedAt,
    @JsonKey(name: 'deleted_at') String? deletedAt,
  }) = _SportFormatResponse;

  factory SportFormatResponse.fromJson(Map<String, dynamic> json) =>
      _$SportFormatResponseFromJson(json);
}

@freezed
class TournamentFormConfigFieldResponse
    with _$TournamentFormConfigFieldResponse {
  const factory TournamentFormConfigFieldResponse({
    @JsonKey(name: 'sport_rule_field_id') required int sportRuleFieldId,
    required String key,
    required String name,
    required int category,
    required int type,
    required bool required,
    @JsonKey(name: 'validation_rules') String? validationRules,
    @JsonKey(name: 'master_default_value') String? masterDefaultValue,
    @JsonKey(name: 'display_order') required int displayOrder,
  }) = _TournamentFormConfigFieldResponse;

  factory TournamentFormConfigFieldResponse.fromJson(
    Map<String, dynamic> json,
  ) =>
      _$TournamentFormConfigFieldResponseFromJson(json);
}

class TournamentPrizeCategoryResponse {
  const TournamentPrizeCategoryResponse({
    required this.id,
    required this.name,
    required this.slug,
    this.description,
    required this.displayOrder,
  });

  final int id;
  final String name;
  final String slug;
  final String? description;
  final int displayOrder;

  factory TournamentPrizeCategoryResponse.fromJson(
    Map<String, dynamic> json,
  ) {
    return TournamentPrizeCategoryResponse(
      id: _intFromJson(json['id']),
      name: _stringFromJson(json['name']),
      slug: _stringFromJson(json['slug']),
      description: _nullableStringFromJson(json['description']),
      displayOrder: _intFromJson(json['display_order']),
    );
  }
}

@freezed
class PartnerTournamentResponse with _$PartnerTournamentResponse {
  const PartnerTournamentResponse._();

  const factory PartnerTournamentResponse({
    required int id,
    @JsonKey(name: 'organization_id', fromJson: _nullableIntFromJson)
    int? organizationId,
    @JsonKey(name: 'partner_profile_id', fromJson: _nullableIntFromJson)
    int? partnerProfileId,
    @JsonKey(name: 'sport_id', fromJson: _intFromJson) required int sportId,
    @JsonKey(name: 'sport_format_id', fromJson: _intFromJson)
    required int sportFormatId,
    @JsonKey(name: 'tournament_type_id', fromJson: _intFromJson)
    required int tournamentTypeId,
    @JsonKey(name: 'venue_id', fromJson: _nullableIntFromJson) int? venueId,
    required String name,
    String? code,
    String? slug,
    String? description,
    @JsonKey(name: 'registration_start_at') String? registrationStartAt,
    @JsonKey(name: 'registration_end_at') String? registrationEndAt,
    @JsonKey(name: 'tournament_start_at') String? tournamentStartAt,
    @JsonKey(name: 'tournament_end_at') String? tournamentEndAt,
    @JsonKey(name: 'minimum_teams', fromJson: _nullableIntFromJson)
    int? minimumTeams,
    @JsonKey(name: 'maximum_teams', fromJson: _nullableIntFromJson)
    int? maximumTeams,
    @JsonKey(fromJson: _nullableIntFromJson) int? visibility,
    @JsonKey(name: 'contact_name') String? contactName,
    @JsonKey(name: 'contact_email') String? contactEmail,
    @JsonKey(name: 'contact_phone') String? contactPhone,
    String? timezone,
    @JsonKey(name: 'registration_fee', fromJson: _nullableStringFromJson)
    String? registrationFee,
    String? currency,
    @JsonKey(name: 'logo_path') String? logoPath,
    @JsonKey(name: 'banner_path') String? bannerPath,
    @JsonKey(name: 'display_order', fromJson: _nullableIntFromJson)
    int? displayOrder,
    @JsonKey(fromJson: _intFromJson) required int status,
    @JsonKey(name: 'created_at') String? createdAt,
    @JsonKey(name: 'updated_at') String? updatedAt,
    @JsonKey(name: 'deleted_at') String? deletedAt,
    @JsonKey(name: 'approval_status', fromJson: _nullableIntFromJson)
    int? approvalStatus,
    @JsonKey(
      name: 'registered_teams',
      readValue: _readRegisteredTeams,
      fromJson: _nullableIntFromJson,
    )
    int? registeredTeams,
    @JsonKey(name: 'total_prize_money', fromJson: _nullableStringFromJson)
    String? totalPrizeMoney,
    SportMasterResponse? sport,
    @JsonKey(name: 'sport_format') SportFormatResponse? sportFormat,
    @JsonKey(name: 'tournament_type') TournamentTypeResponse? tournamentType,
    @JsonKey(name: 'tournament_venues', readValue: _readVenues)
    @Default([])
    List<PartnerTournamentVenueResponse> tournamentVenues,
    @JsonKey(name: 'tournament_prizes', readValue: _readPrizes)
    @Default([])
    List<PartnerTournamentPrizeResponse> tournamentPrizes,
    @JsonKey(name: 'tournament_sponsors', readValue: _readSponsors)
    @Default([])
    List<PartnerTournamentSponsorResponse> tournamentSponsors,
  }) = _PartnerTournamentResponse;

  PartnerTournamentStatus get workflowStatus =>
      PartnerTournamentStatus.fromValue(status);

  PartnerTournamentApprovalStatus? get parsedApprovalStatus =>
      PartnerTournamentApprovalStatus.fromValue(approvalStatus);

  PartnerTournamentVisibility get parsedVisibility =>
      PartnerTournamentVisibility.fromValue(visibility);

  factory PartnerTournamentResponse.fromJson(Map<String, dynamic> json) =>
      _$PartnerTournamentResponseFromJson(json);
}

@freezed
class PartnerTournamentVenueResponse with _$PartnerTournamentVenueResponse {
  const factory PartnerTournamentVenueResponse({
    required int id,
    @JsonKey(name: 'tournament_id', fromJson: _nullableIntFromJson)
    int? tournamentId,
    @JsonKey(name: 'venue_name') required String venueName,
    String? location,
    @JsonKey(name: 'daily_match_capacity', fromJson: _nullableIntFromJson)
    int? dailyMatchCapacity,
    @JsonKey(name: 'ground_type') String? groundType,
    String? date,
    @JsonKey(name: 'start_time') String? startTime,
    @JsonKey(name: 'round_name') String? roundName,
    @JsonKey(name: 'display_order', fromJson: _nullableIntFromJson)
    int? displayOrder,
    @JsonKey(fromJson: _nullableIntFromJson) int? status,
    @JsonKey(name: 'created_at') String? createdAt,
    @JsonKey(name: 'updated_at') String? updatedAt,
    @JsonKey(name: 'deleted_at') String? deletedAt,
  }) = _PartnerTournamentVenueResponse;

  factory PartnerTournamentVenueResponse.fromJson(Map<String, dynamic> json) =>
      _$PartnerTournamentVenueResponseFromJson(json);
}

@freezed
class PartnerTournamentPrizeResponse with _$PartnerTournamentPrizeResponse {
  const factory PartnerTournamentPrizeResponse({
    required int id,
    @JsonKey(name: 'tournament_id', fromJson: _nullableIntFromJson)
    int? tournamentId,
    required String category,
    required String title,
    @JsonKey(fromJson: _stringFromJson) required String amount,
    String? currency,
    @JsonKey(name: 'display_order', fromJson: _nullableIntFromJson)
    int? displayOrder,
    @JsonKey(fromJson: _nullableIntFromJson) int? status,
    @JsonKey(name: 'created_at') String? createdAt,
    @JsonKey(name: 'updated_at') String? updatedAt,
    @JsonKey(name: 'deleted_at') String? deletedAt,
  }) = _PartnerTournamentPrizeResponse;

  factory PartnerTournamentPrizeResponse.fromJson(Map<String, dynamic> json) =>
      _$PartnerTournamentPrizeResponseFromJson(json);
}

@freezed
class PartnerTournamentSponsorResponse with _$PartnerTournamentSponsorResponse {
  const factory PartnerTournamentSponsorResponse({
    required int id,
    @JsonKey(name: 'tournament_id', fromJson: _nullableIntFromJson)
    int? tournamentId,
    @JsonKey(name: 'sponsor_type') required String sponsorType,
    required String name,
    @JsonKey(name: 'contribution_amount', fromJson: _stringFromJson)
    required String contributionAmount,
    String? currency,
    @JsonKey(name: 'logo_path') String? logoPath,
    @JsonKey(name: 'website_url') String? websiteUrl,
    @JsonKey(name: 'display_order', fromJson: _nullableIntFromJson)
    int? displayOrder,
    @JsonKey(fromJson: _nullableIntFromJson) int? status,
    @JsonKey(name: 'created_at') String? createdAt,
    @JsonKey(name: 'updated_at') String? updatedAt,
    @JsonKey(name: 'deleted_at') String? deletedAt,
  }) = _PartnerTournamentSponsorResponse;

  factory PartnerTournamentSponsorResponse.fromJson(
    Map<String, dynamic> json,
  ) =>
      _$PartnerTournamentSponsorResponseFromJson(json);
}

@freezed
class PartnerTournamentReviewData with _$PartnerTournamentReviewData {
  const factory PartnerTournamentReviewData({
    required PartnerTournamentResponse tournament,
    @JsonKey(name: 'financial_summary')
    required PartnerFinancialSummary financialSummary,
    @JsonKey(name: 'can_submit') required bool canSubmit,
  }) = _PartnerTournamentReviewData;

  factory PartnerTournamentReviewData.fromJson(Map<String, dynamic> json) =>
      _$PartnerTournamentReviewDataFromJson(json);
}

@freezed
class PartnerFinancialSummary with _$PartnerFinancialSummary {
  const factory PartnerFinancialSummary({
    @JsonKey(name: 'estimated_collection', fromJson: _intFromJson)
    required int estimatedCollection,
    @JsonKey(name: 'total_prize_money', fromJson: _stringFromJson)
    required String totalPrizeMoney,
    @JsonKey(name: 'platform_fee_percentage', fromJson: _intFromJson)
    required int platformFeePercentage,
    @JsonKey(name: 'platform_fee_amount', fromJson: _intFromJson)
    required int platformFeeAmount,
    @JsonKey(name: 'net_earnings', fromJson: _intFromJson)
    required int netEarnings,
    required String currency,
  }) = _PartnerFinancialSummary;

  factory PartnerFinancialSummary.fromJson(Map<String, dynamic> json) =>
      _$PartnerFinancialSummaryFromJson(json);
}

class PartnerRefereeResponse {
  const PartnerRefereeResponse({
    required this.id,
    required this.name,
    this.profilePhotoUrl,
    this.status,
  });

  final int id;
  final String name;
  final String? profilePhotoUrl;
  final String? status;

  bool get isActive => status?.toLowerCase() == 'active';

  factory PartnerRefereeResponse.fromJson(Map<String, dynamic> json) {
    return PartnerRefereeResponse(
      id: _intFromJson(json['id']),
      name: _stringFromJson(json['name']),
      profilePhotoUrl: _nullableStringFromJson(json['profile_photo_url']),
      status: _nullableStringFromJson(json['status']),
    );
  }
}

class PartnerTournamentMatchResponse {
  const PartnerTournamentMatchResponse({
    required this.id,
    this.tournamentId,
    this.roundName,
    this.matchNumber,
    this.matchDate,
    this.startTime,
    this.venueName,
    this.location,
    this.status,
    this.teamAName,
    this.teamBName,
    this.raw = const {},
  });

  final int id;
  final int? tournamentId;
  final String? roundName;
  final String? matchNumber;
  final String? matchDate;
  final String? startTime;
  final String? venueName;
  final String? location;
  final int? status;
  final String? teamAName;
  final String? teamBName;
  final Map<String, dynamic> raw;

  String get displayRound =>
      _firstText([roundName, raw['round'], raw['stage'], raw['name']]) ??
      'Match';

  String get displayTime =>
      _firstText([matchDate, startTime, raw['scheduled_at'], raw['date']]) ??
      '';

  String get displayVenue =>
      _firstText([venueName, location, raw['venue'], raw['ground']]) ??
      'Venue not set';

  String get displayTeamA =>
      _firstText([teamAName, raw['team_a'], raw['home_team']]) ?? 'Team A';

  String get displayTeamB =>
      _firstText([teamBName, raw['team_b'], raw['away_team']]) ?? 'Team B';

  factory PartnerTournamentMatchResponse.fromJson(Map<String, dynamic> json) {
    final teamA = _readNestedName(json, const [
      'team_a',
      'team1',
      'home_team',
      'first_team',
    ]);
    final teamB = _readNestedName(json, const [
      'team_b',
      'team2',
      'away_team',
      'second_team',
    ]);
    final venue = json['venue'];
    final venueMap = venue is Map ? Map<String, dynamic>.from(venue) : null;
    return PartnerTournamentMatchResponse(
      id: _intFromJson(json['id'] ?? json['match_id']),
      tournamentId: _nullableIntFromJson(json['tournament_id']),
      roundName: _nullableStringFromJson(
        json['round_name'] ?? json['round'] ?? json['stage'],
      ),
      matchNumber: _nullableStringFromJson(
        json['match_number'] ?? json['code'] ?? json['fixture_code'],
      ),
      matchDate: _nullableStringFromJson(
        json['match_date'] ?? json['date'] ?? json['scheduled_date'],
      ),
      startTime: _nullableStringFromJson(
        json['start_time'] ?? json['time'] ?? json['scheduled_at'],
      ),
      venueName: _nullableStringFromJson(
        json['venue_name'] ?? venueMap?['venue_name'] ?? venueMap?['name'],
      ),
      location: _nullableStringFromJson(
        json['location'] ?? venueMap?['location'] ?? venueMap?['address'],
      ),
      status: _nullableIntFromJson(json['status']),
      teamAName: teamA,
      teamBName: teamB,
      raw: Map<String, dynamic>.from(json),
    );
  }
}

class PartnerEligibleRefereeResponse {
  const PartnerEligibleRefereeResponse({
    required this.id,
    this.name,
    this.mobileNumber,
    this.sportName,
    this.level,
    this.rating,
    this.matches,
    this.assignedMatches,
    this.available,
    this.status,
    this.conflict,
    this.raw = const {},
  });

  final int id;
  final String? name;
  final String? mobileNumber;
  final String? sportName;
  final int? level;
  final double? rating;
  final int? matches;
  final int? assignedMatches;
  final bool? available;
  final String? status;
  final String? conflict;
  final Map<String, dynamic> raw;

  String get displayName => name?.trim().isNotEmpty == true ? name! : 'Referee';
  String get displayStatus =>
      status ?? (available == false ? 'Busy' : 'Available Now');
  String get displaySport => sportName ?? 'Cricket';

  factory PartnerEligibleRefereeResponse.fromJson(Map<String, dynamic> json) {
    final user = json['user'];
    final profile = json['profile'];
    final userMap = user is Map ? Map<String, dynamic>.from(user) : null;
    final profileMap =
        profile is Map ? Map<String, dynamic>.from(profile) : null;
    final sport = json['sport'];
    final sportMap = sport is Map ? Map<String, dynamic>.from(sport) : null;
    final fullName = _firstText([
      json['name'],
      json['full_name'],
      json['referee_name'],
      userMap?['name'],
      userMap?['full_name'],
      profileMap?['full_name'],
      [
        profileMap?['first_name'],
        profileMap?['last_name'],
      ].whereType<Object>().join(' '),
    ]);
    return PartnerEligibleRefereeResponse(
      id: _intFromJson(json['id'] ?? json['referee_id'] ?? userMap?['id']),
      name: fullName,
      mobileNumber: _nullableStringFromJson(
        json['mobile_number'] ?? userMap?['mobile_number'],
      ),
      sportName: _nullableStringFromJson(
        json['sport_name'] ?? sportMap?['name'],
      ),
      level: _nullableIntFromJson(
        json['level'] ?? json['referee_level'] ?? json['experience_level'],
      ),
      rating: _nullableDoubleFromJson(json['rating'] ?? json['avg_rating']),
      matches: _nullableIntFromJson(
        json['matches'] ?? json['match_count'] ?? json['total_matches'],
      ),
      assignedMatches: _nullableIntFromJson(
        json['assigned_matches'] ?? json['assigned_match_count'],
      ),
      available:
          _nullableBoolFromJson(json['available'] ?? json['is_available']),
      status: _nullableStringFromJson(json['status_label'] ?? json['status']),
      conflict: _nullableStringFromJson(
        json['conflict'] ?? json['conflict_reason'],
      ),
      raw: Map<String, dynamic>.from(json),
    );
  }
}

class PartnerMatchRefereeAssignmentResponse {
  const PartnerMatchRefereeAssignmentResponse({
    required this.id,
    this.tournamentId,
    this.matchId,
    this.refereeId,
    this.refereeName,
    this.role,
    this.notes,
    this.status,
    this.raw = const {},
  });

  final int id;
  final int? tournamentId;
  final int? matchId;
  final int? refereeId;
  final String? refereeName;
  final String? role;
  final String? notes;
  final int? status;
  final Map<String, dynamic> raw;

  String get displayName => refereeName ?? 'Assigned referee';
  String get displayRole => role ?? 'Main Referee';

  factory PartnerMatchRefereeAssignmentResponse.fromJson(
    Map<String, dynamic> json,
  ) {
    final referee = json['referee'];
    final refereeMap =
        referee is Map ? Map<String, dynamic>.from(referee) : null;
    return PartnerMatchRefereeAssignmentResponse(
      id: _intFromJson(json['id'] ?? json['assignment_id']),
      tournamentId: _nullableIntFromJson(json['tournament_id']),
      matchId: _nullableIntFromJson(json['match_id']),
      refereeId: _nullableIntFromJson(json['referee_id'] ?? refereeMap?['id']),
      refereeName: _firstText([
        json['referee_name'],
        json['name'],
        refereeMap?['name'],
        refereeMap?['full_name'],
      ]),
      role: _nullableStringFromJson(json['role']),
      notes: _nullableStringFromJson(json['notes']),
      status: _nullableIntFromJson(json['status']),
      raw: Map<String, dynamic>.from(json),
    );
  }
}

class PartnerMatchRefereeAssignmentRequest {
  const PartnerMatchRefereeAssignmentRequest({
    required this.refereeId,
    this.role = 'Main Referee',
    this.notes,
  });

  final int refereeId;
  final String role;
  final String? notes;

  Map<String, dynamic> toJson() => {
        'referee_id': refereeId,
        'role': role,
        if (notes != null && notes!.trim().isNotEmpty) 'notes': notes,
      };
}

class PartnerMatchRefereeAssignmentUpdateRequest {
  const PartnerMatchRefereeAssignmentUpdateRequest({
    this.role,
    this.status,
    this.notes,
  });

  final String? role;
  final int? status;
  final String? notes;

  Map<String, dynamic> toJson() => {
        if (role != null) 'role': role,
        if (status != null) 'status': status,
        if (notes != null) 'notes': notes,
      };
}

double? _nullableDoubleFromJson(Object? value) {
  if (value == null) return null;
  if (value is num) return value.toDouble();
  return double.tryParse(value.toString());
}

bool? _nullableBoolFromJson(Object? value) {
  if (value == null) return null;
  if (value is bool) return value;
  if (value is num) return value != 0;
  final text = value.toString().toLowerCase();
  if (text == 'true' || text == 'yes' || text == 'available') return true;
  if (text == 'false' || text == 'no' || text == 'busy') return false;
  return null;
}

String? _firstText(Iterable<Object?> values) {
  for (final value in values) {
    if (value == null) continue;
    if (value is Map) {
      final nested =
          _firstText([value['name'], value['full_name'], value['title']]);
      if (nested != null) return nested;
      continue;
    }
    final text = value.toString().trim();
    if (text.isNotEmpty && text != 'null') return text;
  }
  return null;
}

String? _readNestedName(Map<String, dynamic> json, List<String> keys) {
  for (final key in keys) {
    final value = json[key];
    if (value is Map) {
      final name =
          _firstText([value['name'], value['full_name'], value['title']]);
      if (name != null) return name;
    } else {
      final text = _firstText([value]);
      if (text != null) return text;
    }
  }
  return null;
}
