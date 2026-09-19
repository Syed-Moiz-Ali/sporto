import 'dart:math';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:referee_data/referee_data.dart';
import 'package:shared_domain/shared_domain.dart';

// ============================================================
// FLOW
// ============================================================

enum ConductTossStep {
  flipCoin,
  coinResult,
  chooseBatBowl,
  selectOpeners,
  matchReady,
}

// ============================================================
// MODE
// ============================================================

enum TossMode {
  flipCoin,
  enterResult,
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
  final String? logoUrl;

  final List<TossPlayer> players;

  const TossTeam({
    required this.id,
    required this.name,
    required this.players,
    this.logoUrl,
  });

  @override
  List<Object?> get props => [
        id,
        name,
        players,
        logoUrl,
      ];

  static List<TossPlayer> dummyPlayersFor(String teamId, String teamName) {
    final lower = teamName.toLowerCase();
    final isTeam1 = teamId == '1' ||
        lower.contains('delhi') ||
        lower.contains('warrior');

    if (isTeam1) {
      return const [
        TossPlayer(id: '1', name: 'Shrvn Prajapati', captain: true),
        TossPlayer(id: '2', name: 'Amit Kumar'),
        TossPlayer(id: '3', name: 'R. Sharma'),
        TossPlayer(id: '4', name: 'Virat Singh'),
        TossPlayer(id: '5', name: 'Suresh Raina'),
        TossPlayer(id: '6', name: 'Hardik Patel'),
        TossPlayer(id: '7', name: 'Rishabh Pant'),
        TossPlayer(id: '8', name: 'Ravindra Jadeja'),
        TossPlayer(id: '9', name: 'Jasprit Bumrah', canBat: false),
        TossPlayer(id: '10', name: 'Mohammed Shami', canBat: false),
        TossPlayer(id: '11', name: 'Yuzvendra Chahal', canBat: false),
      ];
    } else {
      return const [
        TossPlayer(id: '12', name: 'Dev Kumar', captain: true),
        TossPlayer(id: '13', name: 'David Warner'),
        TossPlayer(id: '14', name: 'Kane Williamson'),
        TossPlayer(id: '15', name: 'Rashid Khan'),
        TossPlayer(id: '16', name: 'Bhuvneshwar Kumar'),
        TossPlayer(id: '17', name: 'T. Natarajan', canBat: false),
        TossPlayer(id: '18', name: 'Abhishek Sharma'),
        TossPlayer(id: '19', name: 'Rahul Tripathi'),
        TossPlayer(id: '20', name: 'Aiden Markram'),
        TossPlayer(id: '21', name: 'Heinrich Klaasen'),
        TossPlayer(id: '22', name: 'Mohammed Siraj', canBat: false),
      ];
    }
  }
}

// ============================================================
// STATE
// ============================================================

