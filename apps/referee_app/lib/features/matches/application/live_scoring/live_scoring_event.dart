import 'package:equatable/equatable.dart';

import 'live_scoring_state.dart';

sealed class LiveScoringEvent extends Equatable {
  const LiveScoringEvent();

  @override
  List<Object?> get props => [];
}

class ScoringStarted extends LiveScoringEvent {
  final List<ScoringPlayer> bowlers;
  final int totalOvers;

  const ScoringStarted({
    required this.bowlers,
    required this.totalOvers,
  });

  @override
  List<Object?> get props => [
        bowlers,
        totalOvers,
      ];
}

class BowlerSelected extends LiveScoringEvent {
  final String bowlerId;

  const BowlerSelected(this.bowlerId);

  @override
  List<Object?> get props => [bowlerId];
}

class BowlerConfirmed extends LiveScoringEvent {}

class RunRecorded extends LiveScoringEvent {
  final int runs;

  const RunRecorded(this.runs);

  @override
  List<Object?> get props => [runs];
}

class WicketRecorded extends LiveScoringEvent {}

class WideRecorded extends LiveScoringEvent {}

class NoBallRecorded extends LiveScoringEvent {}

class ContinueToNextOver extends LiveScoringEvent {}

class StartSuperOver extends LiveScoringEvent {}
