import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:referee_data/referee_data.dart';
import 'package:ui_kit/ui_kit.dart';

import '../../application/weekly_availability_cubit.dart';
import '../widgets/manage_availability_widgets.dart';

/// Weekly recurring availability CRUD backed by
/// `/v1/referee/availability`.
///
/// This is the redesigned screen: a Daily list and an Hourly slot list share
/// one page, one header and one Add Slot sheet. Cubit/API wiring is unchanged.
class ManageAvailabilityScreen extends StatefulWidget {
  const ManageAvailabilityScreen({super.key});

  @override
  State<ManageAvailabilityScreen> createState() =>
      _ManageAvailabilityScreenState();
}

class _ManageAvailabilityScreenState extends State<ManageAvailabilityScreen> {
  ManageAvailabilityMode _mode = ManageAvailabilityMode.daily;
  String? _selectedDay;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ManageAvailabilityPalette.canvas,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              ManageAvailabilityPalette.header,
              ManageAvailabilityPalette.canvas,
            ],
            stops: [0, .22],
          ),
        ),
        child: SafeArea(
          bottom: false,
          child: BlocBuilder<WeeklyAvailabilityCubit, WeeklyAvailabilityState>(
            builder: (context, state) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 4),
                  ManageAvailabilityHeader(onBack: _goBack),
                  AvailabilityModeTabs(
                    mode: _mode,
                    onChanged: (mode) => setState(() => _mode = mode),
                  ),
                  Expanded(child: _buildBody(context, state)),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  void _goBack() {
    if (context.canPop()) context.pop();
  }

  Widget _buildBody(BuildContext context, WeeklyAvailabilityState state) {
    if (state is WeeklyAvailabilityInitial ||
        state is WeeklyAvailabilityLoading) {
      return const _AvailabilitySkeleton();
    }

    if (state is WeeklyAvailabilityError) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.only(top: 96),
        children: [
          SportoErrorView(
            headline: 'Unable to load availability',
            description: state.message,
            onRetry: () => context.read<WeeklyAvailabilityCubit>().load(),
          ),
        ],
      );
    }

    final loaded = state as WeeklyAvailabilityLoaded;
    return RefreshIndicator(
      color: ManageAvailabilityPalette.green,
      backgroundColor: ManageAvailabilityPalette.card,
      onRefresh: () => context.read<WeeklyAvailabilityCubit>().refresh(),
      child: ManageAvailabilityView(
        loaded: loaded,
        mode: _mode,
        selectedDay: _resolveSelectedDay(loaded),
        enabled: !loaded.isSaving,
        onDaySelected: (day) => setState(() => _selectedDay = day),
        onToggleDay: (day, value) => _toggleDay(context, day, value),
        onToggleSlot: (slot, value) => _toggleSlot(context, slot, value),
        onAddSlot: () {
          final day = _resolveSelectedDay(loaded);
          _openSlotSheet(context, loaded, initialDay: day);
        },
        onAddSlotForDay: (day) {
          setState(() => _selectedDay = day);
          _openSlotSheet(context, loaded, initialDay: day);
        },
        onClearDay: (day) => _clearDay(context, day),
        onLongPressSlot: (slot) =>
            _openSlotActions(context, loaded, slot: slot),
      ),
    );
  }

  List<RefereeWeekday> _weekdays(WeeklyAvailabilityLoaded loaded) {
    if (loaded.weekdays.isNotEmpty) return loaded.weekdays;
    if (loaded.days.isNotEmpty) {
      return [
        for (final day in loaded.days)
          RefereeWeekday(code: day.day, label: day.label),
      ];
    }
    return manageAvailabilityFallbackWeekdays;
  }

  String _resolveSelectedDay(WeeklyAvailabilityLoaded loaded) {
    final weekdays = _weekdays(loaded);
    final codes = weekdays.map((weekday) => weekday.code).toList();
    final current = _selectedDay;
    if (current != null && codes.contains(current)) return current;
    for (final code in codes) {
      if (loaded.slotsForDay(code).isNotEmpty) return code;
    }
    for (final code in codes) {
      final day = loaded.dayFor(code);
      if (day?.isEnabled ?? true) return code;
    }
    return codes.isNotEmpty ? codes.first : 'MONDAY';
  }

  Future<void> _toggleDay(
    BuildContext context,
    String day,
    bool value,
  ) async {
    final error = await context.read<WeeklyAvailabilityCubit>().toggleDay(
          day,
          isEnabled: value,
        );
    if (!mounted || error == null) return;
    _showSnack(context, error, isError: true);
  }

  Future<void> _toggleSlot(
    BuildContext context,
    RefereeAvailabilitySlot slot,
    bool value,
  ) async {
    final error = await context.read<WeeklyAvailabilityCubit>().toggleSlot(
          slot.id,
          isEnabled: value,
        );
    if (!mounted || error == null) return;
    _showSnack(context, error, isError: true);
  }

  Future<void> _openSlotSheet(
    BuildContext context,
    WeeklyAvailabilityLoaded loaded, {
    String? initialDay,
    RefereeAvailabilitySlot? slot,
  }) async {
    final cubit = context.read<WeeklyAvailabilityCubit>();
    final weekdays = _weekdays(loaded);
    final result = await showModalBottomSheet<SlotDraft>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withValues(alpha: .45),
      builder: (_) => AddSlotSheet(
        weekdays: weekdays,
        initialDay: initialDay ?? _resolveSelectedDay(loaded),
        initialSlot: slot,
        isSaving: loaded.isSaving,
        onSubmit: (draft) {
          if (slot == null) {
            return cubit.createSlot(
              day: draft.day,
              startTime: draft.startTime,
              endTime: draft.endTime,
            );
          }
          return cubit.updateSlot(
            slotId: slot.id,
            day: draft.day,
            startTime: draft.startTime,
            endTime: draft.endTime,
          );
        },
      ),
    );
    if (!mounted || result == null) return;
    _showSnack(
      context,
      slot == null ? 'Availability slot added.' : 'Availability slot updated.',
      isError: false,
    );
  }

  Future<void> _openSlotActions(
    BuildContext context,
    WeeklyAvailabilityLoaded loaded, {
    required RefereeAvailabilitySlot slot,
  }) async {
    final action = await showModalBottomSheet<_SlotAction>(
      context: context,
      backgroundColor: ManageAvailabilityPalette.card,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => _SlotActionsSheet(
        dayLabel: manageAvailabilityDayLabel(slot.day),
        range: manageAvailabilitySlotRange(slot),
      ),
    );
    if (!mounted || action == null) return;
    switch (action) {
      case _SlotAction.edit:
        await _openSlotSheet(context, loaded, slot: slot);
        break;
      case _SlotAction.delete:
        await _deleteSlot(context, slot);
        break;
    }
  }

  Future<void> _deleteSlot(
    BuildContext context,
    RefereeAvailabilitySlot slot,
  ) async {
    final confirmed = await _confirm(
      context,
      title: 'Delete this slot?',
      message: '${manageAvailabilityDayLabel(slot.day)} · '
          '${manageAvailabilitySlotRange(slot)} will be removed.',
      confirmLabel: 'Delete',
    );
    if (!mounted || confirmed != true) return;

    final error = await context.read<WeeklyAvailabilityCubit>().deleteSlot(
          slot.id,
        );
    if (!mounted) return;
    _showSnack(
      context,
      error ?? 'Availability slot deleted.',
      isError: error != null,
    );
  }

  Future<void> _clearDay(BuildContext context, String day) async {
    final label = manageAvailabilityDayLabel(day);
    final confirmed = await _confirm(
      context,
      title: 'Clear $label?',
      message: 'All saved slots for $label will be removed.',
      confirmLabel: 'Clear',
    );
    if (!mounted || confirmed != true) return;

    final error = await context.read<WeeklyAvailabilityCubit>().clearDay(day);
    if (!mounted) return;
    _showSnack(
      context,
      error ?? '$label availability cleared.',
      isError: error != null,
    );
  }

  Future<bool?> _confirm(
    BuildContext context, {
    required String title,
    required String message,
    required String confirmLabel,
  }) {
    return showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: ManageAvailabilityPalette.card,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
        ),
        title: Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w700,
          ),
        ),
        content: Text(
          message,
          style: const TextStyle(color: ManageAvailabilityPalette.muted),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text(
              'Cancel',
              style: TextStyle(color: ManageAvailabilityPalette.muted),
            ),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: ManageAvailabilityPalette.redDeep,
            ),
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text(confirmLabel),
          ),
        ],
      ),
    );
  }

  void _showSnack(
    BuildContext context,
    String message, {
    required bool isError,
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? const Color(0xFFB3261E) : null,
      ),
    );
  }
}

