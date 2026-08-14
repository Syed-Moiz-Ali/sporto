import '../storage/hive_service.dart';

class AuthSessionStore {
  static const _tokenKey = 'auth_token';
  static const _sessionKeyKey = 'auth_session_key';
  static const _verifyOtpResponseKey = 'verify_otp_response';

  Future<String?> getToken() async {
    final value = HiveService.pendingSyncBox.get(_tokenKey);
    return value is String && value.isNotEmpty ? value : null;
  }

  Future<void> saveToken(String token) async {
    await HiveService.pendingSyncBox.put(_tokenKey, token);
  }

  Future<Map<String, dynamic>?> getVerifyOtpResponse() async {
    final value = HiveService.pendingSyncBox.get(_verifyOtpResponseKey);
    if (value is! Map) return null;
    return Map<String, dynamic>.from(value);
  }

  Future<void> saveVerifyOtpResponse(Map<String, dynamic> response) async {
    await HiveService.pendingSyncBox.put(_verifyOtpResponseKey, response);
  }

  Future<String?> getSessionKey(String mobileNumber, String role) async {
    final value = HiveService.pendingSyncBox.get(_sessionStorageKey(
      mobileNumber,
      role,
    ));
    return value is String && value.isNotEmpty ? value : null;
  }

  Future<void> saveSessionKey({
    required String mobileNumber,
    required String role,
    required String sessionKey,
  }) async {
    await HiveService.pendingSyncBox.put(
      _sessionStorageKey(mobileNumber, role),
      sessionKey,
    );
  }

  Future<void> clear() async {
    final box = HiveService.pendingSyncBox;
    await box.delete(_tokenKey);
    await box.delete(_verifyOtpResponseKey);
    final sessionKeys =
        box.keys.where((key) => key.toString().startsWith(_sessionKeyKey));
    await box.deleteAll(sessionKeys);
  }

  String _sessionStorageKey(String mobileNumber, String role) {
    return '$_sessionKeyKey-$role-$mobileNumber';
  }
}
