import 'package:flutter/material.dart';

/// Semantic SPORTO values that are not represented by Material's ColorScheme.
/// Screens access these through `Theme.of(context).sporto`.
///
/// Values are aligned to the Figma "User App" palette (agent: global token
/// update, decision 3). `ColorScheme.primary` stays orange for CTAs;
/// `accentGreen` is the brand accent for status/selected/links.
@immutable
class SportoDesignTokens extends ThemeExtension<SportoDesignTokens> {
  final Color canvas;
  final Color card;
  final Color cardElevated;
  final Color section;
  final Color panel;
  final Color iconTile;
  final Color field;
  final Color fieldBorder;
  final Color fieldBorderFocused;
  final Color authFieldBorder;
  final Color border;
  final Color hairlineWarm;
  final Color muted;
  final Color textTertiary;
  final Color live;
  final Color upcoming;
  final Color assigned;
  final Color info;
  final Color liveCardStart;
  final Color liveCardEnd;
  final Color authBadge;
  final Color accentGreen;
  final Color accentGreenSoft;
  final Color avatarGreen;
  final Color statusGreen;
  final Color successArt;
  final Color gold;
  final Color goldSoft;
  final Color red;
  final Color redSoft;
  final Color shimmerBase;
  final Color shimmerHighlight;
  final LinearGradient primaryGradient;
  final LinearGradient ambientGradient;
  final LinearGradient authPanelGradient;
  final LinearGradient authBackgroundGradient;
  final LinearGradient gradientBlue;
  final LinearGradient gradientGold;
  final LinearGradient gradientPink;
  final LinearGradient gradientOrange;
  final LinearGradient gradientRed;
  final Color actionOrange;
  final Color navSurface;
  final Color whiteOverlay10;

  const SportoDesignTokens({
    required this.canvas,
    required this.card,
    required this.cardElevated,
    required this.section,
    required this.panel,
    required this.iconTile,
    required this.field,
    required this.fieldBorder,
    required this.fieldBorderFocused,
    required this.authFieldBorder,
    required this.border,
    required this.hairlineWarm,
    required this.muted,
    required this.textTertiary,
    required this.live,
    required this.upcoming,
    required this.assigned,
    required this.info,
    required this.liveCardStart,
    required this.liveCardEnd,
    required this.authBadge,
    required this.accentGreen,
    required this.accentGreenSoft,
    required this.avatarGreen,
    required this.statusGreen,
    required this.successArt,
    required this.gold,
    required this.goldSoft,
    required this.red,
    required this.redSoft,
    required this.shimmerBase,
    required this.shimmerHighlight,
    required this.primaryGradient,
    required this.ambientGradient,
    required this.authPanelGradient,
    required this.authBackgroundGradient,
    required this.gradientBlue,
    required this.gradientGold,
    required this.gradientPink,
    required this.gradientOrange,
    required this.gradientRed,
    required this.actionOrange,
    required this.navSurface,
    required this.whiteOverlay10,
  });

  static const dark = SportoDesignTokens(
    canvas: Color(0xFF090C10),

    card: Color(0xFF17191E),

    cardElevated: Color(0xFF1C2026),

    section: Color(0xFF12161C),

    panel: Color(0xFF1B2335),

    iconTile: Color(0xFF313135),

    field: Color(0xFF1A1F24),

    fieldBorder: Color(0xFF35424E),

    fieldBorderFocused: Color(0xFF4FBAF0),

    authFieldBorder: Color(0xFF31516B),

    border: Color(0xFF283040),

    hairlineWarm: Color(0xFFF3EEE2),

    muted: Color(0xFFA0A0A0),

    textTertiary: Color(0xFF666666),

    // Screenshot states
    live: Color(0xFFFF4B50),

    upcoming: Color(0xFFFF6C4A),

    assigned: Color(0xFF3ED48E),

    info: Color(0xFF54C2F3),

    // Live card
    liveCardStart: Color(0xFF3A0E07),

    liveCardEnd: Color(0xFF28100C),

    authBadge: Color(0xE6261808),

    // Brand accent (status / selected / links)
    accentGreen: Color(0xFF2BB673),

    accentGreenSoft: Color(0x1A28A166),

    avatarGreen: Color(0xFF28A166),

    statusGreen: Color(0xFF00D816),

    successArt: Color(0xFFE5F4D9),

    gold: Color(0xFFF4B41A),

    goldSoft: Color(0x33F4B41A),

    red: Color(0xFFFE464B),

    redSoft: Color(0x0FE1263F),

    shimmerBase: Color(0x14F4F4F5),

    shimmerHighlight: Color(0x38F4F4F5),

    // Buttons
    actionOrange: Color(0xFFFF4B00),

    // Bottom navigation
    navSurface: Color(0xFF1D1C19),

    whiteOverlay10: Color(0x1AFFFFFF),

    primaryGradient: LinearGradient(
      colors: [
        Color(0xFFED7B00),
        Color(0xFFCF9E24),
      ],
    ),

    ambientGradient: LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        Color(0x1A7BD0FA),
        Color(0x00090C10),
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

    gradientBlue: LinearGradient(
      colors: [
        Color(0xFF7AD3FF),
        Color(0xFF4FBAF0),
      ],
    ),

    gradientGold: LinearGradient(
      colors: [
        Color(0xFFFFD572),
        Color(0xFFFEBD38),
      ],
    ),

    gradientPink: LinearGradient(
      colors: [
        Color(0xFFFF58DD),
        Color(0xFFDC65AC),
      ],
    ),

    gradientOrange: LinearGradient(
      colors: [
        Color(0xFFFF9364),
        Color(0xFFF25F33),
      ],
    ),

    gradientRed: LinearGradient(
      colors: [
        Color(0xFFFE6C6C),
        Color(0xFFFE464B),
      ],
    ),
  );

