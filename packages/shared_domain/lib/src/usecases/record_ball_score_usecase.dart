import '../entities/ball_score_entity.dart';
import '../repos/imatch_repository.dart';

class RecordBallScoreUseCase {
  final IMatchRepository repository;

  RecordBallScoreUseCase(this.repository);

  Future<void> call(String matchId, BallScoreEntity ballScore) {
    return repository.recordBallScore(matchId, ballScore);
  }
}
