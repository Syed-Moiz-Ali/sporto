import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:referee_app/features/matches/presentation/screens/match_verification_screen.dart';
import 'package:ui_kit/ui_kit.dart';

void main() {
  testWidgets('Match Verification Figma reference render', (tester) async {
    await _loadFonts();
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(390, 993);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(
      MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: SportoTheme.darkTheme,
        home: const RepaintBoundary(child: MatchVerificationScreen()),
      ),
    );
    await tester.pumpAndSettle();

    await expectLater(
      find.byType(MatchVerificationScreen),
      matchesGoldenFile('goldens/match_verification_390x993.png'),
    );
  });
}

Future<void> _loadFonts() async {
  for (final font in const {
    'MaterialIcons': 'fonts/MaterialIcons-Regular.otf',
    'packages/ui_kit/Quicksand':
        'packages/ui_kit/assets/fonts/Quicksand-Variable.ttf',
    'packages/ui_kit/Inter':
        'packages/ui_kit/assets/fonts/Inter-Variable.ttf',
    'packages/ui_kit/Mulish':
        'packages/ui_kit/assets/fonts/Mulish-Variable.ttf',
  }.entries) {
    final loader = FontLoader(font.key)..addFont(rootBundle.load(font.value));
    await loader.load();
  }
}
