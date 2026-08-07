import 'package:core/core.dart';
import 'package:referee_data/referee_data.dart';
import 'package:shared_domain/shared_domain.dart';

import '../../features/matches/application/match_scoring_bloc.dart';

/// Composition root: wires data layer (repositories) to the presentation
/// layer (blocs). Kept out of widgets so the UI stays free of construction
/// details.
class DependencyInjector {
  DependencyInjector._();

  static final DependencyInjector instance = DependencyInjector._();

  late final ThemeBloc themeBloc = ThemeBloc()..add(InitThemeEvent());

  late final ConnectivityBloc connectivityBloc = ConnectivityBloc()
    ..add(StartConnectivityWatcherEvent());

  late final AuthBloc authBloc = _buildAuthBloc();

  late final MatchScoringBloc matchScoringBloc = _buildMatchScoringBloc();

  AuthBloc _buildAuthBloc() {
    final authRepository = AuthRepositoryImpl();
    return AuthBloc(
      sendOtpUseCase: SendOtpUseCase(authRepository),
      verifyOtpUseCase: VerifyOtpUseCase(authRepository),
      completeProfileUseCase: CompleteProfileUseCase(authRepository),
      logoutUseCase: LogoutUseCase(authRepository),
      getCurrentUserUseCase: GetCurrentUserUseCase(authRepository),
    )..add(CheckAuthStatusEvent());
  }

  MatchScoringBloc _buildMatchScoringBloc() {
    final matchRepository = MatchRepositoryImpl();
    return MatchScoringBloc(
      getMatchesUseCase: GetMatchesUseCase(matchRepository),
      verifyMatchUseCase: VerifyMatchUseCase(matchRepository),
      conductTossUseCase: ConductTossUseCase(matchRepository),
      recordBallScoreUseCase: RecordBallScoreUseCase(matchRepository),
    );
  }
}
