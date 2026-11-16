import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:referee_app/features/matches/presentation/screens/full_scorecard_screen.dart';
import 'package:referee_app/features/matches/presentation/widgets/scorecard_redesign_widgets.dart';
import 'package:referee_data/referee_data.dart';
import 'package:ui_kit/ui_kit.dart';

RefereeMatchResponse _match() => const RefereeMatchResponse(
      id: 10245,
      tournamentName: 'Hyderabad Super Cup',
      roundName: 'Round of 128',
      matchNumber: 'SP-10245',
      startTime: '10:30 AM',
      matchDate: '2026-08-08',
      venueName: 'Kompally Turf Arena',
      location: 'Hyderabad',
      statusLabel: 'Completed',
      teamA: RefereeMatchTeam(
        id: 1,
        name: 'Hyd Highlanders',
        score: '168/6',
      ),
      teamB: RefereeMatchTeam(
        id: 2,
        name: 'Delhi Warriors',
        score: '150/8',
      ),
      raw: {
        'sport_name': 'Cricket',
        'booking_source': 'partner',
        'winner_team_name': 'Hyd Highlanders',
        'margin': '18 runs',
      },
    );

const _battingOne = [
  RefereeScorecardBatting(
    playerId: 10,
    name: 'You',
    runs: 52,
    ballsFaced: 31,
    fours: 5,
    sixes: 1,
    strikeRate: '168',
    status: 'not out',
  ),
  RefereeScorecardBatting(
    playerId: 11,
    name: 'Arjun R.',
    runs: 38,
    ballsFaced: 24,
    fours: 4,
    sixes: 1,
    strikeRate: '158',
    dismissal: 'b Sana K.',
  ),
];

const _bowlingTwo = [
  RefereeScorecardBowling(
    playerId: 20,
    name: 'Sameer J.',
    legalBalls: 24,
    overs: '4.0',
    runsConceded: 28,
    wickets: 2,
    economyRate: '7.00',
  ),
];

const _battingTwo = [
  RefereeScorecardBatting(
    playerId: 30,
    name: 'Sameer J.',
    runs: 52,
    ballsFaced: 31,
    fours: 5,
    sixes: 1,
    strikeRate: '168',
    dismissal: 'c Devika b Priya M.',
  ),
  RefereeScorecardBatting(
    playerId: 31,
    name: 'Naveen B.',
    runs: 38,
    ballsFaced: 24,
    fours: 4,
    sixes: 1,
    strikeRate: '158',
    dismissal: 'b Karthik S.',
  ),
];

const _bowlingOne = [
  RefereeScorecardBowling(
    playerId: 40,
    name: 'Ravi T.',
    legalBalls: 24,
    overs: '4.0',
    runsConceded: 34,
    wickets: 2,
    economyRate: '8.50',
  ),
];

const _inningsOne = RefereeScorecardInnings(
  inningsNumber: 1,
  battingTeamId: 1,
  battingTeamName: 'Hyd Highlanders',
  bowlingTeamId: 2,
  bowlingTeamName: 'Delhi Warriors',
  totals: RefereeScorecardTotals(
    runs: 168,
    wickets: 6,
    legalBalls: 120,
    overs: '20.0',
    extras: {'b': 1, 'w': 1},
  ),
  batting: _battingOne,
  bowling: _bowlingTwo,
  fallOfWickets: [
    RefereeScorecardFallOfWicket(wicketNumber: 1, score: '61'),
    RefereeScorecardFallOfWicket(wicketNumber: 2, score: '98'),
  ],
);

const _inningsTwo = RefereeScorecardInnings(
  inningsNumber: 2,
  battingTeamId: 2,
  battingTeamName: 'Delhi Warriors',
  bowlingTeamId: 1,
  bowlingTeamName: 'Hyd Highlanders',
  totals: RefereeScorecardTotals(
    runs: 150,
    wickets: 8,
    legalBalls: 120,
    overs: '20.0',
    extras: {'lb': 2, 'w': 2},
  ),
  batting: _battingTwo,
  bowling: _bowlingOne,
  fallOfWickets: [
    RefereeScorecardFallOfWicket(wicketNumber: 1, score: '52'),
    RefereeScorecardFallOfWicket(wicketNumber: 2, score: '97'),
  ],
);

