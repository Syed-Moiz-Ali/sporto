import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:referee_data/referee_data.dart';
import 'package:shared_domain/shared_domain.dart';
import 'package:ui_kit/ui_kit.dart';

import '../../../core/di/dependency_injector.dart';
import '../../../features/auth/presentation/views/auth_flow_view.dart';
import '../../../features/availability/application/weekly_availability_cubit.dart';
import '../../../features/availability/presentation/screens/manage_availability_screen.dart';
import '../../../features/bank/presentation/screens/add_bank_account_screen.dart';
import '../../../features/bank/presentation/screens/bank_account_details_screen.dart';
import '../../../features/bank/presentation/screens/bank_accounts_screen.dart';
import '../../../features/bank/presentation/screens/bank_onboarding_screen.dart';
import '../../../features/matches/presentation/screens/accept_booking_screen.dart';
import '../../../features/matches/presentation/screens/booking_confirmed_screen.dart';
import '../../../features/matches/presentation/screens/booking_session_screen.dart';
import '../../../features/matches/presentation/screens/conduct_toss_wizard.dart';
import '../../../features/matches/presentation/screens/full_scorecard_screen.dart';
import '../../../features/matches/presentation/screens/incoming_requests_screen.dart';
import '../../../features/matches/presentation/screens/live_scoring_screen.dart';
import '../../../features/matches/presentation/screens/match_result_screen.dart';
import '../../../features/matches/presentation/screens/match_summary_screen.dart';
import '../../../features/matches/presentation/screens/schedule_matches_screen.dart';
import '../../../features/matches/presentation/screens/match_verification_screen.dart';
import '../../../features/matches/presentation/screens/referee_match_history_screen.dart';
import '../../../features/matches/presentation/screens/request_details_screen.dart';
import '../../../features/matches/presentation/screens/start_match_screen.dart';
import '../../../features/matches/presentation/widgets/before_toss_widgets.dart';
import '../../../features/notifications/presentation/notification_models.dart';
import '../../../features/notifications/presentation/screens/notification_category_screen.dart';
import '../../../features/notifications/presentation/screens/notification_settings_screen.dart';
import '../../../features/pricing/presentation/screens/my_pricing_screen.dart';
import '../../../features/wallet/presentation/screens/tournaments_history_screen.dart';
import '../../../features/wallet/presentation/screens/transaction_details_screen.dart';
import '../../../features/wallet/presentation/screens/wallet_screen.dart';
import '../../../features/wallet/presentation/screens/wallet_transactions_screen.dart';

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
  static const String matchResultPath = '/match-result';
  static const String matchSummaryPath = '/match-summary';
  static const String matchScorecardPath = '/match-scorecard';
  static const String bookingSessionPath = '/booking-session';
  static const String availabilityPath = '/availability';
  static const String notificationSettingsPath = '/notification-settings';
  static const String notificationCategoryPath = '/notification-category';
  static const String tournamentsHistoryPath = '/tournaments-history';
  static const String myPricingPath = '/my-pricing';
  static const String walletPath = '/wallet';
  static const String walletTransactionsPath = '/wallet-transactions';
  static const String transactionDetailsPath = '/transaction-details';
  static const String bankOnboardingPath = '/bank-onboarding';
  static const String addBankAccountPath = '/add-bank-account';
  static const String bankAccountsPath = '/bank-accounts';
  static const String bankAccountDetailsPath = '/bank-account-details';

  static const String matchesRoute = matchesPath;
  static const String matchVerificationRoute = matchVerificationPath;
  static const String conductTossRoute = conductTossPath;
  static const String liveScoringRoute = liveScoringPath;
  static const String incomingRequestsRoute = incomingRequestsPath;
  static const String requestDetailsRoute = requestDetailsPath;
  static const String acceptBookingRoute = acceptBookingPath;
  static const String bookingConfirmedRoute = bookingConfirmedPath;
  static const String startMatchRoute = startMatchPath;
  static const String matchResultRoute = matchResultPath;
  static const String matchSummaryRoute = matchSummaryPath;
  static const String matchScorecardRoute = matchScorecardPath;
  static const String bookingSessionRoute = bookingSessionPath;
  static const String notificationSettingsRoute = notificationSettingsPath;
  static const String tournamentsHistoryRoute = tournamentsHistoryPath;
  static const String walletRoute = walletPath;
  static const String walletTransactionsRoute = walletTransactionsPath;
  static const String transactionDetailsRoute = transactionDetailsPath;
  static const String bankOnboardingRoute = bankOnboardingPath;
  static const String addBankAccountRoute = addBankAccountPath;
  static const String bankAccountsRoute = bankAccountsPath;
  static const String bankAccountDetailsRoute = bankAccountDetailsPath;

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
          bookingId: state.uri.queryParameters['bookingId'],
          skipTossOtp: state.uri.queryParameters['skipTossOtp'] == 'true',
        ),
      ),
      GoRoute(
        path: matchHistoryPath,
        builder: (context, state) => const RefereeMatchHistoryScreen(),
      ),
      GoRoute(
        path: matchResultPath,
        name: 'matchResult',
        builder: (context, state) => MatchResultScreen(
          matchId: state.uri.queryParameters['matchId'],
        ),
      ),
      GoRoute(
        path: matchSummaryPath,
        name: 'matchSummary',
        builder: (context, state) => MatchSummaryScreen(
          matchId: state.uri.queryParameters['matchId'],
          match: state.extra is RefereeMatchResponse
              ? state.extra as RefereeMatchResponse
              : null,
        ),
      ),
      GoRoute(
        path: matchScorecardPath,
        name: 'matchScorecard',
        builder: (context, state) => FullScorecardScreen(
          matchId: state.uri.queryParameters['matchId'],
          match: state.extra is RefereeMatchResponse
              ? state.extra as RefereeMatchResponse
              : null,
          initialTeamId: int.tryParse(
            state.uri.queryParameters['teamId'] ?? '',
          ),
        ),
      ),
      GoRoute(
        path: notificationSettingsPath,
        name: 'notificationSettings',
        builder: (context, state) => const NotificationSettingsScreen(),
      ),
      GoRoute(
        path: notificationCategoryPath,
        name: 'notificationCategory',
        builder: (context, state) {
          final requested = state.uri.queryParameters['category'] ?? '';
          final category = NotificationCategory.values.firstWhere(
            (value) => value.id == requested,
            orElse: () => NotificationCategory.match,
          );
          return NotificationCategoryScreen(category: category);
        },
      ),
      GoRoute(
        path: tournamentsHistoryPath,
        name: 'tournamentsHistory',
        builder: (context, state) => const TournamentsHistoryScreen(),
      ),
      GoRoute(
        path: myPricingPath,
        name: 'myPricing',
        builder: (context, state) => const MyPricingScreen(),
      ),
      GoRoute(
        path: walletPath,
        name: 'wallet',
        builder: (context, state) => const WalletScreen(),
      ),
      GoRoute(
        path: walletTransactionsPath,
        name: 'walletTransactions',
        builder: (context, state) => const WalletTransactionsScreen(),
      ),
      GoRoute(
        path: transactionDetailsPath,
        name: 'transactionDetails',
        builder: (context, state) => const TransactionDetailsScreen(),
      ),
      GoRoute(
        path: bankOnboardingPath,
        name: 'bankOnboarding',
        builder: (context, state) => const BankOnboardingScreen(),
      ),
      GoRoute(
        path: addBankAccountPath,
        name: 'addBankAccount',
        builder: (context, state) => const AddBankAccountScreen(),
      ),
      GoRoute(
        path: bankAccountsPath,
        name: 'bankAccounts',
        builder: (context, state) => const BankAccountsScreen(),
      ),
      GoRoute(
        path: bankAccountDetailsPath,
        name: 'bankAccountDetails',
        builder: (context, state) => const BankAccountDetailsScreen(),
      ),
      GoRoute(
        path: bookingSessionPath,
        name: 'bookingSession',
        builder: (context, state) => BookingSessionScreen(
          bookingId: state.uri.queryParameters['bookingId'],
          matchId: state.uri.queryParameters['matchId'],
        ),
      ),
      GoRoute(
        path: liveScoringPath,
        name: 'liveScoring',
        builder: (context, state) => LiveScoringScreen(
          matchId: state.uri.queryParameters['matchId'],
          matchCode: state.uri.queryParameters['matchCode'],
          bookingId: state.uri.queryParameters['bookingId'],
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
          bookingId: state.uri.queryParameters['bookingId'],
        ),
      ),
      GoRoute(
        path: availabilityPath,
        name: 'availability',
        builder: (context, state) => BlocProvider<WeeklyAvailabilityCubit>(
          create: (_) =>
              DependencyInjector.instance.createWeeklyAvailabilityCubit()
                ..load(),
          child: const ManageAvailabilityScreen(),
        ),
      ),
    ],
  );
}
