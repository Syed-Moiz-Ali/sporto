import '../enums/enums.dart';
import 'isport_score_engine.dart';
import 'cricket_score_engine.dart';

class SportEngineFactory {
  static final Map<SportType, ISportScoreEngine> _engines = {
    SportType.cricket: CricketScoreEngine(),
  };

  static ISportScoreEngine getEngine(SportType sportType) {
    final engine = _engines[sportType];
    if (engine == null) {
      throw UnsupportedError('Sport engine for $sportType is not implemented yet.');
    }
    return engine;
  }
}
