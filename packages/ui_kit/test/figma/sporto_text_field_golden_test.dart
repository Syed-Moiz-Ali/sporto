import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ui_kit/ui_kit.dart';

void main() {
  testWidgets('Sporto text fields use Figma surface and focus border',
      (tester) async {
    await _loadFonts();
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(390, 260);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(
      MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: SportoTheme.darkTheme,
        home: const Scaffold(
          body: Padding(
            padding: EdgeInsets.all(20),
            child: Column(
              children: [
                SportoTextField(
                  label: 'First Name',
                  hint: 'Enter your first name',
                ),
                SizedBox(height: 24),
                SportoTextField(
                  label: 'Email Address',
                  hint: 'Enter your email address',
                  labelInside: true,
                ),
              ],
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.byType(TextField).last);
    await tester.pump(const Duration(milliseconds: 800));

    await expectLater(
      find.byType(Scaffold),
      matchesGoldenFile('goldens/sporto_text_field_390x260.png'),
    );
  });

  testWidgets('Sporto text field scales up on wider phones', (tester) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(430, 300);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(
      MaterialApp(
        theme: SportoTheme.darkTheme,
        home: const Scaffold(
          body: Padding(
            padding: EdgeInsets.all(20),
            child: SportoTextField(hint: 'Mobile-sized field'),
          ),
        ),
      ),
    );

    final surfaceFinder =
        find.byKey(const ValueKey('sporto_text_field_surface'));
    final surface = tester.widget<Container>(surfaceFinder);
    expect(tester.getSize(surfaceFinder).height, closeTo(52.9, .1));
    final decoration = surface.decoration! as BoxDecoration;
    expect(decoration.border, isNotNull);
  });

  testWidgets('Sporto text field scales down safely on narrow phones',
      (tester) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(320, 240);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(
      MaterialApp(
        theme: SportoTheme.darkTheme,
        home: const Scaffold(
          body: Padding(
            padding: EdgeInsets.all(16),
            child: SportoTextField(hint: 'Narrow phone field'),
          ),
        ),
      ),
    );

    expect(
      tester
          .getSize(find.byKey(const ValueKey('sporto_text_field_surface')))
          .height,
      closeTo(44.16, .1),
    );
    expect(tester.takeException(), isNull);
  });
}

Future<void> _loadFonts() async {
  for (final font in const {
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
