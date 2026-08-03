import '../entities/user_entity.dart';
import '../repos/iauth_repository.dart';

class VerifyOtpUseCase {
  final IAuthRepository repository;

  VerifyOtpUseCase(this.repository);

  Future<({UserEntity user, bool isNewUser})> call(String mobileNumber, String otpCode, String role) {
    return repository.verifyOtp(mobileNumber, otpCode, role);
  }
}
