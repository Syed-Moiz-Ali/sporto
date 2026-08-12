import 'package:flutter/material.dart';

/// Semantic SPORTO values that are not represented by Material's ColorScheme.
/// Screens access these through `Theme.of(context).sporto`.
@immutable
class SportoDesignTokens extends ThemeExtension<SportoDesignTokens> {
  final Color canvas;
  final Color card;
  final Color cardElevated;
  final Color field;
  final Color fieldBorder;
  final Color fieldBorderFocused;
  final Color authFieldBorder;
  final Color border;
  final Color muted;
  final Color live;
  final Color upcoming;
  final Color assigned;
  final Color info;
  final Color liveCardStart;
  final Color liveCardEnd;
  final Color authBadge;
  final LinearGradient primaryGradient;
  final LinearGradient ambientGradient;
  final LinearGradient authPanelGradient;
  final LinearGradient authBackgroundGradient;
  final Color actionOrange;
  final Color navSurface;

  const SportoDesignTokens({
    required this.canvas,
    required this.card,
    required this.cardElevated,
    required this.field,
    required this.fieldBorder,
    required this.fieldBorderFocused,
    required this.authFieldBorder,
    required this.border,
    required this.muted,
    required this.live,
    required this.upcoming,
    required this.assigned,
    required this.info,
    required this.liveCardStart,
    required this.liveCardEnd,
    required this.authBadge,
    required this.primaryGradient,
    required this.ambientGradient,
    required this.authPanelGradient,
    required this.authBackgroundGradient,
    required this.actionOrange,
    required this.navSurface,
  });

  static const dark = SportoDesignTokens(
    canvas: Color(0xFF0E0C08),

    card: Color(0xFF171717),

    cardElevated: Color(0xFF1C2026),

    field: Color(0xFF1C2026),

    fieldBorder: Color(0xFF35424E),

    fieldBorderFocused: Color(0xFF4FBAF0),

    authFieldBorder: Color(0xFF31516B),

    border: Color(0xFF283040),

    muted: Color(0xFF92949A),

    // Screenshot states
    live: Color(0xFFFF4B50),

    upcoming: Color(0xFFFF6C4A),

    assigned: Color(0xFF3ED48E),

    info: Color(0xFF54C2F3),

    // Live card
    liveCardStart: Color(0xFF3A0E07),

    liveCardEnd: Color(0xFF28100C),

    authBadge: Color(0xE6261808),

    // Buttons
    actionOrange: Color(0xFFFF4B00),

    // Bottom navigation
    navSurface: Color(0xFF1D1C19),

    primaryGradient: LinearGradient(
      colors: [
        Color(0xFFFF4B00),
        Color(0xFFCF9E24),
      ],
    ),

    ambientGradient: LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        Color(0x1A7BD0FA),
        Color(0x000E0C08),
        Color(0x145B213F),
      ],
    ),

    authPanelGradient: LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        Color(0xFF151B22),
        Color(0xFF101316),
        Color(0xFF171318),
      ],
    ),

    authBackgroundGradient: LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        Color(0xFF171719),
        Color(0xFF24191E),
        Color(0xFF111A1A),
      ],
    ),
  );

  @override
  SportoDesignTokens copyWith({
    Color? canvas,
    Color? card,
    Color? cardElevated,
    Color? field,
    Color? fieldBorder,
    Color? fieldBorderFocused,
    Color? authFieldBorder,
    Color? border,
    Color? muted,
    Color? live,
    Color? upcoming,
    Color? assigned,
    Color? info,
    Color? liveCardStart,
    Color? liveCardEnd,
    Color? authBadge,
    LinearGradient? primaryGradient,
    LinearGradient? ambientGradient,
    LinearGradient? authPanelGradient,
    LinearGradient? authBackgroundGradient,
    Color? actionOrange,
    Color? navSurface,
  }) =>
      SportoDesignTokens(
        canvas: canvas ?? this.canvas,
        card: card ?? this.card,
        cardElevated: cardElevated ?? this.cardElevated,
        field: field ?? this.field,
        fieldBorder: fieldBorder ?? this.fieldBorder,
        fieldBorderFocused: fieldBorderFocused ?? this.fieldBorderFocused,
        authFieldBorder: authFieldBorder ?? this.authFieldBorder,
        border: border ?? this.border,
        muted: muted ?? this.muted,
        live: live ?? this.live,
        upcoming: upcoming ?? this.upcoming,
        assigned: assigned ?? this.assigned,
        info: info ?? this.info,
        liveCardStart: liveCardStart ?? this.liveCardStart,
        liveCardEnd: liveCardEnd ?? this.liveCardEnd,
        authBadge: authBadge ?? this.authBadge,
        primaryGradient: primaryGradient ?? this.primaryGradient,
        ambientGradient: ambientGradient ?? this.ambientGradient,
        authPanelGradient: authPanelGradient ?? this.authPanelGradient,
        authBackgroundGradient:
            authBackgroundGradient ?? this.authBackgroundGradient,
        actionOrange: actionOrange ?? this.actionOrange,
        navSurface: navSurface ?? this.navSurface,
      );

  @override
  SportoDesignTokens lerp(covariant SportoDesignTokens other, double t) =>
      t < .5 ? this : other;
}

