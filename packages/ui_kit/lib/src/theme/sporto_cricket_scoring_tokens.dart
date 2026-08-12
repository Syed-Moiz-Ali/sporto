// import 'package:flutter/material.dart';

// @immutable
// class SportoCricketScoringTokens
//     extends ThemeExtension<SportoCricketScoringTokens> {
//   final Color matchHeaderStart;
//   final Color matchHeaderEnd;

//   final Color scoreStart;
//   final Color scoreMiddle;
//   final Color scoreEnd;

//   final Color inningsSurface;

//   final Color tieBreakerStart;
//   final Color tieBreakerEnd;

//   final Color actionSurface;
//   final Color actionBorder;

//   final Color scoreAccent;

//   final Color ballBlue;
//   final Color ballNeutral;
//   final Color ballSix;

//   final Color liveBadgeSurface;

//   final Color winnerStart;
//   final Color winnerMiddle;
//   final Color winnerEnd;

//   const SportoCricketScoringTokens({
//     required this.matchHeaderStart,
//     required this.matchHeaderEnd,
//     required this.scoreStart,
//     required this.scoreMiddle,
//     required this.scoreEnd,
//     required this.inningsSurface,
//     required this.tieBreakerStart,
//     required this.tieBreakerEnd,
//     required this.actionSurface,
//     required this.actionBorder,
//     required this.scoreAccent,
//     required this.ballBlue,
//     required this.ballNeutral,
//     required this.ballSix,
//     required this.liveBadgeSurface,
//     required this.winnerStart,
//     required this.winnerMiddle,
//     required this.winnerEnd,
//   });

//   static const dark = SportoCricketScoringTokens(
//     matchHeaderStart: Color(0xFF2A2028),
//     matchHeaderEnd: Color(0xFF1A2024),
//     scoreStart: Color(0xFF56332C),
//     scoreMiddle: Color(0xFF063D2B),
//     scoreEnd: Color(0xFF46530D),
//     inningsSurface: Color(0xFF15281B),
//     tieBreakerStart: Color(0xFF241B12),
//     tieBreakerEnd: Color(0xFF252319),
//     actionSurface: Color(0xFF151A25),
//     actionBorder: Color(0xFF29405E),
//     scoreAccent: Color(0xFFFF9800),
//     ballBlue: Color(0xFF53C4F2),
//     ballNeutral: Color(0xFF29314A),
//     ballSix: Color(0xFFFF68B8),
//     liveBadgeSurface: Color(0xFFF5EEE9),
//     winnerStart: Color(0xFF4A2924),
//     winnerMiddle: Color(0xFF063A27),
//     winnerEnd: Color(0xFF39460A),
//   );

//   LinearGradient get matchHeaderGradient => LinearGradient(
//         begin: Alignment.topLeft,
//         end: Alignment.bottomRight,
//         colors: [
//           matchHeaderStart,
//           matchHeaderEnd,
//         ],
//       );

//   LinearGradient get scoreGradient => LinearGradient(
//         begin: Alignment.centerLeft,
//         end: Alignment.centerRight,
//         colors: [
//           scoreStart,
//           scoreMiddle,
//           scoreEnd,
//         ],
//       );

//   LinearGradient get tieBreakerGradient => LinearGradient(
//         begin: Alignment.centerLeft,
//         end: Alignment.centerRight,
//         colors: [
//           tieBreakerStart,
//           tieBreakerEnd,
//         ],
//       );

//   LinearGradient get winnerGradient => LinearGradient(
//         begin: Alignment.centerLeft,
//         end: Alignment.centerRight,
//         colors: [
//           winnerStart,
//           winnerMiddle,
//           winnerEnd,
//         ],
//       );

//   @override
//   SportoCricketScoringTokens copyWith({
//     Color? matchHeaderStart,
//     Color? matchHeaderEnd,
//     Color? scoreStart,
//     Color? scoreMiddle,
//     Color? scoreEnd,
//     Color? inningsSurface,
//     Color? tieBreakerStart,
//     Color? tieBreakerEnd,
//     Color? actionSurface,
//     Color? actionBorder,
//     Color? scoreAccent,
//     Color? ballBlue,
//     Color? ballNeutral,
//     Color? ballSix,
//     Color? liveBadgeSurface,
//     Color? winnerStart,
//     Color? winnerMiddle,
//     Color? winnerEnd,
//   }) {
//     return SportoCricketScoringTokens(
//       matchHeaderStart: matchHeaderStart ?? this.matchHeaderStart,
//       matchHeaderEnd: matchHeaderEnd ?? this.matchHeaderEnd,
//       scoreStart: scoreStart ?? this.scoreStart,
//       scoreMiddle: scoreMiddle ?? this.scoreMiddle,
//       scoreEnd: scoreEnd ?? this.scoreEnd,
//       inningsSurface: inningsSurface ?? this.inningsSurface,
//       tieBreakerStart: tieBreakerStart ?? this.tieBreakerStart,
//       tieBreakerEnd: tieBreakerEnd ?? this.tieBreakerEnd,
//       actionSurface: actionSurface ?? this.actionSurface,
//       actionBorder: actionBorder ?? this.actionBorder,
//       scoreAccent: scoreAccent ?? this.scoreAccent,
//       ballBlue: ballBlue ?? this.ballBlue,
//       ballNeutral: ballNeutral ?? this.ballNeutral,
//       ballSix: ballSix ?? this.ballSix,
//       liveBadgeSurface: liveBadgeSurface ?? this.liveBadgeSurface,
//       winnerStart: winnerStart ?? this.winnerStart,
//       winnerMiddle: winnerMiddle ?? this.winnerMiddle,
//       winnerEnd: winnerEnd ?? this.winnerEnd,
//     );
//   }

//   @override
//   SportoCricketScoringTokens lerp(
//     covariant SportoCricketScoringTokens other,
//     double t,
//   ) {
//     return t < .5 ? this : other;
//   }
// }

// extension SportoCricketScoringContext on BuildContext {
//   SportoCricketScoringTokens get sportoScoring =>
//       Theme.of(this).extension<SportoCricketScoringTokens>()!;
// }
