import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:partner_data/partner_data.dart';
import 'package:ui_kit/ui_kit.dart';

/// Registration review and scheduling use real backend round/venue IDs.
class TournamentWorkflowScreen extends StatefulWidget {
  const TournamentWorkflowScreen(
      {super.key, required this.tournamentId, required this.api});
  final String tournamentId;
  final PartnerRemoteDataSource api;
  @override
  State<TournamentWorkflowScreen> createState() => _WorkflowState();
}

class _WorkflowState extends State<TournamentWorkflowScreen> {
  int tab = 0;
  String? busy;
  String? error;
  List<TournamentRegistration> registrations = [];
  List<TournamentRound> rounds = [];
  TournamentSchedule? schedule;
  @override
  void initState() {
    super.initState();
    reload();
  }

  Future<void> reload() async {
    try {
      final selectedTab = tab;
      final result = switch (selectedTab) {
        0 => await widget.api.getRegistrations(widget.tournamentId),
        1 => await widget.api.getRounds(widget.tournamentId),
        _ => await widget.api.getSchedule(widget.tournamentId),
      };
      if (!mounted) return;
      if (selectedTab != tab) return;
      setState(() {
        if (selectedTab == 0)
          registrations = result as List<TournamentRegistration>;
        if (selectedTab == 1) rounds = result as List<TournamentRound>;
        if (selectedTab == 2) schedule = result as TournamentSchedule?;
        error = null;
      });
    } catch (e) {
      if (mounted) setState(() => error = e.toString());
    }
  }

  Future<void> action(String key, String path,
      {String method = 'POST', Map<String, dynamic>? body}) async {
    if (busy != null) return;
    setState(() {
      busy = key;
      error = null;
    });
    try {
      await widget.api.tournamentWorkflow(widget.tournamentId, path,
          method: method, body: body);
      await reload();
    } catch (e) {
      if (e is SportoApiException &&
          e.statusCode == 409 &&
          path == 'schedule/generate') {
        if (mounted &&
            await confirm('Replace the existing draft schedule?') == true) {
          try {
            await widget.api.tournamentWorkflow(widget.tournamentId, path,
                method: method, body: {'overwrite': true});
            await reload();
          } catch (retry) {
            if (mounted) setState(() => error = retry.toString());
          }
        }
      } else if (mounted) {
        setState(() => error = e.toString());
      }
    } finally {
      if (mounted) setState(() => busy = null);
    }
  }

