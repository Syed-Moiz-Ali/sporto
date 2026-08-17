import 'package:flutter/foundation.dart';

import '../storage/hive_service.dart';

class AuthSessionStore {
  static const _tokenKey = 'auth_token';
  static const _sessionKeyKey = 'auth_session_key';
  static const _verifyOtpResponseKey = 'verify_otp_response';

  Future<String?> getToken() async {
    final value = HiveService.authSessionBox.get(_tokenKey) ??
        HiveService.pendingSyncBox.get(_tokenKey);
    if (value is String && value.isNotEmpty) {
      await HiveService.authSessionBox.put(_tokenKey, value);
      return value;
    }
    return null;
  }

  Future<void> saveToken(String token) async {
    await HiveService.authSessionBox.put(_tokenKey, token);
    if (kDebugMode) {
      debugPrint('[SportoApi] AUTH_SESSION token saved');
    }
  }

  Future<Map<String, dynamic>?> getVerifyOtpResponse() async {
    final value = HiveService.authSessionBox.get(_verifyOtpResponseKey) ??
        HiveService.pendingSyncBox.get(_verifyOtpResponseKey);
    if (value is! Map) return null;
    final response = Map<String, dynamic>.from(value);
    await HiveService.authSessionBox.put(_verifyOtpResponseKey, response);
    return response;
  }

  Future<void> saveVerifyOtpResponse(Map<String, dynamic> response) async {
    await HiveService.authSessionBox.put(_verifyOtpResponseKey, response);
  }

  Future<String?> getSessionKey(String mobileNumber, String role) async {
    final key = _sessionStorageKey(mobileNumber, role);
    final value = HiveService.authSessionBox.get(key) ??
        HiveService.pendingSyncBox.get(key);
    if (value is String && value.isNotEmpty) {
      await HiveService.authSessionBox.put(key, value);
      return value;
    }
    return null;
  }

  Future<void> saveSessionKey({
    required String mobileNumber,
    required String role,
    required String sessionKey,
  }) async {
    await HiveService.authSessionBox.put(
      _sessionStorageKey(mobileNumber, role),
      sessionKey,
    );
  }

  Future<void> clear() async {
    final authBox = HiveService.authSessionBox;
    await authBox.delete(_tokenKey);
    await authBox.delete(_verifyOtpResponseKey);
    final authSessionKeys =
        authBox.keys.where((key) => key.toString().startsWith(_sessionKeyKey));
    await authBox.deleteAll(authSessionKeys);

    final oldBox = HiveService.pendingSyncBox;
    await oldBox.delete(_tokenKey);
    await oldBox.delete(_verifyOtpResponseKey);
    final oldSessionKeys =
        oldBox.keys.where((key) => key.toString().startsWith(_sessionKeyKey));
    await oldBox.deleteAll(oldSessionKeys);
    if (kDebugMode) {
      debugPrint('[SportoApi] AUTH_SESSION cleared');
    }
  }

  String _sessionStorageKey(String mobileNumber, String role) {
    return '$_sessionKeyKey-$role-$mobileNumber';
  }
}
