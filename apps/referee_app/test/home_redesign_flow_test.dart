import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:referee_data/referee_data.dart';
import 'package:referee_app/features/matches/presentation/screens/accept_booking_screen.dart';
import 'package:referee_app/features/matches/presentation/screens/booking_confirmed_screen.dart';
import 'package:referee_app/features/matches/presentation/screens/incoming_requests_screen.dart';
import 'package:referee_app/features/matches/presentation/screens/request_details_screen.dart';
import 'package:ui_kit/ui_kit.dart';

RefereeMatchRequestResponse _request() {
  return RefereeMatchRequestResponse(
    id: 55,
    assignmentId: 550,
    tournamentName: 'Hyderabad Corporate Cricket Tournament',
    matchNumber: 'SP-10245',
    matchDate: '2026-10-12',
    startTime: '17:00:00',
    venueName: 'KPHB Indoor Stadium',
    location: 'ABC Sports Arena, Madhapur, Hyderabad',
    statusLabel: 'Scheduled',
    teamA: const RefereeMatchTeam(id: 7, name: 'Rahul Kumar'),
    teamB: const RefereeMatchTeam(id: 8, name: 'Royal Strikers'),
    raw: const {
      'booked_by': 'Rahul Kumar',
      'booked_by_type': 'user',
      'fee': 900,
      'distance_km': 8.4,
      'duration_hours': 2,
    },
  );
}

Widget _wrap(Widget child) {
  return MaterialApp(
    theme: SportoTheme.darkTheme,
    home: child,
  );
}

void main() {
  setUp(() {
    final binding = TestWidgetsFlutterBinding.ensureInitialized();
    binding.window.physicalSizeTestValue = const Size(360, 800);
    binding.window.devicePixelRatioTestValue = 1.0;
  });

  tearDown(() {
    final binding = TestWidgetsFlutterBinding.ensureInitialized();
    binding.window.clearPhysicalSizeTestValue();
    binding.window.clearDevicePixelRatioTestValue();
  });

  testWidgets('Incoming Requests renders request cards without overflow',
      (tester) async {
    await tester.pumpWidget(
      _wrap(IncomingRequestsScreen(requestsFuture: Future.value([_request()]))),
    );
    await tester.pumpAndSettle();

    expect(find.text('Incoming Requests'), findsOneWidget);
    expect(find.text('Rahul Kumar'), findsOneWidget);
    expect(find.text('Accept'), findsOneWidget);
    expect(find.text('Decline'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Request Details renders all sections without overflow',
      (tester) async {
    await tester.pumpWidget(
      _wrap(RequestDetailsScreen(request: _request())),
    );
    await tester.pumpAndSettle();

    expect(find.text('Request Details'), findsOneWidget);
    expect(find.text('Booked by'), findsOneWidget);
    expect(find.text('Booking Details'), findsOneWidget);
    expect(find.text('Referee Responsibilities'), findsOneWidget);
    expect(find.text('Accept'), findsOneWidget);
    expect(find.text('Decline'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Accept Booking renders confirmation without overflow',
      (tester) async {
    await tester.pumpWidget(
      _wrap(AcceptBookingScreen(request: _request())),
    );
    await tester.pumpAndSettle();

    expect(find.text('ACCEPT BOOKING?'), findsOneWidget);
    expect(find.text('You are accepting:'), findsOneWidget);
    expect(find.text('Confirm Accept'), findsOneWidget);
    expect(find.text('Cancel'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Booking Confirmed renders success without overflow',
      (tester) async {
    await tester.pumpWidget(
      _wrap(BookingConfirmedScreen(request: _request())),
    );
    await tester.pumpAndSettle();

    expect(find.text('BOOKING CONFIRMED'), findsOneWidget);
    expect(find.text('View Upcoming'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
