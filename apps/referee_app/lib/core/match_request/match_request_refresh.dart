import 'package:flutter/foundation.dart';

/// Broadcasts a completed match-request accept/decline so every screen that
/// shows requests or assigned matches re-hits the referee APIs.
abstract final class MatchRequestRefresh {
  static final ValueNotifier<int> revision = ValueNotifier<int>(0);

  static void bump() => revision.value++;
}
