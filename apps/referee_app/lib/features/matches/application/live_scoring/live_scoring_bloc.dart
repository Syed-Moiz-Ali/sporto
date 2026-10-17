import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:referee_data/referee_data.dart';

// ============================================================
// TEAM / PLAYER
// ============================================================

class ScoringBowler extends Equatable {
  final String id;
  final String name;
  final bool captain;
  final bool enabled;

  const ScoringBowler({
    required this.id,
    required this.name,
    this.captain = false,
    this.enabled = true,
  });

  String get displayName => captain ? '$name (Captain)' : name;

  @override
  List<Object?> get props => [
        id,
        name,
        captain,
        enabled,
      ];
}

class ScoringTeam extends Equatable {
  final String id;
  final String name;

  /// Players eligible to bowl when this team is fielding.
  final List<ScoringBowler> bowlers;

  const ScoringTeam({
    required this.id,
    required this.name,
    required this.bowlers,
  });

  @override
  List<Object?> get props => [
        id,
        name,
        bowlers,
      ];
}

// ============================================================
// DELIVERY
// ============================================================

enum ScoringDeliveryType {
  run,
  wicket,
  wide,
  noBall,
}

class ScoringDelivery extends Equatable {
  final ScoringDeliveryType type;
  final int runs;

  const ScoringDelivery({
    required this.type,
    required this.runs,
  });

  bool get isLegal =>
      type != ScoringDeliveryType.wide && type != ScoringDeliveryType.noBall;

  @override
  List<Object?> get props => [
        type,
        runs,
      ];
}

// ============================================================
// INNINGS RESULT
// ============================================================

class ScoringInningsResult extends Equatable {
  final String battingTeamId;
  final String battingTeamName;

  final int runs;
  final int wickets;

  final int overs;
  final int legalBallsInLastOver;

  const ScoringInningsResult({
    required this.battingTeamId,
    required this.battingTeamName,
    required this.runs,
    required this.wickets,
    required this.overs,
    required this.legalBallsInLastOver,
  });

  String get scoreText => '$runs/$wickets';

  @override
  List<Object?> get props => [
        battingTeamId,
        battingTeamName,
        runs,
        wickets,
        overs,
        legalBallsInLastOver,
      ];
}

// ============================================================
// FLOW
// ============================================================
enum LiveScoringStep {
  selectBowler,
  scoring,
  overComplete,

  inningsBreak,

  finalResult,

  superOverReady,
  superOverSelectBowler,
  superOverScoring,
  superOverComplete,
  superOverBreak,
  superOverFinalResult,

  resultSubmitted,
}
// ============================================================
// STATE
// ============================================================

class LiveScoringState extends Equatable {
  final LiveScoringStep step;

  final ScoringTeam teamA;
  final ScoringTeam teamB;

  /// Team that won toss / starts batting.
  final String firstBattingTeamId;

  /// 1 or 2
  final int inningsNumber;

  final int regulationOvers;
  final int maxWickets;

  /// zero based
  final int currentOverIndex;

  final int runs;
  final int wickets;

  final List<ScoringDelivery> currentOverDeliveries;

  final String? selectedBowlerId;
  final String? strikerId;
  final String? nonStrikerId;
  final Set<String> dismissedPlayerIds;
  final bool awaitingReplacement;
  final String? previousBowlerId;

  final ScoringInningsResult? firstInnings;
  final ScoringInningsResult? secondInnings;

  /// Server-advertised allowed actions (source of truth for button gating).
  /// Lives in the bloc so it survives widget rebuilds.
  final Set<String> allowedActions;

  /// Whether the match is LIVE on the backend.
  final bool matchLive;

  // ==========================================================
  // SUPER OVER
  // ==========================================================

  final bool isSuperOver;

  /// 1 or 2 inside super over.
  final int superOverInningsNumber;

  final int superOverRound;

  final ScoringInningsResult? firstSuperOverInnings;
  final ScoringInningsResult? secondSuperOverInnings;

  const LiveScoringState({
    required this.teamA,
    required this.teamB,
    required this.firstBattingTeamId,
    required this.regulationOvers,
    this.maxWickets = 10,
    this.step = LiveScoringStep.selectBowler,
    this.inningsNumber = 1,
    this.currentOverIndex = 0,
    this.runs = 0,
    this.wickets = 0,
    this.currentOverDeliveries = const [],
    this.selectedBowlerId,
    this.strikerId,
    this.nonStrikerId,
    this.dismissedPlayerIds = const {},
    this.awaitingReplacement = false,
    this.previousBowlerId,
    this.firstInnings,
    this.secondInnings,
    this.allowedActions = const {},
    this.matchLive = false,
    this.isSuperOver = false,
    this.superOverInningsNumber = 1,
    this.superOverRound = 0,
    this.firstSuperOverInnings,
    this.secondSuperOverInnings,
  });

  // ==========================================================
  // TEAM HELPERS
  // ==========================================================

  ScoringTeam get firstBattingTeam =>
      teamA.id == firstBattingTeamId ? teamA : teamB;

  ScoringTeam get firstBowlingTeam =>
      teamA.id == firstBattingTeamId ? teamB : teamA;

  ScoringTeam get currentBattingTeam {
    if (isSuperOver) {
      return superOverInningsNumber == 1 ? firstBattingTeam : firstBowlingTeam;
    }

    return inningsNumber == 1 ? firstBattingTeam : firstBowlingTeam;
  }

  ScoringTeam get currentBowlingTeam {
    if (isSuperOver) {
      return superOverInningsNumber == 1 ? firstBowlingTeam : firstBattingTeam;
    }

    return inningsNumber == 1 ? firstBowlingTeam : firstBattingTeam;
  }

