import 'dart:math' as math;
import 'dart:ui' show ImageFilter;

import 'package:flutter/material.dart';
import 'package:referee_data/referee_data.dart';
import 'package:ui_kit/ui_kit.dart';

/// Which availability editor the screen is showing.
enum ManageAvailabilityMode { daily, hourly }

/// Measured tokens from `redesign/manage_availability/tokens/tokens.json`.
///
/// Kept local to the feature so wallet/bank/home colours are untouched.
abstract final class ManageAvailabilityPalette {
  static const canvas = Color(0xFF090C10);
  static const header = Color(0xFF0A0E12);
  static const card = Color(0xFF1C2026);
  static const field = Color(0xFF17191E);
  static const muted = Color(0xFFA0A0A0);
  static const subtle = Color(0xFF666666);
  static const darkText = Color(0xFF0E0C08);
  static const green = Color(0xFF2BB673);
  static const greenLight = Color(0xFF99FFA3);
  static const greenBright = Color(0xFF68EE76);
  static const red = Color(0xFFFE595C);
  static const redLight = Color(0xFFFE6C6C);
  static const redDeep = Color(0xFFFE464B);
  static const gold = Color(0xFFF4B41A);
  static const goldLight = Color(0xFFFFD572);
  static const goldDeep = Color(0xFFFEBD38);
  static const sky = Color(0xFF4FBAF0);
  static const skyLight = Color(0xFF7AD3FF);
  static const fieldBorder = Color(0x1AFFFFFF);
  static const hairline = Color(0x14FFFFFF);
  static const offTrack = Color(0x33FFFFFF);
  static const knobOff = Color(0xFFE3E5E5);

  static const greenGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [greenLight, green],
  );

  static const goldGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [goldLight, goldDeep],
  );

  static const skyGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [skyLight, sky],
  );

  static const availableDotGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [greenLight, greenBright],
  );

  static const unavailableDotGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [redLight, redDeep],
  );
}

/// Full labels used when the API cannot provide a weekday catalogue.
const manageAvailabilityFallbackWeekdays = <RefereeWeekday>[
  RefereeWeekday(code: 'MONDAY', label: 'Monday'),
  RefereeWeekday(code: 'TUESDAY', label: 'Tuesday'),
  RefereeWeekday(code: 'WEDNESDAY', label: 'Wednesday'),
  RefereeWeekday(code: 'THURSDAY', label: 'Thursday'),
  RefereeWeekday(code: 'FRIDAY', label: 'Friday'),
  RefereeWeekday(code: 'SATURDAY', label: 'Saturday'),
  RefereeWeekday(code: 'SUNDAY', label: 'Sunday'),
];

/// Short labels used by the hourly chip row in Figma.
const manageAvailabilityShortDays = <String, String>{
  'MONDAY': 'Mon',
  'TUESDAY': 'Tue',
  'WEDNESDAY': 'Wed',
  'THURSDAY': 'Thu',
  'FRIDAY': 'Fri',
  'SATURDAY': 'Sat',
  'SUNDAY': 'Sun',
};

/// Returns the full weekday label for [code], preferring the API [label].
String manageAvailabilityDayLabel(String code, [String? label]) {
  if (label != null && label.trim().isNotEmpty) return label;
  for (final weekday in manageAvailabilityFallbackWeekdays) {
    if (weekday.code == code) return weekday.label;
  }
  if (code.isEmpty) return '—';
  return '${code[0]}${code.substring(1).toLowerCase()}';
}

/// Returns "Mon" style labels for [code].
String manageAvailabilityShortLabel(String code) {
  final short = manageAvailabilityShortDays[code];
  if (short != null) return short;
  final full = manageAvailabilityDayLabel(code);
  return full.length <= 3 ? full : full.substring(0, 3);
}

/// API times are `HH:mm` or `HH:mm:ss`.
TimeOfDay? manageAvailabilityParseTime(String? value) {
  if (value == null) return null;
  final parts = value.split(':');
  if (parts.length < 2) return null;
  final hour = int.tryParse(parts[0]);
  final minute = int.tryParse(parts[1]);
  if (hour == null || minute == null) return null;
  if (hour < 0 || hour > 23 || minute < 0 || minute > 59) return null;
  return TimeOfDay(hour: hour, minute: minute);
}

/// Serialises a picked time for the live availability API (`HH:mm:ss`).
String manageAvailabilityFormatApiTime(TimeOfDay time) {
  return '${time.hour.toString().padLeft(2, '0')}:'
      '${time.minute.toString().padLeft(2, '0')}:00';
}

