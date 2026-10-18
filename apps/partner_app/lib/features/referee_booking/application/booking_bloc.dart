import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'booking_models.dart';
import 'booking_repository.dart';

/// Steps of the location screen (Figma E1-04 -> E1-07).
enum LocationStep { search, detected, venue, bookingType }

/// How the user wants to book (Figma E1-07).
enum BookingMode { quick, choose }

/// Booking-type segment on the schedule screen (Figma E1-08 / E1-12).
enum ScheduleMode { hourly, daily }

/// Events for the referee-booking flow.
///
/// Implemented as a sealed hierarchy (rather than a bare enum) so events can
/// carry payloads (selected sport/location/referee, etc.).
sealed class BookingEvent extends Equatable {
  const BookingEvent();

  @override
  List<Object?> get props => [];
}

class BookingLoad extends BookingEvent {
  const BookingLoad();
}

class BookingRetry extends BookingEvent {
  const BookingRetry();
}

class BookingSelectSport extends BookingEvent {
  final Sport sport;
  const BookingSelectSport(this.sport);

  @override
  List<Object?> get props => [sport];
}

class BookingSelectLocation extends BookingEvent {
  final Location location;
  const BookingSelectLocation(this.location);

  @override
  List<Object?> get props => [location];
}

/// Moves from the detected state (E1-05) to the venue state (E1-06).
class BookingConfirmLocation extends BookingEvent {
  const BookingConfirmLocation();
}

/// Moves from the venue state (E1-06) to the booking-type state (E1-07).
class BookingSelectBookingType extends BookingEvent {
  const BookingSelectBookingType();
}

/// Returns to the search step (E1-04) e.g. via "Change Location".
class BookingResetLocation extends BookingEvent {
  const BookingResetLocation();
}

/// Records the booking mode chosen on E1-07.
class BookingChooseMode extends BookingEvent {
  final BookingMode mode;
  const BookingChooseMode(this.mode);

  @override
  List<Object?> get props => [mode];
}

class BookingSelectScheduleMode extends BookingEvent {
  final ScheduleMode mode;
  const BookingSelectScheduleMode(this.mode);

  @override
  List<Object?> get props => [mode];
}

class BookingSelectDate extends BookingEvent {
  final String date;
  const BookingSelectDate(this.date);

  @override
  List<Object?> get props => [date];
}

class BookingSelectTime extends BookingEvent {
  final String time;
  const BookingSelectTime(this.time);

  @override
  List<Object?> get props => [time];
}

class BookingSelectDuration extends BookingEvent {
  final String duration;
  const BookingSelectDuration(this.duration);

  @override
  List<Object?> get props => [duration];
}

class BookingSelectReferee extends BookingEvent {
  final Referee referee;
  const BookingSelectReferee(this.referee);

  @override
  List<Object?> get props => [referee];
}

class BookingConfirm extends BookingEvent {
  const BookingConfirm();
}

class BookingPay extends BookingEvent {
  final String bookingId;
  final Payment method;
  const BookingPay(this.bookingId, this.method);

  @override
  List<Object?> get props => [bookingId, method];
}

class BookingRateReview extends BookingEvent {
  final String bookingId;
  final Rating rating;
  const BookingRateReview(this.bookingId, this.rating);

  @override
  List<Object?> get props => [bookingId, rating];
}

/// State for the referee-booking flow.
class BookingState extends Equatable {
  final bool isLoading;
  final bool hasError;
  final Failure? error;
  final List<Booking> bookings;
  final Sport? selectedSport;
  final Location? selectedLocation;
  final Location? confirmedLocation;
  final Referee? selectedReferee;
  final Booking? bookingDetails;
  final Rating? ratings;
  final LocationStep locationStep;
  final BookingMode? bookingMode;
  final ScheduleMode scheduleMode;
  final String selectedDate;
  final String selectedTime;
  final String selectedDuration;

  const BookingState({
    this.isLoading = true,
    this.hasError = false,
    this.error,
    this.bookings = const [],
    this.selectedSport,
    this.selectedLocation,
    this.confirmedLocation,
    this.selectedReferee,
    this.bookingDetails,
    this.ratings,
    this.locationStep = LocationStep.search,
    this.bookingMode,
    this.scheduleMode = ScheduleMode.hourly,
    this.selectedDate = '13 Oct 2026',
    this.selectedTime = '5:00 PM',
    this.selectedDuration = '1 Hour',
  });

