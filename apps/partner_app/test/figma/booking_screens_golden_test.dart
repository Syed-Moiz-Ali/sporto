import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:partner_app/features/referee_booking/application/booking_bloc.dart';
import 'package:partner_app/features/referee_booking/application/booking_repository.dart';
import 'package:partner_app/features/referee_booking/presentation/screens/booking_details_screen.dart';
import 'package:partner_app/features/referee_booking/presentation/screens/booking_success_screen.dart';
import 'package:partner_app/features/referee_booking/presentation/screens/booking_summary_screen.dart';
import 'package:partner_app/features/referee_booking/presentation/screens/choose_referee_screen.dart';
import 'package:partner_app/features/referee_booking/presentation/screens/payment_screen.dart';
import 'package:partner_app/features/referee_booking/presentation/screens/rate_review_screen.dart';
import 'package:partner_app/features/referee_booking/presentation/screens/referee_profile_screen.dart';
import 'package:ui_kit/ui_kit.dart';

/// Screens 13-17 + Package 2 (Booking Details x3, Rate & Review).
void main() {
  Future<void> render(WidgetTester tester, Widget screen,
      {BookingBloc? bloc, double height = 844}) async {
    await _loadFonts();
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = Size(390, height);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(
      MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: SportoTheme.darkTheme,
        home: BlocProvider<BookingBloc>(
          create: (_) => bloc ?? BookingBloc(MockBookingRepository.instant(seed: 1)),
          child: screen,
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));
    await tester.pump();
  }

  testWidgets('Choose Referee (E1-13)', (tester) async {
    await render(tester, const ChooseRefereeScreen());
    await tester.runAsync(() async {
      await precacheImage(
        const AssetImage(
          'assets/referee_booking/images/avatar_referee.png',
          package: 'ui_kit',
        ),
        tester.element(find.byType(MaterialApp)),
      );
    });
    await tester.pump();    await expectLater(find.byType(ChooseRefereeScreen),
        matchesGoldenFile('goldens/choose_referee_390x844.png'));
  });

  testWidgets('Referee Profile (E1-14)', (tester) async {
    await render(tester, const RefereeProfileScreen(), height: 935);
    await tester.runAsync(() async {
      await precacheImage(
        const AssetImage(
          'assets/referee_booking/images/avatar_referee.png',
          package: 'ui_kit',
        ),
        tester.element(find.byType(MaterialApp)),
      );
    });
    await tester.pump();    await expectLater(find.byType(RefereeProfileScreen),
        matchesGoldenFile('goldens/referee_profile_390x935.png'));
  });

  testWidgets('Booking Summary (E1-15)', (tester) async {
    await render(tester, const BookingSummaryScreen(), height: 935);
    await tester.runAsync(() async {
      await precacheImage(
        const AssetImage(
          'assets/referee_booking/images/avatar_referee.png',
          package: 'ui_kit',
        ),
        tester.element(find.byType(MaterialApp)),
      );
    });
    await tester.pump();    await expectLater(find.byType(BookingSummaryScreen),
        matchesGoldenFile('goldens/booking_summary_390x935.png'));
  });

  testWidgets('Payment - referee (E1-16)', (tester) async {
    final b = BookingBloc(MockBookingRepository.instant(seed: 1))
      ..add(const BookingChooseMode(BookingMode.choose));
    await render(tester, const PaymentScreen(), bloc: b);
    await tester.runAsync(() async {
      await precacheImage(
        const AssetImage(
          'assets/referee_booking/images/avatar_referee.png',
          package: 'ui_kit',
        ),
        tester.element(find.byType(MaterialApp)),
      );
    });
    await tester.pump();    await expectLater(find.byType(PaymentScreen),
        matchesGoldenFile('goldens/payment_referee_390x844.png'));
  });

  testWidgets('Success - confirmed (E1-17)', (tester) async {
    final b = BookingBloc(MockBookingRepository.instant(seed: 1))
      ..add(const BookingChooseMode(BookingMode.choose));
    await render(tester, const BookingSuccessScreen(), bloc: b, height: 976);
    await tester.runAsync(() async {
      await precacheImage(
        const AssetImage(
          'assets/referee_booking/images/avatar_referee.png',
          package: 'ui_kit',
        ),
        tester.element(find.byType(MaterialApp)),
      );
    });
    await tester.pump();    await expectLater(find.byType(BookingSuccessScreen),
        matchesGoldenFile('goldens/booking_success_referee_390x976.png'));
  });

  testWidgets('Booking Details - Upcoming', (tester) async {
    await render(tester, const BookingDetailsScreen(), height: 935);
    await tester.runAsync(() async {
      await precacheImage(
        const AssetImage(
          'assets/referee_booking/images/avatar_referee.png',
          package: 'ui_kit',
        ),
        tester.element(find.byType(MaterialApp)),
      );
    });
    await tester.pump();    await expectLater(find.byType(BookingDetailsScreen),
        matchesGoldenFile('goldens/booking_details_upcoming_390x935.png'));
  });

  testWidgets('Booking Details - Ongoing', (tester) async {
    final b = BookingBloc(MockBookingRepository.instant(seed: 1))
      ..add(const BookingSelectDetailsStatus(BookingDetailsStatus.ongoing));
    await render(tester, const BookingDetailsScreen(), bloc: b, height: 935);
    await tester.runAsync(() async {
      await precacheImage(
        const AssetImage(
          'assets/referee_booking/images/avatar_referee.png',
          package: 'ui_kit',
        ),
        tester.element(find.byType(MaterialApp)),
      );
    });
    await tester.pump();    await expectLater(find.byType(BookingDetailsScreen),
        matchesGoldenFile('goldens/booking_details_ongoing_390x935.png'));
  });

  testWidgets('Booking Details - Completed', (tester) async {
    final b = BookingBloc(MockBookingRepository.instant(seed: 1))
      ..add(const BookingSelectDetailsStatus(BookingDetailsStatus.completed));
    await render(tester, const BookingDetailsScreen(), bloc: b, height: 935);
    await tester.runAsync(() async {
      await precacheImage(
        const AssetImage(
          'assets/referee_booking/images/avatar_referee.png',
          package: 'ui_kit',
        ),
        tester.element(find.byType(MaterialApp)),
      );
    });
    await tester.pump();    await expectLater(find.byType(BookingDetailsScreen),
        matchesGoldenFile('goldens/booking_details_completed_390x935.png'));
  });

  testWidgets('Rate & Review', (tester) async {
    await render(tester, const RateReviewScreen());
    await tester.runAsync(() async {
      await precacheImage(
        const AssetImage(
          'assets/referee_booking/images/avatar_referee.png',
          package: 'ui_kit',
        ),
        tester.element(find.byType(MaterialApp)),
      );
    });
    await tester.pump();    await expectLater(find.byType(RateReviewScreen),
        matchesGoldenFile('goldens/rate_review_390x844.png'));
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

