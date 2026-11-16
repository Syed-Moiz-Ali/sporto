import 'notification_icons.dart';

/// A single notification preference toggle.
///
/// Values intentionally live in the presentation layer only until the referee
/// preferences API ships. See `docs/referee_new_ui_backend_gaps.md`.
class NotificationPreference {
  const NotificationPreference({
    required this.id,
    required this.title,
    required this.description,
    this.defaultEnabled = false,
  });

  /// Stable identifier used by the UI and by tests.
  final String id;
  final String title;
  final String description;
  final bool defaultEnabled;
}

/// The five notification groups shown on the settings list screen.
///
/// The order of the enum values is the visual order of the Figma design.
enum NotificationCategory {
  match(
    id: 'match',
    title: 'Match Notifications',
    summary: 'Captain, Batter, Bowler',
    iconAsset: NotificationIcons.bell,
    preferences: <NotificationPreference>[
      NotificationPreference(
        id: 'match_reminders',
        title: 'Match Reminders',
        description: 'Get notified before your matches start.',
      ),
      NotificationPreference(
        id: 'match_starting_soon',
        title: 'Match Starting Soon',
        description: 'Reminder 30 minutes before your match.',
      ),
      NotificationPreference(
        id: 'live_match_updates',
        title: 'Live Match Updates',
        description: 'Get important updates while a match is live.',
        defaultEnabled: true,
      ),
      NotificationPreference(
        id: 'match_results',
        title: 'Match Results',
        description: 'Get notified when your match ends.',
      ),
    ],
  ),
  tournament(
    id: 'tournament',
    title: 'Tournament Updates',
    summary: 'Schedules, rounds & announcements',
    iconAsset: NotificationIcons.trophy,
    preferences: <NotificationPreference>[
      NotificationPreference(
        id: 'tournament_updates',
        title: 'Tournament Updates',
        description:
            'Schedule changes, round progression and important updates.',
      ),
      NotificationPreference(
        id: 'fixture_schedule_changes',
        title: 'Fixture & Schedule Changes',
        description: 'Get notified when match time, venue or opponent changes.',
      ),
      NotificationPreference(
        id: 'tournament_announcements',
        title: 'Tournament Announcements',
        description: 'Important announcements from tournament organizers.',
        defaultEnabled: true,
      ),
    ],
  ),
  team(
    id: 'team',
    title: 'Team & Requests',
    summary: 'Invites, join requests & updates',
    iconAsset: NotificationIcons.users,
    preferences: <NotificationPreference>[
      NotificationPreference(
        id: 'team_invitations',
        title: 'Team Invitations',
        description: 'When someone invites you to join their team.',
      ),
      NotificationPreference(
        id: 'team_join_requests',
        title: 'Team Join Requests',
        description:
            'Updates when your team join request is accepted or declined.',
      ),
      NotificationPreference(
        id: 'team_updates',
        title: 'Team Updates',
        description: 'Important changes to your team or squad.',
        defaultEnabled: true,
      ),
    ],
  ),
  registration(
    id: 'registration',
    title: 'Registration & Payments',
    summary: 'Registration & payment updates',
    iconAsset: NotificationIcons.card,
    preferences: <NotificationPreference>[
      NotificationPreference(
        id: 'registration_updates',
        title: 'Registration Updates',
        description: 'Registration approval, rejection or status changes.',
      ),
      NotificationPreference(
        id: 'payment_updates',
        title: 'Payment Updates',
        description: 'Payment confirmation, pending payments or refunds.',
      ),
    ],
  ),
  others(
    id: 'others',
    title: 'Others',
    summary: 'Nearby tournaments & offers',
    iconAsset: NotificationIcons.megaphone,
    preferences: <NotificationPreference>[
      NotificationPreference(
        id: 'nearby_tournament_alerts',
        title: 'Nearby Tournament Alerts',
        description: 'Get notified about relevant tournaments near you.',
      ),
      NotificationPreference(
        id: 'promotional_updates',
        title: 'Promotional Updates',
        description: 'New features, offers and occasional Sporto updates.',
      ),
    ],
  );

  const NotificationCategory({
    required this.id,
    required this.title,
    required this.summary,
    required this.iconAsset,
    required this.preferences,
  });

  final String id;
  final String title;

  /// Short secondary line shown in the settings list row.
  final String summary;

  /// SVG registered under `packages/ui_kit/assets/notifications/icons/`.
  final String iconAsset;
  final List<NotificationPreference> preferences;
}

/// Immutable snapshot of the (local-only) notification preferences.
///
/// TODO(referee-notifications): Replace this local state with the referee
/// notification-preferences endpoint once it exists. The missing endpoint is
/// tracked in `docs/referee_new_ui_backend_gaps.md`.
class NotificationPreferences {
  NotificationPreferences(Map<String, bool> values)
      : _values = Map<String, bool>.unmodifiable(values);

  /// Defaults for [category] as defined by the Figma frames.
  factory NotificationPreferences.defaultsFor(NotificationCategory category) {
    return NotificationPreferences(<String, bool>{
      for (final preference in category.preferences)
        preference.id: preference.defaultEnabled,
    });
  }

  final Map<String, bool> _values;

  /// Read-only view, useful for assertions and future persistence adapters.
  Map<String, bool> get values => _values;

  bool isEnabled(String id) => _values[id] ?? false;

  /// Fills any missing ids with the category defaults so callers may pass a
  /// partial `initialPreferences` map.
  NotificationPreferences resolvedFor(NotificationCategory category) {
    return NotificationPreferences(<String, bool>{
      for (final preference in category.preferences)
        preference.id: _values[preference.id] ?? preference.defaultEnabled,
    });
  }

  /// Returns a new snapshot with the given [id] flipped.
  NotificationPreferences toggled(String id) {
    return NotificationPreferences(<String, bool>{
      ..._values,
      id: !isEnabled(id),
    });
  }
}
