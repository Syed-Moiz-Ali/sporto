import '../entities/tournament_entity.dart';
import '../repos/itournament_repository.dart';

class CreateTournamentUseCase {
  final ITournamentRepository repository;

  CreateTournamentUseCase(this.repository);

  Future<void> call(TournamentEntity tournament) {
    return repository.createTournament(tournament);
  }
}
