import 'package:flutter/material.dart';

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
