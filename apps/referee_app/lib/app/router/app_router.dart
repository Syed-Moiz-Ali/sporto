import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';
import 'package:referee_data/referee_data.dart';
import 'package:shared_domain/shared_domain.dart';
import 'package:ui_kit/ui_kit.dart';

import '../../../features/auth/presentation/views/auth_flow_view.dart';
import '../../../features/matches/presentation/screens/accept_booking_screen.dart';
import '../../../features/matches/presentation/screens/booking_confirmed_screen.dart';
import '../../../features/matches/presentation/screens/conduct_toss_wizard.dart';
import '../../../features/matches/presentation/screens/incoming_requests_screen.dart';
import '../../../features/matches/presentation/screens/live_scoring_screen.dart';
import '../../../features/matches/presentation/screens/schedule_matches_screen.dart';
import '../../../features/matches/presentation/screens/match_verification_screen.dart';
import '../../../features/matches/presentation/screens/referee_match_history_screen.dart';
import '../../../features/matches/presentation/screens/request_details_screen.dart';
import '../../../features/matches/presentation/screens/start_match_screen.dart';
import '../../../features/matches/presentation/widgets/before_toss_widgets.dart';

/// Central route table for the referee app.
abstract final class AppRouter {
  static const String homePath = '/';
  static const String matchesPath = '/matches';
  static const String matchVerificationPath = '/match-verification';
  static const String conductTossPath = '/conduct-toss';
  static const String liveScoringPath = '/live-scoring';
  static const String matchHistoryPath = '/match-history';
  static const String incomingRequestsPath = '/incoming-requests';
  static const String requestDetailsPath = '/request-details';
  static const String acceptBookingPath = '/accept-booking';
  static const String bookingConfirmedPath = '/booking-confirmed';
  static const String startMatchPath = '/start-match';

  static const String matchesRoute = matchesPath;
  static const String matchVerificationRoute = matchVerificationPath;
  static const String conductTossRoute = conductTossPath;
  static const String liveScoringRoute = liveScoringPath;
  static const String incomingRequestsRoute = incomingRequestsPath;
  static const String requestDetailsRoute = requestDetailsPath;
  static const String acceptBookingRoute = acceptBookingPath;
  static const String bookingConfirmedRoute = bookingConfirmedPath;
  static const String startMatchRoute = startMatchPath;

  /// Root navigator key so global flows (e.g. session expiry) can show
  /// dialogs and route back to login from anywhere.
  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();

  static final GoRouter router = GoRouter(
    navigatorKey: navigatorKey,
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
          body: ScheduleMatchesScreen(),
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
      GoRoute(
        path: incomingRequestsPath,
        name: 'incomingRequests',
        builder: (context, state) => const IncomingRequestsScreen(),
      ),
      GoRoute(
        path: requestDetailsPath,
        name: 'requestDetails',
        builder: (context, state) => RequestDetailsScreen(
          request: state.extra is RefereeMatchRequestResponse
              ? state.extra as RefereeMatchRequestResponse
              : null,
          requestId: state.uri.queryParameters['requestId'],
        ),
      ),
      GoRoute(
        path: acceptBookingPath,
        name: 'acceptBooking',
        builder: (context, state) => AcceptBookingScreen(
          request: state.extra is RefereeMatchRequestResponse
              ? state.extra as RefereeMatchRequestResponse
              : null,
          requestId: state.uri.queryParameters['requestId'],
        ),
      ),
      GoRoute(
        path: bookingConfirmedPath,
        name: 'bookingConfirmed',
        builder: (context, state) => BookingConfirmedScreen(
          request: state.extra is RefereeMatchRequestResponse
              ? state.extra as RefereeMatchRequestResponse
              : null,
          requestId: state.uri.queryParameters['requestId'],
        ),
      ),
      GoRoute(
        path: startMatchPath,
        name: 'startMatch',
        builder: (context, state) => StartMatchScreen(
          match: state.extra is BeforeTossMatch
              ? state.extra as BeforeTossMatch
              : null,
          matchId: state.uri.queryParameters['matchId'],
        ),
      ),
    ],
  );
}
