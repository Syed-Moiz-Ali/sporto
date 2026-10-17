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
    required this.prizeCategories,
    required this.configSportId,
    required this.configSportFormatId,
    this.tournaments = const [],
    this.dashboard,
    this.dashboardError,
    this.tournamentsError,
    this.configError,
  });

  final PartnerDashboard? dashboard;
  final String? dashboardError;

  /// Last tournament-list refresh failure (list keeps showing stale data).
  final String? tournamentsError;

  /// Last tournament-config (formats/rules) load failure for the wizard.
  final String? configError;
  final PartnerProfileResponseData profile;
  final List<SportMasterResponse> availableSports;
  final List<PartnerSportResponse> selectedSports;
  final List<PartnerDocumentResponse> documents;
  final PartnerApplicationStateResponse application;
  final List<TournamentTypeResponse> tournamentTypes;
  final List<SportMasterResponse> tournamentSports;
  final List<SportFormatResponse> cricketFormats;
  final List<TournamentFormConfigFieldResponse> cricketFormConfig;
  final List<TournamentPrizeCategoryResponse> prizeCategories;
  final int configSportId;
  final int configSportFormatId;

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

  String get mobileNumber => profile.personalInformation.mobileNumber ?? '';

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
        prizeCategories,
        configSportId,
        configSportFormatId,
        tournaments,
        dashboard,
        dashboardError,
        tournamentsError,
        configError,
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

      PartnerDashboard? dashboard;
      String? dashboardError;
      try {
        dashboard = await _remoteDataSource.getDashboardData();
      } catch (_) {
        dashboardError =
            'Dashboard totals could not be loaded. Please refresh.';
      }
      emit(PartnerApiLoadedState(
        dashboard: dashboard,
        dashboardError: dashboardError,
        profile: profile,
        availableSports: const [],
        selectedSports: const [],
        documents: const [],
        application: application,
        tournamentTypes: const [],
        tournamentSports: const [],
        cricketFormats: const [],
        cricketFormConfig: const [],
        prizeCategories: const [],
        configSportId: 1,
        configSportFormatId: 1,
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
      if (cricketFormats.isEmpty) {
        // Never fail silently — the wizard would sit on "Loading formats...".
        if (current is PartnerApiLoadedState) {
          emit(PartnerApiLoadedState(
            profile: profile,
            availableSports: availableSports,
            selectedSports: selectedSports,
            documents: current.documents,
            application: application,
            tournamentTypes: tournamentTypes,
            tournamentSports: tournamentSports,
            cricketFormats: current.cricketFormats,
            cricketFormConfig: current.cricketFormConfig,
            prizeCategories: current.prizeCategories,
            configSportId: event.sportId,
            configSportFormatId: event.sportFormatId,
            tournaments: existingTournaments,
            dashboard: current.dashboard,
            dashboardError: current.dashboardError,
            tournamentsError: current.tournamentsError,
            configError:
                'Sport formats could not be loaded. Please try again.',
          ));
        } else {
          emit(const PartnerApiErrorState(
              'Sport formats could not be loaded. Please try again.'));
        }
        return;
      }
      final resolvedSportFormatId = cricketFormats.any(
        (format) => format.id == event.sportFormatId,
      )
          ? event.sportFormatId
          : cricketFormats.first.id;
      final cricketFormConfig =
          await _remoteDataSource.getTournamentFormConfigData(
        sportId: event.sportId,
        sportFormatId: resolvedSportFormatId,
      );
      final prizeCategories =
          await _remoteDataSource.getTournamentPrizeCategoriesData();

      emit(PartnerApiLoadedState(
        profile: profile,
        availableSports: availableSports,
        selectedSports: selectedSports,
        documents:
            current is PartnerApiLoadedState ? current.documents : const [],
        application: application,
        tournamentTypes: tournamentTypes,
        tournamentSports: tournamentSports,
        cricketFormats: cricketFormats,
        cricketFormConfig: cricketFormConfig,
        prizeCategories: prizeCategories,
        configSportId: event.sportId,
        configSportFormatId: resolvedSportFormatId,
        tournaments: existingTournaments,
        dashboard: current is PartnerApiLoadedState ? current.dashboard : null,
        dashboardError:
            current is PartnerApiLoadedState ? current.dashboardError : null,
        tournamentsError: current is PartnerApiLoadedState
            ? current.tournamentsError
            : null,
      ));
    } catch (error) {
      // Surface config failures — the wizard shows them with a retry action
      // instead of hanging on a loading hint.
      if (current is PartnerApiLoadedState) {
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
          prizeCategories: current.prizeCategories,
          configSportId: current.configSportId,
          configSportFormatId: current.configSportFormatId,
          tournaments: current.tournaments,
          dashboard: current.dashboard,
          dashboardError: current.dashboardError,
          tournamentsError: current.tournamentsError,
          configError:
              'Tournament configuration could not be loaded. Please try again.',
        ));
      } else {
        emit(PartnerApiErrorState(
            'Tournament configuration could not be loaded: $error'));
      }
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
      final application = await _remoteDataSource.getApplicationData();
      final dashboard = await _remoteDataSource.getDashboardData();
      emit(PartnerApiLoadedState(
        profile: profile,
        availableSports: current.availableSports,
        selectedSports: current.selectedSports,
        documents: current.documents,
        application: application,
        tournamentTypes: current.tournamentTypes,
        tournamentSports: current.tournamentSports,
        cricketFormats: current.cricketFormats,
        cricketFormConfig: current.cricketFormConfig,
        prizeCategories: current.prizeCategories,
        configSportId: current.configSportId,
        configSportFormatId: current.configSportFormatId,
        tournaments: current.tournaments,
        dashboard: dashboard,
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
        prizeCategories: current.prizeCategories,
        configSportId: current.configSportId,
        configSportFormatId: current.configSportFormatId,
        tournaments: tournaments,
        dashboard: await _remoteDataSource.getDashboardData(),
        configError: current.configError,
      ));
    } catch (error) {
      // Keep the existing list but surface the failure — silent tabs
      // otherwise look like "no tournaments".
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
        prizeCategories: current.prizeCategories,
        configSportId: current.configSportId,
        configSportFormatId: current.configSportFormatId,
        tournaments: current.tournaments,
        dashboard: current.dashboard,
        dashboardError: current.dashboardError,
        configError: current.configError,
        tournamentsError:
            'Tournament list could not be refreshed. Showing saved list.',
      ));
    }
  }
}
