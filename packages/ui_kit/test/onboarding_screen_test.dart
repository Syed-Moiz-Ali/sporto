import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ui_kit/ui_kit.dart';

void main() {
  testWidgets('partner onboarding uses a horizontal mobile carousel',
      (tester) async {
    await _loadFonts();
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      MaterialApp(
        theme: SportoTheme.darkTheme,
        home: OnboardingScreen(onGetStarted: () {}),
      ),
    );

    final pageView = tester.widget<PageView>(find.byType(PageView));
    expect(pageView.scrollDirection, Axis.horizontal);
    expect(find.text('POWER SPORTS.\nCREATE CHAMPIONS.'), findsOneWidget);

    await tester.drag(find.byType(PageView), const Offset(-500, 0));
    await tester.pump(const Duration(milliseconds: 500));
    expect(find.text('YOU ORGANISE.\nWE MARKET.'), findsOneWidget);

    await tester.drag(find.byType(PageView), const Offset(500, 0));
    await tester.pump(const Duration(milliseconds: 500));
    expect(find.text('POWER SPORTS.\nCREATE CHAMPIONS.'), findsOneWidget);

    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('skip completes onboarding immediately', (tester) async {
    await _loadFonts();
    var completed = false;
    await tester.pumpWidget(
      MaterialApp(
        theme: SportoTheme.darkTheme,
        home: OnboardingScreen(onGetStarted: () => completed = true),
      ),
    );

    await tester.tap(find.text('Skip'));
    expect(completed, isTrue);
    await tester.pumpWidget(const SizedBox.shrink());
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
  }.entries) {
    final loader = FontLoader(font.key);
    for (final asset in font.value) {
      loader.addFont(rootBundle.load(asset));
    }
    await loader.load();
  }
}
