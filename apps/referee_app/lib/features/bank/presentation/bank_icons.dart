/// Bundled assets for the referee bank-account flow.
///
/// The SVG sources were exported from the `redesign/bank_account` Figma
/// package and copied into `packages/ui_kit/assets/bank/icons` so screens can
/// resolve them through [SportoSvgIcon] using the `ui_kit` asset package.
abstract final class BankIcons {
  static const _dir = 'assets/bank/icons';

  static const back = '$_dir/bank_back.svg';
  static const plus = '$_dir/bank_plus.svg';
  static const plusGreen = '$_dir/bank_plus_green.svg';
  static const alert = '$_dir/bank_alert.svg';
  static const lock = '$_dir/bank_lock.svg';
  static const eye = '$_dir/bank_eye.svg';
  static const eyeOff = '$_dir/bank_eye_off.svg';
  static const checkCircle = '$_dir/bank_check_circle.svg';

  static const logoSbi = '$_dir/bank_logo_sbi.svg';
  static const logoHdfc = '$_dir/bank_logo_hdfc.svg';
  static const logoBob = '$_dir/bank_logo_bob.svg';

  /// Best-effort logo for accounts added through the local form.
  static String logoForBank(String bankName) {
    final name = bankName.toLowerCase();
    if (name.contains('sbi') || name.contains('state bank')) return logoSbi;
    if (name.contains('hdfc')) return logoHdfc;
    if (name.contains('bob') || name.contains('baroda')) return logoBob;
    return '';
  }

  /// Every registered bank asset, for smoke tests.
  static const all = <String>[
    back,
    plus,
    plusGreen,
    alert,
    lock,
    eye,
    eyeOff,
    checkCircle,
    logoSbi,
    logoHdfc,
    logoBob,
  ];
}
