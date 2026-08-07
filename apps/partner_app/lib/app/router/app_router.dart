import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/views/auth_flow_view.dart';
import '../../features/tournaments/presentation/screens/create_tournament_wizard_screen.dart';
import '../../features/tournaments/presentation/screens/match_detail_screen.dart';

/// Central route table for the partner app.
abstract final class AppRouter {
  static const String homePath = '/';
  static const String tournamentDetailPath = '/tournaments/:id';
  static const String createTournamentPath = '/create-tournament';

  static String tournamentDetailRoute(String tournamentId) =>
      '/tournaments/$tournamentId';

  static const String createTournamentRoute = createTournamentPath;

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
    ],
  );
}
