import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:partner_app/features/tournaments/presentation/screens/match_detail_screen.dart';
import 'package:partner_app/features/tournaments/presentation/screens/team_details_screen.dart';
import 'package:ui_kit/ui_kit.dart';

void main() {
  for (final state in const <(String, int)>[
    ('overview', 0),
    ('teams', 1),
    ('referees', 2),
    ('schedule', 3),
    ('venues', 4),
  ]) {
    testWidgets('Partner match detail ${state.$1} phase1 render',
        (tester) async {
      await _loadFonts();
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = const Size(390, 1156);
      addTearDown(tester.view.resetDevicePixelRatio);
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: SportoTheme.darkTheme,
        home: TournamentDetailScreen(initialTabIndex: state.$2),
      ));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      await expectLater(
        find.byType(TournamentDetailScreen),
        matchesGoldenFile('goldens/partner_match_${state.$1}_390x1156.png'),
      );
    });
  }

  for (final size in const [Size(320, 568), Size(430, 932)]) {
    testWidgets('Partner match states remain responsive at ${size.width}',
        (tester) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = size;
      addTearDown(tester.view.resetDevicePixelRatio);
      addTearDown(tester.view.resetPhysicalSize);
      for (var tab = 0; tab < 5; tab++) {
        await tester.pumpWidget(MaterialApp(
          theme: SportoTheme.darkTheme,
          home: TournamentDetailScreen(initialTabIndex: tab),
        ));
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
      }
    });
  }

  testWidgets('Partner team detail phase1 render', (tester) async {
    await _loadFonts();
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(390, 844);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);
    await tester.pumpWidget(MaterialApp(
      theme: SportoTheme.darkTheme,
      home: const TeamDetailsScreen(),
    ));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    await expectLater(find.byType(TeamDetailsScreen),
        matchesGoldenFile('goldens/partner_team_details_390x844.png'));
  });
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
