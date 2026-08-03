import '../entities/cricket_match_entity.dart';
import '../entities/ball_score_entity.dart';
import '../enums/enums.dart';
import 'isport_score_engine.dart';

class CricketScoreEngine implements ISportScoreEngine<CricketMatchEntity, BallScoreEntity> {
  @override
  SportType get sportType => SportType.cricket;

  @override
  CricketMatchEntity validateMatchState(CricketMatchEntity match) {
    return match;
  }

  @override
  CricketMatchEntity processEvent(CricketMatchEntity match, BallScoreEntity event) {
    final updatedCommentary = List<BallScoreEntity>.from(match.commentary)..add(event);

    final isTeamA = match.currentInning == 1;

    int newScore = isTeamA ? match.teamAScore + event.runs : match.teamBScore + event.runs;
    if (event.isWide || event.isNoBall) {
      newScore += 1;
    }

    int newWickets = isTeamA
        ? (event.isWicket ? match.teamAWickets + 1 : match.teamAWickets)
        : (event.isWicket ? match.teamBWickets + 1 : match.teamBWickets);

    // Calculate overs
    final validBalls = updatedCommentary.where((b) => !b.isWide && !b.isNoBall).length;
    final oversInt = validBalls ~/ 6;
    final ballsInOver = validBalls % 6;
    final newOvers = oversInt + (ballsInOver / 10.0);

    return match.copyWith(
      teamAScore: isTeamA ? newScore : match.teamAScore,
      teamAWickets: isTeamA ? newWickets : match.teamAWickets,
      teamAOvers: isTeamA ? newOvers : match.teamAOvers,
      teamBScore: !isTeamA ? newScore : match.teamBScore,
      teamBWickets: !isTeamA ? newWickets : match.teamBWickets,
      teamBOvers: !isTeamA ? newOvers : match.teamBOvers,
      commentary: updatedCommentary,
      syncStatus: SyncStatus.pendingSync,
    );
  }
}
