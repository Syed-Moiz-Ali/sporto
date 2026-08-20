import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:partner_data/partner_data.dart';

// ============================================================
// EVENTS
// ============================================================
abstract class PartnerApiEvent extends Equatable {
  const PartnerApiEvent();

  @override
  List<Object?> get props => [];
}

class LoadPartnerApiBootstrapEvent extends PartnerApiEvent {
  const LoadPartnerApiBootstrapEvent();
}

class LoadTournamentConfigEvent extends PartnerApiEvent {
  final int sportId;
  final int sportFormatId;

  const LoadTournamentConfigEvent({
    this.sportId = 1,
    this.sportFormatId = 1,
  });

  @override
  List<Object?> get props => [sportId, sportFormatId];
}

class RefreshPartnerProfileEvent extends PartnerApiEvent {
  const RefreshPartnerProfileEvent();
}

/// Load (or refresh) the partner's tournament list with optional status filter.
/// Pass [status] = null to load all tournaments.
class LoadPartnerTournamentsEvent extends PartnerApiEvent {
  final int? status;

  const LoadPartnerTournamentsEvent({this.status});

  @override
  List<Object?> get props => [status];
}

// ============================================================
// STATES
// ============================================================
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
    this.tournaments = const [],
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

  /// All tournaments loaded from the API (across all statuses for home screen).
  final List<PartnerTournamentResponse> tournaments;

  // ── Computed helpers for the UI ──────────────────────────────────────────

  /// Partner display name (first + last, falling back to mobile).
  String get displayName {
    final pi = profile.personalInformation;
    final first = pi.firstName?.trim() ?? '';
    final last = pi.lastName?.trim() ?? '';
    final full = [first, last].where((s) => s.isNotEmpty).join(' ');
    return full.isNotEmpty
        ? full
        : (pi.mobileNumber?.isNotEmpty == true ? pi.mobileNumber! : 'Partner');
  }

  String get mobileNumber =>
      profile.personalInformation.mobileNumber ?? '';

  /// Tournaments currently live (in-progress, status 6).
  List<PartnerTournamentResponse> get liveTournaments =>
      tournaments.where((t) => t.status == 6).toList();

  /// Upcoming tournaments (published 2, registration open 3, closed 4, check-in 5).
  List<PartnerTournamentResponse> get upcomingTournaments =>
      tournaments.where((t) => t.status >= 2 && t.status <= 5).toList();

  /// Completed tournaments.
  List<PartnerTournamentResponse> get completedTournaments =>
      tournaments.where((t) => t.status == 7).toList();

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
        tournaments,
      ];
}

class PartnerApiErrorState extends PartnerApiState {
  const PartnerApiErrorState(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}

// ============================================================
// BLOC
// ============================================================
class PartnerApiBloc extends Bloc<PartnerApiEvent, PartnerApiState> {
  PartnerApiBloc({required PartnerRemoteDataSource remoteDataSource})
      : _remoteDataSource = remoteDataSource,
        super(const PartnerApiInitialState()) {
    on<LoadPartnerApiBootstrapEvent>(_onLoadBootstrap);
    on<LoadTournamentConfigEvent>(_onLoadTournamentConfig);
    on<RefreshPartnerProfileEvent>(_onRefreshProfile);
    on<LoadPartnerTournamentsEvent>(_onLoadTournaments);
  }

  final PartnerRemoteDataSource _remoteDataSource;

  Future<void> _onLoadBootstrap(
    LoadPartnerApiBootstrapEvent event,
    Emitter<PartnerApiState> emit,
  ) async {
    emit(const PartnerApiLoadingState());
    try {
      final profile = await _remoteDataSource.getProfileData();
      final application = await _remoteDataSource.getApplicationData();

      // Load all tournaments (no status filter) for home-screen stats.
      List<PartnerTournamentResponse> tournaments = const [];
      try {
        tournaments = await _remoteDataSource.listTournamentsData();
      } catch (_) {
        // Non-fatal: home screen can still show with empty list.
      }

      emit(PartnerApiLoadedState(
        profile: profile,
        availableSports: const [],
        selectedSports: const [],
        documents: const [],
        application: application,
        tournamentTypes: const [],
        tournamentSports: const [],
        cricketFormats: const [],
        cricketFormConfig: const [],
        tournaments: tournaments,
      ));
    } catch (error) {
      emit(PartnerApiErrorState('Failed to load partner data: $error'));
    }
  }

  Future<void> _onLoadTournamentConfig(
    LoadTournamentConfigEvent event,
    Emitter<PartnerApiState> emit,
  ) async {
    final current = state;
    late final PartnerProfileResponseData profile;
    late final PartnerApplicationStateResponse application;
    var existingTournaments = <PartnerTournamentResponse>[];

    if (current is PartnerApiLoadedState) {
      profile = current.profile;
      application = current.application;
      existingTournaments = current.tournaments;
    } else {
      profile = await _remoteDataSource.getProfileData();
      application = await _remoteDataSource.getApplicationData();
    }

    try {
      final availableSports = await _remoteDataSource.getAvailableSportsData();
      final selectedSports = await _remoteDataSource.getSelectedSportsData();
      final tournamentTypes = await _remoteDataSource.getTournamentTypesData();
      final tournamentSports =
          await _remoteDataSource.getTournamentSportsData();
      final cricketFormats =
          await _remoteDataSource.getTournamentFormatsData(event.sportId);
      final cricketFormConfig =
          await _remoteDataSource.getTournamentFormConfigData(
        sportId: event.sportId,
        sportFormatId: event.sportFormatId,
      );

      emit(PartnerApiLoadedState(
        profile: profile,
        availableSports: availableSports,
        selectedSports: selectedSports,
        documents: const [],
        application: application,
        tournamentTypes: tournamentTypes,
        tournamentSports: tournamentSports,
        cricketFormats: cricketFormats,
        cricketFormConfig: cricketFormConfig,
        tournaments: existingTournaments,
      ));
    } catch (error) {
      // Keep existing state if loading tournament config fails.
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
        tournaments: current.tournaments,
      ));
    } catch (error) {
      emit(PartnerApiErrorState('Failed to refresh profile: $error'));
    }
  }

  Future<void> _onLoadTournaments(
    LoadPartnerTournamentsEvent event,
    Emitter<PartnerApiState> emit,
  ) async {
    final current = state;
    if (current is! PartnerApiLoadedState) return;

    try {
      final tournaments = await _remoteDataSource.listTournamentsData(
        status: event.status,
      );
      emit(PartnerApiLoadedState(
        profile: current.profile,
        availableSports: current.availableSports,
        selectedSports: current.selectedSports,
        documents: current.documents,
        application: current.application,
        tournamentTypes: current.tournamentTypes,
        tournamentSports: current.tournamentSports,
        cricketFormats: current.cricketFormats,
        cricketFormConfig: current.cricketFormConfig,
        tournaments: tournaments,
      ));
    } catch (_) {
      // Silently ignore — keep existing tournament list.
    }
  }
}
