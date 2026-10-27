import 'package:core/core.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:referee_data/referee_data.dart';

sealed class WeeklyAvailabilityState extends Equatable {
  const WeeklyAvailabilityState();

  @override
  List<Object?> get props => const [];
}

class WeeklyAvailabilityInitial extends WeeklyAvailabilityState {
  const WeeklyAvailabilityInitial();
}

class WeeklyAvailabilityLoading extends WeeklyAvailabilityState {
  const WeeklyAvailabilityLoading();
}

class WeeklyAvailabilityLoaded extends WeeklyAvailabilityState {
  const WeeklyAvailabilityLoaded({
    required this.weekdays,
    required this.slots,
    required this.timezone,
    this.isSaving = false,
  });

  final List<RefereeWeekday> weekdays;
  final List<RefereeAvailabilitySlot> slots;
  final String timezone;
  final bool isSaving;

  bool get isEmpty => slots.isEmpty;

  List<RefereeAvailabilitySlot> slotsForDay(String day) =>
      slots.where((slot) => slot.day == day).toList();

  List<String> get daysWithSlots {
    final seen = <String>{};
    return [
      for (final slot in slots)
        if (seen.add(slot.day)) slot.day,
    ];
  }

  WeeklyAvailabilityLoaded copyWith({
    List<RefereeWeekday>? weekdays,
    List<RefereeAvailabilitySlot>? slots,
    String? timezone,
    bool? isSaving,
  }) {
    return WeeklyAvailabilityLoaded(
      weekdays: weekdays ?? this.weekdays,
      slots: slots ?? this.slots,
      timezone: timezone ?? this.timezone,
      isSaving: isSaving ?? this.isSaving,
    );
  }

  @override
  List<Object?> get props => [weekdays, slots, timezone, isSaving];
}

class WeeklyAvailabilityError extends WeeklyAvailabilityState {
  const WeeklyAvailabilityError(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}

class WeeklyAvailabilityCubit extends Cubit<WeeklyAvailabilityState> {
  WeeklyAvailabilityCubit({
    required RefereeRemoteDataSource remoteDataSource,
  })  : _remoteDataSource = remoteDataSource,
        super(const WeeklyAvailabilityInitial());

  final RefereeRemoteDataSource _remoteDataSource;

  static const _dayOrder = <String, int>{
    'MONDAY': 1,
    'TUESDAY': 2,
    'WEDNESDAY': 3,
    'THURSDAY': 4,
    'FRIDAY': 5,
    'SATURDAY': 6,
    'SUNDAY': 7,
  };

  WeeklyAvailabilityLoaded? get _loaded => state is WeeklyAvailabilityLoaded
      ? state as WeeklyAvailabilityLoaded
      : null;

  Future<void> load() async {
    emit(const WeeklyAvailabilityLoading());
    try {
      final weekdays = await _remoteDataSource.listAvailabilityDays();
      final weekly = await _remoteDataSource.getWeeklyAvailability();
      emit(WeeklyAvailabilityLoaded(
        weekdays: weekdays,
        slots: _sorted(weekly.slots),
        timezone: weekly.timezone,
      ));
    } catch (error) {
      emit(WeeklyAvailabilityError(_readableError(error)));
    }
  }

  /// Reloads without replacing populated data with a loading skeleton.
  Future<void> refresh() async {
    if (_loaded == null) return load();
    try {
      final weekdays = await _remoteDataSource.listAvailabilityDays();
      final weekly = await _remoteDataSource.getWeeklyAvailability();
      emit(WeeklyAvailabilityLoaded(
        weekdays: weekdays,
        slots: _sorted(weekly.slots),
        timezone: weekly.timezone,
      ));
    } catch (error) {
      emit(WeeklyAvailabilityError(_readableError(error)));
    }
  }

  Future<String?> createSlot({
    required String day,
    required String startTime,
    required String endTime,
  }) async {
    final current = _loaded;
    if (current == null) return 'Availability is still loading. Please retry.';
    if (current.isSaving)
      return 'Please wait for the current update to finish.';
    emit(current.copyWith(isSaving: true));
    try {
      final slot = await _remoteDataSource.createAvailabilitySlot(
        RefereeAvailabilitySlotRequest(
          day: day,
          startTime: startTime,
          endTime: endTime,
        ),
      );
      emit(current.copyWith(
        slots: _sorted([...current.slots, slot]),
        isSaving: false,
      ));
      return null;
    } catch (error) {
      emit(current.copyWith(isSaving: false));
      return _readableError(error);
    }
  }

  Future<String?> updateSlot({
    required int slotId,
    required String day,
    required String startTime,
    required String endTime,
  }) async {
    final current = _loaded;
    if (current == null) return 'Availability is still loading. Please retry.';
    if (current.isSaving)
      return 'Please wait for the current update to finish.';
    emit(current.copyWith(isSaving: true));
    try {
      final updated = await _remoteDataSource.updateAvailabilitySlot(
        slotId,
        RefereeAvailabilitySlotRequest(
          day: day,
          startTime: startTime,
          endTime: endTime,
        ),
      );
      emit(current.copyWith(
        slots: _sorted(
          current.slots.map((slot) => slot.id == slotId ? updated : slot),
        ),
        isSaving: false,
      ));
      return null;
    } catch (error) {
      emit(current.copyWith(isSaving: false));
      return _readableError(error);
    }
  }

  Future<String?> deleteSlot(int slotId) async {
    final current = _loaded;
    if (current == null) return 'Availability is still loading. Please retry.';
    if (current.isSaving)
      return 'Please wait for the current update to finish.';
    emit(current.copyWith(isSaving: true));
    try {
      await _remoteDataSource.deleteAvailabilitySlot(slotId);
      emit(current.copyWith(
        slots: current.slots.where((slot) => slot.id != slotId).toList(),
        isSaving: false,
      ));
      return null;
    } catch (error) {
      emit(current.copyWith(isSaving: false));
      return _readableError(error);
    }
  }

  Future<String?> clearDay(String day) async {
    final current = _loaded;
    if (current == null) return 'Availability is still loading. Please retry.';
    if (current.isSaving)
      return 'Please wait for the current update to finish.';
    emit(current.copyWith(isSaving: true));
    try {
      await _remoteDataSource.clearAvailabilityDay(day);
      emit(current.copyWith(
        slots: current.slots.where((slot) => slot.day != day).toList(),
        isSaving: false,
      ));
      return null;
    } catch (error) {
      emit(current.copyWith(isSaving: false));
      return _readableError(error);
    }
  }

  List<RefereeAvailabilitySlot> _sorted(
    Iterable<RefereeAvailabilitySlot> slots,
  ) {
    final sorted = slots.toList();
    sorted.sort((a, b) {
      final dayCompare =
          (_dayOrder[a.day] ?? 99).compareTo(_dayOrder[b.day] ?? 99);
      if (dayCompare != 0) return dayCompare;
      return a.startTime.compareTo(b.startTime);
    });
    return sorted;
  }

  String _readableError(Object error) {
    if (error is SportoApiException) {
      final errors = error.errors;
      if (errors is Map) {
        for (final value in errors.values) {
          if (value is List && value.isNotEmpty) return value.first.toString();
          if (value != null) return value.toString();
        }
      }
      return error.message;
    }
    return error.toString();
  }
}
