import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:partner_app/features/tournaments/presentation/screens/live_tournaments_redesign_screen.dart';
import 'package:partner_app/features/tournaments/presentation/screens/player_details_redesign_screen.dart';
import 'package:partner_app/features/tournaments/presentation/screens/tournament_matches_tab.dart';
import 'package:partner_data/partner_data.dart';
import 'package:ui_kit/ui_kit.dart';

/// Captures for the last batch: Live Tournaments (01), Player details (19) and
/// the Matches tab (16).
void main() {
  testWidgets('Live Tournaments — 390x844 (export 01)', (tester) async {
    await _pump(tester, const Size(390, 844),
        LiveTournamentsRedesignScreen(tournamentsOverride: _live));
    await expectLater(
      find.byType(LiveTournamentsRedesignScreen),
      matchesGoldenFile('goldens/live_tournaments_390x844.png'),
    );
  });

  testWidgets('Player details — 390x1118 (export 19)', (tester) async {
    await _pump(
      tester,
      const Size(390, 1118),
      const PlayerDetailsRedesignScreen(
        playerName: 'Shravan Prajapati',
        teamName: 'Hyd Highlanders',
        tournamentName: 'Gachibowli Super Over Qualifier',
        tournamentCode: 'TA-2026-0104',
      ),
    );
    await expectLater(
      find.byType(PlayerDetailsRedesignScreen),
      matchesGoldenFile('goldens/player_details_390x1118.png'),
    );
  });

  testWidgets('last batch survives 320..1440 and textScaler 2.0',
      (tester) async {
    const sizes = <Size>[
      Size(320, 640),
      Size(390, 844),
      Size(768, 1024),
      Size(844, 390),
    ];
    for (final size in sizes) {
      for (final scaler in <double>[1, 2]) {
        await _pump(
          tester,
          size,
          Scaffold(
            backgroundColor: const Color(0xFF090C10),
            body: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: TournamentMatchesTab(
                tournament: _tournament,
                matches: _matches,
                rounds: _rounds,
              ),
            ),
          ),
          scaler: scaler,
          golden: false,
        );
        expect(
          tester.takeException(),
          isNull,
          reason: 'matches tab overflow at $size / $scaler',
        );
      }
    }
  });
}

Future<void> _pump(
  WidgetTester tester,
  Size size,
  Widget child, {
  double scaler = 1,
  bool golden = true,
}) async {
  await _loadFonts();
  tester.view.devicePixelRatio = 1;
  tester.view.physicalSize = size;
  addTearDown(tester.view.resetDevicePixelRatio);
  addTearDown(tester.view.resetPhysicalSize);
  await tester.pumpWidget(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: SportoTheme.darkTheme,
      home: MediaQuery(
        data: MediaQueryData(
          size: size,
          padding: EdgeInsets.only(top: golden ? 40 : 0),
          textScaler: TextScaler.linear(scaler),
        ),
        child: child,
      ),
    ),
  );
  await tester.pump();
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
  registeredTeams: 42,
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
      venueName: 'GHMC Sports Complex',
      location: 'Hyderabad',
    ),
  ],
);

final _live = <PartnerTournamentResponse>[
  for (var i = 0; i < 6; i++) _status(2),
  for (var i = 0; i < 2; i++) _status(6),
  for (var i = 0; i < 14; i++) _status(7),
];

PartnerTournamentResponse _status(int status) =>
    _tournament.copyWith(status: status);

final _matches = <PartnerTournamentMatchResponse>[
  PartnerTournamentMatchResponse.fromJson({
    'id': 1,
    'match_number': 'M1',
    'round_name': 'Round of 64',
    'team_a_name': 'Hyd Highlanders',
    'team_b_name': 'Delhi Warriors',
    'venue_name': 'GHMC Sports Complex',
    'match_date': '2026-08-05',
    'start_time': '09:00 AM',
    'status': 6,
  }),
  PartnerTournamentMatchResponse.fromJson({
    'id': 2,
    'match_number': 'M2',
    'round_name': 'Round of 64',
    'team_a_name': 'Malkajgiri Mustangs',
    'team_b_name': 'Uppal Uhlans',
    'venue_name': 'GHMC Sports Complex',
    'match_date': '2026-08-05',
    'start_time': '11:00 AM',
    'status': 2,
  }),
];

final _rounds = <TournamentRound>[
  TournamentRound.fromJson(
      {'id': 1, 'name': 'Round of 64', 'sequence': 1, 'match_count': 32}),
  TournamentRound.fromJson(
      {'id': 2, 'name': 'Round of 32', 'sequence': 2, 'match_count': 16}),
];

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
