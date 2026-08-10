import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:partner_app/features/tournaments/presentation/screens/create_tournament_wizard_screen.dart';
import 'package:partner_app/features/tournaments/presentation/screens/match_history_screen.dart';
import 'package:ui_kit/ui_kit.dart';

void main() {
  for (var step = 0; step < 6; step++) {
    testWidgets('Partner phase2 wizard step ${step + 1}', (tester) async {
      await _loadFonts();
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = Size(390, step == 4 ? 2000 : 1156);
      addTearDown(tester.view.resetDevicePixelRatio);
      addTearDown(tester.view.resetPhysicalSize);
      await tester.pumpWidget(MaterialApp(
        theme: SportoTheme.darkTheme,
        home: CreateTournamentWizardScreen(initialStep: step),
      ));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      await expectLater(
        find.byType(CreateTournamentWizardScreen),
        matchesGoldenFile('goldens/partner_wizard_step_${step + 1}.png'),
      );
    });
  }

  testWidgets("Partner phase2 today's matches", (tester) async {
    await _loadFonts();
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(390, 1000);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);
    await tester.pumpWidget(MaterialApp(
      theme: SportoTheme.darkTheme,
      home: const MatchHistoryScreen(),
    ));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    await expectLater(find.byType(MatchHistoryScreen),
        matchesGoldenFile('goldens/partner_today_matches_390x1000.png'));
  });

  testWidgets('Partner phase2 venue editor sheet', (tester) async {
    await _loadFonts();
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(390, 844);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);
    await tester.pumpWidget(MaterialApp(
      theme: SportoTheme.darkTheme,
      home: const CreateTournamentWizardScreen(initialStep: 3),
    ));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('add_venue_details')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));
    expect(tester.takeException(), isNull);
    await expectLater(find.byType(CreateTournamentWizardScreen),
        matchesGoldenFile('goldens/partner_venue_editor_390x844.png'));
  });

  for (final size in const [Size(320, 568), Size(430, 932)]) {
    testWidgets('Partner phase2 remains responsive at ${size.width}',
        (tester) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = size;
      addTearDown(tester.view.resetDevicePixelRatio);
      addTearDown(tester.view.resetPhysicalSize);
      for (var step = 0; step < 6; step++) {
        await tester.pumpWidget(MaterialApp(
          theme: SportoTheme.darkTheme,
          home: CreateTournamentWizardScreen(initialStep: step),
        ));
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
      }
      await tester.pumpWidget(MaterialApp(
        theme: SportoTheme.darkTheme,
        home: const MatchHistoryScreen(),
      ));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    });
  }
}

Future<void> _loadFonts() async {
  for (final font in const {
    'MaterialIcons': 'fonts/MaterialIcons-Regular.otf',
    'packages/ui_kit/Space Grotesk':
        'packages/ui_kit/assets/fonts/SpaceGrotesk-Variable.ttf',
    'packages/ui_kit/Quicksand':
        'packages/ui_kit/assets/fonts/Quicksand-Variable.ttf',
    'packages/ui_kit/Inter': 'packages/ui_kit/assets/fonts/Inter-Variable.ttf',
  }.entries) {
    final loader = FontLoader(font.key)..addFont(rootBundle.load(font.value));
    await loader.load();
  }
}
