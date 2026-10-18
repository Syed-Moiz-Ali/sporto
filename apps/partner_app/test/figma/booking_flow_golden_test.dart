import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:partner_app/features/referee_booking/application/booking_bloc.dart';
import 'package:partner_app/features/referee_booking/application/booking_repository.dart';
import 'package:partner_app/features/referee_booking/presentation/screens/booking_schedule_screen.dart';
import 'package:partner_app/features/referee_booking/presentation/screens/booking_success_screen.dart';
import 'package:partner_app/features/referee_booking/presentation/screens/confirm_booking_screen.dart';
import 'package:partner_app/features/referee_booking/presentation/screens/payment_screen.dart';
import 'package:ui_kit/ui_kit.dart';

/// Screens 8-12: schedule (2 states) + confirm + payment + success.
void main() {
  Future<void> render(WidgetTester tester, Widget screen,
      {BookingBloc? bloc, double height = 844}) async {
    await _loadFonts();
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = Size(390, height);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);

    final provider = BlocProvider<BookingBloc>(
      create: (_) => bloc ?? (BookingBloc(MockBookingRepository.instant(seed: 1))),
      child: screen,
    );
    await tester.pumpWidget(
      MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: SportoTheme.darkTheme,
        home: provider,
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));
    await tester.pump();
  }

  testWidgets('Schedule - Hourly (E1-08)', (tester) async {
    final bloc = BookingBloc(MockBookingRepository.instant(seed: 1));
    await render(tester, const BookingScheduleScreen(), bloc: bloc);
    await expectLater(
      find.byType(BookingScheduleScreen),
      matchesGoldenFile('goldens/booking_schedule_hourly_390x844.png'),
    );
  });

  testWidgets('Schedule - Daily (E1-12)', (tester) async {
    final bloc = BookingBloc(MockBookingRepository.instant(seed: 1))
      ..add(const BookingSelectScheduleMode(ScheduleMode.daily));
    await render(tester, const BookingScheduleScreen(), bloc: bloc);
    await expectLater(
      find.byType(BookingScheduleScreen),
      matchesGoldenFile('goldens/booking_schedule_daily_390x844.png'),
    );
  });

  testWidgets('Confirm Booking (E1-09)', (tester) async {
    await render(tester, const ConfirmBookingScreen());
    await expectLater(
      find.byType(ConfirmBookingScreen),
      matchesGoldenFile('goldens/confirm_booking_390x844.png'),
    );
  });

  testWidgets('Payment (E1-10)', (tester) async {
    await render(tester, const PaymentScreen());
    await expectLater(
      find.byType(PaymentScreen),
      matchesGoldenFile('goldens/payment_390x844.png'),
    );
  });

  testWidgets('Booking Success (E1-11)', (tester) async {
    await render(tester, const BookingSuccessScreen(), height: 976);
    await expectLater(
      find.byType(BookingSuccessScreen),
      matchesGoldenFile('goldens/booking_success_390x976.png'),
    );
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
