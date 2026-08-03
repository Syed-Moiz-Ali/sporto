import 'package:shared_domain/shared_domain.dart';
import '../storage/hive_service.dart';

class AuthRepositoryImpl implements IAuthRepository {
  static const String _userKey = 'current_user';

  @override
  Future<UserEntity?> getCurrentUser() async {
    final box = HiveService.pendingSyncBox;
    final val = box.get(_userKey);
    if (val == null) return null;
    return UserEntity.fromJson(Map<String, dynamic>.from(val as Map));
  }

  @override
  Future<void> sendOtp(String mobileNumber) async {
    // Simulate sending SMS OTP via backend gateway
    await Future.delayed(const Duration(milliseconds: 600));
  }

  @override
  Future<({UserEntity user, bool isNewUser})> verifyOtp(String mobileNumber, String otpCode, String role) async {
    await Future.delayed(const Duration(milliseconds: 600));

    // Simulate backend check for user existence by mobile number
    // If mobile number ends with '00', simulate an existing user with completed profile
    final isExistingUser = mobileNumber.endsWith('00');

    final user = UserEntity(
      id: 'usr-${DateTime.now().millisecondsSinceEpoch}',
      name: isExistingUser ? (role == 'partner' ? 'League Host Partner' : 'Official Ref. Alex Vance') : '',
      email: isExistingUser ? 'user@sporto.com' : '',
      mobileNumber: mobileNumber,
      role: role,
      badgeId: role == 'referee' ? '#UM-9921' : null,
      isProfileComplete: isExistingUser,
    );

    final box = HiveService.pendingSyncBox;
    await box.put(_userKey, user.toJson());

    return (user: user, isNewUser: !isExistingUser);
  }

  @override
  Future<UserEntity> completeProfile(UserEntity updatedUser) async {
    final completeUser = updatedUser.copyWith(isProfileComplete: true);
    final box = HiveService.pendingSyncBox;
    await box.put(_userKey, completeUser.toJson());
    return completeUser;
  }

  @override
  Future<void> logout() async {
    final box = HiveService.pendingSyncBox;
    await box.delete(_userKey);
  }
}
