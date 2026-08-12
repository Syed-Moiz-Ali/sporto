import 'package:flutter/material.dart';

@immutable
class SportoCricketScoringTheme
    extends ThemeExtension<SportoCricketScoringTheme> {
  final Color backgroundTop;
  final Color backgroundMiddle;
  final Color backgroundBottom;

  final Color matchStart;
  final Color matchMiddle;
  final Color matchEnd;

  final Color scoreStart;
  final Color scoreMiddle;
  final Color scoreEnd;

  final Color inputSurface;
  final Color inputBorder;

  final Color inningsSurface;
  final Color inningsBorder;

  final Color tieStart;
  final Color tieEnd;
  final Color tieBorder;

  final Color orange;
  final Color green;
  final Color blue;
  final Color red;

  final Color ballBlue;
  final Color ballNeutral;
  final Color ballSix;

  final Color winnerStart;
  final Color winnerMiddle;
  final Color winnerEnd;

  const SportoCricketScoringTheme({
    required this.backgroundTop,
    required this.backgroundMiddle,
    required this.backgroundBottom,
    required this.matchStart,
    required this.matchMiddle,
    required this.matchEnd,
    required this.scoreStart,
    required this.scoreMiddle,
    required this.scoreEnd,
    required this.inputSurface,
    required this.inputBorder,
    required this.inningsSurface,
    required this.inningsBorder,
    required this.tieStart,
    required this.tieEnd,
    required this.tieBorder,
    required this.orange,
    required this.green,
    required this.blue,
    required this.red,
    required this.ballBlue,
    required this.ballNeutral,
    required this.ballSix,
    required this.winnerStart,
    required this.winnerMiddle,
    required this.winnerEnd,
  });

  static const dark = SportoCricketScoringTheme(
    backgroundTop: Color(0xFF131924),
    backgroundMiddle: Color(0xFF10141E),
    backgroundBottom: Color(0xFF0E0C08),

    // Match card from screenshot.
    matchStart: Color(0xFF19222D),
    matchMiddle: Color(0xFF2A2028),
    matchEnd: Color(0xFF1A2024),

    // Score card from screenshot.
    scoreStart: Color(0xFF56332C),
    scoreMiddle: Color(0xFF073D2A),
    scoreEnd: Color(0xFF46530D),

    inputSurface: Color(0xFF161A24),
    inputBorder: Color(0xFF29405E),

    inningsSurface: Color(0xFF15281B),
    inningsBorder: Color(0xFF245538),

    tieStart: Color(0xFF241B12),
    tieEnd: Color(0xFF252319),
    tieBorder: Color(0xFF6B5310),

    orange: Color(0xFFFF9800),
    green: Color(0xFF36D58B),
    blue: Color(0xFF53C4F2),
    red: Color(0xFFFF5257),

    ballBlue: Color(0xFF53C4F2),
    ballNeutral: Color(0xFF29314A),
    ballSix: Color(0xFFFF68B8),

    winnerStart: Color(0xFF4A2924),
    winnerMiddle: Color(0xFF063A27),
    winnerEnd: Color(0xFF39460A),
  );

  @override
  SportoCricketScoringTheme copyWith({
    Color? backgroundTop,
    Color? backgroundMiddle,
    Color? backgroundBottom,
    Color? matchStart,
    Color? matchMiddle,
    Color? matchEnd,
    Color? scoreStart,
    Color? scoreMiddle,
    Color? scoreEnd,
    Color? inputSurface,
    Color? inputBorder,
    Color? inningsSurface,
    Color? inningsBorder,
    Color? tieStart,
    Color? tieEnd,
    Color? tieBorder,
    Color? orange,
    Color? green,
    Color? blue,
    Color? red,
    Color? ballBlue,
    Color? ballNeutral,
    Color? ballSix,
    Color? winnerStart,
    Color? winnerMiddle,
    Color? winnerEnd,
  }) {
    return SportoCricketScoringTheme(
      backgroundTop: backgroundTop ?? this.backgroundTop,
      backgroundMiddle: backgroundMiddle ?? this.backgroundMiddle,
      backgroundBottom: backgroundBottom ?? this.backgroundBottom,
      matchStart: matchStart ?? this.matchStart,
      matchMiddle: matchMiddle ?? this.matchMiddle,
      matchEnd: matchEnd ?? this.matchEnd,
      scoreStart: scoreStart ?? this.scoreStart,
      scoreMiddle: scoreMiddle ?? this.scoreMiddle,
      scoreEnd: scoreEnd ?? this.scoreEnd,
      inputSurface: inputSurface ?? this.inputSurface,
      inputBorder: inputBorder ?? this.inputBorder,
      inningsSurface: inningsSurface ?? this.inningsSurface,
      inningsBorder: inningsBorder ?? this.inningsBorder,
      tieStart: tieStart ?? this.tieStart,
      tieEnd: tieEnd ?? this.tieEnd,
      tieBorder: tieBorder ?? this.tieBorder,
      orange: orange ?? this.orange,
      green: green ?? this.green,
      blue: blue ?? this.blue,
      red: red ?? this.red,
      ballBlue: ballBlue ?? this.ballBlue,
      ballNeutral: ballNeutral ?? this.ballNeutral,
      ballSix: ballSix ?? this.ballSix,
      winnerStart: winnerStart ?? this.winnerStart,
      winnerMiddle: winnerMiddle ?? this.winnerMiddle,
      winnerEnd: winnerEnd ?? this.winnerEnd,
    );
  }

  @override
  SportoCricketScoringTheme lerp(
    covariant SportoCricketScoringTheme other,
    double t,
  ) {
    return t < .5 ? this : other;
  }
}

extension SportoCricketScoringThemeX on BuildContext {
  SportoCricketScoringTheme get cricketScoring =>
      Theme.of(this).extension<SportoCricketScoringTheme>()!;
}