class ConductTossState extends Equatable {
  final ConductTossStep step;
  final TossMode tossMode;
  final bool hasSelectedCaller;
  final String? manualWinnerTeamId;

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
    this.tossMode = TossMode.flipCoin,
    this.hasSelectedCaller = false,
    this.manualWinnerTeamId,
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
    final team = battingTeam;
    if (team == null) return const [];
    return team.players.where((player) => player.canBat).toList();
  }

  // ==========================================================
  // BOWLERS
  // ==========================================================

  List<TossPlayer> get bowlingPlayers {
    final team = bowlingTeam;
    if (team == null) return const [];
    return team.players.where((player) => player.canBowl).toList();
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
    if (step == ConductTossStep.matchReady) {
      return 'Match Ready';
    }

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
      case ConductTossStep.selectOpeners:
        return 1;

      case ConductTossStep.matchReady:
        return 2;
    }
  }

  // ==========================================================
  // COPY
  // ==========================================================

  ConductTossState copyWith({
    ConductTossStep? step,
    TossMode? tossMode,
    bool? hasSelectedCaller,
    String? manualWinnerTeamId,
    bool clearManualWinner = false,
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
      tossMode: tossMode ?? this.tossMode,
      hasSelectedCaller: hasSelectedCaller ?? this.hasSelectedCaller,
      manualWinnerTeamId: clearManualWinner
          ? null
          : manualWinnerTeamId ?? this.manualWinnerTeamId,
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
        tossMode,
        hasSelectedCaller,
        manualWinnerTeamId,
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
// MODE & CALLER SELECTION
// ============================================================

class SelectTossMode extends ConductTossAction {
  final TossMode mode;
  const SelectTossMode(this.mode);

  @override
  List<Object?> get props => [mode];
}

class CallingTeamSelected extends ConductTossAction {
  final String teamId;
  const CallingTeamSelected(this.teamId);

  @override
  List<Object?> get props => [teamId];
}

class ResetCallingTeam extends ConductTossAction {}

class CallerChoiceSelected extends ConductTossAction {
  final TossCoinSide choice;
  const CallerChoiceSelected(this.choice);

  @override
  List<Object?> get props => [choice];
}

// ============================================================
// MANUAL RESULT (PHYSICAL COIN FLIP)
// ============================================================

class ManualWinnerSelected extends ConductTossAction {
  final String teamId;
  const ManualWinnerSelected(this.teamId);

  @override
  List<Object?> get props => [teamId];
}

class ConfirmManualTossResult extends ConductTossAction {}

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

class ConfirmStartingPlayers extends ConductTossAction {}

class ConfirmOpeners extends ConductTossAction {}

class EditOpenersRequested extends ConductTossAction {}

class StepBackRequested extends ConductTossAction {}

// ============================================================
// BLOC
// ============================================================

class ConductTossBloc extends Bloc<ConductTossAction, ConductTossState> {
  final ConductTossUseCase? conductTossUseCase;
  final RefereeRemoteDataSource? refereeRemoteDataSource;

  /// Actual repository/domain match id.
  final String matchId;

  final TossCoinSide? forcedCoinSide;

  final Random _random = Random();

  ConductTossBloc({
    this.conductTossUseCase,
    this.refereeRemoteDataSource,
    required this.matchId,
    required TossTeam team1,
    required TossTeam team2,
    required String callerTeamId,
    TossCoinSide callerChoice = TossCoinSide.tails,
    this.forcedCoinSide,
    TossMode tossMode = TossMode.flipCoin,
    bool hasSelectedCaller = false,
    RefereeTossResponse? initialToss,
  }) : super(
          ConductTossState(
            team1: team1,
            team2: team2,
            callerTeamId: initialToss?.toss.runtime.callingTeamId?.toString() ?? callerTeamId,
            callerChoice: callerChoice,
            tossMode: tossMode,
            hasSelectedCaller: hasSelectedCaller || initialToss?.toss.runtime.callingTeamId != null,
            step: initialToss?.toss.runtime.nextAction == 'SET_STARTING_PLAYERS'
                ? ConductTossStep.selectOpeners
                : initialToss?.toss.runtime.nextAction == 'SET_DECISION'
                    ? ConductTossStep.chooseBatBowl
                    : ConductTossStep.flipCoin,
            landedSide: _coinSideFromApi(initialToss?.toss.runtime.landedSide),
            tossWinnerTeamId: initialToss?.toss.runtime.winnerTeamId?.toString(),
            tossChoice: _choiceFromApi(initialToss?.toss.runtime.decision),
          ),
        ) {
    on<SelectTossMode>((event, emit) {
      emit(state.copyWith(
        tossMode: event.mode,
        clearError: true,
      ));
    });

    on<CallingTeamSelected>((event, emit) {
      if (event.teamId == state.team1.id || event.teamId == state.team2.id) {
        emit(state.copyWith(
          callerTeamId: event.teamId,
          hasSelectedCaller: true,
          clearError: true,
        ));
      }
    });

    on<ResetCallingTeam>((event, emit) {
      emit(state.copyWith(
        hasSelectedCaller: false,
        clearError: true,
      ));
    });

    on<CallerChoiceSelected>((event, emit) {
      emit(state.copyWith(
        callerChoice: event.choice,
        clearError: true,
      ));
    });

    on<ManualWinnerSelected>((event, emit) {
      if (event.teamId == state.team1.id || event.teamId == state.team2.id) {
        emit(state.copyWith(
          manualWinnerTeamId: event.teamId,
          clearError: true,
        ));
      }
    });

    on<ConfirmManualTossResult>(_onConfirmManualTossResult);

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

    on<ConfirmStartingPlayers>(
      _onConfirmStartingPlayers,
    );

    on<ConfirmOpeners>((event, emit) {
      emit(state.copyWith(step: ConductTossStep.matchReady, clearError: true));
    });

    on<EditOpenersRequested>((event, emit) {
      emit(
          state.copyWith(step: ConductTossStep.selectOpeners, clearError: true));
    });

    on<StepBackRequested>((event, emit) {
      emit(
          state.copyWith(step: ConductTossStep.selectOpeners, clearError: true));
    });
  }

  // ==========================================================
  // MANUAL RESULT
  // ==========================================================

  Future<void> _onConfirmManualTossResult(
    ConfirmManualTossResult event,
    Emitter<ConductTossState> emit,
  ) async {
    final winnerId = state.manualWinnerTeamId;
    if (winnerId == null || state.isSavingToss) {
      return;
    }

    emit(state.copyWith(isSavingToss: true, clearError: true));

    try {
      final parsedWinnerId = int.tryParse(winnerId) ?? 1;
      try {
        await refereeRemoteDataSource?.updateMatchTossData(
          matchId,
          RefereeTossUpdateRequest.enterResult(
            winnerTeamId: parsedWinnerId,
          ),
        );
      } catch (_) {
        // Backend toss fallback
      }

      emit(
        state.copyWith(
          isSavingToss: false,
          tossWinnerTeamId: winnerId,
          step: ConductTossStep.chooseBatBowl,
          clearError: true,
        ),
      );
    } catch (error) {
      emit(
        state.copyWith(
          isSavingToss: false,
          errorMessage: 'Unable to save toss result. Please try again.',
        ),
      );
    }
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

    TossCoinSide? remoteLandedSide;
    String? remoteWinnerTeamId;

    try {
      final callingTeamIdInt = int.tryParse(state.callerTeamId) ?? 1;
      await refereeRemoteDataSource?.updateMatchTossData(
        matchId,
        RefereeTossUpdateRequest.call(
          calledSide: _coinSideToApi(state.callerChoice),
          callingTeamId: callingTeamIdInt,
        ),
      );
      final flip = await refereeRemoteDataSource?.updateMatchTossData(
        matchId,
        RefereeTossUpdateRequest.flip(),
      );
      remoteLandedSide = _coinSideFromApi(flip?.toss.runtime.landedSide);
      final winnerTeamId = flip?.toss.runtime.winnerTeamId;
      if (winnerTeamId != null) {
        remoteWinnerTeamId = winnerTeamId.toString();
      }
    } catch (_) {
      // Backend toss is still returning 404 for some QA matches. Keep the
      // existing local toss flow usable until backend test data is available.
    }

    final result = remoteLandedSide ??
        forcedCoinSide ??
        (_random.nextBool() ? TossCoinSide.heads : TossCoinSide.tails);

    final callerWon = result == state.callerChoice;

    final winner = remoteWinnerTeamId == state.team1.id
        ? state.team1
        : remoteWinnerTeamId == state.team2.id
            ? state.team2
            : (callerWon
                ? state.teamById(
                    state.callerTeamId,
                  )
                : state.otherTeam(
                    state.callerTeamId,
                  ));

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

      await conductTossUseCase?.call(
        matchId,
        tossResult,
      );

      try {
        await refereeRemoteDataSource?.updateMatchTossData(
          matchId,
          RefereeTossUpdateRequest.setDecision(
            decision: _decisionToApi(choice),
          ),
        );
      } catch (_) {
        // Local repository save above remains the fallback source.
      }

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

  Future<void> _onConfirmStartingPlayers(
    ConfirmStartingPlayers event,
    Emitter<ConductTossState> emit,
  ) async {
    final cleanStriker = state.strikerId?.replaceAll(RegExp(r'[^0-9]'), '');
    final cleanNonStriker = state.nonStrikerId?.replaceAll(RegExp(r'[^0-9]'), '');
    final cleanOpeningBowler =
        state.openingBowlerId?.replaceAll(RegExp(r'[^0-9]'), '');
    final strikerId = int.tryParse(cleanStriker ?? state.strikerId ?? '');
    final nonStrikerId = int.tryParse(cleanNonStriker ?? state.nonStrikerId ?? '');
    final openingBowlerId =
        int.tryParse(cleanOpeningBowler ?? state.openingBowlerId ?? '');

    if (strikerId == null ||
        nonStrikerId == null ||
        openingBowlerId == null ||
        !state.canStartScoring) {
      return;
    }

    try {
      await refereeRemoteDataSource?.updateMatchTossData(
        matchId,
        RefereeTossUpdateRequest.setStartingPlayers(
          strikerUserId: strikerId,
          nonStrikerUserId: nonStrikerId,
          openingBowlerUserId: openingBowlerId,
        ),
      );
    } catch (_) {
      // Do not block navigation while backend toss data is not available.
    }
  }

  static String _coinSideToApi(TossCoinSide side) {
    return side == TossCoinSide.heads ? 'HEADS' : 'TAILS';
  }

  static TossCoinSide? _coinSideFromApi(String? value) {
    return switch (value?.toUpperCase()) {
      'HEADS' => TossCoinSide.heads,
      'TAILS' => TossCoinSide.tails,
      _ => null,
    };
  }

  static TossBatBowlChoice? _choiceFromApi(String? value) {
    switch (value) {
      case 'BAT_FIRST':
        return TossBatBowlChoice.batFirst;
      case 'BOWL_FIRST':
        return TossBatBowlChoice.bowlFirst;
      default:
        return null;
    }
  }

  static String _decisionToApi(TossBatBowlChoice choice) {
    return choice == TossBatBowlChoice.batFirst ? 'BAT_FIRST' : 'BOWL_FIRST';
  }
}
