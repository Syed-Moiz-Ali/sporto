import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:referee_app/features/matches/application/match_scoring_bloc.dart';
import 'package:referee_app/features/matches/presentation/screens/referee_home_screen.dart';
import 'package:shared_domain/shared_domain.dart';
import 'package:ui_kit/ui_kit.dart';

void main() {
  testWidgets('Referee Home empty Figma reference render', (tester) async {
    await _loadFigmaFonts();
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(390, 844);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);
    final repository = _PreviewMatchRepository(empty: true);
    final bloc = MatchScoringBloc(
      getMatchesUseCase: GetMatchesUseCase(repository),
      verifyMatchUseCase: VerifyMatchUseCase(repository),
      conductTossUseCase: ConductTossUseCase(repository),
      recordBallScoreUseCase: RecordBallScoreUseCase(repository),
    );
    addTearDown(bloc.close);
    await tester.pumpWidget(BlocProvider.value(
        value: bloc,
        child: MaterialApp(
            theme: SportoTheme.darkTheme,
            home: const Scaffold(body: RefereeHomeScreen()))));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    await expectLater(find.byType(RefereeHomeScreen),
        matchesGoldenFile('goldens/referee_home_empty_390x844.png'));
  });

  testWidgets('Referee Home Figma reference render', (tester) async {
    await _loadFigmaFonts();
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(390, 1097);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);

    final repository = _PreviewMatchRepository();
    final bloc = MatchScoringBloc(
      getMatchesUseCase: GetMatchesUseCase(repository),
      verifyMatchUseCase: VerifyMatchUseCase(repository),
      conductTossUseCase: ConductTossUseCase(repository),
      recordBallScoreUseCase: RecordBallScoreUseCase(repository),
    );
    addTearDown(bloc.close);

    await tester.pumpWidget(
      BlocProvider.value(
        value: bloc,
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: SportoTheme.darkTheme,
          home: RepaintBoundary(
            child: Scaffold(
              body: Column(
                children: [
                  const Expanded(child: RefereeHomeScreen()),
                  SportoBottomNav(
                    currentIndex: 0,
                    onTap: (_) {},
                    items: const [
                      SportoNavItem(Icons.home_rounded, 'Home'),
                      SportoNavItem(Icons.person_outline_rounded, 'Profile'),
                      SportoNavItem(Icons.more_horiz_rounded, 'More'),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await expectLater(
      find.byType(RepaintBoundary).first,
      matchesGoldenFile('goldens/referee_home_390x1097.png'),
    );
  });
}

Future<void> _loadFigmaFonts() async {
  final materialIcons = FontLoader('MaterialIcons')
    ..addFont(rootBundle.load('fonts/MaterialIcons-Regular.otf'));
  await materialIcons.load();

  for (final font in const {
    'packages/ui_kit/Quicksand':
        'packages/ui_kit/assets/fonts/Quicksand-Variable.ttf',
    'packages/ui_kit/Inter': 'packages/ui_kit/assets/fonts/Inter-Variable.ttf',
    'packages/ui_kit/Mulish':
        'packages/ui_kit/assets/fonts/Mulish-Variable.ttf',
  }.entries) {
    final loader = FontLoader(font.key)..addFont(rootBundle.load(font.value));
    await loader.load();
  }
}

class _PreviewMatchRepository implements IMatchRepository {
  _PreviewMatchRepository({bool empty = false})
      : _matches = empty
            ? []
            : [
                CricketMatchEntity(
                  id: 'figma-home',
                  tournamentName: 'Jaipur Super Over',
                  teamA: const TeamEntity(
                      id: 'a', name: 'Thunder Titans', logoEmoji: ''),
                  teamB: const TeamEntity(
                      id: 'b', name: 'Royal Strikers', logoEmoji: ''),
                  venue: 'Hyderabad',
                  scheduledTime: DateTime(2026, 8, 10, 20),
                  status: MatchStatus.live,
                  refereeName: 'Priya Agrawal',
                  teamAScore: 28,
                  teamAWickets: 1,
                  teamAOvers: 2.1,
                ),
              ];

  final List<CricketMatchEntity> _matches;

  @override
  Future<List<CricketMatchEntity>> getMatches() async => _matches;
  @override
  Future<CricketMatchEntity?> getMatchById(String id) async => _matches.first;
  @override
  Stream<List<CricketMatchEntity>> watchMatches() => Stream.value(_matches);
  @override
  Future<void> completeMatch(String matchId) async {}
  @override
  Future<void> conductToss(String matchId, TossResultEntity tossResult) async {}
  @override
  Future<void> recordBallScore(
      String matchId, BallScoreEntity ballScore) async {}
  @override
  Future<void> syncPendingMatches() async {}
  @override
  Future<void> verifyMatchRoster(String matchId) async {}
}
