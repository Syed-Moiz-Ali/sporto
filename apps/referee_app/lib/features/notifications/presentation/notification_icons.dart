/// SVG assets used by the notification settings flow.
///
/// The files live in `packages/ui_kit/assets/notifications/icons/`, which is
/// already declared in the ui_kit pubspec. Render them with [SportoSvgIcon].
abstract final class NotificationIcons {
  static const String _dir = 'assets/notifications/icons';

  static const String back = '$_dir/back.svg';
  static const String bell = '$_dir/bell.svg';
  static const String trophy = '$_dir/trophy.svg';
  static const String users = '$_dir/users.svg';
  static const String card = '$_dir/card.svg';
  static const String megaphone = '$_dir/megaphone.svg';
  static const String chevronRight = '$_dir/chevron_right.svg';

  /// Every icon in this flow, handy for asset-loading guard tests.
  static const List<String> all = <String>[
    back,
    bell,
    trophy,
    users,
    card,
    megaphone,
    chevronRight,
  ];
}
