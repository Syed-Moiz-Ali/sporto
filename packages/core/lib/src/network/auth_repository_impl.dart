import 'package:shared_domain/shared_domain.dart';
import '../storage/hive_service.dart';
import 'auth_session_store.dart';
import 'models/partner_api_requests.dart';
import 'models/sporto_api_response.dart';
import 'sporto_api_client.dart';
import 'sporto_api_endpoints.dart';

class AuthRepositoryImpl implements IAuthRepository {
  static const String _userKey = 'current_user';
  final SportoApiClient apiClient;
  final AuthSessionStore sessionStore;

  AuthRepositoryImpl({
    SportoApiClient? apiClient,
    AuthSessionStore? sessionStore,
  })  : sessionStore = sessionStore ?? AuthSessionStore(),
        apiClient = apiClient ??
            SportoApiClient(
              tokenProvider: (sessionStore ?? AuthSessionStore()).getToken,
            );

  @override
  Future<UserEntity?> getCurrentUser() async {
    final box = HiveService.pendingSyncBox;
    final val = box.get(_userKey);
    if (val == null) return null;
    return UserEntity.fromJson(Map<String, dynamic>.from(val as Map));
  }

  @override
  Future<void> sendOtp(String mobileNumber, String role) async {
    final appRole = _roleFromPath(role);
    final normalizedMobileNumber = _normalizeIndianMobileNumber(mobileNumber);
    final response = await apiClient.postJson(
      SportoApiEndpoints.auth(appRole).sendOtp,
      body: SendOtpRequest(mobileNumber: normalizedMobileNumber).toJson(),
    );
    final envelope = SportoApiResponse.fromJson(response);
    final data = _readObject(envelope.data);
    final otpData = SendOtpResponseData.fromJson(data);
    if (otpData.sessionKey.isNotEmpty) {
      await sessionStore.saveSessionKey(
        mobileNumber: normalizedMobileNumber,
        role: role,
        sessionKey: otpData.sessionKey,
      );
    }
  }

  @override
  Future<({UserEntity user, bool isNewUser})> verifyOtp(
      String mobileNumber, String otpCode, String role) async {
    final appRole = _roleFromPath(role);
    final normalizedMobileNumber = _normalizeIndianMobileNumber(mobileNumber);
    final sessionKey =
        await sessionStore.getSessionKey(normalizedMobileNumber, role) ?? '';
    final response = await apiClient.postJson(
      SportoApiEndpoints.auth(appRole).verifyOtp,
      body: VerifyOtpRequest(
        mobileNumber: normalizedMobileNumber,
        otp: otpCode,
        sessionKey: sessionKey,
        deviceId: 'sporto-flutter-${role}_app',
      ).toJson(),
    );
    final data = _readObject(response['data']);
    await sessionStore.saveVerifyOtpResponse(data);
    final token = data['token']?.toString();
    if (token != null && token.isNotEmpty) {
      await sessionStore.saveToken(token);
    }

    final verifyData = VerifyOtpResponseData.fromJson(data);
    final profile = verifyData.user.profile;
    final name = profile.fullName ?? '';
    final profileComplete = profile.email != null &&
        profile.fullName != null &&
        profile.dateOfBirth != null &&
        profile.gender != null &&
        profile.city != null &&
        profile.state != null;

    final user = UserEntity(
      id: verifyData.user.id.toString(),
      name: name,
      email: profile.email ?? '',
      mobileNumber: normalizedMobileNumber,
      role: role,
      dob: profile.dateOfBirth,
      gender: profile.gender,
      city: profile.city,
      state: profile.state,
      isProfileComplete: profileComplete,
    );

    final box = HiveService.pendingSyncBox;
    await box.put(_userKey, user.toJson());

    return (user: user, isNewUser: verifyData.isNewUser);
  }

  @override
  Future<UserEntity> completeProfile(UserEntity updatedUser) async {
    if (updatedUser.role != SportoAppRole.partner.path) {
      try {
        await apiClient.postJson(
          '/v1/${updatedUser.role}/profile',
          body: {
            ...PartnerProfileRequest(
              firstName: updatedUser.name.split(' ').first,
              lastName: updatedUser.name.split(' ').skip(1).join(' '),
              email: updatedUser.email,
              dateOfBirth: updatedUser.dob ?? '',
              gender: updatedUser.gender?.toLowerCase() ?? '',
              addressLine1: '',
              addressLine2: '',
              city: updatedUser.city ?? '',
              state: updatedUser.state ?? '',
              country: '',
              pincode: '',
              highestQualification: '',
              presentOccupation: '',
            ).toJson(),
          }..removeWhere((_, value) => value == ''),
        );
      } catch (_) {
        // Local profile state persistence proceeds even if remote endpoint is unavailable
      }
    }
    final completeUser = updatedUser.copyWith(isProfileComplete: true);
    final box = HiveService.pendingSyncBox;
    await box.put(_userKey, completeUser.toJson());
    return completeUser;
  }

  @override
  Future<void> logout() async {
    final box = HiveService.pendingSyncBox;
    await box.delete(_userKey);
    await sessionStore.clear();
  }

  Map<String, dynamic> _readObject(Object? value) {
    if (value is Map) return Map<String, dynamic>.from(value);
    return <String, dynamic>{};
  }

  SportoAppRole _roleFromPath(String role) {
    return SportoAppRole.values.firstWhere(
      (value) => value.path == role,
      orElse: () => SportoAppRole.partner,
    );
  }

  String _normalizeIndianMobileNumber(String value) {
    final digits = value.replaceAll(RegExp(r'\D'), '');
    if (digits.length == 12 && digits.startsWith('91')) {
      return digits.substring(2);
    }
    if (digits.length == 11 && digits.startsWith('0')) {
      return digits.substring(1);
    }
    return digits;
  }
}
