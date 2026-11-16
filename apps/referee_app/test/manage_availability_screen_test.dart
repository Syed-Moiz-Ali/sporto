import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:referee_app/features/availability/application/weekly_availability_cubit.dart';
import 'package:referee_app/features/availability/presentation/screens/manage_availability_screen.dart';
import 'package:referee_app/features/availability/presentation/widgets/manage_availability_widgets.dart';
import 'package:referee_data/referee_data.dart';
import 'package:ui_kit/ui_kit.dart';

const _weekdays = <RefereeWeekday>[
  RefereeWeekday(code: 'MONDAY', label: 'Monday'),
  RefereeWeekday(code: 'TUESDAY', label: 'Tuesday'),
  RefereeWeekday(code: 'WEDNESDAY', label: 'Wednesday'),
  RefereeWeekday(code: 'THURSDAY', label: 'Thursday'),
  RefereeWeekday(code: 'FRIDAY', label: 'Friday'),
  RefereeWeekday(code: 'SATURDAY', label: 'Saturday'),
  RefereeWeekday(code: 'SUNDAY', label: 'Sunday'),
];

const _days = <RefereeAvailabilityDay>[
  RefereeAvailabilityDay(day: 'MONDAY', label: 'Monday', isEnabled: true),
  RefereeAvailabilityDay(
    day: 'TUESDAY',
    label: 'Tuesday',
    isEnabled: false,
    hasConfiguredHours: true,
    hasEnabledSlots: true,
  ),
  RefereeAvailabilityDay(day: 'WEDNESDAY', label: 'Wednesday', isEnabled: true),
  RefereeAvailabilityDay(
    day: 'THURSDAY',
    label: 'Thursday',
    isEnabled: true,
    hasConfiguredHours: true,
    hasEnabledSlots: true,
  ),
  RefereeAvailabilityDay(day: 'FRIDAY', label: 'Friday', isEnabled: true),
  RefereeAvailabilityDay(day: 'SATURDAY', label: 'Saturday', isEnabled: true),
  RefereeAvailabilityDay(day: 'SUNDAY', label: 'Sunday', isEnabled: true),
];

const _slots = <RefereeAvailabilitySlot>[
  RefereeAvailabilitySlot(
    id: 1,
    day: 'TUESDAY',
    startTime: '10:00:00',
    endTime: '16:00:00',
    timezone: 'Asia/Kolkata',
  ),
  RefereeAvailabilitySlot(
    id: 2,
    day: 'TUESDAY',
    startTime: '10:00:00',
    endTime: '16:00:00',
    timezone: 'Asia/Kolkata',
  ),
  RefereeAvailabilitySlot(
    id: 3,
    day: 'TUESDAY',
    startTime: '10:00:00',
    endTime: '16:00:00',
    timezone: 'Asia/Kolkata',
    isEnabled: false,
  ),
  RefereeAvailabilitySlot(
    id: 4,
    day: 'THURSDAY',
    startTime: '12:00:00',
    endTime: '18:00:00',
    timezone: 'Asia/Kolkata',
  ),
];

WeeklyAvailabilityLoaded _fixture({bool isSaving = false}) {
  return WeeklyAvailabilityLoaded(
    weekdays: _weekdays,
    slots: _slots,
    timezone: 'Asia/Kolkata',
    days: _days,
    isSaving: isSaving,
  );
}

class _FakeWeeklyAvailabilityCubit extends WeeklyAvailabilityCubit {
  _FakeWeeklyAvailabilityCubit(this.fixture)
      : super(remoteDataSource: RefereeRemoteDataSource()) {
    emit(fixture);
  }

  final WeeklyAvailabilityLoaded fixture;
  String? toggleDayError;
  final List<(String, bool)> dayToggles = [];
  final List<(int, bool)> slotToggles = [];
  final List<SlotDraft> createCalls = [];
  final List<SlotDraft> updateCalls = [];
  final List<int> deleteCalls = [];
  final List<String> clearCalls = [];
  int loadCalls = 0;

  void showLoading() => emit(const WeeklyAvailabilityLoading());

  void showError(String message) => emit(WeeklyAvailabilityError(message));

  @override
  Future<void> load() async {
    loadCalls++;
    emit(fixture);
  }

  @override
  Future<void> refresh() async => emit(fixture);

  @override
  Future<String?> toggleDay(String day, {required bool isEnabled}) async {
    dayToggles.add((day, isEnabled));
    return toggleDayError;
  }

  @override
  Future<String?> toggleSlot(int slotId, {required bool isEnabled}) async {
    slotToggles.add((slotId, isEnabled));
    return null;
  }

