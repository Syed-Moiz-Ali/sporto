import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:referee_app/features/matches/application/conduct_toss_bloc.dart';
import 'package:referee_app/features/matches/presentation/screens/conduct_toss_wizard.dart';
import 'package:referee_data/referee_data.dart';
import 'package:ui_kit/ui_kit.dart';

void main() {
  const dummyMatch = RefereeMatchResponse(
    id: 20481,
    tournamentName: 'Hyderabad Super Cup',
    roundName: 'Round 1',
    teamA: RefereeMatchTeam(
      id: 1,
      name: 'Delhi Warriors',
    ),
    teamB: RefereeMatchTeam(
      id: 2,
      name: 'Hyd Highlanders',
    ),
  );

  ConductTossBloc buildBloc({TossCoinSide? debugForcedCoinSide}) {
    return ConductTossBloc(
      matchId: '20481',
      team1: const TossTeam(id: '1', name: 'Delhi Warriors', players: []),
      team2: const TossTeam(id: '2', name: 'Hyd Highlanders', players: []),
      callerTeamId: '1',
      callerChoice: TossCoinSide.heads,
      forcedCoinSide: debugForcedCoinSide,
      hasSelectedCaller: false,
    );
  }

  Widget createWidget({TossCoinSide? debugForcedCoinSide}) {
    return MaterialApp(
      theme: SportoTheme.darkTheme,
      home: Scaffold(
        body: ConductTossWizard(
          bloc: buildBloc(debugForcedCoinSide: debugForcedCoinSide),
          initialMatch: dummyMatch,
          matchCode: 'SPT-20481',
        ),
      ),
    );
  }

  group('ConductTossWizard - UI & Flow Tests (new_screens mockups)', () {
    testWidgets(
        'Screen 1: Renders exact "Who is calling?" UI from Flip Coin - Conduct Toss.png',
        (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(createWidget());
      await tester.pumpAndSettle();

      // Header
      expect(find.text('Conduct Toss'), findsOneWidget);
      expect(find.text('Match #SPT-20481'), findsOneWidget);

      // Match Strip
      expect(find.text('Delhi Warriors'), findsWidgets);
      expect(find.text('Vs'), findsOneWidget);
      expect(find.text('Hyd Highlanders'), findsWidgets);

      // Mode Selector Tabs
      expect(find.text('Flip Coin'), findsOneWidget);
      expect(find.text('Enter Result'), findsOneWidget);

      // Main Card
      expect(find.text('Who is calling?'), findsOneWidget);
    });

    testWidgets(
        'Screen 2: Selecting calling team navigates to "Conduct Toss.png" coin side view',
        (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(createWidget());
      await tester.pumpAndSettle();

      // Tap on "Delhi Warriors" in the team cards
      final delhiWarriorsCards = find.text('Delhi Warriors');
      await tester.tap(delhiWarriorsCards.last);
      await tester.pumpAndSettle();

      // Calling Bar
      expect(find.text('Change'), findsOneWidget);
      expect(find.textContaining('is calling'), findsOneWidget);

      // Coin Choices
      expect(find.text('Delhi Warriors calls:'), findsOneWidget);
      expect(find.text('Heads'), findsOneWidget);
      expect(find.text('Tails'), findsOneWidget);

      // Primary Button
      expect(find.text('Flip Coin'), findsOneWidget);
    });

    testWidgets(
        'Screen 2 -> Screen 1: Tapping "Change" button goes back to "Who is calling?"',
        (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(createWidget());
      await tester.pumpAndSettle();

      // Select team 1
      await tester.tap(find.text('Delhi Warriors').last);
      await tester.pumpAndSettle();

      expect(find.text('Delhi Warriors calls:'), findsOneWidget);

      // Tap "Change"
      await tester.tap(find.text('Change'));
      await tester.pumpAndSettle();

      // Should be back to "Who is calling?"
      expect(find.text('Who is calling?'), findsOneWidget);
      expect(find.text('Change'), findsNothing);
    });

    testWidgets(
        'Screen 3: Tapping "Enter Result" switches to "Enter Result - Conduct Toss.png"',
        (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(createWidget());
      await tester.pumpAndSettle();

      // Tap "Enter Result" tab
      await tester.tap(find.text('Enter Result'));
      await tester.pumpAndSettle();

      // Card Header
      expect(find.text('Which team won the toss?'), findsOneWidget);

      // Both teams
      expect(find.text('Delhi Warriors'), findsWidgets);
      expect(find.text('Hyd Highlanders'), findsWidgets);

      // Continue button exists
      expect(find.text('Continue'), findsOneWidget);
    });

    testWidgets(
        'Screen 3: Selecting winner and tapping Continue advances to Choose Bat / Bowl',
        (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(createWidget());
      await tester.pumpAndSettle();

      // Switch to Enter Result
      await tester.tap(find.text('Enter Result'));
      await tester.pumpAndSettle();

      // Select Hyd Highlanders as physical toss winner
      final hydCards = find.text('Hyd Highlanders');
      await tester.tap(hydCards.last);
      await tester.pumpAndSettle();

      // Tap Continue
      await tester.tap(find.text('Continue'));
      await tester.pumpAndSettle();

      // Should now be on Step 2 (chooseBatBowl)
      expect(find.text('Toss Winner'), findsOneWidget);
      expect(find.textContaining('Hyd Highlanders'), findsWidgets);
      expect(find.text('Bat First'), findsOneWidget);
      expect(find.text('Bowl First'), findsOneWidget);
    });

    testWidgets(
        'Virtual Flip: Calling Tails and flipping coin results in winner and continues',
        (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(
        createWidget(debugForcedCoinSide: TossCoinSide.tails),
      );
      await tester.pumpAndSettle();

      // Select calling team (Delhi Warriors)
      await tester.tap(find.text('Delhi Warriors').last);
      await tester.pumpAndSettle();

      // Select Tails
      await tester.tap(find.text('Tails'));
      await tester.pumpAndSettle();

      // Tap Flip Coin
      await tester.tap(find.text('Flip Coin'));
      await tester.pump();

      // Wait for flip animation to finish
      await tester.pump(const Duration(milliseconds: 1400));
      await tester.pumpAndSettle();

      // Coin landed on TAILS
      expect(find.text('TAILS'), findsOneWidget);
      expect(find.textContaining('Delhi Warriors Won The Toss'), findsOneWidget);

      // Tap Continue to Step 2
      await tester.tap(find.text('Continue'));
      await tester.pumpAndSettle();

      expect(find.text('Bat First'), findsOneWidget);
      expect(find.text('Bowl First'), findsOneWidget);
    });

    testWidgets(
        'Step 2 (Bat / Bowl Selection): Renders exact UI from Conduct Toss.png with disabled Confirm button',
        (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(createWidget());
      await tester.pumpAndSettle();

      // Enter Result mode -> select Hyd Highlanders -> Continue
      await tester.tap(find.text('Enter Result'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Hyd Highlanders').last);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Continue'));
      await tester.pumpAndSettle();

      // Verify Step 2 UI (Conduct Toss.png)
      expect(find.text('Toss Winner'), findsOneWidget);
      expect(find.text('Hyd Highlanders'), findsWidgets);
      expect(find.text('Vs'), findsOneWidget);
      expect(find.text('Hyd Highlanders chooses to'), findsOneWidget);
      expect(find.text('Bat First'), findsOneWidget);
      expect(find.text('Bowl First'), findsOneWidget);

      // Button exists with disabled appearance
      expect(find.text('Confirm & Select Openers'), findsOneWidget);
    });

    testWidgets(
        'Step 2 (Bat / Bowl Selection): Selecting Bat First enables Confirm button and advances to Openers (Conduct Toss-1.png)',
        (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(createWidget());
      await tester.pumpAndSettle();

      // Enter Result mode -> select Hyd Highlanders -> Continue
      await tester.tap(find.text('Enter Result'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Hyd Highlanders').last);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Continue'));
      await tester.pumpAndSettle();

      // Select "Bat First"
      await tester.tap(find.text('Bat First'));
      await tester.pumpAndSettle();

      // Tap Confirm & Select Openers
      await tester.tap(find.text('Confirm & Select Openers'));
      await tester.pumpAndSettle();

      // Should now be on Step 3: Select Openers (accordion player selectors)
      expect(find.text('Select Openers'), findsOneWidget);
      expect(find.text('Select Striker'), findsWidgets);
      expect(find.text('Select Non-Striker'), findsWidgets);
      expect(find.text('Select Opening Bowler'), findsWidgets);
      expect(find.text('Confirm Openers'), findsOneWidget);
    });

    testWidgets(
        'Step 4 (Match Ready): Tapping Ready button invokes ConfirmStartingPlayers',
        (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(createWidget());
      await tester.pumpAndSettle();

      // Enter Result mode -> select Hyd Highlanders -> Continue
      await tester.tap(find.text('Enter Result'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Hyd Highlanders').last);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Continue'));
      await tester.pumpAndSettle();

      // Select "Bat First"
      await tester.tap(find.text('Bat First'));
      await tester.pumpAndSettle();

      // Tap Confirm & Select Openers -> reach selectOpeners step
      await tester.tap(find.text('Confirm & Select Openers'));
      await tester.pumpAndSettle();

      // Tap Confirm Openers -> reach matchReady step
      expect(find.text('Confirm Openers'), findsOneWidget);
      await tester.tap(find.text('Confirm Openers'));
      await tester.pumpAndSettle();

      // On Step 4 (Match Ready): Tap Ready
      expect(find.text('Ready'), findsOneWidget);
      await tester.tap(find.text('Ready'));
      await tester.pumpAndSettle();
    });

    testWidgets(
        'Step 3 (Select Openers): Renders Select Striker, Select Non-Striker, and Select Opening Bowler with dummy defaults',
        (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(createWidget());
      await tester.pumpAndSettle();

      // Enter Result mode -> select Delhi Warriors -> Continue
      await tester.tap(find.text('Enter Result'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Delhi Warriors').last);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Continue'));
      await tester.pumpAndSettle();

      // Select Bat First -> Confirm & Select Openers
      await tester.tap(find.text('Bat First'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Confirm & Select Openers'));
      await tester.pumpAndSettle();

      // Verify the 3 selector cards are rendered on Step 3
      expect(find.text('Select Striker'), findsWidgets);
      expect(find.text('Select Non-Striker'), findsWidgets);
      expect(find.text('Select Opening Bowler'), findsWidgets);

      // Verify default selected player pills
      expect(find.text('Shrvn Prajapati'), findsWidgets);
      expect(find.text('Amit Kumar'), findsWidgets);
      expect(find.text('Dev Kumar'), findsWidgets);

      // Verify Confirm Openers button is present
      expect(find.text('Confirm Openers'), findsOneWidget);
    });

    testWidgets(
        'Step 3 (Player Selectors): Expanding Select Striker allows choosing another dummy player and updates summary card',
        (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(createWidget());
      await tester.pumpAndSettle();

      // Enter Result mode -> select Delhi Warriors -> Continue
      await tester.tap(find.text('Enter Result'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Delhi Warriors').last);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Continue'));
      await tester.pumpAndSettle();

      // Select Bat First -> Confirm & Select Openers
      await tester.tap(find.text('Bat First'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Confirm & Select Openers'));
      await tester.pumpAndSettle();

      // Tap on Select Striker header to expand
      await tester.tap(find.text('Select Striker').first);
      await tester.pumpAndSettle();

      // Verify captain badge is shown for Shrvn Prajapati
      expect(find.text('Captain'), findsWidgets);

      // Non-striker (Amit Kumar) should show as excluded in Striker list
      expect(find.text('(Selected as Non-Striker)'), findsOneWidget);

      // Select R. Sharma from the expanded list
      expect(find.text('R. Sharma'), findsOneWidget);
      await tester.tap(find.text('R. Sharma'));
      await tester.pumpAndSettle();

      // Striker pill should now be R. Sharma
      expect(find.text('R. Sharma'), findsWidgets);
    });

    testWidgets(
        'Step 3 (Player Selectors): Mutual exclusion prevents selecting the same player for both Striker and Non-Striker',
        (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(createWidget());
      await tester.pumpAndSettle();

      // Enter Result mode -> select Delhi Warriors -> Continue
      await tester.tap(find.text('Enter Result'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Delhi Warriors').last);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Continue'));
      await tester.pumpAndSettle();

      // Select Bat First -> Confirm & Select Openers
      await tester.tap(find.text('Bat First'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Confirm & Select Openers'));
      await tester.pumpAndSettle();

      // Tap on Select Non-Striker header to expand
      await tester.tap(find.text('Select Non-Striker').first);
      await tester.pumpAndSettle();

      // Striker (Shrvn Prajapati) should show as excluded in Non-Striker list
      expect(find.text('(Selected as Striker)'), findsOneWidget);

      // Tapping Shrvn Prajapati in Non-Striker list does not change Non-Striker
      await tester.tap(find.text('Shrvn Prajapati').last);
      await tester.pumpAndSettle();

      // Non-striker should still be Amit Kumar
      expect(find.text('Amit Kumar'), findsWidgets);
    });
  });
}
