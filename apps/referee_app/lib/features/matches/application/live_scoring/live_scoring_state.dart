import 'package:equatable/equatable.dart';

enum ScoringStep {
  selectBowler,
  scoring,
  overCompleted,
  inningsCompleted,
  superOverSetup,
  superOverScoring,
  superOverCompleted,
  finalResult,
}

class ScoringPlayer extends Equatable {
  final String id;
  final String name;
  final bool captain;

  const ScoringPlayer({
    required this.id,
    required this.name,
    this.captain = false,
  });

  @override
  List<Object?> get props => [
        id,
        name,
        captain,
      ];
}

enum ScoringBallType {
  run,
  wicket,
  wide,
  noBall,
}

class ScoringBall extends Equatable {
  final ScoringBallType type;
  final int runs;

  const ScoringBall({
    required this.type,
    this.runs = 0,
  });

  bool get isLegal =>
      type != ScoringBallType.wide && type != ScoringBallType.noBall;

  @override
  List<Object?> get props => [
        type,
        runs,
      ];
}

class LiveScoringState extends Equatable {
  final ScoringStep step;

  final int totalOvers;

  /// Zero-based internally.
  final int currentOver;

  final int runs;
  final int wickets;

  final List<ScoringBall> currentOverBalls;

  final List<ScoringPlayer> availableBowlers;

  final String? selectedBowlerId;

  final String? previousBowlerId;

  final bool superOver;

  const LiveScoringState({
    this.step = ScoringStep.selectBowler,
    required this.totalOvers,
    this.currentOver = 0,
    this.runs = 0,
    this.wickets = 0,
    this.currentOverBalls = const [],
    this.availableBowlers = const [],
    this.selectedBowlerId,
    this.previousBowlerId,
    this.superOver = false,
  });

  int get displayOver => currentOver + 1;

  int get legalBalls => currentOverBalls.where((e) => e.isLegal).length;

  bool get overCompleted => legalBalls >= 6;

  bool get canStartOver => selectedBowlerId != null;

  String get score => '$runs/$wickets';

  String get progressText {
    if (superOver) {
      return 'Ball $legalBalls/6';
    }

    return 'Over $displayOver/$totalOvers  •  Ball $legalBalls/6';
  }

  LiveScoringState copyWith({
    ScoringStep? step,
    int? totalOvers,
    int? currentOver,
    int? runs,
    int? wickets,
    List<ScoringBall>? currentOverBalls,
    List<ScoringPlayer>? availableBowlers,
    String? selectedBowlerId,
    bool clearSelectedBowler = false,
    String? previousBowlerId,
    bool? superOver,
  }) {
    return LiveScoringState(
      step: step ?? this.step,
      totalOvers: totalOvers ?? this.totalOvers,
      currentOver: currentOver ?? this.currentOver,
      runs: runs ?? this.runs,
      wickets: wickets ?? this.wickets,
      currentOverBalls: currentOverBalls ?? this.currentOverBalls,
      availableBowlers: availableBowlers ?? this.availableBowlers,
      selectedBowlerId: clearSelectedBowler
          ? null
          : selectedBowlerId ?? this.selectedBowlerId,
      previousBowlerId: previousBowlerId ?? this.previousBowlerId,
      superOver: superOver ?? this.superOver,
    );
  }

  @override
  List<Object?> get props => [
        step,
        totalOvers,
        currentOver,
        runs,
        wickets,
        currentOverBalls,
        availableBowlers,
        selectedBowlerId,
        previousBowlerId,
        superOver,
      ];
}
