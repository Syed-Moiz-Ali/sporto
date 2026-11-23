import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:partner_app/features/tournaments/presentation/screens/prize_pool_redesign_screen.dart';
import 'package:partner_data/partner_data.dart';
import 'package:ui_kit/ui_kit.dart';

/// 390×844 render of the Prize Pool screen for the Figma diff
/// (`screens/07_Prize-Pool/Prize-Pool@2x.png`).
void main() {
  testWidgets('Prize Pool — 390x844 reference render', (tester) async {
    await _loadFonts();
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(390, 844);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(
      MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: SportoTheme.darkTheme,
        home: MediaQuery(
          data: const MediaQueryData(
            size: Size(390, 844),
            padding: EdgeInsets.only(top: 40),
          ),
          child: PrizePoolRedesignScreen(
            tournamentId: '1',
            tournamentOverride: _tournament,
          ),
        ),
      ),
    );
    await tester.pump();

    await expectLater(
      find.byType(PrizePoolRedesignScreen),
      matchesGoldenFile('goldens/prize_pool_390x844.png'),
    );
  });

  testWidgets('Prize Pool survives 320..1440 and textScaler 2.0',
      (tester) async {
    const sizes = <Size>[
      Size(320, 640),
      Size(360, 800),
      Size(390, 844),
      Size(414, 896),
      Size(768, 1024),
      Size(1024, 768),
      Size(1440, 900),
      Size(844, 390),
    ];
    for (final size in sizes) {
      for (final scaler in <double>[1, 2]) {
        tester.view.devicePixelRatio = 1;
        tester.view.physicalSize = size;
        addTearDown(tester.view.resetDevicePixelRatio);
        addTearDown(tester.view.resetPhysicalSize);

        await tester.pumpWidget(
          MaterialApp(
            theme: SportoTheme.darkTheme,
            home: MediaQuery(
              data: MediaQueryData(
                size: size,
                textScaler: TextScaler.linear(scaler),
              ),
              child: PrizePoolRedesignScreen(
                tournamentId: '1',
                tournamentOverride: _tournament,
              ),
            ),
          ),
        );
        await tester.pump();

        expect(
          tester.takeException(),
          isNull,
          reason: 'overflow at $size / textScaler $scaler',
        );
        expect(find.text('Prize Pool'), findsWidgets);
      }
    }
  });
}

PartnerTournamentResponse get _tournament => PartnerTournamentResponse(
      id: 1,
      sportId: 1,
      sportFormatId: 1,
      tournamentTypeId: 1,
      name: 'Kukatpally Super Over Cup',
      code: 'TA-2026-0104',
      status: 2,
      approvalStatus: 2,
      totalPrizeMoney: '150000',
      tournamentStartAt: '2026-08-05T09:00:00',
      sport: const SportMasterResponse(
        id: 1,
        name: 'Cricket',
        code: 'CRIC',
        slug: 'cricket',
        description: 'Cricket',
        displayOrder: 1,
      ),
      tournamentVenues: const [
        PartnerTournamentVenueResponse(
          id: 1,
          venueName: 'KPHB Cricket Ground',
          location: 'Hyderabad',
        ),
      ],
      tournamentPrizes: [
        _prize(1, 'Winner', '50000', 1),
        _prize(2, 'Runner-up', '20000', 2),
        _prize(3, '3rd Place', '10000', 3),
        _prize(4, '4th Place', '50000', 4),
        _prize(5, '6th Place', '2500', 5),
        _prize(6, '7th Place', '2500', 6),
        _prize(7, 'Best Batsman', '5000', 7),
        _prize(8, 'Best Bowler', '5000', 8),
      ],
    );

PartnerTournamentPrizeResponse _prize(
  int id,
  String title,
  String amount,
  int order,
) =>
    PartnerTournamentPrizeResponse(
      id: id,
      category: 'cash-prize',
      title: title,
      amount: amount,
      displayOrder: order,
    );

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
