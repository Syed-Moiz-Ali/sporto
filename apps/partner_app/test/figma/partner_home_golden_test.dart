import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:partner_app/features/tournaments/application/tournament_bloc.dart';
import 'package:partner_app/features/tournaments/presentation/screens/partner_main_screen.dart';
import 'package:shared_domain/shared_domain.dart';
import 'package:ui_kit/ui_kit.dart';

void main() {
  testWidgets('Partner Home phase1 reference render', (tester) async {
    await _loadFonts();
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(390, 1156);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);

    final repository = _PreviewTournamentRepository();
    final bloc = TournamentBloc(
      getTournamentsUseCase: GetTournamentsUseCase(repository),
      createTournamentUseCase: CreateTournamentUseCase(repository),
    );
    addTearDown(bloc.close);

    await tester.pumpWidget(
      BlocProvider.value(
        value: bloc,
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: SportoTheme.darkTheme,
          home: const PartnerMainScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await expectLater(
      find.byType(PartnerMainScreen),
      matchesGoldenFile('goldens/partner_home_390x1156.png'),
    );
  });

  testWidgets('Partner Profile renders inside the main IndexedStack',
      (tester) async {
    await _loadFonts();
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(390, 844);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);

    final repository = _PreviewTournamentRepository();
    final bloc = TournamentBloc(
      getTournamentsUseCase: GetTournamentsUseCase(repository),
      createTournamentUseCase: CreateTournamentUseCase(repository),
    );
    addTearDown(bloc.close);

    await tester.pumpWidget(
      BlocProvider.value(
        value: bloc,
        child: MaterialApp(
          theme: SportoTheme.darkTheme,
          home: const PartnerMainScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Profile'));
    await tester.pumpAndSettle();

    expect(find.text('Priya Agrawal'), findsOneWidget);
    expect(find.text('Create New Tournament'), findsNothing);
    expect(find.byType(SportoBottomNav), findsOneWidget);
    expect(tester.takeException(), isNull);

    await expectLater(
      find.byType(PartnerMainScreen),
      matchesGoldenFile('goldens/partner_profile_390x844.png'),
    );
  });

  for (final size in const [Size(320, 568), Size(430, 932)]) {
    testWidgets('Partner Home remains responsive at ${size.width}',
        (tester) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = size;
      addTearDown(tester.view.resetDevicePixelRatio);
      addTearDown(tester.view.resetPhysicalSize);

      final repository = _PreviewTournamentRepository();
      final bloc = TournamentBloc(
        getTournamentsUseCase: GetTournamentsUseCase(repository),
        createTournamentUseCase: CreateTournamentUseCase(repository),
      );
      addTearDown(bloc.close);

      await tester.pumpWidget(
        BlocProvider.value(
          value: bloc,
          child: MaterialApp(
            theme: SportoTheme.darkTheme,
            home: const PartnerMainScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    });
  }
}

Future<void> _loadFonts() async {
  for (final font in const {
    'MaterialIcons': 'fonts/MaterialIcons-Regular.otf',
    'packages/ui_kit/Space Grotesk':
        'packages/ui_kit/assets/fonts/SpaceGrotesk-Variable.ttf',
    'packages/ui_kit/Quicksand':
        'packages/ui_kit/assets/fonts/Quicksand-Variable.ttf',
    'packages/ui_kit/Inter': 'packages/ui_kit/assets/fonts/Inter-Variable.ttf',
  }.entries) {
    final loader = FontLoader(font.key)..addFont(rootBundle.load(font.value));
    await loader.load();
  }
}

class _PreviewTournamentRepository implements ITournamentRepository {
  @override
  Future<void> createTournament(TournamentEntity tournament) async {}

  @override
  Future<List<TournamentEntity>> getTournaments({SportType? sportType}) async =>
      const [];

  @override
  Future<void> syncPendingTournaments() async {}

  @override
  Stream<List<TournamentEntity>> watchTournaments() => const Stream.empty();
}
