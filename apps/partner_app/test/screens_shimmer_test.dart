import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:partner_app/features/partner_api/application/partner_api_bloc.dart';
import 'package:partner_app/features/tournaments/application/tournament_bloc.dart';
import 'package:partner_app/features/tournaments/presentation/screens/partner_main_screen.dart';
import 'package:partner_app/features/tournaments/presentation/screens/tournaments_screen.dart';
import 'package:partner_app/features/tournaments/presentation/screens/schedule_screen.dart';
import 'package:partner_app/features/tournaments/presentation/screens/tournament_detail_screen.dart';
import 'package:ui_kit/ui_kit.dart';

class FakePartnerApiBloc extends Bloc<PartnerApiEvent, PartnerApiState>
    implements PartnerApiBloc {
  FakePartnerApiBloc([PartnerApiState initialState = const PartnerApiInitialState()])
      : super(initialState) {
    on<PartnerApiEvent>((event, emit) {});
  }
}

class FakeTournamentBloc extends Bloc<TournamentEvent, TournamentState>
    implements TournamentBloc {
  FakeTournamentBloc([TournamentState? initialState])
      : super(initialState ?? TournamentInitialState()) {
    on<TournamentEvent>((event, emit) {});
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  group('Screens Skeleton Shimmer Tests', () {
    testWidgets('TournamentsScreen renders SportoShimmer when isLoading is true',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: SportoTheme.darkTheme,
          home: const Scaffold(
            body: TournamentsScreen(isLoading: true),
          ),
        ),
      );

      expect(find.byType(SportoShimmer), findsWidgets);
      final shimmers = tester.widgetList<SportoShimmer>(find.byType(SportoShimmer));
      expect(shimmers.length, greaterThanOrEqualTo(3));
    });

    testWidgets('ScheduleScreen renders SportoShimmer when isLoading is true',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: SportoTheme.darkTheme,
          home: const Scaffold(
            body: ScheduleScreen(isLoading: true),
          ),
        ),
      );

      expect(find.byType(SportoShimmer), findsWidgets);
      final shimmers = tester.widgetList<SportoShimmer>(find.byType(SportoShimmer));
      expect(shimmers.length, greaterThanOrEqualTo(6));
    });

    testWidgets('ScheduleScreen renders normal content when isLoading is false',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: SportoTheme.darkTheme,
          home: const Scaffold(
            body: ScheduleScreen(isLoading: false),
          ),
        ),
      );

      expect(find.text('Matches'), findsOneWidget);
      expect(find.text('Live'), findsNWidgets(2)); // in stat card & tab chip
      expect(find.text('Upcoming'), findsWidgets);
      expect(find.byType(TextField), findsOneWidget);
    });

    testWidgets('PartnerMainScreen _buildHomeTab renders SportoShimmer when isLoading is true',
        (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(
        MultiBlocProvider(
          providers: [
            BlocProvider<PartnerApiBloc>(
              create: (_) => FakePartnerApiBloc(),
            ),
            BlocProvider<TournamentBloc>(
              create: (_) => FakeTournamentBloc(),
            ),
          ],
          child: MaterialApp(
            theme: SportoTheme.darkTheme,
            home: const PartnerMainScreen(
              initialIndex: 0,
              isLoading: true,
            ),
          ),
        ),
      );

      await tester.pump();

      expect(find.byType(SportoShimmer), findsWidgets);
      final shimmers = tester.widgetList<SportoShimmer>(find.byType(SportoShimmer));
      // Should have: header name shimmer, header wallet shimmer, 4 overview shimmers (x2 parts each), live tournament shimmer, today's schedule shimmers
      expect(shimmers.length, greaterThanOrEqualTo(10));
    });

    testWidgets('TournamentDetailScreen Overview tab renders SportoShimmer when isLoading is true',
        (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(
        MaterialApp(
          theme: SportoTheme.darkTheme,
          home: const Scaffold(
            body: TournamentDetailScreen(
              isLoading: true,
              initialTabIndex: 0,
            ),
          ),
        ),
      );

      await tester.pump();

      expect(find.byType(SportoShimmer), findsWidgets);
      final shimmers = tester.widgetList<SportoShimmer>(find.byType(SportoShimmer));
      expect(shimmers.length, greaterThanOrEqualTo(6));

      // Verify no hardcoded dummy data from before
      expect(find.text('Hyderabad Super Cup'), findsNothing);
      expect(find.text('Thunder Titans'), findsNothing);
      expect(find.text('Delhi Warriors'), findsNothing);
    });

    testWidgets('TournamentDetailScreen Matches tab renders SportoShimmer when isLoading is true',
        (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(
        MaterialApp(
          theme: SportoTheme.darkTheme,
          home: const Scaffold(
            body: TournamentDetailScreen(
              isLoading: true,
              initialTabIndex: 1,
            ),
          ),
        ),
      );

      await tester.pump();

      expect(find.byType(SportoShimmer), findsWidgets);
      final shimmers = tester.widgetList<SportoShimmer>(find.byType(SportoShimmer));
      expect(shimmers.length, greaterThanOrEqualTo(5));
      expect(find.text('Match 1'), findsNothing);
    });

    testWidgets('TournamentDetailScreen Referees tab renders SportoShimmer when isLoading is true',
        (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(
        MaterialApp(
          theme: SportoTheme.darkTheme,
          home: const Scaffold(
            body: TournamentDetailScreen(
              isLoading: true,
              initialTabIndex: 3,
            ),
          ),
        ),
      );

      await tester.pump();

      expect(find.byType(SportoShimmer), findsWidgets);
      final shimmers = tester.widgetList<SportoShimmer>(find.byType(SportoShimmer));
      expect(shimmers.length, greaterThanOrEqualTo(5));
      // Should not find old progress indicator
      expect(find.byType(LinearProgressIndicator), findsNothing);
    });
  });
}
