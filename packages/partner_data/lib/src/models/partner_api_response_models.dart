// ignore_for_file: invalid_annotation_target

import 'package:freezed_annotation/freezed_annotation.dart';

part 'partner_api_response_models.freezed.dart';
part 'partner_api_response_models.g.dart';

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
    @JsonKey(name: 'partner_profile_id') required int partnerProfileId,
    @JsonKey(name: 'document_type') required String documentType,
    @JsonKey(name: 'document_path') required String documentPath,
    @JsonKey(name: 'verification_status') required int verificationStatus,
    @JsonKey(name: 'rejection_reason') String? rejectionReason,
    @JsonKey(name: 'created_at') required String createdAt,
    @JsonKey(name: 'updated_at') required String updatedAt,
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
