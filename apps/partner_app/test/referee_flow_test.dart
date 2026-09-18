import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:partner_app/features/tournaments/presentation/screens/assign_referee_screen.dart';
import 'package:partner_app/features/tournaments/presentation/screens/referee_details_screen.dart';
import 'package:partner_app/features/tournaments/presentation/screens/referee_management_screen.dart';
import 'package:partner_data/partner_data.dart';
import 'package:ui_kit/ui_kit.dart';

void main() {
  group('Referee Flow Screens', () {
    const sampleMatches = [
      RefereeScheduleMatch(
        id: 'round-64',
        tournamentName: 'Hyderabad Super Cup',
        tournamentCode: 'SPT-20481',
        round: 'Round of 64',
        date: '15 July, 10:00 AM',
        ground: 'Ground A',
        teamA: 'Delhi Warriors',
        teamB: 'Hyd Highlanders',
      ),
      RefereeScheduleMatch(
        id: 'final',
        tournamentName: 'Hyderabad Super Cup',
        tournamentCode: 'SPT-20481',
        badge: 'Final',
        round: 'Round of 64',
        date: '15 July, 10:00 AM',
        ground: 'Ground A',
        teamA: 'Delhi Warriors',
        teamB: 'Hyd Highlanders',
      ),
    ];

    const sampleReferees = [
      ManagedReferee(
        name: 'Amit Verma',
        phone: '+91 98765 43210',
        level: 3,
        rating: 4.8,
        matches: 34,
        assignedMatches: 3,
        status: 'Available Now',
      ),
      ManagedReferee(
        name: 'Sandeep Rao',
        phone: '+91 98480 24680',
        level: 2,
        rating: 4.6,
        matches: 31,
        assignedMatches: 3,
        status: 'Available Now',
      ),
      ManagedReferee(
        name: 'Divya Sri',
        phone: '+91 97000 11223',
        level: 2,
        rating: 4.9,
        matches: 45,
        assignedMatches: 4,
        status: 'Busy',
        conflict: 'Scheduling conflict - same-day matches too close together',
      ),
    ];

    testWidgets(
        'RefereeManagementScreen renders exact elements from Schedules.png with provided data',
        (tester) async {
      tester.view.physicalSize = const Size(390, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        const MaterialApp(
          home: RefereeManagementScreen(
            loadRemote: false,
            initialMatches: sampleMatches,
            initialReferees: sampleReferees,
          ),
        ),
      );
      await tester.pump();

      // Header
      expect(find.text('Referee'), findsOneWidget);

      // Search bar
      expect(find.text('Search referee or tournament...'), findsOneWidget);

      // Filter chips
      expect(find.text('By Match'), findsOneWidget);
      expect(find.text('By Date'), findsOneWidget);
      expect(find.text('By Venue'), findsOneWidget);

      // Section: Needs Your Attention
      expect(find.text('Needs Your Attention'), findsOneWidget);
      expect(find.text('2 Pending'), findsOneWidget);
      expect(find.text('Referee Needed'), findsNWidgets(2));
      expect(find.text('Assign Referee'), findsNWidgets(2));

      // Section: Referee Roster
      expect(find.text('Referee Roster'), findsOneWidget);
      expect(find.text('Amit Verma'), findsOneWidget);
      expect(find.text('Sandeep Rao'), findsOneWidget);
      expect(find.text('Divya Sri'), findsOneWidget);
      expect(find.text('Available Now'), findsNWidgets(2));
      expect(find.text('Busy'), findsOneWidget);
      expect(find.text('View All'), findsNWidgets(3));
    });

    testWidgets(
        'RefereeManagementScreen renders empty states when no data is returned (no dummy fallback)',
        (tester) async {
      tester.view.physicalSize = const Size(390, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        const MaterialApp(
          home: RefereeManagementScreen(
            loadRemote: false,
            initialMatches: [],
            initialReferees: [],
          ),
        ),
      );
      await tester.pump();

      // No dummy referee names should exist
      expect(find.text('Amit Verma'), findsNothing);
      expect(find.text('Sandeep Rao'), findsNothing);
      expect(find.text('0 Pending'), findsOneWidget);
      expect(find.text('All matches have referees assigned.'), findsOneWidget);
      expect(find.text('No referees found.'), findsOneWidget);
    });

    testWidgets(
        'AssignRefereeScreen renders exact elements from Assign Referee.png with provided data',
        (tester) async {
      tester.view.physicalSize = const Size(390, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final eligibleReferees = [
        const PartnerEligibleRefereeResponse(
          id: 1,
          name: 'Amit Verma',
          level: 3,
          rating: 4.8,
          matches: 34,
          assignedMatches: 3,
          available: true,
          status: 'Available Now',
        ),
        const PartnerEligibleRefereeResponse(
          id: 2,
          name: 'Sandeep Rao',
          level: 3,
          rating: 4.6,
          matches: 31,
          assignedMatches: 3,
          available: true,
          status: 'Available Now',
        ),
        const PartnerEligibleRefereeResponse(
          id: 3,
          name: 'Divya Sri',
          level: 2,
          rating: 4.9,
          matches: 45,
          assignedMatches: 4,
          available: false,
          status: 'Busy',
          conflict:
              'Scheduling conflict - same-day matches too close together',
        ),
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: AssignRefereeScreen(
            tournamentName: 'Hyderabad Super Cup',
            tournamentCode: 'SPT-20481',
            loadRemote: false,
            initialReferees: eligibleReferees,
          ),
        ),
      );
      await tester.pump();

      // Header
      expect(find.text('Assign Referee'), findsOneWidget);

      // Match Summary Card
      expect(find.text('SPT-20481'), findsOneWidget);
      expect(find.text('Hyderabad Super Cup'), findsOneWidget);
      expect(find.text('Live Matches'), findsOneWidget);

      // Search & Sort
      expect(find.text('Search referees...'), findsOneWidget);
      expect(find.text('Sort by  |'), findsOneWidget);
      expect(find.text('Matches'), findsOneWidget);
      expect(find.text('Rating'), findsOneWidget);

      // Section: Select a referee
      expect(find.text('Select a referee'), findsOneWidget);
      expect(find.text('Amit Verma'), findsOneWidget);
      expect(find.text('Sandeep Rao'), findsOneWidget);
      expect(find.text('Divya Sri'), findsOneWidget);

      // Assign buttons: Only available referees have Assign button
      expect(find.text('Assign'), findsNWidgets(2));
    });

    testWidgets(
        'AssignRefereeScreen renders empty state when no referees returned (no dummy fallback)',
        (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: AssignRefereeScreen(
            tournamentName: 'Hyderabad Super Cup',
            tournamentCode: 'SPT-20481',
            loadRemote: false,
            initialReferees: [],
          ),
        ),
      );
      await tester.pump();

      // No dummy referee names should exist
      expect(find.text('Amit Verma'), findsNothing);
      expect(find.text('No eligible referees found.'), findsOneWidget);
    });

    testWidgets(
        'RefereeDetailsScreen renders exact elements from Referee Details.png with provided matches',
        (tester) async {
      const referee = ManagedReferee(
        name: 'Amit Verma',
        phone: '+91 98765 43210',
        level: 3,
        rating: 4.8,
        matches: 34,
        assignedMatches: 3,
        status: 'Available Now',
      );

      const sampleAllottedMatches = [
        RefereeAllottedMatch(
          id: 'match-aug-30',
          dateHeader: 'Aug 30',
          matchCount: '1 match',
          badge: 'Final',
          tournamentName: 'Hyderabad Super Cup',
          round: 'Round of 64',
          date: '15 July, 10:00 AM',
          ground: 'Ground A',
          teamA: 'Delhi Warriors',
          teamB: 'Hyd Highlanders',
        ),
        RefereeAllottedMatch(
          id: 'match-aug-31',
          dateHeader: 'Aug 31',
          matchCount: '1 match',
          badge: 'Final',
          tournamentName: 'Hyderabad Super Cup',
          round: 'Round of 64',
          date: '15 July, 10:00 AM',
          ground: 'Ground A',
          teamA: 'Delhi Warriors',
          teamB: 'Hyd Highlanders',
        ),
      ];

      await tester.pumpWidget(
        const MaterialApp(
          home: RefereeDetailsScreen(
            referee: referee,
            loadRemote: false,
            initialMatches: sampleAllottedMatches,
          ),
        ),
      );
      await tester.pump();

      // Header
      expect(find.text('Referee Details'), findsOneWidget);

      // Profile card
      expect(find.text('Amit Verma'), findsOneWidget);
      expect(find.text('+91 98765 43210'), findsOneWidget);
      expect(find.text('Available Now'), findsOneWidget);
      expect(find.text('Assigned to 3 matches'), findsOneWidget);

      // Allotted matches
      expect(find.text('All Allotted Matches'), findsOneWidget);
      expect(find.text('Final'), findsNWidgets(2));
      expect(find.text('Live Matches'), findsNWidgets(2));
      expect(find.text('Hyderabad Super Cup'), findsNWidgets(2));

      // Action buttons
      expect(find.text('Reassign'), findsNWidgets(2));
      expect(find.text('Remove Referee'), findsNWidgets(2));
    });

    testWidgets(
        'RefereeDetailsScreen renders empty state when no matches allotted (no dummy fallback)',
        (tester) async {
      const referee = ManagedReferee(
        name: 'Amit Verma',
        phone: '',
        level: 3,
        rating: 4.8,
        matches: 34,
        assignedMatches: 0,
        status: 'Available Now',
      );

      await tester.pumpWidget(
        const MaterialApp(
          home: RefereeDetailsScreen(
            referee: referee,
            loadRemote: false,
            initialMatches: [],
          ),
        ),
      );
      await tester.pump();

      expect(
        find.text('No allotted matches found for this referee.'),
        findsOneWidget,
      );
      expect(find.text('+91 98765 43210'), findsNothing);
      expect(find.text('No contact number'), findsOneWidget);
    });

    testWidgets('RefereeManagementScreen renders SportoShimmer while loading',
        (tester) async {
      final mock = MockPartnerRemoteDataSource();
      await tester.pumpWidget(
        MaterialApp(
          home: RefereeManagementScreen(
            loadRemote: true,
            remoteDataSource: mock,
          ),
        ),
      );
      await tester.pump();

      expect(find.byType(SportoShimmer), findsWidgets);

      mock.tournamentCompleter.complete([]);
      mock.refereeCompleter.complete([]);
      await tester.pumpAndSettle();
    });

    testWidgets('AssignRefereeScreen renders SportoShimmer while loading',
        (tester) async {
      final mock = MockPartnerRemoteDataSource();
      await tester.pumpWidget(
        MaterialApp(
          home: AssignRefereeScreen(
            tournamentName: 'Hyderabad Super Cup',
            tournamentCode: 'SPT-20481',
            loadRemote: true,
            remoteDataSource: mock,
          ),
        ),
      );
      await tester.pump();

      expect(find.byType(SportoShimmer), findsWidgets);

      mock.eligibleCompleter.complete([]);
      mock.refereeCompleter.complete([]);
      await tester.pumpAndSettle();
    });

    testWidgets('RefereeDetailsScreen renders SportoShimmer while loading',
        (tester) async {
      final mock = MockPartnerRemoteDataSource();
      const referee = ManagedReferee(
        id: 1,
        name: 'Amit Verma',
        phone: '+91 98765 43210',
        level: 3,
        rating: 4.8,
        matches: 34,
        assignedMatches: 3,
        status: 'Available Now',
      );

      await tester.pumpWidget(
        MaterialApp(
          home: RefereeDetailsScreen(
            referee: referee,
            loadRemote: true,
            remoteDataSource: mock,
          ),
        ),
      );
      await tester.pump();

      expect(find.byType(SportoShimmer), findsWidgets);

      mock.tournamentCompleter.complete([]);
      await tester.pumpAndSettle();
    });
  });
}

