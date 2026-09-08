import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:referee_data/referee_data.dart';
import 'package:ui_kit/ui_kit.dart';

import '../../../../core/di/dependency_injector.dart';

class MatchesListScreen extends StatefulWidget {
  const MatchesListScreen({super.key});

  @override
  State<MatchesListScreen> createState() => _MatchesListScreenState();
}

class _MatchesListScreenState extends State<MatchesListScreen> {
  static const List<String> _tabs = [
    'Requests',
    'All',
    'Upcoming',
    'Live',
    'Completed',
  ];

  int _selectedTab = 0;
  late Future<_RefereeMatchesPayload> _future;

  RefereeRemoteDataSource get _remote =>
      DependencyInjector.instance.refereeRemoteDataSource;

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  Future<_RefereeMatchesPayload> _load() async {
    final requests = await _remote.listMatchRequestsData();
    final matches = await _remote.listMyMatchesData(perPage: 50);
    return _RefereeMatchesPayload(
      requests: requests,
      matches: matches,
    );
  }

  void _refresh() {
    setState(() {
      _future = _load();
    });
  }

  Future<void> _accept(RefereeMatchRequestResponse request) async {
    await _remote.acceptMatchRequest(request.assignmentId ?? request.id);
    if (!mounted) return;
    _showSnack('Match request accepted.');
    _refresh();
  }

  Future<void> _reject(RefereeMatchRequestResponse request) async {
    await _remote.rejectMatchRequest(request.assignmentId ?? request.id);
    if (!mounted) return;
    _showSnack('Match request rejected.');
    _refresh();
  }

  Future<void> _showMatchDetails(RefereeMatchResponse match) async {
    try {
      final detail = await _remote.showMyMatchData(match.id);
      if (!mounted) return;
      showModalBottomSheet<void>(
        context: context,
        backgroundColor: const Color(0xFF151B24),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        builder: (_) => _MatchDetailsSheet(match: detail),
      );
    } catch (error) {
      if (!mounted) return;
      _showSnack('Unable to open match details: $error');
    }
  }

