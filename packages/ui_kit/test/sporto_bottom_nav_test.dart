import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ui_kit/ui_kit.dart';

void main() {
  testWidgets('every Sporto bottom navigation destination is tappable',
      (tester) async {
    var selectedIndex = 0;

    await tester.pumpWidget(
      MaterialApp(
        theme: SportoTheme.darkTheme,
        home: Scaffold(
          bottomNavigationBar: SportoBottomNav(
            currentIndex: selectedIndex,
            onTap: (index) => selectedIndex = index,
            items: const [
              SportoNavItem(Icons.home_rounded, 'Home'),
              SportoNavItem(Icons.calendar_month_outlined, 'Matches'),
              SportoNavItem(Icons.person_outline_rounded, 'Profile'),
            ],
          ),
        ),
      ),
    );

    await tester.tap(find.text('Matches'));
    await tester.pump();
    expect(selectedIndex, 1);

    await tester.tap(find.text('Profile'));
    await tester.pump();
    expect(selectedIndex, 2);
  });
}
