import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:partner_app/features/tournaments/presentation/screens/tournaments_redesign_screen.dart';
import 'package:partner_app/features/tournaments/presentation/widgets/redesign/tournament_cards.dart';
import 'package:partner_app/features/tournaments/presentation/widgets/redesign/tournament_redesign_data.dart';
import 'package:partner_app/features/tournaments/presentation/widgets/redesign/tournament_visuals.dart';
import 'package:partner_data/partner_data.dart';
import 'package:ui_kit/ui_kit.dart';

const _sizes = <String, Size>{
  '320x640': Size(320, 640),
  '360x800': Size(360, 800),
  '390x844': Size(390, 844),
  '414x896': Size(414, 896),
  '768x1024': Size(768, 1024),
  '1024x768': Size(1024, 768),
  '1440x900': Size(1440, 900),
  '844x390 landscape': Size(844, 390),
};

void main() {
  for (final entry in _sizes.entries) {
    for (final scaler in <double>[1, 2]) {
      testWidgets('${entry.key} @ textScaler $scaler', (tester) async {
        await _loadFonts();
        tester.view.devicePixelRatio = 1;
        tester.view.physicalSize = entry.value;
        addTearDown(tester.view.resetDevicePixelRatio);
        addTearDown(tester.view.resetPhysicalSize);

        await tester.pumpWidget(
          MaterialApp(
            theme: SportoTheme.darkTheme,
            home: MediaQuery(
              data: MediaQueryData(
                size: entry.value,
                textScaler: TextScaler.linear(scaler),
              ),
              child: TournamentsRedesignScreen(
                tournamentsOverride: _fixtures,
                initialTab: TournamentListTab.approved,
              ),
            ),
          ),
        );
        await tester.pump();

        expect(tester.takeException(), isNull);
        expect(find.text('Tournaments'), findsOneWidget);
        expect(find.byType(TournamentListCard), findsWidgets);
      });
    }
  }

  testWidgets('champion ticket renders the winner it is given', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: SportoTheme.darkTheme,
        home: const Scaffold(
          backgroundColor: Color(0xFF17191E),
          body: Center(
            child: SizedBox(
              width: 350,
              child: TournamentChampionTicket(champion: 'Hyd Highlanders'),
            ),
          ),
        ),
      ),
    );
    expect(find.text('Champions'), findsOneWidget);
    expect(find.text('Hyd Highlanders'), findsOneWidget);
  });

  testWidgets('admin note keeps its Edit action', (tester) async {
    var tapped = false;
    await tester.pumpWidget(
      MaterialApp(
        theme: SportoTheme.darkTheme,
        home: Scaffold(
          backgroundColor: const Color(0xFF17191E),
          body: Center(
            child: SizedBox(
              width: 330,
              child: TournamentCardNote(
                title: 'Admin Requested Changes',
                message: 'Revise the prize pool.',
                onEdit: () => tapped = true,
              ),
            ),
          ),
        ),
      ),
    );
    expect(find.text('Admin Requested Changes'), findsOneWidget);
    await tester.tap(find.text('Edit'));
    expect(tapped, isTrue);
  });

  testWidgets('progress track clamps its value', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: SportoTheme.darkTheme,
        home: const Scaffold(
          body: Center(
            child: SizedBox(
              width: 330,
              child: TournamentProgressTrack(value: 2),
            ),
          ),
        ),
      ),
    );
    expect(tester.takeException(), isNull);
  });
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

final _fixtures = <PartnerTournamentResponse>[
  _build(1, 3, 4, name: 'Mumbai Super Cup'),
  _build(2, 7, 4, name: 'Miyapur Weekend Cup'),
  _build(3, 2, 5, name: 'Kondapur Floodlight Cup'),
  _build(4, 2, 2, name: 'Madhapur Night Series'),
  _build(5, 6, 4, name: 'Gachibowli Super Over Qualifier'),
  _build(6, 8, 4, name: 'Gachibowli Turf Clash'),
];

PartnerTournamentResponse _build(
  int id,
  int status,
  int approval, {
  required String name,
}) =>
    PartnerTournamentResponse(
      id: id,
      sportId: 1,
      sportFormatId: 1,
      tournamentTypeId: 1,
      name: name,
      code: 'TA-2026-0104',
      status: status,
      approvalStatus: approval,
      registeredTeams: 42,
      maximumTeams: 64,
      registrationFee: '400',
      totalPrizeMoney: '25000',
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
      tournamentVenues: [
        PartnerTournamentVenueResponse(
          id: id,
          venueName: 'HITEC Box Cricket Arena',
          location: 'Hyderabad',
        ),
      ],
    );
