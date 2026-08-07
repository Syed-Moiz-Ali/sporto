import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:core/core.dart';
import 'package:ui_kit/ui_kit.dart';

import '../../../../features/tournaments/presentation/screens/partner_main_screen.dart';

/// Handles splash + auth gate (login / onboarding / authenticated home).
class AuthFlowView extends StatefulWidget {
  const AuthFlowView({super.key});

  @override
  State<AuthFlowView> createState() => _AuthFlowViewState();
}

class _AuthFlowViewState extends State<AuthFlowView> {
  bool _splashFinished = false;

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
        if (state is AuthenticatedState) {
          return const PartnerMainScreen();
        }

        if (state is NeedsOnboardingState) {
          return AutomatedOnboardingWizard(
            user: state.user,
            onComplete: (updatedUser) {
              context
                  .read<AuthBloc>()
                  .add(CompleteProfileRequestedEvent(updatedUser));
            },
          );
        }

        return PhoneLoginScreen(
          appRole: 'partner',
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
