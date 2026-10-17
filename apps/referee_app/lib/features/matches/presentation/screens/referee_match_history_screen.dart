import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:referee_data/referee_data.dart';
import 'package:ui_kit/ui_kit.dart';

import '../../../../core/di/dependency_injector.dart';
import '../../../../core/match_action/match_action_resolver.dart';
import '../widgets/match_live_score.dart';

/// Referee match history — real completed matches from
/// `GET /v1/referee/matches`, with working This Week / This Month / All
/// filters. Final scores come from the authoritative per-match
/// `GET /score`, exactly like the live cards (never static text).
class RefereeMatchHistoryScreen extends StatefulWidget {
  final int initialTab;

  /// Test seam — production leaves this null so the screen loads live data.
  final Future<List<RefereeMatchResponse>>? matchesFuture;

  const RefereeMatchHistoryScreen(
      {super.key, this.initialTab = 0, this.matchesFuture});

  @override
  State<RefereeMatchHistoryScreen> createState() =>
      _RefereeMatchHistoryScreenState();
}

class _RefereeMatchHistoryScreenState
    extends State<RefereeMatchHistoryScreen> {
  late int selected;
  late Future<List<RefereeMatchResponse>> _future;

  @override
  void initState() {
    super.initState();
    selected = widget.initialTab.clamp(0, 2);
    _future = widget.matchesFuture ?? _load();
  }

  Future<List<RefereeMatchResponse>> _load() async {
    final matches = await DependencyInjector
        .instance.refereeRemoteDataSource
        .listMyMatchesData(perPage: 50);
    return matches.where((m) => m.isCompleted).toList();
  }

  void _reload() {
    // Start the fetch outside setState — the callback must return void.
    final next = widget.matchesFuture ?? _load();
    setState(() {
      _future = next;
    });
  }

  List<RefereeMatchResponse> _filtered(List<RefereeMatchResponse> matches) {
    DateTime? startedAt(RefereeMatchResponse m) => parseMatchStart(m);
    switch (selected) {
      case 0:
        final now = DateTime.now();
        final monday = DateTime(now.year, now.month, now.day)
            .subtract(Duration(days: now.weekday - 1));
        return matches.where((m) {
          final start = startedAt(m);
          return start != null && !start.isBefore(monday);
        }).toList();
      case 1:
        final now = DateTime.now();
        return matches.where((m) {
          final start = startedAt(m);
          return start != null &&
              start.year == now.year &&
              start.month == now.month;
        }).toList();
      default:
        return matches;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    return SportoScreenShell(
      body: SafeArea(
        child: Column(children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 23),
            child: Row(children: [
              Material(
                  color: const Color(0xFF252C3B),
                  borderRadius: BorderRadius.circular(10),
                  child: InkWell(
                      onTap: () => context.pop(),
                      borderRadius: BorderRadius.circular(10),
                    child: const SizedBox(
                        width: 36,
                        height: 36,
                        child: Icon(Icons.arrow_back_ios_new_rounded,
                            size: 18)))),
              const SizedBox(width: 11),
              Text('Match History',
                  style: theme.textTheme.titleLarge
                      ?.copyWith(fontSize: 18, fontWeight: FontWeight.w600)),
            ]),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Container(
              height: 42,
              padding: const EdgeInsets.all(5),
              decoration: BoxDecoration(
                  gradient: const LinearGradient(
                      colors: [Color(0xFF23202C), Color(0xFF1C2427)]),
                  borderRadius: BorderRadius.circular(15)),
              child: Row(
                children: List.generate(3, (index) {
                  final active = selected == index;
                  return Expanded(
                      child: GestureDetector(
                    onTap: () => setState(() => selected = index),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 160),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                          gradient: active
                              ? const LinearGradient(
                                  colors: [Color(0xFFFF8500), Color(0xFFD9A81B)])
                              : null,
                          borderRadius: BorderRadius.circular(10)),
                      child: Text(
                        const ['This Week', 'This Month', 'All Matches'][index],
                        style: theme.textTheme.bodyMedium?.copyWith(
                            color: active ? Colors.white : cs.onSurfaceVariant,
                            fontWeight:
                                active ? FontWeight.w600 : FontWeight.w500),
                      ),
                    ),
                  ));
                }),
              ),
            ),
          ),
          Expanded(
            child: FutureBuilder<List<RefereeMatchResponse>>(
              future: _future,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return ListView.separated(
                    padding: const EdgeInsets.fromLTRB(20, 21, 20, 30),
                    itemCount: 3,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (_, __) => const _HistoryCardShimmer(),
                  );
                }
                if (snapshot.hasError) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.error_outline,
                              color: Color(0xFFFE464B)),
                          const SizedBox(height: 12),
                          const Text(
                            'Unable to load match history.',
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w600),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            '${snapshot.error}',
                            textAlign: TextAlign.center,
                            style:
                                const TextStyle(color: Color(0xFFAAAAAA)),
                          ),
                          const SizedBox(height: 18),
                          ElevatedButton(
                            onPressed: _reload,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFED7B00),
                              foregroundColor: Colors.white,
                            ),
                            child: const Text('Retry'),
                          ),
                        ],
                      ),
                    ),
                  );
                }
                final visible = _filtered(snapshot.data ?? const []);
                if (visible.isEmpty) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(24),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.emoji_events_outlined,
                              color: Color(0xFFAAAAAA), size: 40),
                          SizedBox(height: 12),
                          Text(
                            'No matches here yet.',
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w600),
                          ),
                          SizedBox(height: 6),
                          Text(
                            'Completed matches will appear here.',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Color(0xFFAAAAAA)),
                          ),
                        ],
                      ),
                    ),
                  );
                }
                return RefreshIndicator(
                  onRefresh: () async => _reload(),
                  child: ListView.separated(
                    padding: const EdgeInsets.fromLTRB(20, 21, 20, 30),
                    itemCount: visible.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (_, i) =>
                        _RealHistoryCard(match: visible[i]),
                  ),
                );
              },
            ),
          ),
        ]),
      ),
    );
  }
}

