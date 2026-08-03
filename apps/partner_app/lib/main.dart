import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:core/core.dart';
import 'package:ui_kit/ui_kit.dart';
import 'package:partner_data/partner_data.dart';
import 'package:shared_domain/shared_domain.dart';

import 'src/bloc/tournament_bloc.dart';
import 'src/views/partner_main_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await HiveService.init();

  final authRepo = AuthRepositoryImpl();
  final sendOtpUseCase = SendOtpUseCase(authRepo);
  final verifyOtpUseCase = VerifyOtpUseCase(authRepo);
  final completeProfileUseCase = CompleteProfileUseCase(authRepo);
  final logoutUseCase = LogoutUseCase(authRepo);
  final getCurrentUserUseCase = GetCurrentUserUseCase(authRepo);

  final tournamentRepo = TournamentRepositoryImpl();
  final getTournamentsUseCase = GetTournamentsUseCase(tournamentRepo);
  final createTournamentUseCase = CreateTournamentUseCase(tournamentRepo);

  runApp(PartnerApp(
    sendOtpUseCase: sendOtpUseCase,
    verifyOtpUseCase: verifyOtpUseCase,
    completeProfileUseCase: completeProfileUseCase,
    logoutUseCase: logoutUseCase,
    getCurrentUserUseCase: getCurrentUserUseCase,
    getTournamentsUseCase: getTournamentsUseCase,
    createTournamentUseCase: createTournamentUseCase,
  ));
}

class PartnerApp extends StatelessWidget {
  final SendOtpUseCase sendOtpUseCase;
  final VerifyOtpUseCase verifyOtpUseCase;
  final CompleteProfileUseCase completeProfileUseCase;
  final LogoutUseCase logoutUseCase;
  final GetCurrentUserUseCase getCurrentUserUseCase;

  final GetTournamentsUseCase getTournamentsUseCase;
  final CreateTournamentUseCase createTournamentUseCase;

  const PartnerApp({
    super.key,
    required this.sendOtpUseCase,
    required this.verifyOtpUseCase,
    required this.completeProfileUseCase,
    required this.logoutUseCase,
    required this.getCurrentUserUseCase,
    required this.getTournamentsUseCase,
    required this.createTournamentUseCase,
  });

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<ThemeBloc>(
          create: (_) => ThemeBloc()..add(InitThemeEvent()),
        ),
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
        BlocProvider<TournamentBloc>(
          create: (_) => TournamentBloc(
            getTournamentsUseCase: getTournamentsUseCase,
            createTournamentUseCase: createTournamentUseCase,
          ),
        ),
      ],
      child: BlocBuilder<ThemeBloc, ThemeState>(
        builder: (context, themeState) {
          return MaterialApp(
            title: 'SPORTO Partner',
            theme: SportoTheme.lightTheme, // Default Light Theme
            darkTheme: SportoTheme.darkTheme,
            themeMode: themeState.themeMode,
            debugShowCheckedModeBanner: false,
            home: const AuthFlowWrapper(),
          );
        },
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
          return const PartnerMainScreen();
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
