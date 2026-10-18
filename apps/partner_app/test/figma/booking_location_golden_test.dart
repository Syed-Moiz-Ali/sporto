import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:partner_app/features/referee_booking/application/booking_bloc.dart';
import 'package:partner_app/features/referee_booking/application/booking_models.dart';
import 'package:partner_app/features/referee_booking/application/booking_repository.dart';
import 'package:partner_app/features/referee_booking/presentation/screens/booking_location_screen.dart';
import 'package:ui_kit/ui_kit.dart';

/// One golden per location state (E1-04 / E1-05 / E1-06 / E1-07), all 390x844.
void main() {
  Future<void> render(WidgetTester tester, BookingBloc bloc) async {
    await _loadFonts();
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(390, 844);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(
      MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: SportoTheme.darkTheme,
        home: BlocProvider<BookingBloc>.value(
          value: bloc,
          child: const BookingLocationScreen(),
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));
    await tester.pump();
  }

  BookingBloc baseBloc() =>
      BookingBloc(MockBookingRepository.instant(seed: 1))
        ..add(const BookingSelectSport(Sport(id: 'cricket', name: 'Cricket')));

  testWidgets('Location state 0 - search (E1-04)', (tester) async {
    await render(tester, baseBloc());
    await expectLater(
      find.byType(BookingLocationScreen),
      matchesGoldenFile('goldens/booking_location_state0_390x844.png'),
    );
  });

  testWidgets('Location state 1 - detected (E1-05)', (tester) async {
    final bloc = baseBloc()
      ..add(const BookingSelectLocation(
        Location(id: 'current', venue: 'Kompally', area: 'Kompally, Hyderabad'),
      ));
    await render(tester, bloc);
    await expectLater(
      find.byType(BookingLocationScreen),
      matchesGoldenFile('goldens/booking_location_state1_390x844.png'),
    );
  });

  testWidgets('Location state 2 - venue (E1-06)', (tester) async {
    final bloc = baseBloc()
      ..add(const BookingSelectLocation(
        Location(id: 'venue', venue: 'KPHB Indoor Stadium', area: 'Kompally, Hyderabad'),
      ))
      ..add(const BookingConfirmLocation());
    await render(tester, bloc);
    await expectLater(
      find.byType(BookingLocationScreen),
      matchesGoldenFile('goldens/booking_location_state2_390x844.png'),
    );
  });

  testWidgets('Location state 3 - booking type (E1-07)', (tester) async {
    final bloc = baseBloc()
      ..add(const BookingSelectLocation(
        Location(id: 'venue', venue: 'KPHB Indoor Stadium', area: 'Kompally, Hyderabad'),
      ))
      ..add(const BookingConfirmLocation())
      ..add(const BookingSelectBookingType());
    await render(tester, bloc);
    await expectLater(
      find.byType(BookingLocationScreen),
      matchesGoldenFile('goldens/booking_location_state3_390x844.png'),
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
