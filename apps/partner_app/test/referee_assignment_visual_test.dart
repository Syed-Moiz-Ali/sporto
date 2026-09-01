import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:partner_app/features/tournaments/presentation/screens/assign_referee_screen.dart';
import 'package:partner_app/features/tournaments/presentation/screens/match_detail_screen.dart';
import 'package:ui_kit/ui_kit.dart';

void main() {
  setUpAll(_loadFonts);

  testWidgets('assigned referees match reference', (tester) async {
    await _pumpPartnerScreen(
      tester,
      const TournamentDetailScreen(initialTabIndex: 2),
    );
    await expectLater(
      find.byType(TournamentDetailScreen),
      matchesGoldenFile('goldens/referee_assignment_assigned.png'),
    );
  });

  testWidgets('pending referee assignments match reference', (tester) async {
    await _pumpPartnerScreen(
      tester,
      const TournamentDetailScreen(initialTabIndex: 2),
    );
    await tester.tap(find.text('Pending'));
    await tester.pumpAndSettle();
    await expectLater(
      find.byType(TournamentDetailScreen),
      matchesGoldenFile('goldens/referee_assignment_pending.png'),
    );
  });

  testWidgets('assign referee picker matches reference', (tester) async {
    await _pumpPartnerScreen(
      tester,
      const AssignRefereeScreen(
        tournamentName: 'Hyderabad Super Cup',
        tournamentCode: 'SPT-20481',
      ),
    );
    await expectLater(
      find.byType(AssignRefereeScreen),
      matchesGoldenFile('goldens/referee_assignment_picker.png'),
    );
  });

  testWidgets('assigning a referee moves the match to Assigned',
      (tester) async {
    await _pumpPartnerScreen(
      tester,
      const TournamentDetailScreen(initialTabIndex: 2),
    );
    await tester.tap(find.text('Pending'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Assign Referee').first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Assign').first);
    await tester.pumpAndSettle();

    expect(find.text('Amit Verma'), findsOneWidget);
    expect(find.text('Assigned'), findsOneWidget);
  });
}

Future<void> _pumpPartnerScreen(WidgetTester tester, Widget screen) async {
  tester.view.devicePixelRatio = 1;
  tester.view.physicalSize = const Size(390, 844);
  addTearDown(tester.view.resetDevicePixelRatio);
  addTearDown(tester.view.resetPhysicalSize);
  await tester.pumpWidget(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: SportoTheme.darkTheme,
      home: SportoAppBackgroundScope(
        background: SportoAppBackground.partner,
        child: SportoAppTextScale(child: screen),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

Future<void> _loadFonts() async {
  for (final font in const {
    'MaterialIcons': ['fonts/MaterialIcons-Regular.otf'],
    'packages/ui_kit/Quicksand': [
      'packages/ui_kit/assets/fonts/Quicksand-Regular.ttf',
      'packages/ui_kit/assets/fonts/Quicksand-Medium.ttf',
      'packages/ui_kit/assets/fonts/Quicksand-SemiBold.ttf',
      'packages/ui_kit/assets/fonts/Quicksand-Bold.ttf',
    ],
  }.entries) {
    final loader = FontLoader(font.key);
    for (final asset in font.value) {
      loader.addFont(rootBundle.load(asset));
    }
    await loader.load();
  }
}