RefereeScorecardResponse _scorecard() => const RefereeScorecardResponse(
      match: RefereeScorecardMatch(
        id: 10245,
        status: 3,
        winnerTeamId: 1,
        teams: [
          RefereeScorecardTeam(id: 1, name: 'Hyd Highlanders'),
          RefereeScorecardTeam(id: 2, name: 'Delhi Warriors'),
        ],
      ),
      dataAvailability: RefereeScorecardAvailability(status: 'COMPLETE'),
      teamTotals: {
        '1': RefereeScorecardTotals(
          runs: 168,
          wickets: 6,
          legalBalls: 120,
          overs: '20.0',
          extras: {'b': 1, 'w': 1},
        ),
        '2': RefereeScorecardTotals(
          runs: 150,
          wickets: 8,
          legalBalls: 120,
          overs: '20.0',
          extras: {'lb': 2, 'w': 2},
        ),
      },
      matchCode: 'SP-10245',
      winnerTeamName: 'Hyd Highlanders',
      playerOfMatch: 'Sameer J.',
      result: {
        'winner_team_name': 'Hyd Highlanders',
        'margin': '18 runs',
      },
      innings: [_inningsOne, _inningsTwo],
      superOvers: [
        RefereeScorecardInnings(
          inningsNumber: 1,
          inningsType: 'SUPER_OVER',
          superOverRound: 1,
          battingTeamId: 1,
          battingTeamName: 'Hyd Highlanders',
          bowlingTeamId: 2,
          bowlingTeamName: 'Delhi Warriors',
          totals: RefereeScorecardTotals(
            runs: 10,
            wickets: 0,
            legalBalls: 6,
            overs: '1.0',
          ),
        ),
        RefereeScorecardInnings(
          inningsNumber: 2,
          inningsType: 'SUPER_OVER',
          superOverRound: 1,
          battingTeamId: 2,
          battingTeamName: 'Delhi Warriors',
          bowlingTeamId: 1,
          bowlingTeamName: 'Hyd Highlanders',
          totals: RefereeScorecardTotals(
            runs: 9,
            wickets: 0,
            legalBalls: 6,
            overs: '1.0',
          ),
        ),
      ],
    );

RefereeScorecardResponse _emptyScorecard() => const RefereeScorecardResponse(
      match: RefereeScorecardMatch(
        id: 10245,
        status: 3,
        winnerTeamId: 1,
        teams: [
          RefereeScorecardTeam(id: 1, name: 'Hyd Highlanders'),
          RefereeScorecardTeam(id: 2, name: 'Delhi Warriors'),
        ],
      ),
      teamTotals: {
        '1': RefereeScorecardTotals(runs: 0, wickets: 0),
        '2': RefereeScorecardTotals(runs: 0, wickets: 0),
      },
      winnerTeamName: 'Hyd Highlanders',
    );

Future<T> _failure<T>() => Future<T>.delayed(
      Duration.zero,
      () => throw const FormatException('boom'),
    );

Widget _app(Widget home) {
  return MaterialApp(
    theme: SportoTheme.darkTheme,
    home: home,
  );
}

void _useTallView(WidgetTester tester) {
  tester.view.physicalSize = const Size(390, 2400);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);
}

