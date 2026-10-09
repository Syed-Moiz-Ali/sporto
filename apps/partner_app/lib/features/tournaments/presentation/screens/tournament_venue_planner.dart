import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:partner_data/partner_data.dart';
import 'package:ui_kit/ui_kit.dart';
import 'venue_location_picker_screen.dart';

class TournamentVenuePlanner extends StatefulWidget {
  const TournamentVenuePlanner(
      {super.key,
      required this.rounds,
      required this.startDate,
      required this.save,
      this.initial});
  final List<TournamentRound> rounds;
  final DateTime startDate;
  final PlannedTournamentVenue? initial;
  final Future<PlannedTournamentVenue> Function(PlannedTournamentVenue) save;
  @override
  State<TournamentVenuePlanner> createState() => _VenuePlannerState();
}

class _VenuePlannerState extends State<TournamentVenuePlanner> {
  VenueRoundPlan? get previous => widget.initial?.allocations.firstOrNull;
  late final name = TextEditingController(text: widget.initial?.name);
  late final location = TextEditingController(text: widget.initial?.location);
  late final capacity =
      TextEditingController(text: widget.initial?.capacity.toString());
  late final date = TextEditingController(text: previous?.date);
  late final start = TextEditingController(text: previous?.startTime);
  late final end = TextEditingController(text: previous?.endTime);
  late int? roundId = previous?.roundId;
  late String ground = widget.initial?.groundType ?? '';
  late bool primary = widget.initial?.isPrimary ?? false;
  bool saving = false;
  String? error;
  final errors = <String, String>{};
  List<TournamentRound> get availableRounds => widget.rounds
      .where((r) => !r.capacityComplete || r.id == previous?.roundId).toList();
  @override
  void dispose() {
    for (final c in [name, location, capacity, date, start, end]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> pickTime(TextEditingController controller) async {
    final old = controller.text.split(':');
    final selected = await showTimePicker(
        context: context,
        initialTime: TimeOfDay(
            hour: int.tryParse(old.first) ?? 9,
            minute: old.length > 1 ? int.tryParse(old[1]) ?? 0 : 0));
    if (selected != null && mounted)
      setState(() => controller.text =
          '${selected.hour.toString().padLeft(2, '0')}:${selected.minute.toString().padLeft(2, '0')}');
  }

  Future<void> submit() async {
    if (saving) return;
    final c = int.tryParse(capacity.text);
    final d = DateTime.tryParse(date.text);
    errors.clear();
    if (roundId == null || !availableRounds.any((r) => r.id == roundId))
      errors['round'] = 'Select a tournament round.';
    if (name.text.trim().isEmpty) errors['name'] = 'Enter venue name.';
    if (location.text.trim().isEmpty)
      errors['location'] = 'Select venue location.';
    if (ground.isEmpty) errors['ground'] = 'Select ground type.';
    if (c == null || c < 1)
      errors['capacity'] = 'Enter a positive daily match capacity.';
    if (d == null || d.isBefore(widget.startDate))
      errors['date'] = 'Choose a date on or after the tournament start.';
    if (start.text.isEmpty) errors['start'] = 'Select start time.';
    if (end.text.isNotEmpty && end.text.compareTo(start.text) <= 0)
      errors['end'] = 'End time must be after start time.';
    if (errors.isNotEmpty) {
      setState(() => error = null);
      return;
    }
    setState(() {
      saving = true;
      error = null;
    });
    try {
      final plan = VenueRoundPlan(
          roundId: roundId!,
          date: date.text,
          startTime: start.text,
          endTime: end.text.isEmpty ? null : end.text,
          capacity: c!,
          priority: previous?.priority ?? 1,
          isPrimary: previous?.isPrimary ?? primary);
      // Existing additional allocations are preserved, not silently discarded.
      final saved = await widget.save(PlannedTournamentVenue(
          id: widget.initial?.id,
          name: name.text.trim(),
          location: location.text.trim(),
          groundType: ground,
          capacity: c,
          isPrimary: primary,
          allocations: [plan, ...?widget.initial?.allocations.skip(1)]));
      if (mounted) Navigator.pop(context, saved);
    } catch (e) {
      if (mounted) setState(() => error = e.toString());
    } finally {
      if (mounted) setState(() => saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return PopScope(
        canPop: !saving,
        child: Padding(
          padding: EdgeInsets.fromLTRB(
              24, 20, 24, 24 + MediaQuery.viewInsetsOf(context).bottom),
          child: SingleChildScrollView(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                Row(children: [
                  Expanded(
                      child: Text(
                          widget.initial == null
                              ? 'Add Venue Details'
                              : 'Edit Venue Details',
                          style: Theme.of(context).textTheme.titleLarge)),
                  IconButton(
                      onPressed:
                          saving ? null : () => Navigator.maybePop(context),
                      icon: const Icon(Icons.close)),
                ]),
                const SizedBox(height: 20),
                DropdownButtonFormField<int>(
                  value: availableRounds.any((r) => r.id == roundId)
                      ? roundId
                      : null,
                  isExpanded: true,
                  hint: const Text('Select tournament round'),
                  decoration: InputDecoration(
                      labelText: 'Tournament Round',
                      errorText: errors['round']),
                  items: availableRounds
                      .map((r) => DropdownMenuItem(
                          value: r.id,
                          child: Text(r.name, overflow: TextOverflow.ellipsis)))
                      .toList(),
                  onChanged: saving
                      ? null
                      : (v) => setState(() {
                            roundId = v;
                            errors.remove('round');
                          }),
                ),
                const SizedBox(height: 20),
                SportoTextField(
                    label: 'Venue Name',
                    hint: 'e.g. Main Stadium',
                    controller: name,
                    readOnly: saving,
                    errorText: errors['name']),
                const SizedBox(height: 20),
                SportoTextField(
                    label: 'Location',
                    hint: 'Search and select on map',
                    controller: location,
                    readOnly: true,
                    errorText: errors['location'],
                    suffixIcon: const Icon(Icons.map_outlined),
                    onTap: saving
                        ? null
                        : () async {
                            final selected =
                                await Navigator.push<VenueLocationSelection>(
                                    context,
                                    MaterialPageRoute(
                                        builder: (_) =>
                                            VenueLocationPickerScreen(
                                                initialAddress:
                                                    location.text)));
                            if (selected != null && mounted)
                              setState(() => location.text = selected.address);
                          }),
                const SizedBox(height: 20),
                SportoTextField(
                    label: 'Daily Match Capacity',
                    hint: 'e.g. 5 matches per day',
                    controller: capacity,
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    readOnly: saving,
                    errorText: errors['capacity']),
                const SizedBox(height: 20),
                Text('Ground Type',
                    style: Theme.of(context).textTheme.titleSmall),
                const SizedBox(height: 10),
                Wrap(
                    spacing: 10,
                    runSpacing: 8,
                    children: {
                      ...['Turf', 'Grass', 'Indoor', 'Outdoor'],
                      if (ground.isNotEmpty) ground
                    }
                        .map((g) => SportoFilterChip(
                            type: SportoFilterChipType.pill,
                            inactiveFill: true,
                            label: g,
                            active: ground == g,
                            onTap: () {
                              if (!saving) setState(() => ground = g);
                            }))
                        .toList()),
                if (errors['ground'] != null)
                  Text(errors['ground']!, style: TextStyle(color: cs.error)),
                const SizedBox(height: 20),
                SportoTextField(
                    label: 'Date',
                    hint: 'Select venue date',
                    controller: date,
                    readOnly: true,
                    errorText: errors['date'],
                    onTap: saving
                        ? null
                        : () async {
                            final existing = DateTime.tryParse(date.text);
                            final selected = await showDatePicker(
                                context: context,
                                initialDate: existing != null &&
                                        !existing.isBefore(widget.startDate)
                                    ? existing
                                    : widget.startDate,
                                firstDate: widget.startDate,
                                lastDate: DateTime(2100));
                            if (selected != null && mounted)
                              setState(() => date.text =
                                  selected.toIso8601String().substring(0, 10));
                          }),
                const SizedBox(height: 20),
                Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Expanded(
                      child: SportoTextField(
                          label: 'Start Time',
                          hint: 'Select time',
                          controller: start,
                          readOnly: true,
                          errorText: errors['start'],
                          onTap: saving ? null : () => pickTime(start))),
                  const SizedBox(width: 12),
                  Expanded(
                      child: SportoTextField(
                          label: 'End Time (optional)',
                          hint: 'Select time',
                          controller: end,
                          readOnly: true,
                          errorText: errors['end'],
                          onTap: saving ? null : () => pickTime(end))),
                ]),
                if (end.text.isNotEmpty)
                  Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                          onPressed:
                              saving ? null : () => setState(() => end.clear()),
                          child: const Text('Clear end time'))),
                SwitchListTile.adaptive(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Primary venue'),
                    subtitle: const Text('Main venue for the tournament'),
                    value: primary,
                    onChanged:
                        saving ? null : (v) => setState(() => primary = v)),
                if (error != null)
                  Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Text(error!, style: TextStyle(color: cs.error))),
                const SizedBox(height: 16),
                Center(
                    child: PrimaryButton(
                        label: 'Save Venue',
                        loading: saving,
                        disabled: false,
                        onPressed: submit)),
              ])),
        ));
  }
}
