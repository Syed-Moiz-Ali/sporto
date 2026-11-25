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

class _RefereeMatchHistoryScreenState extends State<RefereeMatchHistoryScreen> {
  late int selected;
  _HistorySort _sort = _HistorySort.popularity;
  String? _tournamentFilter;
  late Future<List<RefereeMatchResponse>> _future;

  @override
  void initState() {
    super.initState();
    selected = widget.initialTab.clamp(0, 2);
    _future = widget.matchesFuture ?? _load();
  }

  Future<List<RefereeMatchResponse>> _load() async {
    final remote = DependencyInjector.instance.refereeRemoteDataSource;
    final results = await Future.wait<List<RefereeMatchResponse>>([
      remote.listMyMatchesData(perPage: 50),
      remote
          .listBookingsData(filter: 'completed', perPage: 50)
          .catchError((_) => <RefereeMatchResponse>[]),
    ]);
    final seen = <String>{};
    return [
      for (final list in results)
        for (final match in list)
          if (match.isCompleted && seen.add('${match.isBooking}:${match.id}'))
            match,
    ];
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
    List<RefereeMatchResponse> scoped;
    switch (selected) {
      case 0:
        final now = DateTime.now();
        final monday = DateTime(now.year, now.month, now.day)
            .subtract(Duration(days: now.weekday - 1));
        scoped = matches.where((m) {
          final start = startedAt(m);
          return start != null && !start.isBefore(monday);
        }).toList();
        break;
      case 1:
        final now = DateTime.now();
        scoped = matches.where((m) {
          final start = startedAt(m);
          return start != null &&
              start.year == now.year &&
              start.month == now.month;
        }).toList();
        break;
      default:
        scoped = List.of(matches);
    }

    if (_tournamentFilter != null) {
      scoped = scoped
          .where((m) => m.displayTournament == _tournamentFilter)
          .toList();
    }

    if (selected != 2) return scoped;

    final popularity = <String, int>{};
    for (final match in matches) {
      popularity.update(
        match.displayTournament,
        (value) => value + 1,
        ifAbsent: () => 1,
      );
    }
    scoped.sort((a, b) {
      final aDate = startedAt(a);
      final bDate = startedAt(b);
      switch (_sort) {
        case _HistorySort.newest:
          if (aDate == null) return 1;
          if (bDate == null) return -1;
          return bDate.compareTo(aDate);
        case _HistorySort.oldest:
          if (aDate == null) return 1;
          if (bDate == null) return -1;
          return aDate.compareTo(bDate);
        case _HistorySort.popularity:
          final byPopularity = (popularity[b.displayTournament] ?? 0)
              .compareTo(popularity[a.displayTournament] ?? 0);
          if (byPopularity != 0) return byPopularity;
          if (aDate == null) return 1;
          if (bDate == null) return -1;
          return bDate.compareTo(aDate);
      }
    });
    return scoped;
  }

  Future<void> _pickSort() async {
    final selectedSort = await showModalBottomSheet<_HistorySort>(
      context: context,
      backgroundColor: Colors.transparent,
      barrierColor: const Color(0xCC090C10),
      builder: (context) => _ChoiceSheet<_HistorySort>(
        title: 'Sort By',
        options: const [
          _SheetChoice(_HistorySort.popularity, 'Popularity'),
          _SheetChoice(_HistorySort.newest, 'Newest first'),
          _SheetChoice(_HistorySort.oldest, 'Oldest first'),
        ],
        selected: _sort,
      ),
    );
    if (selectedSort != null && mounted) {
      setState(() => _sort = selectedSort);
    }
  }