  List<ScoringBowler> get availableBowlers => currentBowlingTeam.bowlers;

  // ==========================================================
  // OVER
  // ==========================================================

  int get displayOver => currentOverIndex + 1;

  int get totalOvers => isSuperOver ? 1 : regulationOvers;

  /// Whether the innings over limit is known (0 means "not provided by API").
  bool get hasOversLimit => isSuperOver || regulationOvers > 0;

  int get legalBallCount =>
      currentOverDeliveries.where((delivery) => delivery.isLegal).length;

  bool get overComplete => legalBallCount >= 6;

  bool get isFirstBall =>
      currentOverIndex == 0 && currentOverDeliveries.isEmpty;

  bool get isLastOver => hasOversLimit && displayOver >= totalOvers;

  bool get isAllOut => maxWickets > 0 && wickets >= maxWickets;

  // ==========================================================
  // BOWLER
  // ==========================================================

  ScoringBowler? get selectedBowler {
    if (selectedBowlerId == null) {
      return null;
    }

    for (final bowler in availableBowlers) {
      if (bowler.id == selectedBowlerId) {
        return bowler;
      }
    }

    return null;
  }

  bool get canStartOver =>
      selectedBowler != null &&
      strikerId != null &&
      nonStrikerId != null &&
      strikerId != nonStrikerId;

  bool get openersConfigured => strikerId != null && nonStrikerId != null;

  String get currentBowlerName => selectedBowler?.name ?? '';

  String get strikerName => _playerName(currentBattingTeam, strikerId);
  String get nonStrikerName => _playerName(currentBattingTeam, nonStrikerId);
  List<ScoringBowler> get replacementBatters => currentBattingTeam.bowlers
      .where((p) =>
          !dismissedPlayerIds.contains(p.id) &&
          p.id != nonStrikerId &&
          p.id != strikerId)
      .toList();

  String _playerName(ScoringTeam team, String? id) => team.bowlers
      .firstWhere((player) => player.id == id,
          orElse: () => const ScoringBowler(id: '', name: ''))
      .name;

  bool isBowlerEligible(
    ScoringBowler bowler,
  ) {
    if (!bowler.enabled) {
      return false;
    }

    // Prevent same bowler bowling consecutive regulation overs.
    if (!isSuperOver && bowler.id == previousBowlerId) {
      return false;
    }

    return true;
  }

  // ==========================================================
  // SCORES
  // ==========================================================

  String get scoreText => '$runs/$wickets';

  String get progressText {
    if (isSuperOver) {
      return 'Ball $legalBallCount/6';
    }

    // Only show the innings over limit when the API provided one.
    final limit = regulationOvers > 0 ? '/$regulationOvers' : '';
    return 'Over $displayOver$limit  •  Ball $legalBallCount/6';
  }

  // ==========================================================
  // SECOND INNINGS TARGET
  // ==========================================================

  int? get target {
    if (firstInnings == null) {
      return null;
    }

    if (isSuperOver) {
      if (superOverInningsNumber == 2 && firstSuperOverInnings != null) {
        return firstSuperOverInnings!.runs + 1;
      }

      return null;
    }

    if (inningsNumber == 2) {
      return firstInnings!.runs + 1;
    }

    return null;
  }

  int? get runsRequired {
    final chaseTarget = target;

    if (chaseTarget == null) {
      return null;
    }

    final required = chaseTarget - runs;

    return required < 0 ? 0 : required;
  }

  bool get targetReached {
    final chaseTarget = target;

    if (chaseTarget == null) {
      return false;
    }

    return runs >= chaseTarget;
  }

  // ==========================================================
  // WINNER
  // ==========================================================

  String? get regulationWinner {
    if (firstInnings == null || secondInnings == null) {
      return null;
    }

    if (firstInnings!.runs > secondInnings!.runs) {
      return firstInnings!.battingTeamName;
    }

    if (secondInnings!.runs > firstInnings!.runs) {
      return secondInnings!.battingTeamName;
    }

    return null;
  }

  bool get regulationTied {
    if (firstInnings == null || secondInnings == null) {
      return false;
    }

    return firstInnings!.runs == secondInnings!.runs;
  }

  String? get superOverWinner {
    if (firstSuperOverInnings == null || secondSuperOverInnings == null) {
      return null;
    }

    if (firstSuperOverInnings!.runs > secondSuperOverInnings!.runs) {
      return firstSuperOverInnings!.battingTeamName;
    }

    if (secondSuperOverInnings!.runs > firstSuperOverInnings!.runs) {
      return secondSuperOverInnings!.battingTeamName;
    }

    return null;
  }

  // ==========================================================
  // COPY
  // ==========================================================

