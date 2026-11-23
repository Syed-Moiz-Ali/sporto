import 'package:flutter/material.dart';
import 'package:referee_app/core/di/dependency_injector.dart';
import 'package:referee_data/referee_data.dart';
import 'package:ui_kit/ui_kit.dart';

import '../wallet_adapters.dart';
import '../wallet_icons.dart';
import '../widgets/wallet_shared_widgets.dart';

/// Screen 01 - referee tournaments history (Figma `01_My-Tournaments`).
///
/// The live endpoint returns only `{id, name, code, status, currency}`. Venue,
/// date, team counts, fees and level/approval badges are therefore not rendered
/// instead of being faked.
class TournamentsHistoryScreen extends StatefulWidget {
  final Future<RefereeTournamentHistoryPage>? tournamentsFuture;

  const TournamentsHistoryScreen({
    super.key,
    this.tournamentsFuture,
  });

  @override
  State<TournamentsHistoryScreen> createState() =>
      _TournamentsHistoryScreenState();
}

class _TournamentsHistoryScreenState extends State<TournamentsHistoryScreen> {
  bool _showCompleted = true;
  bool _newestFirst = true;
  late Future<RefereeTournamentHistoryPage> _future;

  RefereeRemoteDataSource get _remote =>
      DependencyInjector.instance.refereeRemoteDataSource;

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  Future<RefereeTournamentHistoryPage> _load() {
    return widget.tournamentsFuture ?? _remote.listTournamentsData(perPage: 50);
  }

  void _retry() {
    setState(() => _future = _load());
  }

  List<RefereeTournamentHistoryItem> _visible(
    List<RefereeTournamentHistoryItem> items,
  ) {
    final filtered = items
        .where(
          (item) => _showCompleted
              ? RefereeTournamentStatus.isCompleted(item)
              : RefereeTournamentStatus.isCancelled(item),
        )
        .toList(growable: false);
    return _newestFirst ? filtered : filtered.reversed.toList(growable: false);
  }

