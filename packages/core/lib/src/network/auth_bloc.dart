import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_domain/shared_domain.dart';

// EVENTS
abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

class CheckAuthStatusEvent extends AuthEvent {}

class SendOtpRequestedEvent extends AuthEvent {
  final String mobileNumber;
  final String role;

  const SendOtpRequestedEvent({
    required this.mobileNumber,
    required this.role,
  });

  @override
  List<Object?> get props => [mobileNumber, role];
}

class VerifyOtpRequestedEvent extends AuthEvent {
  final String mobileNumber;
  final String otpCode;
  final String role;

  const VerifyOtpRequestedEvent({
    required this.mobileNumber,
    required this.otpCode,
    required this.role,
  });

  @override
  List<Object?> get props => [mobileNumber, otpCode, role];
}

class CompleteProfileRequestedEvent extends AuthEvent {
  final UserEntity updatedUser;

  const CompleteProfileRequestedEvent(this.updatedUser);

  @override
  List<Object?> get props => [updatedUser];
}

class LogoutRequestedEvent extends AuthEvent {}

// STATES
abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

class AuthInitialState extends AuthState {}

class AuthLoadingState extends AuthState {}

class OtpSentState extends AuthState {
  final String mobileNumber;

  const OtpSentState(this.mobileNumber);

  @override
  List<Object?> get props => [mobileNumber];
}

class NeedsOnboardingState extends AuthState {
  final UserEntity user;

  const NeedsOnboardingState(this.user);

  @override
  List<Object?> get props => [user];
}

class AuthenticatedState extends AuthState {
  final UserEntity user;

  const AuthenticatedState(this.user);

  @override
  List<Object?> get props => [user];
}

class UnauthenticatedState extends AuthState {}

class AuthErrorState extends AuthState {
  final String message;

  const AuthErrorState(this.message);

  @override
  List<Object?> get props => [message];
}

// BLOC (Full BLoC pattern - no Cubit)
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final SendOtpUseCase sendOtpUseCase;
  final VerifyOtpUseCase verifyOtpUseCase;
  final CompleteProfileUseCase completeProfileUseCase;
  final LogoutUseCase logoutUseCase;
  final GetCurrentUserUseCase getCurrentUserUseCase;

  AuthBloc({
    required this.sendOtpUseCase,
    required this.verifyOtpUseCase,
    required this.completeProfileUseCase,
    required this.logoutUseCase,
    required this.getCurrentUserUseCase,
  }) : super(AuthInitialState()) {
    on<CheckAuthStatusEvent>(_onCheckAuthStatus);
    on<SendOtpRequestedEvent>(_onSendOtpRequested);
    on<VerifyOtpRequestedEvent>(_onVerifyOtpRequested);
    on<CompleteProfileRequestedEvent>(_onCompleteProfileRequested);
    on<LogoutRequestedEvent>(_onLogoutRequested);
  }

  void _onCheckAuthStatus(
      CheckAuthStatusEvent event, Emitter<AuthState> emit) async {
    emit(AuthLoadingState());
    try {
      final user = await getCurrentUserUseCase();
      if (user != null) {
        if (user.isProfileComplete) {
          emit(AuthenticatedState(user));
        } else {
          emit(NeedsOnboardingState(user));
        }
      } else {
        emit(UnauthenticatedState());
      }
    } catch (_) {
      emit(UnauthenticatedState());
    }
  }

  void _onSendOtpRequested(
      SendOtpRequestedEvent event, Emitter<AuthState> emit) async {
    emit(AuthLoadingState());
    try {
      await sendOtpUseCase(event.mobileNumber, event.role);
      emit(OtpSentState(event.mobileNumber));
    } catch (e) {
      emit(AuthErrorState('Failed to send OTP: $e'));
    }
  }

  void _onVerifyOtpRequested(
      VerifyOtpRequestedEvent event, Emitter<AuthState> emit) async {
    emit(AuthLoadingState());
    try {
      final result =
          await verifyOtpUseCase(event.mobileNumber, event.otpCode, event.role);
      if (result.isNewUser || !result.user.isProfileComplete) {
        emit(NeedsOnboardingState(result.user));
      } else {
        emit(AuthenticatedState(result.user));
      }
    } catch (e) {
      emit(AuthErrorState('OTP verification failed: $e'));
    }
  }

  void _onCompleteProfileRequested(
      CompleteProfileRequestedEvent event, Emitter<AuthState> emit) async {
    emit(AuthLoadingState());
    try {
      final completedUser = await completeProfileUseCase(event.updatedUser);
      emit(AuthenticatedState(completedUser));
    } catch (e) {
      emit(AuthErrorState('Failed to save profile: $e'));
    }
  }

  void _onLogoutRequested(
      LogoutRequestedEvent event, Emitter<AuthState> emit) async {
    emit(AuthLoadingState());
    await logoutUseCase();
    emit(UnauthenticatedState());
  }
}
