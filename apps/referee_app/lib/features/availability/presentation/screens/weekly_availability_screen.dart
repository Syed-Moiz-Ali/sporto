import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:referee_data/referee_data.dart';
import 'package:ui_kit/ui_kit.dart';

import '../../application/weekly_availability_cubit.dart';

/// Weekly recurring availability CRUD backed by
/// `/v1/referee/availability`.
class WeeklyAvailabilityScreen extends StatelessWidget {
  const WeeklyAvailabilityScreen({super.key});

  static const _dayShortLabels = <String, String>{
    'MONDAY': 'Mon',
    'TUESDAY': 'Tue',
    'WEDNESDAY': 'Wed',
    'THURSDAY': 'Thu',
    'FRIDAY': 'Fri',
    'SATURDAY': 'Sat',
    'SUNDAY': 'Sun',
  };

  @override
  Widget build(BuildContext context) {
    final scale = context.sportoScale;

    return SportoScreenShell(
      body: SafeArea(
        bottom: false,
        child: BlocBuilder<WeeklyAvailabilityCubit, WeeklyAvailabilityState>(
          builder: (context, state) {
            final timezone = state is WeeklyAvailabilityLoaded
                ? state.timezone
                : 'Asia/Kolkata';
            final isSaving =
                state is WeeklyAvailabilityLoaded && state.isSaving;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _Header(
                  scale: scale,
                  timezone: timezone,
                  isSaving: isSaving,
                  onAdd: () => _openEditor(context),
                ),
                Expanded(child: _buildBody(context, state, scale)),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildBody(
    BuildContext context,
    WeeklyAvailabilityState state,
    double scale,
  ) {
    if (state is WeeklyAvailabilityInitial ||
        state is WeeklyAvailabilityLoading) {
      return _SkeletonList(scale: scale);
    }

    if (state is WeeklyAvailabilityError) {
      return SportoErrorView(
        headline: 'Unable to load availability',
        description: state.message,
        onRetry: () => context.read<WeeklyAvailabilityCubit>().load(),
      );
    }

    final loaded = state as WeeklyAvailabilityLoaded;
    return RefreshIndicator(
      color: const Color(0xFFED7B00),
      backgroundColor: const Color(0xFF1B2335),
      onRefresh: () => context.read<WeeklyAvailabilityCubit>().refresh(),
      child: loaded.isEmpty
          ? _EmptyAvailability(scale: scale, onAdd: () => _openEditor(context))
          : _AvailabilityList(
              scale: scale,
              loaded: loaded,
              onEdit: (slot) => _openEditor(context, slot: slot),
              onDelete: (slot) => _deleteSlot(context, slot),
              onClearDay: (day) => _clearDay(context, day),
            ),
    );
  }

  Future<void> _openEditor(
    BuildContext context, {
    RefereeAvailabilitySlot? slot,
  }) async {
    final state = context.read<WeeklyAvailabilityCubit>().state;
    if (state is! WeeklyAvailabilityLoaded) return;

    final draft = await showModalBottomSheet<_SlotDraft>(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF151B24),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => _SlotEditorSheet(
        weekdays: state.weekdays,
        timezone: state.timezone,
        initial: slot,
        shortLabels: _dayShortLabels,
      ),
    );
    if (draft == null || !context.mounted) return;

    final cubit = context.read<WeeklyAvailabilityCubit>();
    final error = slot == null
        ? await cubit.createSlot(
            day: draft.day,
            startTime: draft.startTime,
            endTime: draft.endTime,
          )
        : await cubit.updateSlot(
            slotId: slot.id,
            day: draft.day,
            startTime: draft.startTime,
            endTime: draft.endTime,
          );
    if (!context.mounted) return;

    _showSnack(
      context,
      error ??
          (slot == null
              ? 'Availability slot added.'
              : 'Availability slot updated.'),
      isError: error != null,
    );
  }

  Future<void> _deleteSlot(
    BuildContext context,
    RefereeAvailabilitySlot slot,
  ) async {
    final confirmed = await _confirm(
      context,
      title: 'Delete this slot?',
      message: '${_dayLabel(slot.day)} · ${_displayApiTime(slot.startTime)} – '
          '${_displayApiTime(slot.endTime)} will be removed.',
      confirmLabel: 'Delete',
    );
    if (confirmed != true || !context.mounted) return;

    final error = await context.read<WeeklyAvailabilityCubit>().deleteSlot(
          slot.id,
        );
    if (!context.mounted) return;
    _showSnack(
      context,
      error ?? 'Availability slot deleted.',
      isError: error != null,
    );
  }

  Future<void> _clearDay(BuildContext context, String day) async {
    final confirmed = await _confirm(
      context,
      title: 'Clear $_dayLabel?',
      message: 'All saved slots for $_dayLabel will be removed.',
      confirmLabel: 'Clear',
    );
    if (confirmed != true || !context.mounted) return;

    final error = await context.read<WeeklyAvailabilityCubit>().clearDay(day);
    if (!context.mounted) return;
    _showSnack(
      context,
      error ?? '$day availability cleared.',
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
        backgroundColor: const Color(0xFF1B2335),
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
          style: const TextStyle(color: Color(0xFFA0A0A0)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text(
              'Cancel',
              style: TextStyle(color: Color(0xFFA0A0A0)),
            ),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFFDE3F00),
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

// ============================================================================
// HEADER
// ============================================================================

class _Header extends StatelessWidget {
  final double scale;
  final String timezone;
  final bool isSaving;
  final VoidCallback onAdd;

  const _Header({
    required this.scale,
    required this.timezone,
    required this.isSaving,
    required this.onAdd,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        20 * scale,
        12 * scale,
        20 * scale,
        16 * scale,
      ),
      child: Row(
        children: [
          Material(
            color: const Color(0xFF252C3B),
            borderRadius: BorderRadius.circular(10 * scale),
            child: InkWell(
              onTap: () {
                if (context.canPop()) context.pop();
              },
              borderRadius: BorderRadius.circular(10 * scale),
              child: SizedBox(
                width: 36 * scale,
                height: 36 * scale,
                child: Icon(
                  Icons.arrow_back_ios_new_rounded,
                  size: 16 * scale,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          SizedBox(width: 12 * scale),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Weekly Availability',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 18 * scale,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                    height: 1.15,
                  ),
                ),
                SizedBox(height: 3 * scale),
                Text(
                  'Recurring hours · $timezone',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 12 * scale,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFFA0A0A0),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: 10 * scale),
          _AddSlotButton(
            scale: scale,
            enabled: !isSaving,
            onTap: onAdd,
          ),
        ],
      ),
    );
  }
}

class _AddSlotButton extends StatelessWidget {
  final double scale;
  final bool enabled;
  final VoidCallback onTap;

  const _AddSlotButton({
    required this.scale,
    required this.enabled,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: enabled ? 1 : 0.5,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: enabled ? onTap : null,
          borderRadius: BorderRadius.circular(12 * scale),
          child: Ink(
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFDE3F00), Color(0xFFF65800)],
              ),
              borderRadius: BorderRadius.circular(12 * scale),
            ),
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: 12 * scale,
                vertical: 10 * scale,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.add_rounded,
                    size: 16 * scale,
                    color: Colors.white,
                  ),
                  SizedBox(width: 4 * scale),
                  Text(
                    'Add slot',
                    style: TextStyle(
                      fontSize: 12 * scale,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ============================================================================
// LOADING / EMPTY
// ============================================================================

class _SkeletonList extends StatelessWidget {
  final double scale;

  const _SkeletonList({required this.scale});

  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: EdgeInsets.fromLTRB(
        20 * scale,
        4 * scale,
        20 * scale,
        28 * scale,
      ),
      children: [
        SportoShimmer(height: 74 * scale, borderRadius: 16 * scale),
        SizedBox(height: 14 * scale),
        for (var i = 0; i < 3; i++) ...[
          SportoShimmer(height: 92 * scale, borderRadius: 16 * scale),
          SizedBox(height: 12 * scale),
        ],
      ],
    );
  }
}

class _EmptyAvailability extends StatelessWidget {
  final double scale;
  final VoidCallback onAdd;

  const _EmptyAvailability({
    required this.scale,
    required this.onAdd,
  });

  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(
        parent: BouncingScrollPhysics(),
      ),
      padding: EdgeInsets.fromLTRB(
        20 * scale,
        24 * scale,
        20 * scale,
        28 * scale,
      ),
      children: [
        SizedBox(height: 24 * scale),
        SportoEmptyView(
          icon: Icons.schedule_rounded,
          headline: 'No weekly availability',
          description:
              'Add your recurring working hours so partners can assign you '
              'matches on the right days.',
          action: 'Add your first slot',
          onAction: onAdd,
        ),
      ],
    );
  }
}

// ============================================================================
// DATA
// ============================================================================

class _AvailabilityList extends StatelessWidget {
  final double scale;
  final WeeklyAvailabilityLoaded loaded;
  final ValueChanged<RefereeAvailabilitySlot> onEdit;
  final ValueChanged<RefereeAvailabilitySlot> onDelete;
  final ValueChanged<String> onClearDay;

  const _AvailabilityList({
    required this.scale,
    required this.loaded,
    required this.onEdit,
    required this.onDelete,
    required this.onClearDay,
  });

  @override
  Widget build(BuildContext context) {
    final groups = <String, List<RefereeAvailabilitySlot>>{};
    for (final slot in loaded.slots) {
      groups.putIfAbsent(slot.day, () => []).add(slot);
    }

    final orderedCodes = [
      ...loaded.weekdays.map((weekday) => weekday.code),
      ...groups.keys.where(
        (day) => !loaded.weekdays.any((weekday) => weekday.code == day),
      ),
    ];

    return ListView(
      physics: const AlwaysScrollableScrollPhysics(
        parent: BouncingScrollPhysics(),
      ),
      padding: EdgeInsets.fromLTRB(
        20 * scale,
        4 * scale,
        20 * scale,
        28 * scale,
      ),
      children: [
        _SummaryCard(scale: scale, loaded: loaded),
        SizedBox(height: 16 * scale),
        for (final day in orderedCodes)
          if (groups[day] != null) ...[
            _DayGroup(
              scale: scale,
              day: day,
              slots: groups[day]!,
              onEdit: onEdit,
              onDelete: onDelete,
              onClearDay: onClearDay,
            ),
            SizedBox(height: 14 * scale),
          ],
      ],
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final double scale;
  final WeeklyAvailabilityLoaded loaded;

  const _SummaryCard({required this.scale, required this.loaded});

  @override
  Widget build(BuildContext context) {
    final dayCount = loaded.daysWithSlots.length;
    return Container(
      padding: EdgeInsets.all(14 * scale),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16 * scale),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF7AD3FF).withValues(alpha: 0.12),
            const Color(0xFF4FBAF0).withValues(alpha: 0.04),
          ],
        ),
        border: Border.all(
          color: const Color(0xFF7AD3FF).withValues(alpha: 0.30),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 38 * scale,
            height: 38 * scale,
            decoration: BoxDecoration(
              color: const Color(0xFF7AD3FF).withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(12 * scale),
            ),
            child: Icon(
              Icons.calendar_month_rounded,
              size: 20 * scale,
              color: const Color(0xFF7AD3FF),
            ),
          ),
          SizedBox(width: 12 * scale),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${loaded.slots.length} '
                  '${loaded.slots.length == 1 ? 'slot' : 'slots'} · '
                  '$dayCount ${dayCount == 1 ? 'day' : 'days'}',
                  style: TextStyle(
                    fontSize: 14 * scale,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 2 * scale),
                Text(
                  'Recurring weekly working hours',
                  style: TextStyle(
                    fontSize: 12 * scale,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFFA0A0A0),
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: 8 * scale,
              vertical: 4 * scale,
            ),
            decoration: BoxDecoration(
              color: const Color(0x661B2335),
              borderRadius: BorderRadius.circular(8 * scale),
            ),
            child: Text(
              loaded.timezone,
              style: TextStyle(
                fontSize: 10 * scale,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF7AD3FF),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DayGroup extends StatelessWidget {
  final double scale;
  final String day;
  final List<RefereeAvailabilitySlot> slots;
  final ValueChanged<RefereeAvailabilitySlot> onEdit;
  final ValueChanged<RefereeAvailabilitySlot> onDelete;
  final ValueChanged<String> onClearDay;

  const _DayGroup({
    required this.scale,
    required this.day,
    required this.slots,
    required this.onEdit,
    required this.onDelete,
    required this.onClearDay,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1B2335).withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(16 * scale),
        border: Border.all(
          color: const Color(0xFF7BD0FA).withValues(alpha: 0.18),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(
              14 * scale,
              12 * scale,
              8 * scale,
              8 * scale,
            ),
            child: Row(
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Text(
                        _dayLabel(day),
                        style: TextStyle(
                          fontSize: 14 * scale,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(width: 8 * scale),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 7 * scale,
                          vertical: 2 * scale,
                        ),
                        decoration: BoxDecoration(
                          color:
                              const Color(0xFF2BB673).withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(8 * scale),
                        ),
                        child: Text(
                          '${slots.length} '
                          '${slots.length == 1 ? 'slot' : 'slots'}',
                          style: TextStyle(
                            fontSize: 10 * scale,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF2BB673),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  tooltip: 'Clear $day',
                  onPressed: () => onClearDay(day),
                  icon: Icon(
                    Icons.delete_sweep_outlined,
                    size: 18 * scale,
                    color: const Color(0xFFA0A0A0),
                  ),
                ),
              ],
            ),
          ),
          Divider(
            height: 1,
            thickness: 0.8,
            color: const Color(0xFF283040).withValues(alpha: 0.8),
          ),
          for (var i = 0; i < slots.length; i++) ...[
            _SlotRow(
              scale: scale,
              slot: slots[i],
              onEdit: () => onEdit(slots[i]),
              onDelete: () => onDelete(slots[i]),
            ),
            if (i < slots.length - 1)
              Divider(
                height: 1,
                thickness: 0.8,
                indent: 14 * scale,
                endIndent: 14 * scale,
                color: const Color(0xFF283040).withValues(alpha: 0.6),
              ),
          ],
        ],
      ),
    );
  }
}

class _SlotRow extends StatelessWidget {
  final double scale;
  final RefereeAvailabilitySlot slot;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _SlotRow({
    required this.scale,
    required this.slot,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        14 * scale,
        10 * scale,
        8 * scale,
        10 * scale,
      ),
      child: Row(
        children: [
          Icon(
            Icons.access_time_rounded,
            size: 18 * scale,
            color: const Color(0xFF7AD3FF),
          ),
          SizedBox(width: 10 * scale),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${_displayApiTime(slot.startTime)} – '
                  '${_displayApiTime(slot.endTime)}',
                  style: TextStyle(
                    fontSize: 14 * scale,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 2 * scale),
                Text(
                  slot.timezone,
                  style: TextStyle(
                    fontSize: 11 * scale,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFFA0A0A0),
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            tooltip: 'Edit slot',
            onPressed: onEdit,
            icon: Icon(
              Icons.edit_outlined,
              size: 18 * scale,
              color: const Color(0xFFA0A0A0),
            ),
          ),
          IconButton(
            tooltip: 'Delete slot',
            onPressed: onDelete,
            icon: Icon(
              Icons.delete_outline_rounded,
              size: 18 * scale,
              color: const Color(0xFFFE464B),
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// EDITOR SHEET
// ============================================================================

class _SlotDraft {
  const _SlotDraft({
    required this.day,
    required this.startTime,
    required this.endTime,
  });

  final String day;
  final String startTime;
  final String endTime;
}

class _SlotEditorSheet extends StatefulWidget {
  final List<RefereeWeekday> weekdays;
  final String timezone;
  final RefereeAvailabilitySlot? initial;
  final Map<String, String> shortLabels;

  const _SlotEditorSheet({
    required this.weekdays,
    required this.timezone,
    required this.initial,
    required this.shortLabels,
  });

  @override
  State<_SlotEditorSheet> createState() => _SlotEditorSheetState();
}

class _SlotEditorSheetState extends State<_SlotEditorSheet> {
  static const _fallbackDays = <String, String>{
    'MONDAY': 'Mon',
    'TUESDAY': 'Tue',
    'WEDNESDAY': 'Wed',
    'THURSDAY': 'Thu',
    'FRIDAY': 'Fri',
    'SATURDAY': 'Sat',
    'SUNDAY': 'Sun',
  };

  late String _day;
  late TimeOfDay _start;
  late TimeOfDay _end;
  String? _error;

  List<RefereeWeekday> get _weekdays => widget.weekdays.isNotEmpty
      ? widget.weekdays
      : _fallbackDays.entries
          .map((entry) => RefereeWeekday(
                code: entry.key,
                label: entry.value,
              ))
          .toList();

  @override
  void initState() {
    super.initState();
    final initial = widget.initial;
    _day = initial?.day ?? _weekdays.first.code;
    _start = _parseApiTime(initial?.startTime) ??
        const TimeOfDay(hour: 9, minute: 0);
    _end =
        _parseApiTime(initial?.endTime) ?? const TimeOfDay(hour: 17, minute: 0);
  }

  @override
  Widget build(BuildContext context) {
    final scale = context.sportoScale;
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;

    return Padding(
      padding: EdgeInsets.only(bottom: bottomInset),
      child: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.fromLTRB(
            20 * scale,
            10 * scale,
            20 * scale,
            24 * scale,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
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
              Row(
                children: [
                  Expanded(
                    child: Text(
                      widget.initial == null
                          ? 'Add availability slot'
                          : 'Edit availability slot',
                      style: TextStyle(
                        fontSize: 17 * scale,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 8 * scale,
                      vertical: 4 * scale,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0x661B2335),
                      borderRadius: BorderRadius.circular(8 * scale),
                    ),
                    child: Text(
                      widget.timezone,
                      style: TextStyle(
                        fontSize: 10 * scale,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF7AD3FF),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20 * scale),
              Text(
                'Day',
                style: TextStyle(
                  fontSize: 12 * scale,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFFA0A0A0),
                ),
              ),
              SizedBox(height: 10 * scale),
              Wrap(
                spacing: 8 * scale,
                runSpacing: 8 * scale,
                children: [
                  for (final weekday in _weekdays)
                    _DayChip(
                      scale: scale,
                      label: widget.shortLabels[weekday.code] ?? weekday.label,
                      selected: _day == weekday.code,
                      onTap: () => setState(() {
                        _day = weekday.code;
                        _error = null;
                      }),
                    ),
                ],
              ),
              SizedBox(height: 20 * scale),
              Row(
                children: [
                  Expanded(
                    child: _TimeField(
                      scale: scale,
                      label: 'Start time',
                      value: _start,
                      onTap: () => _pickTime(isStart: true),
                    ),
                  ),
                  SizedBox(width: 12 * scale),
                  Expanded(
                    child: _TimeField(
                      scale: scale,
                      label: 'End time',
                      value: _end,
                      onTap: () => _pickTime(isStart: false),
                    ),
                  ),
                ],
              ),
              if (_error != null) ...[
                SizedBox(height: 10 * scale),
                Text(
                  _error!,
                  style: TextStyle(
                    fontSize: 12 * scale,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFFFE464B),
                  ),
                ),
              ],
              SizedBox(height: 22 * scale),
              SizedBox(
                width: double.infinity,
                height: 48 * scale,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFFDE3F00), Color(0xFFF65800)],
                    ),
                    borderRadius: BorderRadius.circular(14 * scale),
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: _save,
                      borderRadius: BorderRadius.circular(14 * scale),
                      child: Center(
                        child: Text(
                          widget.initial == null ? 'Add slot' : 'Save changes',
                          style: TextStyle(
                            fontSize: 14 * scale,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _pickTime({required bool isStart}) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: isStart ? _start : _end,
      helpText: isStart ? 'Select start time' : 'Select end time',
    );
    if (picked == null) return;
    setState(() {
      if (isStart) {
        _start = picked;
      } else {
        _end = picked;
      }
      _error = null;
    });
  }

  void _save() {
    final startMinutes = _start.hour * 60 + _start.minute;
    final endMinutes = _end.hour * 60 + _end.minute;
    if (endMinutes <= startMinutes) {
      setState(() => _error = 'End time must be after the start time.');
      return;
    }

    Navigator.of(context).pop(
      _SlotDraft(
        day: _day,
        startTime: _formatApiTime(_start),
        endTime: _formatApiTime(_end),
      ),
    );
  }
}

class _DayChip extends StatelessWidget {
  final double scale;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _DayChip({
    required this.scale,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: EdgeInsets.symmetric(
          horizontal: 14 * scale,
          vertical: 9 * scale,
        ),
        decoration: BoxDecoration(
          color: selected
              ? const Color(0xFF7AD3FF).withValues(alpha: 0.16)
              : const Color(0xFF1B2335),
          borderRadius: BorderRadius.circular(10 * scale),
          border: Border.all(
            color: selected ? const Color(0xFF7AD3FF) : const Color(0xFF283040),
            width: 1,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12 * scale,
            fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
            color: selected ? const Color(0xFF7AD3FF) : const Color(0xFFA0A0A0),
          ),
        ),
      ),
    );
  }
}

class _TimeField extends StatelessWidget {
  final double scale;
  final String label;
  final TimeOfDay value;
  final VoidCallback onTap;

  const _TimeField({
    required this.scale,
    required this.label,
    required this.value,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12 * scale,
            fontWeight: FontWeight.w600,
            color: const Color(0xFFA0A0A0),
          ),
        ),
        SizedBox(height: 8 * scale),
        Material(
          color: const Color(0xFF1B2335),
          borderRadius: BorderRadius.circular(12 * scale),
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(12 * scale),
            child: Container(
              height: 48 * scale,
              padding: EdgeInsets.symmetric(horizontal: 12 * scale),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12 * scale),
                border: Border.all(color: const Color(0xFF283040)),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.access_time_rounded,
                    size: 18 * scale,
                    color: const Color(0xFF7AD3FF),
                  ),
                  SizedBox(width: 8 * scale),
                  Expanded(
                    child: Text(
                      _displayTime(value),
                      style: TextStyle(
                        fontSize: 14 * scale,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ============================================================================
// FORMAT HELPERS
// ============================================================================

String _dayLabel(String code) {
  if (code.isEmpty) return '—';
  final lower = code.substring(1).toLowerCase();
  return '${code[0]}${lower}';
}

String _formatApiTime(TimeOfDay time) {
  return '${time.hour.toString().padLeft(2, '0')}:'
      '${time.minute.toString().padLeft(2, '0')}';
}

TimeOfDay? _parseApiTime(String? value) {
  if (value == null) return null;
  final parts = value.split(':');
  if (parts.length < 2) return null;
  final hour = int.tryParse(parts[0]);
  final minute = int.tryParse(parts[1]);
  if (hour == null || minute == null) return null;
  return TimeOfDay(hour: hour, minute: minute);
}

String _displayApiTime(String value) {
  final time = _parseApiTime(value);
  return time == null ? value : _displayTime(time);
}

String _displayTime(TimeOfDay time) {
  final hour = time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod;
  final minute = time.minute.toString().padLeft(2, '0');
  final suffix = time.period == DayPeriod.am ? 'AM' : 'PM';
  return '$hour:$minute $suffix';
}