  void _showSnack(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final layout = context.sportoLayout;
    final sporto = context.sporto;

    return SafeArea(
      bottom: false,
      child: FutureBuilder<_RefereeMatchesPayload>(
        future: _future,
        builder: (context, snapshot) {
          final payload = snapshot.data ?? const _RefereeMatchesPayload();
          final visibleMatches = _visibleMatches(payload.matches);
          final isRequests = _selectedTab == 0;
          final count =
              isRequests ? payload.requests.length : payload.matches.length;

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 18, 20, 16),
                child: SizedBox(
                  width: double.infinity,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (Navigator.of(context).canPop()) ...[
                        IconButton(
                          padding: EdgeInsets.zero,
                          visualDensity: VisualDensity.compact,
                          constraints: const BoxConstraints(
                            minWidth: 32,
                            minHeight: 32,
                          ),
                          icon: Icon(
                            Icons.arrow_back_ios_new_rounded,
                            color: colors.onSurface,
                            size: 19,
                          ),
                          onPressed: () => context.pop(),
                        ),
                        const SizedBox(height: 6),
                      ],
                      Text(
                        isRequests ? 'Match Requests' : 'Today\'s Matches',
                        style: theme.textTheme.titleLarge?.copyWith(
                          color: colors.onSurface,
                          fontSize: 18,
                          height: 1.15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        isRequests
                            ? '$count Pending Requests'
                            : '$count Matches Assigned',
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: sporto.info,
                          fontSize: 14,
                          height: 1.15,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              _MatchTabs(
                tabs: _tabs,
                selectedIndex: _selectedTab,
                onChanged: (index) => setState(() => _selectedTab = index),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: RefreshIndicator(
                  onRefresh: () async => _refresh(),
                  child: Builder(
                    builder: (context) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      if (snapshot.hasError) {
                        return _CenteredMessage(
                          title: 'Unable to load matches',
                          message: snapshot.error.toString(),
                        );
                      }

                      if (isRequests) {
                        if (payload.requests.isEmpty) {
                          return const _CenteredMessage(
                            title: 'No Match Requests',
                            message: 'New assignments will appear here.',
                          );
                        }
                        return ListView.separated(
                          physics: const AlwaysScrollableScrollPhysics(
                            parent: BouncingScrollPhysics(),
                          ),
                          padding: EdgeInsets.fromLTRB(
                            layout.space20,
                            layout.space8,
                            layout.space20,
                            layout.space12,
                          ),
                          itemCount: payload.requests.length,
                          separatorBuilder: (_, __) =>
                              SizedBox(height: layout.space12),
                          itemBuilder: (context, index) {
                            final request = payload.requests[index];
                            return _RefereeApiMatchCard(
                              match: request,
                              isRequest: true,
                              onAccept: () => _accept(request),
                              onReject: () => _reject(request),
                            );
                          },
                        );
                      }

                      if (visibleMatches.isEmpty) {
                        return const _CenteredMessage(
                          title: 'No Assigned Matches',
                          message: 'Enjoy your day bro, no matches here yet.',
                        );
                      }
                      return ListView.separated(
                        physics: const AlwaysScrollableScrollPhysics(
                          parent: BouncingScrollPhysics(),
                        ),
                        padding: EdgeInsets.fromLTRB(
                          layout.space20,
                          layout.space8,
                          layout.space20,
                          layout.space12,
                        ),
                        itemCount: visibleMatches.length,
                        separatorBuilder: (_, __) =>
                            SizedBox(height: layout.space12),
                        itemBuilder: (context, index) => _RefereeApiMatchCard(
                          match: visibleMatches[index],
                          onTap: () => _showMatchDetails(
                            visibleMatches[index],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  List<RefereeMatchResponse> _visibleMatches(
    List<RefereeMatchResponse> matches,
  ) {
    return switch (_selectedTab) {
      2 => matches.where((match) => match.isUpcoming).toList(),
      3 => matches.where((match) => match.isLive).toList(),
      4 => matches.where((match) => match.isCompleted).toList(),
      _ => matches,
    };
  }
}

class _RefereeMatchesPayload {
  const _RefereeMatchesPayload({
    this.requests = const [],
    this.matches = const [],
  });

  final List<RefereeMatchRequestResponse> requests;
  final List<RefereeMatchResponse> matches;
}

class _RefereeApiMatchCard extends StatelessWidget {
  const _RefereeApiMatchCard({
    required this.match,
    this.isRequest = false,
    this.onTap,
    this.onAccept,
    this.onReject,
  });

  final RefereeMatchResponse match;
  final bool isRequest;
  final VoidCallback? onTap;
  final VoidCallback? onAccept;
  final VoidCallback? onReject;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final sporto = context.sporto;
    final accent = match.isLive
        ? sporto.live
        : match.isCompleted
            ? const Color(0xFF55F58E)
            : sporto.upcoming;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Ink(
          padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF251C20), Color(0xFF1B292F)],
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: accent.withValues(alpha: .22)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  _StatusPill(
                      text: isRequest ? 'Request' : match.displayStatus),
                  const Spacer(),
                  Text(
                    match.displaySchedule,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colors.onSurfaceVariant,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 9),
              Text(
                match.displayTournament,
                style: theme.textTheme.titleMedium?.copyWith(
                  color: colors.tertiary,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  SportoAssetIcon(
                    SportoAssets.locationPin,
                    size: 14,
                    color: colors.onSurfaceVariant,
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      match.displayVenue,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colors.onSurfaceVariant,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      match.displayTeamA,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Text(
                    'Vs',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colors.onSurfaceVariant,
                    ),
                  ),
                  Expanded(
                    child: Text(
                      match.displayTeamB,
                      textAlign: TextAlign.end,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              if (match.role != null || match.roundName != null) ...[
                const SizedBox(height: 10),
                Text(
                  [
                    if (match.roundName != null) match.roundName,
                    if (match.role != null) match.role,
                  ].join(' • '),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colors.onSurfaceVariant,
                  ),
                ),
              ],
              if (isRequest) ...[
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: onReject,
                        child: const Text('Reject'),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: FilledButton(
                        onPressed: onAccept,
                        child: const Text('Accept'),
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _MatchDetailsSheet extends StatelessWidget {
  const _MatchDetailsSheet({required this.match});

  final RefereeMatchResponse match;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 18, 20, 26),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 42,
                height: 4,
                decoration: BoxDecoration(
                  color: colors.onSurfaceVariant.withValues(alpha: .35),
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
            ),
            const SizedBox(height: 18),
            Text(
              match.displayTournament,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              match.displayRound,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colors.tertiary,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            _DetailRow(
                label: 'Teams',
                value: '${match.displayTeamA} vs ${match.displayTeamB}'),
            _DetailRow(label: 'Schedule', value: match.displaySchedule),
            _DetailRow(label: 'Venue', value: match.displayVenue),
            _DetailRow(label: 'Status', value: match.displayStatus),
            if (match.role != null)
              _DetailRow(label: 'Role', value: match.role!),
            if (match.notes != null)
              _DetailRow(label: 'Notes', value: match.notes!),
          ],
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 86,
            child: Text(
              label,
              style: theme.textTheme.bodySmall?.copyWith(
                color: colors.onSurfaceVariant,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colors.onSurface,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusPill extends StatelessWidget {
  const _StatusPill({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final color = context.sporto.upcoming;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: .12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        text,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
            ),
      ),
    );
  }
}

class _CenteredMessage extends StatelessWidget {
  const _CenteredMessage({
    required this.title,
    required this.message,
  });

  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(28, 90, 28, 28),
      children: [
        Text(
          title,
          textAlign: TextAlign.center,
          style: theme.textTheme.titleMedium?.copyWith(
            color: colors.onSurface,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          message,
          textAlign: TextAlign.center,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: colors.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}

class _MatchTabs extends StatelessWidget {
  final List<String> tabs;
  final int selectedIndex;
  final ValueChanged<int> onChanged;

  const _MatchTabs({
    required this.tabs,
    required this.selectedIndex,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final sporto = context.sporto;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: sporto.border.withValues(alpha: .9)),
        ),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Row(
          children: List.generate(tabs.length, (index) {
            final selected = selectedIndex == index;
            return Padding(
              padding: EdgeInsets.only(
                right: index == tabs.length - 1 ? 0 : 22,
              ),
              child: InkWell(
                onTap: () => onChanged(index),
                splashColor: Colors.transparent,
                highlightColor: Colors.transparent,
                child: Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        tabs[index],
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: selected
                              ? colors.onSurfaceVariant
                              : colors.onSurfaceVariant.withValues(alpha: .75),
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 7),
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 150),
                        width: 18,
                        height: 2,
                        decoration: BoxDecoration(
                          color:
                              selected ? colors.tertiary : Colors.transparent,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}