  @override
  Future<String?> createSlot({
    required String day,
    required String startTime,
    required String endTime,
  }) async {
    createCalls.add(
      SlotDraft(day: day, startTime: startTime, endTime: endTime),
    );
    return null;
  }

  @override
  Future<String?> updateSlot({
    required int slotId,
    required String day,
    required String startTime,
    required String endTime,
  }) async {
    updateCalls.add(
      SlotDraft(day: day, startTime: startTime, endTime: endTime),
    );
    return null;
  }

  @override
  Future<String?> deleteSlot(int slotId) async {
    deleteCalls.add(slotId);
    return null;
  }

  @override
  Future<String?> clearDay(String day) async {
    clearCalls.add(day);
    return null;
  }
}

Widget _app(_FakeWeeklyAvailabilityCubit cubit) {
  return MaterialApp(
    theme: SportoTheme.darkTheme,
    home: BlocProvider<WeeklyAvailabilityCubit>.value(
      value: cubit,
      child: const ManageAvailabilityScreen(),
    ),
  );
}

Future<void> _pumpScreen(
  WidgetTester tester,
  _FakeWeeklyAvailabilityCubit cubit,
) async {
  await tester.pumpWidget(_app(cubit));
  await tester.pumpAndSettle();
}

Future<void> _openHourly(WidgetTester tester) async {
  await tester.tap(find.text('Hourly'));
  await tester.pumpAndSettle();
}

Future<void> _pumpSheet(
  WidgetTester tester,
  AddSlotSheet sheet,
) async {
  await tester.pumpWidget(
    MaterialApp(
      theme: SportoTheme.darkTheme,
      home: Builder(
        builder: (context) => Scaffold(
          backgroundColor: ManageAvailabilityPalette.canvas,
          body: Center(
            child: ElevatedButton(
              key: const ValueKey<String>('open_sheet'),
              onPressed: () => showModalBottomSheet<SlotDraft>(
                context: context,
                isScrollControlled: true,
                backgroundColor: Colors.transparent,
                barrierColor: Colors.black.withValues(alpha: .45),
                builder: (_) => sheet,
              ),
              child: const Text('Open'),
            ),
          ),
        ),
      ),
    ),
  );
  await tester.tap(find.byKey(const ValueKey<String>('open_sheet')));
  await tester.pumpAndSettle();
}

Finder _inSheet(Finder matching) {
  return find.descendant(
    of: find.byKey(const ValueKey<String>('add_slot_sheet')),
    matching: matching,
  );
}

