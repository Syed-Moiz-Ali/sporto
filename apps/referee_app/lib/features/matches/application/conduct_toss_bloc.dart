import 'dart:math';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_domain/shared_domain.dart';

// ============================================================
// FLOW
// ============================================================

enum ConductTossStep {
  flipCoin,
  coinResult,
  chooseBatBowl,
  selectOpeners,
}

// ============================================================
// COIN
// ============================================================

enum TossCoinSide {
  heads,
  tails,
}

// ============================================================
// BAT / BOWL
// ============================================================

enum TossBatBowlChoice {
  batFirst,
  bowlFirst,
}

// ============================================================
// PLAYER
// ============================================================

class TossPlayer extends Equatable {
  final String id;
  final String name;

  final bool captain;

  final bool canBat;
  final bool canBowl;

  const TossPlayer({
    required this.id,
    required this.name,
    this.captain = false,
    this.canBat = true,
    this.canBowl = true,
  });

  String get displayName {
    return captain ? '$name (Captain)' : name;
  }

  @override
  List<Object?> get props => [
        id,
        name,
        captain,
        canBat,
        canBowl,
      ];
}

// ============================================================
// TEAM
// ============================================================

class TossTeam extends Equatable {
  final String id;
  final String name;

  final List<TossPlayer> players;

  const TossTeam({
    required this.id,
    required this.name,
    required this.players,
  });

  @override
  List<Object?> get props => [
        id,
        name,
        players,
      ];
}

// ============================================================
// STATE
// ============================================================

class ConductTossState extends Equatable {
  final ConductTossStep step;

  final TossTeam team1;
  final TossTeam team2;

  // ==========================================================
  // COIN
  // ==========================================================

  final String callerTeamId;

  final TossCoinSide callerChoice;

  final bool isFlipping;

  final TossCoinSide? landedSide;

  final String? tossWinnerTeamId;

  // ==========================================================
  // TOSS CHOICE
  // ==========================================================

  final TossBatBowlChoice? tossChoice;

  final bool isSavingToss;

  // ==========================================================
  // OPENERS
  // ==========================================================

  final String? strikerId;
  final String? nonStrikerId;
  final String? openingBowlerId;

  // ==========================================================
  // ERROR
  // ==========================================================

  final String? errorMessage;

  const ConductTossState({
    required this.team1,
    required this.team2,
    required this.callerTeamId,
    required this.callerChoice,
    this.step = ConductTossStep.flipCoin,
    this.isFlipping = false,
    this.landedSide,
    this.tossWinnerTeamId,
    this.tossChoice,
    this.isSavingToss = false,
    this.strikerId,
    this.nonStrikerId,
    this.openingBowlerId,
    this.errorMessage,
  });

  // ==========================================================
  // TEAM HELPERS
  // ==========================================================

  TossTeam teamById(String id) {
    if (team1.id == id) {
      return team1;
    }

    if (team2.id == id) {
      return team2;
    }

    throw StateError(
      'Team with id "$id" was not found.',
    );
  }

  TossTeam otherTeam(String id) {
    if (team1.id == id) {
      return team2;
    }

    if (team2.id == id) {
      return team1;
    }

    throw StateError(
      'Team with id "$id" was not found.',
    );
  }

  TossTeam? get tossWinner {
    final winnerId = tossWinnerTeamId;

    if (winnerId == null) {
      return null;
    }

    return teamById(winnerId);
  }

  // ==========================================================
  // BATTING TEAM
  // ==========================================================

  TossTeam? get battingTeam {
    final winner = tossWinner;
    final choice = tossChoice;

    if (winner == null || choice == null) {
      return null;
    }

    if (choice == TossBatBowlChoice.batFirst) {
      return winner;
    }

    return otherTeam(winner.id);
  }

  // ==========================================================
  // BOWLING TEAM
  // ==========================================================

  TossTeam? get bowlingTeam {
    final batting = battingTeam;

    if (batting == null) {
      return null;
    }

    return otherTeam(batting.id);
  }

  // ==========================================================
  // BATTING PLAYERS
  // ==========================================================

  List<TossPlayer> get battingPlayers {
    return battingTeam?.players
            .where(
              (player) => player.canBat,
            )
            .toList() ??
        const [];
  }

  // ==========================================================
  // BOWLERS
  // ==========================================================

  List<TossPlayer> get bowlingPlayers {
    return bowlingTeam?.players
            .where(
              (player) => player.canBowl,
            )
            .toList() ??
        const [];
  }

  // ==========================================================
  // VALIDATION
  // ==========================================================

  bool get canConfirmTossChoice {
    return tossWinnerTeamId != null && tossChoice != null && !isSavingToss;
  }

  bool get canStartScoring {
    return strikerId != null &&
        nonStrikerId != null &&
        openingBowlerId != null &&
        strikerId != nonStrikerId;
  }

  // ==========================================================
  // UI
  // ==========================================================

  String get screenTitle {
    if (step == ConductTossStep.selectOpeners) {
      return 'Select Openers';
    }

    return 'Conduct Toss';
  }

