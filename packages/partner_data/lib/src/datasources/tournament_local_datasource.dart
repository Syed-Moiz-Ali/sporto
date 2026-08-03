import 'dart:async';
import 'package:core/core.dart';
import 'package:shared_domain/shared_domain.dart';

class TournamentLocalDataSource {
  final StreamController<List<TournamentEntity>> _controller = StreamController<List<TournamentEntity>>.broadcast();

  TournamentLocalDataSource() {
    _initMockDataIfNeeded();
  }

  void _initMockDataIfNeeded() {
    final box = HiveService.tournamentsBox;
    if (box.isEmpty) {
      final defaultTournaments = [
        TournamentEntity(
          id: 't-101',
          name: 'Premier T20 Cup 2026',
          sportType: SportType.cricket,
          category: 'T20 Championship',
          startDate: DateTime.now().add(const Duration(days: 3)),
          oversPerInning: 20,
          totalTeams: 8,
          matchDurationMinutes: 120,
          breakMinutes: 15,
          venues: const ['National Cricket Stadium', 'Ground 2'],
          entryFee: 500,
          prizePool: 5000,
          status: 'Active',
          syncStatus: SyncStatus.synced,
        ),
        TournamentEntity(
          id: 't-102',
          name: 'Urban Box Cricket League',
          sportType: SportType.cricket,
          category: 'Box Cricket',
          startDate: DateTime.now().add(const Duration(days: 10)),
          oversPerInning: 10,
          totalTeams: 12,
          matchDurationMinutes: 45,
          breakMinutes: 10,
          venues: const ['Sporto Arena Turf A'],
          entryFee: 250,
          prizePool: 2500,
          status: 'Open Registration',
          syncStatus: SyncStatus.synced,
        ),
      ];

      for (var t in defaultTournaments) {
        box.put(t.id, t.toJson());
      }
    }
  }

  Stream<List<TournamentEntity>> watchTournaments() {
    _emitCurrentTournaments();
    return _controller.stream;
  }

  List<TournamentEntity> getTournaments({SportType? sportType}) {
    final box = HiveService.tournamentsBox;
    final items = box.values.map((v) {
      final jsonMap = Map<String, dynamic>.from(v as Map);
      return TournamentEntity.fromJson(jsonMap);
    }).toList();

    if (sportType != null) {
      return items.where((t) => t.sportType == sportType).toList();
    }
    return items;
  }

  Future<void> saveTournament(TournamentEntity tournament) async {
    final box = HiveService.tournamentsBox;
    await box.put(tournament.id, tournament.toJson());

    // Also add to sync queue if offline or pending
    if (tournament.syncStatus == SyncStatus.pendingSync) {
      await HiveService.addToSyncQueue(SyncQueueItem(
        actionId: 'sync-tournament-${tournament.id}',
        endpoint: '/api/v1/tournaments',
        httpMethod: 'POST',
        payload: tournament.toJson(),
        timestamp: DateTime.now(),
      ));
    }

    _emitCurrentTournaments();
  }

  void _emitCurrentTournaments() {
    _controller.add(getTournaments());
  }
}
