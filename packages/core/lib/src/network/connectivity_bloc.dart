import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../storage/hive_service.dart';

// EVENTS
abstract class ConnectivityEvent extends Equatable {
  const ConnectivityEvent();

  @override
  List<Object?> get props => [];
}

class StartConnectivityWatcherEvent extends ConnectivityEvent {}

class ConnectivityStatusChangedEvent extends ConnectivityEvent {
  final bool isConnected;

  const ConnectivityStatusChangedEvent(this.isConnected);

  @override
  List<Object?> get props => [isConnected];
}

class TriggerSyncQueueEvent extends ConnectivityEvent {}

// STATES
abstract class ConnectivityState extends Equatable {
  const ConnectivityState();

  @override
  List<Object?> get props => [];
}

class ConnectivityInitialState extends ConnectivityState {}

class ConnectivityStatusState extends ConnectivityState {
  final bool isConnected;
  final bool isSyncing;
  final int pendingItemsCount;

  const ConnectivityStatusState({
    required this.isConnected,
    this.isSyncing = false,
    required this.pendingItemsCount,
  });

  @override
  List<Object?> get props => [isConnected, isSyncing, pendingItemsCount];
}

// BLOC (Full BLoC pattern - no Cubit)
class ConnectivityBloc extends Bloc<ConnectivityEvent, ConnectivityState> {
  final Connectivity _connectivity;
  StreamSubscription<List<ConnectivityResult>>? _subscription;

  ConnectivityBloc({Connectivity? connectivity})
      : _connectivity = connectivity ?? Connectivity(),
        super(ConnectivityInitialState()) {
    on<StartConnectivityWatcherEvent>(_onStartWatcher);
    on<ConnectivityStatusChangedEvent>(_onStatusChanged);
    on<TriggerSyncQueueEvent>(_onTriggerSync);
  }

  void _onStartWatcher(
      StartConnectivityWatcherEvent event, Emitter<ConnectivityState> emit) async {
    final results = await _connectivity.checkConnectivity();
    final isConnected = _hasInternet(results);
    final pendingCount = HiveService.getPendingSyncItems().length;

    emit(ConnectivityStatusState(
      isConnected: isConnected,
      isSyncing: false,
      pendingItemsCount: pendingCount,
    ));

    _subscription?.cancel();
    _subscription = _connectivity.onConnectivityChanged.listen((results) {
      final connected = _hasInternet(results);
      add(ConnectivityStatusChangedEvent(connected));
    });
  }

  void _onStatusChanged(
      ConnectivityStatusChangedEvent event, Emitter<ConnectivityState> emit) {
    final pendingCount = HiveService.getPendingSyncItems().length;

    emit(ConnectivityStatusState(
      isConnected: event.isConnected,
      isSyncing: false,
      pendingItemsCount: pendingCount,
    ));

    if (event.isConnected && pendingCount > 0) {
      add(TriggerSyncQueueEvent());
    }
  }

  void _onTriggerSync(
      TriggerSyncQueueEvent event, Emitter<ConnectivityState> emit) async {
    final currentState = state;
    final isConn = currentState is ConnectivityStatusState ? currentState.isConnected : true;

    emit(ConnectivityStatusState(
      isConnected: isConn,
      isSyncing: true,
      pendingItemsCount: HiveService.getPendingSyncItems().length,
    ));

    // Simulate syncing pending items
    await Future.delayed(const Duration(seconds: 1));
    await HiveService.clearAllSyncQueue();

    emit(ConnectivityStatusState(
      isConnected: isConn,
      isSyncing: false,
      pendingItemsCount: 0,
    ));
  }

  bool _hasInternet(List<ConnectivityResult> results) {
    return results.any((r) => r != ConnectivityResult.none);
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }
}