class _HistoryCardShimmer extends StatefulWidget {
  const _HistoryCardShimmer();

  @override
  State<_HistoryCardShimmer> createState() => _HistoryCardShimmerState();
}

class _HistoryCardShimmerState extends State<_HistoryCardShimmer>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) => Container(
        height: 150,
        decoration: BoxDecoration(
          color: const Color(0xFF1C2026),
          borderRadius: BorderRadius.circular(15),
        ),
      ),
    );
  }
}

/// Completed-match card with the final score from the authoritative
/// per-match GET /score — same source as the live cards.
class _RealHistoryCard extends StatelessWidget {
  const _RealHistoryCard({required this.match});

  final RefereeMatchResponse match;

  @override
  Widget build(BuildContext context) {
    return MatchLiveScore(
      matchId: match.id,
      builder: (context, score, isLoading) {
        final teamAScore = _teamScore(score, match.teamA?.id, isLoading);
        final teamBScore = _teamScore(score, match.teamB?.id, isLoading);
        final winner = _winnerLabel(score);

        return Container(
          padding: const EdgeInsets.fromLTRB(10, 12, 10, 11),
          decoration: BoxDecoration(
              gradient: const LinearGradient(
                  colors: [Color(0xFF251C20), Color(0xFF1B292F)]),
              borderRadius: BorderRadius.circular(15)),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Text(
                match.displayTournament,
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w600),
              ),
              const Spacer(),
              Text(
                _dateLine(),
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontSize: 12,
                    ),
              ),
            ]),
            const SizedBox(height: 2),
            Row(children: [
              SportoAssetIcon(
                SportoAssets.locationPin,
                size: 14,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              const SizedBox(width: 2),
              Expanded(
                child: Text(
                  match.displayVenue.isNotEmpty
                      ? match.displayVenue
                      : 'Venue not set',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
            ]),
            const SizedBox(height: 8),
            Divider(
                height: 1,
                color: Theme.of(context)
                    .colorScheme
                    .onSurfaceVariant
                    .withValues(alpha: .22)),
            const SizedBox(height: 8),
            Row(children: [
              Expanded(
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                    Text(match.displayTeamA,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 12)),
                    Text(teamAScore,
                        style: const TextStyle(
                            color: Color(0xFF42F58D),
                            fontSize: 14,
                            fontWeight: FontWeight.w600))
                  ])),
              Text('Vs', style: Theme.of(context).textTheme.bodySmall),
              Expanded(
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                    Text(match.displayTeamB,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.right,
                        style: const TextStyle(fontSize: 12)),
                    Text(teamBScore,
                        textAlign: TextAlign.right,
                        style: const TextStyle(
                            fontSize: 14, fontWeight: FontWeight.w600))
                  ])),
            ]),
            const SizedBox(height: 8),
            Divider(
                height: 1,
                color: Theme.of(context)
                    .colorScheme
                    .onSurfaceVariant
                    .withValues(alpha: .22)),
            const SizedBox(height: 8),
            Center(
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                const CircleAvatar(
                    radius: 4, backgroundColor: Color(0xFF55F58E)),
                const SizedBox(width: 4),
                Text(winner,
                    style: const TextStyle(
                        color: Color(0xFF55F58E),
                        fontSize: 14,
                        fontWeight: FontWeight.w500)),
              ]),
            ),
          ]),
        );
      },
    );
  }

  String _teamScore(
      RefereeScoreResponse? score, int? teamId, bool isLoading) {
    if (isLoading) return '…';
    if (teamId == null) return '—';
    return liveTeamScore(score, teamId) ?? '—';
  }

  String _winnerLabel(RefereeScoreResponse? score) {
    final winnerId = score?.winnerTeamId;
    if (winnerId != null) {
      for (final team in score?.teams ?? const <RefereeScoreTeamResponse>[]) {
        if (team.id == winnerId && team.name.trim().isNotEmpty) {
          return '${team.name} Won';
        }
      }
      if (match.teamA?.id == winnerId) return '${match.displayTeamA} Won';
      if (match.teamB?.id == winnerId) return '${match.displayTeamB} Won';
    }
    final status = score?.resultStatus?.trim() ?? '';
    if (status.isNotEmpty && status.toUpperCase() != 'UNRESOLVED') {
      return status;
    }
    return 'Result awaited';
  }

  String _dateLine() {
    final start = parseMatchStart(match);
    if (start == null) return 'Schedule not set';
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    final today = DateTime.now();
    final isToday = start.year == today.year &&
        start.month == today.month &&
        start.day == today.day;
    return '${start.day} ${months[start.month - 1]}'
        '${isToday ? ', Today' : ''}';
  }
}
