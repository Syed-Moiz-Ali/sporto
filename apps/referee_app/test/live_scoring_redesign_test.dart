import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:referee_app/features/matches/presentation/screens/live_scoring_screen.dart';
import 'package:referee_data/referee_data.dart';
import 'package:ui_kit/ui_kit.dart';

RefereeScoreResponse _fakeScore({required bool bowlerSelected}) {
  const teamA = RefereeScoreTeamResponse(
    id: 1,
    name: 'Hyd Highlanders',
    players: [
      RefereeScorePlayerResponse(userId: 7, name: 'Vikram Reddy'),
      RefereeScorePlayerResponse(userId: 8, name: 'Dev Kumar'),
      RefereeScorePlayerResponse(userId: 9, name: 'Pankaj S'),
    ],
  );
  const teamB = RefereeScoreTeamResponse(
    id: 2,
    name: 'Delhi Warriors',
    players: [
      RefereeScorePlayerResponse(userId: 3, name: 'Amit Kumar'),
      RefereeScorePlayerResponse(userId: 4, name: 'Rohan A'),
    ],
  );
  final runtime = RefereeScoreRuntimeResponse(
    state: 'LIVE',
    currentOver: 0,
    currentBall: 0,
    currentInning: 1,
    currentBattingTeamId: 1,
    currentBowlingTeamId: 2,
    currentStriker: const RefereeScorePlayerRuntime(
      userId: 7,
      name: 'Vikram Reddy',
    ),
    currentNonStriker: const RefereeScorePlayerRuntime(
      userId: 8,
      name: 'Dev Kumar',
    ),
    currentBowler: bowlerSelected
        ? const RefereeScorePlayerRuntime(userId: 3, name: 'Amit Kumar')
        : const RefereeScorePlayerRuntime(),
    awaitingBowler: !bowlerSelected,
  );
  return RefereeScoreResponse(
    matchId: 1,
    matchStatus: 2,
    matchNumber: 10245,
    sportName: 'Cricket',
    formatName: 'Quarter Final',
    tournamentName: 'Asia Cup 2026',
    venueName: 'Hyderabad',
    teams: const [teamA, teamB],
    scoring: RefereeScoreStateResponse(
      enabled: true,
      oversPerInnings: 5,
      runtime: runtime,
      allowedActions: const [
        'START',
        'SET_BATTERS',
        'SET_BOWLER',
        'ADD_EVENT',
      ],
      availableEvents: const [
        RefereeScoreEventResponse(
          code: 'RUN',
          label: 'Run',
          allowedValues: [0, 1, 2, 4, 6],
        ),
        RefereeScoreEventResponse(code: 'WICKET', label: 'Wicket'),
        RefereeScoreEventResponse(code: 'WIDE', label: 'Wide'),
        RefereeScoreEventResponse(code: 'NO_BALL', label: 'No Ball'),
      ],
      score: const {},
    ),
    raw: const {},
  );
}

RefereeScoreResponse _fakeFinalScore({required bool completed}) {
  const teamA = RefereeScoreTeamResponse(
    id: 1,
    name: 'Hyd Highlanders',
    players: [
      RefereeScorePlayerResponse(userId: 7, name: 'Vikram Reddy'),
      RefereeScorePlayerResponse(userId: 8, name: 'Dev Kumar'),
    ],
  );
  const teamB = RefereeScoreTeamResponse(
    id: 2,
    name: 'Delhi Warriors',
    players: [
      RefereeScorePlayerResponse(userId: 3, name: 'Amit Kumar'),
      RefereeScorePlayerResponse(userId: 4, name: 'Rohan A'),
    ],
  );
  final runtime = RefereeScoreRuntimeResponse(
    state: completed ? 'COMPLETED' : 'LIVE',
    currentOver: 4,
    currentBall: 6,
    currentInning: 2,
    currentBattingTeamId: 2,
    currentBowlingTeamId: 1,
    inningsComplete: true,
    currentStriker: const RefereeScorePlayerRuntime(
      userId: 3,
      name: 'Amit Kumar',
    ),
    currentNonStriker: const RefereeScorePlayerRuntime(
      userId: 4,
      name: 'Rohan A',
    ),
    currentBowler: const RefereeScorePlayerRuntime(
      userId: 7,
      name: 'Vikram Reddy',
    ),
  );
  return RefereeScoreResponse(
    matchId: 1,
    matchStatus: completed ? 3 : 2,
    matchNumber: 10245,
    sportName: 'Cricket',
    formatName: 'Quarter Final',
    tournamentName: 'Asia Cup 2026',
    venueName: 'Hyderabad',
    teams: const [teamA, teamB],
    scoring: RefereeScoreStateResponse(
      enabled: true,
      oversPerInnings: 5,
      runtime: runtime,
      allowedActions: completed ? const [] : const ['COMPLETE'],
      score: const {
        'teams': {
          '1': {'score': 90, 'wickets': 2},
          '2': {'score': 85, 'wickets': 3},
        },
      },
    ),
    raw: const {},
  );
}

