import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_domain/shared_domain.dart';

// EVENTS
abstract class TournamentEvent extends Equatable {
  const TournamentEvent();

  @override
  List<Object?> get props => [];
}

class LoadTournamentsEvent extends TournamentEvent {
  final SportType? filterSport;

  const LoadTournamentsEvent({this.filterSport});

  @override
  List<Object?> get props => [filterSport];
}

class AddTournamentEvent extends TournamentEvent {
  final TournamentEntity tournament;

  const AddTournamentEvent(this.tournament);

  @override
  List<Object?> get props => [tournament];
}

// STATES
abstract class TournamentState extends Equatable {
  const TournamentState();

  @override
  List<Object?> get props => [];
}

class TournamentInitialState extends TournamentState {}

class TournamentLoadingState extends TournamentState {}

class TournamentLoadedState extends TournamentState {
  final List<TournamentEntity> tournaments;
  final SportType? selectedSportFilter;

  const TournamentLoadedState({
    required this.tournaments,
    this.selectedSportFilter,
  });

  @override
  List<Object?> get props => [tournaments, selectedSportFilter];
}

class TournamentSuccessState extends TournamentState {
  final String message;

  const TournamentSuccessState(this.message);

  @override
  List<Object?> get props => [message];
}

class TournamentErrorState extends TournamentState {
  final String message;

  const TournamentErrorState(this.message);

  @override
  List<Object?> get props => [message];
}

// BLOC (Full BLoC pattern - no Cubit)
class TournamentBloc extends Bloc<TournamentEvent, TournamentState> {
  final GetTournamentsUseCase getTournamentsUseCase;
  final CreateTournamentUseCase createTournamentUseCase;

  TournamentBloc({
    required this.getTournamentsUseCase,
    required this.createTournamentUseCase,
  }) : super(TournamentInitialState()) {
    on<LoadTournamentsEvent>(_onLoadTournaments);
    on<AddTournamentEvent>(_onAddTournament);
  }

  void _onLoadTournaments(
      LoadTournamentsEvent event, Emitter<TournamentState> emit) async {
    emit(TournamentLoadingState());
    try {
      final list = await getTournamentsUseCase(sportType: event.filterSport);
      emit(TournamentLoadedState(
        tournaments: list,
        selectedSportFilter: event.filterSport,
      ));
    } catch (e) {
      emit(TournamentErrorState('Failed to load tournaments: $e'));
    }
  }

  void _onAddTournament(
      AddTournamentEvent event, Emitter<TournamentState> emit) async {
    try {
      await createTournamentUseCase(event.tournament);
      emit(const TournamentSuccessState('Tournament created successfully!'));
      add(const LoadTournamentsEvent());
    } catch (e) {
      emit(TournamentErrorState('Failed to create tournament: $e'));
    }
  }
}
