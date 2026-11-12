import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:partner_app/features/tournaments/presentation/screens/tournament_detail_redesign_screen.dart';
import 'package:partner_app/features/tournaments/presentation/screens/tournaments_redesign_screen.dart';
import 'package:ui_kit/ui_kit.dart';

void main() {
  testWidgets('Tournaments redesign renders SportoShimmer while loading',
      (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: SportoTheme.darkTheme,
        home: const Scaffold(
          body: TournamentsRedesignScreen(isLoading: true),
        ),
      ),
    );
    await tester.pump();

    expect(find.byType(SportoShimmer), findsWidgets);
    expect(find.text('Tournaments'), findsWidgets);
  });

  testWidgets('Tournament detail redesign renders SportoShimmer while loading',
      (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: SportoTheme.darkTheme,
        home: const TournamentDetailRedesignScreen(
          tournamentId: '1',
          isLoading: true,
        ),
      ),
    );
    await tester.pump();

    expect(find.byType(SportoShimmer), findsWidgets);
  });
}
