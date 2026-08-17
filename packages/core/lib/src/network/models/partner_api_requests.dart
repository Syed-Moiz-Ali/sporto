// ignore_for_file: invalid_annotation_target

import 'package:freezed_annotation/freezed_annotation.dart';

part 'partner_api_requests.freezed.dart';
part 'partner_api_requests.g.dart';

@freezed
class SendOtpRequest with _$SendOtpRequest {
  const factory SendOtpRequest({
    @JsonKey(name: 'mobile_number') required String mobileNumber,
  }) = _SendOtpRequest;

  factory SendOtpRequest.fromJson(Map<String, dynamic> json) =>
      _$SendOtpRequestFromJson(json);
}

@freezed
class VerifyOtpRequest with _$VerifyOtpRequest {
  const factory VerifyOtpRequest({
    @JsonKey(name: 'mobile_number') required String mobileNumber,
    required String otp,
    @JsonKey(name: 'session_key') required String sessionKey,
    @JsonKey(name: 'device_id') required String deviceId,
  }) = _VerifyOtpRequest;

  factory VerifyOtpRequest.fromJson(Map<String, dynamic> json) =>
      _$VerifyOtpRequestFromJson(json);
}

@freezed
class PartnerProfileRequest with _$PartnerProfileRequest {
  const factory PartnerProfileRequest({
    @JsonKey(name: 'first_name') required String firstName,
    @JsonKey(name: 'last_name') required String lastName,
    required String email,
    @JsonKey(name: 'date_of_birth') required String dateOfBirth,
    required String gender,
    @JsonKey(name: 'address_line_1') required String addressLine1,
    @JsonKey(name: 'address_line_2') required String addressLine2,
    required String city,
    required String state,
    required String country,
    required String pincode,
    @JsonKey(name: 'highest_qualification')
    required String highestQualification,
    @JsonKey(name: 'present_occupation') required String presentOccupation,
  }) = _PartnerProfileRequest;

  factory PartnerProfileRequest.fromJson(Map<String, dynamic> json) =>
      _$PartnerProfileRequestFromJson(json);
}

@freezed
class PartnerProfileUpdateRequest with _$PartnerProfileUpdateRequest {
  @JsonSerializable(includeIfNull: false)
  const factory PartnerProfileUpdateRequest({
    @JsonKey(name: 'first_name') String? firstName,
    @JsonKey(name: 'last_name') String? lastName,
    String? email,
    @JsonKey(name: 'date_of_birth') String? dateOfBirth,
    String? gender,
    @JsonKey(name: 'address_line_1') String? addressLine1,
    @JsonKey(name: 'address_line_2') String? addressLine2,
    String? city,
    String? state,
    String? country,
    String? pincode,
    @JsonKey(name: 'highest_qualification') String? highestQualification,
    @JsonKey(name: 'present_occupation') String? presentOccupation,
  }) = _PartnerProfileUpdateRequest;

  factory PartnerProfileUpdateRequest.fromJson(Map<String, dynamic> json) =>
      _$PartnerProfileUpdateRequestFromJson(json);
}

@freezed
class PartnerAddSportsRequest with _$PartnerAddSportsRequest {
  const factory PartnerAddSportsRequest({
    @JsonKey(name: 'sport_ids') required List<int> sportIds,
    @JsonKey(name: 'experience_years') required int experienceYears,
  }) = _PartnerAddSportsRequest;

  factory PartnerAddSportsRequest.fromJson(Map<String, dynamic> json) =>
      _$PartnerAddSportsRequestFromJson(json);
}

@freezed
class PartnerUpdateSportRequest with _$PartnerUpdateSportRequest {
  const factory PartnerUpdateSportRequest({
    @JsonKey(name: 'experience_years') required int experienceYears,
  }) = _PartnerUpdateSportRequest;

  factory PartnerUpdateSportRequest.fromJson(Map<String, dynamic> json) =>
      _$PartnerUpdateSportRequestFromJson(json);
}

@freezed
class PartnerDocumentRequest with _$PartnerDocumentRequest {
  const factory PartnerDocumentRequest({
    @JsonKey(name: 'document_type') required String documentType,
    @JsonKey(name: 'document_path') required String documentPath,
  }) = _PartnerDocumentRequest;

  factory PartnerDocumentRequest.fromJson(Map<String, dynamic> json) =>
      _$PartnerDocumentRequestFromJson(json);
}

