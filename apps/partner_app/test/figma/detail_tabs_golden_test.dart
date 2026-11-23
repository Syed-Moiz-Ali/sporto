import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:partner_app/features/tournaments/presentation/screens/tournament_detail_redesign_screen.dart';
import 'package:partner_data/partner_data.dart';
import 'package:ui_kit/ui_kit.dart';

/// Tab captures of the detail screen for the export tab artboards:
/// 16 (Matches), 17 (Teams), 18 (Stats), 29 (Financials).
void main() {
  const tabs = <int, (String, double)>{
    1: ('matches', 1117),
    2: ('teams', 1012),
    3: ('stats', 844),
    4: ('financials', 844),
  };

  for (final entry in tabs.entries) {
    testWidgets('detail tab ${entry.value.$1} — 390x${entry.value.$2.toInt()}', (tester) async {
      await _loadFonts();
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = Size(390, entry.value.$2);
      addTearDown(tester.view.resetDevicePixelRatio);
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(
        MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: SportoTheme.darkTheme,
          home: MediaQuery(
            data: MediaQueryData(
              size: Size(390, entry.value.$2),
              padding: const EdgeInsets.only(top: 40),
            ),
            child: TournamentDetailRedesignScreen(
              tournamentId: '',
              initialTabIndex: entry.key,
              initialTournament: _tournament,
              initialRounds: _rounds,
              initialMatches: _matches,
              initialRegistrations: _registrations,
              initialReview: _review,
            ),
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 60));

      await expectLater(
        find.byType(TournamentDetailRedesignScreen),
        matchesGoldenFile(
          'goldens/detail_tab_${entry.value.$1}_390x${entry.value.$2.toInt()}.png'),
      );
    });
  }
}

final _tournament = PartnerTournamentResponse(
  id: 1,
  sportId: 1,
  sportFormatId: 1,
  tournamentTypeId: 1,
  name: 'Miyapur Weekend Cup',
  code: 'TA-2026-0104',
  status: 7,
  approvalStatus: 4,
  maximumTeams: 64,
  registeredTeams: 41,
  registrationFee: '400',
  totalPrizeMoney: '15000',
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
    ),
  ],
  tournamentSponsors: const [
    PartnerTournamentSponsorResponse(
      id: 1,
      sponsorType: 'title',
      name: 'CoolBreeze Beverages',
      contributionAmount: '100000',
    ),
  ],
);

final _rounds = <TournamentRound>[
  TournamentRound.fromJson(
      {'id': 1, 'name': 'Round of 64', 'sequence': 1, 'match_count': 32}),
  TournamentRound.fromJson(
      {'id': 2, 'name': 'Round of 32', 'sequence': 2, 'match_count': 16}),
  TournamentRound.fromJson(
      {'id': 3, 'name': 'Quarter-finals', 'sequence': 3, 'match_count': 4}),
];

final _matches = <PartnerTournamentMatchResponse>[
  for (var i = 1; i <= 3; i++)
    PartnerTournamentMatchResponse.fromJson({
      'id': i,
      'match_number': 'M$i',
      'round_name': i == 1 ? 'Round of 64' : 'Round of 32',
      'team_a_name': 'Hyd Highlanders',
      'team_b_name': 'Delhi Warriors',
      'venue_name': 'KPHB Cricket Ground',
      'match_date': '2026-08-05',
      'start_time': '09:00 AM',
      'status': i == 1 ? 6 : 2,
    }),
];

final _registrations = <TournamentRegistration>[
  TournamentRegistration.fromJson({
    'id': 1,
    'name': 'Hyd Highlanders',
    'status': 'approved',
    'registration_players': [
      {'name': 'Shravan Prajapati'},
      {'name': 'Kunal Kumar'},
    ],
  }),
  TournamentRegistration.fromJson({
    'id': 2,
    'name': 'Delhi Warriors',
    'status': 'pending',
    'registration_players': [
      {'name': 'Imran Ali'},
    ],
  }),
];

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
