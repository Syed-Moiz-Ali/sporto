import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:referee_data/referee_data.dart';
import 'package:referee_app/features/matches/presentation/screens/referee_home_screen.dart';
import 'package:ui_kit/ui_kit.dart';

void main() {
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
      scheduledAt: 'Today, 08:00 PM',
      venueName: 'Gachibowli Stadium, Hyderabad',
      status: 0,
      statusLabel: 'Scheduled',
      teamA: const RefereeMatchTeam(id: 3, name: 'Thunder Titans'),
      teamB: const RefereeMatchTeam(id: 4, name: 'Royal Smashers'),
    );
  }

  RefereeMatchResponse createAssignedMatch({int id = 103}) {
    return RefereeMatchResponse(
      id: id,
      tournamentName: 'Asia Cup 2026',
      roundName: 'Semi Final',
      scheduledAt: 'Tomorrow, 06:30 PM',
      venueName: 'Uppal Stadium, Hyderabad',
      status: 0,
      statusLabel: 'Scheduled',
      teamA: const RefereeMatchTeam(id: 5, name: 'Delhi Warriors'),
      teamB: const RefereeMatchTeam(id: 6, name: 'Hyd Highlanders'),
    );
  }

  Widget createTestWidget({
    Future<List<RefereeMatchResponse>>? matchesFuture,
    VoidCallback? onViewAll,
  }) {
    return MaterialApp(
      theme: SportoTheme.darkTheme,
      home: RefereeHomeScreen(
        matchesFuture: matchesFuture,
        onViewAll: onViewAll,
      ),
    );
  }

  group('RefereeHomeScreen - Exact Figma Home.json UI Tests', () {
    testWidgets('Renders exact Figma Header and Search Bar', (tester) async {
      await tester.pumpWidget(
        createTestWidget(
          matchesFuture: Future.value([createLiveMatch()]),
        ),
      );
      await tester.pumpAndSettle();

      // Header Elements
      expect(find.text('Good Evening'), findsOneWidget);
      expect(find.text('Priya Agrawal'), findsOneWidget);
      expect(find.text('₹ 500'), findsOneWidget);
      expect(find.byIcon(Icons.add_rounded), findsOneWidget);
      expect(find.byIcon(Icons.notifications_none_rounded), findsOneWidget);

      // Search Bar Elements
      expect(find.text('Search cricket, football..'), findsOneWidget);
    });

    testWidgets('Renders Overview Stats with dynamic counts from matches',
        (tester) async {
      final matches = [
        createLiveMatch(),
        createUpcomingMatch(id: 102),
        createUpcomingMatch(id: 103),
        createAssignedMatch(id: 104),
      ];

      await tester.pumpWidget(
        createTestWidget(
          matchesFuture: Future.value(matches),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Live Now'), findsWidgets);
      expect(find.text('Upcoming'), findsWidgets);
      expect(find.text('Assigned'), findsWidgets);
      expect(find.textContaining('Completed'), findsWidgets);
      expect(find.textContaining('Cancelled'), findsWidgets);
    });

    testWidgets(
        'Renders Live Match Card with scores, batter/bowler & Continue Scoring action',
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
      expect(find.textContaining('Rahul'), findsOneWidget);
      expect(find.textContaining('Amit'), findsOneWidget);
      expect(find.text('Over - 2.1/6'), findsOneWidget);
      expect(find.text('Continue Scoring'), findsOneWidget);
    });

    testWidgets(
        'Renders Next Match Card with countdown and Verify Teams action',
        (tester) async {
      await tester.pumpWidget(
        createTestWidget(
          matchesFuture: Future.value([createUpcomingMatch()]),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Next Match'), findsOneWidget);
      expect(find.text('Asia Cup 2026'), findsOneWidget);
      expect(find.text('Royal Smashers'), findsOneWidget);
      expect(find.textContaining('Starts in'), findsOneWidget);
      expect(find.text('Verify Teams'), findsOneWidget);
    });

    testWidgets(
        'Renders Assigned Matches section with View All callback and Ads Banner',
        (tester) async {
      bool viewAllTapped = false;
      final matches = [
        createUpcomingMatch(id: 102),
        createAssignedMatch(id: 103),
      ];

      await tester.pumpWidget(
        createTestWidget(
          matchesFuture: Future.value(matches),
          onViewAll: () => viewAllTapped = true,
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Assigned Matches (2)'), findsOneWidget);
      final viewAll = find.text('View All');
      expect(viewAll, findsOneWidget);
      await tester.tap(viewAll);
      expect(viewAllTapped, isTrue);

      // Ads Banner
      expect(find.text('Ads Banner'), findsOneWidget);
    });

    testWidgets('Renders Clean Empty State Card when no matches exist',
        (tester) async {
      await tester.pumpWidget(
        createTestWidget(
          matchesFuture: Future.value(const []),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('No Assigned Matches'), findsOneWidget);
      expect(find.text('Enjoy your day!'), findsOneWidget);
      expect(find.text('Ads Banner'), findsOneWidget);
    });

    testWidgets('Renders Skeleton Shimmer while loading', (tester) async {
      final completer = Completer<List<RefereeMatchResponse>>();

      await tester.pumpWidget(
        createTestWidget(
          matchesFuture: completer.future,
        ),
      );
      await tester.pump();

      // Shimmer elements are rendered
      expect(find.byType(AnimatedBuilder), findsWidgets);

      // Completing the future transitions to loaded content
      completer.complete([createLiveMatch()]);
      await tester.pumpAndSettle();

      expect(find.text('Jaipur Super Over'), findsOneWidget);
    });

    testWidgets('Renders without overflow on standard 390x844 viewport',
        (tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      final matches = [
        createLiveMatch(),
        createUpcomingMatch(id: 102),
        createAssignedMatch(id: 103),
      ];

      await tester.pumpWidget(
        createTestWidget(
          matchesFuture: Future.value(matches),
        ),
      );
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(find.text('Priya Agrawal'), findsOneWidget);
    });
  });
}
