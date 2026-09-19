import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:referee_app/features/matches/presentation/screens/referee_scoring_tab_screen.dart';
import 'package:referee_data/referee_data.dart';
import 'package:ui_kit/ui_kit.dart';

void main() {
  RefereeMatchResponse createFigmaSpotlightMatch() {
    return RefereeMatchResponse(
      id: 101,
      tournamentName: 'Jaipur Super Over',
      roundName: 'Final',
      matchDate: '2026-09-19',
      startTime: '06:30 PM',
      venueName: 'Hyderabad',
      status: 1,
      statusLabel: 'Live',
      teamA: const RefereeMatchTeam(id: 1, name: 'Thunder Titans'),
      teamB: const RefereeMatchTeam(id: 2, name: 'Royal Strikers'),
      raw: const {
        'team_a_score': '28/1',
        'team_b_score': 'Yet to Bat',
        'current_batter': 'Rahul',
        'current_bowler': 'Amit',
        'overs_text': 'Over - 2.1',
        'duration': '08:25',
      },
    );
  }

  Widget createTestWidget({
    Future<List<RefereeMatchResponse>>? payloadFuture,
    void Function(String matchId, String matchCode)? onNavigateToScoring,
  }) {
    return MaterialApp(
      theme: SportoTheme.darkTheme,
      home: RefereeScoringTabScreen(
        payloadFuture: payloadFuture,
        onNavigateToScoring: onNavigateToScoring,
      ),
    );
  }

  Future<void> pumpScreen(WidgetTester tester) async {
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
  }

  group('RefereeScoringTabScreen - Exact Figma Scoring.json UI Tests', () {
    testWidgets('Renders Header with Title and Gradient Matches Count',
        (tester) async {
      final matches = [createFigmaSpotlightMatch()];

      await tester.pumpWidget(
        createTestWidget(payloadFuture: Future.value(matches)),
      );
      await pumpScreen(tester);

      expect(find.text("Today's Matches"), findsOneWidget);
      expect(find.text('1 Matches Assigned'), findsOneWidget);
    });

    testWidgets(
        'Renders exact Figma Spotlight Match Card with Final, Live Now, Overs',
        (tester) async {
      final matches = [createFigmaSpotlightMatch()];

      await tester.pumpWidget(
        createTestWidget(payloadFuture: Future.value(matches)),
      );
      await pumpScreen(tester);

      expect(find.text('Final'), findsOneWidget);
      expect(find.text('Live Now'), findsOneWidget);
      expect(find.text('Over - 2.1'), findsOneWidget);
    });

    testWidgets('Renders tournament name with crisp white text',
        (tester) async {
      final matches = [createFigmaSpotlightMatch()];

      await tester.pumpWidget(
        createTestWidget(payloadFuture: Future.value(matches)),
      );
      await pumpScreen(tester);

      final tournamentText =
          tester.widget<Text>(find.text('Jaipur Super Over'));
      expect(tournamentText.style?.color, const Color(0xFFFFFFFF));
    });

    testWidgets('Renders teams matchup and scores', (tester) async {
      final matches = [createFigmaSpotlightMatch()];

      await tester.pumpWidget(
        createTestWidget(payloadFuture: Future.value(matches)),
      );
      await pumpScreen(tester);

      expect(find.text('Thunder Titans'), findsOneWidget);
      expect(find.text('28/1'), findsOneWidget);
      expect(find.text('Vs'), findsOneWidget);
      expect(find.text('Royal Strikers'), findsOneWidget);
      expect(find.text('Yet to Bat'), findsOneWidget);
    });

    testWidgets('Renders Current Batter, Current Bowler, and Duration',
        (tester) async {
      final matches = [createFigmaSpotlightMatch()];

      await tester.pumpWidget(
        createTestWidget(payloadFuture: Future.value(matches)),
      );
      await pumpScreen(tester);

      expect(find.textContaining('Rahul'), findsOneWidget);
      expect(find.textContaining('Amit'), findsOneWidget);
      expect(find.textContaining('08:25'), findsOneWidget);
      expect(find.text('Continue Scoring'), findsOneWidget);
    });

    testWidgets('Tapping Continue Scoring invokes navigation callback',
        (tester) async {
      String? navigatedId;
      String? navigatedCode;

      final matches = [createFigmaSpotlightMatch()];

      await tester.pumpWidget(
        createTestWidget(
          payloadFuture: Future.value(matches),
          onNavigateToScoring: (id, code) {
            navigatedId = id;
            navigatedCode = code;
          },
        ),
      );
      await pumpScreen(tester);

      await tester.tap(find.byKey(const ValueKey('continue_scoring_btn')));
      await tester.pump();

      expect(navigatedId, '101');
      expect(navigatedCode, 'Jaipur Super Over');
    });

    testWidgets('Renders Clean Empty State Card when no matches exist',
        (tester) async {
      await tester.pumpWidget(
        createTestWidget(payloadFuture: Future.value(const [])),
      );
      await pumpScreen(tester);

      expect(find.text('No Matches in Scoring'), findsOneWidget);
      expect(find.text('0 Matches Assigned'), findsOneWidget);
      expect(find.text('Refresh'), findsOneWidget);
    });

    testWidgets('Renders Skeleton Shimmer while loading', (tester) async {
      final completer = Completer<List<RefereeMatchResponse>>();

      await tester.pumpWidget(
        createTestWidget(payloadFuture: completer.future),
      );
      await tester.pump();

      expect(find.byType(RefereeScoringTabScreen), findsOneWidget);
      expect(find.text("Today's Matches"), findsNothing);

      completer.complete([createFigmaSpotlightMatch()]);
      await pumpScreen(tester);

      expect(find.text("Today's Matches"), findsOneWidget);
    });

    testWidgets('Renders without overflow on standard 390x844 viewport',
        (tester) async {
      tester.view.physicalSize = const Size(390 * 3, 844 * 3);
      tester.view.devicePixelRatio = 3.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      final matches = [createFigmaSpotlightMatch()];

      await tester.pumpWidget(
        createTestWidget(payloadFuture: Future.value(matches)),
      );
      await pumpScreen(tester);

      expect(tester.takeException(), isNull);
    });
  });
}
