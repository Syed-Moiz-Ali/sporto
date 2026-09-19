import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:referee_app/features/matches/presentation/screens/match_verification_screen.dart';
import 'package:shared_domain/shared_domain.dart';
import 'package:ui_kit/ui_kit.dart';

void main() {
  final dummyMatch = CricketMatchEntity(
    id: '20481',
    tournamentName: 'Asia Cup 2026',
    teamA: TeamEntity(
      id: '1',
      name: 'Delhi Warriors',
      logoEmoji: '🏏',
      players: [
        PlayerEntity(
          id: 'p1',
          name: 'Shrvn Prajapati',
          role: 'Captain',
          jerseyNumber: 7,
        ),
        PlayerEntity(
          id: 'p2',
          name: 'Amit Kumar',
          role: 'Batsman',
          jerseyNumber: 10,
        ),
        PlayerEntity(
          id: 'p3',
          name: 'Manish K',
          role: 'Bowler',
          jerseyNumber: 18,
        ),
        PlayerEntity(
          id: 'p4',
          name: 'Sumit Nai',
          role: 'AllRounder',
          jerseyNumber: 24,
        ),
        PlayerEntity(
          id: 'p5',
          name: 'Mayank S',
          role: 'WicketKeeper',
          jerseyNumber: 99,
        ),
      ],
    ),
    teamB: TeamEntity(
      id: '2',
      name: 'Hyd Highlanders',
      logoEmoji: '🦅',
      players: [
        PlayerEntity(
          id: 'p6',
          name: 'Vikram Reddy',
          role: 'Captain',
          jerseyNumber: 1,
        ),
        PlayerEntity(
          id: 'p7',
          name: 'Dev Kumar',
          role: 'Batsman',
          jerseyNumber: 8,
        ),
        PlayerEntity(
          id: 'p8',
          name: 'Pankaj S',
          role: 'Bowler',
          jerseyNumber: 11,
        ),
        PlayerEntity(
          id: 'p9',
          name: 'Rohan A',
          role: 'AllRounder',
          jerseyNumber: 14,
        ),
        PlayerEntity(
          id: 'p10',
          name: 'Vinayak L',
          role: 'WicketKeeper',
          jerseyNumber: 22,
        ),
      ],
    ),
    venue: 'Hyderabad',
    scheduledTime: DateTime(2026, 9, 19, 18, 30),
    status: MatchStatus.upcoming,
    refereeName: 'Official Umpire',
  );

  Widget createWidget({CricketMatchEntity? match, String? matchId}) {
    return MaterialApp(
      theme: SportoTheme.darkTheme,
      home: MatchVerificationScreen(
        match: match ?? dummyMatch,
        matchId: matchId ?? '20481',
      ),
    );
  }

  group('MatchVerificationScreen - Figma Exact UI & Interaction Tests', () {
    testWidgets('Renders exact Figma Header and Match Summary Card',
        (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(createWidget());
      await tester.pumpAndSettle();

      // Header elements
      expect(find.text('Match Verification'), findsOneWidget);
      expect(find.text('Match #SPT-20481'), findsOneWidget);

      // Match Summary Card elements
      expect(find.text('Quarter Final'), findsOneWidget);
      expect(find.text('Today, 06:30 PM'), findsOneWidget);
      expect(find.text('Upcoming'), findsOneWidget);
      expect(find.text('Asia Cup 2026'), findsOneWidget);
      expect(find.text('Hyderabad'), findsOneWidget);
      expect(find.text('Vs'), findsOneWidget);
      expect(find.text('at 06:30 PM'), findsOneWidget);
    });

    testWidgets('Renders Team Verification split cards with players & actions',
        (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(createWidget());
      await tester.pumpAndSettle();

      // Section title
      expect(find.text('Team Verification'), findsOneWidget);

      // Team labels and status
      expect(find.text('Team 1'), findsNWidgets(2)); // Card header & checklist
      expect(find.text('Team 2'), findsNWidgets(2));
      expect(find.text('Team Ready'), findsNWidgets(2));

      // Team names
      expect(find.text('Delhi Warriors'), findsNWidgets(2)); // Card & match card
      expect(find.text('Hyd Highlanders'), findsNWidgets(2));

      // Player names
      expect(find.textContaining('Shrvn Prajapati'), findsOneWidget);
      expect(find.textContaining('Amit Kumar'), findsOneWidget);
      expect(find.textContaining('Vikram Reddy'), findsOneWidget);
      expect(find.textContaining('Dev Kumar'), findsOneWidget);

      // Initial Button States: both teams present
      expect(find.text('✓  Present'), findsNWidgets(2));
      expect(find.text('Mark As Absent'), findsNWidgets(2));

      // Final Checklist
      expect(find.text('Final Checklist'), findsOneWidget);
      expect(find.text('Toss'), findsOneWidget);

      // Bottom Action Button: Ready To Toss
      expect(find.text('Ready To Toss'), findsOneWidget);
    });

    testWidgets(
        'Marking Team 2 Absent displays Absent Decision Card & Walkover actions',
        (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(createWidget());
      await tester.pumpAndSettle();

      // Initially "Ready To Toss" is visible
      expect(find.text('Ready To Toss'), findsOneWidget);

      // Tap "Mark As Absent" for Team 2 (the second "Mark As Absent" button)
      final markAbsentButtons = find.text('Mark As Absent');
      expect(markAbsentButtons, findsNWidgets(2));
      await tester.tap(markAbsentButtons.last);
      await tester.pumpAndSettle();

      // Team 2 status should now be "Team Not Ready"
      expect(find.text('Team Not Ready'), findsOneWidget);
      expect(find.text('✓  Absent'), findsOneWidget);

      // Absent Decision Card appears
      expect(
        find.text("Team 2 - Hyd Highlanders\nhasn't checked in."),
        findsOneWidget,
      );
      expect(
        find.text('Grace period expired. Choose how to handle\nthis match.'),
        findsOneWidget,
      );

      // Walkover action button appears
      expect(
        find.text('Award Walkover to Delhi Warriors'),
        findsOneWidget,
      );

      // Bottom "Mark As Absent" action appears
      expect(find.text('Mark As Absent'), findsNWidgets(2));

      // "Ready To Toss" should no longer be visible
      expect(find.text('Ready To Toss'), findsNothing);

      // Tapping "Mark As Present" restores Team 2
      final markPresentButton = find.text('Mark As Present');
      expect(markPresentButton, findsOneWidget);
      await tester.tap(markPresentButton);
      await tester.pumpAndSettle();

      // "Ready To Toss" is restored
      expect(find.text('Ready To Toss'), findsOneWidget);
      expect(find.text("Team 2 - Hyd Highlanders\nhasn't checked in."),
          findsNothing);
    });

    testWidgets('Award walkover triggers feedback snackbar', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(createWidget());
      await tester.pumpAndSettle();

      // Mark Team 1 absent
      await tester.tap(find.text('Mark As Absent').first);
      await tester.pumpAndSettle();

      // Award Walkover to Team 2
      final walkoverBtn = find.text('Award Walkover to Hyd Highlanders');
      expect(walkoverBtn, findsOneWidget);
      await tester.tap(walkoverBtn);
      await tester.pump();

      expect(
        find.text('Walkover awarded to Hyd Highlanders'),
        findsOneWidget,
      );
    });

    testWidgets('Renders properly without overflow on standard 390x844 viewport',
        (tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(createWidget());
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(find.text('Match Verification'), findsOneWidget);
    });
  });
}
