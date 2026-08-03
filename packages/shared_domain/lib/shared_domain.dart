library shared_domain;

// Enums
export 'src/enums/enums.dart';

// Entities
export 'src/entities/player_entity.dart';
export 'src/entities/team_entity.dart';
export 'src/entities/ball_score_entity.dart';
export 'src/entities/toss_result_entity.dart';
export 'src/entities/base_match_entity.dart';
export 'src/entities/cricket_match_entity.dart';
export 'src/entities/tournament_entity.dart';
export 'src/entities/user_entity.dart';

// Engine Strategy
export 'src/engine/isport_score_engine.dart';
export 'src/engine/cricket_score_engine.dart';
export 'src/engine/sport_engine_factory.dart';

// Repositories Interfaces
export 'src/repos/itournament_repository.dart';
export 'src/repos/imatch_repository.dart';
export 'src/repos/iauth_repository.dart';

// Use Cases (Mobile OTP & Onboarding)
export 'src/usecases/get_tournaments_usecase.dart';
export 'src/usecases/create_tournament_usecase.dart';
export 'src/usecases/get_matches_usecase.dart';
export 'src/usecases/verify_match_usecase.dart';
export 'src/usecases/conduct_toss_usecase.dart';
export 'src/usecases/record_ball_score_usecase.dart';
export 'src/usecases/send_otp_usecase.dart';
export 'src/usecases/verify_otp_usecase.dart';
export 'src/usecases/complete_profile_usecase.dart';
export 'src/usecases/logout_usecase.dart';
export 'src/usecases/get_current_user_usecase.dart';
