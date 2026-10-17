import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:partner_data/partner_data.dart';
import 'package:ui_kit/ui_kit.dart';

/// Live team/registration details. Loaded from
/// `GET tournaments/{id}/registrations/{registrationId}` — no static data.
///
/// Opened from the tournament workflow Teams tab. Approve/Reject act through
/// the same `PUT .../approve|reject` endpoints as the workflow quick actions.
class TeamDetailsScreen extends StatefulWidget {
  const TeamDetailsScreen({
    super.key,
    required this.tournamentId,
    required this.registrationId,
    required this.api,
  });

  final String tournamentId;
  final int registrationId;
  final PartnerRemoteDataSource api;

  @override
  State<TeamDetailsScreen> createState() => _TeamDetailsState();
}

class _TeamDetailsState extends State<TeamDetailsScreen> {
  late Future<Map<String, dynamic>> _future;
  String? _actionError;
  String? _busy;

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  Future<Map<String, dynamic>> _load() async {
    final response = await widget.api.tournamentWorkflow(
      widget.tournamentId,
      'registrations/${widget.registrationId}',
    );
    final data = response['data'];
    if (data is Map) return Map<String, dynamic>.from(data);
    throw const SportoApiException('Registration details are unavailable.');
  }

  void _reload() {
    setState(() {
      _actionError = null;
      _future = _load();
    });
  }

  Future<void> _approve() async {
    if (_busy != null) return;
    setState(() {
      _busy = 'approve';
      _actionError = null;
    });
    try {
      await widget.api.tournamentWorkflow(
        widget.tournamentId,
        'registrations/${widget.registrationId}/approve',
        method: 'PUT',
        body: const {},
      );
      if (mounted) Navigator.of(context).pop(true);
    } on SportoApiException catch (error) {
      if (mounted) setState(() => _actionError = error.message);
    } finally {
      if (mounted) setState(() => _busy = null);
    }
  }

  Future<void> _reject() async {
    if (_busy != null) return;
    final ctrl = TextEditingController();
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Reject registration'),
        content: TextField(
          controller: ctrl,
          decoration: const InputDecoration(labelText: 'Reason'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              if (ctrl.text.trim().isNotEmpty) Navigator.pop(ctx, true);
            },
            child: const Text('Reject'),
          ),
        ],
      ),
    );
    ctrl.dispose();
    if (ok != true || !mounted) return;
    setState(() {
      _busy = 'reject';
      _actionError = null;
    });
    try {
      await widget.api.tournamentWorkflow(
        widget.tournamentId,
        'registrations/${widget.registrationId}/reject',
        method: 'PUT',
        body: {'reason': ctrl.text.trim()},
      );
      if (mounted) Navigator.of(context).pop(true);
    } on SportoApiException catch (error) {
      if (mounted) setState(() => _actionError = error.message);
    } finally {
      if (mounted) setState(() => _busy = null);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SportoScreenShell(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => Navigator.maybePop(context),
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
        ),
        title: const Text('Team Details'),
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError || snapshot.data == null) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      snapshot.hasError
                          ? snapshot.error.toString()
                          : 'Registration details are unavailable.',
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    PrimaryButton(
                      label: 'Try Again',
                      onPressed: _reload,
                    ),
                  ],
                ),
              ),
            );
          }
          return _DetailsBody(
            data: snapshot.data!,
            actionError: _actionError,
            busy: _busy,
            onApprove: _approve,
            onReject: _reject,
          );
        },
      ),
    );
  }
}

class _DetailsBody extends StatelessWidget {
  const _DetailsBody({
    required this.data,
    required this.actionError,
    required this.busy,
    required this.onApprove,
    required this.onReject,
  });

  final Map<String, dynamic> data;
  final String? actionError;
  final String? busy;
  final VoidCallback onApprove;
  final VoidCallback onReject;

  static Map<String, dynamic> _obj(Object? value) =>
      value is Map ? Map<String, dynamic>.from(value) : const {};

  String _teamName() {
    final name = _obj(data['team'])['name']?.toString().trim() ?? '';
    if (name.isNotEmpty) return name;
    return (data['name']?.toString().trim().isNotEmpty == true)
        ? data['name'].toString()
        : 'Registration ${data['id'] ?? ''}';
  }

  String _statusLabel() {
    return switch (int.tryParse('${data['status'] ?? ''}')) {
      1 => 'Pending',
      3 => 'Approved',
      4 => 'Rejected',
      _ => 'Status ${data['status'] ?? '—'}',
    };
  }

  String _paymentLabel() {
    return switch (int.tryParse('${data['payment_status'] ?? ''}')) {
      2 => 'Paid',
      1 => 'Pending',
      _ => '—',
    };
  }

  List<TournamentRegistrationPlayer> _players() {
    final raw = data['registration_players'] ?? data['players'];
    if (raw is! List) return const [];
    return raw
        .whereType<Map>()
        .map((e) => TournamentRegistrationPlayer.fromJson(
            Map<String, dynamic>.from(e)))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final players = _players();
    final captain = _obj(data['captain']);
    final captainName = captain['name']?.toString() ?? '—';

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SportoCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _teamName(),
                  style: theme.textTheme.titleLarge,
                ),
                const SizedBox(height: 4),
                Text(
                  'Reg ${(data['registration_number'] ?? '—').toString()}',
                  style: theme.textTheme.bodySmall,
                ),
                const SizedBox(height: 12),
                Wrap(spacing: 8, runSpacing: 8, children: [
                  SportoBadge(text: _paymentLabel(), color: Colors.green),
                  SportoBadge(
                    text: '✓ ${_statusLabel()}',
                    color: context.sporto.info,
                  ),
                ]),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _metric(theme, 'Players', '${players.length}'),
                    _metric(
                      theme,
                      'Captain',
                      captainName.length > 14
                          ? '${captainName.substring(0, 13)}…'
                          : captainName,
                    ),
                    _metric(
                      theme,
                      'Registered',
                      _shortDate(data['registered_at']?.toString()),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          SportoCard(
            width: double.infinity,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Squad (${players.length})',
                  style: theme.textTheme.titleMedium
                      ?.copyWith(color: context.sporto.info),
                ),
                const SizedBox(height: 12),
                if (players.isEmpty)
                  const Text('No squad players returned.'),
                for (var i = 0; i < players.length; i++) ...[
                  Text(
                    players[i].name,
                    style: theme.textTheme.bodyLarge,
                  ),
                  if (i != players.length - 1) const SizedBox(height: 12),
                ],
              ],
            ),
          ),
          if (actionError != null) ...[
            const SizedBox(height: 12),
            Text(
              actionError!,
              style: TextStyle(color: theme.colorScheme.error),
            ),
          ],
          const SizedBox(height: 20),
          PrimaryButton(
            width: double.infinity,
            height: 48,
            label: 'Approve Team',
            loading: busy == 'approve',
            disabled: busy != null,
            onPressed: onApprove,
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: OutlinedButton(
              onPressed: busy != null ? null : onReject,
              child: busy == 'reject'
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Reject Team'),
            ),
          ),
        ],
      ),
    );
  }

  String _shortDate(String? value) {
    if (value == null || value.isEmpty) return '—';
    final parsed = DateTime.tryParse(value);
    if (parsed == null) return value;
    return '${parsed.day}/${parsed.month}/${parsed.year}';
  }

  Widget _metric(ThemeData theme, String label, String value) => Column(
        children: [
          Text(label, style: theme.textTheme.labelSmall),
          const SizedBox(height: 4),
          Text(value, style: theme.textTheme.bodySmall),
        ],
      );
}
