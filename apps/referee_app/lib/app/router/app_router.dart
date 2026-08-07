import 'package:go_router/go_router.dart';

import '../../../features/auth/presentation/views/auth_flow_view.dart';
import '../../../features/matches/presentation/screens/conduct_toss_wizard.dart';
import '../../../features/matches/presentation/screens/live_scoring_screen.dart';
import '../../../features/matches/presentation/screens/matches_list_screen.dart';
import '../../../features/matches/presentation/screens/match_verification_screen.dart';

/// Central route table for the referee app.
abstract final class AppRouter {
  static const String homePath = '/';
  static const String matchesPath = '/matches';
  static const String matchVerificationPath = '/match-verification';
  static const String conductTossPath = '/conduct-toss';
  static const String liveScoringPath = '/live-scoring';

  static const String matchesRoute = matchesPath;
  static const String matchVerificationRoute = matchVerificationPath;
  static const String conductTossRoute = conductTossPath;
  static const String liveScoringRoute = liveScoringPath;

  static final GoRouter router = GoRouter(
    initialLocation: homePath,
    routes: [
      GoRoute(
        path: homePath,
        name: 'home',
        builder: (context, state) => const AuthFlowView(),
      ),
      GoRoute(
        path: matchesPath,
        name: 'matches',
        builder: (context, state) => const MatchesListScreen(),
      ),
      GoRoute(
        path: matchVerificationPath,
        name: 'matchVerification',
        builder: (context, state) => const MatchVerificationScreen(),
      ),
      GoRoute(
        path: conductTossPath,
        name: 'conductToss',
        builder: (context, state) => const ConductTossWizard(),
      ),
      GoRoute(
        path: liveScoringPath,
        name: 'liveScoring',
        builder: (context, state) => const LiveScoringScreen(),
      ),
    ],
  );
}
