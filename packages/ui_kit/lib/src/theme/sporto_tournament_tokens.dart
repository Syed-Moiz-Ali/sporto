import 'package:flutter/material.dart';

/// Design tokens for the Partner Tournament redesign.
///
/// These values are additive to [SportoDesignTokens] and keep the new
/// tournament screens visually aligned with the Figma export while still
/// using the shared SPORTO theme injection mechanism.
@immutable
class SportoTournamentTokens extends ThemeExtension<SportoTournamentTokens> {
  const SportoTournamentTokens({
    required this.screenBase,
    required this.screenHeader,
    required this.card,
    required this.cardAlt,
    required this.cardElevated,
    required this.panel,
    required this.border,
    required this.borderSoft,
    required this.white,
    required this.warm,
    required this.muted,
    required this.dim,
    required this.textSoft,
    required this.live,
    required this.liveSoft,
    required this.upcoming,
    required this.underReview,
    required this.changesRequested,
    required this.completed,
    required this.draft,
    required this.green,
    required this.greenBright,
    required this.gold,
    required this.goldBright,
    required this.blue,
    required this.blueBright,
    required this.pink,
    required this.pinkBright,
    required this.orange,
    required this.orangeStrong,
    required this.amber,
    required this.red,
    required this.liveCardGradient,
    required this.liveCardBorderGradient,
    required this.bluePillGradient,
    required this.goldPillGradient,
    required this.greenPillGradient,
    required this.orangePillGradient,
    required this.redPillGradient,
    required this.bracketPanelGradient,
    required this.financialPositiveGradient,
    required this.financialNegativeGradient,
    required this.cardFadeGradient,
    required this.headerGradient,
    required this.liveGlow,
    required this.greenGlow,
    required this.goldGlow,
    required this.blueGlow,
    required this.pinkGlow,
    required this.softCardShadow,
    required this.strongCardShadow,
    required this.innerWhiteStroke,
    required this.r4_44,
    required this.r5,
    required this.r6,
    required this.r9,
    required this.r9_07,
    required this.r10,
    required this.r11,
    required this.r14,
    required this.r18,
    required this.r44,
    required this.r50,
    required this.r75,
    required this.r80,
    required this.r90,
  });

  final Color screenBase;
  final Color screenHeader;
  final Color card;
  final Color cardAlt;
  final Color cardElevated;
  final Color panel;
  final Color border;
  final Color borderSoft;
  final Color white;
  final Color warm;
  final Color muted;
  final Color dim;
  final Color textSoft;
  final Color live;
  final Color liveSoft;
  final Color upcoming;
  final Color underReview;
  final Color changesRequested;
  final Color completed;
  final Color draft;
  final Color green;
  final Color greenBright;
  final Color gold;
  final Color goldBright;
  final Color blue;
  final Color blueBright;
  final Color pink;
  final Color pinkBright;
  final Color orange;
  final Color orangeStrong;
  final Color amber;
  final Color red;

  final LinearGradient liveCardGradient;
  final LinearGradient liveCardBorderGradient;
  final LinearGradient bluePillGradient;
  final LinearGradient goldPillGradient;
  final LinearGradient greenPillGradient;
  final LinearGradient orangePillGradient;
  final LinearGradient redPillGradient;
  final LinearGradient bracketPanelGradient;
  final LinearGradient financialPositiveGradient;
  final LinearGradient financialNegativeGradient;
  final LinearGradient cardFadeGradient;
  final LinearGradient headerGradient;

  final List<BoxShadow> liveGlow;
  final List<BoxShadow> greenGlow;
  final List<BoxShadow> goldGlow;
  final List<BoxShadow> blueGlow;
  final List<BoxShadow> pinkGlow;
  final List<BoxShadow> softCardShadow;
  final List<BoxShadow> strongCardShadow;
  final List<BoxShadow> innerWhiteStroke;

  final double r4_44;
  final double r5;
  final double r6;
  final double r9;
  final double r9_07;
  final double r10;
  final double r11;
  final double r14;
  final double r18;
  final double r44;
  final double r50;
  final double r75;
  final double r80;
  final double r90;

