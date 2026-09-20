import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:referee_data/referee_data.dart';
import 'package:ui_kit/ui_kit.dart';

import '../../../../app/router/app_router.dart';
import '../../../../core/di/dependency_injector.dart';
import '../../application/conduct_toss_bloc.dart';

// ============================================================
// CONDUCT TOSS WIZARD (Figma: figma/toss)
// ============================================================

class ConductTossWizard extends StatelessWidget {
  /// Actual repository match id.
  final String? matchId;

  /// Displayed match code, e.g. SPT-20481.
  final String? matchCode;

  /// For screenshot or deterministic testing.
  final TossCoinSide? debugForcedCoinSide;
  final RefereeMatchResponse? initialMatch;
  final ConductTossBloc? bloc;
  final VoidCallback? onNavigateToScoring;

  const ConductTossWizard({
    super.key,
    this.matchId,
    this.matchCode,
    this.debugForcedCoinSide,
    this.initialMatch,
    this.bloc,
    this.onNavigateToScoring,
  });

  @override
  Widget build(BuildContext context) {
    if (bloc != null) {
      return BlocProvider.value(
        value: bloc!,
        child: _ConductTossView(
          matchCode: matchCode ?? 'SPT-${initialMatch?.id ?? 20481}',
          matchId: matchId ?? initialMatch?.id.toString(),
          onNavigateToScoring: onNavigateToScoring,
        ),
      );
    }
    final di = DependencyInjector.instance;
    if (initialMatch != null) {
      final match = initialMatch!;
      return FutureBuilder<RefereeTossResponse?>(
        future: di.refereeRemoteDataSource.getMatchTossData(match.id),
        builder: (context, snapshot) {
          final toss = snapshot.data;
          final team1 = _apiTeamWithRoster(match.teamA, toss, 0, 'team-a');
          final team2 = _apiTeamWithRoster(match.teamB, toss, 1, 'team-b');
          if (!snapshot.hasData) {
            return const SportoScreenShell(
                body: Center(child: CircularProgressIndicator()));
          }
          return BlocProvider(
            create: (_) => di.createConductTossBloc(
              matchId: match.id.toString(),
              team1: team1,
              team2: team2,
              callerTeamId: team1.id,
              callerChoice: TossCoinSide.heads,
              forcedCoinSide: debugForcedCoinSide,
              hasSelectedCaller: false,
              initialToss: toss,
            ),
            child: _ConductTossView(
              matchCode: matchCode ?? 'SPT-${match.id}',
              matchId: match.id.toString(),
              onNavigateToScoring: onNavigateToScoring,
            ),
          );
        },
      );
    }
    return FutureBuilder<(RefereeMatchResponse, RefereeTossResponse?)>(
      future: _loadMatch(di),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          if (snapshot.hasError) {
            return SportoScreenShell(
              body: Center(
                child: Text(
                  'Unable to load match: ${snapshot.error}',
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            );
          }
          return const SportoScreenShell(
            body: Center(
              child: CircularProgressIndicator(color: Color(0xFFED7B00)),
            ),
          );
        }
        final (match, toss) = snapshot.data!;
        final team1 = _apiTeamWithRoster(match.teamA, toss, 0, 'team-a');
        final team2 = _apiTeamWithRoster(match.teamB, toss, 1, 'team-b');
        return BlocProvider(
          create: (_) => di.createConductTossBloc(
            matchId: match.id.toString(),
            team1: team1,
            team2: team2,
            callerTeamId: team1.id,
            callerChoice: TossCoinSide.heads,
            forcedCoinSide: debugForcedCoinSide,
            hasSelectedCaller: false,
            initialToss: toss,
          ),
          child: _ConductTossView(
            matchCode: matchCode ?? 'SPT-${match.id}',
            matchId: match.id.toString(),
            onNavigateToScoring: onNavigateToScoring,
          ),
        );
      },
    );
  }

  Future<(RefereeMatchResponse, RefereeTossResponse?)> _loadMatch(
      DependencyInjector di) async {
    if (matchId != null && matchId!.trim().isNotEmpty) {
      final match = await di.refereeRemoteDataSource.showMyMatchData(matchId!);
      RefereeTossResponse? toss;
      try {
        toss = await di.refereeRemoteDataSource.getMatchTossData(match.id);
      } catch (_) {}
      return (match, toss);
    }
    final matches = await di.refereeRemoteDataSource.listMyMatchesData();
    if (matches.isEmpty) {
      throw StateError('No assigned referee matches available.');
    }
    final match = matches.first;
    RefereeTossResponse? toss;
    try {
      toss = await di.refereeRemoteDataSource.getMatchTossData(match.id);
    } catch (_) {}
    return (match, toss);
  }

  TossTeam _apiTeam(RefereeMatchTeam? team, String fallbackId) {
    final teamId = (team?.id ?? fallbackId.hashCode).toString();
    final teamName = team?.name ?? 'Team';
    return TossTeam(
      id: teamId,
      name: teamName,
      players: const <TossPlayer>[],
      logoUrl: team?.logoUrl,
    );
  }

  TossTeam _apiTeamWithRoster(RefereeMatchTeam? team, RefereeTossResponse? toss,
      int index, String fallbackId) {
    final base = _apiTeam(team, fallbackId);
    final apiTeam =
        toss != null && index < toss.teams.length ? toss.teams[index] : null;
    final players = apiTeam?.members
            .map((member) => TossPlayer(
                  id: member.userId.toString(),
                  name: member.name,
                  captain: member.isCaptain,
                ))
            .toList() ??
        const <TossPlayer>[];
    return TossTeam(
        id: base.id, name: base.name, players: players, logoUrl: base.logoUrl);
  }
}

// ============================================================
// UI VIEW
// ============================================================

class _ConductTossView extends StatelessWidget {
  final String matchCode;
  final String? matchId;
  final VoidCallback? onNavigateToScoring;

