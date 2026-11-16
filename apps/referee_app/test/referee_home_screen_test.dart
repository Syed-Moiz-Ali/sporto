import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:referee_data/referee_data.dart';
import 'package:referee_app/features/matches/presentation/screens/referee_home_screen.dart';
import 'package:referee_app/features/matches/presentation/widgets/match_live_score.dart';
import 'package:ui_kit/ui_kit.dart';

import 'fake_score.dart';

void main() {
  setUp(() {
    // Live cards render the authoritative GET /score — fake it here.
    MatchLiveScore.debugFetchOverride = (matchId) async =>
        fakeLiveScoreResponse(matchId: matchId, oversPerInnings: 6);
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
      raw: const {
        'team_a_score': '28/1',
        'team_b_score': 'Waiting to Bat',
        'current_batter': 'Rahul',
        'current_bowler': 'Amit',
        'overs_text': 'Over - 2.1/6',
      },
    );
  }

  RefereeMatchResponse createUpcomingMatch({int id = 102}) {
    return RefereeMatchResponse(
      id: id,
      tournamentName: 'Asia Cup 2026',
      roundName: 'Quarter Final',
      scheduledAt:
          DateTime.now().add(const Duration(hours: 2)).toIso8601String(),
      venueName: 'Gachibowli Stadium, Hyderabad',
      status: 0,
      statusLabel: 'Scheduled',
      teamA: const RefereeMatchTeam(id: 3, name: 'Thunder Titans'),
      teamB: const RefereeMatchTeam(id: 4, name: 'Royal Smashers'),
      canOfficiate: true,
    );
  }

  RefereeMatchRequestResponse createRequest({
    int id = 55,
    int assignmentId = 550,
    String customer = 'Rahul Kumar',
    bool withFee = true,
  }) {
    return RefereeMatchRequestResponse(
      id: id,
      assignmentId: assignmentId,
      tournamentName: 'Hyderabad Corporate Cricket Tournament',
      matchNumber: 'SP-10245',
      matchDate: '2026-10-12',
      startTime: '17:00:00',
      venueName: 'KPHB Indoor Stadium',
      location: 'ABC Sports Arena, Madhapur, Hyderabad',
      statusLabel: 'Scheduled',
      teamA: const RefereeMatchTeam(id: 7, name: 'Rahul Kumar'),
      teamB: const RefereeMatchTeam(id: 8, name: 'Royal Strikers'),
      raw: {
        'booked_by': customer,
        'booked_by_type': 'user',
        if (withFee) 'fee': 1500,
        if (withFee) 'distance_km': 8.4,
        if (withFee) 'duration_hours': 2,
      },
    );
  }

  /// Match-card shape from `/matches` / dashboard `recent_requests`: no fee,
  /// no distance, no customer, no schedule.
  RefereeMatchRequestResponse createTournamentRequest() {
    return RefereeMatchRequestResponse(
      id: 99,
      assignmentId: 990,
      tournamentName: 'Tournament Cup',
      matchNumber: 'SP-99',
      statusLabel: 'Scheduled',
      teamA: const RefereeMatchTeam(id: 91, name: 'Team Alpha'),
      teamB: const RefereeMatchTeam(id: 92, name: 'Team Beta'),
      raw: const {
        'booked_by_type': 'tournament',
        'fee': null,
        'distance_km': null,
        'duration_hours': null,
        'customer_name': null,
        'schedule': null,
      },
    );
  }

  RefereeDashboardResponse createDashboard() {
    return RefereeDashboardResponse(
      profile: const RefereeDashboardProfile(id: 1, name: 'Moiz Ali'),
      availability: const RefereeAvailabilityStatusResponse(
        isAvailable: true,
        acceptingMatches: true,
      ),
      statistics: const RefereeStatistics(
        liveMatches: 2,
        upcomingMatches: 3,
        completedMatches: 7,
        pendingRequests: 2,
      ),
      wallet: const RefereeWalletSummary(
        balance: 3650,
        totalEarned: 5150,
        pendingEarnings: 1200,
      ),
      raw: {
        'profile': {'name': 'Moiz Ali'},
        'stats': {'pending_requests': 2},
      },
    );
  }

  Widget createTestWidget({
    Future<List<RefereeMatchResponse>>? matchesFuture,
    Future<RefereeHomePayload>? payloadFuture,
    Future<RefereeIncomingRequestsBundle> Function()? incomingRequestsLoader,
    Duration pollInterval = const Duration(seconds: 20),
    VoidCallback? onViewAll,
  }) {
    return MaterialApp(
      theme: SportoTheme.darkTheme,
      home: RefereeHomeScreen(
        matchesFuture: matchesFuture,
        payloadFuture: payloadFuture,
        incomingRequestsLoader: incomingRequestsLoader,
        pollInterval: pollInterval,
        onViewAll: onViewAll,
      ),
    );
  }

  group('RefereeHomeScreen - Redesigned Figma UI Tests', () {
    testWidgets('Renders header, wallet and search bar', (tester) async {
      await tester.pumpWidget(
        createTestWidget(
          matchesFuture: Future.value([createLiveMatch()]),
        ),
      );
      await tester.pumpAndSettle();

      expect(
        find.textContaining(RegExp('Good (Morning|Afternoon|Evening)')),
        findsOneWidget,
      );
      expect(find.text('Referee'), findsOneWidget);
      // Honest zero balance when the dashboard has not loaded.
      expect(find.text('0'), findsWidgets);
      expect(find.text('Search cricket, football..'), findsOneWidget);
      expect(find.text('Referee Status'), findsOneWidget);
    });

    testWidgets('Renders overview stats with dynamic counts', (tester) async {
      final matches = [
        createLiveMatch(),
        createUpcomingMatch(id: 102),
      ];

      await tester.pumpWidget(
        createTestWidget(matchesFuture: Future.value(matches)),
      );
      await tester.pumpAndSettle();

      expect(find.text('Live Now'), findsWidgets);
      expect(find.text('Upcoming'), findsWidgets);
      expect(find.text('Completed'), findsOneWidget);
      expect(find.text('Earnings'), findsOneWidget);
    });

    testWidgets('Renders dashboard wallet, stats and availability',
        (tester) async {
      await tester.pumpWidget(
        createTestWidget(
          payloadFuture: Future.value(
            RefereeHomePayload(
              dashboard: createDashboard(),
              matches: [createLiveMatch()],
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Moiz Ali'), findsOneWidget);
      expect(find.text('3,650'), findsOneWidget);
      expect(find.text('₹3,650'), findsOneWidget);
      expect(find.text('₹5,150 Total earned'), findsOneWidget);
      expect(find.text('₹1,200 Pending'), findsOneWidget);
      expect(find.text('2'), findsWidgets);
      expect(find.text('3'), findsWidgets);
      expect(find.text('7'), findsWidgets);
      expect(find.text('₹5,150'), findsOneWidget);
      expect(find.text('On'), findsOneWidget);
    });

    testWidgets('Renders live match card with score and scoring action',
        (tester) async {
      await tester.pumpWidget(
        createTestWidget(
          matchesFuture: Future.value([createLiveMatch()]),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Jaipur Super Over'), findsOneWidget);
      expect(find.text('Thunder Titans'), findsOneWidget);
      expect(find.text('28/1'), findsOneWidget);
      expect(find.text('Royal Strikers'), findsOneWidget);
      expect(find.text('Waiting to Bat'), findsOneWidget);
      expect(find.text('Continue Scoring'), findsOneWidget);
    });

    testWidgets("Renders Today's Match card with countdown and start session",
        (tester) async {
      await tester.pumpWidget(
        createTestWidget(
          matchesFuture: Future.value([createUpcomingMatch()]),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text("Today's Match"), findsOneWidget);
      expect(find.text('Asia Cup 2026'), findsOneWidget);
      expect(find.textContaining('Starts in'), findsOneWidget);
      expect(find.text('START SESSION'), findsOneWidget);
    });

    testWidgets('does not fake a countdown when the schedule is missing',
        (tester) async {
      final match = RefereeMatchResponse.fromJson({
        'id': 4197,
        'match_code': 'SP-4197',
        'status': 1,
        'status_label': 'Upcoming',
        'booking_source': 'PARTNER',
        'tournament': {'id': 421, 'name': '1017 T Cricket League'},
        'participants': {
          'team_a': 'Winner of Match 4195',
          'team_b': 'Winner of Match 4196',
        },
        'schedule': null,
        'fee': null,
        'distance_km': null,
      });
      await tester.pumpWidget(
        createTestWidget(matchesFuture: Future.value([match])),
      );
      await tester.pumpAndSettle();

      expect(find.text('1017 T Cricket League'), findsOneWidget);
      expect(find.textContaining('--:--'), findsNothing);
      expect(find.textContaining('Starts in'), findsNothing);
      expect(find.text('START SESSION'), findsOneWidget);
    });

    testWidgets('Renders incoming requests section with actions',
        (tester) async {
      await tester.pumpWidget(
        createTestWidget(
          payloadFuture: Future.value(
            RefereeHomePayload(requests: [createRequest()]),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.textContaining('Incoming Requests'), findsOneWidget);
      expect(find.text('View All'), findsOneWidget);
      expect(find.text('Rahul Kumar'), findsOneWidget);
      expect(find.text('Accept'), findsOneWidget);
      expect(find.text('Decline'), findsOneWidget);
      expect(find.text('₹1500'), findsOneWidget);
    });

    testWidgets('Does not invent distance or fee for tournament match requests',
        (tester) async {
      await tester.pumpWidget(
        createTestWidget(
          payloadFuture: Future.value(
            RefereeHomePayload(requests: [createTournamentRequest()]),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Accept'), findsOneWidget);
      expect(find.text('₹1500'), findsNothing);
      expect(find.textContaining('8.4 km'), findsNothing);
      expect(find.textContaining('km'), findsNothing);
      expect(find.textContaining('5:00 PM'), findsNothing);
      expect(find.textContaining('7:00 PM'), findsNothing);
      expect(find.text('by Tournament'), findsOneWidget);
    });

    testWidgets('Polls incoming requests without a full-page spinner',
        (tester) async {
      final polled = createRequest(
        id: 77,
        assignmentId: 770,
        customer: 'Polled Player',
      );
      final pollCompleter = Completer<RefereeIncomingRequestsBundle>();
      var calls = 0;

      await tester.pumpWidget(
        createTestWidget(
          payloadFuture: Future.value(
            RefereeHomePayload(requests: [createRequest()]),
          ),
          incomingRequestsLoader: () {
            calls++;
            return pollCompleter.future;
          },
          pollInterval: const Duration(milliseconds: 50),
        ),
      );
      await tester.pump();
      await tester.pump();

      expect(find.text('Rahul Kumar'), findsOneWidget);

      // Timer fires while the poll is still in flight: the previous request
      // stays visible instead of the whole page reverting to a spinner.
      await tester.pump(const Duration(milliseconds: 60));
      expect(calls, greaterThanOrEqualTo(1));
      expect(find.text('Rahul Kumar'), findsOneWidget);
      expect(find.text('Polled Player'), findsNothing);

      pollCompleter.complete(
        RefereeIncomingRequestsBundle(matchRequests: [polled]),
      );
      for (var i = 0; i < 4; i++) {
        await tester.pump();
      }

      expect(find.text('Polled Player'), findsOneWidget);
      expect(find.text('Rahul Kumar'), findsNothing);

      await tester.pumpWidget(const SizedBox.shrink());
    });

    testWidgets('Poll clears an empty list then repopulates it',
        (tester) async {
      final polled = createRequest(
        id: 88,
        assignmentId: 880,
        customer: 'Fresh Request',
      );
      var calls = 0;

      await tester.pumpWidget(
        createTestWidget(
          payloadFuture: Future.value(
            RefereeHomePayload(requests: [createRequest()]),
          ),
          incomingRequestsLoader: () async {
            calls++;
            if (calls == 1) {
              return const RefereeIncomingRequestsBundle();
            }
            return RefereeIncomingRequestsBundle(matchRequests: [polled]);
          },
          pollInterval: const Duration(milliseconds: 50),
        ),
      );
      await tester.pump();
      await tester.pump();
      expect(find.text('Rahul Kumar'), findsOneWidget);

      await tester.pump(const Duration(milliseconds: 60));
      for (var i = 0; i < 4; i++) {
        await tester.pump();
      }
      expect(find.text('Rahul Kumar'), findsNothing);
      expect(find.text('Fresh Request'), findsNothing);

      await tester.pump(const Duration(milliseconds: 60));
      for (var i = 0; i < 4; i++) {
        await tester.pump();
      }
      expect(find.text('Fresh Request'), findsOneWidget);

      await tester.pumpWidget(const SizedBox.shrink());
    });

    testWidgets('Renders empty assigned state and ads banner', (tester) async {
      await tester.pumpWidget(
        createTestWidget(matchesFuture: Future.value(const [])),
      );
      await tester.pumpAndSettle();

      expect(find.text('No Assigned Matches'), findsOneWidget);
      expect(find.text('Enjoy your day!'), findsOneWidget);
      expect(find.text('Ads Banner'), findsOneWidget);
    });

    testWidgets('Renders skeleton while loading', (tester) async {
      final completer = Completer<List<RefereeMatchResponse>>();

      await tester.pumpWidget(
        createTestWidget(matchesFuture: completer.future),
      );
      await tester.pump();

      expect(find.byType(AnimatedBuilder), findsWidgets);

      completer.complete([createLiveMatch()]);
      await tester.pumpAndSettle();

      expect(find.text('Jaipur Super Over'), findsOneWidget);
    });

    testWidgets('Renders without overflow on standard 390x844 viewport',
        (tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(
        createTestWidget(
          matchesFuture: Future.value([
            createLiveMatch(),
            createUpcomingMatch(id: 102),
          ]),
        ),
      );
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(find.text('Referee'), findsOneWidget);
    });

    testWidgets('Renders without overflow on narrow 360x800 viewport',
        (tester) async {
      tester.view.physicalSize = const Size(360, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(
        createTestWidget(
          payloadFuture: Future.value(
            RefereeHomePayload(
              matches: [createLiveMatch(), createUpcomingMatch(id: 102)],
              requests: [createRequest()],
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(find.text('Referee'), findsOneWidget);
    });
  });
}