class MockPartnerRemoteDataSource extends Fake implements PartnerRemoteDataSource {
  final Completer<List<PartnerTournamentResponse>> tournamentCompleter =
      Completer<List<PartnerTournamentResponse>>();
  final Completer<List<PartnerRefereeResponse>> refereeCompleter =
      Completer<List<PartnerRefereeResponse>>();
  final Completer<List<PartnerEligibleRefereeResponse>> eligibleCompleter =
      Completer<List<PartnerEligibleRefereeResponse>>();

  @override
  Future<List<PartnerTournamentResponse>> listTournamentsData({
    int? status,
    String? search,
    int page = 1,
    int perPage = 50,
  }) =>
      tournamentCompleter.future;

  @override
  Future<List<PartnerRefereeResponse>> listPartnerRefereesData({
    int page = 1,
    int perPage = 20,
  }) =>
      refereeCompleter.future;

  @override
  Future<List<PartnerEligibleRefereeResponse>> getEligibleRefereesData(
    Object tournamentId,
  ) =>
      eligibleCompleter.future;

  @override
  Future<List<PartnerTournamentMatchResponse>> listTournamentMatchesData(
    Object tournamentId,
  ) async =>
      const [];

  @override
  Future<PartnerTournamentResponse> showTournamentData(
    Object tournamentId,
  ) async =>
      const PartnerTournamentResponse(
        id: 1,
        name: 'Hyderabad Super Cup',
        sportId: 1,
        sportFormatId: 1,
        tournamentTypeId: 1,
        status: 1,
      );
}