@freezed
class PartnerApplicationSubmitRequest with _$PartnerApplicationSubmitRequest {
  const factory PartnerApplicationSubmitRequest({
    required bool confirmation,
  }) = _PartnerApplicationSubmitRequest;

  factory PartnerApplicationSubmitRequest.fromJson(Map<String, dynamic> json) =>
      _$PartnerApplicationSubmitRequestFromJson(json);
}

@freezed
class TournamentDraftRequest with _$TournamentDraftRequest {
  const factory TournamentDraftRequest({
    @JsonKey(name: 'sport_id') required int sportId,
    @JsonKey(name: 'sport_format_id') required int sportFormatId,
    @JsonKey(name: 'tournament_type_id') required int tournamentTypeId,
  }) = _TournamentDraftRequest;

  factory TournamentDraftRequest.fromJson(Map<String, dynamic> json) =>
      _$TournamentDraftRequestFromJson(json);
}

@freezed
class TournamentDetailsRequest with _$TournamentDetailsRequest {
  const factory TournamentDetailsRequest({
    required String name,
    @JsonKey(name: 'registration_end_at') required String registrationEndAt,
  }) = _TournamentDetailsRequest;

  factory TournamentDetailsRequest.fromJson(Map<String, dynamic> json) =>
      _$TournamentDetailsRequestFromJson(json);
}

@freezed
class TournamentRuleRequest with _$TournamentRuleRequest {
  const factory TournamentRuleRequest({
    required List<TournamentRuleValueRequest> rules,
  }) = _TournamentRuleRequest;

  factory TournamentRuleRequest.fromJson(Map<String, dynamic> json) =>
      _$TournamentRuleRequestFromJson(json);
}

@freezed
class TournamentRuleValueRequest with _$TournamentRuleValueRequest {
  const factory TournamentRuleValueRequest({
    @JsonKey(name: 'sport_rule_field_id') required int sportRuleFieldId,
    required String value,
  }) = _TournamentRuleValueRequest;

  factory TournamentRuleValueRequest.fromJson(Map<String, dynamic> json) =>
      _$TournamentRuleValueRequestFromJson(json);
}

@freezed
class TournamentVenueRequest with _$TournamentVenueRequest {
  const factory TournamentVenueRequest({
    @JsonKey(name: 'venue_name') required String venueName,
    required String notes,
    @JsonKey(name: 'venue_id') int? venueId,
    String? location,
    @JsonKey(name: 'daily_match_capacity') int? dailyMatchCapacity,
    @JsonKey(name: 'ground_type') String? groundType,
    String? date,
    @JsonKey(name: 'start_time') String? startTime,
    @JsonKey(name: 'round_name') String? roundName,
  }) = _TournamentVenueRequest;

  factory TournamentVenueRequest.fromJson(Map<String, dynamic> json) =>
      _$TournamentVenueRequestFromJson(json);
}

@freezed
class TournamentBudgetRequest with _$TournamentBudgetRequest {
  const factory TournamentBudgetRequest({
    @JsonKey(name: 'registration_fee') required int registrationFee,
    required String currency,
    required List<TournamentPrizeRequest> prizes,
    required List<TournamentSponsorRequest> sponsors,
  }) = _TournamentBudgetRequest;

  factory TournamentBudgetRequest.fromJson(Map<String, dynamic> json) =>
      _$TournamentBudgetRequestFromJson(json);
}

@freezed
class TournamentPrizeRequest with _$TournamentPrizeRequest {
  const factory TournamentPrizeRequest({
    required String title,
    required int amount,
    required String category,
  }) = _TournamentPrizeRequest;

  factory TournamentPrizeRequest.fromJson(Map<String, dynamic> json) =>
      _$TournamentPrizeRequestFromJson(json);
}

@freezed
class TournamentSponsorRequest with _$TournamentSponsorRequest {
  const factory TournamentSponsorRequest({
    required String name,
    @JsonKey(name: 'sponsor_type') required String sponsorType,
    @JsonKey(name: 'contribution_amount') required int contributionAmount,
  }) = _TournamentSponsorRequest;

  factory TournamentSponsorRequest.fromJson(Map<String, dynamic> json) =>
      _$TournamentSponsorRequestFromJson(json);
}

@freezed
class TournamentSubmitRequest with _$TournamentSubmitRequest {
  const factory TournamentSubmitRequest({
    required bool confirmation,
  }) = _TournamentSubmitRequest;

  factory TournamentSubmitRequest.fromJson(Map<String, dynamic> json) =>
      _$TournamentSubmitRequestFromJson(json);
}