  int get progressStep {
    switch (step) {
      case ConductTossStep.flipCoin:
      case ConductTossStep.coinResult:
        return 0;

      case ConductTossStep.chooseBatBowl:
        return 1;

      case ConductTossStep.selectOpeners:
        return 2;
    }
  }

  // ==========================================================
  // COPY
  // ==========================================================

  ConductTossState copyWith({
    ConductTossStep? step,
    TossTeam? team1,
    TossTeam? team2,
    String? callerTeamId,
    TossCoinSide? callerChoice,
    bool? isFlipping,
    TossCoinSide? landedSide,
    String? tossWinnerTeamId,
    TossBatBowlChoice? tossChoice,
    bool? isSavingToss,
    String? strikerId,
    bool clearStriker = false,
    String? nonStrikerId,
    bool clearNonStriker = false,
    String? openingBowlerId,
    bool clearOpeningBowler = false,
    String? errorMessage,
    bool clearError = false,
  }) {
    return ConductTossState(
      step: step ?? this.step,
      team1: team1 ?? this.team1,
      team2: team2 ?? this.team2,
      callerTeamId: callerTeamId ?? this.callerTeamId,
      callerChoice: callerChoice ?? this.callerChoice,
      isFlipping: isFlipping ?? this.isFlipping,
      landedSide: landedSide ?? this.landedSide,
      tossWinnerTeamId: tossWinnerTeamId ?? this.tossWinnerTeamId,
      tossChoice: tossChoice ?? this.tossChoice,
      isSavingToss: isSavingToss ?? this.isSavingToss,
      strikerId: clearStriker ? null : strikerId ?? this.strikerId,
      nonStrikerId: clearNonStriker ? null : nonStrikerId ?? this.nonStrikerId,
      openingBowlerId:
          clearOpeningBowler ? null : openingBowlerId ?? this.openingBowlerId,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [
        step,
        team1,
        team2,
        callerTeamId,
        callerChoice,
        isFlipping,
        landedSide,
        tossWinnerTeamId,
        tossChoice,
        isSavingToss,
        strikerId,
        nonStrikerId,
        openingBowlerId,
        errorMessage,
      ];
}

// ============================================================
// EVENTS
//
// IMPORTANT:
// Do NOT call this ConductTossEvent.
// MatchScoringBloc previously had a class with that name.
// ============================================================

sealed class ConductTossAction extends Equatable {
  const ConductTossAction();

  @override
  List<Object?> get props => [];
}

// ============================================================
// FLIP
// ============================================================

class FlipCoinRequested extends ConductTossAction {}

// ============================================================
// CONTINUE
// ============================================================

class ContinueAfterCoinResult extends ConductTossAction {}

// ============================================================
// BAT / BOWL
// ============================================================

class TossChoiceSelected extends ConductTossAction {
  final TossBatBowlChoice choice;

  const TossChoiceSelected(
    this.choice,
  );

  @override
  List<Object?> get props => [
        choice,
      ];
}

// ============================================================
// SAVE TOSS
// ============================================================

class ConfirmTossChoice extends ConductTossAction {}

// ============================================================
// OPENERS
// ============================================================

class StrikerSelected extends ConductTossAction {
  final String playerId;

  const StrikerSelected(
    this.playerId,
  );

  @override
  List<Object?> get props => [
        playerId,
      ];
}

class NonStrikerSelected extends ConductTossAction {
  final String playerId;

  const NonStrikerSelected(
    this.playerId,
  );

  @override
  List<Object?> get props => [
        playerId,
      ];
}

class OpeningBowlerSelected extends ConductTossAction {
  final String playerId;

  const OpeningBowlerSelected(
    this.playerId,
  );

  @override
  List<Object?> get props => [
        playerId,
      ];
}

// ============================================================
// BLOC
// ============================================================

class ConductTossBloc extends Bloc<ConductTossAction, ConductTossState> {
  final ConductTossUseCase conductTossUseCase;

  /// Actual repository/domain match id.
  final String matchId;

  final TossCoinSide? forcedCoinSide;

  final Random _random = Random();

  ConductTossBloc({
    required this.conductTossUseCase,
    required this.matchId,
    required TossTeam team1,
    required TossTeam team2,
    required String callerTeamId,
    TossCoinSide callerChoice = TossCoinSide.tails,
    this.forcedCoinSide,
  }) : super(
          ConductTossState(
            team1: team1,
            team2: team2,
            callerTeamId: callerTeamId,
            callerChoice: callerChoice,
          ),
        ) {
    on<FlipCoinRequested>(
      _onFlipCoin,
    );

    on<ContinueAfterCoinResult>(
      _onContinueAfterCoinResult,
    );

    on<TossChoiceSelected>(
      _onTossChoiceSelected,
    );

    on<ConfirmTossChoice>(
      _onConfirmTossChoice,
    );

    on<StrikerSelected>(
      _onStrikerSelected,
    );

    on<NonStrikerSelected>(
      _onNonStrikerSelected,
    );

    on<OpeningBowlerSelected>(
      _onOpeningBowlerSelected,
    );
  }

  // ==========================================================
  // FLIP COIN
  // ==========================================================

  Future<void> _onFlipCoin(
    FlipCoinRequested event,
    Emitter<ConductTossState> emit,
  ) async {
    if (state.isFlipping) {
      return;
    }

    emit(
      state.copyWith(
        isFlipping: true,
        clearError: true,
      ),
    );

    await Future<void>.delayed(
      const Duration(
        milliseconds: 1200,
      ),
    );

    final result = forcedCoinSide ??
        (_random.nextBool() ? TossCoinSide.heads : TossCoinSide.tails);

    final callerWon = result == state.callerChoice;

    final winner = callerWon
        ? state.teamById(
            state.callerTeamId,
          )
        : state.otherTeam(
            state.callerTeamId,
          );

    emit(
      state.copyWith(
        isFlipping: false,
        landedSide: result,
        tossWinnerTeamId: winner.id,
        step: ConductTossStep.coinResult,
      ),
    );
  }

  // ==========================================================
  // CONTINUE AFTER RESULT
  // ==========================================================

  void _onContinueAfterCoinResult(
    ContinueAfterCoinResult event,
    Emitter<ConductTossState> emit,
  ) {
    if (state.tossWinner == null) {
      return;
    }

    emit(
      state.copyWith(
        step: ConductTossStep.chooseBatBowl,
        clearError: true,
      ),
    );
  }

  // ==========================================================
  // SELECT BAT / BOWL
  // ==========================================================

  void _onTossChoiceSelected(
    TossChoiceSelected event,
    Emitter<ConductTossState> emit,
  ) {
    emit(
      state.copyWith(
        tossChoice: event.choice,

        // Reset opener selections if user changes
        // Bat First / Bowl First.
        clearStriker: true,
        clearNonStriker: true,
        clearOpeningBowler: true,

        clearError: true,
      ),
    );
  }

  // ==========================================================
  // SAVE TOSS
  // ==========================================================

  Future<void> _onConfirmTossChoice(
    ConfirmTossChoice event,
    Emitter<ConductTossState> emit,
  ) async {
    final winnerId = state.tossWinnerTeamId;

    final choice = state.tossChoice;

    if (winnerId == null || choice == null || state.isSavingToss) {
      return;
    }

    emit(
      state.copyWith(
        isSavingToss: true,
        clearError: true,
      ),
    );

    try {
      final domainChoice = choice == TossBatBowlChoice.batFirst
          ? TossChoice.bat
          : TossChoice.bowl;

      final tossResult = TossResultEntity(
        winnerTeamId: winnerId,
        choice: domainChoice,
      );

      // ======================================================
      // ConductTossBloc now owns toss persistence.
      // ======================================================

      await conductTossUseCase(
        matchId,
        tossResult,
      );

      // ======================================================
      // Set sensible default selections.
      //
      // User can still change all of these.
      // ======================================================

      final battingPlayers = state.battingPlayers;

      final bowlingPlayers = state.bowlingPlayers;

      final defaultStriker =
          battingPlayers.isNotEmpty ? battingPlayers[0].id : null;

      final defaultNonStriker =
          battingPlayers.length > 1 ? battingPlayers[1].id : null;

      final defaultBowler =
          bowlingPlayers.isNotEmpty ? bowlingPlayers[0].id : null;

      emit(
        state.copyWith(
          isSavingToss: false,
          strikerId: defaultStriker,
          nonStrikerId: defaultNonStriker,
          openingBowlerId: defaultBowler,
          step: ConductTossStep.selectOpeners,
          clearError: true,
        ),
      );
    } catch (error) {
      emit(
        state.copyWith(
          isSavingToss: false,
          errorMessage: 'Unable to save toss. Please try again.',
        ),
      );
    }
  }

  // ==========================================================
  // STRIKER
  // ==========================================================

  void _onStrikerSelected(
    StrikerSelected event,
    Emitter<ConductTossState> emit,
  ) {
    final valid = state.battingPlayers.any(
      (player) => player.id == event.playerId,
    );

    if (!valid) {
      return;
    }

    if (event.playerId == state.nonStrikerId) {
      return;
    }

    emit(
      state.copyWith(
        strikerId: event.playerId,
        clearError: true,
      ),
    );
  }

  // ==========================================================
  // NON STRIKER
  // ==========================================================

  void _onNonStrikerSelected(
    NonStrikerSelected event,
    Emitter<ConductTossState> emit,
  ) {
    final valid = state.battingPlayers.any(
      (player) => player.id == event.playerId,
    );

    if (!valid) {
      return;
    }

    if (event.playerId == state.strikerId) {
      return;
    }

    emit(
      state.copyWith(
        nonStrikerId: event.playerId,
        clearError: true,
      ),
    );
  }

  // ==========================================================
  // OPENING BOWLER
  // ==========================================================

  void _onOpeningBowlerSelected(
    OpeningBowlerSelected event,
    Emitter<ConductTossState> emit,
  ) {
    final valid = state.bowlingPlayers.any(
      (player) => player.id == event.playerId && player.canBowl,
    );

    if (!valid) {
      return;
    }

    emit(
      state.copyWith(
        openingBowlerId: event.playerId,
        clearError: true,
      ),
    );
  }
}
