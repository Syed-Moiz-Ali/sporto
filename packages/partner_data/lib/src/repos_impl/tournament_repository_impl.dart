import 'package:shared_domain/shared_domain.dart';
import '../datasources/tournament_local_datasource.dart';

class TournamentRepositoryImpl implements ITournamentRepository {
  final TournamentLocalDataSource localDataSource;

  TournamentRepositoryImpl({TournamentLocalDataSource? localDataSource})
      : localDataSource = localDataSource ?? TournamentLocalDataSource();

  @override
  Stream<List<TournamentEntity>> watchTournaments() {
    return localDataSource.watchTournaments();
  }

  @override
  Future<List<TournamentEntity>> getTournaments({SportType? sportType}) async {
    return localDataSource.getTournaments(sportType: sportType);
  }

  @override
  Future<void> createTournament(TournamentEntity tournament) async {
    final pendingTournament = tournament.copyWith(syncStatus: SyncStatus.pendingSync);
    await localDataSource.saveTournament(pendingTournament);
  }

  @override
  Future<void> syncPendingTournaments() async {
    final tournaments = localDataSource.getTournaments();
    final pending = tournaments.where((t) => t.syncStatus == SyncStatus.pendingSync);

    for (var t in pending) {
      final synced = t.copyWith(syncStatus: SyncStatus.synced);
      await localDataSource.saveTournament(synced);
    }
  }
}
