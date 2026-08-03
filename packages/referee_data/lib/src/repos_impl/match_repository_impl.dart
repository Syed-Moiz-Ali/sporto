import 'package:shared_domain/shared_domain.dart';
import '../datasources/match_local_datasource.dart';

class MatchRepositoryImpl implements IMatchRepository {
  final MatchLocalDataSource localDataSource;

  MatchRepositoryImpl({MatchLocalDataSource? localDataSource})
      : localDataSource = localDataSource ?? MatchLocalDataSource();

  @override
  Stream<List<CricketMatchEntity>> watchMatches() {
    return localDataSource.watchMatches();
  }

  @override
  Future<List<CricketMatchEntity>> getMatches() async {
    return localDataSource.getMatches();
  }

  @override
  Future<CricketMatchEntity?> getMatchById(String id) async {
    return localDataSource.getMatchById(id);
  }

  @override
  Future<void> verifyMatchRoster(String matchId) async {
    final match = localDataSource.getMatchById(matchId);
    if (match != null) {
      final updated = match.copyWith(
        isVerifiedByReferee: true,
        status: MatchStatus.toss,
        syncStatus: SyncStatus.pendingSync,
      );
      await localDataSource.saveMatch(updated);
    }
  }

  @override
  Future<void> conductToss(String matchId, TossResultEntity tossResult) async {
    final match = localDataSource.getMatchById(matchId);
    if (match != null) {
      final updated = match.copyWith(
        tossResult: tossResult,
        status: MatchStatus.live,
        syncStatus: SyncStatus.pendingSync,
      );
      await localDataSource.saveMatch(updated);
    }
  }

  @override
  Future<void> recordBallScore(String matchId, BallScoreEntity ballScore) async {
    final match = localDataSource.getMatchById(matchId);
    if (match != null) {
      final engine = SportEngineFactory.getEngine(match.sportType) as CricketScoreEngine;
      final updatedMatch = engine.processEvent(match, ballScore);
      await localDataSource.saveMatch(updatedMatch);
    }
  }

  @override
  Future<void> completeMatch(String matchId) async {
    final match = localDataSource.getMatchById(matchId);
    if (match != null) {
      final updated = match.copyWith(
        status: MatchStatus.completed,
        syncStatus: SyncStatus.pendingSync,
      );
      await localDataSource.saveMatch(updated);
    }
  }

  @override
  Future<void> syncPendingMatches() async {
    final matches = localDataSource.getMatches();
    final pending = matches.where((m) => m.syncStatus == SyncStatus.pendingSync);

    for (var m in pending) {
      final synced = m.copyWith(syncStatus: SyncStatus.synced);
      await localDataSource.saveMatch(synced);
    }
  }
}
