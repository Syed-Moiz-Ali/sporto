import '../entities/tournament_entity.dart';
import '../enums/enums.dart';
import '../repos/itournament_repository.dart';

class GetTournamentsUseCase {
  final ITournamentRepository repository;

  GetTournamentsUseCase(this.repository);

  Future<List<TournamentEntity>> call({SportType? sportType}) {
    return repository.getTournaments(sportType: sportType);
  }

  Stream<List<TournamentEntity>> watch() {
    return repository.watchTournaments();
  }
}
