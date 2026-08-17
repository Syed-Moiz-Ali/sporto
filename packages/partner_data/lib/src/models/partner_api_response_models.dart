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
    @JsonKey(name: 'first_name') required String firstName,
    @JsonKey(name: 'last_name') required String lastName,
    required String email,
    @JsonKey(name: 'mobile_number') String? mobileNumber,
    @JsonKey(name: 'date_of_birth') String? dateOfBirth,
    required String gender,
  }) = _PartnerPersonalInformation;

  factory PartnerPersonalInformation.fromJson(Map<String, dynamic> json) =>
      _$PartnerPersonalInformationFromJson(json);
}

@freezed
class PartnerAddress with _$PartnerAddress {
  const factory PartnerAddress({
    @JsonKey(name: 'address_line_1') required String addressLine1,
    @JsonKey(name: 'address_line_2') String? addressLine2,
    required String city,
    String? state,
    required String pincode,
    String? country,
  }) = _PartnerAddress;

  factory PartnerAddress.fromJson(Map<String, dynamic> json) =>
      _$PartnerAddressFromJson(json);
}

@freezed
class PartnerProfessionalInformation with _$PartnerProfessionalInformation {
  const factory PartnerProfessionalInformation({
    @JsonKey(name: 'highest_qualification')
    required String highestQualification,
    @JsonKey(name: 'present_occupation') required String presentOccupation,
  }) = _PartnerProfessionalInformation;

  factory PartnerProfessionalInformation.fromJson(Map<String, dynamic> json) =>
      _$PartnerProfessionalInformationFromJson(json);
}

@freezed
class PartnerApplicationSummary with _$PartnerApplicationSummary {
  const factory PartnerApplicationSummary({
    required int id,
    @JsonKey(name: 'application_number') String? applicationNumber,
    @JsonKey(name: 'application_status') required int applicationStatus,
    required int status,
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
    @JsonKey(name: 'application_number') required String applicationNumber,
    @JsonKey(name: 'application_status') required int applicationStatus,
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
    @JsonKey(name: 'tournament_venues')
    @Default([])
    List<PartnerTournamentVenueResponse> tournamentVenues,
    @JsonKey(name: 'tournament_prizes')
    @Default([])
    List<PartnerTournamentPrizeResponse> tournamentPrizes,
    @JsonKey(name: 'tournament_sponsors')
    @Default([])
    List<PartnerTournamentSponsorResponse> tournamentSponsors,
  }) = _PartnerTournamentResponse;

  PartnerTournamentStatus get workflowStatus =>
      PartnerTournamentStatus.fromValue(status);

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