void main() {
  test('legal balls use cricket overs notation', () {
    const totals = RefereeScorecardTotals(runs: 100, legalBalls: 121);
    expect(scorecardOversText(totals), '20.1');
    const bowling =
        RefereeScorecardBowling(playerId: 1, name: 'Bowler', legalBalls: 125);
    expect(scorecardBowlerOvers(bowling), '20.5');
  });

  testWidgets('scorecard renders batting, bowling and player of the match',
      (tester) async {
    _useTallView(tester);
    await tester.pumpWidget(
      _app(
        FullScorecardScreen(
          matchId: '10245',
          match: _match(),
          initialTeamId: 1,
          scorecardFuture: Future.value(_scorecard()),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('168/6 (20 overs)'), findsOneWidget);
    expect(find.text('Batting'), findsOneWidget);
    expect(find.text('Batter'), findsOneWidget);
    expect(find.text('R'), findsWidgets);
    expect(find.text('B'), findsOneWidget);
    expect(find.text('4s'), findsOneWidget);
    expect(find.text('6s'), findsOneWidget);
    expect(find.text('SR'), findsOneWidget);
    expect(find.text('You'), findsOneWidget);
    expect(find.text('not out'), findsOneWidget);
    expect(find.text('52'), findsOneWidget);
    expect(find.text('168'), findsOneWidget);
    expect(find.text('Extras'), findsWidgets);
    expect(find.text('2 (b 1, w 1)'), findsOneWidget);
    expect(find.text('Total (20.0 ov, RR 8.40)'), findsOneWidget);
    expect(
      find.text('Fall of wickets: 1-61, 2-98'),
      findsOneWidget,
    );
    expect(find.text('Bowling'), findsWidgets);
    expect(find.text('Bowler'), findsOneWidget);
    expect(find.text('O'), findsOneWidget);
    expect(find.text('M'), findsOneWidget);
    expect(find.text('W'), findsOneWidget);
    expect(find.text('Econ'), findsOneWidget);
    expect(find.text('Ravi T.'), findsOneWidget);
    expect(find.text('8.50'), findsOneWidget);
    expect(find.text('Player of the Match'), findsOneWidget);
    expect(find.text('Sameer J.'), findsOneWidget);
    expect(find.text('52 runs'), findsOneWidget);
    expect(find.text('2 wickets'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('team toggle switches batting and bowling figures',
      (tester) async {
    _useTallView(tester);
    await tester.pumpWidget(
      _app(
        FullScorecardScreen(
          matchId: '10245',
          match: _match(),
          initialTeamId: 1,
          scorecardFuture: Future.value(_scorecard()),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('You'), findsOneWidget);
    expect(find.text('8.50'), findsOneWidget);

    await tester.tap(
      find.byKey(const ValueKey('scorecard-team-toggle-2')),
    );
    await tester.pumpAndSettle();

    expect(find.text('You'), findsNothing);
    expect(find.text('150/8 (20 overs)'), findsOneWidget);
    expect(find.text('Naveen B.'), findsOneWidget);
    expect(find.text('Sameer J.'), findsWidgets);
    expect(find.text('8.50'), findsNothing);
    expect(find.text('7.00'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('missing innings shows a clean empty state', (tester) async {
    await tester.pumpWidget(
      _app(
        FullScorecardScreen(
          matchId: '10245',
          match: _match(),
          initialTeamId: 1,
          scorecardFuture: Future.value(_emptyScorecard()),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(
      find.text('No innings have been recorded for Hyd Highlanders yet.'),
      findsOneWidget,
    );
    expect(find.text('Batter'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('scorecard error state offers retry', (tester) async {
    await tester.pumpWidget(
      _app(
        FullScorecardScreen(
          matchId: '10245',
          match: _match(),
          scorecardFuture: _failure<RefereeScorecardResponse>(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Unable to load scorecard'), findsOneWidget);
    expect(find.byKey(const ValueKey('scorecard-retry')), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('scorecard has no overflow at 360 and 430', (tester) async {
    for (final size in const [Size(360, 800), Size(430, 932)]) {
      tester.view.physicalSize = size;
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(
        _app(
          FullScorecardScreen(
            key: ValueKey(size),
            matchId: '10245',
            match: _match(),
            initialTeamId: 1,
            scorecardFuture: Future.value(_scorecard()),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.dragUntilVisible(
        find.text('Batter'),
        find.byType(ListView),
        const Offset(0, -300),
      );
      await tester.pumpAndSettle();
      expect(find.text('Batter'), findsOneWidget);
      expect(tester.takeException(), isNull);

      await tester.dragUntilVisible(
        find.text('Player of the Match'),
        find.byType(ListView),
        const Offset(0, -300),
      );
      await tester.pumpAndSettle();
      expect(find.text('Player of the Match'), findsOneWidget);
      expect(tester.takeException(), isNull);
    }
  });
}
