import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:referee_app/features/notifications/presentation/notification_models.dart';
import 'package:referee_app/features/notifications/presentation/notification_store.dart';
import 'package:referee_app/features/notifications/presentation/screens/notification_category_screen.dart';
import 'package:referee_app/features/notifications/presentation/screens/notification_settings_screen.dart';
import 'package:ui_kit/ui_kit.dart';

Widget _app(Widget home) {
  return MaterialApp(
    theme: SportoTheme.darkTheme,
    home: home,
  );
}

bool _toggleValue(WidgetTester tester, String id) {
  final Semantics semantics = tester.widget<Semantics>(
    find.byKey(ValueKey<String>('notification_toggle_$id')),
  );
  return semantics.properties.toggled ?? false;
}

void _setSmallPhone(WidgetTester tester) {
  tester.view.physicalSize = const Size(320, 640);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
}

void main() {
  setUp(NotificationPreferencesStore.instance.reset);

  group('NotificationSettingsScreen', () {
    testWidgets('renders the title, subtitle and all five category rows',
        (tester) async {
      await tester.pumpWidget(_app(const NotificationSettingsScreen()));
      await tester.pumpAndSettle();

      expect(find.text('Notification Settings'), findsOneWidget);
      expect(
        find.text('Choose what you want to be notified about.'),
        findsOneWidget,
      );

      for (final NotificationCategory category in NotificationCategory.values) {
        expect(
          find.text(category.title),
          findsOneWidget,
          reason: 'Missing ${category.title} row',
        );
        expect(
          find.byKey(ValueKey<String>('notification_row_${category.id}')),
          findsOneWidget,
        );
      }

      expect(find.text('Captain, Batter, Bowler'), findsOneWidget);

      final Semantics matchRow = tester.widget<Semantics>(
        find.byKey(const ValueKey<String>('notification_row_match')),
      );
      expect(matchRow.properties.button, isTrue);
      expect(matchRow.properties.label, contains('Match Notifications'));
      expect(matchRow.properties.onTap, isNotNull);
    });

    testWidgets('has an accessible back affordance', (tester) async {
      await tester.pumpWidget(_app(const NotificationSettingsScreen()));
      await tester.pumpAndSettle();

      final Semantics back = tester.widget<Semantics>(
        find.byKey(const ValueKey<String>('notification_back_button')),
      );
      expect(back.properties.label, 'Back');
      expect(back.properties.button, isTrue);
      expect(back.properties.onTap, isNotNull);

      final Size backTarget = tester.getSize(
        find.byKey(const ValueKey<String>('notification_back_button')),
      );
      expect(backTarget.width, greaterThanOrEqualTo(44));
      expect(backTarget.height, greaterThanOrEqualTo(44));

      final Size rowTarget = tester.getSize(
        find.byKey(const ValueKey<String>('notification_row_match')),
      );
      expect(rowTarget.height, greaterThanOrEqualTo(44));
    });

    testWidgets('tapping a category row opens the category screen',
        (tester) async {
      await tester.pumpWidget(_app(const NotificationSettingsScreen()));
      await tester.pumpAndSettle();

      await tester.tap(
        find.byKey(const ValueKey<String>('notification_row_tournament')),
      );
      await tester.pumpAndSettle();

      expect(find.byType(NotificationCategoryScreen), findsOneWidget);
      // Header title + the first preference inside the category share this
      // copy in the Figma content.
      expect(find.text('Tournament Updates'), findsNWidgets(2));
      expect(find.text('Fixture & Schedule Changes'), findsOneWidget);
      expect(
        find.byKey(const ValueKey<String>('notification_back_button')),
        findsOneWidget,
      );
    });

    testWidgets('back button returns to the settings list', (tester) async {
      await tester.pumpWidget(_app(const NotificationSettingsScreen()));
      await tester.pumpAndSettle();

      await tester.tap(
        find.byKey(const ValueKey<String>('notification_row_team')),
      );
      await tester.pumpAndSettle();
      expect(find.byType(NotificationCategoryScreen), findsOneWidget);

      await tester.tap(
        find.byKey(const ValueKey<String>('notification_back_button')),
      );
      await tester.pumpAndSettle();

      expect(find.byType(NotificationCategoryScreen), findsNothing);
      expect(find.byType(NotificationSettingsScreen), findsOneWidget);
    });

    testWidgets('does not overflow on a 320 px wide phone', (tester) async {
      _setSmallPhone(tester);
      await tester.pumpWidget(_app(const NotificationSettingsScreen()));
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(
        find.byKey(const ValueKey<String>('notification_row_registration')),
        findsOneWidget,
      );
    });

    testWidgets('does not overflow on a 430 px wide phone', (tester) async {
      tester.view.physicalSize = const Size(430, 932);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(_app(const NotificationSettingsScreen()));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);

      await tester.tap(
        find.byKey(const ValueKey<String>('notification_row_registration')),
      );
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      expect(find.byType(NotificationCategoryScreen), findsOneWidget);
    });
  });

  group('NotificationCategoryScreen', () {
    testWidgets('Match defaults: only Live Match Updates is ON',
        (tester) async {
      await tester.pumpWidget(
        _app(
          const NotificationCategoryScreen(
              category: NotificationCategory.match),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Match Notifications'), findsOneWidget);
      expect(
        find.text('Choose what you want to be notified about.'),
        findsOneWidget,
      );

      for (final NotificationPreference preference
          in NotificationCategory.match.preferences) {
        expect(
          _toggleValue(tester, preference.id),
          preference.defaultEnabled,
          reason: 'Wrong default for ${preference.title}',
        );
      }

      expect(_toggleValue(tester, 'live_match_updates'), isTrue);
      expect(_toggleValue(tester, 'match_reminders'), isFalse);
      expect(_toggleValue(tester, 'match_starting_soon'), isFalse);
      expect(_toggleValue(tester, 'match_results'), isFalse);

      final Semantics liveToggle = tester.widget<Semantics>(
        find.byKey(
          const ValueKey<String>('notification_toggle_live_match_updates'),
        ),
      );
      expect(liveToggle.properties.label, 'Live Match Updates');
      expect(liveToggle.properties.toggled, isTrue);
      expect(liveToggle.properties.onTap, isNotNull);

      final Size rowTarget = tester.getSize(
        find.byKey(
          const ValueKey<String>(
            'notification_pref_row_live_match_updates',
          ),
        ),
      );
      expect(rowTarget.height, greaterThanOrEqualTo(44));
    });

    testWidgets('toggling flips the local state both ways', (tester) async {
      await tester.pumpWidget(
        _app(
          const NotificationCategoryScreen(
              category: NotificationCategory.match),
        ),
      );
      await tester.pumpAndSettle();

      final Finder toggle = find.byKey(
        const ValueKey<String>('notification_toggle_match_reminders'),
      );
      expect(_toggleValue(tester, 'match_reminders'), isFalse);

      await tester.tap(toggle);
      await tester.pumpAndSettle();
      expect(_toggleValue(tester, 'match_reminders'), isTrue);

      await tester.tap(toggle);
      await tester.pumpAndSettle();
      expect(_toggleValue(tester, 'match_reminders'), isFalse);
    });

    testWidgets('preferences survive leaving and re-opening a category',
        (tester) async {
      await tester.pumpWidget(
        _app(
          const NotificationCategoryScreen(
            category: NotificationCategory.match,
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(
        find.byKey(
          const ValueKey<String>('notification_toggle_match_reminders'),
        ),
      );
      await tester.pumpAndSettle();
      expect(_toggleValue(tester, 'match_reminders'), isTrue);

      // Simulate backing out and opening the category again.
      await tester.pumpWidget(_app(const SizedBox.shrink()));
      await tester.pumpWidget(
        _app(
          const NotificationCategoryScreen(
            category: NotificationCategory.match,
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(_toggleValue(tester, 'match_reminders'), isTrue);
    });

    testWidgets('tapping the row toggles the preference', (tester) async {
      await tester.pumpWidget(
        _app(
          const NotificationCategoryScreen(
              category: NotificationCategory.others),
        ),
      );
      await tester.pumpAndSettle();

      expect(_toggleValue(tester, 'nearby_tournament_alerts'), isFalse);

      await tester.tap(
        find.byKey(
          const ValueKey<String>(
            'notification_pref_row_nearby_tournament_alerts',
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(_toggleValue(tester, 'nearby_tournament_alerts'), isTrue);
    });

    testWidgets('initialPreferences override the Figma defaults',
        (tester) async {
      final NotificationPreferences initial = NotificationPreferences(
        <String, bool>{
          'match_reminders': true,
          'live_match_updates': false,
        },
      );

      await tester.pumpWidget(
        _app(
          NotificationCategoryScreen(
            category: NotificationCategory.match,
            initialPreferences: initial,
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(_toggleValue(tester, 'match_reminders'), isTrue);
      expect(_toggleValue(tester, 'live_match_updates'), isFalse);
    });

    testWidgets('all categories use their documented defaults', (tester) async {
      for (final NotificationCategory category in NotificationCategory.values) {
        await tester.pumpWidget(
          _app(NotificationCategoryScreen(category: category)),
        );
        await tester.pumpAndSettle();

        for (final NotificationPreference preference in category.preferences) {
          expect(
            _toggleValue(tester, preference.id),
            preference.defaultEnabled,
            reason: 'Wrong default for ${category.title}/${preference.title}',
          );
        }
      }
    });

    testWidgets('does not overflow on a 320 px wide phone', (tester) async {
      _setSmallPhone(tester);
      await tester.pumpWidget(
        _app(
          const NotificationCategoryScreen(
              category: NotificationCategory.match),
        ),
      );
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(
        find.byKey(
          const ValueKey<String>(
            'notification_toggle_match_starting_soon',
          ),
        ),
        findsOneWidget,
      );
    });
  });
}
