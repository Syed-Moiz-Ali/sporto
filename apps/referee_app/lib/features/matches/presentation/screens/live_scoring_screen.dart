import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:referee_data/referee_data.dart';
import 'package:ui_kit/ui_kit.dart';

import '../../../../app/router/app_router.dart';
import '../../../../core/di/dependency_injector.dart';
import '../../application/live_scoring/live_scoring_bloc.dart';
import 'referee_scoring_tab_screen.dart';

// ============================================================
// LIVE SCORING SCREEN
// ============================================================

class LiveScoringScreen extends StatefulWidget {
  final String? matchId;
  final String? matchCode;

  /// Innings over limit. 0 means "not provided" — the UI then shows no over
  /// limit. The authoritative value comes from the API
  /// (`scoring.overs_per_innings`) and always wins.
  final int totalOvers;

  const LiveScoringScreen({
    super.key,
    this.matchId,
    this.matchCode,
    this.totalOvers = 0,
  });

  @override
  State<LiveScoringScreen> createState() => _LiveScoringScreenState();
}

class _LiveScoringScreenState extends State<LiveScoringScreen> {
  late final Future<RefereeScoreResponse?> _scoreFuture;

  RefereeRemoteDataSource get _remote =>
      DependencyInjector.instance.refereeRemoteDataSource;

  @override
  void initState() {
    super.initState();
    _scoreFuture = _loadScoreConfig();
  }

  Future<RefereeScoreResponse?> _loadScoreConfig() async {
    final numericMatchId = int.tryParse(widget.matchId ?? '');
    if (numericMatchId == null) return null;
    try {
      return await _remote.getMatchScoreData(numericMatchId);
    } catch (_) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.matchId == null || widget.matchId!.isEmpty) {
      return RefereeScoringTabScreen(
        onNavigateToScoring: (matchId, matchCode) {
          context.push(
            '${AppRouter.liveScoringPath}?matchId=$matchId&matchCode=$matchCode',
          );
        },
      );
    }

    return FutureBuilder<RefereeScoreResponse?>(
      future: _scoreFuture,
      builder: (context, snapshot) {
        final scoreConfig = snapshot.data;
        if (scoreConfig == null) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              backgroundColor: Color(0xFF0E0C08),
              body: Center(
                child: CircularProgressIndicator(color: Color(0xFFED7B00)),
              ),
            );
          }
          return Scaffold(
            backgroundColor: const Color(0xFF0E0C08),
            appBar: AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
                onPressed: () {
                  if (context.canPop()) {
                    context.pop();
                  }
                },
              ),
            ),
            body: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Unable to load live match data.',
                    style: TextStyle(
                      color: Color(0xFFAAAAAA),
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _scoreFuture = _loadScoreConfig();
                      });
                    },
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
        final teams = _teamsFromScore(scoreConfig);
        final scoringRuntime = scoreConfig.scoring.runtime;
        final tossRuntime = scoreConfig.toss?.runtime;
        final inningsNumber = scoringRuntime.currentInning ?? 1;
        final currentBattingTeamId =
            scoringRuntime.currentBattingTeamId?.toString();
        final currentBowlingTeamId =
            scoringRuntime.currentBowlingTeamId?.toString();
        // Before START the runtime has no teams yet; resolve the innings-1
        // batting side from the toss result (winner + decision) so the
        // correct roster is shown for openers.
        String? tossBattingTeamId() {
          final winnerId = tossRuntime?.winnerTeamId;
          final decision = tossRuntime?.decision;
          if (winnerId == null || decision == null) return null;
          final winner = winnerId.toString();
          if (decision == RefereeTossDecisions.batFirst) return winner;
          if (decision == RefereeTossDecisions.bowlFirst) {
            return winner == teams.$1.id ? teams.$2.id : teams.$1.id;
          }
          return null;
        }

        // The bloc's firstBattingTeamId is the innings-1 batting team. When
        // resuming during innings 2, that is the team currently bowling.
        final firstBattingTeamId = inningsNumber == 2 &&
                currentBattingTeamId != null &&
                currentBowlingTeamId != null
            ? currentBowlingTeamId
            : currentBattingTeamId ??
                tossBattingTeamId() ??
                tossRuntime?.battingTeamId?.toString() ??
                teams.$1.id;
        final initialStrikerId =
            scoringRuntime.currentStriker.userId?.toString() ??
                tossRuntime?.startingUserId(RefereeStartingRoles.striker)
                    ?.toString();
        final initialNonStrikerId =
            scoringRuntime.currentNonStriker.userId?.toString() ??
                tossRuntime?.startingUserId(RefereeStartingRoles.nonStriker)
                    ?.toString();
        final initialBowlerId =
            scoringRuntime.currentBowler.userId?.toString() ??
                tossRuntime?.startingUserId(RefereeStartingRoles.openingBowler)
                    ?.toString();

        return BlocProvider(
          create: (_) {
            final bloc = LiveScoringBloc(
              teamA: teams.$1,
              teamB: teams.$2,
              firstBattingTeamId: firstBattingTeamId,
              initialInningsNumber: inningsNumber,
              initialFirstInningsRuns: inningsNumber == 2
                  ? scoreConfig.scoring.teamScore(firstBattingTeamId)
                  : null,
              regulationOvers:
                  scoreConfig.scoring.oversPerInnings ?? widget.totalOvers,
              maxWickets: _maxWicketsFor(teams),
              initialStrikerId: initialStrikerId,
              initialNonStrikerId: initialNonStrikerId,
              initialBowlerId: initialBowlerId,
              initialRuns: scoreConfig.scoring.teamScore(
                currentBattingTeamId ?? firstBattingTeamId,
              ),
            );
            // Seed the bloc from the authoritative server state and let it
            // derive the correct screen from runtime flags/events.
            bloc.add(ApplyServerScoreEvent(scoreConfig));
            return bloc;
          },
          child: _LiveScoringView(
            matchId: widget.matchId!,
            matchCode: widget.matchCode ?? 'Match ${widget.matchId}',
            scoreConfig: scoreConfig,
          ),
        );
      },
    );
  }

  (ScoringTeam, ScoringTeam) _teamsFromScore(RefereeScoreResponse? score) {
    if (score == null || score.teams.length < 2) {
      return (
        const ScoringTeam(id: '', name: '', bowlers: []),
        const ScoringTeam(id: '', name: '', bowlers: []),
      );
    }
    return (
      _teamFromScore(score.teams[0]),
      _teamFromScore(score.teams[1]),
    );
  }

  int _maxWicketsFor((ScoringTeam, ScoringTeam) teams) {
    final teamAPlayers = teams.$1.bowlers.length;
    final teamBPlayers = teams.$2.bowlers.length;
    final players = teamAPlayers > teamBPlayers ? teamAPlayers : teamBPlayers;
    return players > 0 ? players - 1 : 0;
  }

  ScoringTeam _teamFromScore(RefereeScoreTeamResponse team) {
    final players = team.players
        .map((player) => ScoringBowler(
              id: player.userId.toString(),
              name: player.name,
            ))
        .toList();
    return ScoringTeam(
      id: team.id.toString(),
      name: team.name,
      bowlers: players,
    );
  }
}

