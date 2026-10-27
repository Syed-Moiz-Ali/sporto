import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:referee_app/features/matches/presentation/screens/match_verification_screen.dart';
import 'package:referee_app/features/matches/presentation/screens/start_match_screen.dart';
import 'package:referee_app/features/matches/presentation/widgets/before_toss_widgets.dart';
import 'package:shared_domain/shared_domain.dart';
import 'package:ui_kit/ui_kit.dart';

void main() {
  final dummyMatch = CricketMatchEntity(
    id: '20481',
    tournamentName: 'Asia Cup 2026',
    teamA: const TeamEntity(
      id: '1',
      name: 'Delhi Warriors',
      logoEmoji: '',
      players: [],
    ),
    teamB: const TeamEntity(
      id: '2',
      name: 'Hyd Highlanders',
      logoEmoji: '',
      players: [],
    ),
    venue: 'Hyderabad',
    scheduledTime: DateTime.now().add(const Duration(hours: 2, minutes: 15)),
    status: MatchStatus.upcoming,
    refereeName: 'Official Umpire',
  );

  Widget createDetailsWidget() {
    return MaterialApp(
      theme: SportoTheme.darkTheme,
      home: MatchVerificationScreen(
        match: dummyMatch,
        matchId: dummyMatch.id,
      ),
    );
  }

  Widget createStartWidget({String? expectedOtp}) {
    final data = BeforeTossMatch.fromEntity(dummyMatch);
    return MaterialApp(
      theme: SportoTheme.darkTheme,
      home: StartMatchScreen(
        match: BeforeTossMatch(
          tournament: data.tournament,
          venue: data.venue,
          location: data.location,
          teamA: data.teamA,
          teamB: data.teamB,
          sport: data.sport,
          code: data.code,
          sourceLabel: data.sourceLabel,
          dateText: data.dateText,
          startTimeText: data.startTimeText,
          durationText: data.durationText,
          expectedOtp: expectedOtp,
          matchId: data.matchId,
        ),
      ),
    );
  }

  group('Before Toss — Match Details (Figma 01)', () {
    testWidgets('renders header, match card and final checklist',
        (tester) async {
      await tester.pumpWidget(createDetailsWidget());
      await tester.pumpAndSettle();

      expect(find.text('Match Details'), findsOneWidget);
      expect(find.text('Cricket'), findsOneWidget);
      expect(find.text('SP-20481'), findsOneWidget);
      expect(find.text('by Partner'), findsOneWidget);
      expect(find.text('Upcoming'), findsOneWidget);
      expect(find.text('Asia Cup 2026'), findsOneWidget);
      expect(find.text('Delhi Warriors'), findsOneWidget);
      expect(find.text('Hyd Highlanders'), findsOneWidget);
      expect(find.text('Vs'), findsOneWidget);
      expect(find.text('Booking Location'), findsOneWidget);
      expect(find.text('Booking Details'), findsOneWidget);
      expect(find.text('Final Checklist'), findsOneWidget);
      expect(find.text('Team 1'), findsOneWidget);
      expect(find.text('Team 2'), findsOneWidget);
      expect(find.text('Toss'), findsOneWidget);
      expect(find.text('START MATCH'), findsOneWidget);
    });

    testWidgets('renders without overflow on 390x844 and 360x800',
        (tester) async {
      for (final size in const [Size(390, 844), Size(360, 800)]) {
        tester.view.physicalSize = size;
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);

        await tester.pumpWidget(createDetailsWidget());
        await tester.pumpAndSettle();

        expect(tester.takeException(), isNull);
      }
    });
  });

  testWidgets('START MATCH opens OTP and verification continues to toss',
      (tester) async {
    final router = GoRouter(
      initialLocation: '/',
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) => MatchVerificationScreen(
            match: dummyMatch,
            matchId: dummyMatch.id,
          ),
        ),
        GoRoute(
          path: '/start-match',
          builder: (context, state) => StartMatchScreen(
            match: state.extra is BeforeTossMatch
                ? state.extra as BeforeTossMatch
                : null,
          ),
        ),
        GoRoute(
          path: '/conduct-toss',
          builder: (context, state) =>
              const Scaffold(body: Text('CONDUCT TOSS')),
        ),
      ],
    );
    addTearDown(router.dispose);

    await tester.pumpWidget(
      MaterialApp.router(
        theme: SportoTheme.darkTheme,
        routerConfig: router,
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('START MATCH'));
    await tester.pumpAndSettle();
    expect(find.text('Start Session?'), findsOneWidget);

    await tester.enterText(find.byType(TextField), '123456');
    await tester.tap(find.text('Verify OTP & Start Match'));
    await tester.pumpAndSettle();

    expect(find.text('CONDUCT TOSS'), findsOneWidget);
  });

  group('Before Toss — Start Match OTP (Figma 02)', () {
    testWidgets('renders Start Session card and OTP boxes', (tester) async {
      await tester.pumpWidget(createStartWidget());
      await tester.pumpAndSettle();

      expect(find.text('Start Match'), findsOneWidget);
      expect(find.text('Match verification'), findsOneWidget);
      expect(find.text('Start Session?'), findsOneWidget);
      expect(
        find.text('Share this OTP with your referee to start the session.'),
        findsOneWidget,
      );
      expect(find.text('Enter 6-digit match OTP'), findsOneWidget);
      expect(find.text('|'), findsNWidgets(6));
      expect(find.text("Haven't received the OTP?"), findsOneWidget);
      expect(find.text('Verify OTP & Start Match'), findsOneWidget);
      expect(find.text('Having trouble?'), findsOneWidget);
    });

    testWidgets('accepts 6-digit input in the OTP boxes', (tester) async {
      await tester.pumpWidget(createStartWidget());
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField), '123456');
      await tester.pump();

      for (final digit in ['1', '2', '3', '4', '5', '6']) {
        expect(find.text(digit), findsOneWidget);
      }
    });

    testWidgets('short OTP shows validation message', (tester) async {
      await tester.pumpWidget(createStartWidget());
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField), '12');
      await tester.tap(find.text('Verify OTP & Start Match'));
      await tester.pump();

      expect(find.text('Enter the 6-digit match OTP.'), findsOneWidget);
    });

    testWidgets('wrong OTP shows invalid message when expected OTP is known',
        (tester) async {
      await tester.pumpWidget(createStartWidget(expectedOtp: '654321'));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField), '123456');
      await tester.tap(find.text('Verify OTP & Start Match'));
      await tester.pump();

      expect(
        find.text('Incorrect OTP. Please check with the booking user.'),
        findsOneWidget,
      );
    });

    testWidgets('renders without overflow on 390x844 and 360x800',
        (tester) async {
      for (final size in const [Size(390, 844), Size(360, 800)]) {
        tester.view.physicalSize = size;
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);

        await tester.pumpWidget(createStartWidget());
        await tester.pumpAndSettle();

        expect(tester.takeException(), isNull);
      }
    });
  });
}
