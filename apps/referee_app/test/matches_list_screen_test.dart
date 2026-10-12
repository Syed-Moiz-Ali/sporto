import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:referee_app/features/matches/presentation/screens/matches_list_screen.dart';
import 'package:referee_app/features/matches/presentation/widgets/match_live_score.dart';
import 'package:referee_data/referee_data.dart';
import 'package:ui_kit/ui_kit.dart';

import 'fake_score.dart';

void main() {
  setUp(() {
    // Cards render the authoritative GET /score — fake it per match.
    MatchLiveScore.debugFetchOverride = (matchId) async {
      if (matchId == 103) {
        return fakeCompletedScoreResponse(
          matchId: matchId,
          teamAName: 'Mumbai Indians',
          teamBName: 'Chennai Kings',
        );
      }
      return fakeLiveScoreResponse(
        matchId: matchId,
        oversPerInnings: 6,
      );
    };
  });

  tearDown(() {
    MatchLiveScore.debugFetchOverride = null;
  });

  RefereeMatchResponse createLiveMatch() {
    return RefereeMatchResponse(
      id: 101,
      tournamentName: 'Jaipur Super Over',
      roundName: 'Match 1',
      matchDate: '2026-09-19',
      startTime: '06:30 PM',
      venueName: 'SMS Stadium, Jaipur',
      status: 1,
      statusLabel: 'Live',
      teamA: const RefereeMatchTeam(id: 1, name: 'Thunder Titans'),
      teamB: const RefereeMatchTeam(id: 2, name: 'Royal Strikers'),
      canOfficiate: true,
    );
  }

  RefereeMatchResponse createUpcomingMatch({int id = 102}) {
    return RefereeMatchResponse(
      id: id,
      tournamentName: 'Asia Cup 2026',
      roundName: 'Quarter Final',
      scheduledAt: 'Today, 08:00 PM',
      venueName: 'Gachibowli Stadium, Hyderabad',
      status: 0,
      statusLabel: 'Scheduled',
      teamA: const RefereeMatchTeam(id: 3, name: 'Thunder Titans'),
      teamB: const RefereeMatchTeam(id: 4, name: 'Royal Smashers'),
      canOfficiate: true,
    );
  }

  RefereeMatchResponse createCompletedMatch({int id = 103}) {
    return RefereeMatchResponse(
      id: id,
      tournamentName: 'Mumbai Premier Cup',
      roundName: 'Final',
      matchDate: '2026-09-18',
      startTime: '04:00 PM',
      venueName: 'Wankhede Stadium, Mumbai',
      status: 2,
      statusLabel: 'Completed',
      teamA: const RefereeMatchTeam(id: 5, name: 'Mumbai Indians'),
      teamB: const RefereeMatchTeam(id: 6, name: 'Chennai Kings'),
      canOfficiate: true,
    );
  }

  RefereeMatchResponse createDelayedMatch({int id = 104}) {
    return RefereeMatchResponse(
      id: id,
      tournamentName: 'Monsoon Trophy',
      roundName: 'Qualifier 1',
      matchDate: '2026-09-19',
      startTime: '03:00 PM',
      venueName: 'Eden Gardens, Kolkata',
      status: 3,
      statusLabel: 'Delayed',
      teamA: const RefereeMatchTeam(id: 7, name: 'Kolkata Tigers'),
      teamB: const RefereeMatchTeam(id: 8, name: 'Punjab Lions'),
      canOfficiate: true,
      raw: const {
        'delay_reason': 'Heavy Rain',
        'resume_time': '4:00 PM',
      },
    );
  }

  RefereeMatchRequestResponse createMatchRequest({int id = 201}) {
    return RefereeMatchRequestResponse(
      id: id,
      assignmentId: 901,
      tournamentName: 'National Championship',
      roundName: 'Semi Final 2',
      scheduledAt: 'Tomorrow, 10:00 AM',
      venueName: 'Chinnaswamy Stadium, Bangalore',
      role: 'Main Umpire',
      teamA: const RefereeMatchTeam(id: 9, name: 'Bangalore Blasters'),
      teamB: const RefereeMatchTeam(id: 10, name: 'Delhi Dynamos'),
      raw: const {
        'pay_amount': '₹ 1,500',
      },
    );
  }

  Widget createTestWidget({
    Future<RefereeMatchesPayload>? payloadFuture,
  }) {
    return MaterialApp(
      theme: SportoTheme.darkTheme,
      home: MatchesListScreen(
        payloadFuture: payloadFuture,
      ),
    );
  }

  Future<void> pumpScreen(WidgetTester tester) async {
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
  }

  group('MatchesListScreen - Exact Figma matches.json UI Tests', () {
    testWidgets('Opens Requests first when pending assignments exist',
        (tester) async {
      final payload = RefereeMatchesPayload(
        matches: [
          createLiveMatch(),
          createUpcomingMatch(),
          createCompletedMatch(),
          createDelayedMatch(),
        ],
        requests: [createMatchRequest()],
      );

      await tester.pumpWidget(
        createTestWidget(payloadFuture: Future.value(payload)),
      );
      await pumpScreen(tester);

      expect(find.text('Match Requests'), findsOneWidget);
      expect(find.text('1 Pending Requests'), findsOneWidget);
    });

    testWidgets('Renders Filter Tab Bar with dynamic tab badges',
        (tester) async {
      final payload = RefereeMatchesPayload(
        matches: [
          createLiveMatch(),
          createUpcomingMatch(),
        ],
        requests: [createMatchRequest()],
      );

      await tester.pumpWidget(
        createTestWidget(payloadFuture: Future.value(payload)),
      );
      await pumpScreen(tester);

      expect(find.byKey(const ValueKey('filter_tab_All')), findsOneWidget);
      expect(find.byKey(const ValueKey('filter_tab_Upcoming')), findsOneWidget);
      expect(find.byKey(const ValueKey('filter_tab_Live')), findsOneWidget);
      expect(
          find.byKey(const ValueKey('filter_tab_Completed')), findsOneWidget);
      expect(
        find.byKey(const ValueKey('filter_tab_Requests (1)')),
        findsOneWidget,
      );
    });

    testWidgets('Renders Live Match Card with score, batter/bowler & action',
        (tester) async {
      final payload = RefereeMatchesPayload(
        matches: [createLiveMatch()],
        requests: const [],
      );

      await tester.pumpWidget(
        createTestWidget(payloadFuture: Future.value(payload)),
      );
      await pumpScreen(tester);

      expect(find.text('Live Now'), findsOneWidget);
      expect(find.text('Jaipur Super Over'), findsOneWidget);
      expect(find.text('Thunder Titans'), findsOneWidget);
      expect(find.text('28/1'), findsOneWidget);
      expect(find.text('Royal Strikers'), findsOneWidget);
      expect(find.text('Yet to Bat'), findsOneWidget);
      expect(find.textContaining('Rahul'), findsOneWidget);
      expect(find.textContaining('Amit'), findsOneWidget);
      expect(find.text('Over - 2.1/6'), findsOneWidget);
      expect(find.text('Continue Scoring'), findsOneWidget);
    });

    testWidgets('Renders Upcoming Match Card with checklist and Verify Teams',
        (tester) async {
      final payload = RefereeMatchesPayload(
        matches: [createUpcomingMatch()],
        requests: const [],
      );

      await tester.pumpWidget(
        createTestWidget(payloadFuture: Future.value(payload)),
      );
      await pumpScreen(tester);

      expect(find.text('Quarter Final'), findsOneWidget);
      expect(find.text('Asia Cup 2026'), findsOneWidget);
      expect(find.text('Royal Smashers'), findsOneWidget);
      expect(find.text('✓ Teams Verified'), findsOneWidget);
      expect(find.text('✓ Ground Ready'), findsOneWidget);
      expect(find.text('Toss Pending'), findsOneWidget);
    });

    testWidgets(
        'Routes upcoming match to Verify Teams (toss runs via verification)',
        (tester) async {
      final match = RefereeMatchResponse(
        id: 105,
        tournamentName: 'Asia Cup 2026',
        roundName: 'Semi Final',
        scheduledAt: 'Today, 07:00 PM',
        venueName: 'SMS Stadium',
        status: 0,
        statusLabel: 'Toss Pending',
        teamA: const RefereeMatchTeam(id: 1, name: 'Delhi Warriors'),
        teamB: const RefereeMatchTeam(id: 2, name: 'Hyd Highlanders'),
        canOfficiate: true,
      );
      final payload = RefereeMatchesPayload(
        matches: [match],
        requests: const [],
      );

      await tester.pumpWidget(
        createTestWidget(payloadFuture: Future.value(payload)),
      );
      await pumpScreen(tester);

      expect(find.text('✓ Teams Verified'), findsOneWidget);
      expect(find.text('✓ Ground Ready'), findsOneWidget);
      expect(find.text('Toss Pending'), findsOneWidget);
      // Authoritative routing has no verified/toss-pending flag, so every
      // upcoming match enters through verification.
      expect(find.text('Verify Teams'), findsOneWidget);
    });

    testWidgets('Renders Start Scoring state when toss is completed',
        (tester) async {
      final match = RefereeMatchResponse(
        id: 106,
        tournamentName: 'Asia Cup 2026',
        roundName: 'Semi Final',
        scheduledAt: 'Today, 07:00 PM',
        venueName: 'SMS Stadium',
        status: 0,
        statusLabel: 'Toss Done',
        teamA: const RefereeMatchTeam(id: 1, name: 'Delhi Warriors'),
        teamB: const RefereeMatchTeam(id: 2, name: 'Hyd Highlanders'),
        canOfficiate: true,
        raw: const {
          'toss': {'state': 'TOSS_COMPLETED', 'is_completed': true},
        },
      );
      final payload = RefereeMatchesPayload(
        matches: [match],
        requests: const [],
      );

      await tester.pumpWidget(
        createTestWidget(payloadFuture: Future.value(payload)),
      );
      await pumpScreen(tester);

      expect(find.text('✓ Teams Verified'), findsOneWidget);
      expect(find.text('✓ Ground Ready'), findsOneWidget);
      expect(find.text('✓ Toss Completed'), findsOneWidget);
      expect(find.text('Start Scoring'), findsOneWidget);
    });

    testWidgets('Renders tournament names with crisp white text',
        (tester) async {
      final payload = RefereeMatchesPayload(
        matches: [createUpcomingMatch()],
        requests: const [],
      );

      await tester.pumpWidget(
        createTestWidget(payloadFuture: Future.value(payload)),
      );
      await pumpScreen(tester);

      final tournamentText = tester.widget<Text>(find.text('Asia Cup 2026'));
      expect(tournamentText.style?.color, const Color(0xFFFFFFFF));
    });

    testWidgets('Renders Completed Match Card with winner and View Report',
        (tester) async {
      final payload = RefereeMatchesPayload(
        matches: [createCompletedMatch()],
        requests: const [],
      );

      await tester.pumpWidget(
        createTestWidget(payloadFuture: Future.value(payload)),
      );
      await pumpScreen(tester);

      expect(find.text('Mumbai Premier Cup'), findsOneWidget);
      expect(find.text('Mumbai Indians'), findsWidgets);
      expect(find.text('90/2'), findsOneWidget);
      expect(find.text('Chennai Kings'), findsOneWidget);
      expect(find.text('85/3'), findsOneWidget);
      expect(find.textContaining('Won'), findsOneWidget);
      expect(find.text('View Report'), findsOneWidget);
    });

    testWidgets('Renders Delayed Match Card with weather alert & Update Status',
        (tester) async {
      final payload = RefereeMatchesPayload(
        matches: [createDelayedMatch()],
        requests: const [],
      );

      await tester.pumpWidget(
        createTestWidget(payloadFuture: Future.value(payload)),
      );
      await pumpScreen(tester);

      expect(find.text('Monsoon Trophy'), findsOneWidget);
      // Banner now shows the real status, not a fake weather reason.
      expect(find.text('Delayed'), findsWidgets);
      expect(find.text('Update Status'), findsOneWidget);
    });

    testWidgets('Filter tabs filter list items correctly', (tester) async {
      tester.view.physicalSize = const Size(390, 1000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      final payload = RefereeMatchesPayload(
        matches: [
          createLiveMatch(),
          createUpcomingMatch(),
          createCompletedMatch(),
        ],
        requests: const [],
      );

      await tester.pumpWidget(
        createTestWidget(payloadFuture: Future.value(payload)),
      );
      await pumpScreen(tester);

      // Initially on "All" tab - all 3 match cards should be present
      expect(find.text('Jaipur Super Over'), findsOneWidget);
      expect(find.text('Asia Cup 2026'), findsOneWidget);
      expect(find.text('Mumbai Premier Cup'), findsOneWidget);

      // Tap "Upcoming" tab using its ValueKey
      await tester.tap(find.byKey(const ValueKey('filter_tab_Upcoming')));
      await pumpScreen(tester);

      expect(find.text('Jaipur Super Over'), findsNothing);
      expect(find.text('Asia Cup 2026'), findsOneWidget);
      expect(find.text('Mumbai Premier Cup'), findsNothing);

      // Tap "Live" tab using its ValueKey
      await tester.tap(find.byKey(const ValueKey('filter_tab_Live')));
      await pumpScreen(tester);

      expect(find.text('Jaipur Super Over'), findsOneWidget);
      expect(find.text('Asia Cup 2026'), findsNothing);
      expect(find.text('Mumbai Premier Cup'), findsNothing);

      // Tap "Completed" tab using its ValueKey after scrolling it into view
      final completedTab = find.byKey(const ValueKey('filter_tab_Completed'));
      await tester.ensureVisible(completedTab);
      await tester.tap(completedTab);
      await pumpScreen(tester);

      expect(find.text('Jaipur Super Over'), findsNothing);
      expect(find.text('Asia Cup 2026'), findsNothing);
      expect(find.text('Mumbai Premier Cup'), findsOneWidget);
    });

    testWidgets('Requests Tab displays pending requests with Accept and Reject',
        (tester) async {
      final payload = RefereeMatchesPayload(
        matches: [createLiveMatch()],
        requests: [createMatchRequest()],
      );

      await tester.pumpWidget(
        createTestWidget(payloadFuture: Future.value(payload)),
      );
      await pumpScreen(tester);

      // Tap Requests tab using its ValueKey
      await tester.tap(find.byKey(const ValueKey('filter_tab_Requests (1)')));
      await pumpScreen(tester);

      expect(find.text('Match Requests'), findsOneWidget);
      expect(find.text('1 Pending Requests'), findsOneWidget);
      expect(find.text('National Championship'), findsOneWidget);
      expect(find.text('Bangalore Blasters'), findsOneWidget);
      expect(find.text('Accept'), findsOneWidget);
      expect(find.text('Reject'), findsOneWidget);
    });

    testWidgets('Renders Clean Empty State Card when filter has no matches',
        (tester) async {
      final payload = RefereeMatchesPayload(
        matches: [createLiveMatch()], // Only live match
        requests: const [],
      );

      await tester.pumpWidget(
        createTestWidget(payloadFuture: Future.value(payload)),
      );
      await pumpScreen(tester);

      // Switch to Upcoming tab where no matches exist
      await tester.tap(find.byKey(const ValueKey('filter_tab_Upcoming')));
      await pumpScreen(tester);

      expect(find.text('No Assigned Matches'), findsOneWidget);
      expect(find.text('No upcoming matches scheduled.'), findsOneWidget);
    });

    testWidgets('Renders Skeleton Shimmer while loading', (tester) async {
      final completer = Completer<RefereeMatchesPayload>();

      await tester.pumpWidget(
        createTestWidget(payloadFuture: completer.future),
      );
      await tester.pump();

      // Shimmer elements are rendered
      expect(find.byType(AnimatedBuilder), findsWidgets);

      // Completing the future transitions to loaded content
      completer.complete(
        RefereeMatchesPayload(
          matches: [createLiveMatch()],
          requests: const [],
        ),
      );
      await pumpScreen(tester);

      expect(find.text('Jaipur Super Over'), findsOneWidget);
    });

    testWidgets('Renders without overflow on standard 390x844 viewport',
        (tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      final payload = RefereeMatchesPayload(
        matches: [
          createLiveMatch(),
          createUpcomingMatch(),
          createCompletedMatch(),
          createDelayedMatch(),
        ],
        requests: [createMatchRequest()],
      );

      await tester.pumpWidget(
        createTestWidget(payloadFuture: Future.value(payload)),
      );
      await pumpScreen(tester);

      expect(tester.takeException(), isNull);
      expect(find.text('Match Requests'), findsOneWidget);
    });
  });
}




