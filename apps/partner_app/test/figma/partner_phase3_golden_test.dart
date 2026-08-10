import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:partner_app/features/tournaments/presentation/screens/create_tournament_wizard_screen.dart';
import 'package:partner_app/features/tournaments/presentation/screens/match_detail_screen.dart';
import 'package:partner_app/features/tournaments/presentation/screens/schedule_screen.dart';
import 'package:ui_kit/ui_kit.dart';

void main() {
  for (final sport in const ['badminton', 'football']) {
    testWidgets('phase3 $sport tournament configuration', (tester) async {
      await _fonts();
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = const Size(390, 1177);
      addTearDown(tester.view.resetDevicePixelRatio);
      addTearDown(tester.view.resetPhysicalSize);
      await tester.pumpWidget(MaterialApp(theme: SportoTheme.darkTheme,
        home: const CreateTournamentWizardScreen(initialStep: 1)));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('choose_sport')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(Key('sport_$sport')));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      await expectLater(find.byType(CreateTournamentWizardScreen),
        matchesGoldenFile('goldens/phase3_${sport}_390.png'));
    });
  }

  testWidgets('phase3 schedules', (tester) async {
    await _fonts();
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(390, 1012);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);
    await tester.pumpWidget(MaterialApp(theme: SportoTheme.darkTheme, home: const ScheduleScreen()));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    await expectLater(find.byType(ScheduleScreen), matchesGoldenFile('goldens/phase3_schedule_390.png'));
  });

  testWidgets('phase3 long tournament overview', (tester) async {
    await _fonts();
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(390, 2000);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);
    await tester.pumpWidget(MaterialApp(theme: SportoTheme.darkTheme, home: const TournamentDetailScreen()));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    await expectLater(find.byType(TournamentDetailScreen), matchesGoldenFile('goldens/phase3_overview_390.png'));
  });

  for (final size in const [Size(320,568), Size(430,932)]) {
    testWidgets('phase3 responsive ${size.width}', (tester) async {
      tester.view.devicePixelRatio=1; tester.view.physicalSize=size;
      addTearDown(tester.view.resetDevicePixelRatio); addTearDown(tester.view.resetPhysicalSize);
      for (final child in <Widget>[
        const CreateTournamentWizardScreen(initialStep: 1),
        const ScheduleScreen(), const TournamentDetailScreen(),
      ]) {
        await tester.pumpWidget(MaterialApp(theme: SportoTheme.darkTheme, home: child));
        await tester.pumpAndSettle(); expect(tester.takeException(), isNull);
      }
    });
  }
}

Future<void> _fonts() async {
  for (final f in const {'MaterialIcons':'fonts/MaterialIcons-Regular.otf',
    'packages/ui_kit/Quicksand':'packages/ui_kit/assets/fonts/Quicksand-Variable.ttf'}.entries) {
    final loader=FontLoader(f.key)..addFont(rootBundle.load(f.value)); await loader.load();
  }
}
