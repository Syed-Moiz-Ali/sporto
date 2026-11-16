import 'package:flutter/foundation.dart';

/// Whether the Figma placeholder data should be shown for the referee money
/// screens.
///
/// The wallet/bank/tournaments API endpoints do not exist yet, so debug and
/// profile builds render the exported Figma data to make the screens reviewable.
/// Release builds start empty and must not show another person's sample bank
/// accounts or fabricated balances. Pass
/// `--dart-define=REFEREE_DEMO_DATA=true` for a release demo build.
const bool kRefereeDemoData = bool.fromEnvironment(
  'REFEREE_DEMO_DATA',
  defaultValue: !kReleaseMode,
);