  LiveScoringState copyWith({
    LiveScoringStep? step,
    ScoringTeam? teamA,
    ScoringTeam? teamB,
    String? firstBattingTeamId,
    int? inningsNumber,
    int? regulationOvers,
    int? maxWickets,
    int? currentOverIndex,
    int? runs,
    int? wickets,
    List<ScoringDelivery>? currentOverDeliveries,
    String? selectedBowlerId,
    bool clearSelectedBowler = false,
    String? strikerId,
    String? nonStrikerId,
    bool clearStriker = false,
    bool clearNonStriker = false,
    Set<String>? dismissedPlayerIds,
    bool clearDismissed = false,
    bool? awaitingReplacement,
    String? previousBowlerId,
    bool clearPreviousBowler = false,
    ScoringInningsResult? firstInnings,
    ScoringInningsResult? secondInnings,
    Set<String>? allowedActions,
    bool? matchLive,
    bool? isSuperOver,
    int? superOverInningsNumber,
    int? superOverRound,
    ScoringInningsResult? firstSuperOverInnings,
    ScoringInningsResult? secondSuperOverInnings,
    bool clearFirstSuperOver = false,
    bool clearSecondSuperOver = false,
  }) {
    return LiveScoringState(
      step: step ?? this.step,
      teamA: teamA ?? this.teamA,
      teamB: teamB ?? this.teamB,
      firstBattingTeamId: firstBattingTeamId ?? this.firstBattingTeamId,
      inningsNumber: inningsNumber ?? this.inningsNumber,
      regulationOvers: regulationOvers ?? this.regulationOvers,
      maxWickets: maxWickets ?? this.maxWickets,
      currentOverIndex: currentOverIndex ?? this.currentOverIndex,
      runs: runs ?? this.runs,
      wickets: wickets ?? this.wickets,
      currentOverDeliveries:
          currentOverDeliveries ?? this.currentOverDeliveries,
      selectedBowlerId: clearSelectedBowler
          ? null
          : selectedBowlerId ?? this.selectedBowlerId,
      strikerId: clearStriker ? null : strikerId ?? this.strikerId,
      nonStrikerId: clearNonStriker ? null : nonStrikerId ?? this.nonStrikerId,
      dismissedPlayerIds: clearDismissed
          ? const {}
          : dismissedPlayerIds ?? this.dismissedPlayerIds,
      awaitingReplacement: awaitingReplacement ?? this.awaitingReplacement,
      previousBowlerId: clearPreviousBowler
          ? null
          : previousBowlerId ?? this.previousBowlerId,
      firstInnings: firstInnings ?? this.firstInnings,
      secondInnings: secondInnings ?? this.secondInnings,
      allowedActions: allowedActions ?? this.allowedActions,
      matchLive: matchLive ?? this.matchLive,
      isSuperOver: isSuperOver ?? this.isSuperOver,
      superOverInningsNumber:
          superOverInningsNumber ?? this.superOverInningsNumber,
      superOverRound: superOverRound ?? this.superOverRound,
      firstSuperOverInnings: clearFirstSuperOver
          ? null
          : firstSuperOverInnings ?? this.firstSuperOverInnings,
      secondSuperOverInnings: clearSecondSuperOver
          ? null
          : secondSuperOverInnings ?? this.secondSuperOverInnings,
    );
  }

  @override
  List<Object?> get props => [
        step,
        teamA,
        teamB,
        firstBattingTeamId,
        inningsNumber,
        regulationOvers,
        maxWickets,
        currentOverIndex,
        runs,
        wickets,
        currentOverDeliveries,
        selectedBowlerId,
        strikerId,
        nonStrikerId,
        dismissedPlayerIds,
        awaitingReplacement,
        previousBowlerId,
        firstInnings,
        secondInnings,
        allowedActions,
        matchLive,
        isSuperOver,
        superOverInningsNumber,
        superOverRound,
        firstSuperOverInnings,
        secondSuperOverInnings,
      ];
}

// ============================================================
// EVENTS
// ============================================================

sealed class LiveScoringEvent extends Equatable {
  const LiveScoringEvent();

  @override
  List<Object?> get props => [];
}

class SelectBowlerEvent extends LiveScoringEvent {
  final String bowlerId;

  const SelectBowlerEvent(
    this.bowlerId,
  );

  @override
  List<Object?> get props => [
        bowlerId,
      ];
}

class StartSelectedOverEvent extends LiveScoringEvent {}

class ApplyServerScoreEvent extends LiveScoringEvent {
  final RefereeScoreResponse response;

  const ApplyServerScoreEvent(this.response);

  @override
  List<Object?> get props => [response];
}

class SelectStrikerEvent extends LiveScoringEvent {
  final String playerId;

  const SelectStrikerEvent(this.playerId);

  @override
  List<Object?> get props => [playerId];
}

class SelectNonStrikerEvent extends LiveScoringEvent {
  final String playerId;

  const SelectNonStrikerEvent(this.playerId);

  @override
  List<Object?> get props => [playerId];
}

class RecordRunsEvent extends LiveScoringEvent {
  final int runs;

  const RecordRunsEvent(
    this.runs,
  );

  @override
  List<Object?> get props => [runs];
}

class RecordWicketEvent extends LiveScoringEvent {}

class RecordWideEvent extends LiveScoringEvent {}

class RecordNoBallEvent extends LiveScoringEvent {}

class ReplacementBatterSelected extends LiveScoringEvent {
  final String playerId;
  const ReplacementBatterSelected(this.playerId);
  @override
  List<Object?> get props => [playerId];
}

class ContinueAfterOverEvent extends LiveScoringEvent {}

class StartSecondInningsEvent extends LiveScoringEvent {}

class StartSuperOverEvent extends LiveScoringEvent {}

class StartSecondSuperOverInningsEvent extends LiveScoringEvent {}

class SubmitFinalResultEvent extends LiveScoringEvent {}

// ============================================================
// BLOC
// ============================================================

