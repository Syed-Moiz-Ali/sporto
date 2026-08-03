import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:core/core.dart';
import 'package:ui_kit/ui_kit.dart';
import 'package:referee_data/referee_data.dart';
import 'package:shared_domain/shared_domain.dart';

import 'src/bloc/match_scoring_bloc.dart';
import 'src/views/referee_home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await HiveService.init();

  final authRepo = AuthRepositoryImpl();
  final sendOtpUseCase = SendOtpUseCase(authRepo);
  final verifyOtpUseCase = VerifyOtpUseCase(authRepo);
  final completeProfileUseCase = CompleteProfileUseCase(authRepo);
  final logoutUseCase = LogoutUseCase(authRepo);
  final getCurrentUserUseCase = GetCurrentUserUseCase(authRepo);

  final matchRepo = MatchRepositoryImpl();
  final getMatchesUseCase = GetMatchesUseCase(matchRepo);
  final verifyMatchUseCase = VerifyMatchUseCase(matchRepo);
  final conductTossUseCase = ConductTossUseCase(matchRepo);
  final recordBallScoreUseCase = RecordBallScoreUseCase(matchRepo);

  runApp(RefereeApp(
    sendOtpUseCase: sendOtpUseCase,
    verifyOtpUseCase: verifyOtpUseCase,
    completeProfileUseCase: completeProfileUseCase,
    logoutUseCase: logoutUseCase,
    getCurrentUserUseCase: getCurrentUserUseCase,
    getMatchesUseCase: getMatchesUseCase,
    verifyMatchUseCase: verifyMatchUseCase,
    conductTossUseCase: conductTossUseCase,
    recordBallScoreUseCase: recordBallScoreUseCase,
  ));
}

class RefereeApp extends StatelessWidget {
  final SendOtpUseCase sendOtpUseCase;
  final VerifyOtpUseCase verifyOtpUseCase;
  final CompleteProfileUseCase completeProfileUseCase;
  final LogoutUseCase logoutUseCase;
  final GetCurrentUserUseCase getCurrentUserUseCase;

  final GetMatchesUseCase getMatchesUseCase;
  final VerifyMatchUseCase verifyMatchUseCase;
  final ConductTossUseCase conductTossUseCase;
  final RecordBallScoreUseCase recordBallScoreUseCase;

  const RefereeApp({
    super.key,
    required this.sendOtpUseCase,
    required this.verifyOtpUseCase,
    required this.completeProfileUseCase,
    required this.logoutUseCase,
    required this.getCurrentUserUseCase,
    required this.getMatchesUseCase,
    required this.verifyMatchUseCase,
    required this.conductTossUseCase,
    required this.recordBallScoreUseCase,
  });

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<ConnectivityBloc>(
          create: (_) => ConnectivityBloc()..add(StartConnectivityWatcherEvent()),
        ),
        BlocProvider<AuthBloc>(
          create: (_) => AuthBloc(
            sendOtpUseCase: sendOtpUseCase,
            verifyOtpUseCase: verifyOtpUseCase,
            completeProfileUseCase: completeProfileUseCase,
            logoutUseCase: logoutUseCase,
            getCurrentUserUseCase: getCurrentUserUseCase,
          )..add(CheckAuthStatusEvent()),
        ),
        BlocProvider<MatchScoringBloc>(
          create: (_) => MatchScoringBloc(
            getMatchesUseCase: getMatchesUseCase,
            verifyMatchUseCase: verifyMatchUseCase,
            conductTossUseCase: conductTossUseCase,
            recordBallScoreUseCase: recordBallScoreUseCase,
          ),
        ),
      ],
      child: MaterialApp(
        title: 'SPORTO Referee',
        theme: SportoTheme.darkTheme,
        debugShowCheckedModeBanner: false,
        home: const AuthFlowWrapper(),
      ),
    );
  }
}

class AuthFlowWrapper extends StatefulWidget {
  const AuthFlowWrapper({super.key});

  @override
  State<AuthFlowWrapper> createState() => _AuthFlowWrapperState();
}

class _AuthFlowWrapperState extends State<AuthFlowWrapper> {
  bool _splashFinished = false;

  @override
  Widget build(BuildContext context) {
    if (!_splashFinished) {
      return SplashScreen(onFinish: () => setState(() => _splashFinished = true));
    }

    return BlocConsumer<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthErrorState) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message), backgroundColor: Theme.of(context).colorScheme.error),
          );
        }
      },
      builder: (context, state) {
        if (state is AuthenticatedState) {
          return const RefereeHomeScreen();
        }

        if (state is NeedsOnboardingState) {
          return AutomatedOnboardingWizard(
            user: state.user,
            onComplete: (updatedUser) {
              context.read<AuthBloc>().add(CompleteProfileRequestedEvent(updatedUser));
            },
          );
        }

        return PhoneLoginScreen(
          appRole: 'referee',
          onSendOtp: (mobileNumber) {
            context.read<AuthBloc>().add(SendOtpRequestedEvent(mobileNumber));
          },
          onVerifyOtp: (mobileNumber, otpCode) {
            context.read<AuthBloc>().add(VerifyOtpRequestedEvent(
                  mobileNumber: mobileNumber,
                  otpCode: otpCode,
                  role: 'referee',
                ));
          },
        );
      },
    );
  }
}
