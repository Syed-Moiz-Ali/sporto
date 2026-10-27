import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:referee_app/features/matches/presentation/widgets/scoring_redesign_widgets.dart';
import 'package:ui_kit/ui_kit.dart';

Widget _wrap(Widget child) {
  return MaterialApp(
    theme: SportoTheme.darkTheme,
    home: Scaffold(
      backgroundColor: const Color(0xFF090C10),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: child,
        ),
      ),
    ),
  );
}

Widget _summary({bool showScores = false}) {
  return ScoringRedesignMatchSummary(
    scale: 1,
    stage: 'Quarter Final',
    tournament: 'Asia Cup 2026',
    venue: 'Hyderabad',
    leftTeam: 'Hyd Highlanders',
    leftRole: 'Batting',
    leftScore: '90/2',
    rightTeam: 'Delhi Warriors',
    rightRole: 'Bowling',
    rightScore: '85/3',
    showScores: showScores,
  );
}

Widget _scoreCard({bool showThisOver = false}) {
  return ScoringRedesignScoreCard(
    scale: 1,
    title: 'Hyd Highlanders',
    score: '80/2',
    overText: 'Over 4/5',
    ballText: 'Ball 2/6',
    showThisOver: showThisOver,
    bowlerName: 'Amit Kumar',
    balls: const [
      ScoringRedesignBall(label: '4', style: ScoringRedesignBallStyle.four),
      ScoringRedesignBall.run('1'),
      ScoringRedesignBall.empty(),
      ScoringRedesignBall.empty(),
      ScoringRedesignBall.empty(),
      ScoringRedesignBall.empty(),
    ],
  );
}

Widget _fullScoringColumn() {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      const ScoringRedesignSportCard(
        scale: 1,
        sport: 'Cricket',
        code: 'SP-10245',
      ),
      const SizedBox(height: 20),
      _summary(),
      const SizedBox(height: 20),
      _scoreCard(showThisOver: true),
      const SizedBox(height: 21),
      ScoringRedesignRunPad(
        scale: 1,
        bowlerName: 'Dev Kumar',
        runValues: const [0, 1, 2, 4, 6],
        onRun: (_) {},
        onWicket: () {},
        onWide: () {},
        onNoBall: () {},
      ),
    ],
  );
}

void main() {
  testWidgets('scoring widgets render without overflow on 390 and 360',
      (tester) async {
    for (final size in const [Size(390, 844), Size(360, 800)]) {
      tester.view.physicalSize = size;
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(_wrap(_fullScoringColumn()));
      await tester.pumpAndSettle();

      expect(find.text('Cricket'), findsOneWidget);
      expect(find.text('Select Bowler'), findsNothing);
      expect(find.text('80/2'), findsOneWidget);
      expect(find.text('This Over — Dev Kumar'), findsOneWidget);
      expect(tester.takeException(), isNull);
    }
  });

  testWidgets('bowler list renders and reports selection', (tester) async {
    String? selected;
    await tester.pumpWidget(
      _wrap(
        ScoringRedesignBowlerList(
          scale: 1,
          title: 'Select Bowler for — Over 1',
          options: const [
            ScoringRedesignBowlerOption(
              id: '1',
              name: 'Vikram Reddy (Captain)',
            ),
            ScoringRedesignBowlerOption(
              id: '2',
              name: 'Dev Kumar',
              selected: true,
            ),
          ],
          onSelected: (id) => selected = id,
          actionLabel: 'Start Over 1',
          onAction: () {},
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Select Bowler for — Over 1'), findsOneWidget);
    expect(find.text('Vikram Reddy (Captain)'), findsOneWidget);
    await tester.tap(find.text('Vikram Reddy (Captain)'));
    expect(selected, '1');
    expect(tester.takeException(), isNull);
  });

  testWidgets('final result flow shows OTP and verifies 6 digits',
      (tester) async {
    var completed = false;
    var header = '';
    await tester.pumpWidget(
      _wrap(
        ScoringRedesignFinalFlow(
          scale: 1,
          sport: 'Cricket',
          code: 'SP-10245',
          stage: 'Quarter Final',
          tournament: 'Asia Cup 2026',
          venue: 'Hyderabad',
          leftTeam: 'Hyd Highlanders',
          rightTeam: 'Delhi Warriors',
          leftScore: '90/2',
          rightScore: '85/3',
          winner: 'Hyd Highlanders',
          scoreOverText: 'Over 5/5',
          scoreBallText: 'Ball 6/6',
          sessionStartedText: 'Session Started via OTP at 5:00 PM',
          expectedOtp: null,
          onComplete: () async => completed = true,
          onHeaderTitle: (title) => header = title,
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Proceed to Submit Result'), findsOneWidget);
    await tester.tap(find.text('Proceed to Submit Result'));
    await tester.pumpAndSettle();

    expect(find.text('Submit Final Result'), findsOneWidget);
    expect(header, 'Final Result');
    await tester.tap(find.text('Submit Final Result'));
    await tester.pumpAndSettle();

    expect(find.text('End Match?'), findsOneWidget);
    expect(find.text('Verify OTP & End Match'), findsOneWidget);
    expect(find.text('Session Started via OTP at 5:00 PM'), findsOneWidget);

    await tester.tap(find.text('Verify OTP & End Match'));
    await tester.pump();
    expect(find.text('Enter the 6-digit match OTP.'), findsOneWidget);

    await tester.enterText(find.byType(TextField), '123456');
    await tester.tap(find.text('Verify OTP & End Match'));
    await tester.pump();
    expect(completed, isTrue);
    expect(tester.takeException(), isNull);
  });

  testWidgets('result submitted renders without overflow', (tester) async {
    tester.view.physicalSize = const Size(360, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    var historyTapped = false;
    await tester.pumpWidget(
      _wrap(
        ScoringRedesignResultSubmitted(
          scale: 1,
          sport: 'Cricket',
          code: 'SP-10245',
          source: 'by Partner',
          stage: 'Quarter Final',
          tournament: 'Asia Cup 2026',
          venue: 'Hyderabad',
          leftTeam: 'Hyd Highlanders',
          leftScore: '90/2',
          rightTeam: 'Delhi Warriors',
          rightScore: '85/3',
          winner: 'Hyd Highlanders',
          onViewHistory: () => historyTapped = true,
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('RESULT SUBMITTED'), findsOneWidget);
    await tester.tap(find.text('View Match History'));
    expect(historyTapped, isTrue);
    expect(tester.takeException(), isNull);
  });
}
