import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ui_kit/ui_kit.dart';

import 'referee_request_widgets.dart';

// =============================================================================
// Shared header
// =============================================================================
class ScoringRedesignHeader extends StatelessWidget {
  final double scale;
  final String title;
  final VoidCallback? onBack;

  const ScoringRedesignHeader({
    super.key,
    required this.scale,
    required this.title,
    this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 44 * scale,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20 * scale),
        child: Row(
          children: [
            GestureDetector(
              onTap: onBack,
              child: Container(
                width: 36 * scale,
                height: 36 * scale,
                decoration: BoxDecoration(
                  color: const Color(0x1AFFFFFF),
                  borderRadius: BorderRadius.circular(10 * scale),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0x1F000000),
                      blurRadius: 4 * scale,
                      offset: Offset(0, 2 * scale),
                    ),
                  ],
                ),
                child: Center(
                  child: SportoSvgIcon(
                    SportoRefereeBookingIcons.back,
                    width: 6 * scale,
                    height: 12 * scale,
                  ),
                ),
              ),
            ),
            SizedBox(width: 10 * scale),
            Expanded(
              child: Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 16 * scale,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFFFFFFFF),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// =============================================================================
// Sport / code / source / status strip
// =============================================================================
class ScoringRedesignSportCard extends StatelessWidget {
  final double scale;
  final String sport;
  final String code;
  final String source;
  final String status;

  const ScoringRedesignSportCard({
    super.key,
    required this.scale,
    required this.sport,
    required this.code,
    this.source = 'by Partner',
    this.status = 'Ongoing',
  });

  @override
  Widget build(BuildContext context) {
    final isPartner = source == 'by Partner';
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: 14 * scale,
        vertical: 12 * scale,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16 * scale),
        gradient: LinearGradient(
          colors: isPartner
              ? const [Color(0x1AFF58DD), Color(0x1ADC65AC)]
              : const [Color(0x1A7AD3FF), Color(0x1A4FBAF0)],
        ),
      ),
      child: Row(
        children: [
          Flexible(
            child: Text(
              sport,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 14 * scale,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF2BB673),
              ),
            ),
          ),
          _dot(scale),
          Flexible(
            child: Text(
              code,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 14 * scale,
                fontWeight: FontWeight.w500,
                color: const Color(0xFF666666),
              ),
            ),
          ),
          const Spacer(),
          Flexible(
            child: _Pill(
              scale: scale,
              label: source,
              gradient: isPartner
                  ? const LinearGradient(
                      colors: [Color(0x1AFF58DD), Color(0x1ADC65AC)],
                    )
                  : const LinearGradient(
                      colors: [Color(0x1A7AD3FF), Color(0x1A4FBAF0)],
                    ),
              textGradient: isPartner
                  ? const LinearGradient(
                      colors: [Color(0xFFFF58DD), Color(0xFFDC65AC)],
                    )
                  : const LinearGradient(
                      colors: [Color(0xFF7AD3FF), Color(0xFF4FBAF0)],
                    ),
              vertical: 2,
            ),
          ),
          SizedBox(width: 8 * scale),
          Flexible(
            child: _Pill(
              scale: scale,
              label: status,
              gradient: const LinearGradient(
                colors: [Color(0x0F7AD3FF), Color(0x0F4FBAF0)],
              ),
              textGradient: const LinearGradient(
                colors: [Color(0xFF7AD3FF), Color(0xFF4FBAF0)],
              ),
              vertical: 4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _dot(double scale) => Padding(
        padding: EdgeInsets.symmetric(horizontal: 6 * scale),
        child: Container(
          width: 2 * scale,
          height: 2 * scale,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: Color(0xFFA0A0A0),
          ),
        ),
      );
}

class _Pill extends StatelessWidget {
  final double scale;
  final String label;
  final Gradient gradient;
  final Gradient textGradient;
  final double vertical;

  const _Pill({
    required this.scale,
    required this.label,
    required this.gradient,
    required this.textGradient,
    this.vertical = 2,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: 6 * scale,
        vertical: vertical * scale,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10 * scale),
        gradient: gradient,
      ),
      child: RefereeGradientText(
        label,
        gradient: textGradient,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          fontSize: 12 * scale,
          fontWeight: FontWeight.w500,
          height: 1.2,
        ),
      ),
    );
  }
}

// =============================================================================
// Match summary
// =============================================================================
class ScoringRedesignMatchSummary extends StatelessWidget {
  final double scale;
  final String stage;
  final bool showLiveNow;
  final String tournament;
  final String venue;
  final String leftTeam;
  final String leftRole;
  final String? leftScore;
  final String rightTeam;
  final String rightRole;
  final String? rightScore;
  final bool showScores;

