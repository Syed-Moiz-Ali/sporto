import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ui_kit/ui_kit.dart';

void main() {
  testWidgets('Referee Login Figma reference render', (tester) async {
    await _loadFonts();
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(390, 844);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(
      MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: SportoTheme.darkTheme,
        home: PhoneLoginScreen(
          appRole: 'referee',
          onSendOtp: (_) {},
          onVerifyOtp: (_, __) {},
        ),
      ),
    );
    await tester.pumpAndSettle();

    await expectLater(
      find.byType(PhoneLoginScreen),
      matchesGoldenFile('goldens/referee_login_390x844.png'),
    );
  });

  for (final size in const [Size(320, 568), Size(390, 932), Size(430, 932)]) {
    testWidgets('Referee Login remains responsive at ${size.width.toInt()}px',
        (tester) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = size;
      addTearDown(tester.view.resetDevicePixelRatio);
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(
        MaterialApp(
          theme: SportoTheme.darkTheme,
          home: PhoneLoginScreen(
            appRole: 'referee',
            onSendOtp: (_) {},
            onVerifyOtp: (_, __) {},
          ),
        ),
      );
      await tester.pump();

      expect(find.byType(PhoneLoginScreen), findsOneWidget);
      if (size.height > 844) {
        final panelBottom = tester
            .getRect(find.byKey(const ValueKey('login-form-panel')))
            .bottom;
        expect(panelBottom, greaterThanOrEqualTo(size.height));
      }
      expect(tester.takeException(), isNull);
    });
  }
}

Future<void> _loadFonts() async {
  for (final font in const {
    'MaterialIcons': 'fonts/MaterialIcons-Regular.otf',
    'packages/ui_kit/Space Grotesk': 'assets/fonts/SpaceGrotesk-Variable.ttf',
    'packages/ui_kit/Quicksand': 'assets/fonts/Quicksand-Variable.ttf',
    'packages/ui_kit/Inter': 'assets/fonts/Inter-Variable.ttf',
    'packages/ui_kit/Mulish': 'assets/fonts/Mulish-Variable.ttf',
  }.entries) {
    final loader = FontLoader(font.key)..addFont(rootBundle.load(font.value));
    await loader.load();
  }
}
