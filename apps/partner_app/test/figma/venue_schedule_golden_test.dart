import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:partner_app/features/tournaments/presentation/screens/venue_schedule_redesign_screen.dart';
import 'package:partner_data/partner_data.dart';
import 'package:ui_kit/ui_kit.dart';

/// 390×1418 render of Venue & Schedule for the Figma diff
/// (`screens/13_Venue-Schedule/Venue-Schedule@2x.png`).
void main() {
  testWidgets('Venue & Schedule — 390x1418', (tester) async {
    await _loadFonts();
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(390, 1418);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(
      MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: SportoTheme.darkTheme,
        home: MediaQuery(
          data: const MediaQueryData(
            size: Size(390, 1418),
            padding: EdgeInsets.only(top: 40),
          ),
          child: VenueScheduleRedesignScreen(
            tournamentId: '',
            tournamentOverride: _tournament,
            roundsOverride: _rounds,
          ),
        ),
      ),
    );
    await tester.pump();

    await expectLater(
      find.byType(VenueScheduleRedesignScreen),
      matchesGoldenFile('goldens/venue_schedule_390x1418.png'),
    );
  });

  testWidgets('Venue & Schedule survives 320..1440 and textScaler 2.0',
      (tester) async {
    const sizes = <Size>[
      Size(320, 640),
      Size(360, 800),
      Size(390, 844),
      Size(768, 1024),
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
              child: VenueScheduleRedesignScreen(
                tournamentId: '',
                tournamentOverride: _tournament,
                roundsOverride: _rounds,
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
        expect(find.text('Venue & Schedule'), findsWidgets);
      }
    }
  });
}

final _tournament = PartnerTournamentResponse(
  id: 1,
  sportId: 1,
  sportFormatId: 1,
  tournamentTypeId: 1,
  name: 'Gachibowli Super Over Qualifier',
  code: 'TA-2026-0104',
  status: 6,
  approvalStatus: 4,
  maximumTeams: 64,
  tournamentStartAt: '2026-08-05T09:00:00',
  tournamentEndAt: '2026-08-06T18:00:00',
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
      location: 'Kondapur, Hyderabad',
      groundType: 'Indoor',
      roundName: 'Round of 64',
      date: '2026-08-05',
      startTime: '08:00 PM',
      displayOrder: 1,
    ),
    PartnerTournamentVenueResponse(
      id: 2,
      venueName: 'KPHB Cricket Ground',
      location: 'Kondapur, Hyderabad',
      groundType: 'Indoor',
      roundName: 'Round of 32',
      date: '2026-08-06',
      startTime: '08:00 PM',
      displayOrder: 2,
    ),
    PartnerTournamentVenueResponse(
      id: 3,
      venueName: 'KPHB Cricket Ground',
      location: 'Kondapur, Hyderabad',
      groundType: 'Indoor',
      roundName: 'Quarter-Finals',
      date: '2026-08-06',
      startTime: '08:00 PM',
      displayOrder: 3,
    ),
    PartnerTournamentVenueResponse(
      id: 4,
      venueName: 'KPHB Cricket Ground',
      location: 'Kondapur, Hyderabad',
      groundType: 'Indoor',
      roundName: 'Semifinals',
      date: '2026-08-06',
      startTime: '08:00 PM',
      displayOrder: 4,
    ),
    PartnerTournamentVenueResponse(
      id: 5,
      venueName: 'KPHB Cricket Ground',
      location: 'Kondapur, Hyderabad',
      groundType: 'Indoor',
      roundName: 'Final',
      date: '2026-08-06',
      startTime: '08:00 PM',
      displayOrder: 5,
    ),
  ],
);

final _rounds = <TournamentRound>[
  _round(1, 1, 'Round of 64', 32),
  _round(2, 2, 'Round of 32', 16),
  _round(3, 3, 'Quarter-Finals', 4),
  _round(4, 4, 'Semifinals', 2),
  _round(5, 5, 'Final', 1),
];

TournamentRound _round(int id, int sequence, String name, int matches) =>
    TournamentRound.fromJson({
      'id': id,
      'name': name,
      'sequence': sequence,
      'match_count': matches,
      'expected_match_count': matches,
    });

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
