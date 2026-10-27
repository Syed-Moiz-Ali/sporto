import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:referee_app/features/matches/presentation/screens/schedule_matches_screen.dart';
import 'package:referee_app/features/matches/presentation/widgets/match_live_score.dart';
import 'package:referee_data/referee_data.dart';
import 'package:ui_kit/ui_kit.dart';

import 'fake_score.dart';

RefereeMatchResponse _liveMatch() {
  return RefereeMatchResponse(
    id: 101,
    tournamentName: 'Hyderabad Corporate Cricket Tournament',
    roundName: 'Quarter Final',
    venueName: 'Hyderabad',
    statusLabel: 'Live',
    canOfficiate: true,
    teamA: const RefereeMatchTeam(
      id: 1,
      name: 'Thunder Titans',
      score: '28/1',
    ),
    teamB: const RefereeMatchTeam(
      id: 2,
      name: 'Royal Strikers',
      score: '31/2',
    ),
    raw: const {
      'current_batter': 'Rahul',
      'current_bowler': 'Amit',
    },
  );
}

RefereeMatchResponse _upcomingMatch() {
  return RefereeMatchResponse(
    id: 102,
    tournamentName: 'Asia Cup 2026',
    roundName: 'Quarter Final',
    scheduledAt:
        DateTime.now().add(const Duration(minutes: 24)).toIso8601String(),
    venueName: 'Hyderabad',
    statusLabel: 'Scheduled',
    canOfficiate: true,
    teamA: const RefereeMatchTeam(id: 3, name: 'Delhi Warriors'),
    teamB: const RefereeMatchTeam(id: 4, name: 'Hyd Highlanders'),
    raw: const {
      'teams_verified': true,
      'ground_ready': true,
    },
  );
}

RefereeMatchResponse _delayedMatch() {
  return RefereeMatchResponse(
    id: 103,
    tournamentName: 'Asia Cup 2026',
    roundName: 'Final',
    scheduledAt: DateTime.now().add(const Duration(hours: 1)).toIso8601String(),
    venueName: 'Hyderabad',
    statusLabel: 'Delayed',
    canOfficiate: true,
    teamA: const RefereeMatchTeam(
      id: 5,
      name: 'Thunder Titans',
      score: '28/1',
    ),
    teamB: const RefereeMatchTeam(
      id: 6,
      name: 'Royal Strikers',
      score: 'Yet to Bat',
    ),
    raw: const {
      'delay_reason': 'Heavy Rain',
      'resume_time': '4:00 PM',
    },
  );
}

RefereeMatchResponse _completedMatch() {
  return RefereeMatchResponse(
    id: 104,
    tournamentName: 'Asia Cup 2026',
    roundName: 'Final',
    scheduledAt: DateTime.now().toIso8601String(),
    venueName: 'Hyderabad',
    statusLabel: 'Completed',
    teamA: const RefereeMatchTeam(
      id: 7,
      name: 'Delhi Warriors',
      score: '90/2',
    ),
    teamB: const RefereeMatchTeam(
      id: 8,
      name: 'Hyd Highlanders',
      score: '85/3',
    ),
    raw: const {
      'winner_team_name': 'Delhi Warriors',
    },
  );
}

Widget _wrap({Key? key, required List<RefereeMatchResponse> matches}) {
  return MaterialApp(
    theme: SportoTheme.darkTheme,
    home: ScheduleMatchesScreen(
      key: key,
      matchesFuture: Future.value(matches),
    ),
  );
}

void main() {
  setUp(() {
    MatchLiveScore.debugFetchOverride = (matchId) async =>
        fakeLiveScoreResponse(matchId: matchId, includeSecondTeam: true);
  });

  tearDown(() {
    MatchLiveScore.debugFetchOverride = null;
  });

  testWidgets('renders live, upcoming, delayed and completed states',
      (tester) async {
    final matches = [
      _liveMatch(),
      _upcomingMatch(),
      _delayedMatch(),
      _completedMatch(),
    ];

    for (final size in const [Size(390, 844), Size(360, 800)]) {
      tester.view.physicalSize = size;
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(
        _wrap(key: ValueKey(size), matches: matches),
      );
      await tester.pumpAndSettle();

      expect(find.text('Matches'), findsOneWidget);
      expect(find.text('Open Live Match'), findsOneWidget);
      expect(find.text('Thunder Titans'), findsWidgets);

      await tester.tap(find.text('Upcoming').first);
      await tester.pumpAndSettle();
      expect(find.text('Asia Cup 2026'), findsWidgets);
      expect(find.text('Verify Teams'), findsOneWidget);
      expect(find.text('Heavy Rain'), findsOneWidget);
      expect(find.text('Update Status'), findsOneWidget);

      await tester.tap(find.text('Completed').first);
      await tester.pumpAndSettle();
      expect(find.text('Delhi Warriors Won'), findsOneWidget);
      expect(find.text('View Report'), findsOneWidget);
      expect(find.text('90/2'), findsWidgets);
      expect(tester.takeException(), isNull);
    }
  });

  testWidgets('search dialog filters matches', (tester) async {
    await tester.pumpWidget(
      _wrap(matches: [_upcomingMatch(), _completedMatch()]),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Search'));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField), 'Delhi');
    await tester.tap(find.widgetWithText(TextButton, 'Search'));
    await tester.pumpAndSettle();
    expect(find.text('Delhi'), findsOneWidget); // query shown in pill
    expect(find.text('Delhi Warriors'), findsWidgets);
    expect(tester.takeException(), isNull);
  });
}