  const ScoringRedesignMatchSummary({
    super.key,
    required this.scale,
    required this.stage,
    required this.tournament,
    required this.venue,
    required this.leftTeam,
    required this.leftRole,
    required this.rightTeam,
    required this.rightRole,
    this.showLiveNow = true,
    this.leftScore,
    this.rightScore,
    this.showScores = false,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(22 * scale),
      child: Stack(
        children: [
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: const Color(0xFF141A24),
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0x14FF5CBE),
                    Color(0x0A7BD0FA),
                    Color(0x14FF5CBE),
                  ],
                  stops: [0.0, 0.52, 1.0],
                ),
                border: Border.all(color: const Color(0x14F3EEE2), width: 0.5),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(14 * scale),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 6 * scale,
                          vertical: 2 * scale,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0x3301A34D),
                          borderRadius: BorderRadius.circular(10 * scale),
                          border: Border.all(color: const Color(0xFF2BB673)),
                        ),
                        child: Text(
                          stage,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 12 * scale,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFFFFFFFF),
                            height: 1.2,
                          ),
                        ),
                      ),
                    ),
                    if (showLiveNow) ...[
                      SizedBox(width: 6 * scale),
                      _livePill(scale),
                      SizedBox(width: 6 * scale),
                    ],
                  ],
                ),
                SizedBox(height: 10 * scale),
                RefereeGradientText(
                  tournament,
                  gradient: const LinearGradient(
                    colors: [Color(0xFFFFD572), Color(0xFFFEBD38)],
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 16 * scale,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 2 * scale),
                Row(
                  children: [
                    SportoAssetIcon(
                      SportoAssets.locationPin,
                      size: 16 * scale,
                      color: const Color(0xFFA0A0A0),
                    ),
                    SizedBox(width: 2 * scale),
                    Expanded(
                      child: Text(
                        venue,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 12 * scale,
                          fontWeight: FontWeight.w500,
                          color: const Color(0xFFA0A0A0),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 10 * scale),
                _DashedDivider(color: const Color(0x2EF3EEE2), scale: scale),
                SizedBox(height: 8 * scale),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: _teamColumn(
                        name: leftTeam,
                        role: leftRole,
                        score: leftScore,
                        roleGradient: false,
                        scoreColor: const Color(0xFFF4B41A),
                        alignEnd: false,
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8 * scale),
                      child: Text(
                        'Vs',
                        style: TextStyle(
                          fontSize: 12 * scale,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFFAAAAAA),
                        ),
                      ),
                    ),
                    Expanded(
                      child: _teamColumn(
                        name: rightTeam,
                        role: rightRole,
                        score: rightScore,
                        roleGradient: true,
                        scoreColor: const Color(0xFFA0A0A0),
                        alignEnd: true,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _livePill(double scale) {
    return Container(
      height: 19 * scale,
      padding: EdgeInsets.symmetric(horizontal: 4 * scale),
      decoration: BoxDecoration(
        color: const Color(0xCCFFFFFF),
        borderRadius: BorderRadius.circular(10 * scale),
        border: Border.all(color: const Color(0x4DFE595C), width: 0.5),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 12 * scale,
            height: 12 * scale,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [Color(0xFFFF4444), Color(0xFFFF1919)],
              ),
            ),
          ),
          SizedBox(width: 4 * scale),
          RefereeGradientText(
            'Live Now',
            gradient: const LinearGradient(
              colors: [Color(0xFFFE6C6C), Color(0xFFFE464B)],
            ),
            style: TextStyle(
              fontSize: 12 * scale,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _teamColumn({
    required String name,
    required String role,
    required String? score,
    required bool roleGradient,
    required Color scoreColor,
    required bool alignEnd,
  }) {
    return Column(
      crossAxisAlignment:
          alignEnd ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        Text(
          name,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          textAlign: alignEnd ? TextAlign.right : TextAlign.left,
          style: TextStyle(
            fontSize: 14 * scale,
            fontWeight: FontWeight.w500,
            color: const Color(0xFFFFFFFF),
          ),
        ),
        SizedBox(height: 2 * scale),
        roleGradient
            ? RefereeGradientText(
                role,
                gradient: const LinearGradient(
                  colors: [Color(0xFF7AD3FF), Color(0xFF4FBAF0)],
                ),
                style: TextStyle(
                  fontSize: 12 * scale,
                  fontWeight: FontWeight.w500,
                ),
              )
            : Text(
                role,
                style: TextStyle(
                  fontSize: 12 * scale,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF2BB673),
                ),
              ),
        if (showScores && score != null) ...[
          SizedBox(height: 2 * scale),
          scoreColor == const Color(0xFFF4B41A)
              ? RefereeGradientText(
                  score,
                  gradient: const LinearGradient(
                    colors: [Color(0xFFED7B00), Color(0xFFCF9E24)],
                  ),
                  style: TextStyle(
                    fontSize: 16 * scale,
                    fontWeight: FontWeight.w600,
                  ),
                )
              : Text(
                  score,
                  textAlign: alignEnd ? TextAlign.right : TextAlign.left,
                  style: TextStyle(
                    fontSize: 16 * scale,
                    fontWeight: FontWeight.w600,
                    color: scoreColor,
                  ),
                ),
        ],
      ],
    );
  }
}

// =============================================================================
// Live score card
// =============================================================================
enum ScoringRedesignBallStyle { empty, run, four, six, wicket }

class ScoringRedesignBall {
  final String? label;
  final ScoringRedesignBallStyle style;

  const ScoringRedesignBall(
      {this.label, this.style = ScoringRedesignBallStyle.empty});

  const ScoringRedesignBall.empty() : this();
  const ScoringRedesignBall.run(String value)
      : this(label: value, style: ScoringRedesignBallStyle.run);
}

class ScoringRedesignScoreCard extends StatelessWidget {
  final double scale;
  final String? title;
  final String score;
  final String overText;
  final String ballText;
  final bool showThisOver;
  final String bowlerName;
  final List<ScoringRedesignBall> balls;

  const ScoringRedesignScoreCard({
    super.key,
    required this.scale,
    required this.score,
    required this.overText,
    required this.ballText,
    this.title,
    this.showThisOver = false,
    this.bowlerName = '',
    this.balls = const [],
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(22 * scale),
      child: Stack(
        children: [
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF173824), Color(0xFF0E2418)],
                  stops: [0.0, 0.7],
                ),
                border: Border.all(color: const Color(0x14F3EEE2), width: 0.5),
              ),
            ),
          ),
          Positioned(
            top: -50 * scale,
            right: -40 * scale,
            width: 160 * scale,
            height: 160 * scale,
            child: DecoratedBox(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    const Color(0xFFF2B705).withValues(alpha: 0.18),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            bottom: -60 * scale,
            left: -40 * scale,
            width: 170 * scale,
            height: 170 * scale,
            child: DecoratedBox(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    const Color(0xFFE1263F).withValues(alpha: 0.32),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(14 * scale),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (title != null) ...[
                  RefereeGradientText(
                    title!,
                    gradient: const LinearGradient(
                      colors: [Color(0xFF7AD3FF), Color(0xFF4FBAF0)],
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 14 * scale,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: 4 * scale),
                ],
                Text(
                  'Runs / Wicket',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 12 * scale,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFFA0A0A0),
                  ),
                ),
                SizedBox(height: 6 * scale),
                RefereeGradientText(
                  score,
                  gradient: const LinearGradient(
                    colors: [Color(0xFFED7B00), Color(0xFFCF9E24)],
                  ),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 30 * scale,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: 6 * scale),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      overText,
                      style: TextStyle(
                        fontSize: 14 * scale,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFFF3EEE2),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 6 * scale),
                      child: Container(
                        width: 3 * scale,
                        height: 3 * scale,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Color(0xFFA0A0A0),
                        ),
                      ),
                    ),
                    Text(
                      ballText,
                      style: TextStyle(
                        fontSize: 14 * scale,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFFF3EEE2),
                      ),
                    ),
                  ],
                ),
                if (showThisOver) ...[
                  SizedBox(height: 10 * scale),
                  _DashedDivider(
                    color: const Color(0x2EF3EEE2),
                    scale: scale,
                  ),
                  SizedBox(height: 6 * scale),
                  Row(
                    children: [
                      Text(
                        'This Over - ',
                        style: TextStyle(
                          fontSize: 14 * scale,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFFAAAAAA),
                        ),
                      ),
                      Expanded(
                        child: Text(
                          bowlerName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 16 * scale,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFFFFFFFF),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 10 * scale),
                  Row(
                    children: List.generate(6, (index) {
                      final ball = index < balls.length
                          ? balls[index]
                          : const ScoringRedesignBall.empty();
                      return Padding(
                        padding: EdgeInsets.only(
                          right: index == 5 ? 0 : 10 * scale,
                        ),
                        child: _ballChip(ball),
                      );
                    }),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _ballChip(ScoringRedesignBall ball) {
    Gradient? gradient;
    Color fill = const Color(0xFF283040);
    Color textColor = const Color(0xFFFFFFFF);
    switch (ball.style) {
      case ScoringRedesignBallStyle.four:
        gradient = const LinearGradient(
          colors: [Color(0xFF7AD3FF), Color(0xFF4FBAF0)],
        );
        textColor = const Color(0xFF1B2335);
        break;
      case ScoringRedesignBallStyle.six:
        gradient = const LinearGradient(
          colors: [Color(0xFFFD95D3), Color(0xFFFF5CBE)],
        );
        textColor = const Color(0xFF1B2335);
        break;
      case ScoringRedesignBallStyle.wicket:
        gradient = const LinearGradient(
          colors: [Color(0xFFFE6C6C), Color(0xFFFE464B)],
        );
        break;
      case ScoringRedesignBallStyle.empty:
      case ScoringRedesignBallStyle.run:
        break;
    }
    return Container(
      width: 30 * scale,
      height: 30 * scale,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: gradient == null ? fill : null,
        gradient: gradient,
        border: ball.style == ScoringRedesignBallStyle.run
            ? Border.all(color: const Color(0x4D7BD0FA), width: 0.5)
            : null,
      ),
      child: Text(
        ball.label ?? '',
        style: TextStyle(
          fontSize: 16 * scale,
          fontWeight: FontWeight.w700,
          color: textColor,
        ),
      ),
    );
  }
}

// =============================================================================
// Bowler selector
// =============================================================================
class ScoringRedesignBowlerOption {
  final String id;
  final String name;
  final bool selected;
  final bool enabled;

  const ScoringRedesignBowlerOption({
    required this.id,
    required this.name,
    this.selected = false,
    this.enabled = true,
  });
}

class ScoringRedesignBowlerList extends StatelessWidget {
  final double scale;
  final String title;
  final List<ScoringRedesignBowlerOption> options;
  final ValueChanged<String> onSelected;
  final String? actionLabel;
  final bool actionEnabled;
  final VoidCallback? onAction;

  const ScoringRedesignBowlerList({
    super.key,
    required this.scale,
    required this.title,
    required this.options,
    required this.onSelected,
    this.actionLabel,
    this.actionEnabled = true,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RefereeGradientText(
          title,
          gradient: const LinearGradient(
            colors: [Color(0xFF99FFA3), Color(0xFF68EE76)],
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: 16 * scale,
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(height: 14 * scale),
        for (var i = 0; i < options.length; i++) ...[
          if (i > 0) SizedBox(height: 8 * scale),
          _row(options[i]),
        ],
        if (actionLabel != null) ...[
          SizedBox(height: 20 * scale),
          ScoringRedesignPrimaryButton(
            scale: scale,
            label: actionLabel!,
            onTap: actionEnabled ? onAction : null,
          ),
        ],
      ],
    );
  }

  Widget _row(ScoringRedesignBowlerOption option) {
    final selected = option.selected;
    return GestureDetector(
      onTap: option.enabled ? () => onSelected(option.id) : null,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(
          horizontal: 14 * scale,
          vertical: 10 * scale,
        ),
        decoration: BoxDecoration(
          color: const Color(0x991B2335),
          borderRadius: BorderRadius.circular(12 * scale),
          border: selected
              ? Border.all(color: const Color(0x332BB673), width: 1)
              : null,
        ),
        child: Row(
          children: [
            Container(
              width: 16 * scale,
              height: 16 * scale,
              decoration: BoxDecoration(
                color: selected ? const Color(0xFF2BB673) : Colors.transparent,
                borderRadius: BorderRadius.circular(4 * scale),
                border: selected
                    ? null
                    : Border.all(color: const Color(0xFF666666), width: 1),
              ),
              child: selected
                  ? Icon(
                      Icons.check_rounded,
                      size: 11 * scale,
                      color: const Color(0xFFFFFFFF),
                    )
                  : null,
            ),
            SizedBox(width: 8 * scale),
            Expanded(
              child: Text(
                option.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 14 * scale,
                  fontWeight: FontWeight.w500,
                  color: selected
                      ? const Color(0xFFA0A0A0)
                      : const Color(0xFF666666),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// =============================================================================
// Scoring pad
// =============================================================================
class ScoringRedesignRunPad extends StatelessWidget {
  final double scale;
  final String bowlerName;
  final List<int> runValues;
  final ValueChanged<int> onRun;
  final VoidCallback onWicket;
  final VoidCallback onWide;
  final VoidCallback onNoBall;
  final bool showExtraNote;

  const ScoringRedesignRunPad({
    super.key,
    required this.scale,
    required this.bowlerName,
    required this.runValues,
    required this.onRun,
    required this.onWicket,
    required this.onWide,
    required this.onNoBall,
    this.showExtraNote = true,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RefereeGradientText(
          'This Over — $bowlerName',
          gradient: const LinearGradient(
            colors: [Color(0xFFED7B00), Color(0xFFCF9E24)],
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: 16 * scale,
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: 14 * scale),
        Row(
          children: [
            for (var i = 0; i < runValues.length; i++) ...[
              if (i > 0) SizedBox(width: 16 * scale),
              Expanded(
                child: _button(
                  height: 45,
                  label: '${runValues[i]}',
                  textColor: const Color(0xFFFFFFFF),
                  fontWeight: FontWeight.w600,
                  fill: const Color(0x991B2335),
                  border: true,
                  onTap: () => onRun(runValues[i]),
                ),
              ),
            ],
          ],
        ),
        SizedBox(height: 20 * scale),
        Row(
          children: [
            Expanded(
              child: _button(
                height: 45,
                label: 'WKT',
                textColor: const Color(0xFFFFFFFF),
                fontWeight: FontWeight.w700,
                gradient: const LinearGradient(
                  colors: [Color(0xFFFE6C6C), Color(0xFFFE464B)],
                ),
                onTap: onWicket,
              ),
            ),
            SizedBox(width: 16 * scale),
            Expanded(
              child: _button(
                height: 45,
                label: 'Wide',
                textColor: const Color(0xFFED7B00),
                textGradient: const LinearGradient(
                  colors: [Color(0xFFED7B00), Color(0xFFCF9E24)],
                ),
                fontWeight: FontWeight.w600,
                fill: const Color(0x991B2335),
                border: true,
                onTap: onWide,
              ),
            ),
            SizedBox(width: 16 * scale),
            Expanded(
              child: _button(
                height: 45,
                label: 'No Ball',
                textColor: const Color(0xFFED7B00),
                textGradient: const LinearGradient(
                  colors: [Color(0xFFED7B00), Color(0xFFCF9E24)],
                ),
                fontWeight: FontWeight.w600,
                fill: const Color(0x991B2335),
                border: true,
                onTap: onNoBall,
              ),
            ),
          ],
        ),
        if (showExtraNote) ...[
          SizedBox(height: 24 * scale),
          Container(height: 0.8 * scale, color: const Color(0xFF283040)),
          SizedBox(height: 10 * scale),
          Center(
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: 8 * scale,
                vertical: 4 * scale,
              ),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8 * scale),
                gradient: const LinearGradient(
                  colors: [Color(0x0FFFD572), Color(0x0FFEBD38)],
                ),
                border: Border.all(color: const Color(0x08FFC641)),
              ),
              child: RefereeGradientText(
                '*One Wide in Ove Doesn’t Count. Re-bowled It',
                gradient: const LinearGradient(
                  colors: [Color(0xFFFFD572), Color(0xFFFEBD38)],
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 12 * scale,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _button({
    required double height,
    required String label,
    required Color textColor,
    required FontWeight fontWeight,
    Gradient? gradient,
    Gradient? textGradient,
    Color? fill,
    bool border = false,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: height * scale,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: gradient == null ? fill : null,
          gradient: gradient,
          borderRadius: BorderRadius.circular(12 * scale),
          border: border
              ? Border.all(color: const Color(0x4D7BD0FA), width: 0.8)
              : null,
        ),
        child: textGradient != null
            ? RefereeGradientText(
                label,
                gradient: textGradient,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 20 * scale,
                  fontWeight: fontWeight,
                ),
              )
            : Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 20 * scale,
                  fontWeight: fontWeight,
                  color: textColor,
                ),
              ),
      ),
    );
  }
}

// =============================================================================
// Notice / winner / innings summary
// =============================================================================
class ScoringRedesignNoticePill extends StatelessWidget {
  final double scale;
  final String text;
  final bool checked;

  const ScoringRedesignNoticePill({
    super.key,
    required this.scale,
    required this.text,
    this.checked = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: 14 * scale,
        vertical: 14 * scale,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12 * scale),
        gradient: const LinearGradient(
          colors: [Color(0x1A99FFA3), Color(0x1A68EE76)],
        ),
        border: Border.all(color: const Color(0x332BB673), width: 0.5),
      ),
      child: Row(
        children: [
          Container(
            width: 16 * scale,
            height: 16 * scale,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: checked ? const Color(0xFF2BB673) : Colors.transparent,
              border:
                  checked ? null : Border.all(color: const Color(0xFF666666)),
            ),
            child: checked
                ? Icon(
                    Icons.check_rounded,
                    size: 11 * scale,
                    color: const Color(0xFFFFFFFF),
                  )
                : null,
          ),
          SizedBox(width: 8 * scale),
          Expanded(
            child: Text(
              text,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 14 * scale,
                fontWeight: FontWeight.w500,
                color: const Color(0xFFA0A0A0),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ScoringRedesignWinnerCard extends StatelessWidget {
  final double scale;
  final String winner;

  const ScoringRedesignWinnerCard({
    super.key,
    required this.scale,
    required this.winner,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 62 * scale,
      padding: EdgeInsets.all(10 * scale),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22 * scale),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF173824), Color(0xFF0E2418)],
          stops: [0.0, 0.7],
        ),
        border: Border.all(color: const Color(0x14F3EEE2), width: 0.5),
      ),
      child: Row(
        children: [
          Container(
            width: 40 * scale,
            height: 40 * scale,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(
                colors: [Color(0x1AED7B00), Color(0x1ACF9E24)],
              ),
              border: Border.all(color: const Color(0x33F4B41A)),
            ),
            child: Center(
              child: Icon(
                Icons.emoji_events_rounded,
                size: 22 * scale,
                color: const Color(0xFFF4B41A),
              ),
            ),
          ),
          SizedBox(width: 10 * scale),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                RefereeGradientText(
                  'Winner',
                  gradient: const LinearGradient(
                    colors: [Color(0xFF7AD3FF), Color(0xFF4FBAF0)],
                  ),
                  style: TextStyle(
                    fontSize: 14 * scale,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                RefereeGradientText(
                  winner,
                  gradient: const LinearGradient(
                    colors: [Color(0xFFED7B00), Color(0xFFCF9E24)],
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 16 * scale,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class ScoringRedesignInningsCompletedCard extends StatelessWidget {
  final double scale;
  final String leftTeam;
  final String leftRole;
  final String leftScore;
  final String rightTeam;
  final String rightRole;
  final String rightScore;

  const ScoringRedesignInningsCompletedCard({
    super.key,
    required this.scale,
    required this.leftTeam,
    required this.leftRole,
    required this.leftScore,
    required this.rightTeam,
    required this.rightRole,
    required this.rightScore,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(14 * scale),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12 * scale),
        gradient: const LinearGradient(
          colors: [Color(0x1A99FFA3), Color(0x1A68EE76)],
        ),
        border: Border.all(color: const Color(0x332BB673), width: 0.5),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 16 * scale,
                height: 16 * scale,
                decoration: const BoxDecoration(
                  color: Color(0xFF2BB673),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.check_rounded,
                  size: 11 * scale,
                  color: const Color(0xFFFFFFFF),
                ),
              ),
              SizedBox(width: 8 * scale),
              Text(
                'Innings Completed',
                style: TextStyle(
                  fontSize: 14 * scale,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFFA0A0A0),
                ),
              ),
            ],
          ),
          SizedBox(height: 10 * scale),
          _DashedDivider(color: const Color(0x2EF3EEE2), scale: scale),
          SizedBox(height: 10 * scale),
          Row(
            children: [
              Expanded(
                child: _col(leftTeam, leftRole, leftScore, false),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 8 * scale),
                child: Text(
                  'Vs',
                  style: TextStyle(
                    fontSize: 12 * scale,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFFAAAAAA),
                  ),
                ),
              ),
              Expanded(
                child: _col(rightTeam, rightRole, rightScore, true),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _col(String team, String role, String score, bool end) {
    return Column(
      crossAxisAlignment:
          end ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        Text(
          team,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          textAlign: end ? TextAlign.right : TextAlign.left,
          style: TextStyle(
            fontSize: 14 * scale,
            fontWeight: FontWeight.w500,
            color: const Color(0xFFFFFFFF),
          ),
        ),
        SizedBox(height: 2 * scale),
        end
            ? RefereeGradientText(
                role,
                gradient: const LinearGradient(
                  colors: [Color(0xFF7AD3FF), Color(0xFF4FBAF0)],
                ),
                style: TextStyle(
                  fontSize: 12 * scale,
                  fontWeight: FontWeight.w500,
                ),
              )
            : Text(
                role,
                style: TextStyle(
                  fontSize: 12 * scale,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF2BB673),
                ),
              ),
        SizedBox(height: 2 * scale),
        end
            ? Text(
                score,
                style: TextStyle(
                  fontSize: 16 * scale,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFFA0A0A0),
                ),
              )
            : RefereeGradientText(
                score,
                gradient: const LinearGradient(
                  colors: [Color(0xFFED7B00), Color(0xFFCF9E24)],
                ),
                style: TextStyle(
                  fontSize: 16 * scale,
                  fontWeight: FontWeight.w600,
                ),
              ),
      ],
    );
  }
}

// =============================================================================
// End-match OTP
// =============================================================================
class ScoringRedesignEndOtpCard extends StatelessWidget {
  final double scale;
  final TextEditingController controller;
  final FocusNode focusNode;
  final VoidCallback onChanged;
  final VoidCallback onSubmitted;
  final String sessionStartedText;

  const ScoringRedesignEndOtpCard({
    super.key,
    required this.scale,
    required this.controller,
    required this.focusNode,
    required this.onChanged,
    required this.onSubmitted,
    this.sessionStartedText = '',
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(
        16 * scale,
        20 * scale,
        16 * scale,
        16 * scale,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20 * scale),
        color: const Color(0x0DFE464B),
        border: Border.all(color: const Color(0x80FE464B), width: 0.8),
        boxShadow: [
          BoxShadow(
            color: const Color(0x33FE464B),
            blurRadius: 10 * scale,
            offset: Offset(1 * scale, 4 * scale),
          ),
        ],
      ),
      child: Column(
        children: [
          RefereeGradientText(
            'End Match?',
            gradient: const LinearGradient(
              colors: [Color(0xFFFE6C6C), Color(0xFFFE464B)],
            ),
            style: TextStyle(
              fontSize: 18 * scale,
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(height: 10 * scale),
          Text(
            'Share this OTP with your referee to End the Match.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12 * scale,
              fontWeight: FontWeight.w500,
              color: const Color(0xFFA0A0A0),
              height: 1.3,
            ),
          ),
          if (sessionStartedText.isNotEmpty) ...[
            SizedBox(height: 8 * scale),
            Text(
              sessionStartedText,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12 * scale,
                fontWeight: FontWeight.w500,
                color: const Color(0xFFA0A0A0),
              ),
            ),
          ],
          SizedBox(height: 16 * scale),
          RefereeGradientText(
            'Enter 6-digit match OTP',
            gradient: const LinearGradient(
              colors: [Color(0xFF7AD3FF), Color(0xFF4FBAF0)],
            ),
            style: TextStyle(
              fontSize: 14 * scale,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 10 * scale),
          _OtpBoxes(
            scale: scale,
            controller: controller,
            focusNode: focusNode,
            onChanged: onChanged,
            onSubmitted: onSubmitted,
          ),
        ],
      ),
    );
  }
}

class _OtpBoxes extends StatelessWidget {
  final double scale;
  final TextEditingController controller;
  final FocusNode focusNode;
  final VoidCallback onChanged;
  final VoidCallback onSubmitted;

  const _OtpBoxes({
    required this.scale,
    required this.controller,
    required this.focusNode,
    required this.onChanged,
    required this.onSubmitted,
  });

  @override
  Widget build(BuildContext context) {
    final text = controller.text;
    final activeIndex = text.isEmpty ? 0 : (text.length - 1).clamp(0, 5);
    return SizedBox(
      height: 46 * scale,
      child: Stack(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(6, (index) {
              final active = index == activeIndex;
              final hasDigit = index < text.length;
              return Container(
                width: 44 * scale,
                height: 46 * scale,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14 * scale),
                  color: active ? null : const Color(0xFF1C2026),
                  gradient: active
                      ? const LinearGradient(
                          colors: [Color(0x0F7AD3FF), Color(0x0F4FBAF0)],
                        )
                      : null,
                  border: Border.all(
                    color: active
                        ? const Color(0xFF7AD3FF)
                        : const Color(0x80666666),
                    width: 0.8,
                  ),
                ),
                child: Text(
                  hasDigit ? text[index] : '|',
                  style: TextStyle(
                    fontSize: 16 * scale,
                    fontWeight: FontWeight.w700,
                    color: hasDigit
                        ? const Color(0xFFFFFFFF)
                        : const Color(0xFFA0A0A0),
                  ),
                ),
              );
            }),
          ),
          Positioned.fill(
            child: TextField(
              controller: controller,
              focusNode: focusNode,
              autofocus: false,
              showCursor: false,
              enableInteractiveSelection: false,
              keyboardType: TextInputType.number,
              textInputAction: TextInputAction.done,
              maxLength: 6,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(6),
              ],
              style: const TextStyle(
                color: Colors.transparent,
                fontSize: 1,
                height: 1,
              ),
              cursorColor: Colors.transparent,
              decoration: const InputDecoration(
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                counterText: '',
                contentPadding: EdgeInsets.zero,
                isCollapsed: true,
              ),
              onChanged: (_) => onChanged(),
              onSubmitted: (_) => onSubmitted(),
            ),
          ),
        ],
      ),
    );
  }
}

class ScoringRedesignHelpCard extends StatelessWidget {
  final double scale;

  const ScoringRedesignHelpCard({super.key, required this.scale});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(10 * scale),
      decoration: BoxDecoration(
        color: const Color(0x6612161C),
        borderRadius: BorderRadius.circular(14 * scale),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.info_outline_rounded,
            size: 18 * scale,
            color: const Color(0xFF2BB673),
          ),
          SizedBox(width: 8 * scale),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Haven't received the OTP?",
                  style: TextStyle(
                    fontSize: 14 * scale,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFFFFFFFF),
                  ),
                ),
                SizedBox(height: 4 * scale),
                Text(
                  'Ask the user or partner who booked you to open their '
                  'booking and show you the match OTP.',
                  style: TextStyle(
                    fontSize: 12 * scale,
                    fontWeight: FontWeight.w400,
                    color: const Color(0xFFA0A0A0),
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// =============================================================================
// Primary button
// =============================================================================
class ScoringRedesignPrimaryButton extends StatelessWidget {
  final double scale;
  final String label;
  final VoidCallback? onTap;
  final Gradient? gradient;
  final Color textColor;
  final double? width;

  const ScoringRedesignPrimaryButton({
    super.key,
    required this.scale,
    required this.label,
    required this.onTap,
    this.gradient,
    this.textColor = const Color(0xFFFFFFFF),
    this.width,
  });

  @override
  Widget build(BuildContext context) {
    final resolvedGradient = gradient ??
        const LinearGradient(
          colors: [Color(0xFFED7B00), Color(0xFFCF9E24)],
        );
    return Center(
      child: Container(
        width: width ?? 270 * scale,
        height: 48 * scale,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16 * scale),
          gradient: resolvedGradient,
          boxShadow: [
            BoxShadow(
              color: const Color(0x59ED7B00),
              blurRadius: 30 * scale,
              offset: Offset(2 * scale, 10 * scale),
            ),
            BoxShadow(
              color: const Color(0x1A000000),
              blurRadius: 8 * scale,
              offset: Offset(0, 2 * scale),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(16 * scale),
            child: Center(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 16 * scale,
                  fontWeight: FontWeight.w700,
                  color: textColor,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// =============================================================================
// Result submitted
// =============================================================================
class ScoringRedesignResultSubmitted extends StatelessWidget {
  final double scale;
  final String sport;
  final String code;
  final String source;
  final String stage;
  final String tournament;
  final String venue;
  final String leftTeam;
  final String leftScore;
  final String rightTeam;
  final String rightScore;
  final String winner;
  final VoidCallback onViewHistory;

  const ScoringRedesignResultSubmitted({
    super.key,
    required this.scale,
    required this.sport,
    required this.code,
    required this.source,
    required this.stage,
    required this.tournament,
    required this.venue,
    required this.leftTeam,
    required this.leftScore,
    required this.rightTeam,
    required this.rightScore,
    required this.winner,
    required this.onViewHistory,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          width: double.infinity,
          padding: EdgeInsets.fromLTRB(
            20 * scale,
            40 * scale,
            20 * scale,
            30 * scale,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(30 * scale),
            color: const Color(0xCC1C2026),
            border: Border.all(color: const Color(0x332BB673), width: 0.8),
          ),
          child: Column(
            children: [
              Container(
                width: 120 * scale,
                height: 120 * scale,
                decoration: BoxDecoration(
                  color: const Color(0x1FE5F4D9),
                  borderRadius: BorderRadius.circular(40 * scale),
                ),
                child: Center(
                  child: Container(
                    width: 76 * scale,
                    height: 76 * scale,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Color(0xFFBFF0A8),
                          Color(0xFF84DC6F),
                          Color(0xFF16B704),
                          Color(0xFF13B601),
                        ],
                        stops: [0.14, 0.28, 0.53, 1.0],
                      ),
                    ),
                    child: Center(
                      child: SportoSvgIcon(
                        SportoRefereeBookingIcons.check,
                        size: 34 * scale,
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 40 * scale),
              Text(
                'RESULT SUBMITTED',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 20 * scale,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFFFFFFFF),
                ),
              ),
              SizedBox(height: 12 * scale),
              Text(
                'Bracket, stats, and leaderboards have been updated.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14 * scale,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFFA0A0A0),
                  height: 1.3,
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 20 * scale),
        ScoringRedesignSportCard(
          scale: scale,
          sport: sport,
          code: code,
          source: source,
          status: 'Completed',
        ),
        SizedBox(height: 20 * scale),
        ScoringRedesignMatchSummary(
          scale: scale,
          stage: stage,
          showLiveNow: false,
          tournament: tournament,
          venue: venue,
          leftTeam: leftTeam,
          leftRole: 'Batting',
          leftScore: leftScore,
          rightTeam: rightTeam,
          rightRole: 'Bowling',
          rightScore: rightScore,
          showScores: true,
        ),
        SizedBox(height: 20 * scale),
        ScoringRedesignWinnerCard(scale: scale, winner: winner),
        SizedBox(height: 20 * scale),
        ScoringRedesignPrimaryButton(
          scale: scale,
          label: 'View Match History',
          gradient: const LinearGradient(
            colors: [Color(0xFF7AD3FF), Color(0xFF4FBAF0)],
          ),
          textColor: const Color(0xFF1B2335),
          onTap: onViewHistory,
        ),
      ],
    );
  }
}

// =============================================================================
// Dashed divider
// =============================================================================
class _DashedDivider extends StatelessWidget {
  final Color color;
  final double scale;

  const _DashedDivider({required this.color, required this.scale});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 1,
      child: CustomPaint(painter: _DashedPainter(color)),
    );
  }
}

class _DashedPainter extends CustomPainter {
  final Color color;

  const _DashedPainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1;
    for (double x = 0; x < size.width; x += 6) {
      canvas.drawLine(
        Offset(x, 0),
        Offset((x + 2).clamp(0, size.width).toDouble(), 0),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _DashedPainter oldDelegate) =>
      oldDelegate.color != color;
}

// =============================================================================
// Final result -> End match OTP -> submitted
// =============================================================================
class ScoringRedesignFinalFlow extends StatefulWidget {
  final double scale;
  final String sport;
  final String code;
  final String source;
  final String stage;
  final String tournament;
  final String venue;
  final String leftTeam;
  final String rightTeam;
  final String leftScore;
  final String rightScore;
  final String winner;
  final String scoreOverText;
  final String scoreBallText;
  final String sessionStartedText;
  final String? expectedOtp;
  final Future<void> Function() onComplete;
  final ValueChanged<String> onHeaderTitle;

  const ScoringRedesignFinalFlow({
    super.key,
    required this.scale,
    required this.sport,
    required this.code,
    required this.stage,
    required this.tournament,
    required this.venue,
    required this.leftTeam,
    required this.rightTeam,
    required this.leftScore,
    required this.rightScore,
    required this.winner,
    required this.scoreOverText,
    required this.scoreBallText,
    required this.sessionStartedText,
    required this.expectedOtp,
    required this.onComplete,
    required this.onHeaderTitle,
    this.source = 'by Partner',
  });

  @override
  State<ScoringRedesignFinalFlow> createState() =>
      _ScoringRedesignFinalFlowState();
}

enum _FinalFlowStage { summary, result, otp }

class _ScoringRedesignFinalFlowState extends State<ScoringRedesignFinalFlow> {
  _FinalFlowStage _stage = _FinalFlowStage.summary;
  final TextEditingController _otpController = TextEditingController();
  final FocusNode _otpFocus = FocusNode();
  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) widget.onHeaderTitle('Cricket Score Entry');
    });
  }

  @override
  void dispose() {
    _otpController.dispose();
    _otpFocus.dispose();
    super.dispose();
  }

  void _snack(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _verify() async {
    final code = _otpController.text.trim();
    if (code.length != 6) {
      _snack('Enter the 6-digit match OTP.');
      _otpFocus.requestFocus();
      return;
    }
    final expected = widget.expectedOtp;
    if (expected != null && expected.isNotEmpty && expected != code) {
      _snack('Incorrect OTP. Please check with the booking user.');
      _otpController.clear();
      setState(() {});
      _otpFocus.requestFocus();
      return;
    }
    setState(() => _submitting = true);
    await widget.onComplete();
    if (mounted) setState(() => _submitting = false);
  }

  void _showHelp() {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1C2026),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: const Text(
          'Having trouble?',
          style: TextStyle(
            color: Color(0xFFFFFFFF),
            fontWeight: FontWeight.w700,
          ),
        ),
        content: const Text(
          'Ask the user or partner who booked you to open their booking and '
          'show you the 6-digit match OTP.',
          style: TextStyle(color: Color(0xFFA0A0A0), height: 1.4),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Got it'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final scale = widget.scale;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ScoringRedesignSportCard(
          scale: scale,
          sport: widget.sport,
          code: widget.code,
          source: widget.source,
          status: 'Ongoing',
        ),
        SizedBox(height: 20 * scale),
        ScoringRedesignMatchSummary(
          scale: scale,
          stage: widget.stage,
          tournament: widget.tournament,
          venue: widget.venue,
          leftTeam: widget.leftTeam,
          leftRole: 'Batting',
          leftScore: widget.leftScore,
          rightTeam: widget.rightTeam,
          rightRole: 'Bowling',
          rightScore: widget.rightScore,
          showScores: true,
        ),
        if (_stage == _FinalFlowStage.summary) ...[
          SizedBox(height: 20 * scale),
          ScoringRedesignScoreCard(
            scale: scale,
            title: widget.leftTeam,
            score: widget.leftScore,
            overText: widget.scoreOverText,
            ballText: widget.scoreBallText,
          ),
          SizedBox(height: 20 * scale),
          ScoringRedesignInningsCompletedCard(
            scale: scale,
            leftTeam: widget.leftTeam,
            leftRole: 'Batting',
            leftScore: widget.leftScore,
            rightTeam: widget.rightTeam,
            rightRole: 'Bowling',
            rightScore: widget.rightScore,
          ),
          SizedBox(height: 20 * scale),
          ScoringRedesignPrimaryButton(
            scale: scale,
            label: 'Proceed to Submit Result',
            onTap: () {
              setState(() => _stage = _FinalFlowStage.result);
              widget.onHeaderTitle('Final Result');
            },
          ),
        ] else ...[
          SizedBox(height: 20 * scale),
          ScoringRedesignWinnerCard(scale: scale, winner: widget.winner),
          if (_stage == _FinalFlowStage.result) ...[
            SizedBox(height: 20 * scale),
            ScoringRedesignPrimaryButton(
              scale: scale,
              label: 'Submit Final Result',
              onTap: () {
                setState(() => _stage = _FinalFlowStage.otp);
                widget.onHeaderTitle('Final Result');
              },
            ),
          ] else ...[
            SizedBox(height: 20 * scale),
            ScoringRedesignEndOtpCard(
              scale: scale,
              controller: _otpController,
              focusNode: _otpFocus,
              onChanged: () => setState(() {}),
              onSubmitted: _verify,
              sessionStartedText: widget.sessionStartedText,
            ),
            SizedBox(height: 20 * scale),
            ScoringRedesignHelpCard(scale: scale),
            SizedBox(height: 20 * scale),
            ScoringRedesignPrimaryButton(
              scale: scale,
              label: _submitting ? 'Verifying…' : 'Verify OTP & End Match',
              onTap: _submitting ? null : _verify,
              width: 330 * scale,
              gradient: const LinearGradient(
                colors: [Color(0xFFFE6C6C), Color(0xFFFE464B)],
              ),
              textColor: const Color(0xFFFFFFFF),
            ),
            SizedBox(height: 20 * scale),
            Center(
              child: GestureDetector(
                onTap: _showHelp,
                behavior: HitTestBehavior.opaque,
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: 12 * scale,
                    vertical: 6 * scale,
                  ),
                  child: Text(
                    'Having trouble?',
                    style: TextStyle(
                      fontSize: 14 * scale,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFFA0A0A0),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ],
      ],
    );
  }
}