  static const dark = SportoTournamentTokens(
    screenBase: Color(0xFF090C10),
    screenHeader: Color(0xFF0A0E12),
    card: Color(0xFF17191E),
    cardAlt: Color(0xFF13161A),
    cardElevated: Color(0xFF1C2026),
    panel: Color(0xFF1B2335),
    border: Color(0xFF283040),
    borderSoft: Color(0x33283040),
    white: Color(0xFFFFFFFF),
    warm: Color(0xFFF3EEE2),
    muted: Color(0xFFAAAAAA),
    dim: Color(0xFF666666),
    textSoft: Color(0xCCFFFFFF),
    live: Color(0xFFFE464B),
    liveSoft: Color(0x1AFE464B),
    upcoming: Color(0xFFFF6C4A),
    underReview: Color(0xFFF4B41A),
    changesRequested: Color(0xFFFF5CBE),
    completed: Color(0xFF65C6F8),
    draft: Color(0xFFAAAAAA),
    green: Color(0xFF2BB673),
    greenBright: Color(0xFF81F78C),
    gold: Color(0xFFF4B41A),
    goldBright: Color(0xFFFEC955),
    blue: Color(0xFF4FBAF0),
    blueBright: Color(0xFF7AD3FF),
    pink: Color(0xFFED5EC5),
    pinkBright: Color(0xFFFF5CBE),
    orange: Color(0xFFF9794C),
    orangeStrong: Color(0xFFEA4C00),
    amber: Color(0xFFDE8C12),
    red: Color(0xFFFE464B),
    liveCardGradient: LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [Color(0xFF3A0E07), Color(0xFF28100C)],
    ),
    liveCardBorderGradient: LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [Color(0x66FE464B), Color(0x1AFE464B)],
    ),
    bluePillGradient: LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [Color(0xFF7AD3FF), Color(0xFF4FBAF0)],
    ),
    goldPillGradient: LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [Color(0xFFFFD572), Color(0xFFFEBD38)],
    ),
    greenPillGradient: LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [Color(0xFF99FFA3), Color(0xFF68EE76)],
    ),
    orangePillGradient: LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [Color(0xFFFF9364), Color(0xFFF25F33)],
    ),
    redPillGradient: LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [Color(0xFFFE6C6C), Color(0xFFFE464B)],
    ),
    bracketPanelGradient: LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [Color(0x1A28A166), Color(0x0A28A166)],
    ),
    financialPositiveGradient: LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [Color(0x1A2BB673), Color(0x0A2BB673)],
    ),
    financialNegativeGradient: LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [Color(0x33B40003), Color(0x0AB40003)],
    ),
    cardFadeGradient: LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [Color(0xFF1C2026), Color(0x001C2026)],
    ),
    headerGradient: LinearGradient(
      begin: Alignment(-0.36, 1.46),
      end: Alignment(0.36, -1.46),
      colors: [Color(0x0A6075FF), Color(0x0A274D4D)],
      stops: [0, 0.7],
    ),
    liveGlow: [
      BoxShadow(
        color: Color(0x33FE464B),
        offset: Offset(0, 3),
        blurRadius: 10,
      ),
    ],
    greenGlow: [
      BoxShadow(
        color: Color(0x1A2BB673),
        offset: Offset(0, 4),
        blurRadius: 11,
        spreadRadius: 1,
      ),
    ],
    goldGlow: [
      BoxShadow(
        color: Color(0x29ED7B00),
        offset: Offset(0, 3),
        blurRadius: 10,
      ),
    ],
    blueGlow: [
      BoxShadow(
        color: Color(0x1A4FBAF0),
        offset: Offset(0, 2),
        blurRadius: 8,
      ),
    ],
    pinkGlow: [
      BoxShadow(
        color: Color(0x4CEC5FC2),
        offset: Offset(0, 1),
        blurRadius: 2,
      ),
    ],
    softCardShadow: [
      BoxShadow(
        color: Color(0x1A000000),
        offset: Offset(0, 2),
        blurRadius: 8,
      ),
    ],
    strongCardShadow: [
      BoxShadow(
        color: Color(0x29000000),
        offset: Offset(0, 2),
        blurRadius: 8,
      ),
    ],
    innerWhiteStroke: [
      BoxShadow(
        color: Color(0x0FFFFFFF),
        offset: Offset(0, 1),
        spreadRadius: 1,
      ),
    ],
    r4_44: 4.44,
    r5: 5,
    r6: 6,
    r9: 9,
    r9_07: 9.07,
    r10: 10,
    r11: 11,
    r14: 14,
    r18: 18,
    r44: 44,
    r50: 50,
    r75: 75,
    r80: 80,
    r90: 90,
  );

  @override
  SportoTournamentTokens copyWith({
    Color? screenBase,
    Color? screenHeader,
    Color? card,
    Color? cardAlt,
    Color? cardElevated,
    Color? panel,
    Color? border,
    Color? borderSoft,
    Color? white,
    Color? warm,
    Color? muted,
    Color? dim,
    Color? textSoft,
    Color? live,
    Color? liveSoft,
    Color? upcoming,
    Color? underReview,
    Color? changesRequested,
    Color? completed,
    Color? draft,
    Color? green,
    Color? greenBright,
    Color? gold,
    Color? goldBright,
    Color? blue,
    Color? blueBright,
    Color? pink,
    Color? pinkBright,
    Color? orange,
    Color? orangeStrong,
    Color? amber,
    Color? red,
    LinearGradient? liveCardGradient,
    LinearGradient? liveCardBorderGradient,
    LinearGradient? bluePillGradient,
    LinearGradient? goldPillGradient,
    LinearGradient? greenPillGradient,
    LinearGradient? orangePillGradient,
    LinearGradient? redPillGradient,
    LinearGradient? bracketPanelGradient,
    LinearGradient? financialPositiveGradient,
    LinearGradient? financialNegativeGradient,
    LinearGradient? cardFadeGradient,
    LinearGradient? headerGradient,
    List<BoxShadow>? liveGlow,
    List<BoxShadow>? greenGlow,
    List<BoxShadow>? goldGlow,
    List<BoxShadow>? blueGlow,
    List<BoxShadow>? pinkGlow,
    List<BoxShadow>? softCardShadow,
    List<BoxShadow>? strongCardShadow,
    List<BoxShadow>? innerWhiteStroke,
    double? r4_44,
    double? r5,
    double? r6,
    double? r9,
    double? r9_07,
    double? r10,
    double? r11,
    double? r14,
    double? r18,
    double? r44,
    double? r50,
    double? r75,
    double? r80,
    double? r90,
  }) {
    return SportoTournamentTokens(
      screenBase: screenBase ?? this.screenBase,
      screenHeader: screenHeader ?? this.screenHeader,
      card: card ?? this.card,
      cardAlt: cardAlt ?? this.cardAlt,
      cardElevated: cardElevated ?? this.cardElevated,
      panel: panel ?? this.panel,
      border: border ?? this.border,
      borderSoft: borderSoft ?? this.borderSoft,
      white: white ?? this.white,
      warm: warm ?? this.warm,
      muted: muted ?? this.muted,
      dim: dim ?? this.dim,
      textSoft: textSoft ?? this.textSoft,
      live: live ?? this.live,
      liveSoft: liveSoft ?? this.liveSoft,
      upcoming: upcoming ?? this.upcoming,
      underReview: underReview ?? this.underReview,
      changesRequested: changesRequested ?? this.changesRequested,
      completed: completed ?? this.completed,
      draft: draft ?? this.draft,
      green: green ?? this.green,
      greenBright: greenBright ?? this.greenBright,
      gold: gold ?? this.gold,
      goldBright: goldBright ?? this.goldBright,
      blue: blue ?? this.blue,
      blueBright: blueBright ?? this.blueBright,
      pink: pink ?? this.pink,
      pinkBright: pinkBright ?? this.pinkBright,
      orange: orange ?? this.orange,
      orangeStrong: orangeStrong ?? this.orangeStrong,
      amber: amber ?? this.amber,
      red: red ?? this.red,
      liveCardGradient: liveCardGradient ?? this.liveCardGradient,
      liveCardBorderGradient:
          liveCardBorderGradient ?? this.liveCardBorderGradient,
      bluePillGradient: bluePillGradient ?? this.bluePillGradient,
      goldPillGradient: goldPillGradient ?? this.goldPillGradient,
      greenPillGradient: greenPillGradient ?? this.greenPillGradient,
      orangePillGradient: orangePillGradient ?? this.orangePillGradient,
      redPillGradient: redPillGradient ?? this.redPillGradient,
      bracketPanelGradient: bracketPanelGradient ?? this.bracketPanelGradient,
      financialPositiveGradient:
          financialPositiveGradient ?? this.financialPositiveGradient,
      financialNegativeGradient:
          financialNegativeGradient ?? this.financialNegativeGradient,
      cardFadeGradient: cardFadeGradient ?? this.cardFadeGradient,
      headerGradient: headerGradient ?? this.headerGradient,
      liveGlow: liveGlow ?? this.liveGlow,
      greenGlow: greenGlow ?? this.greenGlow,
      goldGlow: goldGlow ?? this.goldGlow,
      blueGlow: blueGlow ?? this.blueGlow,
      pinkGlow: pinkGlow ?? this.pinkGlow,
      softCardShadow: softCardShadow ?? this.softCardShadow,
      strongCardShadow: strongCardShadow ?? this.strongCardShadow,
      innerWhiteStroke: innerWhiteStroke ?? this.innerWhiteStroke,
      r4_44: r4_44 ?? this.r4_44,
      r5: r5 ?? this.r5,
      r6: r6 ?? this.r6,
      r9: r9 ?? this.r9,
      r9_07: r9_07 ?? this.r9_07,
      r10: r10 ?? this.r10,
      r11: r11 ?? this.r11,
      r14: r14 ?? this.r14,
      r18: r18 ?? this.r18,
      r44: r44 ?? this.r44,
      r50: r50 ?? this.r50,
      r75: r75 ?? this.r75,
      r80: r80 ?? this.r80,
      r90: r90 ?? this.r90,
    );
  }

  @override
  SportoTournamentTokens lerp(
    covariant SportoTournamentTokens? other,
    double t,
  ) =>
      t < .5 ? this : (other ?? this);
}

extension SportoTournamentThemeX on BuildContext {
  SportoTournamentTokens get sportoTournament =>
      Theme.of(this).extension<SportoTournamentTokens>()!;
}
