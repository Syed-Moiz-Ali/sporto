import '../entities/cricket_match_entity.dart';
import '../repos/imatch_repository.dart';

class GetMatchesUseCase {
  final IMatchRepository repository;

  GetMatchesUseCase(this.repository);

  Future<List<CricketMatchEntity>> call() {
    return repository.getMatches();
  }

  Stream<List<CricketMatchEntity>> watch() {
    return repository.watchMatches();
  }

  Future<CricketMatchEntity?> getById(String id) {
    return repository.getMatchById(id);
  }
}