/// Pure presentation for a loaded availability state.
///
/// Public so widget tests can inject a [WeeklyAvailabilityLoaded] fixture and
/// observe every callback without touching the network or the cubit.
class ManageAvailabilityView extends StatelessWidget {
  const ManageAvailabilityView({
    super.key,
    required this.loaded,
    required this.mode,
    required this.selectedDay,
    required this.enabled,
    required this.onDaySelected,
    required this.onToggleDay,
    required this.onToggleSlot,
    required this.onAddSlot,
    required this.onAddSlotForDay,
    required this.onClearDay,
    required this.onLongPressSlot,
  });

  final WeeklyAvailabilityLoaded loaded;
  final ManageAvailabilityMode mode;
  final String selectedDay;
  final bool enabled;
  final ValueChanged<String> onDaySelected;
  final void Function(String day, bool value) onToggleDay;
  final void Function(RefereeAvailabilitySlot slot, bool value) onToggleSlot;
  final VoidCallback onAddSlot;
  final ValueChanged<String> onAddSlotForDay;
  final ValueChanged<String> onClearDay;
  final ValueChanged<RefereeAvailabilitySlot> onLongPressSlot;

  @override
  Widget build(BuildContext context) {
    final scale = context.sportoScale;
    final weekdays = _weekdays(loaded);
    final children = mode == ManageAvailabilityMode.daily
        ? _dailyChildren(weekdays, scale)
        : _hourlyChildren(weekdays, scale);

    return ListView(
      key: ValueKey<String>('availability_${mode.name}_list'),
      physics: const AlwaysScrollableScrollPhysics(
        parent: BouncingScrollPhysics(),
      ),
      padding: EdgeInsets.fromLTRB(
        20 * scale,
        10 * scale,
        20 * scale,
        32 * scale,
      ),
      children: children,
    );
  }

