import 'package:go_router/go_router.dart';
import 'package:shared_domain/shared_domain.dart';
import 'package:ui_kit/ui_kit.dart';

import '../../../features/auth/presentation/views/auth_flow_view.dart';
import '../../../features/matches/presentation/screens/conduct_toss_wizard.dart';
import '../../../features/matches/presentation/screens/live_scoring_screen.dart';
import '../../../features/matches/presentation/screens/matches_list_screen.dart';
import '../../../features/matches/presentation/screens/match_verification_screen.dart';
import '../../../features/matches/presentation/screens/referee_match_history_screen.dart';

/// Central route table for the referee app.
abstract final class AppRouter {
  static const String homePath = '/';
  static const String matchesPath = '/matches';
  static const String matchVerificationPath = '/match-verification';
  static const String conductTossPath = '/conduct-toss';
  static const String liveScoringPath = '/live-scoring';
  static const String matchHistoryPath = '/match-history';

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
        builder: (context, state) => const SportoScreenShell(
          body: MatchesListScreen(),
        ),
      ),
      GoRoute(
        path: matchVerificationPath,
        name: 'matchVerification',
        builder: (context, state) => MatchVerificationScreen(
          matchId: state.uri.queryParameters['matchId'],
          match: state.extra is CricketMatchEntity
              ? state.extra as CricketMatchEntity
              : null,
        ),
      ),
      GoRoute(
        path: conductTossPath,
        name: 'conductToss',
        builder: (context, state) => ConductTossWizard(
          matchId: state.uri.queryParameters['matchId'],
        ),
      ),
      GoRoute(
        path: matchHistoryPath,
        builder: (context, state) => const RefereeMatchHistoryScreen(),
      ),
      GoRoute(
        path: liveScoringPath,
        name: 'liveScoring',
        builder: (context, state) => LiveScoringScreen(
          matchId: state.uri.queryParameters['matchId'],
          matchCode: state.uri.queryParameters['matchCode'],
        ),
      ),
    ],
  );
}
