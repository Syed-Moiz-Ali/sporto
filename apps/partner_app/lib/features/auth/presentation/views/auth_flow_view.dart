import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:core/core.dart';
import 'package:ui_kit/ui_kit.dart';

import '../../../../features/tournaments/presentation/screens/partner_main_screen.dart';

/// Handles splash + auth gate (login / onboarding / authenticated home).
class AuthFlowView extends StatefulWidget {
  final int initialTabIndex;

  const AuthFlowView({
    super.key,
    this.initialTabIndex = 0,
  });

  @override
  State<AuthFlowView> createState() => _AuthFlowViewState();
}

class _AuthFlowViewState extends State<AuthFlowView> {
  bool _splashFinished = false;

  // Last non-loading auth state - keeps the current screen visible
  // (with an in-button spinner) while auth operations are in flight.
  AuthState? _lastScreenState;

  @override
  Widget build(BuildContext context) {
    if (!_splashFinished) {
      return SplashScreen(
          onFinish: () => setState(() => _splashFinished = true));
    }

    return BlocConsumer<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthErrorState) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text(state.message),
                backgroundColor: Theme.of(context).colorScheme.error),
          );
        }
      },
      builder: (context, state) {
        if (state is! AuthLoadingState) {
          _lastScreenState = state;
        }

        final screenState =
            state is AuthLoadingState ? (_lastScreenState ?? state) : state;
        final isSubmitting = state is AuthLoadingState;

        if (screenState is AuthenticatedState) {
          return PartnerMainScreen(initialIndex: widget.initialTabIndex);
        }

        if (screenState is NeedsOnboardingState) {
          return AutomatedOnboardingWizard(
            user: screenState.user,
            onComplete: (updatedUser) {
              context
                  .read<AuthBloc>()
                  .add(CompleteProfileRequestedEvent(updatedUser));
            },
            onGoHome: () {
              context.read<AuthBloc>().add(LogoutRequestedEvent());
            },
          );
        }

        return PhoneLoginScreen(
          appRole: 'partner',
          initialMobileNumber:
              screenState is OtpSentState ? screenState.mobileNumber : null,
          isSubmitting: isSubmitting,
          onSendOtp: (mobileNumber) {
            context.read<AuthBloc>().add(SendOtpRequestedEvent(mobileNumber));
          },
          onVerifyOtp: (mobileNumber, otpCode) {
            context.read<AuthBloc>().add(VerifyOtpRequestedEvent(
                  mobileNumber: mobileNumber,
                  otpCode: otpCode,
                  role: 'partner',
                ));
          },
        );
      },
    );
  }
}
