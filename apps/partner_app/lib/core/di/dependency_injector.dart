import 'package:core/core.dart';
import 'package:partner_data/partner_data.dart';
import 'package:shared_domain/shared_domain.dart';

import '../../features/tournaments/application/tournament_bloc.dart';

/// Composition root: wires data layer (repositories) to the presentation
/// layer (blocs). Kept out of widgets so the UI stays free of construction
/// details.
class DependencyInjector {
  DependencyInjector._();

  static final DependencyInjector instance = DependencyInjector._();

  late final ThemeBloc themeBloc = ThemeBloc()..add(InitThemeEvent());

  late final ConnectivityBloc connectivityBloc =
      ConnectivityBloc()..add(StartConnectivityWatcherEvent());

  late final AuthBloc authBloc = _buildAuthBloc();

  late final TournamentBloc tournamentBloc = _buildTournamentBloc();

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

  TournamentBloc _buildTournamentBloc() {
    final tournamentRepository = TournamentRepositoryImpl();
    return TournamentBloc(
      getTournamentsUseCase: GetTournamentsUseCase(tournamentRepository),
      createTournamentUseCase: CreateTournamentUseCase(tournamentRepository),
    );
  }
}
