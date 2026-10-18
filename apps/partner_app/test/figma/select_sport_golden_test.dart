import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:partner_app/features/referee_booking/application/booking_bloc.dart';
import 'package:partner_app/features/referee_booking/application/booking_models.dart';
import 'package:partner_app/features/referee_booking/application/booking_repository.dart';
import 'package:partner_app/features/referee_booking/presentation/screens/select_sport_screen.dart';
import 'package:ui_kit/ui_kit.dart';

void main() {
  testWidgets('Select sport (E1-03) 390x844 reference render', (tester) async {
    await _loadFonts();
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(390, 844);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);

    final bloc = BookingBloc(MockBookingRepository.instant(seed: 1))
      ..add(const BookingSelectSport(Sport(id: 'cricket', name: 'Cricket')));

    await tester.pumpWidget(
      MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: SportoTheme.darkTheme,
        home: BlocProvider<BookingBloc>.value(
          value: bloc,
          child: const SelectSportScreen(),
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));
    await tester.pump();

    await tester.runAsync(() async {
      await precacheImage(
        const AssetImage(
          'assets/referee_booking/images/avatar_referee.png',
          package: 'ui_kit',
        ),
        tester.element(find.byType(MaterialApp)),
      );
    });
    await tester.pump();    await expectLater(
      find.byType(SelectSportScreen),
      matchesGoldenFile('goldens/select_sport_390x844.png'),
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

