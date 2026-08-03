import '../repos/imatch_repository.dart';

class VerifyMatchUseCase {
  final IMatchRepository repository;

  VerifyMatchUseCase(this.repository);

  Future<void> call(String matchId) {
    return repository.verifyMatchRoster(matchId);
  }
}
