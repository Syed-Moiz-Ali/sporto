import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:referee_app/features/matches/presentation/screens/matches_list_screen.dart';
import 'package:referee_app/features/matches/presentation/screens/profile_screen.dart';
import 'package:referee_app/features/matches/presentation/screens/referee_home_screen.dart';
import 'package:referee_app/features/matches/presentation/screens/referee_scoring_tab_screen.dart';
import 'package:referee_app/features/matches/presentation/screens/referee_shell_screen.dart';
import 'package:ui_kit/ui_kit.dart';

void main() {
  Widget createTestWidget({int initialIndex = 0}) {
    return MaterialApp(
      theme: SportoTheme.darkTheme,
      home: RefereeShellScreen(initialIndex: initialIndex),
    );
  }

  Future<void> pumpScreen(WidgetTester tester) async {
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
  }

  group('RefereeShellScreen - Exact Figma Scoring.json Navbar Tests', () {
    testWidgets('Renders all 4 navigation tabs: Home, Matches, Scoring, Profile',
        (tester) async {
      await tester.pumpWidget(createTestWidget());
      await pumpScreen(tester);

      expect(find.byKey(const ValueKey('referee_nav_tab_Home')), findsOneWidget);
      expect(find.byKey(const ValueKey('referee_nav_tab_Matches')), findsOneWidget);
      expect(find.byKey(const ValueKey('referee_nav_tab_Scoring')), findsOneWidget);
      expect(find.byKey(const ValueKey('referee_nav_tab_Profile')), findsOneWidget);
    });

    testWidgets('Initial tab is Home (index 0)', (tester) async {
      await tester.pumpWidget(createTestWidget(initialIndex: 0));
      await pumpScreen(tester);

      expect(find.byType(RefereeHomeScreen), findsOneWidget);
      final homeSemantics = tester.getSemantics(
        find.byKey(const ValueKey('referee_nav_tab_Home')),
      );
      expect(homeSemantics.hasFlag(SemanticsFlag.isSelected), isTrue);
    });

    testWidgets('Tapping Matches tab switches to MatchesListScreen',
        (tester) async {
      await tester.pumpWidget(createTestWidget());
      await pumpScreen(tester);

      await tester.tap(find.byKey(const ValueKey('referee_nav_tab_Matches')));
      await pumpScreen(tester);

      expect(find.byType(MatchesListScreen), findsOneWidget);
      final matchesSemantics = tester.getSemantics(
        find.byKey(const ValueKey('referee_nav_tab_Matches')),
      );
      expect(matchesSemantics.hasFlag(SemanticsFlag.isSelected), isTrue);
    });

    testWidgets('Tapping Scoring tab switches to RefereeScoringTabScreen',
        (tester) async {
      await tester.pumpWidget(createTestWidget());
      await pumpScreen(tester);

      await tester.tap(find.byKey(const ValueKey('referee_nav_tab_Scoring')));
      await pumpScreen(tester);

      expect(find.byType(RefereeScoringTabScreen), findsOneWidget);
      final scoringSemantics = tester.getSemantics(
        find.byKey(const ValueKey('referee_nav_tab_Scoring')),
      );
      expect(scoringSemantics.hasFlag(SemanticsFlag.isSelected), isTrue);
    });

    testWidgets('Tapping Profile tab switches to RefereeProfileScreen',
        (tester) async {
      await tester.pumpWidget(createTestWidget());
      await pumpScreen(tester);

      await tester.tap(find.byKey(const ValueKey('referee_nav_tab_Profile')));
      await pumpScreen(tester);

      expect(find.byType(RefereeProfileScreen), findsOneWidget);
      final profileSemantics = tester.getSemantics(
        find.byKey(const ValueKey('referee_nav_tab_Profile')),
      );
      expect(profileSemantics.hasFlag(SemanticsFlag.isSelected), isTrue);
    });

    testWidgets('Setting initialIndex to 2 displays Scoring tab initially',
        (tester) async {
      await tester.pumpWidget(createTestWidget(initialIndex: 2));
      await pumpScreen(tester);

      expect(find.byType(RefereeScoringTabScreen), findsOneWidget);
      final scoringSemantics = tester.getSemantics(
        find.byKey(const ValueKey('referee_nav_tab_Scoring')),
      );
      expect(scoringSemantics.hasFlag(SemanticsFlag.isSelected), isTrue);
    });
  });
}
