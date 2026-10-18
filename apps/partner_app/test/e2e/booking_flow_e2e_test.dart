import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:partner_app/features/referee_booking/application/booking_bloc.dart';
import 'package:partner_app/features/referee_booking/application/booking_repository.dart';
import 'package:partner_app/features/referee_booking/presentation/screens/booking_details_screen.dart';
import 'package:partner_app/features/referee_booking/presentation/screens/booking_list_screen.dart';
import 'package:partner_app/features/referee_booking/presentation/screens/booking_location_screen.dart';
import 'package:partner_app/features/referee_booking/presentation/screens/booking_schedule_screen.dart';
import 'package:partner_app/features/referee_booking/presentation/screens/booking_success_screen.dart';
import 'package:partner_app/features/referee_booking/presentation/screens/booking_summary_screen.dart';
import 'package:partner_app/features/referee_booking/presentation/screens/choose_referee_screen.dart';
import 'package:partner_app/features/referee_booking/presentation/screens/confirm_booking_screen.dart';
import 'package:partner_app/features/referee_booking/presentation/screens/payment_screen.dart';
import 'package:partner_app/features/referee_booking/presentation/screens/rate_review_screen.dart';
import 'package:partner_app/features/referee_booking/presentation/screens/referee_profile_screen.dart';
import 'package:partner_app/features/referee_booking/presentation/screens/select_sport_screen.dart';
import 'package:ui_kit/ui_kit.dart';

