import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:partner_app/features/tournaments/presentation/screens/tournament_detail_redesign_screen.dart';
import 'package:partner_data/partner_data.dart';
import 'package:ui_kit/ui_kit.dart';

/// Full-height render of the tournament detail Info tab for the Figma diff
/// (`screens/06_Under-Review/Under-Review@2x.png`, 390×1442).
void main() {
  testWidgets('Tournament detail — Under Review 390x1442', (tester) async {
    await _loadFonts();
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(390, 1442);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(
      MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: SportoTheme.darkTheme,
        home: MediaQuery(
          data: const MediaQueryData(
            size: Size(390, 1442),
            padding: EdgeInsets.only(top: 40),
          ),
          child: TournamentDetailRedesignScreen(
            tournamentId: '',
            initialTournament: _tournament,
            initialRounds: _rounds,
            initialReview: _review,
          ),
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));

    await expectLater(
      find.byType(TournamentDetailRedesignScreen),
      matchesGoldenFile('goldens/tournament_detail_under_review_390x1442.png'),
    );
  });

  testWidgets('Tournament detail survives 320..1440 and textScaler 2.0',
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
              child: TournamentDetailRedesignScreen(
                tournamentId: '',
                initialTournament: _tournament,
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
        expect(find.byType(TournamentDetailRedesignScreen), findsOneWidget);
      }
    }
  });
}

final _tournament = PartnerTournamentResponse(
  id: 1,
  sportId: 1,
  sportFormatId: 1,
  tournamentTypeId: 1,
  name: 'Kukatpally Super Over Cup',
  code: 'TA-2026-0104',
  status: 2,
  approvalStatus: 2,
  maximumTeams: 64,
  registeredTeams: 42,
  registrationFee: '400',
  totalPrizeMoney: '150000',
  tournamentStartAt: '2026-08-05T09:00:00',
  tournamentEndAt: '2026-08-06T18:00:00',
  registrationEndAt: '2026-08-03T09:00:00',
  updatedAt: '2026-08-05T09:00:00',
  description: 'Community cricket tournament for the Kukatpally circuit.',
  sport: const SportMasterResponse(
    id: 1,
    name: 'Cricket',
    code: 'CRIC',
    slug: 'cricket',
    description: 'Cricket',
    displayOrder: 1,
  ),
  sportFormat: const SportFormatResponse(
    id: 1,
    sportId: 1,
    name: 'Mini Cricket - Super Over Challenge',
    slug: 'mini-cricket',
    description: 'Mini cricket',
    status: 1,
    createdAt: '',
    updatedAt: '',
  ),
  tournamentType: const TournamentTypeResponse(
    id: 1,
    name: 'Community Tournament',
    code: 'COMM',
    slug: 'community',
    description: '',
    status: 1,
    createdAt: '',
    updatedAt: '',
    displayOrder: 1,
  ),
  tournamentVenues: [
    for (var i = 1; i <= 5; i++)
      PartnerTournamentVenueResponse(
        id: i,
        venueName: 'KPHB Cricket Ground',
        location: 'Kondapur, Hyderabad',
        groundType: 'Indoor',
        dailyMatchCapacity: 4,
      ),
  ],
  tournamentSponsors: const [
    PartnerTournamentSponsorResponse(
      id: 1,
      sponsorType: 'title',
      name: 'CoolBreeze Beverages',
      contributionAmount: '100000',
    ),
    PartnerTournamentSponsorResponse(
      id: 2,
      sponsorType: 'co',
      name: 'Turf Energy',
      contributionAmount: '80000',
    ),
  ],
);

final _review = PartnerTournamentReviewData(
  tournament: _tournament,
  financialSummary: const PartnerFinancialSummary(
    estimatedCollection: 12800,
    totalPrizeMoney: '15000',
    platformFeePercentage: 10,
    platformFeeAmount: 1280,
    netEarnings: -11520,
    currency: 'INR',
  ),
  canSubmit: false,
);

final _rounds = <TournamentRound>[
  _round(1, 1, '64 Teams'),
  _round(2, 2, '32 Teams'),
  _round(3, 3, '16 Teams'),
  _round(4, 4, 'Quarter Finals'),
  _round(5, 5, 'Semi Finals'),
  _round(6, 6, 'Final'),
];

TournamentRound _round(int id, int sequence, String name) =>
    TournamentRound.fromJson({'id': id, 'name': name, 'sequence': sequence});

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