class LiveScoringBloc extends Bloc<LiveScoringEvent, LiveScoringState> {
  LiveScoringBloc({
    required ScoringTeam teamA,
    required ScoringTeam teamB,
    required String firstBattingTeamId,
    int initialInningsNumber = 1,
    int? initialFirstInningsRuns,
    int? initialFirstInningsWickets,
    int regulationOvers = 0,
    int maxWickets = 10,
    String? initialBowlerId,
    String? initialStrikerId,
    String? initialNonStrikerId,
    int initialRuns = 0,
    int initialWickets = 0,
    LiveScoringStep? initialStep,
  }) : super(
          LiveScoringState(
            teamA: teamA,
            teamB: teamB,
            firstBattingTeamId: firstBattingTeamId,
            inningsNumber: initialInningsNumber,
            firstInnings: _initialFirstInnings(
              initialFirstInningsRuns,
              initialFirstInningsWickets,
              firstBattingTeamId,
              teamA,
              teamB,
            ),
            regulationOvers: regulationOvers,
            maxWickets: maxWickets,
            step: initialStep ?? LiveScoringStep.selectBowler,
            runs: initialRuns,
            wickets: initialWickets,
            selectedBowlerId: initialBowlerId,
            strikerId: initialStrikerId,
            nonStrikerId: initialNonStrikerId,
          ),
        ) {
    on<SelectBowlerEvent>(
      _selectBowler,
    );

    on<SelectStrikerEvent>((event, emit) {
      final valid = state.currentBattingTeam.bowlers.any(
        (player) =>
            player.id == event.playerId &&
            !state.dismissedPlayerIds.contains(player.id),
      );

      if (!valid || event.playerId == state.nonStrikerId) {
        return;
      }

      emit(state.copyWith(strikerId: event.playerId));
    });

    on<SelectNonStrikerEvent>((event, emit) {
      final valid = state.currentBattingTeam.bowlers.any(
        (player) =>
            player.id == event.playerId &&
            !state.dismissedPlayerIds.contains(player.id),
      );

      if (!valid || event.playerId == state.strikerId) {
        return;
      }

      emit(state.copyWith(nonStrikerId: event.playerId));
    });

    on<StartSelectedOverEvent>(
      _startOver,
    );

    on<ApplyServerScoreEvent>(
      _applyServerState,
    );

    on<RecordRunsEvent>(
      _recordRuns,
    );

    on<RecordWicketEvent>(
      _recordWicket,
    );

    on<RecordWideEvent>(
      _recordWide,
    );

    on<RecordNoBallEvent>(
      _recordNoBall,
    );
    on<ReplacementBatterSelected>((event, emit) {
      if (!state.awaitingReplacement ||
          !state.replacementBatters.any((p) => p.id == event.playerId)) {
        return;
      }
      emit(state.copyWith(
        strikerId: event.playerId,
        awaitingReplacement: false,
      ));
    });

    on<ContinueAfterOverEvent>(
      _continueAfterOver,
    );

    on<StartSecondInningsEvent>(
      _startSecondInnings,
    );

    on<StartSuperOverEvent>(
      _startSuperOver,
    );

    on<StartSecondSuperOverInningsEvent>(
      _startSecondSuperOverInnings,
    );

    on<SubmitFinalResultEvent>(
      _submitFinalResult,
    );
  }

  // ==========================================================
  // SELECT BOWLER
  // ==========================================================

  void _selectBowler(
    SelectBowlerEvent event,
    Emitter<LiveScoringState> emit,
  ) {
    ScoringBowler? selected;

    for (final bowler in state.availableBowlers) {
      if (bowler.id == event.bowlerId) {
        selected = bowler;
        break;
      }
    }

    if (selected == null || !state.isBowlerEligible(selected)) {
      return;
    }

    emit(
      state.copyWith(
        selectedBowlerId: selected.id,
      ),
    );
  }

  void _startOver(
    StartSelectedOverEvent event,
    Emitter<LiveScoringState> emit,
  ) {
    if (!state.canStartOver) {
      return;
    }

    emit(
      state.copyWith(
        step: state.isSuperOver
            ? LiveScoringStep.superOverScoring
            : LiveScoringStep.scoring,
      ),
    );
  }

  // ==========================================================
  // DELIVERY EVENTS
  // ==========================================================

  void _recordRuns(
    RecordRunsEvent event,
    Emitter<LiveScoringState> emit,
  ) {
    _recordDelivery(
      ScoringDelivery(
        type: ScoringDeliveryType.run,
        runs: event.runs,
      ),
      emit,
    );
  }

  void _recordWicket(
    RecordWicketEvent event,
    Emitter<LiveScoringState> emit,
  ) {
    _recordDelivery(
      const ScoringDelivery(
        type: ScoringDeliveryType.wicket,
        runs: 0,
      ),
      emit,
    );
  }

  void _recordWide(
    RecordWideEvent event,
    Emitter<LiveScoringState> emit,
  ) {
    _recordDelivery(
      const ScoringDelivery(
        type: ScoringDeliveryType.wide,
        runs: 1,
      ),
      emit,
    );
  }

  void _recordNoBall(
    RecordNoBallEvent event,
    Emitter<LiveScoringState> emit,
  ) {
    _recordDelivery(
      const ScoringDelivery(
        type: ScoringDeliveryType.noBall,
        runs: 1,
      ),
      emit,
    );
  }

  // ==========================================================
  // RECORD DELIVERY
  // ==========================================================

