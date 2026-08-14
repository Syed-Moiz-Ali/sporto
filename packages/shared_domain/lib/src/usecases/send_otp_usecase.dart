import '../repos/iauth_repository.dart';

class SendOtpUseCase {
  final IAuthRepository repository;

  SendOtpUseCase(this.repository);

  Future<void> call(String mobileNumber, String role) {
    return repository.sendOtp(mobileNumber, role);
  }
}
