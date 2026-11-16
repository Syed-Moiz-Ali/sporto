import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:referee_app/features/matches/presentation/screens/profile_screen.dart';
import 'package:referee_data/referee_data.dart';
import 'package:ui_kit/ui_kit.dart';

Widget _app(Widget child) {
  return MaterialApp(
    theme: SportoTheme.darkTheme,
    home: Scaffold(
      backgroundColor: const Color(0xFF090C10),
      body: child,
    ),
  );
}

void _useScreenSize(WidgetTester tester) {
  tester.view.physicalSize = const Size(390, 844);
  tester.view.devicePixelRatio = 1;
  addTearDown(() {
    tester.view.resetPhysicalSize();
    tester.view.resetDevicePixelRatio();
  });
}

void main() {
  group('Referee profile stats', () {
    testWidgets('renders API match, rating and dispute values', (tester) async {
      _useScreenSize(tester);
      const profile = RefereeProfileResponse(
        name: 'Mayank Reddy',
        mobile: '9876543210',
        sports: ['Cricket'],
        totalMatches: 42,
        rating: 4.75,
        disputesCount: 3,
      );

      await tester.pumpWidget(
        _app(
          RefereeProfileScreen(loadProfile: () async => profile),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('42'), findsOneWidget);
      expect(find.text('4.8'), findsOneWidget);
      expect(find.text('3'), findsOneWidget);
      expect(find.text('Matches'), findsOneWidget);
      expect(find.text('Rating'), findsOneWidget);
      expect(find.text('Disputes'), findsOneWidget);
      expect(find.text('4.9'), findsNothing);
    });

    testWidgets('renders em dashes when API stats are nullable',
        (tester) async {
      _useScreenSize(tester);
      const profile = RefereeProfileResponse(
        name: 'Mayank Reddy',
        mobile: '9876543210',
        sports: ['Cricket'],
      );

      await tester.pumpWidget(
        _app(
          RefereeProfileScreen(loadProfile: () async => profile),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('—'), findsNWidgets(3));
      expect(find.text('Matches'), findsOneWidget);
      expect(find.text('Rating'), findsOneWidget);
      expect(find.text('Disputes'), findsOneWidget);
    });
  });
}