  void _recordDelivery(
    ScoringDelivery delivery,
    Emitter<LiveScoringState> emit,
  ) {
    final validStep = state.step == LiveScoringStep.scoring ||
        state.step == LiveScoringStep.superOverScoring;

    if (!validStep) {
      return;
    }

    final deliveries = [
      ...state.currentOverDeliveries,
      delivery,
    ];

    final newRuns = state.runs + delivery.runs;

    var newWickets = state.wickets;

    if (delivery.type == ScoringDeliveryType.wicket) {
      newWickets++;
    }

    final legalBalls = deliveries.where((d) => d.isLegal).length;

    var updated = state.copyWith(
      runs: newRuns,
      wickets: newWickets,
      currentOverDeliveries: deliveries,
    );

    if (delivery.type == ScoringDeliveryType.wicket &&
        state.strikerId != null) {
      updated = updated.copyWith(
        dismissedPlayerIds: {...state.dismissedPlayerIds, state.strikerId!},
        awaitingReplacement: true,
      );
    }

    // An odd number of runs off the bat changes the striker for the next
    // delivery. Wides and no-balls do not change ends.
    if (delivery.type == ScoringDeliveryType.run &&
        delivery.runs.isOdd &&
        state.strikerId != null &&
        state.nonStrikerId != null) {
      updated = updated.copyWith(
        strikerId: state.nonStrikerId,
        nonStrikerId: state.strikerId,
      );
    }

    // ========================================================
    // SECOND INNINGS CHASE COMPLETED EARLY
    // ========================================================

    if (!state.isSuperOver &&
        state.inningsNumber == 2 &&
        state.firstInnings != null &&
        newRuns > state.firstInnings!.runs) {
      _finishSecondInnings(
        updated,
        emit,
      );
      return;
    }

    // ========================================================
    // SECOND SUPER OVER CHASE COMPLETED EARLY
    // ========================================================

    if (state.isSuperOver &&
        state.superOverInningsNumber == 2 &&
        state.firstSuperOverInnings != null &&
        newRuns > state.firstSuperOverInnings!.runs) {
      _finishSecondSuperOverInnings(
        updated,
        emit,
      );
      return;
    }

    // ========================================================
    // ALL OUT
    // ========================================================

    if (newWickets >= state.maxWickets) {
      if (state.isSuperOver) {
        if (state.superOverInningsNumber == 1) {
          _finishFirstSuperOverInnings(
            updated,
            emit,
          );
        } else {
          _finishSecondSuperOverInnings(
            updated,
            emit,
          );
        }
      } else if (state.inningsNumber == 1) {
        _finishFirstInnings(
          updated,
          emit,
        );
      } else {
        _finishSecondInnings(
          updated,
          emit,
        );
      }

      return;
    }

    // ========================================================
    // OVER NOT FINISHED
    // ========================================================

    if (legalBalls < 6) {
      emit(updated);
      return;
    }

    // ========================================================
    // SUPER OVER
    // ========================================================

    if (state.isSuperOver) {
      if (state.superOverInningsNumber == 1) {
        _finishFirstSuperOverInnings(
          updated,
          emit,
        );
      } else {
        _finishSecondSuperOverInnings(
          updated,
          emit,
        );
      }

      return;
    }

    // ========================================================
    // LAST REGULATION OVER
    // ========================================================

    if (state.isLastOver) {
      if (state.inningsNumber == 1) {
        _finishFirstInnings(
          updated,
          emit,
        );
      } else {
        _finishSecondInnings(
          updated,
          emit,
        );
      }

      return;
    }

    // ========================================================
    // NORMAL OVER FINISHED
    // ========================================================

    emit(
      updated.copyWith(
        step: LiveScoringStep.overComplete,
      ),
    );
  }

  // ==========================================================
  // FIRST INNINGS COMPLETE
  // ==========================================================

  void _finishFirstInnings(
    LiveScoringState updated,
    Emitter<LiveScoringState> emit,
  ) {
    final result = _buildResult(updated);

    emit(
      updated.copyWith(
        firstInnings: result,
        step: LiveScoringStep.inningsBreak,
      ),
    );
  }

  // ==========================================================
  // START SECOND INNINGS
  // ==========================================================

  void _startSecondInnings(
    StartSecondInningsEvent event,
    Emitter<LiveScoringState> emit,
  ) {
    if (state.step != LiveScoringStep.inningsBreak) {
      return;
    }

    emit(
      state.copyWith(
        inningsNumber: 2,
        currentOverIndex: 0,
        runs: 0,
        wickets: 0,
        currentOverDeliveries: const [],
        clearSelectedBowler: true,
        clearPreviousBowler: true,
        clearStriker: true,
        clearNonStriker: true,
        clearDismissed: true,
        awaitingReplacement: false,
        step: LiveScoringStep.selectBowler,
      ),
    );
  }

  // ==========================================================
  // SECOND INNINGS COMPLETE
  // ==========================================================

  void _finishSecondInnings(
    LiveScoringState updated,
    Emitter<LiveScoringState> emit,
  ) {
    final result = _buildResult(updated);

    final first = updated.firstInnings;

    // Resumed mid-innings-2 sessions may not have the first innings result
    // locally; go straight to the final result in that case.
    if (first != null && result.runs == first.runs) {
      emit(
        updated.copyWith(
          secondInnings: result,
          step: LiveScoringStep.superOverReady,
        ),
      );

      return;
    }

    emit(
      updated.copyWith(
        secondInnings: result,
        step: LiveScoringStep.finalResult,
      ),
    );
  }

  // ==========================================================
  // NEXT REGULATION OVER
  // ==========================================================

  void _continueAfterOver(
    ContinueAfterOverEvent event,
    Emitter<LiveScoringState> emit,
  ) {
    if (state.step != LiveScoringStep.overComplete) {
      return;
    }

    // Overs, strike rotation and bowler clearing are tracked by the backend;
    // this only advances the local screen to bowler selection. The completed
    // over's deliveries are cleared so the new over starts fresh (and all
    // eligible bowlers are selectable again).
    emit(state.copyWith(
      step: LiveScoringStep.selectBowler,
      clearSelectedBowler: true,
      currentOverDeliveries: const [],
    ));
  }

