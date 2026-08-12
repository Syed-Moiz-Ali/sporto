import 'package:core/core.dart';
import 'package:referee_data/referee_data.dart';
import 'package:shared_domain/shared_domain.dart';

import '../../features/matches/application/conduct_toss_bloc.dart';
import '../../features/matches/application/match_scoring_bloc.dart';

class DependencyInjector {
  DependencyInjector._();

  static final DependencyInjector instance = DependencyInjector._();

  // ==========================================================
  // SHARED REPOSITORIES
  // ==========================================================

  late final MatchRepositoryImpl _matchRepository = MatchRepositoryImpl();

  // ==========================================================
  // CORE BLOCS
  // ==========================================================

  late final ThemeBloc themeBloc = ThemeBloc()
    ..add(
      InitThemeEvent(),
    );

  late final ConnectivityBloc connectivityBloc = ConnectivityBloc()
    ..add(
      StartConnectivityWatcherEvent(),
    );

  // ==========================================================
  // AUTH
  // ==========================================================

  late final AuthBloc authBloc = _buildAuthBloc();

  // ==========================================================
  // MATCHES
  //
  // General match loading / verification / scoring.
  //
  // Toss is NOT owned by this bloc anymore.
  // ==========================================================

  late final MatchScoringBloc matchScoringBloc = _buildMatchScoringBloc();

  // ==========================================================
  // TOSS USE CASE
  // ==========================================================

  late final ConductTossUseCase _conductTossUseCase = ConductTossUseCase(
    _matchRepository,
  );

  // ==========================================================
  // AUTH FACTORY
  // ==========================================================

  AuthBloc _buildAuthBloc() {
    final authRepository = AuthRepositoryImpl();

    return AuthBloc(
      sendOtpUseCase: SendOtpUseCase(
        authRepository,
      ),
      verifyOtpUseCase: VerifyOtpUseCase(
        authRepository,
      ),
      completeProfileUseCase: CompleteProfileUseCase(
        authRepository,
      ),
      logoutUseCase: LogoutUseCase(
        authRepository,
      ),
      getCurrentUserUseCase: GetCurrentUserUseCase(
        authRepository,
      ),
    )..add(
        CheckAuthStatusEvent(),
      );
  }

  // ==========================================================
  // MATCH SCORING FACTORY
  // ==========================================================

  MatchScoringBloc _buildMatchScoringBloc() {
    return MatchScoringBloc(
      getMatchesUseCase: GetMatchesUseCase(
        _matchRepository,
      ),
      verifyMatchUseCase: VerifyMatchUseCase(
        _matchRepository,
      ),
      recordBallScoreUseCase: RecordBallScoreUseCase(
        _matchRepository,
      ),
    );
  }

  // ==========================================================
  // CONDUCT TOSS FACTORY
  //
  // Feature-scoped.
  // Do NOT make ConductTossBloc a global singleton because
  // every match needs its own independent toss session.
  // ==========================================================

  ConductTossBloc createConductTossBloc({
    required String matchId,
    required TossTeam team1,
    required TossTeam team2,
    required String callerTeamId,
    TossCoinSide callerChoice = TossCoinSide.tails,
    TossCoinSide? forcedCoinSide,
  }) {
    return ConductTossBloc(
      conductTossUseCase: _conductTossUseCase,
      matchId: matchId,
      team1: team1,
      team2: team2,
      callerTeamId: callerTeamId,
      callerChoice: callerChoice,
      forcedCoinSide: forcedCoinSide,
    );
  }
}
