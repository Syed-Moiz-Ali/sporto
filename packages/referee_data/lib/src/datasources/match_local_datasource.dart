import 'dart:async';
import 'package:core/core.dart';
import 'package:shared_domain/shared_domain.dart';

class MatchLocalDataSource {
  final StreamController<List<CricketMatchEntity>> _controller = StreamController<List<CricketMatchEntity>>.broadcast();

  MatchLocalDataSource() {
    _initMockDataIfNeeded();
  }

  void _initMockDataIfNeeded() {
    final box = HiveService.matchesBox;
    if (box.isEmpty) {
      final defaultMatches = [
        CricketMatchEntity(
          id: 'm-901',
          tournamentName: 'Premier T20 Cup 2026',
          teamA: const TeamEntity(id: 'tm-1', name: 'Royal Strikers', logoEmoji: '🏏'),
          teamB: const TeamEntity(id: 'tm-2', name: 'Thunderbolts', logoEmoji: '⚡'),
          venue: 'National Cricket Stadium Pitch 1',
          scheduledTime: DateTime.now().add(const Duration(minutes: 15)),
          status: MatchStatus.upcoming,
          refereeName: 'Official Ref. Alex Vance (#UM-9921)',
          isVerifiedByReferee: false,
          syncStatus: SyncStatus.synced,
          totalOvers: 20,
        ),
        CricketMatchEntity(
          id: 'm-902',
          tournamentName: 'Urban Box Cricket League',
          teamA: const TeamEntity(id: 'tm-3', name: 'Viper XI', logoEmoji: '🐍'),
          teamB: const TeamEntity(id: 'tm-4', name: 'Cyber Titans', logoEmoji: '🤖'),
          venue: 'Sporto Arena Turf A',
          scheduledTime: DateTime.now().add(const Duration(hours: 2)),
          status: MatchStatus.verification,
          refereeName: 'Official Ref. Alex Vance (#UM-9921)',
          isVerifiedByReferee: true,
          syncStatus: SyncStatus.synced,
          totalOvers: 10,
        ),
      ];

      for (var m in defaultMatches) {
        box.put(m.id, m.toJson());
      }
    }
  }

  Stream<List<CricketMatchEntity>> watchMatches() {
    _emitCurrentMatches();
    return _controller.stream;
  }

  List<CricketMatchEntity> getMatches() {
    final box = HiveService.matchesBox;
    return box.values.map((v) {
      final jsonMap = Map<String, dynamic>.from(v as Map);
      return CricketMatchEntity.fromJson(jsonMap);
    }).toList();
  }

  CricketMatchEntity? getMatchById(String id) {
    final box = HiveService.matchesBox;
    final val = box.get(id);
    if (val == null) return null;
    return CricketMatchEntity.fromJson(Map<String, dynamic>.from(val as Map));
  }

  Future<void> saveMatch(CricketMatchEntity match) async {
    final box = HiveService.matchesBox;
    await box.put(match.id, match.toJson());

    if (match.syncStatus == SyncStatus.pendingSync) {
      await HiveService.addToSyncQueue(SyncQueueItem(
        actionId: 'sync-match-${match.id}-${DateTime.now().millisecondsSinceEpoch}',
        endpoint: '/api/v1/matches/${match.id}',
        httpMethod: 'PUT',
        payload: match.toJson(),
        timestamp: DateTime.now(),
      ));
    }

    _emitCurrentMatches();
  }

  void _emitCurrentMatches() {
    _controller.add(getMatches());
  }
}
