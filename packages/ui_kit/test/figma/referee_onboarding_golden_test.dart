import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_domain/shared_domain.dart';
import 'package:ui_kit/ui_kit.dart';

void main() {
  testWidgets('Referee onboarding personal information reference render',
      (tester) async {
    await _loadFonts();
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(390, 844);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(
      MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: SportoTheme.darkTheme,
        home: AutomatedOnboardingWizard(
          user: const UserEntity(
            id: 'golden-referee',
            name: '',
            email: '',
            mobileNumber: '+91XXXXXXXXXX',
            role: 'referee',
          ),
          onComplete: (_) {},
        ),
      ),
    );
    await tester.pumpAndSettle();

    await expectLater(
      find.byType(AutomatedOnboardingWizard),
      matchesGoldenFile('goldens/referee_onboarding_personal_390x844.png'),
    );
  });

  testWidgets('Referee onboarding complete signup PNG state sequence',
      (tester) async {
    await _loadFonts();
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(390, 844);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(_onboardingApp());
    await tester.pumpAndSettle();

    for (var step = 2; step <= 6; step++) {
      await _tapVisible(tester, 'Continue');
      await expectLater(
        find.byType(AutomatedOnboardingWizard),
        matchesGoldenFile('goldens/referee_onboarding_step_$step.png'),
      );
    }

    await _tapVisible(tester, 'I confirm all information is accurate.');
    final submit = find.text('Submit Application');
    await tester.ensureVisible(submit);
    await tester.pumpAndSettle();
    await tester.tap(submit);
    await tester.pump(const Duration(seconds: 4));
    await expectLater(
      find.byType(AutomatedOnboardingWizard),
      matchesGoldenFile('goldens/referee_onboarding_submitted.png'),
    );

    await tester.pumpWidget(
      MaterialApp(
        theme: SportoTheme.darkTheme,
        home: const ApplicationStatusScreen(applicationRef: 'RF202600124'),
      ),
    );
    await tester.pumpAndSettle();
    await expectLater(
      find.byType(ApplicationStatusScreen),
      matchesGoldenFile('goldens/referee_application_status.png'),
    );
  });

  for (final size in const [Size(320, 568), Size(430, 932)]) {
    testWidgets('Onboarding remains usable through all steps at ${size.width}',
        (tester) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = size;
      addTearDown(tester.view.resetDevicePixelRatio);
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(_onboardingApp());
      await tester.pumpAndSettle();
      for (var step = 2; step <= 6; step++) {
        await _tapVisible(tester, 'Continue');
        expect(tester.takeException(), isNull);
      }
    });
  }
}

Widget _onboardingApp() => MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: SportoTheme.darkTheme,
      home: AutomatedOnboardingWizard(
        user: const UserEntity(
          id: 'golden-referee',
          name: '',
          email: '',
          mobileNumber: '+91XXXXXXXXXX',
          role: 'referee',
        ),
        onComplete: (_) {},
      ),
    );

Future<void> _tapVisible(WidgetTester tester, String text) async {
  final finder = find.text(text).last;
  await tester.ensureVisible(finder);
  await tester.pumpAndSettle();
  await tester.tap(finder);
  await tester.pumpAndSettle();
}

Future<void> _loadFonts() async {
  for (final font in const {
    'MaterialIcons': ['fonts/MaterialIcons-Regular.otf'],
    'packages/ui_kit/Space Grotesk': [
      'assets/fonts/SpaceGrotesk-Regular.ttf',
      'assets/fonts/SpaceGrotesk-Medium.ttf',
      'assets/fonts/SpaceGrotesk-SemiBold.ttf',
      'assets/fonts/SpaceGrotesk-Bold.ttf',
    ],
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
      'assets/fonts/Inter-Black.ttf',
    ],
  }.entries) {
    final loader = FontLoader(font.key);
    for (final asset in font.value) {
      loader.addFont(rootBundle.load(asset));
    }
    await loader.load();
  }
}