extension SportoThemeContext on BuildContext {
  SportoDesignTokens get sporto =>
      Theme.of(this).extension<SportoDesignTokens>()!;

  SportoLayoutTokens get sportoLayout =>
      Theme.of(this).extension<SportoLayoutTokens>()!;

  /// Bounded multiplier based on the 390 px Figma mobile canvas.
  double get sportoScale =>
      (MediaQuery.sizeOf(this).width / 390).clamp(0.92, 1.16);

  double sportoSize(double figmaValue) => figmaValue * sportoScale;
}

/// Repeated Figma measurements. Unique screen measurements stay local.
@immutable
class SportoLayoutTokens extends ThemeExtension<SportoLayoutTokens> {
  final double space2;
  final double space4;
  final double space6;
  final double space8;
  final double space10;
  final double space12;
  final double space16;
  final double space20;
  final double space24;
  final double space30;
  final double radius4;
  final double radius8;
  final double radius10;
  final double radius12;
  final double radius14;
  final double radius16;
  final double radius18;
  final double radius20;
  final List<BoxShadow> cardShadow;

  const SportoLayoutTokens({
    required this.space2,
    required this.space4,
    required this.space6,
    required this.space8,
    required this.space10,
    required this.space12,
    required this.space16,
    required this.space20,
    required this.space24,
    required this.space30,
    required this.radius4,
    required this.radius8,
    required this.radius10,
    required this.radius12,
    required this.radius14,
    required this.radius16,
    required this.radius18,
    required this.radius20,
    required this.cardShadow,
  });

  static const figma = SportoLayoutTokens(
    space2: 2,
    space4: 4,
    space6: 6,
    space8: 8,
    space10: 10,
    space12: 12,
    space16: 16,
    space20: 20,
    space24: 24,
    space30: 30,
    radius4: 4,
    radius8: 8,
    radius10: 10,
    radius12: 12,
    radius14: 14,
    radius16: 16,
    radius18: 18,
    radius20: 20,
    cardShadow: [
      BoxShadow(color: Color(0x1A000000), blurRadius: 8, offset: Offset(0, 2)),
    ],
  );

  @override
  SportoLayoutTokens copyWith({
    double? space2,
    double? space4,
    double? space6,
    double? space8,
    double? space10,
    double? space12,
    double? space16,
    double? space20,
    double? space24,
    double? space30,
    double? radius4,
    double? radius8,
    double? radius10,
    double? radius12,
    double? radius14,
    double? radius16,
    double? radius18,
    double? radius20,
    List<BoxShadow>? cardShadow,
  }) =>
      SportoLayoutTokens(
        space2: space2 ?? this.space2,
        space4: space4 ?? this.space4,
        space6: space6 ?? this.space6,
        space8: space8 ?? this.space8,
        space10: space10 ?? this.space10,
        space12: space12 ?? this.space12,
        space16: space16 ?? this.space16,
        space20: space20 ?? this.space20,
        space24: space24 ?? this.space24,
        space30: space30 ?? this.space30,
        radius4: radius4 ?? this.radius4,
        radius8: radius8 ?? this.radius8,
        radius10: radius10 ?? this.radius10,
        radius12: radius12 ?? this.radius12,
        radius14: radius14 ?? this.radius14,
        radius16: radius16 ?? this.radius16,
        radius18: radius18 ?? this.radius18,
        radius20: radius20 ?? this.radius20,
        cardShadow: cardShadow ?? this.cardShadow,
      );

  @override
  SportoLayoutTokens lerp(covariant SportoLayoutTokens other, double t) =>
      t < .5 ? this : other;
}
