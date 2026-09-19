import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:referee_data/referee_data.dart';
import 'package:ui_kit/ui_kit.dart';

import '../../../../app/router/app_router.dart';
import '../../../../core/di/dependency_injector.dart';
import '../../application/conduct_toss_bloc.dart';

// ============================================================
// CONDUCT TOSS WIZARD
// ============================================================

class ConductTossWizard extends StatelessWidget {
  /// Actual repository match id.
  ///
  /// Current repository mock has ids such as m-901 / m-902.
  final String? matchId;

  /// What designer wants displayed.
  final String? matchCode;

  /// Null = actual random toss.
  ///
  /// For screenshot testing:
  ///
  /// TossCoinSide.tails
  final TossCoinSide? debugForcedCoinSide;

  const ConductTossWizard({
    super.key,

    // Current local mock repository contains m-902.
    // Replace with actual selected match id later.
    this.matchId,
    this.matchCode,
    this.debugForcedCoinSide,
  });

  // ==========================================================
  // BUILD
  // ==========================================================

  @override
  Widget build(BuildContext context) {
    final di = DependencyInjector.instance;
    return FutureBuilder<RefereeMatchResponse>(
      future: _loadMatch(di),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          if (snapshot.hasError) {
            return SportoScreenShell(
              body: Center(
                  child: Text('Unable to load match: ${snapshot.error}')),
            );
          }
          return const SportoScreenShell(
              body: Center(child: CircularProgressIndicator()));
        }
        final match = snapshot.data!;
        final team1 = _apiTeam(match.teamA, 'team-a');
        final team2 = _apiTeam(match.teamB, 'team-b');
        return BlocProvider(
          create: (_) => di.createConductTossBloc(
            matchId: match.id.toString(),
            team1: team1,
            team2: team2,
            callerTeamId: team2.id,
            callerChoice: TossCoinSide.tails,
            forcedCoinSide: debugForcedCoinSide,
          ),
          child: _ConductTossView(
            matchCode: matchCode ??
                '${match.displayTournament} • ${match.displayRound}',
          ),
        );
      },
    );
  }

  Future<RefereeMatchResponse> _loadMatch(DependencyInjector di) async {
    if (matchId != null && matchId!.trim().isNotEmpty) {
      return di.refereeRemoteDataSource.showMyMatchData(matchId!);
    }
    final matches = await di.refereeRemoteDataSource.listMyMatchesData();
    if (matches.isEmpty) {
      throw StateError('No assigned referee matches available.');
    }
    return matches.first;
  }

  TossTeam _apiTeam(RefereeMatchTeam? team, String fallbackId) {
    return TossTeam(
      id: (team?.id ?? fallbackId.hashCode).toString(),
      name: team?.name ?? 'Team',
      players: const [],
    );
  }
}

// ============================================================
// UI
// ============================================================

class _ConductTossView extends StatelessWidget {
  final String matchCode;