/// End-to-end walkthrough of both booking flows via routed navigation.
void main() {
  GoRouter router() => GoRouter(
        initialLocation: '/book-referee/sport',
        routes: [
          ShellRoute(
            builder: (context, state, child) => BlocProvider<BookingBloc>(
              create: (_) => BookingBloc(MockBookingRepository.instant(seed: 1))
                ..add(const BookingLoad()),
              child: child,
            ),
            routes: [
              GoRoute(
                  path: '/book-referee/sport',
                  builder: (c, s) => const SelectSportScreen()),
              GoRoute(
                  path: '/book-referee/location',
                  builder: (c, s) => const BookingLocationScreen()),
              GoRoute(
                  path: '/book-referee/schedule',
                  builder: (c, s) => const BookingScheduleScreen()),
              GoRoute(
                  path: '/book-referee/confirm',
                  builder: (c, s) => const ConfirmBookingScreen()),
              GoRoute(
                  path: '/book-referee/payment',
                  builder: (c, s) => const PaymentScreen()),
              GoRoute(
                  path: '/book-referee/success',
                  builder: (c, s) => const BookingSuccessScreen()),
              GoRoute(
                path: '/book-referee/referee',
                builder: (c, s) => const ChooseRefereeScreen(),
                routes: [
                  GoRoute(
                      path: ':id',
                      builder: (c, s) => const RefereeProfileScreen()),
                ],
              ),
              GoRoute(
                  path: '/book-referee/summary',
                  builder: (c, s) => const BookingSummaryScreen()),
              GoRoute(
                  path: '/book-referee/bookings',
                  builder: (c, s) => const BookingListScreen()),
              GoRoute(
                  path: '/bookings/:id',
                  builder: (c, s) => const BookingDetailsScreen()),
              GoRoute(
                  path: '/bookings/review',
                  builder: (c, s) => const RateReviewScreen()),
            ],
          ),
        ],
      );

  Future<void> settle(WidgetTester tester) async {
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    await tester.pump();
  }

  Future<void> tap(WidgetTester tester, Finder f) async {
    await tester.tap(f);
    await settle(tester);
  }

  Future<void> start(WidgetTester tester) async {
    await _loadFonts();
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(390, 844);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);
    await tester.pumpWidget(MaterialApp.router(
      debugShowCheckedModeBanner: false,
      theme: SportoTheme.darkTheme,
      routerConfig: router(),
    ));
    await settle(tester);
  }

  testWidgets('Quick Book flow: sport -> location -> schedule -> confirm -> payment -> success',
      (tester) async {
    await start(tester);
    expect(find.byType(SelectSportScreen), findsOneWidget);
    expect(tester.takeException(), isNull);

    await tap(tester, find.text('Cricket'));
    expect(find.byType(BookingLocationScreen), findsOneWidget);

    await tap(tester, find.text('Use My Current Location'));
    expect(find.text('Kompally, Hyderabad'), findsWidgets);

    await tap(tester, find.text('Confirm & Continue'));
    expect(find.text('KPHB Indoor Stadium'), findsWidgets);

    await tap(tester, find.text('Confirm & Continue'));
    expect(find.text('Find Me a Referee'), findsOneWidget);
    expect(find.text('Choose Your Referee'), findsOneWidget);

    await tap(tester, find.text('Quick Book'));
    expect(find.byType(BookingScheduleScreen), findsOneWidget);
    expect(find.text('Booking Type'), findsOneWidget);

    await tap(tester, find.text('Register Individually'));
    expect(find.byType(ConfirmBookingScreen), findsOneWidget);

    await tap(tester, find.text('Proceed To Booking'));
    expect(find.byType(PaymentScreen), findsOneWidget);

    await tap(tester, find.text('Pay \u20B91385'));
    expect(find.byType(BookingSuccessScreen), findsOneWidget);
    expect(find.text('REFEREE FOUND!'), findsOneWidget);

    expect(tester.takeException(), isNull);
  });

  testWidgets(
      'Choose Referee flow: sport -> location -> list -> profile -> summary -> payment -> success',
      (tester) async {
    await start(tester);
    await tap(tester, find.text('Cricket'));
    await tap(tester, find.text('Use My Current Location'));
    await tap(tester, find.text('Confirm & Continue'));
    await tap(tester, find.text('Confirm & Continue'));

    await tap(tester, find.text('Browse Referees'));
    expect(find.byType(ChooseRefereeScreen), findsOneWidget);
    expect(find.text('Sort By'), findsOneWidget);

    await tap(tester, find.text('Suresh Reddy'));
    expect(find.byType(RefereeProfileScreen), findsOneWidget);
    expect(find.text('Book This Referee'), findsOneWidget);

    await tap(tester, find.text('Book This Referee'));
    expect(find.byType(BookingSummaryScreen), findsOneWidget);

    await tap(tester, find.text('Confirm & Pay \u20B91440'));
    expect(find.byType(PaymentScreen), findsOneWidget);
    // choose-referee branch → referee summary + ₹1440
    expect(find.text('Vijay Mohan'), findsWidgets);

    await tap(tester, find.text('Pay \u20B91440'));
    expect(find.byType(BookingSuccessScreen), findsOneWidget);
    expect(find.text('BOOKING CONFIRMED!'), findsOneWidget);

    expect(tester.takeException(), isNull);
  });

  testWidgets('Booking list -> details -> rate & review',
      (tester) async {
    await start(tester);
    expect(find.byType(SelectSportScreen), findsOneWidget);
    await tester.pumpWidget(MaterialApp.router(
      theme: SportoTheme.darkTheme,
      routerConfig: GoRouter(
        initialLocation: '/book-referee/bookings',
        routes: [
          ShellRoute(
            builder: (context, state, child) => BlocProvider<BookingBloc>(
              create: (_) => BookingBloc(MockBookingRepository.instant(seed: 1))
                ..add(const BookingLoad()),
              child: child,
            ),
            routes: [
              GoRoute(
                  path: '/book-referee/bookings',
                  builder: (c, s) => const BookingListScreen()),
              GoRoute(
                  path: '/bookings/:id',
                  builder: (c, s) => const BookingDetailsScreen()),
              GoRoute(
                  path: '/bookings/review',
                  builder: (c, s) => const RateReviewScreen()),
            ],
          ),
        ],
      ),
    ));
    await settle(tester);
    expect(find.byType(BookingListScreen), findsOneWidget);
    expect(find.text('Suresh Reddy'), findsWidgets);

    await tap(tester, find.text('Suresh Reddy').first);
    expect(find.byType(BookingDetailsScreen), findsOneWidget);
    expect(find.text('Booking Details'), findsWidgets);

    expect(tester.takeException(), isNull);
  });
}

Future<void> _loadFonts() async {
  for (final font in const {
    'MaterialIcons': ['fonts/MaterialIcons-Regular.otf'],
    'packages/ui_kit/Quicksand': [
      'packages/ui_kit/assets/fonts/Quicksand-Regular.ttf',
      'packages/ui_kit/assets/fonts/Quicksand-Medium.ttf',
      'packages/ui_kit/assets/fonts/Quicksand-SemiBold.ttf',
      'packages/ui_kit/assets/fonts/Quicksand-Bold.ttf',
    ],
  }.entries) {
    final loader = FontLoader(font.key);
    for (final asset in font.value) {
      loader.addFont(rootBundle.load(asset));
    }
    await loader.load();
  }
}
