import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:referee_app/features/matches/presentation/screens/match_summary_screen.dart';
import 'package:referee_data/referee_data.dart';
import 'package:ui_kit/ui_kit.dart';

RefereeMatchResponse _match() => const RefereeMatchResponse(
      id: 10245,
      tournamentName: 'Hyderabad Super Cup',
      roundName: 'Quarter Final',
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

RefereeMatchResultResponse _result() => const RefereeMatchResultResponse(
      matchId: 10245,
      status: 'WIN',
      winnerTeamId: 1,
      winnerTeamName: 'Hyd Highlanders',
      margin: '18 runs',
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
      innings: [
        RefereeScorecardInnings(
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
          batting: [
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
          ],
          bowling: [
            RefereeScorecardBowling(
              playerId: 20,
              name: 'Sameer J.',
              legalBalls: 24,
              overs: '4.0',
              runsConceded: 28,
              wickets: 2,
              economyRate: '7.00',
            ),
          ],
          fallOfWickets: [
            RefereeScorecardFallOfWicket(wicketNumber: 1, score: '61'),
            RefereeScorecardFallOfWicket(wicketNumber: 2, score: '98'),
          ],
        ),
        RefereeScorecardInnings(
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
          batting: [
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
          ],
          bowling: [
            RefereeScorecardBowling(
              playerId: 40,
              name: 'Ravi T.',
              legalBalls: 24,
              overs: '4.0',
              runsConceded: 34,
              wickets: 2,
              economyRate: '8.50',
            ),
          ],
          fallOfWickets: [
            RefereeScorecardFallOfWicket(wicketNumber: 1, score: '52'),
            RefereeScorecardFallOfWicket(wicketNumber: 2, score: '97'),
          ],
        ),
      ],
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

void main() {
  testWidgets('summary shows winner, scores and opens full scorecard',
      (tester) async {
    await tester.pumpWidget(
      _app(
        MatchSummaryScreen(
          matchId: '10245',
          match: _match(),
          scorecardFuture: Future.value(_scorecard()),
          resultFuture: Future.value(_result()),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Hyd Highlanders'), findsWidgets);
    expect(find.text('Winner'), findsOneWidget);
    expect(find.text('View Full Scoreboard'), findsOneWidget);
    expect(find.text('168/6'), findsOneWidget);
    expect(find.text('Super Over Innings Completed'), findsOneWidget);
    expect(find.text('10/0'), findsOneWidget);
    expect(find.text('9/0'), findsOneWidget);
    expect(tester.takeException(), isNull);

    await tester.tap(find.byKey(const ValueKey('view-full-scoreboard')));
    await tester.pumpAndSettle();

    expect(find.text('Batting'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('summary respects an injected onViewScoreboard callback',
      (tester) async {
    var tapped = false;
    await tester.pumpWidget(
      _app(
        MatchSummaryScreen(
          matchId: '10245',
          match: _match(),
          scorecardFuture: Future.value(_scorecard()),
          resultFuture: Future.value(_result()),
          onViewScoreboard: () => tapped = true,
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const ValueKey('view-full-scoreboard')));
    await tester.pumpAndSettle();

    expect(tapped, isTrue);
    expect(find.text('Batting'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('summary has no overflow at 360 and 430', (tester) async {
    for (final size in const [Size(360, 800), Size(430, 932)]) {
      tester.view.physicalSize = size;
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(
        _app(
          MatchSummaryScreen(
            key: ValueKey(size),
            matchId: '10245',
            match: _match(),
            scorecardFuture: Future.value(_scorecard()),
            resultFuture: Future.value(_result()),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('View Full Scoreboard'), findsOneWidget);
      expect(tester.takeException(), isNull);
    }
  });

  testWidgets('summary shows a retry card when the scorecard fails',
      (tester) async {
    await tester.pumpWidget(
      _app(
        MatchSummaryScreen(
          matchId: '10245',
          match: _match(),
          scorecardFuture: _failure<RefereeScorecardResponse>(),
          resultFuture: Future.value(_result()),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Unable to load scorecard'), findsOneWidget);
    expect(find.byKey(const ValueKey('scorecard-retry')), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
