import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:ui_kit/ui_kit.dart';

import '../../../../app/router/app_router.dart';
import '../../application/live_scoring/live_scoring_bloc.dart';

// ============================================================
// LIVE SCORING SCREEN
// ============================================================

class LiveScoringScreen extends StatelessWidget {
  final String matchId;
  final String matchCode;

  final int totalOvers;

  const LiveScoringScreen({
    super.key,
    this.matchId = 'm-902',
    this.matchCode = 'SPT-20481',
    this.totalOvers = 5,
  });

  // ==========================================================
  // DEMO TEAM A
  //
  // Replace these players with actual match data/API later.
  // ==========================================================

  static const ScoringTeam _hydHighlanders = ScoringTeam(
    id: 'hyd',
    name: 'Hyd Highlanders',
    bowlers: [
      ScoringBowler(
        id: 'hyd_arjun',
        name: 'Arjun Reddy',
      ),
      ScoringBowler(
        id: 'hyd_rakesh',
        name: 'Rakesh Rao',
      ),
      ScoringBowler(
        id: 'hyd_vishal',
        name: 'Vishal M',
      ),
      ScoringBowler(
        id: 'hyd_sanjay',
        name: 'Sanjay Kumar',
      ),
      ScoringBowler(
        id: 'hyd_rajesh',
        name: 'Rajesh K',
      ),
    ],
  );

  // ==========================================================
  // DEMO TEAM B
  // ==========================================================

  static const ScoringTeam _delhiWarriors = ScoringTeam(
    id: 'delhi',
    name: 'Delhi Warriors',
    bowlers: [
      ScoringBowler(
        id: 'vikram',
        name: 'Vikram Reddy',
        captain: true,
        enabled: false,
      ),
      ScoringBowler(
        id: 'dev',
        name: 'Dev Kumar',
      ),
      ScoringBowler(
        id: 'pankaj',
        name: 'Pankaj S',
      ),
      ScoringBowler(
        id: 'rohan',
        name: 'Rohan A',
      ),
      ScoringBowler(
        id: 'vinayak',
        name: 'Vinayak L',
      ),
    ],
  );

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) {
        return LiveScoringBloc(
          teamA: _hydHighlanders,
          teamB: _delhiWarriors,

          // Hyd bats first.
          // Later pass this from ConductTossBloc.
          firstBattingTeamId: _hydHighlanders.id,

          regulationOvers: totalOvers,
          maxWickets: 10,
        );
      },
      child: _LiveScoringView(
        matchId: matchId,
        matchCode: matchCode,
      ),
    );
  }
}

// ============================================================
// MAIN VIEW
// ============================================================

class _LiveScoringView extends StatelessWidget {
  final String matchId;
  final String matchCode;

  const _LiveScoringView({
    required this.matchId,
    required this.matchCode,
  });

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
    return SportoLiveMatchCard(
      battingTeam: state.currentBattingTeam.name,
      bowlingTeam: state.currentBowlingTeam.name,
      compact: compact,
      showScores: showScores,
      battingScore: showScores ? state.scoreText : null,
      bowlingScore: showScores ? _opponentScore(state) : null,
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
            context.read<LiveScoringBloc>().add(
                  SelectBowlerEvent(
                    bowlerId,
                  ),
                );
          },
          buttonText: 'Start Over ${state.displayOver}',
          buttonEnabled: state.canStartOver,
          onContinue: () {
            context.read<LiveScoringBloc>().add(
                  StartSelectedOverEvent(),
                );
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
            context.read<LiveScoringBloc>().add(
                  RecordRunsEvent(
                    runs,
                  ),
                );
          },
          onWicket: () {
            context.read<LiveScoringBloc>().add(
                  RecordWicketEvent(),
                );
          },
          onWide: () {
            context.read<LiveScoringBloc>().add(
                  RecordWideEvent(),
                );
          },
          onNoBall: () {
            context.read<LiveScoringBloc>().add(
                  RecordNoBallEvent(),
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
            context.read<LiveScoringBloc>().add(
                  ContinueAfterOverEvent(),
                );
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
            context.read<LiveScoringBloc>().add(
                  StartSecondInningsEvent(),
                );
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
        context.read<LiveScoringBloc>().add(
              SubmitFinalResultEvent(),
            );
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
            context.read<LiveScoringBloc>().add(
                  StartSuperOverEvent(),
                );
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
            context.read<LiveScoringBloc>().add(
                  StartSelectedOverEvent(),
                );
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
            context.read<LiveScoringBloc>().add(
                  StartSecondSuperOverInningsEvent(),
                );
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
        context.read<LiveScoringBloc>().add(
              SubmitFinalResultEvent(),
            );
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
          enabled: state.isBowlerEligible(
            bowler,
          ),
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
