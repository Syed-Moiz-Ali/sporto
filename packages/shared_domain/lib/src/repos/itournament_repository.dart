import '../entities/tournament_entity.dart';
import '../enums/enums.dart';

abstract class ITournamentRepository {
  Stream<List<TournamentEntity>> watchTournaments();
  Future<List<TournamentEntity>> getTournaments({SportType? sportType});
  Future<void> createTournament(TournamentEntity tournament);
  Future<void> syncPendingTournaments();
}