  Future<bool?> confirm(String message) => showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(title: Text(message), actions: [
            TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text('Cancel')),
            TextButton(
                onPressed: () => Navigator.pop(ctx, true),
                child: const Text('Continue'))
          ]));

  Widget button(String key, String label, VoidCallback callback,
          {bool disabled = false}) =>
      Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: PrimaryButton(
              label: label,
              loading: busy == key,
              disabled: disabled || (busy != null && busy != key),
              onPressed: callback));

  Future<void> reject(TournamentRegistration row) async {
    final ctrl = TextEditingController();
    final ok = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
                title: const Text('Reject registration'),
                content: TextField(
                    controller: ctrl,
                    decoration: const InputDecoration(labelText: 'Reason')),
                actions: [
                  TextButton(
                      onPressed: () => Navigator.pop(ctx),
                      child: const Text('Cancel')),
                  TextButton(
                      onPressed: () {
                        if (ctrl.text.trim().isNotEmpty)
                          Navigator.pop(ctx, true);
                      },
                      child: const Text('Reject'))
                ]));
    if (ok == true)
      await action('reject-${row.id}', 'registrations/${row.id}/reject',
          method: 'PUT', body: {'reason': ctrl.text.trim()});
    ctrl.dispose();
  }

  Future<void> registrationDetails(TournamentRegistration row) async {
    if (busy != null) return;
    setState(() => busy = 'roster-${row.id}');
    try {
      final registration =
          await widget.api.getRegistration(widget.tournamentId, row.id);
      if (!mounted) return;
      final players = registration.players;
      await showDialog<void>(
          context: context,
          builder: (ctx) => AlertDialog(
                  title: const Text('Tournament roster'),
                  content: SizedBox(
                    width: double.maxFinite,
                    child: ListView(
                        shrinkWrap: true,
                        children: players.isEmpty
                            ? [const Text('No tournament roster returned.')]
                            : players
                                .map((p) => ListTile(title: Text(p.name)))
                                .toList()),
                  ),
                  actions: [
                    TextButton(
                        onPressed: () => Navigator.pop(ctx),
                        child: const Text('Close'))
                  ]));
    } catch (e) {
      if (mounted) setState(() => error = e.toString());
    } finally {
      if (mounted) setState(() => busy = null);
    }
  }

  Future<void> allocations(TournamentRound round) async {
    if (busy != null) return;
    setState(() => busy = 'allocate-${round.id}');
    try {
      final tournament =
          await widget.api.showTournamentData(widget.tournamentId);
      final result =
          await widget.api.getAllocations(widget.tournamentId, round.id);
      if (!mounted) return;
      await Navigator.push(
          context,
          MaterialPageRoute(
              builder: (_) => _AllocationScreen(
                  api: widget.api,
                  tournamentId: widget.tournamentId,
                  roundId: '${round.id}',
                  venues: tournament.tournamentVenues,
                  initial: result)));
      await reload();
    } catch (e) {
      if (mounted) setState(() => error = e.toString());
    } finally {
      if (mounted) setState(() => busy = null);
    }
  }

  @override
  Widget build(BuildContext context) => SportoScreenShell(
      appBar: AppBar(title: const Text('Tournament management')),
      body: Column(children: [
        SegmentedButton<int>(
            segments: const [
              ButtonSegment(value: 0, label: Text('Teams')),
              ButtonSegment(value: 1, label: Text('Rounds')),
              ButtonSegment(value: 2, label: Text('Schedule'))
            ],
            selected: {
              tab
            },
            onSelectionChanged: busy != null
                ? null
                : (value) {
                    setState(() {
                      tab = value.first;
                    });
                    reload();
                  }),
        Expanded(
            child: RefreshIndicator(
                onRefresh: reload,
                child: ListView(padding: const EdgeInsets.all(16), children: [
                  if (error != null)
                    Text(error!,
                        style: TextStyle(
                            color: Theme.of(context).colorScheme.error)),
                  if (tab == 1)
                    button('generate-rounds', 'Generate rounds',
                        () => action('generate-rounds', 'rounds/generate')),
                  if (tab == 2) ...[
                    button('generate-schedule', 'Generate schedule',
                        () => action('generate-schedule', 'schedule/generate')),
                    Text('Version: ${schedule?.versionId ?? 'Not generated'}'),
                    button(
                        'publish',
                        'Publish schedule',
                        () => action('publish', 'schedule/publish',
                            body: {'version_id': schedule?.versionId}),
                        disabled: schedule?.versionId == null),
                  ],
                  if (tab == 0)
                    ...registrations.map((row) => Card(
                        child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Column(children: [
                              Text(row.name),
                              Text('Status: ${row.status}'),
                              button('roster-${row.id}', 'View roster',
                                  () => registrationDetails(row)),
                              button(
                                  'approve-${row.id}',
                                  'Approve',
                                  () => action('approve-${row.id}',
                                      'registrations/${row.id}/approve',
                                      method: 'PUT')),
                              button('reject-${row.id}', 'Reject',
                                  () => reject(row)),
                            ])))),
                  if (tab == 1)
                    ...rounds.map((round) => Card(
                        child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Column(children: [
                              Text(round.name),
                              Text('${round.matchCount} matches'),
                              button(
                                  'allocate-${round.id}',
                                  'Manage venue allocations',
                                  () => allocations(round)),
                            ])))),
                  if (tab == 2)
                    ...?schedule?.matches.map((match) => Card(
                        child: ListTile(
                            title: Text(match.name),
                            subtitle: Text(
                                '${match.startAt ?? 'Unscheduled'} - ${match.endAt ?? ''}')))),
                  if (tab == 0 && registrations.isEmpty ||
                      tab == 1 && rounds.isEmpty ||
                      tab == 2 && (schedule?.matches.isEmpty ?? true))
                    const Padding(
                        padding: EdgeInsets.all(24),
                        child: Text('No records available yet.')),
                ]))),
      ]));
}

class _AllocationScreen extends StatefulWidget {
  const _AllocationScreen(
      {required this.api,
      required this.tournamentId,
      required this.roundId,
      required this.venues,
      required this.initial});
  final PartnerRemoteDataSource api;
  final String tournamentId, roundId;
  final List<PartnerTournamentVenueResponse> venues;
  final List<TournamentRoundAllocation> initial;
  @override
  State<_AllocationScreen> createState() => _AllocationState();
}

