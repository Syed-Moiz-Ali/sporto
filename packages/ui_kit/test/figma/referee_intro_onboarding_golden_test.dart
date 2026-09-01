import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ui_kit/ui_kit.dart';

void main() {
  setUpAll(_loadFonts);

  for (final entry in const <int, String>{
    0: 'welcome',
    1: 'booking',
    2: 'matches',
    3: 'payout',
    4: 'earnings',
    5: 'profile',
    6: 'journey',
    7: 'join',
  }.entries) {
    testWidgets('referee intro ${entry.value} matches mobile reference',
        (tester) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = const Size(390, 844);
      addTearDown(tester.view.resetDevicePixelRatio);
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(
        MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: SportoTheme.darkTheme,
          home: RefereeOnboardingScreen(
            initialPage: entry.key,
            onGetStarted: () {},
          ),
        ),
      );
      await tester.pumpAndSettle();

      await expectLater(
        find.byKey(const ValueKey('referee_onboarding_scaffold')),
        matchesGoldenFile(
          'goldens/referee_intro_onboarding_${entry.value}.png',
        ),
      );
    });
  }

  testWidgets('referee onboarding navigation follows the HTML flow',
      (tester) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(390, 844);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);
    var completed = false;
    await tester.pumpWidget(
      MaterialApp(
        theme: SportoTheme.darkTheme,
        home: RefereeOnboardingScreen(
          onGetStarted: () => completed = true,
        ),
      ),
    );

    expect(find.text('OFFICIAL REFEREE NETWORK'), findsOneWidget);
    await tester.tap(find.text('GET STARTED'));
    await tester.pumpAndSettle();
    expect(find.text('SCREEN 02 / MATCH REQUESTS'), findsOneWidget);

    await tester.tap(find.text('SKIP'));
    await tester.pumpAndSettle();
    expect(find.text('JOIN NOW'), findsOneWidget);
    expect(completed, isFalse);

    await tester.tap(find.text('BECOME A SPOTO REFEREE'));
    expect(completed, isTrue);
  });
}

Future<void> _loadFonts() async {
  for (final font in const {
    'MaterialIcons': ['fonts/MaterialIcons-Regular.otf'],
    'packages/ui_kit/Quicksand': [
      'assets/fonts/Quicksand-Regular.ttf',
      'assets/fonts/Quicksand-Medium.ttf',
      'assets/fonts/Quicksand-SemiBold.ttf',
      'assets/fonts/Quicksand-Bold.ttf',
    ],
    'packages/ui_kit/Inter': [
      'assets/fonts/Inter-Regular.ttf',
      'assets/fonts/Inter-Medium.ttf',
      'assets/fonts/Inter-SemiBold.ttf',
      'assets/fonts/Inter-Bold.ttf',
    ],
    'packages/ui_kit/Space Grotesk': [
      'assets/fonts/SpaceGrotesk-Regular.ttf',
      'assets/fonts/SpaceGrotesk-Medium.ttf',
      'assets/fonts/SpaceGrotesk-SemiBold.ttf',
      'assets/fonts/SpaceGrotesk-Bold.ttf',
    ],
  }.entries) {
    final loader = FontLoader(font.key);
    for (final asset in font.value) {
      loader.addFont(rootBundle.load(asset));
    }
    await loader.load();
  }
}
