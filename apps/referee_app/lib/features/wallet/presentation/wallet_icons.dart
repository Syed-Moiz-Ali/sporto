/// SVGs copied from the `redesign/wallet_transaction` screen exports.
///
/// Files live under `packages/ui_kit/assets/wallet/icons/` and are rendered by
/// `SportoSvgIcon` (which prefixes the `ui_kit` package automatically).
abstract final class WalletIcons {
  static const _dir = 'assets/wallet/icons';

  static const back = '$_dir/back.svg';
  static const sort = '$_dir/sort.svg';
  static const plus = '$_dir/plus.svg';
  static const arrowRight = '$_dir/arrow_right.svg';
  static const download = '$_dir/download.svg';
  static const checkCircle = '$_dir/check_circle.svg';
  static const cricketBat = '$_dir/cricket_bat.svg';

  /// Every wallet SVG, for exhaustive asset-loading tests.
  static const all = <String>[
    back,
    sort,
    plus,
    arrowRight,
    download,
    checkCircle,
    cricketBat,
  ];
}