  @override
  SportoDesignTokens copyWith({
    Color? canvas,
    Color? card,
    Color? cardElevated,
    Color? section,
    Color? panel,
    Color? iconTile,
    Color? field,
    Color? fieldBorder,
    Color? fieldBorderFocused,
    Color? authFieldBorder,
    Color? border,
    Color? hairlineWarm,
    Color? muted,
    Color? textTertiary,
    Color? live,
    Color? upcoming,
    Color? assigned,
    Color? info,
    Color? liveCardStart,
    Color? liveCardEnd,
    Color? authBadge,
    Color? accentGreen,
    Color? accentGreenSoft,
    Color? avatarGreen,
    Color? statusGreen,
    Color? successArt,
    Color? gold,
    Color? goldSoft,
    Color? red,
    Color? redSoft,
    Color? shimmerBase,
    Color? shimmerHighlight,
    LinearGradient? primaryGradient,
    LinearGradient? ambientGradient,
    LinearGradient? authPanelGradient,
    LinearGradient? authBackgroundGradient,
    LinearGradient? gradientBlue,
    LinearGradient? gradientGold,
    LinearGradient? gradientPink,
    LinearGradient? gradientOrange,
    LinearGradient? gradientRed,
    Color? actionOrange,
    Color? navSurface,
    Color? whiteOverlay10,
  }) =>
      SportoDesignTokens(
        canvas: canvas ?? this.canvas,
        card: card ?? this.card,
        cardElevated: cardElevated ?? this.cardElevated,
        section: section ?? this.section,
        panel: panel ?? this.panel,
        iconTile: iconTile ?? this.iconTile,
        field: field ?? this.field,
        fieldBorder: fieldBorder ?? this.fieldBorder,
        fieldBorderFocused: fieldBorderFocused ?? this.fieldBorderFocused,
        authFieldBorder: authFieldBorder ?? this.authFieldBorder,
        border: border ?? this.border,
        hairlineWarm: hairlineWarm ?? this.hairlineWarm,
        muted: muted ?? this.muted,
        textTertiary: textTertiary ?? this.textTertiary,
        live: live ?? this.live,
        upcoming: upcoming ?? this.upcoming,
        assigned: assigned ?? this.assigned,
        info: info ?? this.info,
        liveCardStart: liveCardStart ?? this.liveCardStart,
        liveCardEnd: liveCardEnd ?? this.liveCardEnd,
        authBadge: authBadge ?? this.authBadge,
        accentGreen: accentGreen ?? this.accentGreen,
        accentGreenSoft: accentGreenSoft ?? this.accentGreenSoft,
        avatarGreen: avatarGreen ?? this.avatarGreen,
        statusGreen: statusGreen ?? this.statusGreen,
        successArt: successArt ?? this.successArt,
        gold: gold ?? this.gold,
        goldSoft: goldSoft ?? this.goldSoft,
        red: red ?? this.red,
        redSoft: redSoft ?? this.redSoft,
        shimmerBase: shimmerBase ?? this.shimmerBase,
        shimmerHighlight: shimmerHighlight ?? this.shimmerHighlight,
        primaryGradient: primaryGradient ?? this.primaryGradient,
        ambientGradient: ambientGradient ?? this.ambientGradient,
        authPanelGradient: authPanelGradient ?? this.authPanelGradient,
        authBackgroundGradient:
            authBackgroundGradient ?? this.authBackgroundGradient,
        gradientBlue: gradientBlue ?? this.gradientBlue,
        gradientGold: gradientGold ?? this.gradientGold,
        gradientPink: gradientPink ?? this.gradientPink,
        gradientOrange: gradientOrange ?? this.gradientOrange,
        gradientRed: gradientRed ?? this.gradientRed,
        actionOrange: actionOrange ?? this.actionOrange,
        navSurface: navSurface ?? this.navSurface,
        whiteOverlay10: whiteOverlay10 ?? this.whiteOverlay10,
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
  /// Geometry stays close to the design; app-wide text is lifted separately.
  double get sportoScale {
    final width = MediaQuery.sizeOf(this).width;
    if (width < 360) {
      return (width / 360).clamp(0.92, 1.0);
    }
    return (width / 390).clamp(1.0, 1.16);
  }

  double sportoSize(double figmaValue) => figmaValue * sportoScale;
}

/// Sweep direction for skeleton shimmer.
enum ShimmerDirection { leftToRight, rightToLeft, topToBottom, bottomToTop }

/// Repeated Figma measurements. Unique screen measurements stay local.
@immutable
class SportoLayoutTokens extends ThemeExtension<SportoLayoutTokens> {
  final double space2;
  final double space4;
  final double space6;
  final double space8;
  final double space10;
  final double space12;
  final double space14;
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
  final double radius30;
  final double radiusFull;

