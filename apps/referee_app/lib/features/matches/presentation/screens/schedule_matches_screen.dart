import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:referee_data/referee_data.dart';
import 'package:ui_kit/ui_kit.dart';

import '../../../../app/router/app_router.dart';
import '../../../../core/di/dependency_injector.dart';
import '../../../../core/match_action/match_action_resolver.dart';
import '../widgets/match_live_score.dart';
import '../widgets/referee_request_widgets.dart';

/// Referee Schedule/Matches tab redesigned from the
/// `schedule_matches_redesign` Figma package (Matches + Playground states).
class ScheduleMatchesScreen extends StatefulWidget {
  final Future<List<RefereeMatchResponse>>? matchesFuture;

  const ScheduleMatchesScreen({super.key, this.matchesFuture});

  @override
  State<ScheduleMatchesScreen> createState() => _ScheduleMatchesScreenState();
}

class _ScheduleMatchesScreenState extends State<ScheduleMatchesScreen> {
  late Future<List<RefereeMatchResponse>> _future;
  int _selectedTab = 0;
  bool _tabInitialized = false;
  String _query = '';

  RefereeRemoteDataSource get _remote =>
      DependencyInjector.instance.refereeRemoteDataSource;

  @override
  void initState() {
    super.initState();
    _future = _prepare(widget.matchesFuture ?? _load());
  }

  Future<List<RefereeMatchResponse>> _load() =>
      _remote.listMyMatchesData(perPage: 50);

  Future<List<RefereeMatchResponse>> _prepare(
    Future<List<RefereeMatchResponse>> source,
  ) async {
    final matches = await source;
    if (!_tabInitialized) {
      _tabInitialized = true;
      if (matches.any((match) => match.isLive)) {
        _selectedTab = 0;
      } else if (matches.any((match) => match.isUpcoming)) {
        _selectedTab = 1;
      } else {
        _selectedTab = 2;
      }
    }
    return matches;
  }

  Future<void> _refresh() async {
    setState(() => _future = _prepare(_load()));
    await _future;
  }

