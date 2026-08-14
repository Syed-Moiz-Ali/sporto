import '../entities/user_entity.dart';

abstract class IAuthRepository {
  Future<UserEntity?> getCurrentUser();
  Future<void> sendOtp(String mobileNumber, String role);
  Future<({UserEntity user, bool isNewUser})> verifyOtp(
      String mobileNumber, String otpCode, String role);
  Future<UserEntity> completeProfile(UserEntity updatedUser);
  Future<void> logout();
}