// ============================================================
// MAIN VIEW
// ============================================================

class _LiveScoringView extends StatelessWidget {
  final String matchId;
  final String matchCode;
  final RefereeScoreResponse? scoreConfig;
  final ValueNotifier<bool> _scoreApiLoading = ValueNotifier<bool>(false);

  _LiveScoringView({
    required this.matchId,
    required this.matchCode,
    required this.scoreConfig,
  });

  bool _isActionAllowed(BuildContext context, String action) {
    // Empty means nothing is allowed (e.g. pre-toss PENDING) — never
    // treat "no data" as "everything allowed".
    final actions = context.read<LiveScoringBloc>().state.allowedActions;
    return actions.contains(action);
  }

  bool _matchAlreadyLive(BuildContext context) =>
      context.read<LiveScoringBloc>().state.matchLive;

  RefereeRemoteDataSource get _remote =>
      DependencyInjector.instance.refereeRemoteDataSource;

  bool get _scoreApiEnabled => scoreConfig?.scoring.enabled ?? true;
  bool get _readOnly => scoreConfig?.isReadOnly ?? false;
  Set<String> get _availableEventCodes => {
        for (final event in scoreConfig?.scoring.availableEvents ?? const [])
          event.code,
      };
  List<int> get _allowedRunValues {
    for (final event in scoreConfig?.scoring.availableEvents ?? const []) {
      if (event.code == RefereeCricketEventCodes.run &&
          event.allowedValues.isNotEmpty) {
        return event.allowedValues;
      }
    }
    // No values are invented locally; without config the run buttons are
    // hidden and the UI relies on available_events from the backend.
    return const [];
  }

  int? get _numericMatchId => int.tryParse(matchId);