  Future<void> _pickTournament(List<RefereeMatchResponse> matches) async {
    final tournaments = matches.map((m) => m.displayTournament).toSet().toList()
      ..sort();
    final picked = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: Colors.transparent,
      barrierColor: const Color(0xCC090C10),
      builder: (context) => _ChoiceSheet<String>(
        title: 'Filter',
        options: [
          const _SheetChoice('__all__', 'All tournaments'),
          for (final tournament in tournaments)
            _SheetChoice(tournament, tournament),
        ],
        selected: _tournamentFilter ?? '__all__',
      ),
    );
    if (picked != null && mounted) {
      setState(() => _tournamentFilter = picked == '__all__' ? null : picked);
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
                              ? const LinearGradient(colors: [
                                  Color(0xFFFF8500),
                                  Color(0xFFD9A81B)
                                ])
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
          if (selected == 2)
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
              child: Row(
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: _pickSort,
                      borderRadius: BorderRadius.circular(8),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Text(
                          'Sort By: ${_sort.label}',
                          style: const TextStyle(
                            color: Color(0xFFA0A0A0),
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  ),
                  InkWell(
                    onTap: () async {
                      final snapshot = await _future;
                      if (mounted) await _pickTournament(snapshot);
                    },
                    borderRadius: BorderRadius.circular(8),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 4,
                        vertical: 4,
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.tune_rounded,
                            size: 16,
                            color: Colors.white,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            _tournamentFilter == null ? 'Filter' : 'Filtered',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
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
                            style: const TextStyle(color: Color(0xFFAAAAAA)),
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
                    itemBuilder: (_, i) => _RealHistoryCard(match: visible[i]),
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
                begin: Alignment.bottomRight,
                end: Alignment.topLeft,
                colors: [
                  Color(0xFF2A1522),
                  Color(0xFF122027),
                  Color(0xFF0A0E12),
                ],
                stops: [0, 0.55, 1],
              ),
              color: const Color(0xFF0A0E12),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0x14FFFFFF))),
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
                  match.displayVenue.isNotEmpty ? _cityLine() : 'Venue not set',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
            ]),
            const SizedBox(height: 8),
            const _DashedDivider(),
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
            const _DashedDivider(),
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

  String _teamScore(RefereeScoreResponse? score, int? teamId, bool isLoading) {
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
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];
    final now = DateTime.now();
    final time = _time12(start);
    final today = DateTime(now.year, now.month, now.day);
    final date = DateTime(start.year, start.month, start.day);
    final dayDiff = today.difference(date).inDays;
    if (dayDiff == 0) return 'Today, $time';
    if (dayDiff == 1) return 'Yesterday, $time';
    return '${start.day} ${months[start.month - 1]}, $time';
  }

  String _cityLine() {
    final raw = match.location?.trim().isNotEmpty == true
        ? match.location!.trim()
        : match.displayVenue.trim();
    if (raw.isEmpty) return 'Venue not set';
    final parts = raw.split(',');
    return parts.last.trim().isEmpty ? raw : parts.last.trim();
  }

  String _time12(DateTime value) {
    final hour = value.hour % 12 == 0 ? 12 : value.hour % 12;
    final minute = value.minute.toString().padLeft(2, '0');
    final suffix = value.hour >= 12 ? 'PM' : 'AM';
    return '${hour.toString().padLeft(2, '0')}:$minute $suffix';
  }
}

class _DashedDivider extends StatelessWidget {
  const _DashedDivider();

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: const Size(double.infinity, 1),
      painter: _DashedDividerPainter(),
    );
  }
}

class _DashedDividerPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0x38FFFFFF)
      ..strokeWidth = 1;
    const dash = 4.0;
    const gap = 3.0;
    var x = 0.0;
    while (x < size.width) {
      canvas.drawLine(
        Offset(x, 0),
        Offset((x + dash).clamp(0, size.width), 0),
        paint,
      );
      x += dash + gap;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

enum _HistorySort {
  popularity('Popularity'),
  newest('Newest first'),
  oldest('Oldest first');

  const _HistorySort(this.label);
  final String label;
}

class _SheetChoice<T> {
  const _SheetChoice(this.value, this.label);
  final T value;
  final String label;
}

class _ChoiceSheet<T> extends StatelessWidget {
  const _ChoiceSheet({
    required this.title,
    required this.options,
    required this.selected,
  });

  final String title;
  final List<_SheetChoice<T>> options;
  final T selected;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
      decoration: const BoxDecoration(
        color: Color(0xFF1C2026),
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close_rounded, color: Colors.white),
                ),
              ],
            ),
            const SizedBox(height: 8),
            for (final option in options)
              InkWell(
                onTap: () => Navigator.of(context).pop(option.value),
                borderRadius: BorderRadius.circular(10),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          option.label,
                          style: TextStyle(
                            color: option.value == selected
                                ? const Color(0xFF7AD3FF)
                                : Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      if (option.value == selected)
                        const Icon(
                          Icons.check_rounded,
                          color: Color(0xFF7AD3FF),
                          size: 20,
                        ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
