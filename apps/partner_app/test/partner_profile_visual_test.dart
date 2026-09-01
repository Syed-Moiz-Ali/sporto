import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:partner_app/features/partner_api/application/partner_api_bloc.dart';
import 'package:partner_app/features/tournaments/presentation/screens/partner_profile_detail_screens.dart';
import 'package:partner_app/features/tournaments/presentation/screens/profile_screen.dart';
import 'package:partner_data/partner_data.dart';
import 'package:ui_kit/ui_kit.dart';

void main() {
  setUpAll(_loadFonts);

  testWidgets('partner profile hub reference render', (tester) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(390, 1175);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);

    final bloc = PartnerApiBloc(remoteDataSource: _FakeRemoteDataSource());
    addTearDown(bloc.close);
    await tester.pumpWidget(
      MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: SportoTheme.darkTheme,
        home: BlocProvider<PartnerApiBloc>.value(
          value: bloc,
          child: SportoAppBackgroundScope(
            background: SportoAppBackground.partner,
            child: SportoBottomTabShell(
              initialIndex: 3,
              tabs: [
                SizedBox.shrink(),
                SizedBox.shrink(),
                SizedBox.shrink(),
                PartnerProfileScreen(),
              ],
              items: [
                SportoNavItem.asset(asset: SportoAssets.home, label: 'Home'),
                SportoNavItem.asset(
                    asset: SportoAssets.tournaments, label: 'Tournaments'),
                SportoNavItem.asset(
                    asset: SportoAssets.matches, label: 'Schedules'),
                SportoNavItem.asset(
                    asset: SportoAssets.profile, label: 'Profile'),
              ],
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await expectLater(
      find.byType(SportoBottomTabShell),
      matchesGoldenFile('goldens/partner_profile_hub.png'),
    );
  });

  for (final entry in <String, Widget>{
    'wallet': const PartnerWalletScreen(),
    'score': const PartnerScoreScreen(),
    'bank': const PartnerBankAccountScreen(),
    'verification': const PartnerVerificationScreen(),
  }.entries) {
    testWidgets('partner profile ${entry.key} reference render',
        (tester) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = const Size(390, 844);
      addTearDown(tester.view.resetDevicePixelRatio);
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(
        MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: SportoTheme.darkTheme,
          home: SportoAppBackgroundScope(
            background: SportoAppBackground.partner,
            child: SportoAppTextScale(child: entry.value),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await expectLater(
        find.byType(entry.value.runtimeType),
        matchesGoldenFile('goldens/partner_profile_${entry.key}.png'),
      );
    });
  }
}

class _FakeRemoteDataSource implements PartnerRemoteDataSource {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

Future<void> _loadFonts() async {
  for (final font in const {
    'MaterialIcons': ['fonts/MaterialIcons-Regular.otf'],
    'packages/ui_kit/Quicksand': [
      'packages/ui_kit/assets/fonts/Quicksand-Regular.ttf',
      'packages/ui_kit/assets/fonts/Quicksand-Medium.ttf',
      'packages/ui_kit/assets/fonts/Quicksand-SemiBold.ttf',
      'packages/ui_kit/assets/fonts/Quicksand-Bold.ttf',
    ],
  }.entries) {
    final loader = FontLoader(font.key);
    for (final asset in font.value) {
      loader.addFont(rootBundle.load(asset));
    }
    await loader.load();
  }
}