  // ==========================================================
  // SUPER OVER START
  // ==========================================================

  void _startSuperOver(
    StartSuperOverEvent event,
    Emitter<LiveScoringState> emit,
  ) {
    if (state.step != LiveScoringStep.superOverReady) {
      return;
    }

    emit(
      state.copyWith(
        isSuperOver: true,
        superOverRound: state.superOverRound + 1,
        superOverInningsNumber: 1,
        currentOverIndex: 0,
        runs: 0,
        wickets: 0,
        currentOverDeliveries: const [],
        clearSelectedBowler: true,
        clearPreviousBowler: true,
        clearStriker: true,
        clearNonStriker: true,
        clearDismissed: true,
        awaitingReplacement: false,
        clearFirstSuperOver: true,
        clearSecondSuperOver: true,
        step: LiveScoringStep.superOverSelectBowler,
      ),
    );
  }

  // ==========================================================
  // FIRST SUPER OVER INNINGS FINISHED
  // ==========================================================

  void _finishFirstSuperOverInnings(
    LiveScoringState updated,
    Emitter<LiveScoringState> emit,
  ) {
    final result = _buildResult(updated);

    emit(
      updated.copyWith(
        firstSuperOverInnings: result,
        step: LiveScoringStep.superOverBreak,
      ),
    );
  }

  // ==========================================================
  // START SECOND SUPER OVER INNINGS
  // ==========================================================

  void _startSecondSuperOverInnings(
    StartSecondSuperOverInningsEvent event,
    Emitter<LiveScoringState> emit,
  ) {
    if (state.step != LiveScoringStep.superOverBreak) {
      return;
    }

    emit(
      state.copyWith(
        superOverInningsNumber: 2,
        currentOverIndex: 0,
        runs: 0,
        wickets: 0,
        currentOverDeliveries: const [],
        clearSelectedBowler: true,
        clearPreviousBowler: true,
        clearStriker: true,
        clearNonStriker: true,
        clearDismissed: true,
        awaitingReplacement: false,
        step: LiveScoringStep.superOverSelectBowler,
      ),
    );
  }

  // ==========================================================
  // SECOND SUPER OVER FINISHED
  // ==========================================================

  void _finishSecondSuperOverInnings(
    LiveScoringState updated,
    Emitter<LiveScoringState> emit,
  ) {
    final result = _buildResult(updated);

    final first = updated.firstSuperOverInnings!;

    // Super over tied again.
    if (result.runs == first.runs) {
      emit(
        updated.copyWith(
          secondSuperOverInnings: result,
          isSuperOver: false,
          step: LiveScoringStep.superOverReady,
        ),
      );

      return;
    }

    emit(
      updated.copyWith(
        secondSuperOverInnings: result,
        step: LiveScoringStep.superOverFinalResult,
      ),
    );
  }

  // ==========================================================
  // SERVER STATE (single source of truth)
  // ==========================================================

