import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:partner_app/features/partner_api/application/partner_api_bloc.dart';
import 'package:partner_app/features/tournaments/presentation/screens/create_tournament_wizard_screen.dart';
import 'package:partner_app/features/tournaments/presentation/screens/tournament_venue_planner.dart';
import 'package:partner_data/partner_data.dart';
import 'package:ui_kit/ui_kit.dart';

class _Loaded extends PartnerApiState implements PartnerApiLoadedState {
  @override
  int get configSportId => 1;
  @override
  int get configSportFormatId => 1;
  @override
  List<TournamentFormConfigFieldResponse> get cricketFormConfig => [];
  @override
  List<SportFormatResponse> get cricketFormats => [];
  @override
  List<TournamentPrizeCategoryResponse> get prizeCategories => [];
  @override
  List<Object?> get props => [];
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _Bloc extends Bloc<PartnerApiEvent, PartnerApiState>
    implements PartnerApiBloc {
  _Bloc() : super(_Loaded()) {
    on<PartnerApiEvent>((event, emit) {});
  }
}

class _Api extends PartnerRemoteDataSource {
  int creates = 0;
  final updates = <int>[];
  bool failRead = true;
  final saved = const PartnerTournamentResponse(
      id: 354,
      sportId: 1,
      sportFormatId: 1,
      tournamentTypeId: 1,
      name: 'Test tournament',
      status: 1);
  @override
  Future<PartnerTournamentResponse> saveTournamentPlanning(
      TournamentPlanningRequest request,
      {int? id}) async {
    if (id == null) {
      creates++;
    } else {
      updates.add(id);
    }
    return saved;
  }

  @override
  Future<PartnerTournamentResponse> showTournamentData(Object id) async {
    if (failRead) {
      failRead = false;
      throw StateError('Temporary read failure');
    }
    return saved;
  }

  @override
  Future<List<TournamentRound>> getRounds(Object id) async => rounds;
  @override
  Future<List<PlannedTournamentVenue>> getPlannedVenues(Object id) async => [];
}

final rounds = [
  TournamentRound.fromJson(
      {'id': 402, 'name': 'Round of 128', 'sequence': 1, 'match_count': 0})
];
const venue = PlannedTournamentVenue(
    id: 460,
    name: 'Main Stadium',
    location: 'Downtown Sports Complex',
    groundType: 'Turf',
    capacity: 5,
    isPrimary: true,
    allocations: [
      VenueRoundPlan(
          roundId: 402,
          date: '2026-10-17',
          startTime: '09:00',
          endTime: '18:00',
          capacity: 3,
          isPrimary: true)
    ]);

void main() {
  testWidgets(
      'details Continue creates once and retries GET failure on the same ID',
      (tester) async {
    tester.view.physicalSize = const Size(430, 2000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final bloc = _Bloc(), api = _Api();
    addTearDown(bloc.close);
    await tester.pumpWidget(BlocProvider<PartnerApiBloc>.value(
        value: bloc,
        child: MaterialApp(
            theme: SportoTheme.darkTheme,
            home: CreateTournamentWizardScreen(initialStep: 2, api: api))));
    await tester.pumpAndSettle();
    final fields = tester
        .widgetList<SportoTextField>(find.byType(SportoTextField))
        .where((f) => f.label != 'From' && f.label != 'To')
        .toList();
    final values = [
      'Test tournament',
      '2026-10-17',
      '2026-10-15',
      '18:00',
      '90',
      '09:00',
      '15',
      '2',
      '128'
    ];
    expect(fields.length, values.length);
    for (var i = 0; i < fields.length; i++) {
      fields[i].controller!.text = values[i];
    }
    final next = find.widgetWithText(PrimaryButton, 'Continue');
    await tester.ensureVisible(next);
    await tester.tap(next);
    await tester.pumpAndSettle();
    expect(api.creates, 1);
    expect(find.textContaining('Temporary read failure'), findsOneWidget);
    await tester.tap(next);
    await tester.pumpAndSettle();
    expect(api.creates, 1);
    expect(api.updates, [354]);
    expect(find.text('Venue Setup'), findsOneWidget);
    expect(find.textContaining('Round of 128:'), findsNothing);
    expect(tester.takeException(), isNull);
  });
  testWidgets(
      'venue editor renders API rounds and allocations without overflow',
      (tester) async {
    tester.view.physicalSize = const Size(390, 1400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(MaterialApp(
        theme: SportoTheme.darkTheme,
        home: Scaffold(
            body: TournamentVenuePlanner(
                rounds: rounds,
                startDate: DateTime(2026, 10, 17),
                initial: venue,
                save: (v) async => v))));
    await tester.pumpAndSettle();
    expect(find.text('Round of 128'), findsOneWidget);
    expect(find.textContaining('2026-10-17'), findsOneWidget);
    expect(find.byType(DropdownButtonFormField<int>), findsOneWidget);
    expect(find.text('Add round allocation'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('save shows button loader and preserves form on API failure',
      (tester) async {
    final completer = Completer<PlannedTournamentVenue>();
    PlannedTournamentVenue? sent;
    await tester.pumpWidget(MaterialApp(
        theme: SportoTheme.darkTheme,
        home: Scaffold(
            body: TournamentVenuePlanner(
                rounds: rounds,
                startDate: DateTime(2026, 10, 17),
                initial: venue,
                save: (v) {
                  sent = v;
                  return completer.future;
                }))));
    await tester.pumpAndSettle();
    final button = find.byType(PrimaryButton);
    await tester.ensureVisible(button);
    await tester.tap(button);
    await tester.pump();
    expect(tester.widget<PrimaryButton>(button).loading, isTrue);
    expect(sent!.allocations.single.roundId, 402);
    expect(sent!.toJson().containsKey('round_id'), isFalse);
    completer.completeError(StateError('Allocation rejected'));
    await tester.pumpAndSettle();
    expect(find.textContaining('Allocation rejected'), findsOneWidget);
    expect(tester.widget<PrimaryButton>(button).loading, isFalse);
    expect(find.text('Round of 128'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
