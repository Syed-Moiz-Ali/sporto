import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/views/auth_flow_view.dart';
import '../../features/referee_booking/application/booking_bloc.dart';
import '../../features/referee_booking/application/booking_repository.dart';
import '../../features/referee_booking/presentation/screens/booking_list_screen.dart';
import '../../features/referee_booking/presentation/screens/booking_location_screen.dart';
import '../../features/referee_booking/presentation/screens/booking_overview_screen.dart';
import '../../features/referee_booking/presentation/screens/booking_schedule_screen.dart';
import '../../features/referee_booking/presentation/screens/booking_success_screen.dart';
import '../../features/referee_booking/presentation/screens/confirm_booking_screen.dart';
import '../../features/referee_booking/presentation/screens/payment_screen.dart';
import '../../features/referee_booking/presentation/screens/select_sport_screen.dart';
import '../../features/tournaments/presentation/screens/create_tournament_wizard_screen.dart';
import '../../features/tournaments/presentation/screens/tournament_detail_screen.dart';

/// Central route table for the partner app.
abstract final class AppRouter {
  static const String homePath = '/';
  static const String tournamentDetailPath = '/tournaments/:id';
  static const String createTournamentPath = '/create-tournament';
  static const String matchHistoryPath = '/match-history';
  static const String schedulePath = '/schedule';
  static const String refereeBookingListPath = '/book-referee/bookings';
  static const String refereeBookingOverviewPath = '/book-referee/overview';
  static const String selectSportPath = '/book-referee/sport';
  static const String selectLocationPath = '/book-referee/location';
  static const String schedulePath2 = '/book-referee/schedule';
  static const String confirmBookingPath = '/book-referee/confirm';
  static const String paymentPath = '/book-referee/payment';
  static const String bookingSuccessPath = '/book-referee/success';

  static String tournamentDetailRoute(String tournamentId) =>
      '/tournaments/$tournamentId';

  static const String createTournamentRoute = createTournamentPath;
  static const String matchHistoryRoute = matchHistoryPath;
  static const String profileRoute = '$homePath?tab=profile';
  static const String scheduleRoute = schedulePath;

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
        builder: (context, state) => AuthFlowView(
          initialTabIndex:
              state.uri.queryParameters['tab'] == 'profile' ? 4 : 0,
        ),
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
        builder: (context, state) => const AuthFlowView(initialTabIndex: 1),
      ),
      GoRoute(
        path: schedulePath,
        name: 'schedule',
        builder: (context, state) => const AuthFlowView(initialTabIndex: 2),
      ),
      // The whole referee-booking flow shares ONE BookingBloc so selections
      // (sport/location/referee) persist across the steps.
      ShellRoute(
        builder: (context, state, child) => BlocProvider<BookingBloc>(
          create: (_) => BookingBloc(MockBookingRepository())
            ..add(const BookingLoad()),
          child: child,
        ),
        routes: [
          GoRoute(
            path: refereeBookingListPath,
            name: 'refereeBookingList',
            builder: (context, state) => const BookingListScreen(),
          ),
          GoRoute(
            path: refereeBookingOverviewPath,
            name: 'refereeBookingOverview',
            builder: (context, state) => const BookingOverviewScreen(),
          ),
          GoRoute(
            path: selectSportPath,
            name: 'selectSport',
            builder: (context, state) => const SelectSportScreen(),
          ),
          GoRoute(
            path: selectLocationPath,
            name: 'selectLocation',
            builder: (context, state) => const BookingLocationScreen(),
          ),
          GoRoute(
            path: schedulePath2,
            name: 'bookingSchedule',
            builder: (context, state) => const BookingScheduleScreen(),
          ),
          GoRoute(
            path: confirmBookingPath,
            name: 'confirmBooking',
            builder: (context, state) => const ConfirmBookingScreen(),
          ),
          GoRoute(
            path: paymentPath,
            name: 'bookingPayment',
            builder: (context, state) => const PaymentScreen(),
          ),
          GoRoute(
            path: bookingSuccessPath,
            name: 'bookingSuccess',
            builder: (context, state) => const BookingSuccessScreen(),
          ),
        ],
      ),
    ],
  );
}
