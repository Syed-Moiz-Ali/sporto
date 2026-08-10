import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/views/auth_flow_view.dart';
import '../../features/tournaments/presentation/screens/create_tournament_wizard_screen.dart';
import '../../features/tournaments/presentation/screens/match_detail_screen.dart';
import '../../features/tournaments/presentation/screens/match_history_screen.dart';
import '../../features/tournaments/presentation/screens/profile_screen.dart';
import '../../features/tournaments/presentation/screens/schedule_screen.dart';

/// Central route table for the partner app.
abstract final class AppRouter {
  static const String homePath = '/';
  static const String tournamentDetailPath = '/tournaments/:id';
  static const String createTournamentPath = '/create-tournament';
  static const String matchHistoryPath = '/match-history';
  static const String profilePath = '/profile';
  static const String schedulePath = '/schedule';

  static String tournamentDetailRoute(String tournamentId) =>
      '/tournaments/$tournamentId';

  static const String createTournamentRoute = createTournamentPath;
  static const String matchHistoryRoute = matchHistoryPath;
  static const String profileRoute = profilePath;
  static const String scheduleRoute = schedulePath;

  static final GoRouter router = GoRouter(
    initialLocation: homePath,
    routes: [
      GoRoute(
        path: homePath,
        name: 'home',
        builder: (context, state) => const AuthFlowView(),
      ),
      GoRoute(
        path: tournamentDetailPath,
        name: 'tournamentDetail',
        builder: (context, state) => TournamentDetailScreen(
          tournamentId: state.pathParameters['id'],
        ),
      ),
      GoRoute(
        path: createTournamentPath,
        name: 'createTournament',
        builder: (context, state) => const CreateTournamentWizardScreen(),
      ),
      GoRoute(
        path: matchHistoryPath,
        name: 'matchHistory',
        builder: (context, state) => const MatchHistoryScreen(),
      ),
      GoRoute(
        path: schedulePath,
        name: 'schedule',
        builder: (context, state) => const ScheduleScreen(),
      ),
      GoRoute(
        path: profilePath,
        name: 'profile',
        builder: (context, state) => const ProfileScreen(),
      ),
    ],
  );
}
