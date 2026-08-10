import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:referee_app/features/matches/presentation/screens/conduct_toss_wizard.dart';
import 'package:referee_app/features/matches/presentation/screens/live_scoring_screen.dart';
import 'package:referee_app/features/matches/presentation/screens/matches_list_screen.dart';
import 'package:referee_app/features/matches/presentation/screens/profile_screen.dart';
import 'package:referee_app/features/matches/presentation/screens/referee_scoring_tab_screen.dart';
import 'package:ui_kit/ui_kit.dart';

void main() {
  testWidgets('phase4 referee scoring tab', (tester) async {
    await _fonts();
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(390, 844);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);
    await tester.pumpWidget(MaterialApp(
      theme: SportoTheme.darkTheme,
      home: Scaffold(
        body: Column(children: [
          const Expanded(child: RefereeScoringTabScreen()),
          SportoBottomNav(
            currentIndex: 2,
            onTap: (_) {},
            items: const [
              SportoNavItem(Icons.home_outlined, 'Home'),
              SportoNavItem(Icons.calendar_month_outlined, 'Matches'),
              SportoNavItem(Icons.sports_cricket_outlined, 'Scoring'),
              SportoNavItem(Icons.person_outline, 'Profile'),
            ],
          ),
        ]),
      ),
    ));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    await expectLater(find.byType(RefereeScoringTabScreen),
        matchesGoldenFile('goldens/phase4_scoring_tab.png'));
  });

  testWidgets('phase4 referee profile tab', (tester) async {
    await _fonts();
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(390, 858);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);
    await tester.pumpWidget(MaterialApp(
      theme: SportoTheme.darkTheme,
      home: Scaffold(
        body: Stack(children: [
          const SportoAmbientBackground(),
          const SafeArea(bottom: false, child: ProfileScreen()),
          Align(
            alignment: Alignment.bottomCenter,
            child: SportoBottomNav(
              currentIndex: 3,
              onTap: (_) {},
              items: const [
                SportoNavItem(Icons.home_outlined, 'Home'),
                SportoNavItem(Icons.calendar_month_outlined, 'Matches'),
                SportoNavItem(Icons.sports_cricket_outlined, 'Scoring'),
                SportoNavItem(Icons.person_outline, 'Profile'),
              ],
            ),
          ),
        ]),
      ),
    ));
    await tester.pumpAndSettle();
    final profileError = tester.takeException();
    if (profileError is FlutterError) {
      debugPrint(profileError.toStringDeep());
    }
    expect(profileError, isNull);
    await expectLater(find.byType(ProfileScreen),
        matchesGoldenFile('goldens/phase4_profile.png'));
  });

  testWidgets('phase4 referee matches tab', (tester) async {
    await _fonts();
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(390, 1012);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);
    await tester.pumpWidget(MaterialApp(
      theme: SportoTheme.darkTheme,
      home: Scaffold(
        body: Column(children: [
          const Expanded(child: MatchesListScreen()),
          SportoBottomNav(
            currentIndex: 1,
            onTap: (_) {},
            items: const [
              SportoNavItem(Icons.home_outlined, 'Home'),
              SportoNavItem(Icons.calendar_month_outlined, 'Matches'),
              SportoNavItem(Icons.sports_cricket_outlined, 'Scoring'),
              SportoNavItem(Icons.person_outline, 'Profile'),
            ],
          ),
        ]),
      ),
    ));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    await expectLater(find.byType(MatchesListScreen),
        matchesGoldenFile('goldens/phase4_matches.png'));
  });

  for (final view in RefereeScoringView.values) {
    testWidgets('phase4 scoring ${view.name}', (tester) async {
      await _fonts();
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = const Size(390, 844);
      addTearDown(tester.view.resetDevicePixelRatio);
      addTearDown(tester.view.resetPhysicalSize);
      await tester.pumpWidget(MaterialApp(
        theme: SportoTheme.darkTheme,
        home: LiveScoringScreen(initialView: view),
      ));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      await expectLater(
        find.byType(LiveScoringScreen),
        matchesGoldenFile('goldens/phase4_scoring_${view.name}.png'),
      );
    });
  }

  for (var step = 0; step < 5; step++) {
    testWidgets('phase4 toss step $step', (tester) async {
      await _fonts();
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = Size(390, step == 3 ? 1056 : 844);
      addTearDown(tester.view.resetDevicePixelRatio);
      addTearDown(tester.view.resetPhysicalSize);
      await tester.pumpWidget(MaterialApp(
        theme: SportoTheme.darkTheme,
        home: ConductTossWizard(initialStep: step),
      ));
      await tester.runAsync(() => precacheImage(
            const AssetImage('assets/images/toss_coin_heads.png'),
            tester.element(find.byType(ConductTossWizard)),
          ));
      if (step == 1) {
        await tester.runAsync(() => precacheImage(
              const AssetImage('assets/images/toss_coin_tails.png'),
              tester.element(find.byType(ConductTossWizard)),
            ));
      }
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      await expectLater(
        find.byType(ConductTossWizard),
        matchesGoldenFile('goldens/phase4_toss_step_$step.png'),
      );
    });
  }

  for (final width in const [320.0, 430.0]) {
    testWidgets('phase4 core flows remain responsive at $width',
        (tester) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = Size(width, 932);
      addTearDown(tester.view.resetDevicePixelRatio);
      addTearDown(tester.view.resetPhysicalSize);
      for (final child in const <Widget>[
        LiveScoringScreen(),
        LiveScoringScreen(initialView: RefereeScoringView.scoring),
        LiveScoringScreen(initialView: RefereeScoringView.submitted),
        ConductTossWizard(),
        ConductTossWizard(initialStep: 3),
      ]) {
        await tester
            .pumpWidget(MaterialApp(theme: SportoTheme.darkTheme, home: child));
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
      }
    });
  }
}

Future<void> _fonts() async {
  for (final font in const {
    'MaterialIcons': 'fonts/MaterialIcons-Regular.otf',
    'packages/ui_kit/Quicksand':
        'packages/ui_kit/assets/fonts/Quicksand-Variable.ttf',
  }.entries) {
    final loader = FontLoader(font.key)..addFont(rootBundle.load(font.value));
    await loader.load();
  }
}