  @override
  Widget build(BuildContext context) {
    final scale = context.sportoScale;
    final tokens = context.sporto;

    return Scaffold(
      backgroundColor: tokens.canvas,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            WalletScreenHeader(
              title: 'Tournaments History',
              trailing: WalletPill(
                label: 'Create',
                gradient: const LinearGradient(
                  colors: [Color(0xFF7AD3FF), Color(0xFF4FBAF0)],
                ),
                textColor: const Color(0xFF090C10),
                fontWeight: FontWeight.w700,
                leading: SportoSvgIcon(
                  WalletIcons.plus,
                  size: 10 * scale,
                  color: const Color(0xFF090C10),
                ),
                onTap: () => _showComingSoon(
                  'Tournament creation is not available yet.',
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(
                20 * scale,
                8 * scale,
                12 * scale,
                0,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      clipBehavior: Clip.none,
                      child: Row(
                        children: [
                          WalletFilterChip(
                            label: 'Completed',
                            selected: _showCompleted,
                            onTap: () => setState(() => _showCompleted = true),
                          ),
                          SizedBox(width: 10 * scale),
                          WalletFilterChip(
                            label: 'Cancelled',
                            selected: !_showCompleted,
                            onTap: () => setState(() => _showCompleted = false),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(width: 6 * scale),
                  WalletSortButton(
                    onTap: () => setState(() => _newestFirst = !_newestFirst),
                  ),
                ],
              ),
            ),
            Expanded(
              child: FutureBuilder<RefereeTournamentHistoryPage>(
                future: _future,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting ||
                      snapshot.connectionState == ConnectionState.none) {
                    return const _TournamentsSkeleton();
                  }
                  if (snapshot.hasError) {
                    return Center(
                      child: SportoErrorView(
                        headline: 'Unable to load tournaments',
                        description: 'Check your connection and try again.',
                        onRetry: _retry,
                      ),
                    );
                  }
                  final visible = _visible(snapshot.data?.items ?? const []);
                  return ListView(
                    padding: EdgeInsets.fromLTRB(
                      20 * scale,
                      10 * scale,
                      20 * scale,
                      24 * scale + MediaQuery.paddingOf(context).bottom,
                    ),
                    children: [
                      if (visible.isEmpty)
                        WalletEmptyState(
                          message: _showCompleted
                              ? 'No completed tournaments yet'
                              : 'No cancelled tournaments yet',
                        )
                      else
                        for (var i = 0; i < visible.length; i++) ...[
                          _TournamentCard(
                            tournament: visible[i],
                            scale: scale,
                            onAction: (label) => _showComingSoon(
                              '$label is not available yet.',
                            ),
                          ),
                          if (i != visible.length - 1)
                            SizedBox(height: 20 * scale),
                        ],
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showComingSoon(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: context.sporto.cardElevated,
          behavior: SnackBarBehavior.floating,
        ),
      );
  }
}

class _TournamentsSkeleton extends StatelessWidget {
  const _TournamentsSkeleton();

  @override
  Widget build(BuildContext context) {
    final scale = context.sportoScale;
    return Semantics(
      label: 'Loading tournaments',
      child: ListView(
        padding: EdgeInsets.fromLTRB(
          20 * scale,
          10 * scale,
          20 * scale,
          24 * scale + MediaQuery.paddingOf(context).bottom,
        ),
        children: [
          for (var i = 0; i < 3; i++) ...[
            SportoSkeletonCard(
              height: 120 * scale,
              borderRadius: 16 * scale,
            ),
            if (i != 2) SizedBox(height: 20 * scale),
          ],
        ],
      ),
    );
  }
}

class _TournamentCard extends StatelessWidget {
  final RefereeTournamentHistoryItem tournament;
  final double scale;
  final ValueChanged<String> onAction;

  const _TournamentCard({
    required this.tournament,
    required this.scale,
    required this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    final tokens = context.sporto;
    final statusLabel = RefereeTournamentStatus.labelFor(tournament);
    final statusColor = RefereeTournamentStatus.isCancelled(tournament)
        ? tokens.red
        : tokens.accentGreen;

    return Container(
      padding: EdgeInsets.all(12 * scale),
      decoration: BoxDecoration(
        color: tokens.card,
        borderRadius: BorderRadius.circular(16 * scale),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              WalletBadge(label: statusLabel, color: statusColor),
              const Spacer(),
            ],
          ),
          SizedBox(height: 12 * scale),
          Text(
            tournament.name.isEmpty ? '—' : tournament.name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 14 * scale,
              fontWeight: FontWeight.w600,
              color: Colors.white,
              height: 1.25,
            ),
          ),
          SizedBox(height: 12 * scale),
          Container(
            height: 1 * scale,
            color: tokens.border.withValues(alpha: 0.5),
          ),
          SizedBox(height: 8 * scale),
          _InfoRow(
            label: 'Code',
            value: RefereeTournamentStatus.codeFor(tournament),
            scale: scale,
          ),
          SizedBox(height: 6 * scale),
          _InfoRow(
            label: 'Currency',
            value: RefereeTournamentStatus.currencyFor(tournament),
            scale: scale,
          ),
          // Wire the fields supplied by the referee tournament projection.
          SizedBox(height: 6 * scale),
          _InfoRow(
            label: 'Venue',
            value: _firstText([
                  tournament.raw['venue_name'],
                  tournament.raw['location'],
                  tournament.raw['venue'],
                ]) ??
                'Not configured',
            scale: scale,
          ),
          if (_firstText([tournament.raw['city']]) != null) ...[
            SizedBox(height: 6 * scale),
            _InfoRow(
              label: 'City',
              value: _firstText([tournament.raw['city']])!,
              scale: scale,
            ),
          ],
          SizedBox(height: 6 * scale),
          _InfoRow(
            label: 'Date',
            value: _dateRange(tournament) ?? 'Not configured',
            scale: scale,
          ),
          SizedBox(height: 6 * scale),
          _InfoRow(
            label: 'Teams',
            value: _teamCount(tournament) ?? 'Not configured',
            scale: scale,
          ),
          SizedBox(height: 6 * scale),
          _InfoRow(
            label: 'Level',
            value: _firstText([tournament.raw['level']]) ?? 'Not configured',
            scale: scale,
          ),
          SizedBox(height: 6 * scale),
          _InfoRow(
            label: 'Earnings',
            value: _earningsTotal(tournament) ?? 'Not available',
            scale: scale,
          ),
          SizedBox(height: 12 * scale),
          Row(
            children: [
              Expanded(
                child: _CardAction(
                  label: 'View',
                  scale: scale,
                  onTap: () => onAction('View'),
                ),
              ),
              SizedBox(width: 8 * scale),
              Expanded(
                child: _CardAction(
                  label: 'Manage',
                  scale: scale,
                  onTap: () => onAction('Manage'),
                ),
              ),
              SizedBox(width: 8 * scale),
              Expanded(
                child: _CardAction(
                  label: 'Earnings',
                  scale: scale,
                  onTap: () => onAction('Earnings'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

String? _firstText(List<Object?> values) {
  for (final value in values) {
    final text = value?.toString().trim() ?? '';
    if (text.isNotEmpty) return text;
  }
  return null;
}

String? _dateRange(RefereeTournamentHistoryItem item) {
  final start = _firstText([
    item.raw['start_date'],
    item.raw['start_at'],
    item.raw['from_date'],
  ]);
  final end = _firstText([
    item.raw['end_date'],
    item.raw['end_at'],
    item.raw['to_date'],
  ]);
  if (start == null && end == null) return null;
  if (start != null && end != null) return '$start - $end';
  return start ?? end;
}

String? _teamCount(RefereeTournamentHistoryItem item) {
  final registered =
      item.raw['teams_registered'] ?? item.raw['registered_teams'];
  final capacity = item.raw['teams_capacity'] ?? item.raw['max_teams'];
  if (registered == null && capacity == null) return null;
  return '${registered ?? '-'}/${capacity ?? '-'} Teams';
}

String? _earningsTotal(RefereeTournamentHistoryItem item) {
  final value = item.raw['earnings_total'];
  if (value == null) return null;
  final number = num.tryParse(value.toString());
  if (number == null) return null;
  return '\u20B9${number.toStringAsFixed(0)}';
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  final double scale;

  const _InfoRow({
    required this.label,
    required this.value,
    required this.scale,
  });

  @override
  Widget build(BuildContext context) {
    final tokens = context.sporto;
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 12 * scale,
              fontWeight: FontWeight.w500,
              color: tokens.muted,
              height: 1.2,
            ),
          ),
        ),
        SizedBox(width: 12 * scale),
        Expanded(
          child: Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.right,
            style: TextStyle(
              fontSize: 12 * scale,
              fontWeight: FontWeight.w500,
              color: Colors.white,
              height: 1.2,
            ),
          ),
        ),
      ],
    );
  }
}

class _CardAction extends StatelessWidget {
  final String label;
  final double scale;
  final VoidCallback onTap;

  const _CardAction({
    required this.label,
    required this.scale,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final tokens = context.sporto;
    return Semantics(
      button: true,
      label: label,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12 * scale),
          child: SizedBox(
            height: 44 * scale,
            width: double.infinity,
            child: Center(
              child: Container(
                height: 31 * scale,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: tokens.canvas.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(12 * scale),
                ),
                alignment: Alignment.center,
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 12 * scale,
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                    height: 1.2,
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