RefereeScoreResponse _fakeOverOrInnings({required bool overComplete}) {
  const teamA = RefereeScoreTeamResponse(
    id: 1,
    name: 'Hyd Highlanders',
    players: [
      RefereeScorePlayerResponse(userId: 7, name: 'Vikram Reddy'),
      RefereeScorePlayerResponse(userId: 8, name: 'Dev Kumar'),
    ],
  );
  const teamB = RefereeScoreTeamResponse(
    id: 2,
    name: 'Delhi Warriors',
    players: [
      RefereeScorePlayerResponse(userId: 3, name: 'Amit Kumar'),
      RefereeScorePlayerResponse(userId: 4, name: 'Rohan A'),
    ],
  );
  final runtime = RefereeScoreRuntimeResponse(
    state: 'LIVE',
    currentOver: overComplete ? 4 : 4,
    currentBall: overComplete ? 6 : 6,
    currentInning: 1,
    currentBattingTeamId: 1,
    currentBowlingTeamId: 2,
    inningsComplete: !overComplete,
    awaitingBowler: overComplete,
    currentStriker: const RefereeScorePlayerRuntime(
      userId: 7,
      name: 'Vikram Reddy',
    ),
    currentNonStriker: const RefereeScorePlayerRuntime(
      userId: 8,
      name: 'Dev Kumar',
    ),
    lastEvent: overComplete
        ? const RefereeScoreEvent(
            type: RefereeScoreEventTypes.overComplete,
            data: {'over_number': 4},
          )
        : null,
  );
  return RefereeScoreResponse(
    matchId: 1,
    matchStatus: 2,
    matchNumber: 10245,
    sportName: 'Cricket',
    formatName: 'Quarter Final',
    tournamentName: 'Asia Cup 2026',
    venueName: 'Hyderabad',
    teams: const [teamA, teamB],
    scoring: RefereeScoreStateResponse(
      enabled: true,
      oversPerInnings: 5,
      runtime: runtime,
      allowedActions:
          overComplete ? const ['SET_BOWLER'] : const ['END_PERIOD'],
      score: const {
        'teams': {
          '1': {'score': 80, 'wickets': 2},
          '2': {'score': 0, 'wickets': 0},
        },
      },
    ),
    raw: const {},
  );
}

Widget _wrap({Key? key}) {
  return MaterialApp(
    theme: SportoTheme.darkTheme,
    home: LiveScoringScreen(
      key: key,
      matchId: '1',
      matchCode: 'SP-10245',
    ),
  );
}

void main() {
  tearDown(() {
    LiveScoringScreen.debugFetchOverride = null;
  });

  testWidgets('select bowler step renders redesigned scorer UI',
      (tester) async {
    LiveScoringScreen.debugFetchOverride =
        (matchId) async => _fakeScore(bowlerSelected: false);

    for (final size in const [Size(390, 844), Size(360, 800)]) {
      tester.view.physicalSize = size;
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(_wrap());
      await tester.pumpAndSettle();

      expect(find.text('Cricket Score Entry'), findsOneWidget);
      expect(find.text('Cricket'), findsOneWidget);
      expect(find.text('SP-10245'), findsOneWidget);
      expect(find.text('Hyd Highlanders'), findsWidgets);
      expect(find.text('Delhi Warriors'), findsWidgets);
      expect(find.text('Select Bowler for — Over 1'), findsOneWidget);
      expect(find.text('Start Over 1'), findsOneWidget);
      expect(tester.takeException(), isNull);
    }
  });

  testWidgets('scoring step renders redesigned run pad', (tester) async {
    LiveScoringScreen.debugFetchOverride =
        (matchId) async => _fakeScore(bowlerSelected: true);

    tester.view.physicalSize = const Size(360, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(_wrap());
    await tester.pumpAndSettle();

    expect(find.text('This Over — Amit Kumar'), findsOneWidget);
    expect(find.text('WKT'), findsOneWidget);
    expect(find.text('Wide'), findsOneWidget);
    expect(find.text('No Ball'), findsOneWidget);
    expect(find.text('0'), findsWidgets);
    expect(tester.takeException(), isNull);
  });

  testWidgets('final result screens render and submit advances stages',
      (tester) async {
    LiveScoringScreen.debugFetchOverride =
        (matchId) async => _fakeFinalScore(completed: false);

    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(_wrap());
    await tester.pumpAndSettle();

    expect(find.text('Cricket Score Entry'), findsOneWidget);
    expect(find.text('Proceed to Submit Result'), findsOneWidget);
    await tester.tap(find.text('Proceed to Submit Result'));
    await tester.pumpAndSettle();

    expect(find.text('Final Result'), findsOneWidget);
    expect(find.text('Submit Final Result'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('submitted result screen renders without header or overflow',
      (tester) async {
    LiveScoringScreen.debugFetchOverride =
        (matchId) async => _fakeFinalScore(completed: true);

    tester.view.physicalSize = const Size(360, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(_wrap());
    await tester.pumpAndSettle();

    expect(find.text('RESULT SUBMITTED'), findsOneWidget);
    expect(find.text('View Match History'), findsOneWidget);
    expect(find.text('Cricket Score Entry'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('over complete and innings break screens render without overflow',
      (tester) async {
    for (final overComplete in [true, false]) {
      LiveScoringScreen.debugFetchOverride =
          (matchId) async => _fakeOverOrInnings(overComplete: overComplete);
      tester.view.physicalSize = const Size(360, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(_wrap(key: ValueKey(overComplete)));
      await tester.pumpAndSettle();

      if (overComplete) {
        expect(find.text('Over 4 completed.'), findsOneWidget);
        expect(find.text("Let’s Begin 5 Last Over"), findsOneWidget);
      } else {
        expect(find.text('Start 2nd Innings'), findsOneWidget);
      }
      expect(tester.takeException(), isNull);
    }
  });
}
