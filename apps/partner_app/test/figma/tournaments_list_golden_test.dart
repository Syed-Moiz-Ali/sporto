import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:partner_app/features/tournaments/presentation/screens/tournaments_redesign_screen.dart';
import 'package:partner_app/features/tournaments/presentation/widgets/redesign/tournament_redesign_data.dart';
import 'package:partner_data/partner_data.dart';
import 'package:ui_kit/ui_kit.dart';

/// Renders the Tournaments tab at the export's design size (390x844) so the
/// capture can be diffed against `screens/09|14|36/<name>@2x.png`.
///
/// Run with `flutter test --update-goldens test/figma/tournaments_list_golden_test.dart`
/// to regenerate `goldens/tournaments_*.png`.
void main() {
  testWidgets('Tournaments tab — approved / registration open (export 09)',
      (tester) async {
    await _pump(
      tester,
      tournaments: [_openTournament(), _openTournament(id: 2)],
      tab: TournamentListTab.approved,
    );
    await expectLater(
      find.byType(TournamentsRedesignScreen),
      matchesGoldenFile('goldens/tournaments_list_approved_390x844.png'),
    );
  });

  testWidgets('Tournaments tab — completed (export 14)', (tester) async {
    await _pump(
      tester,
      tournaments: [_completedTournament(), _completedTournament(id: 2)],
      tab: TournamentListTab.completed,
    );
    await expectLater(
      find.byType(TournamentsRedesignScreen),
      matchesGoldenFile('goldens/tournaments_list_completed_390x844.png'),
    );
  });

  testWidgets('Tournaments tab — rejected (export 36)', (tester) async {
    await _pump(
      tester,
      tournaments: [_rejectedTournament(), _cancelledTournament()],
      tab: TournamentListTab.rejected,
    );
    await expectLater(
      find.byType(TournamentsRedesignScreen),
      matchesGoldenFile('goldens/tournaments_list_rejected_390x844.png'),
    );
  });
}

Future<void> _pump(
  WidgetTester tester, {
  required List<PartnerTournamentResponse> tournaments,
  required TournamentListTab tab,
}) async {
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
        // The export artboard includes a 40 px status-bar inset.
        data: const MediaQueryData(
          size: Size(390, 844),
          padding: EdgeInsets.only(top: 40),
        ),
        child: TournamentsRedesignScreen(
          tournamentsOverride: tournaments,
          initialTab: tab,
        ),
      ),
    ),
  );
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 50));
}

PartnerTournamentResponse _base({
  required int id,
  required String name,
  required String venue,
  required String city,
  required int status,
  required int approvalStatus,
  String start = '2026-08-05T09:00:00',
  String end = '2026-08-06T18:00:00',
  String createdAt = '2026-10-12T10:20:00',
  int registered = 42,
  int maximum = 64,
  String fee = '400',
  String prize = '25000',
}) =>
    PartnerTournamentResponse(
      id: id,
      sportId: 1,
      sportFormatId: 1,
      tournamentTypeId: 1,
      name: name,
      code: 'TA-2026-0104',
      status: status,
      approvalStatus: approvalStatus,
      registeredTeams: registered,
      maximumTeams: maximum,
      registrationFee: fee,
      totalPrizeMoney: prize,
      currency: 'INR',
      tournamentStartAt: start,
      tournamentEndAt: end,
      createdAt: createdAt,
      sport: const SportMasterResponse(
        id: 1,
        name: 'Cricket',
        code: 'CRIC',
        slug: 'cricket',
        description: 'Cricket',
        displayOrder: 1,
      ),
      tournamentVenues: [
        PartnerTournamentVenueResponse(
          id: id,
          venueName: venue,
          location: city,
        ),
      ],
    );

PartnerTournamentResponse _openTournament({int id = 1}) => _base(
      id: id,
      name: 'Mumbai Super Cup',
      venue: 'HITEC Box Cricket Arena',
      city: 'Hyderabad',
      status: 3,
      approvalStatus: 4,
    );

PartnerTournamentResponse _completedTournament({int id = 1}) => _base(
      id: id,
      name: 'Miyapur Weekend Cup',
      venue: 'HITEC Box Cricket Arena',
      city: 'Hyderabad',
      status: 7,
      approvalStatus: 4,
      start: '2026-08-26T09:00:00',
      end: '2026-08-27T18:00:00',
    );

PartnerTournamentResponse _rejectedTournament() => _base(
      id: 11,
      name: 'Kondapur Floodlight Cup',
      venue: 'Kondapur Sports Turf',
      city: 'Hyderabad',
      status: 2,
      approvalStatus: 5,
      start: '2026-11-08T09:00:00',
      end: '2026-11-09T18:00:00',
      registered: 16,
      maximum: 32,
      fee: '350',
      prize: '12000',
    );

PartnerTournamentResponse _cancelledTournament() => _base(
      id: 12,
      name: 'Gachibowli Turf Clash',
      venue: 'GHMC Sports Complex',
      city: 'Hyderabad',
      status: 8,
      approvalStatus: 4,
      start: '2026-11-08T09:00:00',
      end: '2026-11-09T18:00:00',
      registered: 16,
      maximum: 32,
      fee: '350',
      prize: '12000',
    );

// Placeholder so the cancelled fixture reads clearly at the call site.

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
