import 'package:flutter/foundation.dart';

import 'notification_models.dart';

/// Session-scoped notification preference store.
///
/// TODO(referee-notifications): Replace with the server-backed preferences
/// endpoint once it exists (see `docs/referee_new_ui_backend_gaps.md`). Until
/// then this keeps toggles alive when the user backs out of a category instead
/// of silently resetting them.
class NotificationPreferencesStore extends ChangeNotifier {
  NotificationPreferencesStore._();

  static final NotificationPreferencesStore instance =
      NotificationPreferencesStore._();

  final Map<NotificationCategory, NotificationPreferences> _preferences = {};

  NotificationPreferences preferencesFor(NotificationCategory category) {
    return _preferences[category] ??=
        NotificationPreferences.defaultsFor(category);
  }

  void update(
    NotificationCategory category,
    NotificationPreferences preferences,
  ) {
    _preferences[category] = preferences;
    notifyListeners();
  }

  /// Clears the previous referee's consent choices on logout/session expiry.
  void clearForSession() {
    _preferences.clear();
    notifyListeners();
  }

  @visibleForTesting
  void reset() {
    _preferences.clear();
    notifyListeners();
  }
}
