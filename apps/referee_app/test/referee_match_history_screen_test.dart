import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:referee_app/features/matches/presentation/screens/referee_match_history_screen.dart';
import 'package:referee_app/features/matches/presentation/widgets/match_live_score.dart';
import 'package:referee_data/referee_data.dart';
import 'package:ui_kit/ui_kit.dart';

import 'fake_score.dart';

void main() {
  RefereeMatchResponse completed({
    required int id,
    required String tournament,
    String scheduledAt = '2026-09-19T18:30:00.000000Z',
  }) {
    return RefereeMatchResponse(
      id: id,
      tournamentName: tournament,
      roundName: 'Final',
      venueName: 'Hyderabad Stadium',
      status: 3,
      statusLabel: 'Completed',
      teamA: const RefereeMatchTeam(id: 1, name: 'Thunder Titans'),
      teamB: const RefereeMatchTeam(id: 2, name: 'Royal Strikers'),
      canOfficiate: true,
      raw: {
        'scheduled_at': scheduledAt,
        'toss': {'state': 'TOSS_COMPLETED', 'is_completed': true},
      },
    );
  }

  setUp(() {
    // History cards render the final GET /score — fake it per match.
    MatchLiveScore.debugFetchOverride = (matchId) async =>
        fakeCompletedScoreResponse(
          matchId: matchId,
          teamAId: 1,
          teamBId: 2,
          teamAName: 'Thunder Titans',
          teamBName: 'Royal Strikers',
        );
  });

  tearDown(() {
    MatchLiveScore.debugFetchOverride = null;
  });

  Widget build(WidgetTester tester,
      {Future<List<RefereeMatchResponse>>? future, int initialTab = 2}) {
    return MaterialApp(
      theme: SportoTheme.darkTheme,
      home: RefereeMatchHistoryScreen(
        initialTab: initialTab,
        matchesFuture: future,
      ),
    );
  }

  Future<void> settle(WidgetTester tester) async {
    // Nested futures (matches list, then one score fetch per card).
    await tester.pump();
    for (var i = 0; i < 6; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }
  }

  group('RefereeMatchHistoryScreen - real data & filters', () {
    testWidgets('shows shimmer while loading', (tester) async {
      final completer = Completer<List<RefereeMatchResponse>>();
      await tester.pumpWidget(build(tester, future: completer.future));
      await tester.pump();

      expect(find.byType(AnimatedBuilder), findsWidgets);

      completer.complete([completed(id: 1, tournament: 'Cup')]);
      await settle(tester);

      expect(find.text('Cup'), findsOneWidget);
    });

    testWidgets('completed matches show real final scores and winner',
        (tester) async {
      await tester.pumpWidget(build(
        tester,
        future: Future.value(
            [completed(id: 101, tournament: 'Jaipur Super Over')]),
      ));
      await settle(tester);

      expect(find.text('Jaipur Super Over'), findsOneWidget);
      expect(find.text('90/2'), findsOneWidget);
      expect(find.text('85/3'), findsOneWidget);
      expect(find.text('Thunder Titans Won'), findsOneWidget);
      expect(find.text('No matches here yet.'), findsNothing);
    });

    testWidgets('error state offers retry', (tester) async {
      // Complete the error only after the FutureBuilder has subscribed —
      // a pre-failed Future.error would leak an unhandled async error.
      final completer = Completer<List<RefereeMatchResponse>>();
      await tester.pumpWidget(build(tester, future: completer.future));
      await tester.pump();
      completer.completeError(Exception('offline'));
      await settle(tester);

      expect(find.text('Unable to load match history.'), findsOneWidget);
      await tester.tap(find.text('Retry'));
      await tester.pump();
      expect(find.text('Unable to load match history.'), findsOneWidget);
    });

    testWidgets('All tab shows everything incl. dateless matches',
        (tester) async {
      await tester.pumpWidget(build(
        tester,
        future: Future.value([
          completed(id: 1, tournament: 'Dated Cup'),
          RefereeMatchResponse(
            id: 2,
            tournamentName: 'Dateless Cup',
            roundName: 'Final',
            status: 3,
            statusLabel: 'Completed',
            teamA: const RefereeMatchTeam(id: 1, name: 'A'),
            teamB: const RefereeMatchTeam(id: 2, name: 'B'),
            canOfficiate: true,
          ),
        ]),
      ));
      await settle(tester);

      expect(find.text('Dated Cup'), findsOneWidget);
      expect(find.text('Dateless Cup'), findsOneWidget);
    });
  });
}
