import '../entities/toss_result_entity.dart';
import '../repos/imatch_repository.dart';

class ConductTossUseCase {
  final IMatchRepository repository;

  ConductTossUseCase(this.repository);

  Future<void> call(String matchId, TossResultEntity tossResult) {
    return repository.conductToss(matchId, tossResult);
  }
}
