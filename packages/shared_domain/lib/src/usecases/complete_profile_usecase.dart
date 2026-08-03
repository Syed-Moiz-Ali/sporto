import '../entities/user_entity.dart';
import '../repos/iauth_repository.dart';

class CompleteProfileUseCase {
  final IAuthRepository repository;

  CompleteProfileUseCase(this.repository);

  Future<UserEntity> call(UserEntity updatedUser) {
    return repository.completeProfile(updatedUser);
  }
}