  void _snack(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  void _performAction(RefereeMatchResponse match) {
    final resolved = resolveMatchAction(match);
    switch (resolved.action) {
      case MatchAction.continueScoring:
      case MatchAction.startScoring:
      case MatchAction.viewReport:
        context.push(
          '${AppRouter.liveScoringRoute}?matchId=${match.id}&matchCode=${Uri.encodeComponent(requestCode(match))}',
        );
      case MatchAction.toss:
        context.push('${AppRouter.conductTossRoute}?matchId=${match.id}');
      case MatchAction.verify:
        context.push(
          '${AppRouter.matchVerificationRoute}?matchId=${match.id}',
        );
      case MatchAction.blocked:
        _snack(resolved.blockedReason ?? 'Unavailable');
    }
  }

  void _openDelayedStatus(RefereeMatchResponse match) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: const Color(0xFF151B24),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 44,
                height: 4,
                decoration: BoxDecoration(
                  color: const Color(0xFF283040),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Update Match Status',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _delayReason(match),
              style: const TextStyle(
                color: Color(0xFFA0A0A0),
                fontSize: 13,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 46,
              child: FilledButton(
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFFF4B41A),
                  foregroundColor: const Color(0xFF0E0C08),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                onPressed: () {
                  Navigator.of(sheetContext).pop();
                  _performAction(match);
                },
                child: const Text(
                  'Resume Match',
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _openSearch() async {
    final result = await showDialog<String>(
      context: context,
      builder: (dialogContext) => _SearchDialog(initialQuery: _query),
    );
    if (result == null) return;
    setState(() => _query = result.trim());
  }

  List<RefereeMatchResponse> _filtered(List<RefereeMatchResponse> source) {
    if (_query.isEmpty) return source;
    final query = _query.toLowerCase();
    return source.where((match) {
      final haystack = [
        match.displayTournament,
        match.displayTeamA,
        match.displayTeamB,
        match.displayVenue,
        match.displayRound,
        match.raw['booked_by'],
        match.raw['customer_name'],
      ].whereType<Object>().join(' ').toLowerCase();
      return haystack.contains(query);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final scale = context.sportoScale;
    return Scaffold(
      backgroundColor: const Color(0xFF090C10),
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(
                20 * scale,
                4 * scale,
                20 * scale,
                0,
              ),
              child: _MatchesHeader(
                scale: scale,
                query: _query,
                onSearch: _openSearch,
              ),
            ),
            SizedBox(height: 10 * scale),
            _MatchesTabs(
              scale: scale,
              selected: _selectedTab,
              onSelected: (index) => setState(() => _selectedTab = index),
            ),
            SizedBox(height: 10 * scale),
            Expanded(
              child: FutureBuilder<List<RefereeMatchResponse>>(
                future: _future,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return _MatchesSkeleton(scale: scale);
                  }
                  if (snapshot.hasError) {
                    return _MatchesError(
                      scale: scale,
                      message: snapshot.error.toString(),
                      onRetry: _refresh,
                    );
                  }
                  final matches = snapshot.data ?? const [];
                  final live = _filtered(
                    matches.where((match) => match.isLive).toList(),
                  );
                  final upcoming = _filtered(
                    matches.where((match) => match.isUpcoming).toList(),
                  );
                  final completed = _filtered(
                    matches.where((match) => match.isCompleted).toList(),
                  );
                  final visible = switch (_selectedTab) {
                    0 => live,
                    1 => upcoming,
                    _ => completed,
                  };

                  return RefreshIndicator(
                    onRefresh: _refresh,
                    child: visible.isEmpty
                        ? ListView(
                            physics: const AlwaysScrollableScrollPhysics(),
                            padding: EdgeInsets.fromLTRB(
                              20 * scale,
                              4 * scale,
                              20 * scale,
                              96 * scale,
                            ),
                            children: [
                              _EmptyMatches(
                                scale: scale,
                                message: switch (_selectedTab) {
                                  0 => 'No live matches right now',
                                  1 => 'No upcoming matches',
                                  _ => 'No completed matches yet',
                                },
                              ),
                            ],
                          )
                        : ListView.separated(
                            physics: const AlwaysScrollableScrollPhysics(
                              parent: BouncingScrollPhysics(),
                            ),
                            padding: EdgeInsets.fromLTRB(
                              20 * scale,
                              4 * scale,
                              20 * scale,
                              96 * scale,
                            ),
                            itemCount: visible.length,
                            separatorBuilder: (_, __) =>
                                SizedBox(height: 12 * scale),
                            itemBuilder: (context, index) {
                              final match = visible[index];
                              if (_selectedTab == 0) {
                                return _LiveMatchCard(
                                  scale: scale,
                                  match: match,
                                  onOpen: () => _performAction(match),
                                );
                              }
                              if (_selectedTab == 1) {
                                if (_isDelayed(match)) {
                                  return _DelayedMatchCard(
                                    scale: scale,
                                    match: match,
                                    onUpdate: () => _openDelayedStatus(match),
                                  );
                                }
                                return _UpcomingMatchCard(
                                  scale: scale,
                                  match: match,
                                  onAction: () => _performAction(match),
                                );
                              }
                              return _CompletedMatchCard(
                                scale: scale,
                                match: match,
                                onOpen: () => _performAction(match),
                              );
                            },
                          ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// =============================================================================
// Header + tabs
// =============================================================================
class _MatchesHeader extends StatelessWidget {
  final double scale;
  final String query;
  final VoidCallback onSearch;

  const _MatchesHeader({
    required this.scale,
    required this.query,
    required this.onSearch,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 44 * scale,
      child: Row(
        children: [
          Expanded(
            child: Text(
              'Matches',
              style: TextStyle(
                fontSize: 20 * scale,
                fontWeight: FontWeight.w700,
                color: const Color(0xFFFFFFFF),
              ),
            ),
          ),
          GestureDetector(
            onTap: onSearch,
            behavior: HitTestBehavior.opaque,
            child: Container(
              height: 32 * scale,
              constraints: BoxConstraints(maxWidth: 140 * scale),
              padding: EdgeInsets.symmetric(
                horizontal: 8 * scale,
                vertical: 6 * scale,
              ),
              decoration: BoxDecoration(
                color: const Color(0x1F767680),
                borderRadius: BorderRadius.circular(16 * scale),
                border: Border.all(color: const Color(0x14FFFFFF)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SportoSvgIcon(
                    SportoHomeRedesignIcons.search,
                    size: 20 * scale,
                  ),
                  SizedBox(width: 8 * scale),
                  Flexible(
                    child: Text(
                      query.isEmpty ? 'Search' : query,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 14 * scale,
                        fontWeight: FontWeight.w400,
                        color: const Color(0xFFA0A0A0),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MatchesTabs extends StatelessWidget {
  final double scale;
  final int selected;
  final ValueChanged<int> onSelected;

  const _MatchesTabs({
    required this.scale,
    required this.selected,
    required this.onSelected,
  });

  static const _labels = ['Live', 'Upcoming', 'Completed'];

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 34 * scale,
      padding: EdgeInsets.symmetric(horizontal: 20 * scale),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0x001B2335), Color(0x331B2335)],
        ),
        border: Border(
          bottom: BorderSide(
            color: const Color(0x14FFFFFF),
            width: 0.8 * scale,
          ),
        ),
      ),
      child: Row(
        children: [
          for (var i = 0; i < _labels.length; i++) ...[
            if (i > 0) SizedBox(width: 16 * scale),
            Flexible(
              child: GestureDetector(
                onTap: () => onSelected(i),
                behavior: HitTestBehavior.opaque,
                child: SizedBox(
                  height: 34 * scale,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (i == 0) ...[
                            Container(
                              width: 8 * scale,
                              height: 8 * scale,
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: LinearGradient(
                                  colors: [
                                    Color(0xFFFF4444),
                                    Color(0xFFFF1919),
                                  ],
                                ),
                              ),
                            ),
                            SizedBox(width: 6 * scale),
                          ],
                          Flexible(
                            child: Text(
                              _labels[i],
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 14 * scale,
                                fontWeight: selected == i
                                    ? FontWeight.w600
                                    : FontWeight.w400,
                                color: selected == i
                                    ? const Color(0xFFFFFFFF)
                                    : const Color(0xFFA0A0A0),
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 4 * scale),
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 160),
                        width: 40 * scale,
                        height: 2 * scale,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(2),
                          gradient: selected == i
                              ? const LinearGradient(
                                  colors: [
                                    Color(0xFFED7B00),
                                    Color(0xFFCF9E24),
                                  ],
                                )
                              : null,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// =============================================================================
// Cards
// =============================================================================
class _LiveMatchCard extends StatelessWidget {
  final double scale;
  final RefereeMatchResponse match;
  final VoidCallback onOpen;

  const _LiveMatchCard({
    required this.scale,
    required this.match,
    required this.onOpen,
  });

  @override
  Widget build(BuildContext context) {
    return MatchLiveScore(
      matchId: match.id,
      builder: (context, score, isLoading) {
        final runtime = score?.scoring.runtime;
        final teamA = match.teamA;
        final teamB = match.teamB;
        final scoreA = isLoading
            ? '…'
            : (teamA?.id == null
                ? (teamA?.score ?? '0/0')
                : (liveTeamScore(score, teamA!.id!) ?? teamA.score ?? '0/0'));
        final scoreB = isLoading
            ? '…'
            : (teamB?.id == null
                ? (teamB?.score ?? '0/0')
                : (liveTeamScore(score, teamB!.id!) ?? teamB.score ?? '0/0'));
        final batter = isLoading
            ? '…'
            : (runtime?.currentStriker.name?.trim().isNotEmpty == true
                ? runtime!.currentStriker.name!.trim()
                : (match.raw['current_batter']?.toString() ?? '—'));
        final bowler = isLoading
            ? '…'
            : (runtime?.currentBowler.name?.trim().isNotEmpty == true
                ? runtime!.currentBowler.name!.trim()
                : (match.raw['current_bowler']?.toString() ?? '—'));
        final over = runtime?.currentOver;
        final ball = runtime?.currentBall;
        final oversLabel =
            over == null ? '— Over' : '${over}.${ball ?? 0} Over';
        final runsRequired = runtime?.runsRequired;
        final ballsLeft = ball == null ? null : 6 - ball;
        final needText = runsRequired != null && ballsLeft != null
            ? 'Need $runsRequired Runs in $ballsLeft Ball Left'
            : 'Match in progress';

        return Container(
          width: double.infinity,
          padding: EdgeInsets.all(10 * scale),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16 * scale),
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0x33B40003),
                Color(0x33ED7B00),
                Color(0x26CF9E24),
              ],
            ),
            border: Border.all(color: const Color(0x4DF53E02)),
            boxShadow: [
              BoxShadow(
                color: const Color(0x80512813),
                blurRadius: 8 * scale,
                offset: Offset(0, 1 * scale),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    height: 22 * scale,
                    padding: EdgeInsets.symmetric(horizontal: 8 * scale),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(80 * scale),
                      gradient: const LinearGradient(
                        colors: [Color(0x0FFF9364), Color(0x0FF25F33)],
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 8 * scale,
                          height: 8 * scale,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: LinearGradient(
                              colors: [Color(0xFFFF4444), Color(0xFFFF1919)],
                            ),
                          ),
                        ),
                        SizedBox(width: 6 * scale),
                        Text(
                          'Live',
                          style: TextStyle(
                            fontSize: 12 * scale,
                            fontWeight: FontWeight.w500,
                            color: const Color(0xFFFFFFFF),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: 6 * scale),
                  Flexible(
                    child: Container(
                      height: 19 * scale,
                      padding: EdgeInsets.symmetric(horizontal: 6 * scale),
                      decoration: BoxDecoration(
                        color: const Color(0x0F2BB673),
                        borderRadius: BorderRadius.circular(10 * scale),
                      ),
                      child: Center(
                        child: Text(
                          _stage(match),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 12 * scale,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF2BB673),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const Spacer(),
                  Container(
                    height: 24 * scale,
                    padding: EdgeInsets.symmetric(horizontal: 8 * scale),
                    decoration: BoxDecoration(
                      color: const Color(0xFF090C10),
                      borderRadius: BorderRadius.circular(8 * scale),
                    ),
                    child: Center(
                      child: Text(
                        oversLabel,
                        style: TextStyle(
                          fontSize: 12 * scale,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFFFFFFFF),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 8 * scale),
              Text(
                match.displayTournament,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 14 * scale,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFFFFFFFF),
                ),
              ),
              SizedBox(height: 8 * scale),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          match.displayTeamA,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 10 * scale,
                            fontWeight: FontWeight.w500,
                            color: const Color(0xFFA0A0A0),
                          ),
                        ),
                        Text(
                          scoreA,
                          style: TextStyle(
                            fontSize: 12 * scale,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF2BB673),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 10 * scale),
                    child: Text(
                      'Vs',
                      style: TextStyle(
                        fontSize: 10 * scale,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFFAAAAAA),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          match.displayTeamB,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.right,
                          style: TextStyle(
                            fontSize: 10 * scale,
                            fontWeight: FontWeight.w500,
                            color: const Color(0xFFA0A0A0),
                          ),
                        ),
                        Text(
                          scoreB,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.right,
                          style: TextStyle(
                            fontSize: 12 * scale,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFFFFFFFF),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 6 * scale),
              _CardDivider(scale: scale),
              SizedBox(height: 6 * scale),
              Row(
                children: [
                  Expanded(
                    child: Text.rich(
                      TextSpan(
                        style: TextStyle(
                          fontSize: 12 * scale,
                          fontWeight: FontWeight.w500,
                          color: const Color(0xFFA0A0A0),
                        ),
                        children: [
                          const TextSpan(text: 'Current Batter '),
                          TextSpan(
                            text: batter,
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              color: Color(0xFFFFFFFF),
                            ),
                          ),
                        ],
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Expanded(
                    child: Text.rich(
                      textAlign: TextAlign.right,
                      TextSpan(
                        style: TextStyle(
                          fontSize: 12 * scale,
                          fontWeight: FontWeight.w500,
                          color: const Color(0xFFA0A0A0),
                        ),
                        children: [
                          const TextSpan(text: 'Current Bowler '),
                          TextSpan(
                            text: bowler,
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              color: Color(0xFFFFFFFF),
                            ),
                          ),
                        ],
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 6 * scale),
              _CardDivider(scale: scale),
              SizedBox(height: 6 * scale),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      needText,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 12 * scale,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFFAAAAAA),
                      ),
                    ),
                  ),
                  SizedBox(width: 8 * scale),
                  _GradientActionButton(
                    scale: scale,
                    label: 'Open Live Match',
                    width: 128,
                    height: 28,
                    gradient: const LinearGradient(
                      colors: [Color(0xFFDF3F00), Color(0xFFF65800)],
                    ),
                    textColor: const Color(0xFFFFFFFF),
                    onTap: onOpen,
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

class _UpcomingMatchCard extends StatelessWidget {
  final double scale;
  final RefereeMatchResponse match;
  final VoidCallback onAction;

  const _UpcomingMatchCard({
    required this.scale,
    required this.match,
    required this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    final action = resolveMatchAction(match);
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(10 * scale),
      decoration: BoxDecoration(
        color: const Color(0xFF1C2026),
        borderRadius: BorderRadius.circular(14 * scale),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _BadgePill(
                scale: scale,
                label: _stage(match),
                textColor: const Color(0xFFFFFFFF),
                background: const Color(0x3301A34D),
                border: const Color(0xFF2BB673),
              ),
              const Spacer(),
              Flexible(
                child: Text(
                  requestScheduleText(match),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 12 * scale,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFFAAAAAA),
                  ),
                ),
              ),
              const Spacer(),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: 6 * scale,
                  vertical: 2 * scale,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10 * scale),
                  gradient: const LinearGradient(
                    colors: [Color(0x1AFF9364), Color(0x1AF25F33)],
                  ),
                ),
                child: RefereeGradientText(
                  'Upcoming',
                  gradient: const LinearGradient(
                    colors: [Color(0xFFFF9364), Color(0xFFF25F33)],
                  ),
                  style: TextStyle(
                    fontSize: 12 * scale,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 8 * scale),
          Text(
            match.displayTournament,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 16 * scale,
              fontWeight: FontWeight.w600,
              color: const Color(0xFFFFFFFF),
            ),
          ),
          SizedBox(height: 2 * scale),
          Row(
            children: [
              SportoAssetIcon(
                SportoAssets.locationPin,
                size: 16 * scale,
                color: const Color(0xFFA0A0A0),
              ),
              SizedBox(width: 2 * scale),
              Expanded(
                child: Text(
                  match.displayVenue,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 12 * scale,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFFA0A0A0),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 8 * scale),
          Row(
            children: [
              Expanded(
                child: Text(
                  match.displayTeamA,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 14 * scale,
                    fontWeight: FontWeight.w400,
                    color: const Color(0xFFFFFFFF),
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 8 * scale),
                child: Text(
                  'Vs',
                  style: TextStyle(
                    fontSize: 12 * scale,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFFAAAAAA),
                  ),
                ),
              ),
              Expanded(
                child: Text(
                  match.displayTeamB,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.right,
                  style: TextStyle(
                    fontSize: 14 * scale,
                    fontWeight: FontWeight.w400,
                    color: const Color(0xFFFFFFFF),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 8 * scale),
          _CardDivider(scale: scale),
          SizedBox(height: 6 * scale),
          Row(
            children: [
              Expanded(
                child: _statusItem(
                  icon: Icons.check_rounded,
                  color: const Color(0xFF68EE76),
                  label: 'Teams Verified',
                ),
              ),
              _statusDot(),
              Expanded(
                child: _statusItem(
                  icon: Icons.check_rounded,
                  color: const Color(0xFF68EE76),
                  label: 'Ground Ready',
                ),
              ),
              _statusDot(),
              Expanded(
                child: _statusItem(
                  icon: Icons.warning_amber_rounded,
                  color: const Color(0xFFFFD31A),
                  label: 'Toss Pending',
                  textColor: const Color(0xFFA0A0A0),
                ),
              ),
            ],
          ),
          SizedBox(height: 6 * scale),
          _CardDivider(scale: scale),
          SizedBox(height: 8 * scale),
          Row(
            children: [
              Expanded(
                child: _CountdownText(
                  scale: scale,
                  start: parseMatchStart(match),
                ),
              ),
              SizedBox(width: 8 * scale),
              _GradientActionButton(
                scale: scale,
                label: _actionLabel(action),
                width: 108,
                height: 30,
                gradient: const LinearGradient(
                  colors: [Color(0xFF7AD3FF), Color(0xFF4FBAF0)],
                ),
                textColor: const Color(0xFF1B2335),
                onTap: onAction,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _statusItem({
    required IconData icon,
    required Color color,
    required String label,
    Color? textColor,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 12 * scale, color: color),
        SizedBox(width: 2 * scale),
        Flexible(
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 12 * scale,
              fontWeight: FontWeight.w400,
              color: textColor ?? color,
            ),
          ),
        ),
      ],
    );
  }

  Widget _statusDot() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 4 * scale),
      child: Container(
        width: 2 * scale,
        height: 2 * scale,
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          color: Color(0xFFA0A0A0),
        ),
      ),
    );
  }
}

class _DelayedMatchCard extends StatelessWidget {
  final double scale;
  final RefereeMatchResponse match;
  final VoidCallback onUpdate;

  const _DelayedMatchCard({
    required this.scale,
    required this.match,
    required this.onUpdate,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(10 * scale),
      decoration: BoxDecoration(
        color: const Color(0xFF1C2026),
        borderRadius: BorderRadius.circular(14 * scale),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _BadgePill(
                scale: scale,
                label: _stage(match),
                textColor: const Color(0xFFFFFFFF),
                background: const Color(0x3301A34D),
                border: const Color(0xFF2BB673),
              ),
              const Spacer(),
              Flexible(
                child: Text(
                  requestScheduleText(match),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 12 * scale,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFFAAAAAA),
                  ),
                ),
              ),
              SizedBox(width: 8 * scale),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: 6 * scale,
                  vertical: 2 * scale,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10 * scale),
                  gradient: const LinearGradient(
                    colors: [Color(0x1AFFD572), Color(0x1AFEBD38)],
                  ),
                  border: Border.all(
                    color: const Color(0x33F4B41A),
                    width: 0.5,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.warning_amber_rounded,
                      size: 14 * scale,
                      color: const Color(0xFFFFD31A),
                    ),
                    SizedBox(width: 2 * scale),
                    RefereeGradientText(
                      'Delayed',
                      gradient: const LinearGradient(
                        colors: [Color(0xFFFFD572), Color(0xFFFEBD38)],
                      ),
                      style: TextStyle(
                        fontSize: 12 * scale,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 8 * scale),
          Row(
            children: [
              Container(
                width: 8 * scale,
                height: 8 * scale,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [Color(0xFFFE6C6C), Color(0xFFFE464B)],
                  ),
                ),
              ),
              SizedBox(width: 4 * scale),
              RefereeGradientText(
                _delayReason(match),
                gradient: const LinearGradient(
                  colors: [Color(0xFFFE6C6C), Color(0xFFFE464B)],
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 14 * scale,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          SizedBox(height: 8 * scale),
          Text(
            match.displayTournament,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 16 * scale,
              fontWeight: FontWeight.w600,
              color: const Color(0xFFFFFFFF),
            ),
          ),
          SizedBox(height: 2 * scale),
          Row(
            children: [
              SportoAssetIcon(
                SportoAssets.locationPin,
                size: 16 * scale,
                color: const Color(0xFFA0A0A0),
              ),
              SizedBox(width: 2 * scale),
              Expanded(
                child: Text(
                  match.displayVenue,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 12 * scale,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFFA0A0A0),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 8 * scale),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      match.displayTeamA,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 12 * scale,
                        fontWeight: FontWeight.w400,
                        color: const Color(0xFFA0A0A0),
                      ),
                    ),
                    Text(
                      _teamScore(match.teamA),
                      style: TextStyle(
                        fontSize: 14 * scale,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFFFFFFFF),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 8 * scale),
                child: Text(
                  'Vs',
                  style: TextStyle(
                    fontSize: 12 * scale,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFFAAAAAA),
                  ),
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      match.displayTeamB,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.right,
                      style: TextStyle(
                        fontSize: 12 * scale,
                        fontWeight: FontWeight.w400,
                        color: const Color(0xFFA0A0A0),
                      ),
                    ),
                    Text(
                      _teamScore(match.teamB),
                      textAlign: TextAlign.right,
                      style: TextStyle(
                        fontSize: 14 * scale,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFFFFFFFF),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 8 * scale),
          _CardDivider(scale: scale),
          SizedBox(height: 6 * scale),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Resume Time',
                      style: TextStyle(
                        fontSize: 12 * scale,
                        fontWeight: FontWeight.w400,
                        color: const Color(0xFFA0A0A0),
                      ),
                    ),
                    Text(
                      _resumeTime(match),
                      style: TextStyle(
                        fontSize: 14 * scale,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFFFFFFFF),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(width: 8 * scale),
              _OutlineActionButton(
                scale: scale,
                label: 'Update Status',
                width: 141,
                height: 33,
                onTap: onUpdate,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _CompletedMatchCard extends StatelessWidget {
  final double scale;
  final RefereeMatchResponse match;
  final VoidCallback onOpen;

  const _CompletedMatchCard({
    required this.scale,
    required this.match,
    required this.onOpen,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onOpen,
        borderRadius: BorderRadius.circular(14 * scale),
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.all(10 * scale),
          decoration: BoxDecoration(
            color: const Color(0xFF1C2026),
            borderRadius: BorderRadius.circular(14 * scale),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  _BadgePill(
                    scale: scale,
                    label: _stage(match),
                    textColor: const Color(0xFFFFFFFF),
                    background: const Color(0x332BB673),
                    border: const Color(0xFF2BB673),
                  ),
                  const Spacer(),
                  Flexible(
                    child: Text(
                      requestScheduleText(match),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 12 * scale,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFFAAAAAA),
                      ),
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 6 * scale,
                      vertical: 2 * scale,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10 * scale),
                      gradient: const LinearGradient(
                        colors: [Color(0x1A7AD3FF), Color(0x1A4FBAF0)],
                      ),
                    ),
                    child: RefereeGradientText(
                      'Completed',
                      gradient: const LinearGradient(
                        colors: [Color(0xFF7AD3FF), Color(0xFF4FBAF0)],
                      ),
                      style: TextStyle(
                        fontSize: 12 * scale,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 8 * scale),
              Text(
                match.displayTournament,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 16 * scale,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFFFFFFFF),
                ),
              ),
              SizedBox(height: 2 * scale),
              Row(
                children: [
                  SportoAssetIcon(
                    SportoAssets.locationPin,
                    size: 16 * scale,
                    color: const Color(0xFFA0A0A0),
                  ),
                  SizedBox(width: 2 * scale),
                  Expanded(
                    child: Text(
                      match.displayVenue,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 12 * scale,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFFA0A0A0),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 8 * scale),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          match.displayTeamA,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 12 * scale,
                            fontWeight: FontWeight.w400,
                            color: const Color(0xFFA0A0A0),
                          ),
                        ),
                        RefereeGradientText(
                          _teamScore(match.teamA),
                          gradient: const LinearGradient(
                            colors: [Color(0xFF99FFA3), Color(0xFF68EE76)],
                          ),
                          style: TextStyle(
                            fontSize: 14 * scale,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8 * scale),
                    child: Text(
                      'Vs',
                      style: TextStyle(
                        fontSize: 12 * scale,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFFAAAAAA),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          match.displayTeamB,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.right,
                          style: TextStyle(
                            fontSize: 12 * scale,
                            fontWeight: FontWeight.w400,
                            color: const Color(0xFFA0A0A0),
                          ),
                        ),
                        Text(
                          _teamScore(match.teamB),
                          textAlign: TextAlign.right,
                          style: TextStyle(
                            fontSize: 14 * scale,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFFFFFFFF),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 8 * scale),
              _CardDivider(scale: scale),
              SizedBox(height: 6 * scale),
              Row(
                children: [
                  Container(
                    width: 8 * scale,
                    height: 8 * scale,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: [Color(0xFF99FFA3), Color(0xFF68EE76)],
                      ),
                    ),
                  ),
                  SizedBox(width: 4 * scale),
                  Expanded(
                    child: RefereeGradientText(
                      _winnerLabel(match),
                      gradient: const LinearGradient(
                        colors: [Color(0xFF99FFA3), Color(0xFF68EE76)],
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 14 * scale,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  SizedBox(width: 8 * scale),
                  _OutlineActionButton(
                    scale: scale,
                    label: 'View Report',
                    width: 101,
                    height: 30,
                    onTap: onOpen,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// =============================================================================
// Small shared pieces
// =============================================================================
class _BadgePill extends StatelessWidget {
  final double scale;
  final String label;
  final Color textColor;
  final Color background;
  final Color border;

  const _BadgePill({
    required this.scale,
    required this.label,
    required this.textColor,
    required this.background,
    required this.border,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 19 * scale,
      padding: EdgeInsets.symmetric(horizontal: 6 * scale),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(10 * scale),
        border: Border.all(color: border, width: 0.8),
      ),
      child: Center(
        child: Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: 12 * scale,
            fontWeight: FontWeight.w600,
            color: textColor,
            height: 1.0,
          ),
        ),
      ),
    );
  }
}

class _CardDivider extends StatelessWidget {
  final double scale;

  const _CardDivider({required this.scale});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 0.8 * scale,
      color: const Color(0xFF283040),
    );
  }
}

class _GradientActionButton extends StatelessWidget {
  final double scale;
  final String label;
  final double width;
  final double height;
  final Gradient gradient;
  final Color textColor;
  final VoidCallback onTap;

  const _GradientActionButton({
    required this.scale,
    required this.label,
    required this.width,
    required this.height,
    required this.gradient,
    required this.textColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width * scale,
      height: height * scale,
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(10 * scale),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(10 * scale),
          child: Center(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 14 * scale,
                fontWeight: FontWeight.w600,
                color: textColor,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _OutlineActionButton extends StatelessWidget {
  final double scale;
  final String label;
  final double width;
  final double height;
  final VoidCallback onTap;

  const _OutlineActionButton({
    required this.scale,
    required this.label,
    required this.width,
    required this.height,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width * scale,
      height: height * scale,
      decoration: BoxDecoration(
        color: const Color(0x66283040),
        borderRadius: BorderRadius.circular(10 * scale),
        border: Border.all(color: const Color(0xFF283040)),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(10 * scale),
          child: Center(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 14 * scale,
                fontWeight: FontWeight.w500,
                color: const Color(0xFFFFFFFF),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _CountdownText extends StatefulWidget {
  final double scale;
  final DateTime? start;

  const _CountdownText({required this.scale, required this.start});

  @override
  State<_CountdownText> createState() => _CountdownTextState();
}

class _CountdownTextState extends State<_CountdownText> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final start = widget.start;
    final now = DateTime.now();
    final diff = start == null ? null : start.difference(now);
    String value;
    if (diff == null || diff.isNegative) {
      value = '--:--:--';
    } else {
      final hours = diff.inHours.toString().padLeft(2, '0');
      final minutes = (diff.inMinutes % 60).toString().padLeft(2, '0');
      final seconds = (diff.inSeconds % 60).toString().padLeft(2, '0');
      value = '$hours:$minutes:$seconds';
    }
    return Text.rich(
      TextSpan(
        style: TextStyle(
          fontSize: 14 * widget.scale,
          fontWeight: FontWeight.w500,
          color: const Color(0xFFFFFFFF),
        ),
        children: [
          const TextSpan(text: 'Starts in '),
          TextSpan(
            text: value,
            style: const TextStyle(
              fontWeight: FontWeight.w700,
              color: Color(0xFF2BB673),
            ),
          ),
        ],
      ),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
  }
}

class _EmptyMatches extends StatelessWidget {
  final double scale;
  final String message;

  const _EmptyMatches({required this.scale, required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(vertical: 34 * scale),
      decoration: BoxDecoration(
        color: const Color(0xFF1C2026),
        borderRadius: BorderRadius.circular(14 * scale),
      ),
      child: Column(
        children: [
          Icon(
            Icons.event_note_rounded,
            size: 32 * scale,
            color: const Color(0xFF666666),
          ),
          SizedBox(height: 10 * scale),
          Text(
            message,
            style: TextStyle(
              fontSize: 14 * scale,
              fontWeight: FontWeight.w500,
              color: const Color(0xFFA0A0A0),
            ),
          ),
        ],
      ),
    );
  }
}

class _MatchesError extends StatelessWidget {
  final double scale;
  final String message;
  final Future<void> Function() onRetry;

  const _MatchesError({
    required this.scale,
    required this.message,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(24 * scale),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Unable to load matches',
              style: TextStyle(
                color: const Color(0xFFFFFFFF),
                fontSize: 16 * scale,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 6 * scale),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: const Color(0xFFA0A0A0),
                fontSize: 12 * scale,
              ),
            ),
            SizedBox(height: 16 * scale),
            FilledButton(
              onPressed: onRetry,
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}

class _MatchesSkeleton extends StatelessWidget {
  final double scale;

  const _MatchesSkeleton({required this.scale});

  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: const NeverScrollableScrollPhysics(),
      padding: EdgeInsets.fromLTRB(
        20 * scale,
        4 * scale,
        20 * scale,
        96 * scale,
      ),
      children: [
        for (var i = 0; i < 2; i++) ...[
          Container(
            height: (i == 0 ? 180 : 168) * scale,
            decoration: BoxDecoration(
              color: const Color(0xFF1C2026),
              borderRadius: BorderRadius.circular(14 * scale),
            ),
          ),
          SizedBox(height: 12 * scale),
        ],
      ],
    );
  }
}

class _SearchDialog extends StatefulWidget {
  final String initialQuery;

  const _SearchDialog({required this.initialQuery});

  @override
  State<_SearchDialog> createState() => _SearchDialogState();
}

class _SearchDialogState extends State<_SearchDialog> {
  late final TextEditingController _controller =
      TextEditingController(text: widget.initialQuery);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: const Color(0xFF1C2026),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      title: const Text(
        'Search Matches',
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w700,
        ),
      ),
      content: TextField(
        controller: _controller,
        autofocus: true,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          hintText: 'Tournament, team or venue',
          hintStyle: const TextStyle(color: Color(0xFF666666)),
          filled: true,
          fillColor: const Color(0xFF0E1218),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
        ),
        onSubmitted: (value) => Navigator.of(context).pop(value),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(_controller.text),
          child: const Text('Search'),
        ),
      ],
    );
  }
}

// =============================================================================
// Match data helpers
// =============================================================================
String _stage(RefereeMatchResponse match) {
  for (final value in [
    match.roundName,
    match.matchNumber,
    match.raw['round_name'],
    match.raw['stage'],
  ]) {
    final text = value?.toString().trim() ?? '';
    if (text.isNotEmpty) return text;
  }
  return 'Match';
}

bool _isDelayed(RefereeMatchResponse match) {
  final label = match.statusLabel?.toLowerCase() ?? '';
  final state = match.raw['state']?.toString().toLowerCase() ?? '';
  return label.contains('delay') ||
      state == 'delayed' ||
      match.raw['delay_reason'] != null;
}

String _delayReason(RefereeMatchResponse match) {
  for (final value in [
    match.raw['delay_reason'],
    match.raw['weather'],
    match.raw['delay_reason_text'],
  ]) {
    final text = value?.toString().trim() ?? '';
    if (text.isNotEmpty) return text;
  }
  return 'Heavy Rain';
}

String _resumeTime(RefereeMatchResponse match) {
  for (final value in [
    match.raw['resume_time'],
    match.raw['resume_at'],
    match.startTime,
  ]) {
    final text = value?.toString().trim() ?? '';
    if (text.isNotEmpty) return text;
  }
  return '—';
}

String _teamScore(RefereeMatchTeam? team) {
  final score = team?.score?.trim() ?? '';
  return score.isEmpty ? '—' : score;
}

String _winnerLabel(RefereeMatchResponse match) {
  for (final value in [
    match.raw['winner_team_name'],
    match.raw['winner_name'],
    match.raw['winner'],
  ]) {
    final text = value?.toString().trim() ?? '';
    if (text.isNotEmpty) {
      return text.toLowerCase().endsWith('won') ? text : '$text Won';
    }
  }
  final a = _parseScore(match.teamA?.score);
  final b = _parseScore(match.teamB?.score);
  if (a != null && b != null && a != b) {
    final name = a > b ? match.displayTeamA : match.displayTeamB;
    return '$name Won';
  }
  return 'Match Completed';
}

int? _parseScore(String? score) {
  if (score == null || score.trim().isEmpty) return null;
  return int.tryParse(score.split('/').first.trim());
}

String _actionLabel(MatchActionResult resolved) {
  return switch (resolved.action) {
    MatchAction.continueScoring => 'Continue Scoring',
    MatchAction.startScoring => 'Start Scoring',
    MatchAction.viewReport => 'View Report',
    MatchAction.toss => 'Conduct Toss',
    MatchAction.verify => 'Verify Teams',
    MatchAction.blocked => 'Unavailable',
  };
}