  List<Widget> _dailyChildren(
    List<RefereeWeekday> weekdays,
    double scale,
  ) {
    final entries = _dailyEntries(weekdays);
    return [
      for (var i = 0; i < entries.length; i++) ...[
        DailyAvailabilityRow(
          dayCode: entries[i].code,
          label: entries[i].label,
          isEnabled: entries[i].isEnabled,
          enabled: enabled,
          onToggle: (value) => onToggleDay(entries[i].code, value),
          onLongPress:
              entries[i].hasSlots ? () => onClearDay(entries[i].code) : null,
        ),
        if (i < entries.length - 1) SizedBox(height: 10 * scale),
      ],
    ];
  }

  List<Widget> _hourlyChildren(
    List<RefereeWeekday> weekdays,
    double scale,
  ) {
    final slots = loaded.slotsForDay(selectedDay);
    final dayLabel = _dayLabel(weekdays, selectedDay);
    final activity = <String>{
      for (final weekday in weekdays)
        if (_hasActivity(weekday.code)) weekday.code,
    };
    return [
      HourlyWeekdayChipRow(
        weekdays: weekdays,
        selectedDay: selectedDay,
        daysWithActivity: activity,
        enabled: enabled,
        onSelected: onDaySelected,
      ),
      SizedBox(height: 16 * scale),
      AvailabilitySectionHeader(
        onAddSlot: enabled ? onAddSlot : null,
      ),
      SizedBox(height: 10 * scale),
      if (slots.isEmpty)
        EmptySlotsCard(
          dayLabel: dayLabel,
          onAddSlot: enabled ? () => onAddSlotForDay(selectedDay) : null,
        )
      else
        for (var i = 0; i < slots.length; i++) ...[
          AvailabilitySlotCard(
            slot: slots[i],
            dayLabel: _dayLabel(weekdays, slots[i].day),
            enabled: enabled,
            onToggle: (value) => onToggleSlot(slots[i], value),
            onLongPress: enabled ? () => onLongPressSlot(slots[i]) : null,
          ),
          if (i < slots.length - 1) SizedBox(height: 10 * scale),
        ],
    ];
  }

  List<RefereeWeekday> _weekdays(WeeklyAvailabilityLoaded loaded) {
    if (loaded.weekdays.isNotEmpty) return loaded.weekdays;
    if (loaded.days.isNotEmpty) {
      return [
        for (final day in loaded.days)
          RefereeWeekday(code: day.day, label: day.label),
      ];
    }
    return manageAvailabilityFallbackWeekdays;
  }

