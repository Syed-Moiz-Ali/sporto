import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ui_kit/ui_kit.dart';

import '../core/di/dependency_injector.dart';
import '../features/tournaments/application/tournament_bloc.dart';
import 'router/app_router.dart';

class PartnerApp extends StatelessWidget {
  const PartnerApp({super.key});

  @override
  Widget build(BuildContext context) {
    final di = DependencyInjector.instance;
    return MultiBlocProvider(
      providers: [
        BlocProvider<ThemeBloc>.value(value: di.themeBloc),
        BlocProvider<ConnectivityBloc>.value(value: di.connectivityBloc),
        BlocProvider<AuthBloc>.value(value: di.authBloc),
        BlocProvider<TournamentBloc>.value(value: di.tournamentBloc),
      ],
      child: BlocBuilder<ThemeBloc, ThemeState>(
        builder: (context, themeState) {
          return MaterialApp.router(
            title: 'SPORTO Partner',
            theme: SportoTheme.darkTheme,
            darkTheme: SportoTheme.darkTheme,
            themeMode: themeState.themeMode,
            debugShowCheckedModeBanner: false,
            routerConfig: AppRouter.router,
            builder: (context, child) => SportoAppBackgroundScope(
              background: SportoAppBackground.partner,
              child: child ?? const SizedBox.shrink(),
            ),
          );
        },
      ),
    );
  }
}
