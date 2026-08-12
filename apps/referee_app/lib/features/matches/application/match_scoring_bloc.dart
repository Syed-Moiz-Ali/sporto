import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_domain/shared_domain.dart';

// ============================================================
// EVENTS
// ============================================================

abstract class MatchScoringEvent extends Equatable {
  const MatchScoringEvent();

  @override
  List<Object?> get props => [];
}

class LoadMatchesEvent extends MatchScoringEvent {}

class LoadMatchDetailEvent extends MatchScoringEvent {
  final String matchId;

  const LoadMatchDetailEvent(
    this.matchId,
  );

  @override
  List<Object?> get props => [
        matchId,
      ];
}

class VerifyMatchRosterEvent extends MatchScoringEvent {
  final String matchId;

  const VerifyMatchRosterEvent(
    this.matchId,
  );

  @override
  List<Object?> get props => [
        matchId,
      ];
}

class RecordBallEvent extends MatchScoringEvent {
  final String matchId;
  final BallScoreEntity ballScore;

  const RecordBallEvent(
    this.matchId,
    this.ballScore,
  );

  @override
  List<Object?> get props => [
        matchId,
        ballScore,
      ];
}

class CompleteMatchEvent extends MatchScoringEvent {
  final String matchId;

  const CompleteMatchEvent(
    this.matchId,
  );

  @override
  List<Object?> get props => [
        matchId,
      ];
}

// ============================================================
// STATES
// ============================================================

abstract class MatchScoringState extends Equatable {
  const MatchScoringState();

  @override
  List<Object?> get props => [];
}

class MatchScoringInitialState extends MatchScoringState {}

class MatchScoringLoadingState extends MatchScoringState {}

class MatchScoringListLoadedState extends MatchScoringState {
  final List<CricketMatchEntity> matches;

  const MatchScoringListLoadedState(
    this.matches,
  );

  @override
  List<Object?> get props => [
        matches,
      ];
}

class MatchScoringLoadedState extends MatchScoringState {
  final CricketMatchEntity match;

  const MatchScoringLoadedState(
    this.match,
  );

  @override
  List<Object?> get props => [
        match,
      ];
}

class MatchCompletedState extends MatchScoringState {
  final CricketMatchEntity match;

  final String winnerName;

  const MatchCompletedState(
    this.match,
    this.winnerName,
  );

  @override
  List<Object?> get props => [
        match,
        winnerName,
      ];
}

class MatchScoringErrorState extends MatchScoringState {
  final String message;

  const MatchScoringErrorState(
    this.message,
  );

  @override
  List<Object?> get props => [
        message,
      ];
}

// ============================================================
// BLOC
// ============================================================

class MatchScoringBloc extends Bloc<MatchScoringEvent, MatchScoringState> {
  final GetMatchesUseCase getMatchesUseCase;

  final VerifyMatchUseCase verifyMatchUseCase;

  final RecordBallScoreUseCase recordBallScoreUseCase;

  MatchScoringBloc({
    required this.getMatchesUseCase,
    required this.verifyMatchUseCase,
    required this.recordBallScoreUseCase,
  }) : super(
          MatchScoringInitialState(),
        ) {
    on<LoadMatchesEvent>(
      _onLoadMatches,
    );

    on<LoadMatchDetailEvent>(
      _onLoadMatchDetail,
    );

    on<VerifyMatchRosterEvent>(
      _onVerifyRoster,
    );

    on<RecordBallEvent>(
      _onRecordBall,
    );

    on<CompleteMatchEvent>(
      _onCompleteMatch,
    );
  }

  // ==========================================================
  // LOAD MATCHES
  // ==========================================================

  Future<void> _onLoadMatches(
    LoadMatchesEvent event,
    Emitter<MatchScoringState> emit,
  ) async {
    emit(
      MatchScoringLoadingState(),
    );

    try {
      final matches = await getMatchesUseCase();

      emit(
        MatchScoringListLoadedState(
          matches,
        ),
      );
    } catch (error) {
      emit(
        MatchScoringErrorState(
          'Failed to load matches: $error',
        ),
      );
    }
  }

  // ==========================================================
  // LOAD MATCH
  // ==========================================================

  Future<void> _onLoadMatchDetail(
    LoadMatchDetailEvent event,
    Emitter<MatchScoringState> emit,
  ) async {
    emit(
      MatchScoringLoadingState(),
    );

    try {
      final match = await getMatchesUseCase.getById(
        event.matchId,
      );

      if (match == null) {
        emit(
          const MatchScoringErrorState(
            'Match not found',
          ),
        );

        return;
      }

      emit(
        MatchScoringLoadedState(
          match,
        ),
      );
    } catch (error) {
      emit(
        MatchScoringErrorState(
          'Failed to load match detail: $error',
        ),
      );
    }
  }

  // ==========================================================
  // VERIFY
  // ==========================================================

  Future<void> _onVerifyRoster(
    VerifyMatchRosterEvent event,
    Emitter<MatchScoringState> emit,
  ) async {
    try {
      await verifyMatchUseCase(
        event.matchId,
      );

      final match = await getMatchesUseCase.getById(
        event.matchId,
      );

      if (match != null) {
        emit(
          MatchScoringLoadedState(
            match,
          ),
        );
      }
    } catch (error) {
      emit(
        MatchScoringErrorState(
          'Verification failed: $error',
        ),
      );
    }
  }

  // ==========================================================
  // RECORD BALL
  // ==========================================================

  Future<void> _onRecordBall(
    RecordBallEvent event,
    Emitter<MatchScoringState> emit,
  ) async {
    try {
      await recordBallScoreUseCase(
        event.matchId,
        event.ballScore,
      );

      final match = await getMatchesUseCase.getById(
        event.matchId,
      );

      if (match != null) {
        emit(
          MatchScoringLoadedState(
            match,
          ),
        );
      }
    } catch (error) {
      emit(
        MatchScoringErrorState(
          'Failed to record ball: $error',
        ),
      );
    }
  }

  // ==========================================================
  // COMPLETE
  // ==========================================================

  Future<void> _onCompleteMatch(
    CompleteMatchEvent event,
    Emitter<MatchScoringState> emit,
  ) async {
    try {
      final match = await getMatchesUseCase.getById(
        event.matchId,
      );

      if (match == null) {
        return;
      }

      final winner = match.teamAScore >= match.teamBScore
          ? match.teamA.name
          : match.teamB.name;

      emit(
        MatchCompletedState(
          match,
          winner,
        ),
      );
    } catch (error) {
      emit(
        MatchScoringErrorState(
          'Match completion failed: $error',
        ),
      );
    }
  }
}
