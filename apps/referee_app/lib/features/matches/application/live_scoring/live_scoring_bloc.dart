import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

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
  final String? previousBowlerId;

  final ScoringInningsResult? firstInnings;
  final ScoringInningsResult? secondInnings;

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
    this.previousBowlerId,
    this.firstInnings,
    this.secondInnings,
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

  int get legalBallCount =>
      currentOverDeliveries.where((delivery) => delivery.isLegal).length;

  bool get overComplete => legalBallCount >= 6;

  bool get isLastOver => displayOver >= totalOvers;

  bool get isAllOut => wickets >= maxWickets;

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

  bool get canStartOver => selectedBowler != null;

  String get currentBowlerName => selectedBowler?.name ?? '';

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

    return 'Over $displayOver/$regulationOvers'
        '  •  Ball $legalBallCount/6';
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
    String? previousBowlerId,
    bool clearPreviousBowler = false,
    ScoringInningsResult? firstInnings,
    ScoringInningsResult? secondInnings,
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
      previousBowlerId: clearPreviousBowler
          ? null
          : previousBowlerId ?? this.previousBowlerId,
      firstInnings: firstInnings ?? this.firstInnings,
      secondInnings: secondInnings ?? this.secondInnings,
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
        previousBowlerId,
        firstInnings,
        secondInnings,
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
    int regulationOvers = 5,
    int maxWickets = 10,
  }) : super(
          LiveScoringState(
            teamA: teamA,
            teamB: teamB,
            firstBattingTeamId: firstBattingTeamId,
            regulationOvers: regulationOvers,
            maxWickets: maxWickets,
          ),
        ) {
    on<SelectBowlerEvent>(
      _selectBowler,
    );

    on<StartSelectedOverEvent>(
      _startOver,
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

    final updated = state.copyWith(
      runs: newRuns,
      wickets: newWickets,
      currentOverDeliveries: deliveries,
    );

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

    final first = updated.firstInnings!;

    if (result.runs == first.runs) {
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

    emit(
      state.copyWith(
        currentOverIndex: state.currentOverIndex + 1,
        previousBowlerId: state.selectedBowlerId,
        currentOverDeliveries: const [],
        clearSelectedBowler: true,
        step: LiveScoringStep.selectBowler,
      ),
    );
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
  // RESULT BUILDER
  // ==========================================================

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
