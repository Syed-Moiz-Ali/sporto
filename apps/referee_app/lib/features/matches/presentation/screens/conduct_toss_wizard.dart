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
  final RefereeMatchResponse? initialMatch;
  final ConductTossBloc? bloc;

  const ConductTossWizard({
    super.key,

    // Current local mock repository contains m-902.
    // Replace with actual selected match id later.
    this.matchId,
    this.matchCode,
    this.debugForcedCoinSide,
    this.initialMatch,
    this.bloc,
  });

  // ==========================================================
  // BUILD
  // ==========================================================

  @override
  Widget build(BuildContext context) {
    if (bloc != null) {
      return BlocProvider.value(
        value: bloc!,
        child: _ConductTossView(
          matchCode: matchCode ?? 'SPT-${initialMatch?.id ?? 20481}',
        ),
      );
    }
    final di = DependencyInjector.instance;
    if (initialMatch != null) {
      final match = initialMatch!;
      final team1 = _apiTeam(match.teamA, 'team-a');
      final team2 = _apiTeam(match.teamB, 'team-b');
      return BlocProvider(
        create: (_) => di.createConductTossBloc(
          matchId: match.id.toString(),
          team1: team1,
          team2: team2,
          callerTeamId: team1.id,
          callerChoice: TossCoinSide.heads,
          forcedCoinSide: debugForcedCoinSide,
          hasSelectedCaller: false,
        ),
        child: _ConductTossView(
          matchCode: matchCode ?? 'SPT-${match.id}',
        ),
      );
    }
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
            callerTeamId: team1.id,
            callerChoice: TossCoinSide.heads,
            forcedCoinSide: debugForcedCoinSide,
            hasSelectedCaller: false,
          ),
          child: _ConductTossView(
            matchCode: matchCode ?? 'SPT-${match.id}',
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
      logoUrl: team?.logoUrl,
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

                  _buildHeader(
                    context: context,
                    title: state.screenTitle,
                    matchCode: matchCode,
                    currentStep: state.progressStep,
                    scale: context.sportoScale,
                  ),

                  SizedBox(
                    height: 24 * context.sportoScale,
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

    // ==========================================================
    // SCREEN 3: "Enter Result - Conduct Toss.png" (PHYSICAL FLIP)
    // ==========================================================
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

    // ==========================================================
    // SCREEN 1: "Flip Coin - Conduct Toss.png" (WHO IS CALLING?)
    // ==========================================================
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

    // ==========================================================
    // SCREEN 2: "Conduct Toss.png" (TEAM CALLS HEADS/TAILS & FLIP)
    // ==========================================================
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

  Widget _buildModeSelector(
    BuildContext context,
    ConductTossState state,
    double scale,
  ) {
    final isFlip = state.tossMode == TossMode.flipCoin;
    return Container(
      width: double.infinity,
      height: 48 * scale,
      padding: EdgeInsets.all(4 * scale),
      decoration: BoxDecoration(
        color: const Color(0xFF0D141F),
        borderRadius: BorderRadius.circular(14 * scale),
        border: Border.all(color: const Color(0xFF1E2838)),
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
                  color: isFlip ? const Color(0xFF20C783) : Colors.transparent,
                  borderRadius: BorderRadius.circular(10 * scale),
                ),
                child: Text(
                  'Flip Coin',
                  style: TextStyle(
                    color: isFlip
                        ? const Color(0xFF03160D)
                        : const Color(0xFF8C96A5),
                    fontSize: 14 * scale,
                    fontWeight: isFlip ? FontWeight.w700 : FontWeight.w500,
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () => context
                  .read<ConductTossBloc>()
                  .add(const SelectTossMode(TossMode.enterResult)),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: !isFlip ? const Color(0xFF20C783) : Colors.transparent,
                  borderRadius: BorderRadius.circular(10 * scale),
                ),
                child: Text(
                  'Enter Result',
                  style: TextStyle(
                    color: !isFlip
                        ? const Color(0xFF03160D)
                        : const Color(0xFF8C96A5),
                    fontSize: 14 * scale,
                    fontWeight: !isFlip ? FontWeight.w700 : FontWeight.w500,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
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
      padding:
          EdgeInsets.symmetric(horizontal: 16 * scale, vertical: 14 * scale),
      decoration: BoxDecoration(
        color: const Color(0xFF0D141F),
        borderRadius: BorderRadius.circular(14 * scale),
        border: Border.all(color: const Color(0xFF1E2838)),
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
                      color: const Color(0xFF20C783),
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
                color: const Color(0xFF4B96E6),
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
      padding:
          EdgeInsets.fromLTRB(16 * scale, 24 * scale, 16 * scale, 24 * scale),
      decoration: BoxDecoration(
        color: const Color(0xFF0E1622),
        borderRadius: BorderRadius.circular(18 * scale),
        border: Border.all(color: const Color(0xFF1A2433)),
      ),
      child: Column(
        children: [
          Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: const Color(0xFF20C783),
              fontSize: 18 * scale,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 20 * scale),
          child,
        ],
      ),
    );
  }

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
        height: 195 * scale,
        padding:
            EdgeInsets.symmetric(horizontal: 10 * scale, vertical: 16 * scale),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFF0C2018) : const Color(0xFF111A24),
          borderRadius: BorderRadius.circular(16 * scale),
          border: Border.all(
            color: selected ? const Color(0xFF20C783) : const Color(0xFF1E2838),
            width: selected ? 1.5 : 1.0,
          ),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: const Color(0xFF20C783).withValues(alpha: 0.16),
                    blurRadius: 14,
                    spreadRadius: -2,
                  ),
                ]
              : null,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 86 * scale,
              height: 86 * scale,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14 * scale),
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
            SizedBox(height: 14 * scale),
            Text(
              team.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: selected
                    ? const Color(0xFF20C783)
                    : const Color(0xFF94A3B8),
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
          color: const Color(0xFF20C783),
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
        height: 195 * scale,
        padding:
            EdgeInsets.symmetric(horizontal: 10 * scale, vertical: 16 * scale),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFF0C2018) : const Color(0xFF111A24),
          borderRadius: BorderRadius.circular(16 * scale),
          border: Border.all(
            color: selected ? const Color(0xFF20C783) : const Color(0xFF1E2838),
            width: selected ? 1.5 : 1.0,
          ),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: const Color(0xFF20C783).withValues(alpha: 0.16),
                    blurRadius: 14,
                    spreadRadius: -2,
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
            SizedBox(height: 14 * scale),
            Text(
              label,
              style: TextStyle(
                color: selected
                    ? const Color(0xFF20C783)
                    : const Color(0xFF94A3B8),
                fontSize: 14 * scale,
                fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGoldenButton({
    required String label,
    required double scale,
    required VoidCallback? onPressed,
    bool disabled = false,
    bool loading = false,
  }) {
    return Center(
      child: GestureDetector(
        onTap: (disabled || loading) ? null : onPressed,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          width: double.infinity,
          height: 52 * scale,
          decoration: BoxDecoration(
            color: disabled ? const Color(0xFF151A22) : null,
            gradient: disabled
                ? null
                : const LinearGradient(
                    colors: [Color(0xFFE58A13), Color(0xFFF5A623)],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
            borderRadius: BorderRadius.circular(16 * scale),
            border: disabled
                ? Border.all(color: const Color(0xFF202633), width: 1.0)
                : null,
            boxShadow: disabled
                ? null
                : [
                    BoxShadow(
                      color: const Color(0xFFE58A13).withValues(alpha: 0.35),
                      blurRadius: 18,
                      offset: const Offset(0, 6),
                    ),
                  ],
          ),
          alignment: Alignment.center,
          child: loading
              ? const SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    color: Colors.white,
                  ),
                )
              : Text(
                  label,
                  style: TextStyle(
                    color: disabled ? const Color(0xFF4A5568) : Colors.white,
                    fontSize: 16 * scale,
                    fontWeight: FontWeight.w600,
                  ),
                ),
        ),
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
        _buildMatchStrip(
          team1: state.team1.name,
          team2: state.team2.name,
          scale: scale,
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

  Widget _buildHeader({
    required BuildContext context,
    required String title,
    required String matchCode,
    required int currentStep,
    required double scale,
  }) {
    return Column(
      children: [
        SizedBox(
          height: 36 * scale,
          child: Row(
            children: [
              GestureDetector(
                onTap: () {
                  if (context.canPop()) {
                    context.pop();
                  }
                },
                child: Container(
                  width: 36 * scale,
                  height: 36 * scale,
                  decoration: BoxDecoration(
                    color: const Color(0xFF2E3341),
                    borderRadius: BorderRadius.circular(10 * scale),
                  ),
                  alignment: Alignment.center,
                  child: Icon(
                    Icons.chevron_left_rounded,
                    color: Colors.white,
                    size: 26 * scale,
                  ),
                ),
              ),
              SizedBox(width: 14 * scale),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18 * scale,
                      fontWeight: FontWeight.w600,
                      height: 1.1,
                    ),
                  ),
                  SizedBox(height: 3 * scale),
                  Text(
                    'Match #$matchCode',
                    style: TextStyle(
                      color: const Color(0xFFA0A5B0),
                      fontSize: 12 * scale,
                      fontWeight: FontWeight.w400,
                      height: 1.1,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        SizedBox(height: 20 * scale),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(3, (index) {
            final active = index <= currentStep;
            return Container(
              margin: EdgeInsets.only(right: index == 2 ? 0 : 13 * scale),
              width: 50 * scale,
              height: 4 * scale,
              decoration: BoxDecoration(
                gradient: active
                    ? const LinearGradient(
                        colors: [Color(0xFFED7B00), Color(0xFFCE9E24)],
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
  // STEP 2
  // BAT / BOWL (Exact match to Conduct Toss.png & Conduct Toss-1.png)
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

    return Column(
      children: [
        _buildTossWinnerCard(
          winnerName: winner.name,
          scale: scale,
        ),
        SizedBox(height: 20 * scale),
        _buildMatchStrip(
          team1: state.team1.name,
          team2: state.team2.name,
          scale: scale,
        ),
        SizedBox(height: 20 * scale),
        _buildBatBowlPanel(
          context: context,
          winnerName: winner.name,
          selectedChoice: state.tossChoice,
          scale: scale,
        ),
        SizedBox(height: 22 * scale),
        _buildConfirmButton(
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
      constraints: BoxConstraints(minHeight: 70 * scale),
      padding: EdgeInsets.symmetric(
        horizontal: 16 * scale,
        vertical: 12 * scale,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFF1C2026),
        borderRadius: BorderRadius.circular(18 * scale),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Toss Winner',
            style: TextStyle(
              color: const Color(0xFF2BB673),
              fontSize: 13 * scale,
              fontWeight: FontWeight.w500,
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

  Widget _buildMatchStrip({
    required String team1,
    required String team2,
    required double scale,
  }) {
    return Container(
      width: double.infinity,
      constraints: BoxConstraints(minHeight: 46 * scale),
      padding: EdgeInsets.symmetric(
        horizontal: 16 * scale,
        vertical: 12 * scale,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFF1C2026),
        borderRadius: BorderRadius.circular(14 * scale),
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
          Text(
            'Vs',
            style: TextStyle(
              color: const Color(0xFFAAAAAA),
              fontSize: 13 * scale,
              fontWeight: FontWeight.w500,
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
        color: const Color(0xFF1C2026),
        borderRadius: BorderRadius.circular(18 * scale),
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
        height: 140 * scale,
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
                    spreadRadius: 0,
                  ),
                ]
              : null,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 68 * scale,
              height: 68 * scale,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(14 * scale),
                child: Image.asset(
                  assetPath,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) {
                    return Icon(
                      label.contains('Bat')
                          ? Icons.sports_cricket
                          : Icons.sports_baseball,
                      color: const Color(0xFF5185A1),
                      size: 38 * scale,
                    );
                  },
                ),
              ),
            ),
            SizedBox(height: 14 * scale),
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

  Widget _buildConfirmButton({
    required String label,
    required bool disabled,
    required bool loading,
    required VoidCallback? onPressed,
    required double scale,
  }) {
    return Center(
      child: GestureDetector(
        onTap: (disabled || loading) ? null : onPressed,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          width: 270 * scale,
          height: 48 * scale,
          decoration: BoxDecoration(
            color: disabled ? const Color(0xFF161411) : null,
            gradient: disabled
                ? null
                : const LinearGradient(
                    colors: [Color(0xFFED7B00), Color(0xFFCE9E24)],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
            borderRadius: BorderRadius.circular(16 * scale),
            boxShadow: disabled
                ? null
                : [
                    BoxShadow(
                      color: const Color(0xFFED7B00).withValues(alpha: 0.40),
                      blurRadius: 20,
                      offset: const Offset(0, 4),
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