  Future<bool> _syncScore(
    BuildContext context,
    RefereeScoreUpdateRequest request,
  ) async {
    final numericMatchId = _numericMatchId;
    if (scoreConfig == null || numericMatchId == null) return true;
    if (_readOnly) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('This match is read-only.')),
      );
      return false;
    }
    if (!_scoreApiEnabled) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Scoring API is disabled for this match.')),
      );
      return false;
    }
    _scoreApiLoading.value = true;
    try {
      final response =
          await _remote.updateMatchScoreData(numericMatchId, request);
      _applyServerScoreState(context, response);
      return true;
    } catch (error) {
      // Reconcile with the authoritative backend state (e.g. on HTTP 409).
      var recoveredLiveStart = false;
      try {
        final fresh = await _remote.getMatchScoreData(numericMatchId);
        _applyServerScoreState(context, fresh);
        recoveredLiveStart =
            request.body['action'] == RefereeScoreActions.start &&
            (fresh.isLive || fresh.scoring.runtime.state == 'LIVE');
      } catch (_) {}
      if (context.mounted && !recoveredLiveStart) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Score sync failed: $error')),
        );
      }
      return false;
    } finally {
      _scoreApiLoading.value = false;
    }
  }

  Future<void> _reload(BuildContext context) async {
    final numericMatchId = _numericMatchId;
    if (numericMatchId == null) return;
    try {
      final fresh = await _remote.getMatchScoreData(numericMatchId);
      _applyServerScoreState(context, fresh);
    } catch (error) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Reload failed: $error')),
        );
      }
    }
  }

  Widget _missingStepData(BuildContext context) {
    final scale = context.sportoScale;
    return Column(
      children: [
        SizedBox(height: 30 * scale),
        const SportoLiveNoticeBar(
          text: 'Match data is incomplete. Refresh to sync the latest state.',
        ),
        SizedBox(height: 16 * scale),
        SportoLivePrimaryButton(
          text: 'Refresh',
          onTap: () => _reload(context),
        ),
      ],
    );
  }

  void _applyServerScoreState(
    BuildContext context,
    RefereeScoreResponse? response,
  ) {
    if (response == null) return;
    // The bloc keeps allowed_actions / match-live in its state so gating
    // survives widget rebuilds; just forward the authoritative response.
    if (context.mounted) {
      context.read<LiveScoringBloc>().add(ApplyServerScoreEvent(response));
    }
  }

  int? _teamId(String teamId) => int.tryParse(teamId);

  int? _selectedPlayerId(LiveScoringState state, String eventCode) {
    final requiresPlayer = scoreConfig?.scoring.availableEvents
        .where((event) => event.code == eventCode)
        .map((event) => event.requiresPlayer)
        .firstWhere((value) => true,
            orElse: () =>
          eventCode == RefereeCricketEventCodes.run ||
          eventCode == RefereeCricketEventCodes.wicket);
    if (requiresPlayer != true) return null;
    final playerId =
        eventCode == RefereeCricketEventCodes.run ||
                eventCode == RefereeCricketEventCodes.wicket
            ? state.strikerId
            : state.selectedBowlerId;
    return int.tryParse(playerId ?? '');
  }

  Future<void> _startOver(BuildContext context) async {
    if (_scoreApiLoading.value) return;
    final state = context.read<LiveScoringBloc>().state;
    final bowlerId = int.tryParse(state.selectedBowlerId ?? '');
    if (bowlerId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Select a valid bowler first.')),
      );
      return;
    }
    if (state.currentOverIndex == 0 && !_matchAlreadyLive(context)) {
      if (!_isActionAllowed(context, RefereeScoreActions.start)) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Cannot start the match yet.'),
          ),
        );
        return;
      }
      final started = await _syncScore(
        context,
        RefereeScoreUpdateRequest.start(),
      );
      if (!context.mounted) return;
      // A 409 here means the backend already started the match (e.g. the
      // screen held a stale snapshot after resume). The reconciliation GET
      // inside _syncScore marks the match live, so continue into scoring.
      if (!started && !_matchAlreadyLive(context)) return;
    }

    final strikerId = int.tryParse(state.strikerId ?? '');
    final nonStrikerId = int.tryParse(state.nonStrikerId ?? '');
    if (strikerId == null || nonStrikerId == null || strikerId == nonStrikerId) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Select both batters first.')),
      );
      return;
    }

    // START reveals the authoritative teams. Make sure the locally selected
    // players belong to the correct sides before pushing SET_BATTERS.
    await Future<void>.delayed(Duration.zero);
    if (!context.mounted) return;
    final refreshed = context.read<LiveScoringBloc>().state;
    final battingRoster =
        refreshed.currentBattingTeam.bowlers.map((p) => p.id).toSet();
    final bowlingRoster =
        refreshed.currentBowlingTeam.bowlers.map((p) => p.id).toSet();
    if (!battingRoster.contains(strikerId.toString()) ||
        !battingRoster.contains(nonStrikerId.toString()) ||
        !bowlingRoster.contains(bowlerId.toString())) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'The batting side has changed. Please re-select batters and bowler.',
          ),
        ),
      );
      return;
    }

    final battersSynced = await _syncScore(
      context,
      RefereeScoreUpdateRequest.setBatters(
        strikerUserId: strikerId,
        nonStrikerUserId: nonStrikerId,
      ),
    );
    if (!context.mounted || !battersSynced) return;

    // Bowler selection is a server-side scoring action. Persist it before
    // entering the over so ADD_EVENT uses the backend's current bowler.
    final bowlerSynced = await _syncScore(
      context,
      RefereeScoreUpdateRequest.setBowler(bowlerUserId: bowlerId),
    );
    if (!context.mounted || !bowlerSynced) return;
    context.read<LiveScoringBloc>().add(StartSelectedOverEvent());
  }

  /// WICKET requires a dismissal type from the backend; ask the referee
  /// before sending the event.
  Future<void> _pickWicketType(
    BuildContext context,
    LiveScoringState state,
  ) async {
    final type = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: const Color(0xFF12161C),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
      ),
      builder: (sheetContext) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 18, 8, 4),
              child: Row(
                children: [
                  const Expanded(
                    child: Text(
                      'How was the batter out?',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(sheetContext).pop(),
                    icon: const Icon(
                      Icons.close_rounded,
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
            ),
            ...RefereeWicketTypes.selectable.map(
              (option) => ListTile(
                title: Text(
                  option.label,
                  style: const TextStyle(color: Colors.white, fontSize: 15),
                ),
                onTap: () => Navigator.of(sheetContext).pop(option.code),
              ),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );

    if (type == null || !context.mounted) return;
    await _addScoreEvent(
      context,
      state,
      eventCode: RefereeCricketEventCodes.wicket,
      wicketType: type,
    );
  }

  Future<void> _addScoreEvent(
    BuildContext context,
    LiveScoringState state, {
    required String eventCode,
    int? value,
    String? wicketType,
  }) async {
    if (_scoreApiLoading.value) return;
    RefereeScoreEventResponse? configuredEvent;
    if (!_isActionAllowed(context, RefereeScoreActions.addEvent)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Scoring is not allowed right now.'),
        ),
      );
      return;
    }
    for (final event in scoreConfig?.scoring.availableEvents ?? const []) {
      if (event.code == eventCode) {
        configuredEvent = event;
        break;
      }
    }
    if (scoreConfig != null &&
        scoreConfig!.scoring.availableEvents.isNotEmpty &&
        configuredEvent == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('$eventCode is not available for this match.')),
      );
      return;
    }
    if (configuredEvent != null &&
        configuredEvent.allowedValues.isNotEmpty &&
        value != null &&
        !configuredEvent.allowedValues.contains(value)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Invalid value for $eventCode.')),
      );
      return;
    }
    final teamId = _teamId(state.currentBattingTeam.id);
    if (teamId == null) return;
    final playerId = _selectedPlayerId(state, eventCode);
    if (configuredEvent?.requiresPlayer == true && playerId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Set the striker and bowler before scoring.'),
        ),
      );
      return;
    }
    final synced = await _syncScore(
      context,
      RefereeScoreUpdateRequest.addEvent(
        eventCode: eventCode,
        teamId: teamId,
        playerId: playerId,
        value: value,
        wicketType: wicketType,
      ),
    );
    if (!context.mounted || !synced) return;
    // The backend applies the ball (score, ball count, strike rotation,
    // wickets, over completion) and the returned state is applied above.
  }

  Future<void> _endPeriod(BuildContext context) async {
    if (_scoreApiLoading.value) return;
    if (!_isActionAllowed(context, RefereeScoreActions.endPeriod)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Cannot end the period right now.'),
        ),
      );
      return;
    }
    await _syncScore(
      context,
      RefereeScoreUpdateRequest.endPeriod(),
    );
  }

  Future<void> _startSuperOver(BuildContext context) async {
    if (_scoreApiLoading.value) return;
    await _syncScore(
      context,
      RefereeScoreUpdateRequest.startSuperOver(),
    );
  }

  Future<void> _complete(BuildContext context) async {
    if (_scoreApiLoading.value) return;
    // COMPLETE is only advertised once every period is closed. When the
    // second innings was finished locally the current period may still be
    // open, so close it first and then complete.
    var synced = await _syncScore(
      context,
      RefereeScoreUpdateRequest.complete(),
    );
    if (!context.mounted) return;
    if (!synced) {
      final endSynced = await _syncScore(
        context,
        RefereeScoreUpdateRequest.endPeriod(),
      );
      if (!context.mounted || !endSynced) return;
      synced = await _syncScore(
        context,
        RefereeScoreUpdateRequest.complete(),
      );
      if (!context.mounted || !synced) return;
    }
    context.read<LiveScoringBloc>().add(SubmitFinalResultEvent());
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<LiveScoringBloc, LiveScoringState>(
      listener: (context, state) {
        // Add API/save-error listener here later if needed.
      },
      builder: (context, state) {
        final submitted = state.step == LiveScoringStep.resultSubmitted;

        final finalResult = state.step == LiveScoringStep.finalResult ||
            state.step == LiveScoringStep.superOverFinalResult;

        // Guard accidental back-outs while the match is LIVE. Resume is
        // always safe: the backend holds the authoritative state.
        final needsGuard = state.matchLive &&
            state.step != LiveScoringStep.resultSubmitted;

        return PopScope(
          canPop: !needsGuard,
          onPopInvokedWithResult: (didPop, result) {
            if (!didPop && needsGuard) {
              _confirmExit(context);
            }
          },
          child: SportoScreenShell(
          body: SafeArea(
            bottom: false,
            child: SingleChildScrollView(
              physics: const ClampingScrollPhysics(),
              padding: EdgeInsets.fromLTRB(
                20 * context.sportoScale,

                // Result submitted screenshot does not
                // contain the normal header.
                submitted ? 26 * context.sportoScale : 10 * context.sportoScale,

                20 * context.sportoScale,

                40 * context.sportoScale,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ===========================================
                  // HEADER
                  // ===========================================

                  if (!submitted) ...[
                    SportoLiveScoringHeader(
                      title:
                          finalResult ? 'Final Result' : 'Cricket Score Entry',
                      matchId: matchCode,
                      onBack: () {
                        if (context.canPop()) {
                          context.pop();
                        }
                      },
                    ),
                    SizedBox(
                      height: 23 * context.sportoScale,
                    ),
                    if (scoreConfig != null && !_scoreApiEnabled) ...[
                      const SportoLiveNoticeBar(
                        text: 'Scoring is disabled for this match by backend.',
                      ),
                      SizedBox(
                        height: 16 * context.sportoScale,
                      ),
                    ],
                  ],

                  // ===========================================
                  // CURRENT STEP
                  // ===========================================

                  AnimatedSwitcher(
                    duration: const Duration(
                      milliseconds: 220,
                    ),
                    switchInCurve: Curves.easeOutCubic,
                    switchOutCurve: Curves.easeInCubic,
                    child: KeyedSubtree(
                      key: ValueKey(
                        '${state.step}-'
                        '${state.inningsNumber}-'
                        '${state.superOverInningsNumber}-'
                        '${state.currentOverIndex}',
                      ),
                      child: ValueListenableBuilder<bool>(
                        valueListenable: _scoreApiLoading,
                        builder: (context, loading, _) => _buildStep(
                          context,
                          state,
                          apiLoading: loading,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
      },
    );
  }

  Future<void> _confirmExit(BuildContext context) async {
    final leave = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: const Color(0xFF1C2026),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Text(
          'Leave live scoring?',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        content: const Text(
          'The match is LIVE. Your progress is safe — the backend keeps '
          'the authoritative state and you can resume from Matches.',
          style: TextStyle(color: Color(0xFFAAAAAA)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Stay'),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text(
              'Leave',
              style: TextStyle(color: Color(0xFFFE464B)),
            ),
          ),
        ],
      ),
    );
    if (leave == true && context.mounted && context.canPop()) {
      context.pop();
    }
  }

  // ==========================================================
  // STEP ROUTER
  // ==========================================================

  Widget _buildStep(
    BuildContext context,
    LiveScoringState state, {
    bool apiLoading = false,
  }
  ) {
    switch (state.step) {
      case LiveScoringStep.selectBowler:
        return _selectBowler(
          context,
          state,
          apiLoading: apiLoading,
        );

      case LiveScoringStep.scoring:
        return _scoring(
          context,
          state,
        );

      case LiveScoringStep.overComplete:
        return _overComplete(
          context,
          state,
        );

      case LiveScoringStep.inningsBreak:
        return _inningsBreak(
          context,
          state,
        );

      case LiveScoringStep.finalResult:
        return _normalFinalResult(
          context,
          state,
        );

      case LiveScoringStep.superOverReady:
        return _superOverReady(
          context,
          state,
        );

      case LiveScoringStep.superOverSelectBowler:
        return _superOverSelectBowler(
          context,
          state,
        );

      case LiveScoringStep.superOverScoring:
        return _scoring(
          context,
          state,
        );

      case LiveScoringStep.superOverComplete:
        return _superOverComplete(
          context,
          state,
        );

      case LiveScoringStep.superOverBreak:
        return _superOverBreak(
          context,
          state,
        );

      case LiveScoringStep.superOverFinalResult:
        return _superOverFinalResult(
          context,
          state,
        );

      case LiveScoringStep.resultSubmitted:
        return _resultSubmitted(
          context,
          state,
        );
    }
  }

  // ==========================================================
  // COMMON MATCH CARD
  // ==========================================================

  Widget _matchCard(
    LiveScoringState state, {
    bool compact = false,
    bool showScores = false,
  }) {
    return _FigmaScoringLiveMatchCard(
      tournament: scoreConfig?.tournamentName ??
          scoreConfig?.formatName ??
          matchCode,
      location: scoreConfig?.venueName ?? '',
      battingTeam: state.currentBattingTeam.name,
      bowlingTeam: state.currentBowlingTeam.name,
      compact: compact,
      showScores: showScores,
      battingScore: showScores ? state.scoreText : null,
      bowlingScore: showScores ? _opponentScore(state) : null,
      oversText: 'Over - ${state.progressText}',
      currentBowler: state.currentBowlerName,
    );
  }

  String _opponentScore(
    LiveScoringState state,
  ) {
    // ========================================================
    // SUPER OVER
    // ========================================================

    if (state.isSuperOver) {
      if (state.superOverInningsNumber == 2 &&
          state.firstSuperOverInnings != null) {
        return state.firstSuperOverInnings!.scoreText;
      }

      return 'Yet to Bat';
    }

    // ========================================================
    // SECOND REGULATION INNINGS
    // ========================================================

    if (state.inningsNumber == 2 && state.firstInnings != null) {
      return state.firstInnings!.scoreText;
    }

    return 'Yet to Bat';
  }

  // ==========================================================
  // SELECT BOWLER
  // ==========================================================

  Widget _selectBowler(
    BuildContext context,
    LiveScoringState state, {
    bool apiLoading = false,
  }
  ) {
    final scale = context.sportoScale;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ===========================================
        // MATCH
        // ===========================================

        _matchCard(state),

        SizedBox(
          height: 21 * scale,
        ),

        // ===========================================
        // SCORE
        // ===========================================

        SportoLiveScoreCard(
          title: state.currentBattingTeam.name,
          score: state.scoreText,
          progress: state.progressText,
          height: 143,
        ),

        // ===========================================
        // SECOND INNINGS TARGET
        // ===========================================

        if (!state.isSuperOver &&
            state.inningsNumber == 2 &&
            state.target != null) ...[
          SizedBox(
            height: 12 * scale,
          ),
          SportoLiveNoticeBar(
            text: 'Target ${state.target}  •  '
                '${state.runsRequired} runs required',
          ),
        ],

        SizedBox(
          height: 21 * scale,
        ),

        // ===========================================
        // STEPPED SELECTION: openers -> continue -> bowler
        // ===========================================

        _BowlerSelectionStep(
          state: state,
          apiLoading: apiLoading,
          isSuperOver: false,
          onStartOver: () {
            _startOver(context);
          },
        ),
      ],
    );
  }

  // ==========================================================
  // SCORING
  // ==========================================================

  Widget _scoring(
    BuildContext context,
    LiveScoringState state,
  ) {
    final scale = context.sportoScale;

    final title = state.isSuperOver
        ? 'Super Over - ${state.currentBattingTeam.name}'
        : state.currentBattingTeam.name;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ===========================================
        // MATCH
        // ===========================================

        _matchCard(state),

        SizedBox(
          height: 21 * scale,
        ),

        // ===========================================
        // SCORE
        // ===========================================

        SportoLiveScoreCard(
          title: title,
          score: state.scoreText,
          progress: state.progressText,
          bowler: state.currentBowlerName,
          height: state.isSuperOver ? 212 : 225,
          balls: _ballViews(state),
        ),

        if (state.strikerName.isNotEmpty ||
            state.nonStrikerName.isNotEmpty) ...[
          SizedBox(height: 8 * scale),
          Text(
            'Batters: ${state.strikerName} (Striker)  •  ${state.nonStrikerName} (Non-Striker)',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: Colors.white70,
              fontSize: 12 * scale,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],

        // ===========================================
        // CHASE INFO
        // ===========================================

        if (state.target != null) ...[
          SizedBox(
            height: 12 * scale,
          ),
          SportoLiveNoticeBar(
            text: '${state.runsRequired} runs needed to win',
          ),
        ],

        SizedBox(
          height: 21 * scale,
        ),

        // ===========================================
        // REPLACEMENT BATTER (wicket) — replaces the scoring pad until set
        // ===========================================

        if (state.awaitingReplacement) ...[
          const SportoLiveNoticeBar(
            text: 'Wicket — select the next batter to continue.',
          ),
          SizedBox(height: 16 * scale),
          SportoLivePlayerSelector(
            title: 'Select Replacement Batter',
            players: state.replacementBatters
                .map(
                  (player) => SportoLiveBowlerOption(
                    id: player.id,
                    name: player.displayName,
                    selected: false,
                    enabled: true,
                  ),
                )
                .toList(),
            onSelected: (playerId) async {
              if (_scoreApiLoading.value) return;
              final striker = int.tryParse(playerId);
              final nonStriker = int.tryParse(state.nonStrikerId ?? '');
              if (striker == null || nonStriker == null) return;
              await _syncScore(
                context,
                RefereeScoreUpdateRequest.setBatters(
                  strikerUserId: striker,
                  nonStrikerUserId: nonStriker,
                ),
              );
            },
          ),
        ] else ...[
          // ===========================================
          // SCORING BUTTONS
          // ===========================================

          SportoLiveScoringControls(
            bowler: state.currentBowlerName,
            availableEvents: _availableEventCodes,
            allowedRunValues: _allowedRunValues,
            onRun: (
              runs,
            ) {
              _addScoreEvent(
                context,
                state,
                eventCode: RefereeCricketEventCodes.run,
                value: runs,
              );
            },
            onWicket: () {
              _pickWicketType(context, state);
            },
            onWide: () {
              _addScoreEvent(
                context,
                state,
                eventCode: RefereeCricketEventCodes.wide,
              );
            },
            onNoBall: () {
              _addScoreEvent(
                context,
                state,
                eventCode: RefereeCricketEventCodes.noBall,
              );
            },
          ),
          if (state.strikerId == null) ...[
            SizedBox(height: 16 * scale),
            _missingStepData(context),
          ],
        ],
        if (state.awaitingReplacement && state.replacementBatters.isEmpty) ...[
          SizedBox(height: 16 * scale),
          _missingStepData(context),
        ],
      ],
    );
  }

  Widget _overComplete(
    BuildContext context,
    LiveScoringState state,
  ) {
    final scale = context.sportoScale;

    // The backend increments `current_over` as soon as the over completes, so
    // `displayOver` is the NEXT over; the completed one is displayOver - 1.
    final completedOver = state.displayOver - 1;
    final nextOver = state.displayOver;

    final nextIsLastOver = state.regulationOvers > 0 &&
        nextOver == state.regulationOvers;

    final buttonText = nextIsLastOver
        ? 'Let’s Begin $nextOver Last Over'
        : 'Select Bowler for Over $nextOver';

    return Column(
      children: [
        // ===========================================
        // MATCH
        // ===========================================

        _matchCard(state),

        SizedBox(
          height: 21 * scale,
        ),

        // ===========================================
        // COMPLETED OVER SCORE
        // ===========================================

        SportoLiveScoreCard(
          title: null,
          score: state.scoreText,
          progress: state.regulationOvers > 0
              ? 'Over $completedOver/${state.regulationOvers}'
                  '  •  Ball ${state.legalBallCount}/6'
              : 'Over $completedOver  •  Ball ${state.legalBallCount}/6',
          bowler: state.currentBowlerName,
          height: 200,
          balls: _ballViews(state),
        ),

        SizedBox(
          height: 22 * scale,
        ),

        // ===========================================
        // NOTICE
        // ===========================================

        SportoLiveNoticeBar(
          text: 'Over $completedOver completed.',
        ),

        SizedBox(
          height: 20 * scale,
        ),

        // ===========================================
        // NEXT OVER
        // ===========================================

        SportoLivePrimaryButton(
          text: buttonText,
          onTap: () {
            // Over boundaries are tracked locally; the backend only advances
            // on END_PERIOD at an innings/period boundary.
            context.read<LiveScoringBloc>().add(ContinueAfterOverEvent());
          },
        ),
      ],
    );
  }

  // ==========================================================
  // FIRST INNINGS COMPLETE
  // ==========================================================

  Widget _inningsBreak(
    BuildContext context,
    LiveScoringState state,
  ) {
    final scale = context.sportoScale;

    final first = state.firstInnings;

    if (first == null) {
      return _missingStepData(context);
    }

    final chasingTeam = state.firstBowlingTeam;

    final target = first.runs + 1;

    return Column(
      children: [
        // ===========================================
        // FIRST INNINGS RESULT
        // ===========================================

        SportoLiveMatchCard(
          battingTeam: first.battingTeamName,
          bowlingTeam: chasingTeam.name,
          showScores: true,
          battingScore: first.scoreText,
          bowlingScore: 'Yet to Bat',
        ),

        SizedBox(
          height: 21 * scale,
        ),

        // ===========================================
        // INNINGS BREAK
        // ===========================================

        SportoLiveInningsBreakCard(
          completedTeam: first.battingTeamName,
          completedScore: first.scoreText,
          chasingTeam: chasingTeam.name,
          target: target,
        ),

        SizedBox(
          height: 21 * scale,
        ),

        // ===========================================
        // START SECOND INNINGS
        // ===========================================

        SportoLivePrimaryButton(
          text: 'Start 2nd Innings',
          onTap: () {
            _endPeriod(context);
          },
        ),
      ],
    );
  }

  // ==========================================================
  // NORMAL FINAL RESULT
  // ==========================================================

  Widget _normalFinalResult(
    BuildContext context,
    LiveScoringState state,
  ) {
    final first = state.firstInnings;

    final second = state.secondInnings;

    if (first == null || second == null) {
      return _missingStepData(context);
    }

    return SportoCricketFinalResult(
      tournament: scoreConfig?.tournamentName ?? '',
      location: scoreConfig?.venueName ?? '',
      stage: scoreConfig?.formatName ?? '',
      regulation: SportoCricketInningsResultData(
        title: 'Regulation',
        teamA: first.battingTeamName,
        teamARole: 'Batting',
        teamAScore: first.scoreText,
        teamB: second.battingTeamName,
        teamBRole: 'Bowling',
        teamBScore: second.scoreText,
      ),
      winner: state.regulationWinner ?? '',
      onSubmit: () {
        _complete(context);
      },
    );
  }

  // ==========================================================
  // TIE → SUPER OVER REQUIRED
  // ==========================================================

  Widget _superOverReady(
    BuildContext context,
    LiveScoringState state,
  ) {
    final scale = context.sportoScale;

    final first = state.firstInnings;

    final second = state.secondInnings;

    return Column(
      children: [
        // ===========================================
        // MATCH
        // ===========================================

        SportoLiveMatchCard(
          battingTeam: first?.battingTeamName ?? state.currentBattingTeam.name,
          bowlingTeam:
              second?.battingTeamName ?? state.currentBowlingTeam.name,
        ),

        SizedBox(
          height: 21 * scale,
        ),

        // ===========================================
        // FINAL REGULATION SCORE (when available)
        // ===========================================

        if (first != null) ...[
          SportoLiveScoreCard(
            title: first.battingTeamName,
            score: first.scoreText,
            progress: state.regulationOvers > 0
                ? 'Over ${state.regulationOvers}/${state.regulationOvers}'
                    '  •  Ball 6/6'
                : 'Innings completed',
            height: 143,
          ),
          SizedBox(
            height: 20 * scale,
          ),
        ],

        // ===========================================
        // TIE WARNING
        // ===========================================

        if (first != null && second != null)
          SportoSuperOverRequiredBanner(
            teamAScore: first.runs,
            teamBScore: second.runs,
          )
        else
          const SportoLiveNoticeBar(
            text: 'Scores are level — a Super Over is required.',
          ),

        SizedBox(
          height: 20 * scale,
        ),

        // ===========================================
        // START SUPER OVER
        // ===========================================

        SportoLivePrimaryButton(
          text: state.superOverRound == 0
              ? 'Start Super Over'
              : 'Start Another Super Over',
          onTap: () {
            _startSuperOver(context);
          },
        ),
      ],
    );
  }

  // ==========================================================
  // SUPER OVER - SELECT BOWLER
  // ==========================================================

  Widget _superOverSelectBowler(
    BuildContext context,
    LiveScoringState state,
  ) {
    final scale = context.sportoScale;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ===========================================
        // MATCH
        // ===========================================

        _matchCard(state),

        SizedBox(
          height: 21 * scale,
        ),

        // ===========================================
        // TIE BREAKER INFORMATION
        // ===========================================

        if (state.firstInnings != null && state.secondInnings != null) ...[
          SportoLiveTieBreakerCard(
            regulationScore: '${state.firstInnings!.runs}'
                '–${state.secondInnings!.runs}',
            opponentTeam: state.currentBowlingTeam.name,
            opponentSuperOverScore: state.superOverInningsNumber == 2 &&
                    state.firstSuperOverInnings != null
                ? '${state.firstSuperOverInnings!.runs}'
                : 'Not started',
          ),
          SizedBox(
            height: 20 * scale,
          ),
        ],

        // ===========================================
        // SCORE
        // ===========================================

        SportoLiveScoreCard(
          title: 'Super Over - '
              '${state.currentBattingTeam.name}',
          score: state.scoreText,
          progress: state.progressText,
          height: 143,
        ),

        // Second Super Over innings = chase
        if (state.target != null) ...[
          SizedBox(
            height: 12 * scale,
          ),
          SportoLiveNoticeBar(
            text: 'Target ${state.target}  •  '
                '${state.runsRequired} runs required',
          ),
        ],

        SizedBox(
          height: 21 * scale,
        ),

        // ===========================================
        // STEPPED SELECTION: openers -> continue -> bowler
        // ===========================================

        _BowlerSelectionStep(
          state: state,
          isSuperOver: true,
          onStartOver: () {
            _startOver(context);
          },
        ),
      ],
    );
  }

  // ==========================================================
  // OPTIONAL SUPER OVER COMPLETE VIEW
  // ==========================================================

  Widget _superOverComplete(
    BuildContext context,
    LiveScoringState state,
  ) {
    final scale = context.sportoScale;

    return Column(
      children: [
        _matchCard(state),
        SizedBox(
          height: 21 * scale,
        ),
        SportoLiveScoreCard(
          title: 'Super Over - '
              '${state.currentBattingTeam.name}',
          score: state.scoreText,
          progress: 'Ball 6/6',
          height: 143,
        ),
        SizedBox(
          height: 20 * scale,
        ),
        const SportoLiveNoticeBar(
          text: 'Super Over innings completed.',
        ),
        SizedBox(
          height: 20 * scale,
        ),
        SportoLivePrimaryButton(
          text: 'Start Super Over 2nd Innings',
          onTap: () {
            _endPeriod(context);
          },
        ),
      ],
    );
  }

  // ==========================================================
  // FIRST SUPER OVER INNINGS COMPLETE
  // ==========================================================

  Widget _superOverBreak(
    BuildContext context,
    LiveScoringState state,
  ) {
    final scale = context.sportoScale;

    final first = state.firstSuperOverInnings;

    if (first == null) {
      return _missingStepData(context);
    }

    final chasingTeam = state.firstBowlingTeam;

    return Column(
      children: [
        // ===========================================
        // MATCH
        // ===========================================

        SportoLiveMatchCard(
          battingTeam: first.battingTeamName,
          bowlingTeam: chasingTeam.name,
          showScores: true,
          battingScore: first.scoreText,
          bowlingScore: 'Yet to Bat',
        ),

        SizedBox(
          height: 21 * scale,
        ),

        // ===========================================
        // SUPER OVER FIRST INNINGS COMPLETE
        // ===========================================

        SportoLiveInningsBreakCard(
          completedTeam: first.battingTeamName,
          completedScore: first.scoreText,
          chasingTeam: chasingTeam.name,
          target: first.runs + 1,
        ),

        SizedBox(
          height: 21 * scale,
        ),

        // ===========================================
        // START SECOND SUPER OVER INNINGS
        // ===========================================

        SportoLivePrimaryButton(
          text: 'Start Super Over 2nd Innings',
          onTap: () {
            _endPeriod(context);
          },
        ),
      ],
    );
  }

  // ==========================================================
  // SUPER OVER FINAL RESULT
  // ==========================================================

  Widget _superOverFinalResult(
    BuildContext context,
    LiveScoringState state,
  ) {
    final firstRegulation = state.firstInnings;

    final secondRegulation = state.secondInnings;

    final firstSuperOver = state.firstSuperOverInnings;

    final secondSuperOver = state.secondSuperOverInnings;

    if (firstRegulation == null || secondRegulation == null) {
      return _missingStepData(context);
    }

    // If super-over innings details are unavailable (e.g. the app entered the
    // match mid-super-over), fall back to the regulation result screen.
    if (firstSuperOver == null || secondSuperOver == null) {
      return _normalFinalResult(context, state);
    }

    return SportoCricketFinalResult(
      tournament: scoreConfig?.tournamentName ?? '',

      location: scoreConfig?.venueName ?? '',

      stage: scoreConfig?.formatName ?? '',

      // ======================================================
      // REGULATION
      // ======================================================

      regulation: SportoCricketInningsResultData(
        title: 'Regulation',
        teamA: firstRegulation.battingTeamName,
        teamARole: 'Batting',
        teamAScore: firstRegulation.scoreText,
        teamB: secondRegulation.battingTeamName,
        teamBRole: 'Bowling',
        teamBScore: secondRegulation.scoreText,
      ),

      // ======================================================
      // SUPER OVER
      // ======================================================

      superOver: SportoCricketInningsResultData(
        title: 'Super Over Innings Completed',
        teamA: firstSuperOver.battingTeamName,
        teamARole: '',
        teamAScore: firstSuperOver.scoreText,
        teamB: secondSuperOver.battingTeamName,
        teamBRole: '',
        teamBScore: secondSuperOver.scoreText,
      ),

      winner: state.superOverWinner ?? '',

      onSubmit: () {
        _complete(context);
      },
    );
  }

  // ==========================================================
  // RESULT SUBMITTED
  // ==========================================================

  Widget _resultSubmitted(
    BuildContext context,
    LiveScoringState state,
  ) {
    final scale = context.sportoScale;

    final first = state.firstInnings;

    final second = state.secondInnings;

    if (first == null || second == null) {
      return _missingStepData(context);
    }

    final hasSuperOver = state.firstSuperOverInnings != null &&
        state.secondSuperOverInnings != null;

    final winner =
        hasSuperOver ? state.superOverWinner : state.regulationWinner;

    return Column(
      children: [
        // ===========================================
        // RESULT SUBMITTED HERO
        // ===========================================

        const SportoResultSubmittedHero(),

        SizedBox(
          height: 21 * scale,
        ),

        // ===========================================
        // MATCH RESULT
        // ===========================================

        SportoCompletedMatchCard(
          regulation: SportoCompletedResultData(
            teamA: first.battingTeamName,
            teamARole: 'Batting',
            teamAScore: first.scoreText,
            teamB: second.battingTeamName,
            teamBRole: 'Bowling',
            teamBScore: second.scoreText,
          ),
          superOver: hasSuperOver
              ? SportoSuperOverResultData(
                  teamA: state.firstSuperOverInnings!.battingTeamName,
                  teamAScore: state.firstSuperOverInnings!.scoreText,
                  teamB: state.secondSuperOverInnings!.battingTeamName,
                  teamBScore: state.secondSuperOverInnings!.scoreText,
                )
              : null,
        ),

        SizedBox(
          height: 21 * scale,
        ),

        // ===========================================
        // WINNER
        // ===========================================

        SportoLiveWinnerCard(
          winner: winner ?? '',
        ),

        SizedBox(
          height: 20 * scale,
        ),

        // ===========================================
        // BACK HOME
        // ===========================================

        SportoLivePrimaryButton(
          text: 'Back to Home',
          onTap: () {
            context.go(AppRouter.homePath);
          },
        ),

        SizedBox(
          height: 12 * scale,
        ),

        // ===========================================
        // HISTORY
        // ===========================================

        SportoViewMatchHistoryButton(
          onTap: () {
            context.go(
              AppRouter.matchHistoryPath,
            );
          },
        ),
      ],
    );
  }

  // ==========================================================
  // BOWLER OPTIONS
  // ==========================================================

  // ==========================================================
  // STEPPED OVER-START SELECTION (top-level widget below)
  // ==========================================================

  // ==========================================================
  // BALL VIEW DATA
  //
  // Wide / No Ball are not legal deliveries,
  // therefore they do not consume one of six circles.
  // ==========================================================

  List<SportoLiveBallView> _ballViews(
    LiveScoringState state,
  ) {
    final legalDeliveries = state.currentOverDeliveries
        .where(
          (
            delivery,
          ) =>
              delivery.isLegal,
        )
        .take(6)
        .toList();

    final views = <SportoLiveBallView>[];

    for (final delivery in legalDeliveries) {
      switch (delivery.type) {
        case ScoringDeliveryType.wicket:
          views.add(
            const SportoLiveBallView(
              'W',
              style: SportoLiveBallStyle.wicket,
            ),
          );
          break;

        case ScoringDeliveryType.run:
          if (delivery.runs == 4) {
            views.add(
              const SportoLiveBallView(
                '4',
                style: SportoLiveBallStyle.four,
              ),
            );
          } else if (delivery.runs == 6) {
            views.add(
              const SportoLiveBallView(
                '6',
                style: SportoLiveBallStyle.six,
              ),
            );
          } else {
            views.add(
              SportoLiveBallView(
                '${delivery.runs}',
              ),
            );
          }

          break;

        case ScoringDeliveryType.wide:
        case ScoringDeliveryType.noBall:
          break;
      }
    }

    // Fill remaining legal-ball circles.
    while (views.length < 6) {
      views.add(
        const SportoLiveBallView.empty(),
      );
    }

    return views;
  }
}

/// Live match card component matching Section from `figma/Scoring.json` (350x203, radius 16).
class _FigmaScoringLiveMatchCard extends StatelessWidget {
  final String tournament;
  final String location;
  final String battingTeam;
  final String bowlingTeam;
  final String? battingScore;
  final String? bowlingScore;
  final String oversText;
  final String currentBowler;
  final bool compact;
  final bool showScores;

  const _FigmaScoringLiveMatchCard({
    required this.tournament,
    required this.location,
    required this.battingTeam,
    required this.bowlingTeam,
    this.battingScore,
    this.bowlingScore,
    required this.oversText,
    required this.currentBowler,
    this.compact = false,
    this.showScores = false,
  });

  @override
  Widget build(BuildContext context) {
    final scale = context.sportoScale;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0x33B40003), // 20% opacity #b40003
        gradient: const LinearGradient(
          colors: [
            Color(0x0AED7B00),
            Color(0x0ACF9E24),
          ],
        ),
        borderRadius: BorderRadius.circular(16 * scale),
        border: Border.all(
          color: const Color(0x4DF53E02),
          width: 1.0,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x80512813),
            blurRadius: 8,
            offset: Offset(0, 1),
          ),
        ],
      ),
      padding: EdgeInsets.all(10 * scale),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Badges Row: Stage badge, Live Now badge, Overs badge (Frame 1261154267)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 6 * scale,
                      vertical: 2 * scale,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF2BB673),
                      borderRadius: BorderRadius.circular(10 * scale),
                      border: Border.all(
                        color: const Color(0xFF2BB673),
                        width: 1.0,
                      ),
                    ),
                    child: Text(
                      'Quarter Final',
                      style: TextStyle(
                        fontSize: 11 * scale,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFFFFFFFF),
                        height: 1.0,
                      ),
                    ),
                  ),
                  SizedBox(width: 6 * scale),
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 6 * scale,
                      vertical: 2 * scale,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xCCFFFFFF),
                      borderRadius: BorderRadius.circular(10 * scale),
                      border: Border.all(
                        color: const Color(0x4DFE595C),
                        width: 1.0,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _ScoringPulsingDot(scale: scale),
                        SizedBox(width: 4 * scale),
                        Text(
                          'Live Now',
                          style: TextStyle(
                            fontSize: 11 * scale,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFFFE464B),
                            height: 1.0,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: 8 * scale,
                  vertical: 2 * scale,
                ),
                decoration: BoxDecoration(
                  color: const Color(0x661B2335),
                  borderRadius: BorderRadius.circular(8 * scale),
                ),
                child: Text(
                  oversText,
                  style: TextStyle(
                    fontSize: 14 * scale,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFFFFFFFF),
                    height: 1.0,
                  ),
                ),
              ),
            ],
          ),

          SizedBox(height: 8 * scale),

          // 2. Tournament Name: Crisp white text (Quicksand 16px, FontWeight.w600)
          Text(
            tournament,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 16 * scale,
              fontWeight: FontWeight.w600,
              color: const Color(0xFFFFFFFF),
              height: 1.2,
            ),
          ),

          SizedBox(height: 2 * scale),

          // Venue
          Row(
            children: [
              SportoAssetIcon(
                SportoAssets.locationPin,
                size: 13 * scale,
                color: const Color(0xFFAAAAAA),
              ),
              SizedBox(width: 4 * scale),
              Expanded(
                child: Text(
                  location,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 12 * scale,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFFAAAAAA),
                  ),
                ),
              ),
            ],
          ),

          SizedBox(height: 8 * scale),

          // 3. Teams & Scores Matchup
          Row(
            children: [
              Flexible(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      battingTeam,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 14 * scale,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFFFFFFFF),
                      ),
                    ),
                    if (showScores && battingScore != null) ...[
                      SizedBox(height: 2 * scale),
                      Text(
                        battingScore!,
                        style: TextStyle(
                          fontSize: 14 * scale,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFFFFFFFF),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 10 * scale),
                child: Text(
                  'Vs',
                  style: TextStyle(
                    fontSize: 12 * scale,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFFAAAAAA),
                  ),
                ),
              ),
              Flexible(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      bowlingTeam,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 14 * scale,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFFFFFFFF),
                      ),
                    ),
                    if (showScores && bowlingScore != null) ...[
                      SizedBox(height: 2 * scale),
                      Text(
                        bowlingScore!,
                        style: TextStyle(
                          fontSize: 12 * scale,
                          fontWeight: FontWeight.w500,
                          color: const Color(0xFFAAAAAA),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),

          if (!compact) ...[
            SizedBox(height: 8 * scale),

            // Line 7: 0.8px, #283040
            Container(
              height: 0.8 * scale,
              color: const Color(0xFF283040),
            ),

            SizedBox(height: 6 * scale),

            // Bowler info
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: Row(
                    children: [
                      Flexible(
                        child: Text(
                          'Current Batting: ',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 12 * scale,
                            fontWeight: FontWeight.w500,
                            color: const Color(0xFFAAAAAA),
                          ),
                        ),
                      ),
                      Flexible(
                        child: Text(
                          battingTeam,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 12 * scale,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFFFFFFFF),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Flexible(
                  child: Row(
                    children: [
                      Flexible(
                        child: Text(
                          'Current Bowler: ',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 12 * scale,
                            fontWeight: FontWeight.w500,
                            color: const Color(0xFFAAAAAA),
                          ),
                        ),
                      ),
                      Flexible(
                        child: Text(
                          currentBowler,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 12 * scale,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFFFFFFFF),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

/// Pulsing red live indicator dot for live scoring screen.
class _ScoringPulsingDot extends StatefulWidget {
  final double scale;

  const _ScoringPulsingDot({required this.scale});

  @override
  State<_ScoringPulsingDot> createState() => _ScoringPulsingDotState();
}

class _ScoringPulsingDotState extends State<_ScoringPulsingDot>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);
    _animation = Tween<double>(begin: 0.4, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          width: 7 * widget.scale,
          height: 7 * widget.scale,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: const Color(0xFFFE464B).withOpacity(_animation.value),
            boxShadow: [
              BoxShadow(
                color:
                    const Color(0xFFFE464B).withOpacity(_animation.value * 0.5),
                blurRadius: 4 * widget.scale,
              ),
            ],
          ),
        );
      },
    );
  }
}

// ============================================================
// STEPPED OVER-START SELECTION
// ============================================================

/// Guides the referee through starting an over:
///   1. Select Striker + Non-Striker (only when the batting side has no
///      batters configured yet, e.g. start of an innings)
///   2. Continue
///   3. Select Bowler
///   4. Start Over / Start Super Over
class _BowlerSelectionStep extends StatefulWidget {
  const _BowlerSelectionStep({
    required this.state,
    required this.isSuperOver,
    required this.onStartOver,
    this.apiLoading = false,
  });

  final LiveScoringState state;
  final bool isSuperOver;
  final VoidCallback onStartOver;
  final bool apiLoading;

  @override
  State<_BowlerSelectionStep> createState() => _BowlerSelectionStepState();
}

class _BowlerSelectionStepState extends State<_BowlerSelectionStep> {
  /// Whether the openers (striker/non-striker) phase is active.
  late bool _showOpeners;

  @override
  void initState() {
    super.initState();
    _showOpeners = !widget.state.openersConfigured;
  }

  @override
  void didUpdateWidget(covariant _BowlerSelectionStep oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Return to the openers phase whenever the batting side's batters were
    // cleared (new innings / server reset).
    if (!widget.state.openersConfigured) {
      _showOpeners = true;
    }
  }

  List<SportoLiveBowlerOption> _batterOptions({String? excludeId}) {
    final state = widget.state;
    return state.currentBattingTeam.bowlers
        .where((player) => !state.dismissedPlayerIds.contains(player.id))
        .map(
          (player) => SportoLiveBowlerOption(
            id: player.id,
            name: player.name,
            selected: player.id == state.strikerId ||
                player.id == state.nonStrikerId,
            enabled: player.id != excludeId,
          ),
        )
        .toList();
  }

  List<SportoLiveBowlerOption> _bowlerOptions() {
    final state = widget.state;
    return state.availableBowlers.map(
      (bowler) {
        return SportoLiveBowlerOption(
          id: bowler.id,
          name: bowler.displayName,
          selected: state.selectedBowlerId == bowler.id,
          // Before the first ball of the over any eligible bowler can be
          // chosen (and changed); once the over has started the selection
          // is locked.
          enabled: state.currentOverDeliveries.isEmpty
              ? state.isBowlerEligible(bowler)
              : state.selectedBowlerId == bowler.id,
        );
      },
    ).toList();
  }

  @override
  Widget build(BuildContext context) {
    final scale = context.sportoScale;
    final state = widget.state;

    if (_showOpeners) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SportoLivePlayerSelector(
            title: 'Select Striker',
            players: _batterOptions(excludeId: state.nonStrikerId),
            onSelected: (playerId) {
              context.read<LiveScoringBloc>().add(SelectStrikerEvent(playerId));
            },
          ),
          SizedBox(height: 18 * scale),
          SportoLivePlayerSelector(
            title: 'Select Non-Striker',
            players: _batterOptions(excludeId: state.strikerId),
            onSelected: (playerId) {
              context
                  .read<LiveScoringBloc>()
                  .add(SelectNonStrikerEvent(playerId));
            },
          ),
          SizedBox(height: 20 * scale),
          SportoLivePrimaryButton(
            text: 'Continue',
            disabled: !state.openersConfigured,
            onTap: () => setState(() => _showOpeners = false),
          ),
        ],
      );
    }

    return SportoLiveBowlerSelector(
      title: widget.isSuperOver
          ? 'Select Super Over Bowler'
          : 'Select Bowler for — Over ${state.displayOver}',
      bowlers: _bowlerOptions(),
      onSelected: (bowlerId) {
        context.read<LiveScoringBloc>().add(SelectBowlerEvent(bowlerId));
      },
      buttonText: widget.isSuperOver
          ? 'Start Super Over'
          : 'Start Over ${state.displayOver}',
      buttonEnabled: state.selectedBowler != null && state.openersConfigured,
      loading: widget.apiLoading,
      onContinue: widget.onStartOver,
    );
  }
}