  void _applyServerState(
    ApplyServerScoreEvent event,
    Emitter<LiveScoringState> emit,
  ) {
    final response = event.response;
    final runtime = response.scoring.runtime;

    ScoringTeam mapTeam(int? id, ScoringTeam fallback) {
      if (id == null) return fallback;
      final value = id.toString();
      if (state.teamA.id == value) return state.teamA;
      if (state.teamB.id == value) return state.teamB;
      return fallback;
    }

    final battingTeam =
        mapTeam(runtime.currentBattingTeamId, state.currentBattingTeam);
    final bowlingTeam =
        mapTeam(runtime.currentBowlingTeamId, state.currentBowlingTeam);
    final inningsNumber = runtime.currentInning ?? state.inningsNumber;
    final battingTotals = response.scoring.teamTotals(battingTeam.id);

    // Rebuild innings results from the authoritative score payload.
    var firstInnings = state.firstInnings;
    var secondInnings = state.secondInnings;

    if (!runtime.isSuperOver && firstInnings == null) {
      if (inningsNumber >= 2) {
        // The team currently bowling batted in innings 1.
        firstInnings = _inningsResultFor(response, bowlingTeam);
      } else if (runtime.inningsComplete) {
        // Innings 1 just finished; the current batting team is done.
        firstInnings = _inningsResultFor(response, battingTeam);
      }
    }
    if (!runtime.isSuperOver &&
        runtime.inningsComplete &&
        inningsNumber >= 2 &&
        secondInnings == null) {
      secondInnings = _inningsResultFor(response, battingTeam);
    }
    if (!runtime.isSuperOver && response.matchStatus == 3) {
      firstInnings ??= _inningsResultFor(response, bowlingTeam);
      secondInnings ??= _inningsResultFor(
        response,
        state.teamA.id == firstInnings.battingTeamId ? state.teamB : state.teamA,
      );
    }

    // Super over innings results (for the super over result screen).
    var firstSuperOver = state.firstSuperOverInnings;
    var secondSuperOver = state.secondSuperOverInnings;
    var clearFirstSuper = false;
    var clearSecondSuper = false;
    if (runtime.isSuperOver) {
      // Regulation innings results are needed by the super-over screens even
      // when the app entered the match mid-super-over; rebuild them from the
      // regulation snapshot the backend provides.
      if (firstInnings == null) {
        final regulation = response.scoring.regulationTeamScores;
        if (regulation.isNotEmpty) {
          final entry = regulation.entries.first;
          final name = state.teamA.id == entry.key
              ? state.teamA.name
              : state.teamB.id == entry.key
                  ? state.teamB.name
                  : entry.key;
          firstInnings = ScoringInningsResult(
            battingTeamId: entry.key,
            battingTeamName: name,
            runs: entry.value,
            wickets: 0,
            overs: 0,
            legalBallsInLastOver: 0,
          );
        }
      }

      final roundChanged = runtime.superOverRound != null &&
          state.superOverRound != runtime.superOverRound;
      if (roundChanged) {
        firstSuperOver = null;
        secondSuperOver = null;
        clearFirstSuper = true;
        clearSecondSuper = true;
      }
      if (inningsNumber >= 2 && firstSuperOver == null) {
        firstSuperOver = _inningsResultFor(response, bowlingTeam);
      }
      if (runtime.inningsComplete &&
          inningsNumber >= 2 &&
          secondSuperOver == null) {
        secondSuperOver = _inningsResultFor(response, battingTeam);
      }
      if (response.matchStatus == 3) {
        firstSuperOver ??= _inningsResultFor(response, bowlingTeam);
        secondSuperOver ??= _inningsResultFor(
          response,
          state.teamA.id == firstSuperOver.battingTeamId
              ? state.teamB
              : state.teamA,
        );
      }
    }

    final strikerId = runtime.currentStriker.userId?.toString();
    final nonStrikerId = runtime.currentNonStriker.userId?.toString();
    final bowlerId = runtime.currentBowler.userId?.toString();
    final step = _deriveServerStep(response, runtime);

    if (kDebugMode) {
      debugPrint(
        '[LiveScoring] step=${step.name} status=${response.statusText} '
        'inning=$inningsNumber over=${runtime.currentOver} '
        'ab=${runtime.awaitingBatter} abw=${runtime.awaitingBowler} '
        'ic=${runtime.inningsComplete} '
        'allowed=${response.scoring.allowedActions.join(',')}',
      );
    }

    String? previousBowlerId;
    if (!runtime.isSuperOver && (runtime.currentOver ?? 0) > 0) {
      final completedOver = runtime.currentOver! - 1;
      for (final e in _currentInningsEvents(runtime)) {
        if (e.isBallRecorded &&
            e.overNumber == completedOver &&
            e.bowlerUserId != null) {
          previousBowlerId = e.bowlerUserId.toString();
        }
      }
    }

    final String firstBattingTeamId;
    if (runtime.isSuperOver) {
      firstBattingTeamId = inningsNumber >= 2
          ? state.firstBattingTeamId
          : battingTeam.id;
    } else {
      firstBattingTeamId =
          inningsNumber >= 2 ? bowlingTeam.id : battingTeam.id;
    }

    final isLiveNow =
        response.isLive || runtime.state == RefereeScoreRuntimeStates.live;
    final serverActions = response.scoring.allowedActions.toSet();
    // Verified against the live API (4056 super-over audit): while a match
    // is LIVE the backend accepts base scoring actions even when it does
    // not advertise them — e.g. SET_BATTERS/SET_BOWLER right after
    // START_SUPER_OVER (allowed showed only START_SUPER_OVER/UNDO_LAST),
    // and the title-winning ADD_EVENT at a level SO score. Without this
    // union the UI dead-ends there ("Scoring is not allowed") while the
    // server would have accepted the ball. Invalid taps still fail safe:
    // the server validates every request (409 + reconcile via GET).
    // Not-live matches use the server set verbatim (read-only stays shut).
    final allowedActions = isLiveNow
        ? {
            ...serverActions,
            RefereeScoreActions.addEvent,
            RefereeScoreActions.setBatters,
            RefereeScoreActions.setBowler,
            RefereeScoreActions.setWicketKeeper,
            RefereeScoreActions.undoLast,
          }
        : serverActions;

    emit(
      state.copyWith(
        firstBattingTeamId: firstBattingTeamId,
        inningsNumber: inningsNumber,
        currentOverIndex: runtime.currentOver ?? state.currentOverIndex,
        runs: battingTotals.score,
        wickets: battingTotals.wickets,
        currentOverDeliveries: _deliveriesFromServer(runtime, step),
        strikerId: strikerId,
        clearStriker: strikerId == null,
        nonStrikerId: nonStrikerId,
        clearNonStriker: nonStrikerId == null,
        selectedBowlerId: bowlerId,
        clearSelectedBowler: bowlerId == null,
        previousBowlerId: previousBowlerId,
        clearPreviousBowler: previousBowlerId == null,
        dismissedPlayerIds:
            runtime.dismissedBatters.map((id) => id.toString()).toSet(),
        awaitingReplacement: runtime.awaitingBatter,
        isSuperOver: runtime.isSuperOver,
        superOverRound: runtime.superOverRound ?? state.superOverRound,
        superOverInningsNumber:
            runtime.isSuperOver ? inningsNumber : state.superOverInningsNumber,
        firstInnings: firstInnings,
        secondInnings: secondInnings,
        firstSuperOverInnings: firstSuperOver,
        secondSuperOverInnings: secondSuperOver,
        clearFirstSuperOver: clearFirstSuper,
        clearSecondSuperOver: clearSecondSuper,
        allowedActions: allowedActions,
        matchLive: isLiveNow,
        step: step,
      ),
    );
  }

  static ScoringInningsResult _inningsResultFor(
    RefereeScoreResponse response,
    ScoringTeam team,
  ) {
    final totals = response.scoring.teamTotals(team.id);
    return ScoringInningsResult(
      battingTeamId: team.id,
      battingTeamName: team.name,
      runs: totals.score,
      wickets: totals.wickets,
      overs: 0,
      legalBallsInLastOver: 0,
    );
  }

