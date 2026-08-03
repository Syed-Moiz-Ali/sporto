import '../entities/cricket_match_entity.dart';
import '../entities/ball_score_entity.dart';
import '../entities/toss_result_entity.dart';

abstract class IMatchRepository {
  Stream<List<CricketMatchEntity>> watchMatches();
  Future<List<CricketMatchEntity>> getMatches();
  Future<CricketMatchEntity?> getMatchById(String id);
  Future<void> verifyMatchRoster(String matchId);
  Future<void> conductToss(String matchId, TossResultEntity tossResult);
  Future<void> recordBallScore(String matchId, BallScoreEntity ballScore);
  Future<void> completeMatch(String matchId);
  Future<void> syncPendingMatches();
}