  const _ConductTossView({
    required this.matchCode,
    this.matchId,
    this.onNavigateToScoring,
  });

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ConductTossBloc, ConductTossState>(
      listenWhen: (previous, current) =>
          previous.errorMessage != current.errorMessage,
      listener: (context, state) {
        final error = state.errorMessage;
        if (error == null) return;
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(
            SnackBar(
              content: Text(error),
              backgroundColor: const Color(0xFFB40003),
            ),
          );
      },
      builder: (context, state) {
        final scale = context.sportoScale;
        final title = state.screenTitle;

        return SportoScreenShell(
          body: Container(
            color: const Color(0xFF090C10),
            child: SafeArea(
              bottom: false,
              child: SingleChildScrollView(
                physics: const ClampingScrollPhysics(),
                padding: EdgeInsets.fromLTRB(
                  20 * scale,
                  10 * scale,
                  20 * scale,
                  40 * scale,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ===========================================
                    // TOP HEADER & PROGRESS (Exact Figma)
                    // ===========================================
                    _buildHeader(
                      context: context,
                      title: title,
                      matchCode: matchCode,
                      state: state,
                      scale: scale,
                    ),

                    SizedBox(height: 20 * scale),

                    // ===========================================
                    // STEP VIEW
                    // ===========================================
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 220),
                      switchInCurve: Curves.easeOutCubic,
                      switchOutCurve: Curves.easeInCubic,
                      child: KeyedSubtree(
                        key: ValueKey(state.step.name +
                            state.tossMode.name +
                            state.hasSelectedCaller.toString()),
                        child: _buildStep(context, state),
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

  // ==========================================================
  // STEP ROUTER
  // ==========================================================

  Widget _buildStep(BuildContext context, ConductTossState state) {
    switch (state.step) {
      case ConductTossStep.flipCoin:
        return _flipCoin(context, state);
      case ConductTossStep.coinResult:
        return _coinResult(context, state);
      case ConductTossStep.chooseBatBowl:
        return _chooseBatBowl(context, state);
      case ConductTossStep.selectOpeners:
        return _buildSelectOpenersStep(context, state);
      case ConductTossStep.matchReady:
        return _buildMatchReadyStep(context, state);
    }
  }

  // ==========================================================
  // HEADER (Frame 1261154402)
  // ==========================================================

  Widget _buildHeader({
    required BuildContext context,
    required String title,
    required String matchCode,
    required ConductTossState state,
    required double scale,
  }) {
    final cleanMatchCode =
        matchCode.replaceAll('Match #', '').replaceAll('#', '');

    return Column(
      children: [
        SizedBox(
          height: 46 * scale,
          child: Row(
            children: [
              // Glassmorphic Back Button (Figma Back: 36x36, r10, fill #ffffff1a)
              GestureDetector(
                onTap: () {
                  if (context.canPop()) {
                    context.pop();
                  }
                },
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10 * scale),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                    child: Container(
                      width: 36 * scale,
                      height: 36 * scale,
                      decoration: BoxDecoration(
                        color: const Color(0x1AFFFFFF),
                        borderRadius: BorderRadius.circular(10 * scale),
                        border: Border.all(
                          color: const Color(0x33FFFFFF),
                          width: 0.8,
                        ),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x1F000000),
                            blurRadius: 4,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      alignment: Alignment.center,
                      child: Icon(
                        Icons.chevron_left_rounded,
                        color: Colors.white,
                        size: 26 * scale,
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(width: 12 * scale),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18 * scale,
                      fontWeight: FontWeight.w700,
                      height: 1.1,
                    ),
                  ),
                  SizedBox(height: 3 * scale),
                  Text(
                    'Match #$cleanMatchCode',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12 * scale,
                      fontWeight: FontWeight.w500,
                      height: 1.1,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        SizedBox(height: 16 * scale),

        // Progress Capsules (Frame 1261154355: Line 2, Line 3, Line 5)
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(3, (index) {
            final active = (state.step == ConductTossStep.selectOpeners ||
                    state.step == ConductTossStep.matchReady)
                ? true
                : (index <= state.progressStep);
            return Container(
              margin: EdgeInsets.only(right: index == 2 ? 0 : 16 * scale),
              width: 46 * scale,
              height: 4 * scale,
              decoration: BoxDecoration(
                gradient: active
                    ? const LinearGradient(
                        colors: [Color(0xFFED7B00), Color(0xFFCF9E24)],
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                      )
                    : null,
                color: active ? null : const Color(0xFF283040),
                borderRadius: BorderRadius.circular(2 * scale),
              ),
            );
          }),
        ),
      ],
    );
  }

  // ==========================================================
  // MATCH STRIP (Section: 350x46, radius 14, #12161c)
  // ==========================================================

  Widget _buildMatchStrip({
    required String team1,
    required String team2,
    required double scale,
  }) {
    return Container(
      width: double.infinity,
      constraints: BoxConstraints(minHeight: 46 * scale),
      padding: EdgeInsets.symmetric(
        horizontal: 14 * scale,
        vertical: 12 * scale,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFF12161C),
        borderRadius: BorderRadius.circular(14 * scale),
        border: Border.all(
          color: const Color(0x1AFFFFFF),
          width: 0.8,
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              team1,
              style: TextStyle(
                color: Colors.white,
                fontSize: 14 * scale,
                fontWeight: FontWeight.w500,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 8 * scale),
            child: Text(
              'Vs',
              style: TextStyle(
                color: const Color(0xFFAAAAAA),
                fontSize: 13 * scale,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              team2,
              textAlign: TextAlign.end,
              style: TextStyle(
                color: Colors.white,
                fontSize: 14 * scale,
                fontWeight: FontWeight.w500,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================================
  // MODE SELECTOR (Shape: 350x42, r14, fill #2bb6731f, blur 20)
  // ==========================================================

  Widget _buildModeSelector(
    BuildContext context,
    ConductTossState state,
    double scale,
  ) {
    final isFlip = state.tossMode == TossMode.flipCoin;
    return ClipRRect(
      borderRadius: BorderRadius.circular(14 * scale),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          width: double.infinity,
          height: 42 * scale,
          padding: EdgeInsets.all(4 * scale),
          decoration: BoxDecoration(
            color: const Color(0x1F2BB673),
            borderRadius: BorderRadius.circular(14 * scale),
            border: Border.all(
              color: const Color(0x33FFFFFF),
              width: 1.0,
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () => context
                      .read<ConductTossBloc>()
                      .add(const SelectTossMode(TossMode.flipCoin)),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: isFlip
                          ? const Color(0xFF2BB673)
                          : const Color(0xFF090C10),
                      borderRadius: BorderRadius.circular(10 * scale),
                      boxShadow: isFlip
                          ? const [
                              BoxShadow(
                                color: Color(0x332BB673),
                                blurRadius: 4,
                                offset: Offset(0, 4),
                              ),
                            ]
                          : null,
                    ),
                    child: Text(
                      'Flip Coin',
                      style: TextStyle(
                        color: isFlip
                            ? const Color(0xFF0E0C08)
                            : const Color(0xFFA0A0A0),
                        fontSize: 14 * scale,
                        fontWeight: isFlip ? FontWeight.w700 : FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(width: 8 * scale),
              Expanded(
                child: GestureDetector(
                  onTap: () => context
                      .read<ConductTossBloc>()
                      .add(const SelectTossMode(TossMode.enterResult)),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: !isFlip
                          ? const Color(0xFF2BB673)
                          : const Color(0xFF090C10),
                      borderRadius: BorderRadius.circular(10 * scale),
                      boxShadow: !isFlip
                          ? const [
                              BoxShadow(
                                color: Color(0x332BB673),
                                blurRadius: 4,
                                offset: Offset(0, 4),
                              ),
                            ]
                          : null,
                    ),
                    child: Text(
                      'Enter Result',
                      style: TextStyle(
                        color: !isFlip
                            ? const Color(0xFF0E0C08)
                            : const Color(0xFFA0A0A0),
                        fontSize: 14 * scale,
                        fontWeight: !isFlip ? FontWeight.w700 : FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ==========================================================
  // STEP 1: FLIP COIN & ENTER RESULT
  // ==========================================================

  Widget _flipCoin(BuildContext context, ConductTossState state) {
    final scale = context.sportoScale;

    // ----------------------------------------------------------
    // MODE: ENTER RESULT (Enter Result - Conduct Toss.json)
    // ----------------------------------------------------------
    if (state.tossMode == TossMode.enterResult) {
      return Column(
        children: [
          _buildMatchStrip(
            team1: state.team1.name,
            team2: state.team2.name,
            scale: scale,
          ),
          SizedBox(height: 16 * scale),
          _buildModeSelector(context, state, scale),
          SizedBox(height: 16 * scale),
          _buildMainCard(
            context: context,
            title: 'Which team won the toss?',
            scale: scale,
            child: Row(
              children: [
                Expanded(
                  child: _teamChoiceCard(
                    context: context,
                    team: state.team1,
                    selected: state.manualWinnerTeamId == state.team1.id,
                    onTap: () => context
                        .read<ConductTossBloc>()
                        .add(ManualWinnerSelected(state.team1.id)),
                    scale: scale,
                  ),
                ),
                SizedBox(width: 14 * scale),
                Expanded(
                  child: _teamChoiceCard(
                    context: context,
                    team: state.team2,
                    selected: state.manualWinnerTeamId == state.team2.id,
                    onTap: () => context
                        .read<ConductTossBloc>()
                        .add(ManualWinnerSelected(state.team2.id)),
                    scale: scale,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 24 * scale),
          _buildGoldenButton(
            label: 'Continue',
            scale: scale,
            disabled: state.manualWinnerTeamId == null || state.isSavingToss,
            loading: state.isSavingToss,
            onPressed: () {
              context.read<ConductTossBloc>().add(ConfirmManualTossResult());
            },
          ),
        ],
      );
    }

    // ----------------------------------------------------------
    // MODE: FLIP COIN - WHO IS CALLING? (Flip Coin - Conduct Toss.json)
    // ----------------------------------------------------------
    if (!state.hasSelectedCaller) {
      return Column(
        children: [
          _buildMatchStrip(
            team1: state.team1.name,
            team2: state.team2.name,
            scale: scale,
          ),
          SizedBox(height: 16 * scale),
          _buildModeSelector(context, state, scale),
          SizedBox(height: 16 * scale),
          _buildMainCard(
            context: context,
            title: 'Who is calling?',
            scale: scale,
            child: Row(
              children: [
                Expanded(
                  child: _teamChoiceCard(
                    context: context,
                    team: state.team1,
                    selected: state.callerTeamId == state.team1.id,
                    onTap: () => context
                        .read<ConductTossBloc>()
                        .add(CallingTeamSelected(state.team1.id)),
                    scale: scale,
                  ),
                ),
                SizedBox(width: 14 * scale),
                Expanded(
                  child: _teamChoiceCard(
                    context: context,
                    team: state.team2,
                    selected: state.callerTeamId == state.team2.id,
                    onTap: () => context
                        .read<ConductTossBloc>()
                        .add(CallingTeamSelected(state.team2.id)),
                    scale: scale,
                  ),
                ),
              ],
            ),
          ),
        ],
      );
    }

    // ----------------------------------------------------------
    // MODE: FLIP COIN - COIN SIDE & FLIP
    // ----------------------------------------------------------
    final callingTeam = state.teamById(state.callerTeamId);
    return Column(
      children: [
        _buildMatchStrip(
          team1: state.team1.name,
          team2: state.team2.name,
          scale: scale,
        ),
        SizedBox(height: 16 * scale),
        _buildCallingBar(context, state, scale),
        SizedBox(height: 16 * scale),
        _buildMainCard(
          context: context,
          title: '${callingTeam.name} calls:',
          scale: scale,
          child: Row(
            children: [
              Expanded(
                child: _coinChoiceCard(
                  context: context,
                  label: 'Heads',
                  asset: 'assets/images/toss_coin_heads.png',
                  selected: state.callerChoice == TossCoinSide.heads,
                  onTap: state.isFlipping
                      ? () {}
                      : () => context
                          .read<ConductTossBloc>()
                          .add(const CallerChoiceSelected(TossCoinSide.heads)),
                  scale: scale,
                ),
              ),
              SizedBox(width: 14 * scale),
              Expanded(
                child: _coinChoiceCard(
                  context: context,
                  label: 'Tails',
                  asset: 'assets/images/toss_coin_tails.png',
                  selected: state.callerChoice == TossCoinSide.tails,
                  onTap: state.isFlipping
                      ? () {}
                      : () => context
                          .read<ConductTossBloc>()
                          .add(const CallerChoiceSelected(TossCoinSide.tails)),
                  scale: scale,
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 24 * scale),
        _buildGoldenButton(
          label: state.isFlipping ? 'Flipping Coin...' : 'Flip Coin',
          scale: scale,
          loading: state.isFlipping,
          disabled: state.isFlipping,
          onPressed: () {
            context.read<ConductTossBloc>().add(FlipCoinRequested());
          },
        ),
      ],
    );
  }

  Widget _buildCallingBar(
    BuildContext context,
    ConductTossState state,
    double scale,
  ) {
    final caller = state.teamById(state.callerTeamId);
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: 16 * scale,
        vertical: 14 * scale,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFF12161C),
        borderRadius: BorderRadius.circular(14 * scale),
        border: Border.all(
          color: const Color(0x1AFFFFFF),
          width: 0.8,
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text: caller.name,
                    style: TextStyle(
                      color: const Color(0xFF2BB673),
                      fontSize: 14 * scale,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  TextSpan(
                    text: ' is calling',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14 * scale,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          GestureDetector(
            onTap: () =>
                context.read<ConductTossBloc>().add(ResetCallingTeam()),
            child: Text(
              'Change',
              style: TextStyle(
                color: const Color(0xFF7AD3FF),
                fontSize: 14 * scale,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMainCard({
    required BuildContext context,
    required String title,
    required Widget child,
    required double scale,
  }) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(
        14 * scale,
        18 * scale,
        14 * scale,
        18 * scale,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFF12161C),
        borderRadius: BorderRadius.circular(14 * scale),
        border: Border.all(
          color: const Color(0x1AFFFFFF),
          width: 0.8,
        ),
      ),
      child: Column(
        children: [
          Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: const Color(0xFF2BB673),
              fontSize: 16 * scale,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 16 * scale),
          child,
        ],
      ),
    );
  }

  // ==========================================================
  // TEAM CHOICE CARD (Frame 1261154265: 154x160, r16, logo 90x90)
  // ==========================================================

  Widget _teamChoiceCard({
    required BuildContext context,
    required TossTeam team,
    required bool selected,
    required VoidCallback onTap,
    required double scale,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        height: 160 * scale,
        padding: EdgeInsets.symmetric(
          horizontal: 10 * scale,
          vertical: 16 * scale,
        ),
        decoration: BoxDecoration(
          color: selected ? const Color(0x1A2BB673) : const Color(0x991B2335),
          borderRadius: BorderRadius.circular(16 * scale),
          border: Border.all(
            color: selected ? const Color(0xFF2BB673) : const Color(0x4D7AD0FA),
            width: selected ? 1.2 : 1.0,
          ),
          boxShadow: selected
              ? const [
                  BoxShadow(
                    color: Color(0x4D17A25F),
                    blurRadius: 24,
                    offset: Offset(2, 6),
                  ),
                  BoxShadow(
                    color: Color(0x1A000000),
                    blurRadius: 8,
                    offset: Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 90 * scale,
              height: 90 * scale,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20 * scale),
                color: const Color(0xFF1A2332),
              ),
              clipBehavior: Clip.antiAlias,
              child: team.logoUrl != null && team.logoUrl!.isNotEmpty
                  ? Image.network(
                      team.logoUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => _fallbackLogo(team, scale),
                    )
                  : _fallbackLogo(team, scale),
            ),
            SizedBox(height: 10 * scale),
            Text(
              team.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: selected ? const Color(0xFF2BB673) : Colors.white,
                fontSize: 14 * scale,
                fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _fallbackLogo(TossTeam team, double scale) {
    final initials = team.name.trim().isNotEmpty
        ? team.name
            .trim()
            .split(RegExp(r'\s+'))
            .take(2)
            .map((e) => e.isNotEmpty ? e[0].toUpperCase() : '')
            .join()
        : 'T';
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF1E293B), Color(0xFF0F172A)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      alignment: Alignment.center,
      child: Text(
        initials,
        style: TextStyle(
          color: const Color(0xFF2BB673),
          fontSize: 24 * scale,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _coinChoiceCard({
    required BuildContext context,
    required String label,
    required String asset,
    required bool selected,
    required VoidCallback onTap,
    required double scale,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        height: 160 * scale,
        padding: EdgeInsets.symmetric(
          horizontal: 10 * scale,
          vertical: 16 * scale,
        ),
        decoration: BoxDecoration(
          color: selected ? const Color(0x1A2BB673) : const Color(0x991B2335),
          borderRadius: BorderRadius.circular(16 * scale),
          border: Border.all(
            color: selected ? const Color(0xFF2BB673) : const Color(0x4D7AD0FA),
            width: selected ? 1.2 : 1.0,
          ),
          boxShadow: selected
              ? const [
                  BoxShadow(
                    color: Color(0x4D17A25F),
                    blurRadius: 24,
                    offset: Offset(2, 6),
                  ),
                ]
              : null,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 86 * scale,
              height: 86 * scale,
              child: Image.asset(
                asset,
                fit: BoxFit.contain,
              ),
            ),
            SizedBox(height: 10 * scale),
            Text(
              label,
              style: TextStyle(
                color: selected ? const Color(0xFF2BB673) : Colors.white,
                fontSize: 14 * scale,
                fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ==========================================================
  // STEP 1 RESULT
  // ==========================================================

  Widget _coinResult(BuildContext context, ConductTossState state) {
    final scale = context.sportoScale;
    final landedSide = state.landedSide;
    final winner = state.tossWinner;

    if (landedSide == null || winner == null) {
      return const SizedBox.shrink();
    }

    final isTails = landedSide == TossCoinSide.tails;

    return Column(
      children: [
        _buildMatchStrip(
          team1: state.team1.name,
          team2: state.team2.name,
          scale: scale,
        ),
        SizedBox(height: 20 * scale),
        SportoTossCoinCard(
          coinAsset: isTails
              ? 'assets/images/toss_coin_tails.png'
              : 'assets/images/toss_coin_heads.png',
          landedText: isTails ? 'TAILS' : 'HEADS',
          winnerText: '${winner.name} Won The Toss',
          buttonText: 'Continue',
          onButtonPressed: () {
            context.read<ConductTossBloc>().add(ContinueAfterCoinResult());
          },
        ),
      ],
    );
  }

  // ==========================================================
  // STEP 2: CHOOSE BAT / BOWL
  // ==========================================================

  Widget _chooseBatBowl(BuildContext context, ConductTossState state) {
    final scale = context.sportoScale;
    final winner = state.tossWinner;

    if (winner == null) {
      return const SizedBox.shrink();
    }

    return Column(
      children: [
        _buildTossWinnerCard(
          winnerName: winner.name,
          scale: scale,
        ),
        SizedBox(height: 16 * scale),
        _buildMatchStrip(
          team1: state.team1.name,
          team2: state.team2.name,
          scale: scale,
        ),
        SizedBox(height: 16 * scale),
        _buildBatBowlPanel(
          context: context,
          winnerName: winner.name,
          selectedChoice: state.tossChoice,
          scale: scale,
        ),
        SizedBox(height: 24 * scale),
        _buildGoldenButton(
          label: state.isSavingToss
              ? 'Saving Toss...'
              : 'Confirm & Select Openers',
          disabled: !state.canConfirmTossChoice,
          loading: state.isSavingToss,
          scale: scale,
          onPressed: () {
            context.read<ConductTossBloc>().add(ConfirmTossChoice());
          },
        ),
      ],
    );
  }

  Widget _buildTossWinnerCard({
    required String winnerName,
    required double scale,
  }) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: 16 * scale,
        vertical: 14 * scale,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFF12161C),
        borderRadius: BorderRadius.circular(14 * scale),
        border: Border.all(
          color: const Color(0x1AFFFFFF),
          width: 0.8,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Toss Winner',
            style: TextStyle(
              color: const Color(0xFF2BB673),
              fontSize: 13 * scale,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 4 * scale),
          Text(
            winnerName,
            style: TextStyle(
              color: Colors.white,
              fontSize: 18 * scale,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBatBowlPanel({
    required BuildContext context,
    required String winnerName,
    required TossBatBowlChoice? selectedChoice,
    required double scale,
  }) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(14 * scale),
      decoration: BoxDecoration(
        color: const Color(0xFF12161C),
        borderRadius: BorderRadius.circular(14 * scale),
        border: Border.all(
          color: const Color(0x1AFFFFFF),
          width: 0.8,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$winnerName chooses to',
            style: TextStyle(
              color: const Color(0xFF2BB673),
              fontSize: 16 * scale,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 14 * scale),
          Row(
            children: [
              Expanded(
                child: _buildDecisionChoiceCard(
                  label: 'Bat First',
                  assetPath: 'assets/images/bat_first.png',
                  selected: selectedChoice == TossBatBowlChoice.batFirst,
                  onTap: () {
                    context.read<ConductTossBloc>().add(
                          const TossChoiceSelected(TossBatBowlChoice.batFirst),
                        );
                  },
                  scale: scale,
                ),
              ),
              SizedBox(width: 14 * scale),
              Expanded(
                child: _buildDecisionChoiceCard(
                  label: 'Bowl First',
                  assetPath: 'assets/images/bowl_first.png',
                  selected: selectedChoice == TossBatBowlChoice.bowlFirst,
                  onTap: () {
                    context.read<ConductTossBloc>().add(
                          const TossChoiceSelected(TossBatBowlChoice.bowlFirst),
                        );
                  },
                  scale: scale,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDecisionChoiceCard({
    required String label,
    required String assetPath,
    required bool selected,
    required VoidCallback onTap,
    required double scale,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        height: 130 * scale,
        decoration: BoxDecoration(
          color: selected ? const Color(0xFF2A4250) : const Color(0xFF1B222F),
          borderRadius: BorderRadius.circular(16 * scale),
          border: Border.all(
            color: selected ? const Color(0xFF5185A1) : const Color(0xFF28394B),
            width: selected ? 1.8 : 1.0,
          ),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: const Color(0xFF5185A1).withValues(alpha: 0.35),
                    blurRadius: 16,
                  ),
                ]
              : null,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              label.contains('Bat')
                  ? Icons.sports_cricket
                  : Icons.sports_baseball,
              color: selected ? Colors.white : const Color(0xFF7AD3FF),
              size: 36 * scale,
            ),
            SizedBox(height: 10 * scale),
            Text(
              label,
              style: TextStyle(
                color: Colors.white,
                fontSize: 14 * scale,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ==========================================================
  // STEP 3 — SELECT OPENERS (player accordion selectors)
  // ==========================================================

  Widget _buildSelectOpenersStep(BuildContext context, ConductTossState state) {
    final scale = context.sportoScale;
    final battingTeam = state.battingTeam;
    final bowlingTeam = state.bowlingTeam;

    if (battingTeam == null || bowlingTeam == null) {
      return const SizedBox.shrink();
    }

    final displayBattingPlayers = state.battingPlayers;
    final displayBowlingPlayers = state.bowlingPlayers;
    if (displayBattingPlayers.length < 2 || displayBowlingPlayers.isEmpty) {
      return const SportoCard(
          child: Text(
              'Starting players are not available from the match roster yet.'));
    }

    final defaultStrikerId = displayBattingPlayers.first.id;
    final defaultNonStrikerId = displayBattingPlayers[1].id;
    final defaultBowlerId = displayBowlingPlayers.first.id;

    final activeStrikerId = state.strikerId ?? defaultStrikerId;
    final activeNonStrikerId = state.nonStrikerId ?? defaultNonStrikerId;
    final activeBowlerId = state.openingBowlerId ?? defaultBowlerId;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ------------------------------------------------------
        // CARD 1: SELECT STRIKER
        // ------------------------------------------------------
        _FigmaPlayerSelector(
          title: 'Select Striker',
          teamSubtitle: '${battingTeam.name} Batting',
          icon: Icons.sports_cricket,
          players: displayBattingPlayers,
          selectedId: activeStrikerId,
          excludedId: activeNonStrikerId,
          excludedReason: 'Selected as Non-Striker',
          onSelected: (id) =>
              context.read<ConductTossBloc>().add(StrikerSelected(id)),
          scale: scale,
        ),

        SizedBox(height: 12 * scale),

        // ------------------------------------------------------
        // CARD 2: SELECT NON-STRIKER
        // ------------------------------------------------------
        _FigmaPlayerSelector(
          title: 'Select Non-Striker',
          teamSubtitle: '${battingTeam.name} Batting',
          icon: Icons.sports_cricket_outlined,
          players: displayBattingPlayers,
          selectedId: activeNonStrikerId,
          excludedId: activeStrikerId,
          excludedReason: 'Selected as Striker',
          onSelected: (id) =>
              context.read<ConductTossBloc>().add(NonStrikerSelected(id)),
          scale: scale,
        ),

        SizedBox(height: 12 * scale),

        // ------------------------------------------------------
        // CARD 3: SELECT OPENING BOWLER
        // ------------------------------------------------------
        _FigmaPlayerSelector(
          title: 'Select Opening Bowler',
          teamSubtitle: '${bowlingTeam.name} Bowling',
          icon: Icons.sports_baseball,
          players: displayBowlingPlayers,
          selectedId: activeBowlerId,
          excludedId: null,
          onSelected: (id) =>
              context.read<ConductTossBloc>().add(OpeningBowlerSelected(id)),
          scale: scale,
        ),

        SizedBox(height: 28 * scale),

        // ------------------------------------------------------
        // CONFIRM OPENERS BUTTON
        // ------------------------------------------------------
        _buildGoldenButton(
          label: 'Confirm Openers',
          scale: scale,
          disabled: false,
          onPressed: () {
            final bloc = context.read<ConductTossBloc>();
            if (bloc.state.strikerId == null) {
              bloc.add(StrikerSelected(activeStrikerId));
            }
            if (bloc.state.nonStrikerId == null) {
              bloc.add(NonStrikerSelected(activeNonStrikerId));
            }
            if (bloc.state.openingBowlerId == null) {
              bloc.add(OpeningBowlerSelected(activeBowlerId));
            }
            bloc.add(ConfirmOpeners());
          },
        ),
      ],
    );
  }

  // ==========================================================
  // STEP 4 — MATCH READY (Innings Set + On the Field summary)
  // ==========================================================

  Widget _buildMatchReadyStep(BuildContext context, ConductTossState state) {
    final scale = context.sportoScale;
    final battingTeam = state.battingTeam;
    final bowlingTeam = state.bowlingTeam;

    if (battingTeam == null || bowlingTeam == null) {
      return const SizedBox.shrink();
    }

    final battingPlayers = state.battingPlayers.length >= 2
        ? state.battingPlayers
        : TossTeam.dummyPlayersFor(battingTeam.id, battingTeam.name)
            .where((p) => p.canBat)
            .toList();
    final bowlingPlayers = state.bowlingPlayers.isNotEmpty
        ? state.bowlingPlayers
        : TossTeam.dummyPlayersFor(bowlingTeam.id, bowlingTeam.name)
            .where((p) => p.canBowl)
            .toList();

    final defaultStrikerId = battingPlayers.first.id;
    final defaultNonStrikerId = battingPlayers.length > 1
        ? battingPlayers[1].id
        : battingPlayers.first.id;
    final defaultBowlerId = bowlingPlayers.first.id;

    final activeStrikerId = state.strikerId ?? defaultStrikerId;
    final activeNonStrikerId = state.nonStrikerId ?? defaultNonStrikerId;
    final activeBowlerId = state.openingBowlerId ?? defaultBowlerId;

    final striker =
        battingPlayers.where((p) => p.id == activeStrikerId).firstOrNull ??
            battingPlayers.firstOrNull;
    final nonStriker =
        battingPlayers.where((p) => p.id == activeNonStrikerId).firstOrNull ??
            (battingPlayers.length > 1 ? battingPlayers[1] : null);
    final openingBowler =
        bowlingPlayers.where((p) => p.id == activeBowlerId).firstOrNull ??
            bowlingPlayers.firstOrNull;

    final strikerDisplay = striker?.displayName ?? 'Shrvn Prajapati (Captain)';
    final nonStrikerDisplay = nonStriker?.displayName ?? 'Amit Kumar';
    final openingBowlerDisplay = openingBowler?.displayName ?? 'Dev Kumar';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ------------------------------------------------------
        // CARD 1: INNINGS SET (Section: 350x92, r14, #12161c)
        // ------------------------------------------------------
        Container(
          width: double.infinity,
          padding: EdgeInsets.all(14 * scale),
          decoration: BoxDecoration(
            color: const Color(0xFF12161C),
            borderRadius: BorderRadius.circular(14 * scale),
            border: Border.all(
              color: const Color(0x1AFFFFFF),
              width: 0.8,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Innings Set',
                style: TextStyle(
                  color: const Color(0xFF2BB673),
                  fontSize: 14 * scale,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 8 * scale),
              Text(
                '${battingTeam.name} First Batting',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16 * scale,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 3 * scale),
              Text(
                'Vs ${bowlingTeam.name} Bowling',
                style: TextStyle(
                  color: const Color(0xFFAAAAAA),
                  fontSize: 14 * scale,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),

        SizedBox(height: 16 * scale),

        // ------------------------------------------------------
        // CARD 2: ON THE FIELD (Frame 1261154345: 350x192, r14, #1c2026)
        // ------------------------------------------------------
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14 * scale),
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            children: [
              // Header Row
              Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(
                  horizontal: 14 * scale,
                  vertical: 14 * scale,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFF1C2026),
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(14 * scale),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'On the Field',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16 * scale,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    GestureDetector(
                      onTap: () => context
                          .read<ConductTossBloc>()
                          .add(EditOpenersRequested()),
                      child: Text(
                        'Edit',
                        style: TextStyle(
                          color: const Color(0xFF7AD3FF),
                          fontSize: 13 * scale,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 2 * scale),

              // Striker Row
              Container(
                width: double.infinity,
                height: 46 * scale,
                padding: EdgeInsets.symmetric(horizontal: 14 * scale),
                color: const Color(0xFF1C2026),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Striker',
                      style: TextStyle(
                        color: const Color(0xFFA0A0A0),
                        fontSize: 14 * scale,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Expanded(
                      child: Text(
                        strikerDisplay,
                        textAlign: TextAlign.end,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14 * scale,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 2 * scale),

              // Non-Striker Row
              Container(
                width: double.infinity,
                height: 46 * scale,
                padding: EdgeInsets.symmetric(horizontal: 14 * scale),
                color: const Color(0xFF1C2026),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Non-Striker',
                      style: TextStyle(
                        color: const Color(0xFFA0A0A0),
                        fontSize: 14 * scale,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Expanded(
                      child: Text(
                        nonStrikerDisplay,
                        textAlign: TextAlign.end,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14 * scale,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 2 * scale),

              // Opening Bowler Row
              Container(
                width: double.infinity,
                height: 46 * scale,
                padding: EdgeInsets.symmetric(horizontal: 14 * scale),
                decoration: BoxDecoration(
                  color: const Color(0xFF1C2026),
                  borderRadius: BorderRadius.vertical(
                    bottom: Radius.circular(14 * scale),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Opening Bowler',
                      style: TextStyle(
                        color: const Color(0xFFA0A0A0),
                        fontSize: 14 * scale,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Expanded(
                      child: Text(
                        openingBowlerDisplay,
                        textAlign: TextAlign.end,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14 * scale,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        SizedBox(height: 28 * scale),

        // ------------------------------------------------------
        // PRIMARY BUTTON (Figma Primary Button: Ready)
        // ------------------------------------------------------
        _buildGoldenButton(
          label: 'Ready',
          scale: scale,
          disabled: false,
          onPressed: () {
            final bloc = context.read<ConductTossBloc>();
            if (bloc.state.strikerId == null) {
              bloc.add(StrikerSelected(activeStrikerId));
            }
            if (bloc.state.nonStrikerId == null) {
              bloc.add(NonStrikerSelected(activeNonStrikerId));
            }
            if (bloc.state.openingBowlerId == null) {
              bloc.add(OpeningBowlerSelected(activeBowlerId));
            }
            bloc.add(ConfirmStartingPlayers());
            if (onNavigateToScoring != null) {
              onNavigateToScoring!();
            } else {
              final router = GoRouter.maybeOf(context);
              if (router != null) {
                router.replace(
                  '${AppRouter.liveScoringRoute}?matchId=${matchId ?? ''}&matchCode=${Uri.encodeComponent(matchCode)}',
                );
              }
            }
          },
        ),
      ],
    );
  }

  // ==========================================================
  // PRIMARY GOLDEN BUTTON (Figma Primary Button)
  // ==========================================================

  Widget _buildGoldenButton({
    required String label,
    required double scale,
    required VoidCallback? onPressed,
    bool disabled = false,
    bool loading = false,
    double? width,
  }) {
    return Center(
      child: GestureDetector(
        onTap: (disabled || loading) ? null : onPressed,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          width: width ?? (270 * scale),
          height: 48 * scale,
          decoration: BoxDecoration(
            color: disabled ? const Color(0xFF161411) : null,
            gradient: disabled
                ? null
                : const LinearGradient(
                    colors: [Color(0xFFED7B00), Color(0xFFCF9E24)],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
            borderRadius: BorderRadius.circular(16 * scale),
            boxShadow: disabled
                ? null
                : [
                    BoxShadow(
                      color: const Color(0xFFED7B00).withValues(alpha: 0.35),
                      blurRadius: 30,
                      offset: const Offset(2, 10),
                    ),
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
          ),
          alignment: Alignment.center,
          child: loading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    color: Colors.white,
                  ),
                )
              : Text(
                  label,
                  style: TextStyle(
                    color: disabled ? const Color(0xFF4A4540) : Colors.white,
                    fontSize: 15 * scale,
                    fontWeight: FontWeight.w600,
                  ),
                ),
        ),
      ),
    );
  }
}

// ============================================================
// FIGMA PLAYER SELECTOR (Inline Role Accordion Card)
// ============================================================

class _FigmaPlayerSelector extends StatefulWidget {
  final String title;
  final String teamSubtitle;
  final IconData icon;
  final List<TossPlayer> players;
  final String? selectedId;
  final String? excludedId;
  final String? excludedReason;
  final ValueChanged<String> onSelected;
  final double scale;

  const _FigmaPlayerSelector({
    required this.title,
    required this.teamSubtitle,
    required this.icon,
    required this.players,
    required this.selectedId,
    this.excludedId,
    this.excludedReason,
    required this.onSelected,
    required this.scale,
  });

  @override
  State<_FigmaPlayerSelector> createState() => _FigmaPlayerSelectorState();
}

class _FigmaPlayerSelectorState extends State<_FigmaPlayerSelector> {
  bool _isExpanded = false;
  bool _showAll = false;

  @override
  Widget build(BuildContext context) {
    final scale = widget.scale;
    final selectedPlayer =
        widget.players.where((p) => p.id == widget.selectedId).firstOrNull;

    final displayedPlayers =
        _showAll ? widget.players : widget.players.take(4).toList();

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFF12161C),
        borderRadius: BorderRadius.circular(14 * scale),
        border: Border.all(
          color: const Color(0x1AFFFFFF),
          width: 0.8,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () {
              setState(() {
                _isExpanded = !_isExpanded;
              });
            },
            child: Padding(
              padding: EdgeInsets.all(14 * scale),
              child: Row(
                children: [
                  Container(
                    width: 34 * scale,
                    height: 34 * scale,
                    decoration: BoxDecoration(
                      color: const Color(0x1A7AD3FF),
                      borderRadius: BorderRadius.circular(8 * scale),
                    ),
                    alignment: Alignment.center,
                    child: Icon(
                      widget.icon,
                      color: const Color(0xFF7AD3FF),
                      size: 18 * scale,
                    ),
                  ),
                  SizedBox(width: 10 * scale),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.title,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 15 * scale,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(height: 2 * scale),
                        Text(
                          widget.teamSubtitle,
                          style: TextStyle(
                            color: const Color(0xFF7AD3FF),
                            fontSize: 12 * scale,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: 8 * scale),
                  Container(
                    constraints: BoxConstraints(maxWidth: 140 * scale),
                    padding: EdgeInsets.symmetric(
                      horizontal: 8 * scale,
                      vertical: 4 * scale,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0x1A2BB673),
                      borderRadius: BorderRadius.circular(12 * scale),
                      border: Border.all(
                        color: const Color(0xFF2BB673),
                        width: 0.8,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.check_circle_rounded,
                          color: const Color(0xFF2BB673),
                          size: 12 * scale,
                        ),
                        SizedBox(width: 4 * scale),
                        Flexible(
                          child: Text(
                            selectedPlayer?.name ?? 'Select',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: const Color(0xFF2BB673),
                              fontSize: 12 * scale,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: 6 * scale),
                  Icon(
                    _isExpanded
                        ? Icons.keyboard_arrow_up_rounded
                        : Icons.keyboard_arrow_down_rounded,
                    color: const Color(0xFFAAAAAA),
                    size: 20 * scale,
                  ),
                ],
              ),
            ),
          ),

          // Expanded List
          if (_isExpanded) ...[
            Container(
              height: 0.8,
              color: const Color(0x1AFFFFFF),
            ),
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: 10 * scale,
                vertical: 8 * scale,
              ),
              child: Column(
                children: [
                  for (final p in displayedPlayers)
                    _buildPlayerRow(
                      player: p,
                      scale: scale,
                    ),
                  if (widget.players.length > 4)
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          _showAll = !_showAll;
                        });
                      },
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 8 * scale),
                        child: Center(
                          child: Text(
                            _showAll
                                ? 'Show Less'
                                : 'Show all ${widget.players.length} players',
                            style: TextStyle(
                              color: const Color(0xFF7AD3FF),
                              fontSize: 13 * scale,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildPlayerRow({
    required TossPlayer player,
    required double scale,
  }) {
    final isSelected = player.id == widget.selectedId;
    final isExcluded = player.id == widget.excludedId;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: isExcluded
          ? null
          : () {
              widget.onSelected(player.id);
            },
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 3 * scale),
        padding: EdgeInsets.symmetric(
          horizontal: 10 * scale,
          vertical: 8 * scale,
        ),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0x1A2BB673)
              : isExcluded
                  ? const Color(0x08FFFFFF)
                  : const Color(0xFF181D26),
          borderRadius: BorderRadius.circular(8 * scale),
          border: Border.all(
            color:
                isSelected ? const Color(0xFF2BB673) : const Color(0x0DFFFFFF),
            width: isSelected ? 1.0 : 0.6,
          ),
        ),
        child: Row(
          children: [
            // Radio Indicator
            Container(
              width: 18 * scale,
              height: 18 * scale,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected
                      ? const Color(0xFF2BB673)
                      : isExcluded
                          ? const Color(0xFF444444)
                          : const Color(0xFF556070),
                  width: 1.5,
                ),
              ),
              alignment: Alignment.center,
              child: isSelected
                  ? Container(
                      width: 10 * scale,
                      height: 10 * scale,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Color(0xFF2BB673),
                      ),
                    )
                  : null,
            ),
            SizedBox(width: 10 * scale),

            // Player Name
            Expanded(
              child: Row(
                children: [
                  Flexible(
                    child: Text(
                      player.name,
                      style: TextStyle(
                        color: isExcluded
                            ? const Color(0xFF555555)
                            : isSelected
                                ? const Color(0xFF2BB673)
                                : Colors.white,
                        fontSize: 14 * scale,
                        fontWeight:
                            isSelected ? FontWeight.w600 : FontWeight.w500,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (player.captain) ...[
                    SizedBox(width: 6 * scale),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 6 * scale,
                        vertical: 1.5 * scale,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0x26FEBD38),
                        borderRadius: BorderRadius.circular(4 * scale),
                        border: Border.all(
                          color: const Color(0x66FEBD38),
                          width: 0.6,
                        ),
                      ),
                      child: Text(
                        'Captain',
                        style: TextStyle(
                          color: const Color(0xFFFEBD38),
                          fontSize: 10 * scale,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                  if (isExcluded && widget.excludedReason != null) ...[
                    SizedBox(width: 6 * scale),
                    Text(
                      '(${widget.excludedReason})',
                      style: TextStyle(
                        color: const Color(0xFF666666),
                        fontSize: 11 * scale,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ],
              ),
            ),

            if (isSelected)
              Icon(
                Icons.check_rounded,
                color: const Color(0xFF2BB673),
                size: 18 * scale,
              ),
          ],
        ),
      ),
    );
  }
}