  LiveScoringStep _deriveServerStep(
    RefereeScoreResponse response,
    RefereeScoreRuntimeResponse runtime,
  ) {
    final allowed = response.scoring.allowedActions;
    final isSuper = runtime.isSuperOver;

    // Completed (or cancelled) matches are read-only: show the submitted
    // result screen regardless of any stale runtime flags.
    if (response.isReadOnly) {
      return LiveScoringStep.resultSubmitted;
    }

    if (runtime.inningsComplete) {
      if (allowed.contains(RefereeScoreActions.complete)) {
        return isSuper
            ? LiveScoringStep.superOverFinalResult
            : LiveScoringStep.finalResult;
      }
      if (allowed.contains(RefereeScoreActions.startSuperOver)) {
        return LiveScoringStep.superOverReady;
      }
      if (allowed.contains(RefereeScoreActions.endPeriod)) {
        return isSuper
            ? LiveScoringStep.superOverComplete
            : LiveScoringStep.inningsBreak;
      }
    }

    if (runtime.awaitingBatter) {
      // A replacement batter keeps the non-striker; a fresh innings has no
      // batters yet and needs the openers selection screen instead.
      final hasRemainingBatter = runtime.currentNonStriker.userId != null;
      if (hasRemainingBatter) {
        return isSuper
            ? LiveScoringStep.superOverScoring
            : LiveScoringStep.scoring;
      }
      return isSuper
          ? LiveScoringStep.superOverSelectBowler
          : LiveScoringStep.selectBowler;
    }

    if (runtime.awaitingBowler || runtime.currentBowler.userId == null) {
      if (isSuper) return LiveScoringStep.superOverSelectBowler;
      if (runtime.lastEvent?.isOverComplete == true) {
        return LiveScoringStep.overComplete;
      }
      return LiveScoringStep.selectBowler;
    }

    return isSuper ? LiveScoringStep.superOverScoring : LiveScoringStep.scoring;
  }

  /// Events belonging to the current innings only. The backend sends the
  /// whole match stream, and over numbers restart each innings, so without
  /// this scoping an innings-1 over 0 would leak into innings 2.
  static List<RefereeScoreEvent> _currentInningsEvents(
    RefereeScoreRuntimeResponse runtime,
  ) {
    final events = runtime.events;
    for (var i = events.length - 1; i >= 0; i--) {
      if (events[i].isInningsStarted) {
        return events.sublist(i + 1);
      }
    }
    return events;
  }

  List<ScoringDelivery> _deliveriesFromServer(
    RefereeScoreRuntimeResponse runtime,
    LiveScoringStep step,
  ) {
    final currentOver = runtime.currentOver ?? 0;
    final targetOver = step == LiveScoringStep.overComplete
        ? (currentOver > 0 ? currentOver - 1 : 0)
        : currentOver;

    final deliveries = <ScoringDelivery>[];
    for (final event in _currentInningsEvents(runtime)) {
      if (!event.isBallRecorded) continue;
      if (event.overNumber != targetOver) continue;
      if ((event.ballInOver ?? 0) < 1) continue;
      final runs = int.tryParse('${event.data['delivery_runs'] ?? ''}') ?? 0;
      switch (event.eventCode) {
        case RefereeCricketEventCodes.run:
          deliveries.add(
            ScoringDelivery(type: ScoringDeliveryType.run, runs: runs),
          );
          break;
        case RefereeCricketEventCodes.wicket:
          deliveries.add(
            const ScoringDelivery(type: ScoringDeliveryType.wicket, runs: 0),
          );
          break;
        case RefereeCricketEventCodes.wide:
          deliveries.add(
            const ScoringDelivery(type: ScoringDeliveryType.wide, runs: 1),
          );
          break;
        case RefereeCricketEventCodes.noBall:
          deliveries.add(
            const ScoringDelivery(type: ScoringDeliveryType.noBall, runs: 1),
          );
          break;
      }
    }
    return deliveries;
  }

  // ==========================================================
  // RESULT BUILDER
  // ==========================================================

  static ScoringInningsResult? _initialFirstInnings(
    int? runs,
    int? wickets,
    String firstBattingTeamId,
    ScoringTeam teamA,
    ScoringTeam teamB,
  ) {
    if (runs == null) {
      return null;
    }

    final teamName =
        firstBattingTeamId == teamA.id ? teamA.name : teamB.name;

    return ScoringInningsResult(
      battingTeamId: firstBattingTeamId,
      battingTeamName: teamName,
      runs: runs,
      wickets: wickets ?? 0,
      overs: 0,
      legalBallsInLastOver: 0,
    );
  }

  ScoringInningsResult _buildResult(
    LiveScoringState state,
  ) {
    return ScoringInningsResult(
      battingTeamId: state.currentBattingTeam.id,
      battingTeamName: state.currentBattingTeam.name,
      runs: state.runs,
      wickets: state.wickets,
      overs: state.currentOverIndex,
      legalBallsInLastOver: state.legalBallCount,
    );
  }

  void _submitFinalResult(
    SubmitFinalResultEvent event,
    Emitter<LiveScoringState> emit,
  ) {
    final validNormalResult = state.step == LiveScoringStep.finalResult;

    final validSuperOverResult =
        state.step == LiveScoringStep.superOverFinalResult;

    if (!validNormalResult && !validSuperOverResult) {
      return;
    }

    emit(
      state.copyWith(
        step: LiveScoringStep.resultSubmitted,
      ),
    );
  }
}
