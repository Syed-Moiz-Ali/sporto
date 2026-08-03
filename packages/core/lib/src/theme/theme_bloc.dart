import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../storage/hive_service.dart';

// EVENTS
abstract class ThemeEvent extends Equatable {
  const ThemeEvent();

  @override
  List<Object?> get props => [];
}

class InitThemeEvent extends ThemeEvent {}

class ToggleThemeEvent extends ThemeEvent {}

class SetThemeModeEvent extends ThemeEvent {
  final ThemeMode themeMode;

  const SetThemeModeEvent(this.themeMode);

  @override
  List<Object?> get props => [themeMode];
}

// STATES
class ThemeState extends Equatable {
  final ThemeMode themeMode;

  const ThemeState({this.themeMode = ThemeMode.light});

  @override
  List<Object?> get props => [themeMode];
}

// BLOC (Full BLoC pattern - no Cubit)
class ThemeBloc extends Bloc<ThemeEvent, ThemeState> {
  static const String _themeKey = 'app_theme_mode';

  ThemeBloc() : super(const ThemeState(themeMode: ThemeMode.light)) {
    on<InitThemeEvent>(_onInitTheme);
    on<ToggleThemeEvent>(_onToggleTheme);
    on<SetThemeModeEvent>(_onSetThemeMode);
  }

  void _onInitTheme(InitThemeEvent event, Emitter<ThemeState> emit) async {
    final box = HiveService.pendingSyncBox;
    final savedModeStr = box.get(_themeKey) as String?;

    if (savedModeStr == 'dark') {
      emit(const ThemeState(themeMode: ThemeMode.dark));
    } else {
      emit(const ThemeState(themeMode: ThemeMode.light));
    }
  }

  void _onToggleTheme(ToggleThemeEvent event, Emitter<ThemeState> emit) async {
    final newMode = state.themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    await _saveThemeMode(newMode);
    emit(ThemeState(themeMode: newMode));
  }

  void _onSetThemeMode(SetThemeModeEvent event, Emitter<ThemeState> emit) async {
    await _saveThemeMode(event.themeMode);
    emit(ThemeState(themeMode: event.themeMode));
  }

  Future<void> _saveThemeMode(ThemeMode mode) async {
    final box = HiveService.pendingSyncBox;
    final val = mode == ThemeMode.dark ? 'dark' : 'light';
    await box.put(_themeKey, val);
  }
}
