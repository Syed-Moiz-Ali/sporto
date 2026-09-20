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

  final int totalOvers;

  const LiveScoringScreen({
    super.key,
    this.matchId,
    this.matchCode,
    this.totalOvers = 5,
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
        final toss = _tossRuntime(scoreConfig);
        final firstBattingTeamId = _stringId(
              _map(toss['batting_team'])['id'],
            ) ??
            teams.$1.id;

        return BlocProvider(
          create: (_) {
            return LiveScoringBloc(
              teamA: teams.$1,
              teamB: teams.$2,
              firstBattingTeamId: firstBattingTeamId,
              regulationOvers: widget.totalOvers,
              maxWickets: 10,
              initialStrikerId:
                  _stringId(_map(toss['starting_setup'])['STRIKER']),
              initialNonStrikerId:
                  _stringId(_map(toss['starting_setup'])['NON_STRIKER']),
              initialBowlerId:
                  _stringId(_map(toss['starting_setup'])['OPENING_BOWLER']),
            );
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

  Map<String, dynamic> _tossRuntime(RefereeScoreResponse score) {
    final toss = score.raw['toss'];
    if (toss is! Map) return const {};
    final runtime = toss['runtime'];
    return runtime is Map
        ? Map<String, dynamic>.from(runtime)
        : Map<String, dynamic>.from(toss);
  }

  Map<String, dynamic> _map(Object? value) => value is Map
      ? Map<String, dynamic>.from(value)
      : const <String, dynamic>{};

  String? _stringId(Object? value) => value == null ? null : value.toString();

  (ScoringTeam, ScoringTeam) _teamsFromScore(RefereeScoreResponse? score) {
    if (score == null || score.teams.length < 2) {
      return (
        const ScoringTeam(id: 'team-a', name: 'Team A', bowlers: []),
        const ScoringTeam(id: 'team-b', name: 'Team B', bowlers: []),
      );
    }
    return (
      _teamFromScore(score.teams[0]),
      _teamFromScore(score.teams[1]),
    );
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

  const _LiveScoringView({
    required this.matchId,
    required this.matchCode,
    required this.scoreConfig,
  });

  RefereeRemoteDataSource get _remote =>
      DependencyInjector.instance.refereeRemoteDataSource;

  bool get _scoreApiEnabled => scoreConfig?.scoring.enabled ?? true;

  int? get _numericMatchId => int.tryParse(matchId);

  Future<bool> _syncScore(
    BuildContext context,
    RefereeScoreUpdateRequest request,
  ) async {
    final numericMatchId = _numericMatchId;
    if (scoreConfig == null || numericMatchId == null) return true;
    if (!_scoreApiEnabled) {
      if (!_scoreApiEnabled) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Scoring API is disabled for this match.'),
          ),
        );
      }
      return false;
    }
    try {
      await _remote.updateMatchScoreData(numericMatchId, request);
      return true;
    } catch (error) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Score sync failed: $error')),
        );
      }
      return false;
    }
  }

  int? _teamId(String teamId) => int.tryParse(teamId);

  int? _selectedPlayerId(LiveScoringState state) {
    return int.tryParse(state.selectedBowlerId ?? '');
  }

  Future<void> _startOver(BuildContext context) async {
    final synced = await _syncScore(
      context,
      RefereeScoreUpdateRequest.start(),
    );
    if (!context.mounted || !synced) return;
    context.read<LiveScoringBloc>().add(StartSelectedOverEvent());
  }

  Future<void> _addScoreEvent(
    BuildContext context,
    LiveScoringState state, {
    required String eventCode,
    int? value,
  }) async {
    final teamId = _teamId(state.currentBattingTeam.id);
    if (teamId == null) return;
    final synced = await _syncScore(
      context,
      RefereeScoreUpdateRequest.addEvent(
        eventCode: eventCode,
        teamId: teamId,
        playerId: _selectedPlayerId(state),
        value: value,
      ),
    );
    if (!context.mounted || !synced) return;
    final bloc = context.read<LiveScoringBloc>();
    switch (eventCode) {
      case 'RUN':
        bloc.add(RecordRunsEvent(value ?? 0));
        break;
      case 'WICKET':
        bloc.add(RecordWicketEvent());
        break;
      case 'WIDE':
        bloc.add(RecordWideEvent());
        break;
      case 'NO_BALL':
        bloc.add(RecordNoBallEvent());
        break;
    }
  }

  Future<void> _endPeriod(
    BuildContext context,
    LiveScoringEvent event,
  ) async {
    final synced = await _syncScore(
      context,
      RefereeScoreUpdateRequest.endPeriod(),
    );
    if (!context.mounted || !synced) return;
    context.read<LiveScoringBloc>().add(event);
  }

  Future<void> _complete(BuildContext context) async {
    final synced = await _syncScore(
      context,
      RefereeScoreUpdateRequest.complete(),
    );
    if (!context.mounted || !synced) return;
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

        return SportoScreenShell(
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
                      child: _buildStep(
                        context,
                        state,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // ==========================================================
  // STEP ROUTER
  // ==========================================================

  Widget _buildStep(
    BuildContext context,
    LiveScoringState state,
  ) {
    switch (state.step) {
      case LiveScoringStep.selectBowler:
        return _selectBowler(
          context,
          state,
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
      tournament: scoreConfig?.raw['tournament_name']?.toString() ??
          scoreConfig?.formatName ??
          matchCode,
      location: scoreConfig?.raw['venue_name']?.toString() ?? 'Hyderabad',
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
        // BOWLER SELECTOR
        // ===========================================

        SportoLiveBowlerSelector(
          title: 'Select Bowler for — Over ${state.displayOver}',
          bowlers: _bowlerOptions(state),
          onSelected: (
            bowlerId,
          ) {
            if (state.isFirstBall && state.selectedBowlerId != null) return;
            context.read<LiveScoringBloc>().add(
                  SelectBowlerEvent(
                    bowlerId,
                  ),
                );
          },
          buttonText: 'Start Over ${state.displayOver}',
          buttonEnabled: state.canStartOver,
          onContinue: () {
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
        // SCORING BUTTONS
        // ===========================================

        SportoLiveScoringControls(
          bowler: state.currentBowlerName,
          onRun: (
            runs,
          ) {
            _addScoreEvent(
              context,
              state,
              eventCode: 'RUN',
              value: runs,
            );
          },
          onWicket: () {
            _addScoreEvent(
              context,
              state,
              eventCode: 'WICKET',
            );
          },
          onWide: () {
            _addScoreEvent(
              context,
              state,
              eventCode: 'WIDE',
            );
          },
          onNoBall: () {
            _addScoreEvent(
              context,
              state,
              eventCode: 'NO_BALL',
            );
          },
        ),
      ],
    );
  }

  // ==========================================================
  // OVER COMPLETE
  // ==========================================================

  Widget _overComplete(
    BuildContext context,
    LiveScoringState state,
  ) {
    final scale = context.sportoScale;

    final nextOver = state.displayOver + 1;

    final nextIsLastOver = nextOver == state.regulationOvers;

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
          progress: state.progressText,
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
          text: 'Over ${state.displayOver} completed.',
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
            _endPeriod(context, ContinueAfterOverEvent());
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
      return const SizedBox.shrink();
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
            _endPeriod(context, StartSecondInningsEvent());
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
      return const SizedBox.shrink();
    }

    return SportoCricketFinalResult(
      tournament: 'Asia Cup 2026',
      location: 'Hyderabad',
      stage: 'Quarter Final',
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

    if (first == null || second == null) {
      return const SizedBox.shrink();
    }

    return Column(
      children: [
        // ===========================================
        // MATCH
        // ===========================================

        SportoLiveMatchCard(
          battingTeam: first.battingTeamName,
          bowlingTeam: second.battingTeamName,
        ),

        SizedBox(
          height: 21 * scale,
        ),

        // ===========================================
        // FINAL REGULATION SCORE
        // ===========================================

        SportoLiveScoreCard(
          title: first.battingTeamName,
          score: first.scoreText,
          progress: 'Over ${state.regulationOvers}/${state.regulationOvers}'
              '  •  Ball 6/6',
          height: 143,
        ),

        SizedBox(
          height: 20 * scale,
        ),

        // ===========================================
        // TIE WARNING
        // ===========================================

        SportoSuperOverRequiredBanner(
          teamAScore: first.runs,
          teamBScore: second.runs,
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
            _endPeriod(context, StartSuperOverEvent());
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
        // SELECT BOWLER
        // ===========================================

        SportoLiveBowlerSelector(
          title: 'Select Super Over Bowler',
          bowlers: _bowlerOptions(state),
          onSelected: (
            bowlerId,
          ) {
            context.read<LiveScoringBloc>().add(
                  SelectBowlerEvent(
                    bowlerId,
                  ),
                );
          },
          buttonText: 'Start Super Over',
          buttonEnabled: state.canStartOver,
          onContinue: () {
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
      return const SizedBox.shrink();
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
            _endPeriod(context, StartSecondSuperOverInningsEvent());
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

    if (firstRegulation == null ||
        secondRegulation == null ||
        firstSuperOver == null ||
        secondSuperOver == null) {
      return const SizedBox.shrink();
    }

    return SportoCricketFinalResult(
      tournament: 'Asia Cup 2026',

      location: 'Hyderabad',

      stage: 'Quarter Final',

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
      return const SizedBox.shrink();
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

  List<SportoLiveBowlerOption> _bowlerOptions(
    LiveScoringState state,
  ) {
    return state.availableBowlers.map(
      (
        bowler,
      ) {
        return SportoLiveBowlerOption(
          id: bowler.id,
          name: bowler.displayName,
          selected: state.selectedBowlerId == bowler.id,
          enabled: state.isFirstBall && state.selectedBowlerId != null
              ? state.selectedBowlerId == bowler.id
              : state.isBowlerEligible(bowler),
        );
      },
    ).toList();
  }

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
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Current Batting: ',
                      style: TextStyle(
                        fontSize: 12 * scale,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFFAAAAAA),
                      ),
                    ),
                    Text(
                      battingTeam,
                      style: TextStyle(
                        fontSize: 12 * scale,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFFFFFFFF),
                      ),
                    ),
                  ],
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Current Bowler: ',
                      style: TextStyle(
                        fontSize: 12 * scale,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFFAAAAAA),
                      ),
                    ),
                    Text(
                      currentBowler,
                      style: TextStyle(
                        fontSize: 12 * scale,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFFFFFFFF),
                      ),
                    ),
                  ],
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
