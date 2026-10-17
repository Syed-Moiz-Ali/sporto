import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

abstract final class SportoAssets {
  static const package = 'ui_kit';

  static const home = 'assets/icons/home_inactive.png';
  static const matches = 'assets/icons/matches.png';
  static const tournaments = 'assets/icons/tournaments.png';
  static const profile = 'assets/icons/profile.png';

  static const addCircle = 'assets/icons/add_circle.png';
  static const locationPin = 'assets/icons/location_pin.png';
  static const cricketAction = 'assets/icons/announcement.png';
  static const announcement = cricketAction;
  static const calendarTick = 'assets/icons/calendar_tick.png';
  static const searchNormal = 'assets/icons/search_normal.png';
  static const mic = 'assets/icons/mic.png';
  static const soccer = 'assets/icons/soccer.png';
  static const genderMale = 'assets/icons/gender_male.png';
  static const genderFemale = 'assets/icons/gender_female.png';

  static const playAndWin = 'assets/images/sporto_play_and_win.png';
}

/// SVG icons migrated from the Figma "User App" referee-booking export.
/// Sources and original node names are documented in `docs/asset_mapping.md`.
abstract final class SportoRefereeBookingIcons {
  static const _dir = 'assets/referee_booking/icons';

  static const back = '$_dir/ic_back.svg';
  static const search = '$_dir/ic_search.svg';
  static const chevronRight = '$_dir/ic_chevron_right.svg';
  static const check = '$_dir/ic_check.svg';
  static const checkGreen = '$_dir/ic_check_green.svg';
  static const checkBlue = '$_dir/ic_check_blue.svg';
  static const creditCard = '$_dir/ic_credit_card.svg';
  static const wallet = '$_dir/ic_wallet.svg';
  static const addSquare = '$_dir/ic_add_square.svg';
  static const gps = '$_dir/ic_gps.svg';
  static const gpsSmall = '$_dir/ic_gps_sm.svg';
  static const clockOrange = '$_dir/ic_clock_orange.svg';
  static const clockGreen = '$_dir/ic_clock_green.svg';
  static const pinGreen = '$_dir/ic_pin_green.svg';
  static const pinGreenSmall = '$_dir/ic_pin_green_sm.svg';
  static const pinGold = '$_dir/ic_pin_gold.svg';
  static const pinGoldSmall = '$_dir/ic_pin_gold_sm.svg';
  static const starGold = '$_dir/ic_star_gold.svg';
  static const starGoldSmall = '$_dir/ic_star_gold_sm.svg';
  static const flashGreen = '$_dir/ic_flash_green.svg';
  static const profileTwoUser = '$_dir/ic_profile_2user.svg';
  static const sport = '$_dir/ic_sport.svg';
  static const sportCricket = '$_dir/sport_cricket.svg';
  static const sportFootball = '$_dir/sport_football.svg';
  static const statusDotGreen = '$_dir/status_dot_green.svg';
  static const statusDotGreenSmall = '$_dir/status_dot_green_sm.svg';
  static const statusDotGold = '$_dir/status_dot_gold.svg';
  static const dotSeparator = '$_dir/dot_separator.svg';
  static const dotSeparatorSmall = '$_dir/dot_separator_sm.svg';
  static const dividerHairline = '$_dir/divider_hairline.svg';
  static const dividerHairlineShort = '$_dir/divider_hairline_short.svg';
  static const dividerSolid = '$_dir/divider_solid.svg';
  static const dividerVertical = '$_dir/divider_vertical.svg';
  static const ratingStarsGold = '$_dir/rating_stars_gold.svg';
  static const ratingStarsGoldLarge = '$_dir/rating_stars_gold_lg.svg';
  static const ratingStarsGoldPage = '$_dir/rating_stars_gold_pg.svg';

  /// Every registered SVG, for exhaustive asset loading tests.
  static const List<String> all = [
    back,
    search,
    chevronRight,
    check,
    checkGreen,
    checkBlue,
    creditCard,
    wallet,
    addSquare,
    gps,
    gpsSmall,
    clockOrange,
    clockGreen,
    pinGreen,
    pinGreenSmall,
    pinGold,
    pinGoldSmall,
    starGold,
    starGoldSmall,
    flashGreen,
    profileTwoUser,
    sport,
    sportCricket,
    sportFootball,
    statusDotGreen,
    statusDotGreenSmall,
    statusDotGold,
    dotSeparator,
    dotSeparatorSmall,
    dividerHairline,
    dividerHairlineShort,
    dividerSolid,
    dividerVertical,
    ratingStarsGold,
    ratingStarsGoldLarge,
    ratingStarsGoldPage,
  ];

  static const avatarReferee =
      'assets/referee_booking/images/avatar_referee.png';
}

class SportoAssetIcon extends StatelessWidget {
  final String asset;
  final double? size;
  final Color? color;
  final BoxFit fit;

  const SportoAssetIcon(
    this.asset, {
    super.key,
    this.size,
    this.color,
    this.fit = BoxFit.contain,
  });

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      asset,
      package: SportoAssets.package,
      width: size,
      height: size,
      fit: fit,
      color: color,
      colorBlendMode: color == null ? null : BlendMode.srcIn,
      filterQuality: FilterQuality.high,
    );
  }
}

/// Renders a bundled SVG icon from [SportoRefereeBookingIcons].
/// Pass [color] only for monochrome icons; accent (multi-color / gradient)
/// icons must be rendered without a tint.
class SportoSvgIcon extends StatelessWidget {
  final String asset;
  final double? size;
  final double? width;
  final double? height;
  final Color? color;
  final BoxFit fit;

  const SportoSvgIcon(
    this.asset, {
    super.key,
    this.size,
    this.width,
    this.height,
    this.color,
    this.fit = BoxFit.contain,
  });

  @override
  Widget build(BuildContext context) {
    final w = width ?? size;
    final h = height ?? size;
    return SvgPicture.asset(
      asset,
      package: SportoAssets.package,
      width: w,
      height: h,
      fit: fit,
      colorFilter: color == null
          ? null
          : ColorFilter.mode(color!, BlendMode.srcIn),
    );
  }
}
