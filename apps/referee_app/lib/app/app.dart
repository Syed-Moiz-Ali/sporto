import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:core/core.dart';
import 'package:ui_kit/ui_kit.dart';

import '../../core/di/dependency_injector.dart';
import '../../features/matches/application/match_scoring_bloc.dart';
import 'router/app_router.dart';

class RefereeApp extends StatelessWidget {
  const RefereeApp({super.key});

  @override
  Widget build(BuildContext context) {
    final di = DependencyInjector.instance;
    return MultiBlocProvider(
      providers: [
        BlocProvider<ThemeBloc>.value(value: di.themeBloc),
        BlocProvider<ConnectivityBloc>.value(value: di.connectivityBloc),
        BlocProvider<AuthBloc>.value(value: di.authBloc),
        BlocProvider<MatchScoringBloc>.value(value: di.matchScoringBloc),
      ],
      child: BlocBuilder<ThemeBloc, ThemeState>(
        builder: (context, themeState) {
          return MaterialApp.router(
            title: 'SPORTO Referee',
            theme: SportoTheme.darkTheme,
            darkTheme: SportoTheme.darkTheme,
            themeMode: themeState.themeMode,
            debugShowCheckedModeBanner: false,
            routerConfig: AppRouter.router,
            builder: (context, child) => SportoAppTextScale(
              child: SportoAppBackgroundScope(
                background: SportoAppBackground.referee,
                child: child ?? const SizedBox.shrink(),
              ),
            ),
          );
        },
      ),
    );
  }
}