void main() {
  group('Daily mode', () {
    testWidgets('renders all seven days with Available / Not Available',
        (tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final cubit = _FakeWeeklyAvailabilityCubit(_fixture());
      await _pumpScreen(tester, cubit);

      expect(find.text('Manage Availability'), findsOneWidget);
      for (final weekday in _weekdays) {
        expect(
          find.byKey(ValueKey<String>('availability_day_${weekday.code}')),
          findsOneWidget,
          reason: 'Missing ${weekday.label}',
        );
      }
      expect(find.text('Available'), findsNWidgets(6));
      expect(find.text('Not Available'), findsOneWidget);

      final Semantics tuesday = tester.widget<Semantics>(
        find.byKey(const ValueKey<String>('availability_day_TUESDAY')),
      );
      expect(tuesday.properties.value, 'Not Available');
      expect(tuesday.properties.toggled, isFalse);

      final Semantics back = tester.widget<Semantics>(
        find.byKey(const ValueKey<String>('manage_availability_back')),
      );
      expect(back.properties.label, 'Back');
      expect(back.properties.button, isTrue);
      expect(back.properties.onTap, isNotNull);
      final Size backSize = tester.getSize(
        find.byKey(const ValueKey<String>('manage_availability_back')),
      );
      expect(backSize.width, greaterThanOrEqualTo(44));
      expect(backSize.height, greaterThanOrEqualTo(44));

      final Semantics dailyTab = tester.widget<Semantics>(
        find.byKey(
          const ValueKey<String>('availability_tab_semantics_daily'),
        ),
      );
      expect(dailyTab.properties.selected, isTrue);
    });

    testWidgets('tapping Tuesday fires the day toggle', (tester) async {
      final cubit = _FakeWeeklyAvailabilityCubit(_fixture());
      await _pumpScreen(tester, cubit);

      await tester.tap(
        find.byKey(const ValueKey<String>('availability_day_TUESDAY')),
      );
      await tester.pump();

      expect(cubit.dayToggles, contains(('TUESDAY', true)));
    });

    testWidgets('long-pressing a configured day clears it after confirm',
        (tester) async {
      final cubit = _FakeWeeklyAvailabilityCubit(_fixture());
      await _pumpScreen(tester, cubit);

      await tester.longPress(
        find.byKey(const ValueKey<String>('availability_day_TUESDAY')),
      );
      await tester.pumpAndSettle();
      expect(find.text('Clear Tuesday?'), findsOneWidget);

      await tester.tap(find.text('Clear'));
      await tester.pumpAndSettle();

      expect(cubit.clearCalls, <String>['TUESDAY']);
    });

    testWidgets('saving disables day toggles and Add Slot', (tester) async {
      final cubit = _FakeWeeklyAvailabilityCubit(_fixture(isSaving: true));
      await _pumpScreen(tester, cubit);

      await tester.tap(
        find.byKey(const ValueKey<String>('availability_day_TUESDAY')),
      );
      await tester.pump();
      expect(cubit.dayToggles, isEmpty);

      await _openHourly(tester);
      final Semantics addSlot = tester.widget<Semantics>(
        find.byKey(const ValueKey<String>('availability_add_slot')),
      );
      expect(addSlot.properties.enabled, isFalse);
      expect(addSlot.properties.onTap, isNull);
    });

    testWidgets('shows the cubit error in a SnackBar', (tester) async {
      final cubit = _FakeWeeklyAvailabilityCubit(_fixture())
        ..toggleDayError = 'Server said no';
      await _pumpScreen(tester, cubit);

      await tester.tap(
        find.byKey(const ValueKey<String>('availability_day_TUESDAY')),
      );
      await tester.pumpAndSettle();

      expect(find.text('Server said no'), findsOneWidget);
    });
  });

  group('States', () {
    testWidgets('loading is a skeleton and error offers Retry', (tester) async {
      final cubit = _FakeWeeklyAvailabilityCubit(_fixture())..showLoading();

      await tester.pumpWidget(_app(cubit));
      await tester.pump();

      expect(find.byType(SportoShimmer), findsAtLeastNWidgets(6));

      cubit.showError('Backend is down');
      await tester.pump();

      expect(find.text('Unable to load availability'), findsOneWidget);
      expect(find.text('Backend is down'), findsOneWidget);
      expect(find.text('Retry'), findsOneWidget);

      await tester.tap(find.text('Retry'));
      await tester.pumpAndSettle();

      expect(cubit.loadCalls, 1);
      expect(
        find.byKey(const ValueKey<String>('availability_day_MONDAY')),
        findsOneWidget,
      );
    });
  });

  group('Hourly mode', () {
    testWidgets('shows chips, activity dots and the selected day slots',
        (tester) async {
      final cubit = _FakeWeeklyAvailabilityCubit(_fixture());
      await _pumpScreen(tester, cubit);
      await _openHourly(tester);

      final Semantics hourlyTab = tester.widget<Semantics>(
        find.byKey(
          const ValueKey<String>('availability_tab_semantics_hourly'),
        ),
      );
      expect(hourlyTab.properties.selected, isTrue);

      expect(find.text('Mon'), findsOneWidget);
      expect(find.text('Tue'), findsOneWidget);
      expect(find.text('Wed'), findsOneWidget);
      expect(find.text('Thu'), findsOneWidget);
      expect(find.text('Fri'), findsOneWidget);
      expect(find.text('Sat'), findsOneWidget);
      expect(find.text('Sun'), findsOneWidget);

      expect(
        find.byKey(const ValueKey<String>('availability_day_dot_TUESDAY')),
        findsOneWidget,
      );
      expect(
        find.byKey(const ValueKey<String>('availability_day_dot_THURSDAY')),
        findsOneWidget,
      );
      expect(
        find.byKey(const ValueKey<String>('availability_day_dot_MONDAY')),
        findsNothing,
      );

      final Semantics tuesdayChip = tester.widget<Semantics>(
        find.byKey(
          const ValueKey<String>('availability_chip_semantics_TUESDAY'),
        ),
      );
      expect(tuesdayChip.properties.selected, isTrue);

      // The first day with slots is Tuesday.
      expect(find.text('10:00 AM - 04:00 PM'), findsNWidgets(3));

      await tester.tap(find.text('Thu'));
      await tester.pumpAndSettle();

      final Semantics thursdayChip = tester.widget<Semantics>(
        find.byKey(
          const ValueKey<String>('availability_chip_semantics_THURSDAY'),
        ),
      );
      expect(thursdayChip.properties.selected, isTrue);
      expect(find.text('12:00 PM - 06:00 PM'), findsOneWidget);
      expect(find.text('10:00 AM - 04:00 PM'), findsNothing);
    });

    testWidgets('Empty day shows a CTA and opens the sheet on that day',
        (tester) async {
      final cubit = _FakeWeeklyAvailabilityCubit(_fixture());
      await _pumpScreen(tester, cubit);
      await _openHourly(tester);

      await tester.tap(find.text('Sun'));
      await tester.pumpAndSettle();

      expect(find.text('No slots for Sunday'), findsOneWidget);
      await tester.tap(
        find.byKey(const ValueKey<String>('availability_empty_add_slot')),
      );
      await tester.pumpAndSettle();

      expect(
          find.byKey(const ValueKey<String>('add_slot_sheet')), findsOneWidget);
      expect(_inSheet(find.text('Sunday')), findsOneWidget);
    });

    testWidgets('Add Slot opens the sheet prefilled with the selected day',
        (tester) async {
      final cubit = _FakeWeeklyAvailabilityCubit(_fixture());
      await _pumpScreen(tester, cubit);
      await _openHourly(tester);

      await tester.tap(
        find.byKey(const ValueKey<String>('availability_add_slot')),
      );
      await tester.pumpAndSettle();

      expect(
          find.byKey(const ValueKey<String>('add_slot_sheet')), findsOneWidget);
      expect(_inSheet(find.text('Add Slot')), findsOneWidget);
      expect(_inSheet(find.text('Tuesday')), findsWidgets);
    });

    testWidgets('slot switch and long-press delete are wired', (tester) async {
      final cubit = _FakeWeeklyAvailabilityCubit(_fixture());
      await _pumpScreen(tester, cubit);
      await _openHourly(tester);

      await tester.tap(
        find.byKey(const ValueKey<String>('availability_slot_switch_1')),
      );
      await tester.pump();

      expect(cubit.slotToggles, contains((1, false)));

      await tester.longPress(
        find.byKey(const ValueKey<String>('availability_slot_1')),
      );
      await tester.pumpAndSettle();
      expect(find.text('Edit slot'), findsOneWidget);
      expect(find.text('Delete slot'), findsOneWidget);

      await tester.tap(find.text('Delete slot'));
      await tester.pumpAndSettle();
      expect(find.text('Delete this slot?'), findsOneWidget);

      await tester.tap(find.text('Delete'));
      await tester.pumpAndSettle();
      expect(cubit.deleteCalls, <int>[1]);
    });

    testWidgets('long-press edit opens a prefilled Edit Slot sheet and updates',
        (tester) async {
      final cubit = _FakeWeeklyAvailabilityCubit(_fixture());
      await _pumpScreen(tester, cubit);
      await _openHourly(tester);

      await tester.longPress(
        find.byKey(const ValueKey<String>('availability_slot_1')),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('Edit slot'));
      await tester.pumpAndSettle();

      expect(_inSheet(find.text('Edit Slot')), findsOneWidget);
      expect(_inSheet(find.text('Tuesday')), findsWidgets);
      expect(_inSheet(find.text('10:00 AM')), findsOneWidget);
      expect(_inSheet(find.text('4:00 PM')), findsOneWidget);

      await tester.tap(find.byKey(const ValueKey<String>('add_slot_submit')));
      await tester.pumpAndSettle();

      expect(cubit.updateCalls, hasLength(1));
      expect(cubit.updateCalls.single.day, 'TUESDAY');
      expect(cubit.updateCalls.single.startTime, '10:00:00');
      expect(cubit.updateCalls.single.endTime, '16:00:00');
    });
  });

  group('AddSlotSheet', () {
    testWidgets('prefills the initial day and shows placeholders',
        (tester) async {
      await _pumpSheet(
        tester,
        AddSlotSheet(
          weekdays: _weekdays,
          initialDay: 'SATURDAY',
          onSubmit: (_) async => null,
        ),
      );

      expect(_inSheet(find.text('Add Slot')), findsOneWidget);
      expect(_inSheet(find.text('Saturday')), findsOneWidget);
      expect(_inSheet(find.text('Select Day')), findsOneWidget);
      expect(_inSheet(find.text('Select time')), findsNWidgets(2));

      final Semantics close = tester.widget<Semantics>(
        find.byKey(const ValueKey<String>('add_slot_close')),
      );
      expect(close.properties.label, 'Close');
      expect(close.properties.button, isTrue);
    });

    testWidgets('edit mode prefills slot day and times', (tester) async {
      await _pumpSheet(
        tester,
        AddSlotSheet(
          weekdays: _weekdays,
          initialSlot: _slots.first,
          onSubmit: (_) async => null,
        ),
      );

      expect(_inSheet(find.text('Edit Slot')), findsOneWidget);
      expect(_inSheet(find.text('Tuesday')), findsOneWidget);
      expect(_inSheet(find.text('10:00 AM')), findsOneWidget);
      expect(_inSheet(find.text('4:00 PM')), findsOneWidget);
    });

    testWidgets('submits HH:mm:ss payload after picking times', (tester) async {
      final queue = <TimeOfDay>[
        const TimeOfDay(hour: 9, minute: 0),
        const TimeOfDay(hour: 17, minute: 0),
      ];
      SlotDraft? submitted;
      await _pumpSheet(
        tester,
        AddSlotSheet(
          weekdays: _weekdays,
          initialDay: 'SATURDAY',
          timePicker: (context,
              {required initialTime, required helpText}) async {
            return queue.removeAt(0);
          },
          onSubmit: (draft) async {
            submitted = draft;
            return null;
          },
        ),
      );

      await tester.tap(
        find.byKey(const ValueKey<String>('add_slot_from_field')),
      );
      await tester.pumpAndSettle();
      await tester.tap(
        find.byKey(const ValueKey<String>('add_slot_to_field')),
      );
      await tester.pumpAndSettle();

      expect(_inSheet(find.text('9:00 AM')), findsOneWidget);
      expect(_inSheet(find.text('5:00 PM')), findsOneWidget);

      await tester.tap(find.byKey(const ValueKey<String>('add_slot_submit')));
      await tester.pumpAndSettle();

      expect(submitted, isNotNull);
      expect(submitted!.day, 'SATURDAY');
      expect(submitted!.startTime, '09:00:00');
      expect(submitted!.endTime, '17:00:00');
      expect(
          find.byKey(const ValueKey<String>('add_slot_sheet')), findsNothing);
    });

    testWidgets('rejects an end time before the start time', (tester) async {
      final queue = <TimeOfDay>[
        const TimeOfDay(hour: 10, minute: 0),
        const TimeOfDay(hour: 9, minute: 0),
      ];
      SlotDraft? submitted;
      await _pumpSheet(
        tester,
        AddSlotSheet(
          weekdays: _weekdays,
          initialDay: 'SATURDAY',
          timePicker: (context,
              {required initialTime, required helpText}) async {
            return queue.removeAt(0);
          },
          onSubmit: (draft) async {
            submitted = draft;
            return null;
          },
        ),
      );

      await tester.tap(
        find.byKey(const ValueKey<String>('add_slot_from_field')),
      );
      await tester.pumpAndSettle();
      await tester.tap(
        find.byKey(const ValueKey<String>('add_slot_to_field')),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey<String>('add_slot_submit')));
      await tester.pumpAndSettle();

      expect(
        find.text('End time must be after the start time.'),
        findsOneWidget,
      );
      expect(submitted, isNull);
      expect(
        find.byKey(const ValueKey<String>('add_slot_sheet')),
        findsOneWidget,
      );
    });

    testWidgets('shows a returned cubit error inline and stays open',
        (tester) async {
      await _pumpSheet(
        tester,
        AddSlotSheet(
          weekdays: _weekdays,
          initialSlot: _slots.first,
          onSubmit: (_) async => 'Slot overlaps another slot.',
        ),
      );

      await tester.tap(find.byKey(const ValueKey<String>('add_slot_submit')));
      await tester.pumpAndSettle();

      expect(find.text('Slot overlaps another slot.'), findsOneWidget);
      expect(
        find.byKey(const ValueKey<String>('add_slot_sheet')),
        findsOneWidget,
      );
    });
  });

  group('Responsive', () {
    for (final width in <double>[320, 390, 430]) {
      testWidgets('no overflow at ${width.toInt()} px', (tester) async {
        tester.view.physicalSize = Size(width, 800);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        final cubit = _FakeWeeklyAvailabilityCubit(_fixture());
        await _pumpScreen(tester, cubit);
        expect(tester.takeException(), isNull);

        await _openHourly(tester);
        expect(tester.takeException(), isNull);
        expect(
          find.byKey(const ValueKey<String>('availability_add_slot')),
          findsOneWidget,
        );

        await tester.tap(
          find.byKey(const ValueKey<String>('availability_add_slot')),
        );
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
        expect(
          find.byKey(const ValueKey<String>('add_slot_sheet')),
          findsOneWidget,
        );
      });
    }
  });
}