  /// Backdrop blur used on glass cards (Figma `BACKGROUND_BLUR 20`).
  final double glassBlur;

  /// Backdrop blur used on the sticky header (Figma `BACKGROUND_BLUR 100`).
  final double headerBlur;

  final List<BoxShadow> cardShadow;
  final List<BoxShadow> btnShadow;
  final List<BoxShadow> ctaGlow;
  final Duration shimmerDuration;
  final Curve shimmerCurve;
  final ShimmerDirection shimmerDirection;

  const SportoLayoutTokens({
    required this.space2,
    required this.space4,
    required this.space6,
    required this.space8,
    required this.space10,
    required this.space12,
    required this.space14,
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
    required this.radius30,
    required this.radiusFull,
    required this.glassBlur,
    required this.headerBlur,
    required this.cardShadow,
    required this.btnShadow,
    required this.ctaGlow,
    required this.shimmerDuration,
    required this.shimmerCurve,
    required this.shimmerDirection,
  });

  static const figma = SportoLayoutTokens(
    space2: 2,
    space4: 4,
    space6: 6,
    space8: 8,
    space10: 10,
    space12: 12,
    space14: 14,
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
    radius30: 30,
    radiusFull: 999,
    glassBlur: 20,
    headerBlur: 100,
    cardShadow: [
      BoxShadow(color: Color(0x1A000000), blurRadius: 8, offset: Offset(0, 2)),
    ],
    btnShadow: [
      BoxShadow(color: Color(0x33000000), blurRadius: 2, offset: Offset(0, 1)),
      BoxShadow(color: Color(0x1F000000), blurRadius: 4, offset: Offset(0, 2)),
    ],
    ctaGlow: [
      BoxShadow(
        color: Color(0x59ED7B00),
        blurRadius: 30,
        offset: Offset(2, 10),
      ),
    ],
    shimmerDuration: Duration(milliseconds: 1000),
    shimmerCurve: Curves.easeInOut,
    shimmerDirection: ShimmerDirection.leftToRight,
  );

  @override
  SportoLayoutTokens copyWith({
    double? space2,
    double? space4,
    double? space6,
    double? space8,
    double? space10,
    double? space12,
    double? space14,
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
    double? radius30,
    double? radiusFull,
    double? glassBlur,
    double? headerBlur,
    List<BoxShadow>? cardShadow,
    List<BoxShadow>? btnShadow,
    List<BoxShadow>? ctaGlow,
    Duration? shimmerDuration,
    Curve? shimmerCurve,
    ShimmerDirection? shimmerDirection,
  }) =>
      SportoLayoutTokens(
        space2: space2 ?? this.space2,
        space4: space4 ?? this.space4,
        space6: space6 ?? this.space6,
        space8: space8 ?? this.space8,
        space10: space10 ?? this.space10,
        space12: space12 ?? this.space12,
        space14: space14 ?? this.space14,
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
        radius30: radius30 ?? this.radius30,
        radiusFull: radiusFull ?? this.radiusFull,
        glassBlur: glassBlur ?? this.glassBlur,
        headerBlur: headerBlur ?? this.headerBlur,
        cardShadow: cardShadow ?? this.cardShadow,
        btnShadow: btnShadow ?? this.btnShadow,
        ctaGlow: ctaGlow ?? this.ctaGlow,
        shimmerDuration: shimmerDuration ?? this.shimmerDuration,
        shimmerCurve: shimmerCurve ?? this.shimmerCurve,
        shimmerDirection: shimmerDirection ?? this.shimmerDirection,
      );

  @override
  SportoLayoutTokens lerp(covariant SportoLayoutTokens other, double t) =>
      t < .5 ? this : other;
}
