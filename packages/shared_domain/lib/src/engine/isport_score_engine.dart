import '../entities/base_match_entity.dart';
import '../enums/enums.dart';

abstract class ISportScoreEngine<T extends BaseMatchEntity, E> {
  SportType get sportType;
  T validateMatchState(T match);
  T processEvent(T currentMatch, E event);
}