  BookingState copyWith({
    bool? isLoading,
    bool? hasError,
    Failure? error,
    List<Booking>? bookings,
    Sport? selectedSport,
    Location? selectedLocation,
    Location? confirmedLocation,
    Referee? selectedReferee,
    Booking? bookingDetails,
    Rating? ratings,
    LocationStep? locationStep,
    BookingMode? bookingMode,
    ScheduleMode? scheduleMode,
    String? selectedDate,
    String? selectedTime,
    String? selectedDuration,
    bool clearError = false,
  }) {
    return BookingState(
      isLoading: isLoading ?? this.isLoading,
      hasError: hasError ?? this.hasError,
      error: clearError ? null : (error ?? this.error),
      bookings: bookings ?? this.bookings,
      selectedSport: selectedSport ?? this.selectedSport,
      selectedLocation: selectedLocation ?? this.selectedLocation,
      confirmedLocation: confirmedLocation ?? this.confirmedLocation,
      selectedReferee: selectedReferee ?? this.selectedReferee,
      bookingDetails: bookingDetails ?? this.bookingDetails,
      ratings: ratings ?? this.ratings,
      locationStep: locationStep ?? this.locationStep,
      bookingMode: bookingMode ?? this.bookingMode,
      scheduleMode: scheduleMode ?? this.scheduleMode,
      selectedDate: selectedDate ?? this.selectedDate,
      selectedTime: selectedTime ?? this.selectedTime,
      selectedDuration: selectedDuration ?? this.selectedDuration,
    );
  }

  @override
  List<Object?> get props => [
        isLoading,
        hasError,
        error,
        bookings,
        selectedSport,
        selectedLocation,
        confirmedLocation,
        selectedReferee,
        bookingDetails,
        ratings,
        locationStep,
        bookingMode,
        scheduleMode,
        selectedDate,
        selectedTime,
        selectedDuration,
      ];
}

/// Bloc driving the referee-booking flow. All data comes from
/// [BookingRepository] (mock by default); no business logic lives in screens.
class BookingBloc extends Bloc<BookingEvent, BookingState> {
  final BookingRepository repository;

  BookingBloc(this.repository) : super(const BookingState()) {
    on<BookingLoad>(_onLoad);
    on<BookingRetry>(_onLoad);
    on<BookingSelectSport>(
        (event, emit) => emit(state.copyWith(selectedSport: event.sport)));
    on<BookingSelectLocation>((event, emit) => emit(state.copyWith(
          selectedLocation: event.location,
          locationStep: LocationStep.detected,
        )));
    on<BookingConfirmLocation>((event, emit) => emit(state.copyWith(
          confirmedLocation: state.selectedLocation,
          locationStep: LocationStep.venue,
        )));
    on<BookingSelectBookingType>(
        (event, emit) => emit(state.copyWith(locationStep: LocationStep.bookingType)));
    on<BookingResetLocation>(
        (event, emit) => emit(state.copyWith(locationStep: LocationStep.search)));
    on<BookingChooseMode>(
        (event, emit) => emit(state.copyWith(bookingMode: event.mode)));
    on<BookingSelectScheduleMode>(
        (event, emit) => emit(state.copyWith(scheduleMode: event.mode)));
    on<BookingSelectDate>(
        (event, emit) => emit(state.copyWith(selectedDate: event.date)));
    on<BookingSelectTime>(
        (event, emit) => emit(state.copyWith(selectedTime: event.time)));
    on<BookingSelectDuration>(
        (event, emit) => emit(state.copyWith(selectedDuration: event.duration)));
    on<BookingSelectReferee>((event, emit) =>
        emit(state.copyWith(selectedReferee: event.referee)));
    on<BookingConfirm>((event, emit) =>
        emit(state.copyWith(bookingDetails: state.bookings.isNotEmpty
            ? state.bookings.first
            : null)));
    on<BookingPay>((event, emit) async {
      await repository.payBooking(event.bookingId, event.method);
    });
    on<BookingRateReview>((event, emit) async {
      await repository.submitReview(event.bookingId, event.rating);
      emit(state.copyWith(ratings: event.rating));
    });
  }

  Future<void> _onLoad(BookingEvent event, Emitter<BookingState> emit) async {
    emit(state.copyWith(isLoading: true, hasError: false, clearError: true));
    try {
      final bookings = await repository.fetchBookings();
      emit(state.copyWith(isLoading: false, bookings: bookings));
    } catch (error) {
      emit(state.copyWith(
        isLoading: false,
        hasError: true,
        error: Failure(error.toString()),
      ));
    }
  }
}