String manageAvailabilityDisplayTime(
  TimeOfDay time, {
  bool padHour = false,
}) {
  final hourValue = time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod;
  final hour =
      padHour ? hourValue.toString().padLeft(2, '0') : hourValue.toString();
  final minute = time.minute.toString().padLeft(2, '0');
  final suffix = time.period == DayPeriod.am ? 'AM' : 'PM';
  return '$hour:$minute $suffix';
}

String manageAvailabilityDisplayApiTime(
  String value, {
  bool padHour = false,
}) {
  final time = manageAvailabilityParseTime(value);
  return time == null
      ? value
      : manageAvailabilityDisplayTime(time, padHour: padHour);
}

String manageAvailabilitySlotRange(RefereeAvailabilitySlot slot) {
  final start = manageAvailabilityDisplayApiTime(
    slot.startTime,
    padHour: true,
  );
  final end = manageAvailabilityDisplayApiTime(slot.endTime, padHour: true);
  return '$start - $end';
}

/// Header used on every state (loading, error, data).
class ManageAvailabilityHeader extends StatelessWidget {
  const ManageAvailabilityHeader({
    super.key,
    required this.onBack,
    this.title = 'Manage Availability',
  });

  final VoidCallback? onBack;
  final String title;

  @override
  Widget build(BuildContext context) {
    final scale = context.sportoScale;
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20 * scale),
      child: SizedBox(
        height: 44,
        child: Row(
          children: [
            Semantics(
              key: const ValueKey<String>('manage_availability_back'),
              label: 'Back',
              button: true,
              onTap: onBack,
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: onBack,
                child: SizedBox(
                  width: 44,
                  height: 44,
                  child: Center(
                    child: Container(
                      width: 36 * scale,
                      height: 36 * scale,
                      decoration: BoxDecoration(
                        color: const Color(0x1AFFFFFF),
                        borderRadius: BorderRadius.circular(10 * scale),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x1F000000),
                            offset: Offset(0, 2),
                            blurRadius: 4,
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.chevron_left_rounded,
                        size: 22 * scale,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(width: 10 * scale),
            Expanded(
              child: Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 18 * scale,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                  height: 1.15,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Daily / Hourly pills. The selected pill always reflects [mode].
class AvailabilityModeTabs extends StatelessWidget {
  const AvailabilityModeTabs({
    super.key,
    required this.mode,
    required this.onChanged,
    this.enabled = true,
  });

  final ManageAvailabilityMode mode;
  final ValueChanged<ManageAvailabilityMode> onChanged;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final scale = context.sportoScale;
    return SizedBox(
      height: 52 * scale,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _ModePill(
            key: const ValueKey<String>('availability_tab_daily'),
            label: 'Daily',
            selected: mode == ManageAvailabilityMode.daily,
            scale: scale,
            enabled: enabled,
            onTap: () => onChanged(ManageAvailabilityMode.daily),
          ),
          SizedBox(width: 10 * scale),
          _ModePill(
            key: const ValueKey<String>('availability_tab_hourly'),
            label: 'Hourly',
            selected: mode == ManageAvailabilityMode.hourly,
            scale: scale,
            enabled: enabled,
            onTap: () => onChanged(ManageAvailabilityMode.hourly),
          ),
        ],
      ),
    );
  }
}

class _ModePill extends StatelessWidget {
  const _ModePill({
    super.key,
    required this.label,
    required this.selected,
    required this.scale,
    required this.enabled,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final double scale;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: enabled ? onTap : null,
      child: Semantics(
        key: ValueKey<String>(
          'availability_tab_semantics_${label.toLowerCase()}',
        ),
        label: label,
        button: true,
        selected: selected,
        enabled: enabled,
        onTap: enabled ? onTap : null,
        child: SizedBox(
          height: 44,
          child: Center(
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              curve: Curves.easeOut,
              height: 32 * scale,
              padding: EdgeInsets.symmetric(horizontal: 20 * scale),
              decoration: BoxDecoration(
                color: selected ? null : ManageAvailabilityPalette.card,
                gradient:
                    selected ? ManageAvailabilityPalette.greenGradient : null,
                borderRadius: BorderRadius.circular(50),
              ),
              child: Center(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 14 * scale,
                    fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                    color: selected
                        ? ManageAvailabilityPalette.darkText
                        : ManageAvailabilityPalette.muted,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// 40 × 20 Figma switch with a 44 × 44 tap target.
class AvailabilityToggle extends StatelessWidget {
  const AvailabilityToggle({
    super.key,
    required this.value,
    required this.onChanged,
    required this.semanticLabel,
  });

  final bool value;
  final ValueChanged<bool>? onChanged;
  final String semanticLabel;

  @override
  Widget build(BuildContext context) {
    final scale = context.sportoScale;
    final enabled = onChanged != null;
    return Semantics(
      label: semanticLabel,
      toggled: value,
      button: true,
      enabled: enabled,
      onTap: enabled ? () => onChanged!(!value) : null,
      child: SizedBox(
        width: 44,
        height: 44,
        child: Center(
          child: Opacity(
            opacity: enabled ? 1 : .55,
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: enabled ? () => onChanged!(!value) : null,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 160),
                curve: Curves.easeOut,
                width: 40 * scale,
                height: 22 * scale,
                padding: EdgeInsets.all(2 * scale),
                decoration: BoxDecoration(
                  color: value
                      ? ManageAvailabilityPalette.green
                      : ManageAvailabilityPalette.offTrack,
                  borderRadius: BorderRadius.circular(50),
                ),
                child: AnimatedAlign(
                  duration: const Duration(milliseconds: 160),
                  curve: Curves.easeOut,
                  alignment:
                      value ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    width: 18 * scale,
                    height: 18 * scale,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Color(0x33000000),
                          offset: Offset(0, 1),
                          blurRadius: 2,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Status dot used by daily rows: green gradient or red gradient.
class AvailabilityStatusDot extends StatelessWidget {
  const AvailabilityStatusDot({
    super.key,
    required this.available,
  });

  final bool available;

  @override
  Widget build(BuildContext context) {
    final scale = context.sportoScale;
    return Container(
      width: 8 * scale,
      height: 8 * scale,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: available
            ? ManageAvailabilityPalette.availableDotGradient
            : ManageAvailabilityPalette.unavailableDotGradient,
        boxShadow: [
          BoxShadow(
            color:
                available ? const Color(0x4C7FF68B) : const Color(0x4CFE595B),
            offset: const Offset(0, 2),
            blurRadius: 6,
          ),
        ],
      ),
    );
  }
}

/// One of the seven daily availability cards.
class DailyAvailabilityRow extends StatelessWidget {
  const DailyAvailabilityRow({
    super.key,
    required this.dayCode,
    required this.label,
    required this.isEnabled,
    required this.onToggle,
    required this.onLongPress,
    this.enabled = true,
  });

  final String dayCode;
  final String label;
  final bool isEnabled;
  final ValueChanged<bool> onToggle;
  final VoidCallback? onLongPress;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final scale = context.sportoScale;
    final accent = isEnabled
        ? ManageAvailabilityPalette.green
        : ManageAvailabilityPalette.red;
    return Semantics(
      key: ValueKey<String>('availability_day_$dayCode'),
      container: true,
      label: '$label availability',
      value: isEnabled ? 'Available' : 'Not Available',
      button: true,
      toggled: isEnabled,
      enabled: enabled,
      onTap: enabled ? () => onToggle(!isEnabled) : null,
      onLongPress: enabled ? onLongPress : null,
      child: Container(
        decoration: BoxDecoration(
          color: ManageAvailabilityPalette.card,
          borderRadius: BorderRadius.circular(14 * scale),
          border: Border.all(color: accent.withValues(alpha: .2)),
          boxShadow: [
            BoxShadow(
              color: accent.withValues(alpha: .08),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(14 * scale),
            onTap: enabled ? () => onToggle(!isEnabled) : null,
            onLongPress: enabled ? onLongPress : null,
            child: Container(
              height: 59 * scale,
              padding: EdgeInsets.symmetric(horizontal: 12 * scale),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          label,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 16 * scale,
                            fontWeight: FontWeight.w600,
                            color: isEnabled
                                ? Colors.white
                                : ManageAvailabilityPalette.muted,
                            height: 1.1,
                          ),
                        ),
                        SizedBox(height: 4 * scale),
                        Row(
                          children: [
                            AvailabilityStatusDot(available: isEnabled),
                            SizedBox(width: 6 * scale),
                            Flexible(
                              child: Text(
                                isEnabled ? 'Available' : 'Not Available',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 12 * scale,
                                  fontWeight: FontWeight.w500,
                                  color: isEnabled
                                      ? ManageAvailabilityPalette.greenLight
                                      : ManageAvailabilityPalette.red,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: 7 * scale),
                  AvailabilityToggle(
                    key: ValueKey<String>(
                      'availability_day_switch_$dayCode',
                    ),
                    value: isEnabled,
                    onChanged: enabled ? onToggle : null,
                    semanticLabel: '$label availability',
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

/// Seven weekday chips with an orange activity dot underneath.
class HourlyWeekdayChipRow extends StatelessWidget {
  const HourlyWeekdayChipRow({
    super.key,
    required this.weekdays,
    required this.selectedDay,
    required this.daysWithActivity,
    required this.onSelected,
    this.enabled = true,
  });

  final List<RefereeWeekday> weekdays;
  final String selectedDay;
  final Set<String> daysWithActivity;
  final ValueChanged<String> onSelected;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final scale = context.sportoScale;
    final items =
        weekdays.isEmpty ? manageAvailabilityFallbackWeekdays : weekdays;
    return LayoutBuilder(
      builder: (context, constraints) {
        final gap = (constraints.maxWidth < 340 * scale ? 6 : 10) * scale;
        final chipWidth =
            (constraints.maxWidth - gap * (items.length - 1)) / items.length;
        return Row(
          children: [
            for (var i = 0; i < items.length; i++) ...[
              SizedBox(
                width: math.max(0, chipWidth),
                child: _HourlyDayChip(
                  key: ValueKey<String>(
                    'availability_chip_${items[i].code}',
                  ),
                  weekday: items[i],
                  selected: items[i].code == selectedDay,
                  hasActivity: daysWithActivity.contains(items[i].code),
                  scale: scale,
                  enabled: enabled,
                  onTap: () => onSelected(items[i].code),
                ),
              ),
              if (i < items.length - 1) SizedBox(width: gap),
            ],
          ],
        );
      },
    );
  }
}

class _HourlyDayChip extends StatelessWidget {
  const _HourlyDayChip({
    super.key,
    required this.weekday,
    required this.selected,
    required this.hasActivity,
    required this.scale,
    required this.enabled,
    required this.onTap,
  });

  final RefereeWeekday weekday;
  final bool selected;
  final bool hasActivity;
  final double scale;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final fullLabel = manageAvailabilityDayLabel(weekday.code, weekday.label);
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: enabled ? onTap : null,
      child: Semantics(
        key: ValueKey<String>(
          'availability_chip_semantics_${weekday.code}',
        ),
        label: fullLabel,
        button: true,
        selected: selected,
        enabled: enabled,
        hint: hasActivity ? 'Has configured hours' : null,
        onTap: enabled ? onTap : null,
        child: SizedBox(
          height: 44,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 160),
                curve: Curves.easeOut,
                height: 27 * scale,
                width: double.infinity,
                padding: EdgeInsets.symmetric(horizontal: 4 * scale),
                decoration: BoxDecoration(
                  color: selected ? null : ManageAvailabilityPalette.card,
                  gradient:
                      selected ? ManageAvailabilityPalette.goldGradient : null,
                  borderRadius: BorderRadius.circular(12 * scale),
                ),
                child: Center(
                  child: Text(
                    manageAvailabilityShortLabel(weekday.code),
                    maxLines: 1,
                    overflow: TextOverflow.clip,
                    style: TextStyle(
                      fontSize: 12 * scale,
                      fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                      color: selected
                          ? ManageAvailabilityPalette.darkText
                          : ManageAvailabilityPalette.muted,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 2 * scale),
              SizedBox(
                height: 6 * scale,
                child: hasActivity
                    ? Align(
                        alignment: Alignment.topCenter,
                        child: Container(
                          key: ValueKey<String>(
                            'availability_day_dot_${weekday.code}',
                          ),
                          width: 6 * scale,
                          height: 6 * scale,
                          decoration: const BoxDecoration(
                            color: ManageAvailabilityPalette.gold,
                            shape: BoxShape.circle,
                          ),
                        ),
                      )
                    : null,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// "Slots" label with the sky gradient "+ Add Slot" pill.
class AvailabilitySectionHeader extends StatelessWidget {
  const AvailabilitySectionHeader({
    super.key,
    required this.onAddSlot,
  });

  final VoidCallback? onAddSlot;

  @override
  Widget build(BuildContext context) {
    final scale = context.sportoScale;
    return Row(
      children: [
        Expanded(
          child: Text(
            'Slots',
            style: TextStyle(
              fontSize: 16 * scale,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ),
        AvailabilityGradientButton(
          semanticsKey: const ValueKey<String>('availability_add_slot'),
          label: 'Add Slot',
          icon: Icons.add_rounded,
          onTap: onAddSlot,
          gradient: ManageAvailabilityPalette.skyGradient,
          textColor: ManageAvailabilityPalette.darkText,
          height: 34,
          fontSize: 12,
          radius: 10,
          fontWeight: FontWeight.w700,
        ),
      ],
    );
  }
}

/// A horizon/sky gradient button used by Add Slot and Submit.
class AvailabilityGradientButton extends StatelessWidget {
  const AvailabilityGradientButton({
    super.key,
    required this.label,
    required this.onTap,
    required this.gradient,
    required this.textColor,
    required this.height,
    required this.fontSize,
    this.radius = 10,
    this.icon,
    this.semanticsKey,
    this.semanticLabel,
    this.expand = false,
    this.fontWeight = FontWeight.w600,
  });

  final String label;
  final VoidCallback? onTap;
  final Gradient gradient;
  final Color textColor;
  final double height;
  final double fontSize;
  final double radius;
  final IconData? icon;
  final Key? semanticsKey;
  final String? semanticLabel;
  final bool expand;
  final FontWeight fontWeight;

  @override
  Widget build(BuildContext context) {
    final scale = context.sportoScale;
    final visualHeight = height * scale;
    final enabled = onTap != null;
    final button = Opacity(
      opacity: enabled ? 1 : .5,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(radius * scale),
          child: Ink(
            height: visualHeight,
            decoration: BoxDecoration(
              gradient: gradient,
              borderRadius: BorderRadius.circular(radius * scale),
            ),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 10 * scale),
              child: Row(
                mainAxisSize: expand ? MainAxisSize.max : MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (icon != null) ...[
                    Icon(
                      icon,
                      size: 14 * scale,
                      color: textColor,
                    ),
                    SizedBox(width: 5 * scale),
                  ],
                  Flexible(
                    child: Text(
                      label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: fontSize * scale,
                        fontWeight: fontWeight,
                        color: textColor,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );

    return Semantics(
      key: semanticsKey,
      label: semanticLabel ?? label,
      button: true,
      enabled: enabled,
      onTap: onTap,
      child: SizedBox(
        width: expand ? double.infinity : null,
        height: math.max(44, visualHeight),
        child: Center(
          child:
              expand ? SizedBox(width: double.infinity, child: button) : button,
        ),
      ),
    );
  }
}

/// Slot card used in hourly mode.
class AvailabilitySlotCard extends StatelessWidget {
  const AvailabilitySlotCard({
    super.key,
    required this.slot,
    required this.onToggle,
    this.onLongPress,
    this.enabled = true,
    this.dayLabel,
  });

  final RefereeAvailabilitySlot slot;
  final ValueChanged<bool> onToggle;
  final VoidCallback? onLongPress;
  final bool enabled;
  final String? dayLabel;

  @override
  Widget build(BuildContext context) {
    final scale = context.sportoScale;
    final fullDay = dayLabel ?? manageAvailabilityDayLabel(slot.day);
    final range = manageAvailabilitySlotRange(slot);
    final timeColor =
        slot.isEnabled ? Colors.white : ManageAvailabilityPalette.muted;
    return Semantics(
      key: ValueKey<String>('availability_slot_${slot.id}'),
      container: true,
      label: '$fullDay slot, ${range.replaceAll(' - ', ' to ')}',
      value: slot.isEnabled ? 'Enabled' : 'Disabled',
      button: true,
      toggled: slot.isEnabled,
      enabled: enabled,
      onTap: enabled ? () => onToggle(!slot.isEnabled) : null,
      onLongPress: enabled ? onLongPress : null,
      child: Container(
        height: 59 * scale,
        decoration: BoxDecoration(
          color: ManageAvailabilityPalette.card,
          borderRadius: BorderRadius.circular(14 * scale),
          border: Border.all(color: const Color(0x332BB673)),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(14 * scale),
            onTap: enabled ? () => onToggle(!slot.isEnabled) : null,
            onLongPress: enabled ? onLongPress : null,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 12 * scale),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          fullDay,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 12 * scale,
                            fontWeight: FontWeight.w500,
                            color: ManageAvailabilityPalette.muted,
                            height: 1.1,
                          ),
                        ),
                        SizedBox(height: 4 * scale),
                        Text(
                          range,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 16 * scale,
                            fontWeight: FontWeight.w600,
                            color: timeColor,
                            height: 1.1,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: 7 * scale),
                  AvailabilityToggle(
                    key: ValueKey<String>(
                      'availability_slot_switch_${slot.id}',
                    ),
                    value: slot.isEnabled,
                    onChanged: enabled ? onToggle : null,
                    semanticLabel: '$fullDay slot $range',
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

/// Friendly empty state inside the hourly list.
class EmptySlotsCard extends StatelessWidget {
  const EmptySlotsCard({
    super.key,
    required this.dayLabel,
    required this.onAddSlot,
  });

  final String dayLabel;
  final VoidCallback? onAddSlot;

  @override
  Widget build(BuildContext context) {
    final scale = context.sportoScale;
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20 * scale),
      decoration: BoxDecoration(
        color: ManageAvailabilityPalette.card,
        borderRadius: BorderRadius.circular(14 * scale),
        border: Border.all(color: const Color(0x337AD3FF)),
      ),
      child: Column(
        children: [
          Icon(
            Icons.schedule_rounded,
            size: 28 * scale,
            color: ManageAvailabilityPalette.skyLight,
          ),
          SizedBox(height: 10 * scale),
          Text(
            'No slots for $dayLabel',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16 * scale,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 4 * scale),
          Text(
            'Add your working hours for this day.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12 * scale,
              fontWeight: FontWeight.w500,
              color: ManageAvailabilityPalette.muted,
            ),
          ),
          SizedBox(height: 16 * scale),
          AvailabilityGradientButton(
            semanticsKey: const ValueKey<String>(
              'availability_empty_add_slot',
            ),
            label: 'Add Slot',
            icon: Icons.add_rounded,
            onTap: onAddSlot,
            gradient: ManageAvailabilityPalette.skyGradient,
            textColor: ManageAvailabilityPalette.darkText,
            height: 34,
            fontSize: 12,
            radius: 10,
            fontWeight: FontWeight.w700,
          ),
        ],
      ),
    );
  }
}

/// Data captured by the Add/Edit sheet. Times are API `HH:mm:ss`.
class SlotDraft {
  const SlotDraft({
    required this.day,
    required this.startTime,
    required this.endTime,
  });

  final String day;
  final String startTime;
  final String endTime;
}

/// Injectable time-picker used by widget tests.
typedef AvailabilityTimePicker = Future<TimeOfDay?> Function(
  BuildContext context, {
  required TimeOfDay initialTime,
  required String helpText,
});

Future<TimeOfDay?> _defaultTimePicker(
  BuildContext context, {
  required TimeOfDay initialTime,
  required String helpText,
}) {
  return showTimePicker(
    context: context,
    initialTime: initialTime,
    helpText: helpText,
  );
}

/// Add / Edit Slot bottom sheet from screen 03.
class AddSlotSheet extends StatefulWidget {
  const AddSlotSheet({
    super.key,
    required this.weekdays,
    required this.onSubmit,
    this.initialDay,
    this.initialSlot,
    this.isSaving = false,
    this.timePicker,
  });

  final List<RefereeWeekday> weekdays;
  final Future<String?> Function(SlotDraft draft) onSubmit;
  final String? initialDay;
  final RefereeAvailabilitySlot? initialSlot;
  final bool isSaving;
  final AvailabilityTimePicker? timePicker;

  @override
  State<AddSlotSheet> createState() => _AddSlotSheetState();
}

class _AddSlotSheetState extends State<AddSlotSheet> {
  late String _day;
  TimeOfDay? _start;
  TimeOfDay? _end;
  String? _error;
  bool _submitting = false;

  List<RefereeWeekday> get _weekdays => widget.weekdays.isEmpty
      ? manageAvailabilityFallbackWeekdays
      : widget.weekdays;

  RefereeAvailabilitySlot? get _initial => widget.initialSlot;

  @override
  void initState() {
    super.initState();
    _day = _initial?.day ??
        widget.initialDay ??
        (_weekdays.isNotEmpty ? _weekdays.first.code : 'MONDAY');
    if (!_weekdays.any((weekday) => weekday.code == _day)) {
      _day = _weekdays.isNotEmpty ? _weekdays.first.code : 'MONDAY';
    }
    _start = manageAvailabilityParseTime(_initial?.startTime);
    _end = manageAvailabilityParseTime(_initial?.endTime);
  }

  String get _dayLabel {
    for (final weekday in _weekdays) {
      if (weekday.code == _day) {
        return manageAvailabilityDayLabel(weekday.code, weekday.label);
      }
    }
    return manageAvailabilityDayLabel(_day);
  }

  bool get _busy => _submitting || widget.isSaving;

  @override
  Widget build(BuildContext context) {
    final scale = context.sportoScale;
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;
    return ClipRRect(
      key: const ValueKey<String>('add_slot_sheet'),
      borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
        child: Container(
          color: ManageAvailabilityPalette.card,
          child: SafeArea(
            top: false,
            child: Padding(
              padding: EdgeInsets.only(bottom: bottomInset),
              child: SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(
                  20 * scale,
                  22 * scale,
                  20 * scale,
                  24 * scale,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            _initial == null ? 'Add Slot' : 'Edit Slot',
                            style: TextStyle(
                              fontSize: 18 * scale,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        Semantics(
                          key: const ValueKey<String>('add_slot_close'),
                          label: 'Close',
                          button: true,
                          onTap: _busy ? null : _close,
                          child: GestureDetector(
                            behavior: HitTestBehavior.opaque,
                            onTap: _busy ? null : _close,
                            child: SizedBox(
                              width: 44,
                              height: 44,
                              child: Center(
                                child: Container(
                                  width: 32 * scale,
                                  height: 32 * scale,
                                  decoration: BoxDecoration(
                                    color: ManageAvailabilityPalette.hairline,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Icon(
                                    Icons.close_rounded,
                                    size: 16 * scale,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 20 * scale),
                    _FieldLabel(label: 'Select Day', scale: scale),
                    SizedBox(height: 8 * scale),
                    _DayField(
                      scale: scale,
                      label: _dayLabel,
                      onTap: _busy ? null : _pickDay,
                    ),
                    SizedBox(height: 20 * scale),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: _TimeField(
                            fieldKey: const ValueKey<String>(
                              'add_slot_from_field',
                            ),
                            scale: scale,
                            label: 'From',
                            value: _start,
                            enabled: !_busy,
                            onTap: () => _pickTime(isStart: true),
                          ),
                        ),
                        SizedBox(width: 12 * scale),
                        Expanded(
                          child: _TimeField(
                            fieldKey: const ValueKey<String>(
                              'add_slot_to_field',
                            ),
                            scale: scale,
                            label: 'To',
                            value: _end,
                            enabled: !_busy,
                            onTap: () => _pickTime(isStart: false),
                          ),
                        ),
                      ],
                    ),
                    if (_error != null) ...[
                      SizedBox(height: 10 * scale),
                      Text(
                        _error!,
                        key: const ValueKey<String>('add_slot_error'),
                        style: TextStyle(
                          fontSize: 12 * scale,
                          fontWeight: FontWeight.w500,
                          color: ManageAvailabilityPalette.red,
                        ),
                      ),
                    ],
                    SizedBox(height: 24 * scale),
                    AvailabilityGradientButton(
                      semanticsKey: const ValueKey<String>('add_slot_submit'),
                      label: 'Submit',
                      onTap: _busy ? null : _submit,
                      gradient: ManageAvailabilityPalette.skyGradient,
                      textColor: Colors.white,
                      height: 48,
                      fontSize: 16,
                      radius: 16,
                      fontWeight: FontWeight.w700,
                      expand: true,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _close() {
    Navigator.of(context).maybePop();
  }

  Future<void> _pickDay() async {
    final picked = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: ManageAvailabilityPalette.card,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) {
        final scale = context.sportoScale;
        return SafeArea(
          top: false,
          child: ListView(
            shrinkWrap: true,
            padding: EdgeInsets.fromLTRB(
              20 * scale,
              16 * scale,
              20 * scale,
              20 * scale,
            ),
            children: [
              Text(
                'Select Day',
                style: TextStyle(
                  fontSize: 18 * scale,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: 10 * scale),
              for (final weekday in _weekdays)
                Semantics(
                  selected: weekday.code == _day,
                  button: true,
                  label: manageAvailabilityDayLabel(
                    weekday.code,
                    weekday.label,
                  ),
                  onTap: () => Navigator.of(sheetContext).pop(weekday.code),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(12 * scale),
                    onTap: () => Navigator.of(sheetContext).pop(weekday.code),
                    child: SizedBox(
                      height: 48,
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              manageAvailabilityDayLabel(
                                weekday.code,
                                weekday.label,
                              ),
                              style: TextStyle(
                                fontSize: 14 * scale,
                                fontWeight: FontWeight.w500,
                                color: weekday.code == _day
                                    ? ManageAvailabilityPalette.greenLight
                                    : Colors.white,
                              ),
                            ),
                          ),
                          if (weekday.code == _day)
                            Icon(
                              Icons.check_rounded,
                              size: 18 * scale,
                              color: ManageAvailabilityPalette.greenLight,
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
    if (picked == null) return;
    setState(() {
      _day = picked;
      _error = null;
    });
  }

  Future<void> _pickTime({required bool isStart}) async {
    final picker = widget.timePicker ?? _defaultTimePicker;
    final fallback = isStart
        ? const TimeOfDay(hour: 9, minute: 0)
        : const TimeOfDay(hour: 17, minute: 0);
    final current = isStart ? _start : _end;
    final picked = await picker(
      context,
      initialTime: current ?? fallback,
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

  Future<void> _submit() async {
    final start = _start;
    final end = _end;
    if (start == null || end == null) {
      setState(() => _error = 'Select both start and end time.');
      return;
    }
    final startMinutes = start.hour * 60 + start.minute;
    final endMinutes = end.hour * 60 + end.minute;
    if (endMinutes <= startMinutes) {
      setState(() => _error = 'End time must be after the start time.');
      return;
    }

    final draft = SlotDraft(
      day: _day,
      startTime: manageAvailabilityFormatApiTime(start),
      endTime: manageAvailabilityFormatApiTime(end),
    );

    setState(() {
      _submitting = true;
      _error = null;
    });

    final error = await widget.onSubmit(draft);
    if (!mounted) return;
    if (error != null) {
      setState(() {
        _submitting = false;
        _error = error;
      });
      return;
    }
    Navigator.of(context).pop(draft);
  }
}

class _FieldLabel extends StatelessWidget {
  const _FieldLabel({required this.label, required this.scale});

  final String label;
  final double scale;

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: TextStyle(
        fontSize: 12 * scale,
        fontWeight: FontWeight.w500,
        color: ManageAvailabilityPalette.muted,
      ),
    );
  }
}

class _DayField extends StatelessWidget {
  const _DayField({
    required this.scale,
    required this.label,
    required this.onTap,
  });

  final double scale;
  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      key: const ValueKey<String>('add_slot_day_field'),
      label: 'Select Day, $label',
      button: true,
      onTap: onTap,
      child: Material(
        color: ManageAvailabilityPalette.field,
        borderRadius: BorderRadius.circular(12 * scale),
        child: InkWell(
          borderRadius: BorderRadius.circular(12 * scale),
          onTap: onTap,
          child: Container(
            height: 48 * scale,
            padding: EdgeInsets.symmetric(horizontal: 14 * scale),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12 * scale),
              border: Border.all(color: ManageAvailabilityPalette.fieldBorder),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 14 * scale,
                      fontWeight: FontWeight.w500,
                      color: Colors.white,
                    ),
                  ),
                ),
                Icon(
                  Icons.keyboard_arrow_down_rounded,
                  size: 18 * scale,
                  color: ManageAvailabilityPalette.muted,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _TimeField extends StatelessWidget {
  const _TimeField({
    required this.fieldKey,
    required this.scale,
    required this.label,
    required this.value,
    required this.enabled,
    required this.onTap,
  });

  final Key fieldKey;
  final double scale;
  final String label;
  final TimeOfDay? value;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final text =
        value == null ? 'Select time' : manageAvailabilityDisplayTime(value!);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _FieldLabel(label: label, scale: scale),
        SizedBox(height: 8 * scale),
        Semantics(
          key: fieldKey,
          label: '$label, $text',
          button: true,
          enabled: enabled,
          onTap: enabled ? onTap : null,
          child: Material(
            color: ManageAvailabilityPalette.field,
            borderRadius: BorderRadius.circular(12 * scale),
            child: InkWell(
              borderRadius: BorderRadius.circular(12 * scale),
              onTap: enabled ? onTap : null,
              child: Container(
                height: 48 * scale,
                padding: EdgeInsets.symmetric(horizontal: 14 * scale),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12 * scale),
                  border:
                      Border.all(color: ManageAvailabilityPalette.fieldBorder),
                ),
                alignment: Alignment.centerLeft,
                child: Text(
                  text,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 14 * scale,
                    fontWeight:
                        value == null ? FontWeight.w400 : FontWeight.w500,
                    color: value == null
                        ? ManageAvailabilityPalette.muted
                        : Colors.white,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
