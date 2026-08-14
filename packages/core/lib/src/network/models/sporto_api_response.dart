// ignore_for_file: invalid_annotation_target

import 'package:freezed_annotation/freezed_annotation.dart';

part 'sporto_api_response.freezed.dart';
part 'sporto_api_response.g.dart';

@freezed
class SportoApiResponse with _$SportoApiResponse {
  const factory SportoApiResponse({
    required bool success,
    required String message,
    Object? data,
    Object? errors,
  }) = _SportoApiResponse;

  factory SportoApiResponse.fromJson(Map<String, dynamic> json) =>
      _$SportoApiResponseFromJson(json);
}

@freezed
class SendOtpResponseData with _$SendOtpResponseData {
  const factory SendOtpResponseData({
    @JsonKey(name: 'session_key') required String sessionKey,
    @JsonKey(name: 'provider_response')
    required OtpProviderResponse providerResponse,
  }) = _SendOtpResponseData;

  factory SendOtpResponseData.fromJson(Map<String, dynamic> json) =>
      _$SendOtpResponseDataFromJson(json);
}

@freezed
class OtpProviderResponse with _$OtpProviderResponse {
  const factory OtpProviderResponse({
    required String Status,
    required String Details,
  }) = _OtpProviderResponse;

  factory OtpProviderResponse.fromJson(Map<String, dynamic> json) =>
      _$OtpProviderResponseFromJson(json);
}

@freezed
class VerifyOtpResponseData with _$VerifyOtpResponseData {
  const factory VerifyOtpResponseData({
    required String token,
    @JsonKey(name: 'is_new_user') required bool isNewUser,
    required AuthUserResponse user,
  }) = _VerifyOtpResponseData;

  factory VerifyOtpResponseData.fromJson(Map<String, dynamic> json) =>
      _$VerifyOtpResponseDataFromJson(json);
}

@freezed
class AuthUserResponse with _$AuthUserResponse {
  const factory AuthUserResponse({
    required int id,
    @JsonKey(name: 'mobile_number') required String mobileNumber,
    required int status,
    required AuthUserProfileResponse profile,
  }) = _AuthUserResponse;

  factory AuthUserResponse.fromJson(Map<String, dynamic> json) =>
      _$AuthUserResponseFromJson(json);
}

@freezed
class AuthUserProfileResponse with _$AuthUserProfileResponse {
  const factory AuthUserProfileResponse({
    required int id,
    @JsonKey(name: 'user_id') required int userId,
    @JsonKey(name: 'full_name') String? fullName,
    String? email,
    @JsonKey(name: 'date_of_birth') String? dateOfBirth,
    String? gender,
    String? city,
    String? state,
    String? country,
    @JsonKey(name: 'profile_photo_path') String? profilePhotoPath,
    @JsonKey(name: 'created_at') required String createdAt,
    @JsonKey(name: 'updated_at') required String updatedAt,
  }) = _AuthUserProfileResponse;

  factory AuthUserProfileResponse.fromJson(Map<String, dynamic> json) =>
      _$AuthUserProfileResponseFromJson(json);
}

@freezed
class UploadFileResponseData with _$UploadFileResponseData {
  const factory UploadFileResponseData({
    required String path,
    required String url,
  }) = _UploadFileResponseData;

  factory UploadFileResponseData.fromJson(Map<String, dynamic> json) =>
      _$UploadFileResponseDataFromJson(json);
}