  const _ConductTossView({
    required this.matchCode,
  });

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ConductTossBloc, ConductTossState>(
      listenWhen: (
        previous,
        current,
      ) {
        return previous.errorMessage != current.errorMessage;
      },
      listener: (
        context,
        state,
      ) {
        final error = state.errorMessage;

        if (error == null) {
          return;
        }

        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(
            SnackBar(
              content: Text(
                error,
              ),
            ),
          );
      },
      builder: (
        context,
        state,
      ) {
        return SportoScreenShell(
          body: SafeArea(
            bottom: false,
            child: SingleChildScrollView(
              physics: const ClampingScrollPhysics(),
              padding: EdgeInsets.fromLTRB(
                20 * context.sportoScale,
                10 * context.sportoScale,
                20 * context.sportoScale,
                40 * context.sportoScale,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ===========================================
                  // HEADER
                  // ===========================================

                  SportoTossHeader(
                    title: state.screenTitle,
                    matchId: matchCode,
                    currentStep: state.progressStep,
                    onBack: () {
                      if (context.canPop()) {
                        context.pop();
                      }
                    },
                  ),

                  SizedBox(
                    height: 25 * context.sportoScale,
                  ),

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
                        state.step,
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
    ConductTossState state,
  ) {
    switch (state.step) {
      case ConductTossStep.flipCoin:
        return _flipCoin(
          context,
          state,
        );

      case ConductTossStep.coinResult:
        return _coinResult(
          context,
          state,
        );

      case ConductTossStep.chooseBatBowl:
        return _chooseBatBowl(
          context,
          state,
        );

      case ConductTossStep.selectOpeners:
        return _selectOpeners(
          context,
          state,
        );
    }
  }

  // ==========================================================
  // STEP 1
  // FLIP COIN
  // ==========================================================

  Widget _flipCoin(
    BuildContext context,
    ConductTossState state,
  ) {
    final scale = context.sportoScale;

    return Column(
      children: [
        SportoTossMatchStrip(
          team1: state.team1.name,
          team2: state.team2.name,
        ),
        SizedBox(height: 14 * scale),
        Align(
          alignment: Alignment.centerLeft,
          child: Text('Who is calling?',
              style: Theme.of(context).textTheme.titleMedium),
        ),
        SizedBox(height: 8 * scale),
        Row(children: [
          Expanded(child: _callingTeamCard(context, state, state.team1)),
          SizedBox(width: 10 * scale),
          Expanded(child: _callingTeamCard(context, state, state.team2)),
        ]),
        SizedBox(
          height: 21 * scale,
        ),
        SportoTossCoinCard(
          coinAsset: 'assets/images/toss_coin_heads.png',
          isFlipping: state.isFlipping,
          buttonText: 'Flip Coin',
          onButtonPressed: () {
            context.read<ConductTossBloc>().add(
                  FlipCoinRequested(),
                );
          },
        ),
      ],
    );
  }

  Widget _callingTeamCard(
      BuildContext context, ConductTossState state, TossTeam team) {
    final selected = state.callerTeamId == team.id;
    return GestureDetector(
      onTap: state.isFlipping
          ? null
          : () => context.read<ConductTossBloc>().add(
                CallingTeamSelected(team.id),
              ),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        height: 54,
        padding: const EdgeInsets.all(10),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selected
              ? const Color(0xFF103126)
              : Theme.of(context).colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected
                ? const Color(0xFF20C783)
                : Theme.of(context).colorScheme.outline,
          ),
        ),
        child: Text(team.name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: TextStyle(
                color: selected
                    ? const Color(0xFF20C783)
                    : Theme.of(context).colorScheme.onSurface,
                fontSize: 12)),
      ),
    );
  }

  // ==========================================================
  // STEP 1 RESULT
  // ==========================================================

  Widget _coinResult(
    BuildContext context,
    ConductTossState state,
  ) {
    final scale = context.sportoScale;

    final landedSide = state.landedSide;

    final winner = state.tossWinner;

    if (landedSide == null || winner == null) {
      return const SizedBox.shrink();
    }

    final isTails = landedSide == TossCoinSide.tails;

    return Column(
      children: [
        SportoTossMatchStrip(
          team1: state.team1.name,
          team2: state.team2.name,
        ),
        SizedBox(
          height: 21 * scale,
        ),
        SportoTossCoinCard(
          coinAsset: isTails
              ? 'assets/images/toss_coin_tails.png'
              : 'assets/images/toss_coin_heads.png',
          landedText: isTails ? 'TAILS' : 'HEADS',
          winnerText: '${winner.name} Won The Toss',
          buttonText: 'Continue',
          onButtonPressed: () {
            context.read<ConductTossBloc>().add(
                  ContinueAfterCoinResult(),
                );
          },
        ),
      ],
    );
  }

  // ==========================================================
  // STEP 2
  // BAT / BOWL
  // ==========================================================

  Widget _chooseBatBowl(
    BuildContext context,
    ConductTossState state,
  ) {
    final scale = context.sportoScale;

    final winner = state.tossWinner;

    if (winner == null) {
      return const SizedBox.shrink();
    }

    SportoTossChoice? selected;

    if (state.tossChoice == TossBatBowlChoice.batFirst) {
      selected = SportoTossChoice.bat;
    }

    if (state.tossChoice == TossBatBowlChoice.bowlFirst) {
      selected = SportoTossChoice.bowl;
    }

    return Column(
      children: [
        // ===========================================
        // WINNER
        // ===========================================

        SportoTossWinnerCard(
          winner: winner.name,
        ),

        SizedBox(
          height: 22 * scale,
        ),

        // ===========================================
        // TEAMS
        // ===========================================

        SportoTossMatchStrip(
          team1: state.team1.name,
          team2: state.team2.name,
        ),

        SizedBox(
          height: 20 * scale,
        ),

        // ===========================================
        // CHOICE
        // ===========================================

        SportoTossChoicePanel(
          winner: winner.name,
          selected: selected,
          onSelected: (
            choice,
          ) {
            final bloc = context.read<ConductTossBloc>();

            if (choice == SportoTossChoice.bat) {
              bloc.add(
                const TossChoiceSelected(
                  TossBatBowlChoice.batFirst,
                ),
              );

              return;
            }

            bloc.add(
              const TossChoiceSelected(
                TossBatBowlChoice.bowlFirst,
              ),
            );
          },
        ),

        SizedBox(
          height: 20 * scale,
        ),

        // ===========================================
        // CONFIRM
        //
        // IMPORTANT:
        // No MatchScoringBloc.
        // No TossResultEntity in UI.
        // No repository in UI.
        // ===========================================

        SportoTossPrimaryButton(
          text: state.isSavingToss
              ? 'Saving Toss...'
              : 'Confirm & Select Openers',
          disabled: !state.canConfirmTossChoice,
          onTap: () {
            context.read<ConductTossBloc>().add(
                  ConfirmTossChoice(),
                );
          },
        ),
      ],
    );
  }

  // ==========================================================
  // STEP 3
  // SELECT OPENERS
  // ==========================================================

  Widget _selectOpeners(
    BuildContext context,
    ConductTossState state,
  ) {
    final scale = context.sportoScale;

    final battingTeam = state.battingTeam;

    final bowlingTeam = state.bowlingTeam;

    if (battingTeam == null || bowlingTeam == null) {
      return const SizedBox.shrink();
    }

    return Column(
      children: [
        // ===========================================
        // TEAMS
        // ===========================================

        SportoTossRoleStrip(
          battingTeam: battingTeam.name,
          bowlingTeam: bowlingTeam.name,
        ),

        SizedBox(
          height: 22 * scale,
        ),

        // ===========================================
        // STRIKER
        // ===========================================

        SportoTossPlayerSelector(
          title: 'Striker',
          teamName: battingTeam.name,
          players: _battingOptions(
            state,
            selectedId: state.strikerId,
            excludedId: state.nonStrikerId,
          ),
          onSelected: (
            playerId,
          ) {
            context.read<ConductTossBloc>().add(
                  StrikerSelected(
                    playerId,
                  ),
                );
          },
        ),

        SizedBox(
          height: 2 * scale,
        ),

        // ===========================================
        // NON STRIKER
        // ===========================================

        SportoTossPlayerSelector(
          title: 'Non - Striker',
          players: _battingOptions(
            state,
            selectedId: state.nonStrikerId,
            excludedId: state.strikerId,
          ),
          onSelected: (
            playerId,
          ) {
            context.read<ConductTossBloc>().add(
                  NonStrikerSelected(
                    playerId,
                  ),
                );
          },
        ),

        SizedBox(
          height: 21 * scale,
        ),

        // ===========================================
        // OPENING BOWLER
        // ===========================================

        SportoTossPlayerSelector(
          title: 'Opening Bowler',
          teamName: bowlingTeam.name,
          players: _bowlingOptions(
            state,
          ),
          onSelected: (
            playerId,
          ) {
            context.read<ConductTossBloc>().add(
                  OpeningBowlerSelected(
                    playerId,
                  ),
                );
          },
        ),

        SizedBox(
          height: 21 * scale,
        ),

        // ===========================================
        // START SCORING
        // ===========================================

        SportoTossPrimaryButton(
          text: 'Start Scoring',
          disabled: !state.canStartScoring,
          onTap: () {
            if (!state.canStartScoring) {
              return;
            }

            // ================================================
            // At this point ConductTossBloc contains:
            //
            // state.battingTeam
            // state.bowlingTeam
            // state.strikerId
            // state.nonStrikerId
            // state.openingBowlerId
            //
            // Next we should pass these to LiveScoringBloc.
            // ================================================

            context.read<ConductTossBloc>().add(
                  ConfirmStartingPlayers(),
                );

            context.push(
              AppRouter.liveScoringRoute,
            );
          },
        ),
      ],
    );
  }

  // ==========================================================
  // BATTING PLAYER OPTIONS
  // ==========================================================

  List<SportoTossPlayerOption> _battingOptions(
    ConductTossState state, {
    required String? selectedId,
    required String? excludedId,
  }) {
    return state.battingPlayers.map(
      (
        player,
      ) {
        return SportoTossPlayerOption(
          id: player.id,
          name: player.name,
          captain: player.captain,
          selected: selectedId == player.id,
          enabled: excludedId != player.id,
        );
      },
    ).toList();
  }

  // ==========================================================
  // BOWLING PLAYER OPTIONS
  // ==========================================================

  List<SportoTossPlayerOption> _bowlingOptions(
    ConductTossState state,
  ) {
    return state.bowlingPlayers.map(
      (
        player,
      ) {
        return SportoTossPlayerOption(
          id: player.id,
          name: player.name,
          captain: player.captain,
          selected: state.openingBowlerId == player.id,
          enabled: player.canBowl,
        );
      },
    ).toList();
  }
}