  List<_DailyEntry> _dailyEntries(List<RefereeWeekday> weekdays) {
    if (loaded.days.isEmpty) {
      return [
        for (final weekday in weekdays)
          _DailyEntry(
            code: weekday.code,
            label: manageAvailabilityDayLabel(weekday.code, weekday.label),
            isEnabled: true,
            hasSlots: loaded.slotsForDay(weekday.code).isNotEmpty,
          ),
      ];
    }

    final byCode = <String, RefereeAvailabilityDay>{
      for (final day in loaded.days) day.day: day,
    };
    final entries = <_DailyEntry>[
      for (final weekday in weekdays)
        _DailyEntry(
          code: weekday.code,
          label: manageAvailabilityDayLabel(
            weekday.code,
            byCode[weekday.code]?.label ?? weekday.label,
          ),
          isEnabled: byCode[weekday.code]?.isEnabled ?? true,
          hasSlots: loaded.slotsForDay(weekday.code).isNotEmpty ||
              (byCode[weekday.code]?.hasConfiguredHours ?? false),
        ),
    ];
    for (final day in loaded.days) {
      if (weekdays.any((weekday) => weekday.code == day.day)) continue;
      entries.add(
        _DailyEntry(
          code: day.day,
          label: manageAvailabilityDayLabel(day.day, day.label),
          isEnabled: day.isEnabled,
          hasSlots:
              loaded.slotsForDay(day.day).isNotEmpty || day.hasConfiguredHours,
        ),
      );
    }
    return entries;
  }

  bool _hasActivity(String day) {
    final model = loaded.dayFor(day);
    return loaded.slotsForDay(day).isNotEmpty ||
        (model?.hasEnabledSlots ?? false) ||
        (model?.hasConfiguredHours ?? false);
  }

  String _dayLabel(List<RefereeWeekday> weekdays, String code) {
    for (final weekday in weekdays) {
      if (weekday.code == code) {
        return manageAvailabilityDayLabel(weekday.code, weekday.label);
      }
    }
    return manageAvailabilityDayLabel(code, loaded.dayFor(code)?.label);
  }
}

class _DailyEntry {
  const _DailyEntry({
    required this.code,
    required this.label,
    required this.isEnabled,
    required this.hasSlots,
  });

  final String code;
  final String label;
  final bool isEnabled;
  final bool hasSlots;
}

enum _SlotAction { edit, delete }

class _SlotActionsSheet extends StatelessWidget {
  const _SlotActionsSheet({
    required this.dayLabel,
    required this.range,
  });

  final String dayLabel;
  final String range;

  @override
  Widget build(BuildContext context) {
    final scale = context.sportoScale;
    return SafeArea(
      top: false,
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          20 * scale,
          16 * scale,
          20 * scale,
          20 * scale,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 42 * scale,
                height: 4 * scale,
                decoration: BoxDecoration(
                  color: const Color(0xFF3A4356),
                  borderRadius: BorderRadius.circular(2 * scale),
                ),
              ),
            ),
            SizedBox(height: 18 * scale),
            Text(
              dayLabel,
              style: TextStyle(
                fontSize: 16 * scale,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
            SizedBox(height: 2 * scale),
            Text(
              range,
              style: TextStyle(
                fontSize: 13 * scale,
                fontWeight: FontWeight.w500,
                color: ManageAvailabilityPalette.muted,
              ),
            ),
            SizedBox(height: 14 * scale),
            _SheetAction(
              icon: Icons.edit_outlined,
              label: 'Edit slot',
              scale: scale,
              onTap: () => Navigator.of(context).pop(_SlotAction.edit),
            ),
            _SheetAction(
              icon: Icons.delete_outline_rounded,
              label: 'Delete slot',
              scale: scale,
              destructive: true,
              onTap: () => Navigator.of(context).pop(_SlotAction.delete),
            ),
          ],
        ),
      ),
    );
  }
}

class _SheetAction extends StatelessWidget {
  const _SheetAction({
    required this.icon,
    required this.label,
    required this.scale,
    required this.onTap,
    this.destructive = false,
  });

  final IconData icon;
  final String label;
  final double scale;
  final VoidCallback onTap;
  final bool destructive;

  @override
  Widget build(BuildContext context) {
    final color = destructive
        ? ManageAvailabilityPalette.red
        : ManageAvailabilityPalette.greenLight;
    return Semantics(
      button: true,
      label: label,
      onTap: onTap,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12 * scale),
          onTap: onTap,
          child: SizedBox(
            height: 52,
            child: Row(
              children: [
                Icon(icon, size: 20 * scale, color: color),
                SizedBox(width: 12 * scale),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 15 * scale,
                    fontWeight: FontWeight.w600,
                    color: color,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _AvailabilitySkeleton extends StatelessWidget {
  const _AvailabilitySkeleton();

  @override
  Widget build(BuildContext context) {
    final scale = context.sportoScale;
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: EdgeInsets.fromLTRB(
        20 * scale,
        10 * scale,
        20 * scale,
        28 * scale,
      ),
      children: [
        for (var i = 0; i < 7; i++) ...[
          SportoShimmer(
            height: 59 * scale,
            borderRadius: 14 * scale,
          ),
          if (i < 6) SizedBox(height: 10 * scale),
        ],
      ],
    );
  }
}
