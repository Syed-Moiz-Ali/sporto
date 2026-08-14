import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:partner_data/partner_data.dart';

abstract class PartnerApiEvent extends Equatable {
  const PartnerApiEvent();

  @override
  List<Object?> get props => [];
}

class LoadPartnerApiBootstrapEvent extends PartnerApiEvent {
  const LoadPartnerApiBootstrapEvent();
}

class RefreshPartnerProfileEvent extends PartnerApiEvent {
  const RefreshPartnerProfileEvent();
}

abstract class PartnerApiState extends Equatable {
  const PartnerApiState();

  @override
  List<Object?> get props => [];
}

class PartnerApiInitialState extends PartnerApiState {
  const PartnerApiInitialState();
}

class PartnerApiLoadingState extends PartnerApiState {
  const PartnerApiLoadingState();
}

class PartnerApiLoadedState extends PartnerApiState {
  const PartnerApiLoadedState({
    required this.profile,
    required this.availableSports,
    required this.selectedSports,
    required this.documents,
    required this.application,
    required this.tournamentTypes,
    required this.tournamentSports,
    required this.cricketFormats,
    required this.cricketFormConfig,
  });

  final PartnerProfileResponseData profile;
  final List<SportMasterResponse> availableSports;
  final List<PartnerSportResponse> selectedSports;
  final List<PartnerDocumentResponse> documents;
  final PartnerApplicationStateResponse application;
  final List<TournamentTypeResponse> tournamentTypes;
  final List<SportMasterResponse> tournamentSports;
  final List<SportFormatResponse> cricketFormats;
  final List<TournamentFormConfigFieldResponse> cricketFormConfig;

  @override
  List<Object?> get props => [
        profile,
        availableSports,
        selectedSports,
        documents,
        application,
        tournamentTypes,
        tournamentSports,
        cricketFormats,
        cricketFormConfig,
      ];
}

class PartnerApiErrorState extends PartnerApiState {
  const PartnerApiErrorState(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}

class PartnerApiBloc extends Bloc<PartnerApiEvent, PartnerApiState> {
  PartnerApiBloc({required PartnerRemoteDataSource remoteDataSource})
      : _remoteDataSource = remoteDataSource,
        super(const PartnerApiInitialState()) {
    on<LoadPartnerApiBootstrapEvent>(_onLoadBootstrap);
    on<RefreshPartnerProfileEvent>(_onRefreshProfile);
  }

  final PartnerRemoteDataSource _remoteDataSource;

  Future<void> _onLoadBootstrap(
    LoadPartnerApiBootstrapEvent event,
    Emitter<PartnerApiState> emit,
  ) async {
    emit(const PartnerApiLoadingState());
    try {
      final profile = await _remoteDataSource.getProfileData();
      final availableSports = await _remoteDataSource.getAvailableSportsData();
      final selectedSports = await _remoteDataSource.getSelectedSportsData();
      final documents = await _remoteDataSource.getDocumentsData();
      final application = await _remoteDataSource.getApplicationData();
      final tournamentTypes = await _remoteDataSource.getTournamentTypesData();
      final tournamentSports =
          await _remoteDataSource.getTournamentSportsData();
      final cricketFormats =
          await _remoteDataSource.getTournamentFormatsData(1);
      final cricketFormConfig =
          await _remoteDataSource.getTournamentFormConfigData(
        sportId: 1,
        sportFormatId: 1,
      );

      emit(PartnerApiLoadedState(
        profile: profile,
        availableSports: availableSports,
        selectedSports: selectedSports,
        documents: documents,
        application: application,
        tournamentTypes: tournamentTypes,
        tournamentSports: tournamentSports,
        cricketFormats: cricketFormats,
        cricketFormConfig: cricketFormConfig,
      ));
    } catch (error) {
      emit(PartnerApiErrorState('Failed to load partner APIs: $error'));
    }
  }

  Future<void> _onRefreshProfile(
    RefreshPartnerProfileEvent event,
    Emitter<PartnerApiState> emit,
  ) async {
    final current = state;
    if (current is! PartnerApiLoadedState) {
      add(const LoadPartnerApiBootstrapEvent());
      return;
    }

    try {
      final profile = await _remoteDataSource.getProfileData();
      emit(PartnerApiLoadedState(
        profile: profile,
        availableSports: current.availableSports,
        selectedSports: current.selectedSports,
        documents: current.documents,
        application: current.application,
        tournamentTypes: current.tournamentTypes,
        tournamentSports: current.tournamentSports,
        cricketFormats: current.cricketFormats,
        cricketFormConfig: current.cricketFormConfig,
      ));
    } catch (error) {
      emit(PartnerApiErrorState('Failed to refresh profile: $error'));
    }
  }
}