class _AllocationState extends State<_AllocationScreen> {
  late List<TournamentRoundAllocation> rows = widget.initial;
  String? busy, error;
  String get path => 'rounds/${widget.roundId}/allocations';
  Future<void> edit([TournamentRoundAllocation? existing]) async {
    int? venue = existing?.venueId;
    final date = TextEditingController(text: existing?.date);
    final time = TextEditingController(text: existing?.startTime);
    final capacity = TextEditingController(text: existing?.capacity.toString());
    final ok = await showDialog<bool>(
        context: context,
        builder: (ctx) => StatefulBuilder(
            builder: (ctx, update) => AlertDialog(
                    title: const Text('Round venue allocation'),
                    content: SingleChildScrollView(
                        child:
                            Column(mainAxisSize: MainAxisSize.min, children: [
                      DropdownButtonFormField<int>(
                          value: venue,
                          isExpanded: true,
                          decoration: const InputDecoration(labelText: 'Venue'),
                          items: widget.venues
                              .map((v) => DropdownMenuItem(
                                  value: v.id,
                                  child: Text(v.venueName,
                                      overflow: TextOverflow.ellipsis)))
                              .toList(),
                          onChanged: (v) => update(() => venue = v)),
                      TextField(
                          controller: date,
                          readOnly: true,
                          decoration: const InputDecoration(labelText: 'Date'),
                          onTap: () async {
                            final d = await showDatePicker(
                                context: ctx,
                                initialDate: DateTime.now(),
                                firstDate: DateTime(2020),
                                lastDate: DateTime(2100));
                            if (d != null)
                              date.text = d.toIso8601String().substring(0, 10);
                          }),
                      TextField(
                          controller: time,
                          readOnly: true,
                          decoration:
                              const InputDecoration(labelText: 'Start time'),
                          onTap: () async {
                            final t = await showTimePicker(
                                context: ctx, initialTime: TimeOfDay.now());
                            if (t != null)
                              time.text =
                                  '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';
                          }),
                      TextField(
                          controller: capacity,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                              labelText: 'Allocated matches/day')),
                    ])),
                    actions: [
                      TextButton(
                          onPressed: () => Navigator.pop(ctx),
                          child: const Text('Cancel')),
                      TextButton(
                          onPressed: () {
                            final c = int.tryParse(capacity.text);
                            if (venue != null &&
                                date.text.isNotEmpty &&
                                time.text.isNotEmpty &&
                                c != null &&
                                c > 0 &&
                                c <=
                                    (widget.venues
                                            .firstWhere((v) => v.id == venue)
                                            .dailyMatchCapacity ??
                                        c)) {
                              Navigator.pop(ctx, true);
                            } else {
                              ScaffoldMessenger.of(context)
                                  .showSnackBar(const SnackBar(
                                content: Text(
                                    'Choose a venue, date and start time. Capacity must be positive and within the venue limit.'),
                              ));
                            }
                          },
                          child: const Text('Save'))
                    ])));
    if (ok == true)
      await mutate(
          existing == null ? path : '$path/${existing.id}',
          existing == null ? 'POST' : 'PUT',
          TournamentAllocationRequest(
                  venueId: venue!,
                  date: date.text,
                  startTime: time.text,
                  capacity: int.parse(capacity.text))
              .toJson());
    date.dispose();
    time.dispose();
    capacity.dispose();
  }

  Future<void> mutate(
      String resource, String method, Map<String, dynamic>? body) async {
    if (busy != null) return;
    setState(() => busy = resource);
    try {
      await widget.api.tournamentWorkflow(widget.tournamentId, resource,
          method: method, body: body);
      final updated =
          await widget.api.getAllocations(widget.tournamentId, widget.roundId);
      if (mounted)
        setState(() {
          rows = updated;
          error = null;
        });
    } catch (e) {
      if (mounted) setState(() => error = e.toString());
    } finally {
      if (mounted) setState(() => busy = null);
    }
  }

  @override
  Widget build(BuildContext context) => SportoScreenShell(
      appBar: AppBar(title: const Text('Round allocations')),
      body: ListView(padding: const EdgeInsets.all(16), children: [
        if (error != null) Text(error!),
        PrimaryButton(
            label: 'Add allocation',
            loading: busy == path,
            disabled: busy != null,
            onPressed: () => edit()),
        ...rows.map((r) => Card(
            child: ListTile(
                title: Text('${r.date} • ${r.startTime}'),
                subtitle:
                    Text('Venue ${r.venueId} • ${r.capacity} matches/day'),
                onTap: busy == null ? () => edit(r) : null,
                trailing: IconButton(
                    icon: busy == '$path/${r.id}'
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator())
                        : const Icon(Icons.delete_outline),
                    onPressed: busy == null
                        ? () => mutate('$path/${r.id}', 'DELETE', null)
                        : null)))),
      ]));
}
