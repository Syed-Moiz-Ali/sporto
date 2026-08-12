import 'package:flutter/material.dart';

import '../theme/sporto_design_tokens.dart';
import '../theme/sporto_scoring_tokens.dart';
import 'primary_button.dart';
import 'sporto_badge.dart';
import 'sporto_check_box.dart';

// ============================================================
// ROOT SCORING SHELL
// ============================================================

class SportoLiveScoringShell extends StatelessWidget {
  final Widget child;

  const SportoLiveScoringShell({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: SportoScoringTokens.backgroundBottom,
      body: SizedBox(
        height: double.infinity,
        child: Stack(
          children: [
            const Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    stops: [
                      0,
                      .11,
                      .17,
                      .82,
                      1,
                    ],
                    colors: [
                      SportoScoringTokens.backgroundTop,
                      SportoScoringTokens.backgroundMiddle,
                      SportoScoringTokens.backgroundBottom,
                      SportoScoringTokens.backgroundBottom,
                      Color(0xFF171718),
                    ],
                  ),
                ),
              ),
            ),
            child,
          ],
        ),
      ),
    );
  }
}

// ============================================================
// PAGE HEADER
// ============================================================

class SportoLiveScoringHeader extends StatelessWidget {
  final String title;
  final String matchId;
  final VoidCallback? onBack;

  const SportoLiveScoringHeader({
    super.key,
    required this.title,
    required this.matchId,
    this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    final scale = context.sportoScale;
    final theme = Theme.of(context);

    return SizedBox(
      height: 36 * scale,
      child: Row(
        children: [
          Material(
            color: const Color(0xFF293141),
            borderRadius: BorderRadius.circular(
              11 * scale,
            ),
            child: InkWell(
              onTap: onBack,
              borderRadius: BorderRadius.circular(
                11 * scale,
              ),
              child: SizedBox(
                width: 36 * scale,
                height: 36 * scale,
                child: Icon(
                  Icons.chevron_left_rounded,
                  size: 27 * scale,
                ),
              ),
            ),
          ),
          SizedBox(width: 10 * scale),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontSize: 18 * scale,
                    height: 1,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: 4 * scale),
                Text(
                  'Match #$matchId',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface,
                    fontSize: 11 * scale,
                    height: 1,
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

// ============================================================
// LIVE BADGE
// ============================================================

class SportoLiveBadge extends StatelessWidget {
  const SportoLiveBadge({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final scale = context.sportoScale;

    return Container(
      height: 20 * scale,
      padding: EdgeInsets.symmetric(
        horizontal: 6 * scale,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFFF4ECE7),
        borderRadius: BorderRadius.circular(
          8 * scale,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8 * scale,
            height: 8 * scale,
            decoration: const BoxDecoration(
              color: SportoScoringTokens.red,
              shape: BoxShape.circle,
            ),
          ),
          SizedBox(width: 4 * scale),
          Text(
            'Live Now',
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: SportoScoringTokens.red,
                  fontSize: 11 * scale,
                  fontWeight: FontWeight.w700,
                ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// DASHED DIVIDER
// ============================================================

class SportoScoringDashedDivider extends StatelessWidget {
  final Color? color;

  const SportoScoringDashedDivider({
    super.key,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 1,
      child: CustomPaint(
        painter: _DashedPainter(
          color ?? Theme.of(context).colorScheme.outline.withValues(alpha: .7),
        ),
      ),
    );
  }
}

class _DashedPainter extends CustomPainter {
  final Color color;

  const _DashedPainter(
    this.color,
  );

  @override
  void paint(
    Canvas canvas,
    Size size,
  ) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1;

    for (double x = 0; x < size.width; x += 6) {
      canvas.drawLine(
        Offset(x, 0),
        Offset(
          (x + 2).clamp(0, size.width).toDouble(),
          0,
        ),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(
    covariant _DashedPainter oldDelegate,
  ) =>
      oldDelegate.color != color;
}

// ============================================================
// MATCH HEADER CARD
// ============================================================

class SportoLiveMatchCard extends StatelessWidget {
  final String tournament;
  final String location;

  final String battingTeam;
  final String bowlingTeam;

  final String? battingScore;
  final String? bowlingScore;

  final bool compact;
  final bool showScores;

  const SportoLiveMatchCard({
    super.key,
    this.tournament = 'Asia Cup 2026',
    this.location = 'Hyderabad',
    required this.battingTeam,
    required this.bowlingTeam,
    this.battingScore,
    this.bowlingScore,
    this.compact = false,
    this.showScores = false,
  });

  @override
  Widget build(BuildContext context) {
    final scale = context.sportoScale;
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    final height = compact
        ? 95.0
        : showScores
            ? 176.0
            : 154.0;

    return Container(
      width: double.infinity,
      height: height * scale,
      padding: EdgeInsets.fromLTRB(
        14 * scale,
        13 * scale,
        14 * scale,
        13 * scale,
      ),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            SportoScoringTokens.matchStart,
            SportoScoringTokens.matchMiddle,
            SportoScoringTokens.matchEnd,
          ],
        ),
        borderRadius: BorderRadius.circular(
          20 * scale,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              SportoBadge(
                text: 'Quarter Final',
                color: SportoScoringTokens.green,
                outlined: true,
              ),
              SizedBox(width: 6 * scale),
              const SportoLiveBadge(),
            ],
          ),
          SizedBox(height: 9 * scale),
          Text(
            tournament,
            style: theme.textTheme.titleLarge?.copyWith(
              color: SportoScoringTokens.orange,
              fontSize: 15 * scale,
              height: 1,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 5 * scale),
          Row(
            children: [
              Icon(
                Icons.location_on_outlined,
                size: 14 * scale,
                color: colors.onSurfaceVariant,
              ),
              SizedBox(width: 3 * scale),
              Text(
                location,
                style: theme.textTheme.bodySmall?.copyWith(
                  fontSize: 11 * scale,
                ),
              ),
            ],
          ),
          if (!compact) ...[
            SizedBox(height: 11 * scale),
            const SportoScoringDashedDivider(),
            SizedBox(height: 11 * scale),
            _SportoTeamRow(
              battingTeam: battingTeam,
              bowlingTeam: bowlingTeam,
              battingScore: showScores ? battingScore : null,
              bowlingScore: showScores ? bowlingScore : null,
            ),
          ],
        ],
      ),
    );
  }
}

class _SportoTeamRow extends StatelessWidget {
  final String battingTeam;
  final String bowlingTeam;

  final String? battingScore;
  final String? bowlingScore;

  const _SportoTeamRow({
    required this.battingTeam,
    required this.bowlingTeam,
    this.battingScore,
    this.bowlingScore,
  });

  @override
  Widget build(BuildContext context) {
    final scale = context.sportoScale;
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                battingTeam,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colors.onSurface,
                  fontSize: 13 * scale,
                ),
              ),
              SizedBox(height: 4 * scale),
              Text(
                'Batting',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: SportoScoringTokens.green,
                  fontSize: 11 * scale,
                ),
              ),
              if (battingScore != null) ...[
                SizedBox(height: 3 * scale),
                Text(
                  battingScore!,
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: SportoScoringTokens.orange,
                    fontSize: 16 * scale,
                  ),
                ),
              ],
            ],
          ),
        ),
        Text(
          'Vs',
          style: theme.textTheme.bodySmall?.copyWith(
            fontSize: 11 * scale,
          ),
        ),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                bowlingTeam,
                textAlign: TextAlign.end,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colors.onSurface,
                  fontSize: 13 * scale,
                ),
              ),
              SizedBox(height: 4 * scale),
              Text(
                'Bowling',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: SportoScoringTokens.blue,
                  fontSize: 11 * scale,
                ),
              ),
              if (bowlingScore != null) ...[
                SizedBox(height: 3 * scale),
                Text(
                  bowlingScore!,
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: colors.onSurfaceVariant,
                    fontSize: 16 * scale,
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

// ============================================================
// BALL UI MODEL
// ============================================================

enum SportoLiveBallStyle {
  normal,
  four,
  six,
  wicket,
  empty,
}

class SportoLiveBallView {
  final String value;
  final SportoLiveBallStyle style;

  const SportoLiveBallView(
    this.value, {
    this.style = SportoLiveBallStyle.normal,
  });

  const SportoLiveBallView.empty()
      : value = '',
        style = SportoLiveBallStyle.empty;
}

// ============================================================
// SCORE CARD
// ============================================================

class SportoLiveScoreCard extends StatelessWidget {
  final String? title;

  final String score;
  final String progress;

  final String? bowler;

  final List<SportoLiveBallView>? balls;

  final double height;

  const SportoLiveScoreCard({
    super.key,
    this.title = 'Hyd Highlanders',
    required this.score,
    required this.progress,
    this.bowler,
    this.balls,
    this.height = 143,
  });

  @override
  Widget build(BuildContext context) {
    final scale = context.sportoScale;
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Container(
      width: double.infinity,
      height: height * scale,
      padding: EdgeInsets.symmetric(
        horizontal: 14 * scale,
      ),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [
            SportoScoringTokens.scoreStart,
            SportoScoringTokens.scoreMiddle,
            SportoScoringTokens.scoreEnd,
          ],
        ),
        borderRadius: BorderRadius.circular(
          20 * scale,
        ),
        border: Border.all(
          color: SportoScoringTokens.green.withValues(alpha: .25),
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (title != null) ...[
            Text(
              title!,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: SportoScoringTokens.blue,
                fontSize: 14 * scale,
              ),
            ),
            SizedBox(height: 9 * scale),
          ],
          Text(
            'Runs / Wicket',
            style: theme.textTheme.bodySmall?.copyWith(
              color: colors.onSurfaceVariant,
              fontSize: 12 * scale,
            ),
          ),
          SizedBox(height: 7 * scale),
          Text(
            score,
            style: theme.textTheme.displayLarge?.copyWith(
              color: SportoScoringTokens.orange,
              fontSize: 31 * scale,
              height: 1,
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(height: 10 * scale),
          Text(
            progress,
            style: theme.textTheme.bodyLarge?.copyWith(
              color: colors.onSurface,
              fontSize: 14 * scale,
              fontWeight: FontWeight.w600,
            ),
          ),
          if (balls != null) ...[
            SizedBox(height: 13 * scale),
            const SportoScoringDashedDivider(),
            SizedBox(height: 11 * scale),
            Align(
              alignment: Alignment.centerLeft,
              child: Text.rich(
                TextSpan(
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: colors.onSurfaceVariant,
                    fontSize: 14 * scale,
                  ),
                  children: [
                    const TextSpan(
                      text: 'This Over - ',
                    ),
                    TextSpan(
                      text: bowler ?? '',
                      style: TextStyle(
                        color: colors.onSurface,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 11 * scale),
            Align(
              alignment: Alignment.centerLeft,
              child: Row(
                children: List.generate(
                  balls!.length,
                  (index) {
                    return Padding(
                      padding: EdgeInsets.only(
                        right: index == balls!.length - 1 ? 0 : 10 * scale,
                      ),
                      child: _BallCircle(
                        ball: balls![index],
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _BallCircle extends StatelessWidget {
  final SportoLiveBallView ball;

  const _BallCircle({
    required this.ball,
  });

  @override
  Widget build(BuildContext context) {
    final scale = context.sportoScale;

    final background = switch (ball.style) {
      SportoLiveBallStyle.four => SportoScoringTokens.ballBlue,
      SportoLiveBallStyle.six => SportoScoringTokens.ballSix,
      SportoLiveBallStyle.wicket => SportoScoringTokens.red,
      SportoLiveBallStyle.normal => SportoScoringTokens.ballNeutral,
      SportoLiveBallStyle.empty => SportoScoringTokens.ballNeutral,
    };

    final darkText = ball.style == SportoLiveBallStyle.four ||
        ball.style == SportoLiveBallStyle.six;

    return Container(
      width: 30 * scale,
      height: 30 * scale,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: background,
        shape: BoxShape.circle,
      ),
      child: Text(
        ball.value,
        style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: darkText ? const Color(0xFF071018) : Colors.white,
              fontSize: 12 * scale,
              fontWeight: FontWeight.w700,
            ),
      ),
    );
  }
}

// ============================================================
// BOWLER OPTION MODEL
// ============================================================

class SportoLiveBowlerOption {
  final String id;
  final String name;

  final bool selected;
  final bool enabled;

  const SportoLiveBowlerOption({
    required this.id,
    required this.name,
    required this.selected,
    required this.enabled,
  });
}

// ============================================================
// BOWLER SELECTOR
// ============================================================

class SportoLiveBowlerSelector extends StatelessWidget {
  final String title;

  final List<SportoLiveBowlerOption> bowlers;

  final ValueChanged<String> onSelected;

  final String buttonText;

  final bool buttonEnabled;

  final VoidCallback onContinue;

  const SportoLiveBowlerSelector({
    super.key,
    required this.title,
    required this.bowlers,
    required this.onSelected,
    required this.buttonText,
    required this.buttonEnabled,
    required this.onContinue,
  });

  @override
  Widget build(BuildContext context) {
    final scale = context.sportoScale;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: SportoScoringTokens.green,
                fontSize: 15 * scale,
                fontWeight: FontWeight.w600,
              ),
        ),
        SizedBox(height: 14 * scale),
        ...List.generate(
          bowlers.length,
          (index) {
            final bowler = bowlers[index];

            return Padding(
              padding: EdgeInsets.only(
                bottom: index == bowlers.length - 1 ? 0 : 8 * scale,
              ),
              child: _BowlerTile(
                option: bowler,
                onTap: () {
                  if (bowler.enabled) {
                    onSelected(bowler.id);
                  }
                },
              ),
            );
          },
        ),
        SizedBox(height: 18 * scale),
        SportoLivePrimaryButton(
          text: buttonText,
          disabled: !buttonEnabled,
          onTap: onContinue,
        ),
      ],
    );
  }
}

class _BowlerTile extends StatelessWidget {
  final SportoLiveBowlerOption option;
  final VoidCallback onTap;

  const _BowlerTile({
    required this.option,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final scale = context.sportoScale;
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Material(
      color: SportoScoringTokens.inputSurface,
      borderRadius: BorderRadius.circular(
        11 * scale,
      ),
      child: InkWell(
        onTap: option.enabled ? onTap : null,
        borderRadius: BorderRadius.circular(
          11 * scale,
        ),
        child: Container(
          width: double.infinity,
          height: 40 * scale,
          padding: EdgeInsets.symmetric(
            horizontal: 14 * scale,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(
              11 * scale,
            ),
            border: Border.all(
              color: option.selected
                  ? SportoScoringTokens.blue.withValues(alpha: .28)
                  : Colors.transparent,
            ),
          ),
          child: Row(
            children: [
              SizedBox(
                width: 17 * scale,
                height: 17 * scale,
                child: FittedBox(
                  child: SportoCheckBox(
                    checked: option.selected,
                  ),
                ),
              ),
              SizedBox(width: 8 * scale),
              Expanded(
                child: Text(
                  option.name,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: option.enabled
                        ? colors.onSurfaceVariant
                        : colors.onSurfaceVariant.withValues(
                            alpha: .43,
                          ),
                    fontSize: 13 * scale,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ============================================================
// SCORING CONTROLS
// ============================================================

class SportoLiveScoringControls extends StatelessWidget {
  final String bowler;

  final ValueChanged<int> onRun;

  final VoidCallback onWicket;
  final VoidCallback onWide;
  final VoidCallback onNoBall;

  const SportoLiveScoringControls({
    super.key,
    required this.bowler,
    required this.onRun,
    required this.onWicket,
    required this.onWide,
    required this.onNoBall,
  });

  @override
  Widget build(BuildContext context) {
    final scale = context.sportoScale;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'This Over — $bowler',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: SportoScoringTokens.orange,
                fontSize: 15 * scale,
                fontWeight: FontWeight.w600,
              ),
        ),
        SizedBox(height: 14 * scale),
        Row(
          children: [
            for (final run in const [0, 1, 2, 4, 6]) ...[
              Expanded(
                child: _ScoringButton(
                  label: '$run',
                  onTap: () => onRun(run),
                ),
              ),
              if (run != 6) SizedBox(width: 16 * scale),
            ],
          ],
        ),
        SizedBox(height: 20 * scale),
        Row(
          children: [
            Expanded(
              child: _ScoringButton(
                label: 'WKT',
                danger: true,
                onTap: onWicket,
              ),
            ),
            SizedBox(width: 16 * scale),
            Expanded(
              child: _ScoringButton(
                label: 'Wide',
                accent: true,
                onTap: onWide,
              ),
            ),
            SizedBox(width: 16 * scale),
            Expanded(
              child: _ScoringButton(
                label: 'No Ball',
                accent: true,
                onTap: onNoBall,
              ),
            ),
          ],
        ),
        SizedBox(height: 19 * scale),
        Divider(
          height: 1,
          color: Theme.of(context).colorScheme.outline.withValues(alpha: .28),
        ),
        SizedBox(height: 10 * scale),
        Center(
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: 9 * scale,
              vertical: 4 * scale,
            ),
            decoration: BoxDecoration(
              color: SportoScoringTokens.orange.withValues(alpha: .07),
              borderRadius: BorderRadius.circular(
                6 * scale,
              ),
            ),
            child: Text(
              '“One Wide in One Doesn’t Count. Re-bowled It',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: SportoScoringTokens.orange,
                    fontSize: 10 * scale,
                  ),
            ),
          ),
        ),
      ],
    );
  }
}

class _ScoringButton extends StatelessWidget {
  final String label;

  final bool danger;
  final bool accent;

  final VoidCallback onTap;

  const _ScoringButton({
    required this.label,
    required this.onTap,
    this.danger = false,
    this.accent = false,
  });

  @override
  Widget build(BuildContext context) {
    final scale = context.sportoScale;

    return Material(
      color:
          danger ? SportoScoringTokens.red : SportoScoringTokens.inputSurface,
      borderRadius: BorderRadius.circular(
        11 * scale,
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(
          11 * scale,
        ),
        child: Container(
          height: 45 * scale,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(
              11 * scale,
            ),
            border: danger
                ? null
                : Border.all(
                    color: SportoScoringTokens.inputBorder,
                  ),
          ),
          child: Text(
            label,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: danger
                      ? Colors.white
                      : accent
                          ? SportoScoringTokens.orange
                          : Theme.of(context).colorScheme.onSurface,
                  fontSize: 18 * scale,
                  fontWeight: FontWeight.w600,
                ),
          ),
        ),
      ),
    );
  }
}

// ============================================================
// OVER COMPLETED NOTICE
// ============================================================

class SportoLiveNoticeBar extends StatelessWidget {
  final String text;

  const SportoLiveNoticeBar({
    super.key,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    final scale = context.sportoScale;

    return Container(
      width: double.infinity,
      height: 47 * scale,
      decoration: BoxDecoration(
        color: SportoScoringTokens.inningsSurface,
        borderRadius: BorderRadius.circular(
          10 * scale,
        ),
        border: Border.all(
          color: SportoScoringTokens.inningsBorder,
        ),
      ),
      alignment: Alignment.center,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 17 * scale,
            height: 17 * scale,
            child: const FittedBox(
              child: SportoCheckBox(
                checked: true,
              ),
            ),
          ),
          SizedBox(width: 8 * scale),
          Text(
            text,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                  fontSize: 13 * scale,
                ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// INNINGS SUMMARY
// ============================================================

class SportoLiveInningsSummary extends StatelessWidget {
  final String title;

  final String battingTeam;
  final String bowlingTeam;

  final String battingScore;
  final String bowlingScore;

  final double height;

  const SportoLiveInningsSummary({
    super.key,
    required this.title,
    required this.battingTeam,
    required this.bowlingTeam,
    required this.battingScore,
    required this.bowlingScore,
    this.height = 129,
  });

  @override
  Widget build(BuildContext context) {
    final scale = context.sportoScale;

    return Container(
      width: double.infinity,
      height: height * scale,
      padding: EdgeInsets.all(
        14 * scale,
      ),
      decoration: BoxDecoration(
        color: SportoScoringTokens.inningsSurface,
        borderRadius: BorderRadius.circular(
          12 * scale,
        ),
        border: Border.all(
          color: SportoScoringTokens.inningsBorder,
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              SizedBox(
                width: 17 * scale,
                height: 17 * scale,
                child: const FittedBox(
                  child: SportoCheckBox(
                    checked: true,
                  ),
                ),
              ),
              SizedBox(width: 8 * scale),
              Expanded(
                child: Text(
                  title,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontSize: 14 * scale,
                      ),
                ),
              ),
            ],
          ),
          SizedBox(height: 11 * scale),
          const SportoScoringDashedDivider(),
          SizedBox(height: 11 * scale),
          _SportoTeamRow(
            battingTeam: battingTeam,
            bowlingTeam: bowlingTeam,
            battingScore: battingScore,
            bowlingScore: bowlingScore,
          ),
        ],
      ),
    );
  }
}

// ============================================================
// TIE BREAKER
// ============================================================

class SportoLiveTieBreakerCard extends StatelessWidget {
  final String regulationScore;

  final String opponentTeam;
  final String opponentSuperOverScore;

  const SportoLiveTieBreakerCard({
    super.key,
    required this.regulationScore,
    required this.opponentTeam,
    required this.opponentSuperOverScore,
  });

  @override
  Widget build(BuildContext context) {
    final scale = context.sportoScale;

    return Container(
      width: double.infinity,
      height: 120 * scale,
      padding: EdgeInsets.all(
        14 * scale,
      ),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            SportoScoringTokens.tieStart,
            SportoScoringTokens.tieEnd,
          ],
        ),
        borderRadius: BorderRadius.circular(
          12 * scale,
        ),
        border: Border.all(
          color: SportoScoringTokens.tieBorder,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              SizedBox(
                width: 17 * scale,
                height: 17 * scale,
                child: const FittedBox(
                  child: SportoCheckBox(
                    checked: true,
                  ),
                ),
              ),
              SizedBox(width: 8 * scale),
              Text(
                'Tie - Breaker',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontSize: 14 * scale,
                    ),
              ),
            ],
          ),
          SizedBox(height: 12 * scale),
          const SportoScoringDashedDivider(),
          SizedBox(height: 11 * scale),
          Text(
            'Regulation tied $regulationScore.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurface,
                  fontSize: 13 * scale,
                ),
          ),
          SizedBox(height: 4 * scale),
          Text(
            'One extra over each, $opponentTeam’s Super Over already\nposted $opponentSuperOverScore.',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurface,
                  fontSize: 11 * scale,
                  height: 1.2,
                ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// WINNER
// ============================================================

class SportoLiveWinnerCard extends StatelessWidget {
  final String winner;

  const SportoLiveWinnerCard({
    super.key,
    required this.winner,
  });

  @override
  Widget build(BuildContext context) {
    final scale = context.sportoScale;

    return Container(
      width: double.infinity,
      height: 70 * scale,
      padding: EdgeInsets.symmetric(
        horizontal: 14 * scale,
      ),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [
            SportoScoringTokens.winnerStart,
            SportoScoringTokens.winnerMiddle,
            SportoScoringTokens.winnerEnd,
          ],
        ),
        borderRadius: BorderRadius.circular(
          20 * scale,
        ),
        border: Border.all(
          color: SportoScoringTokens.green.withValues(alpha: .25),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 40 * scale,
            height: 40 * scale,
            decoration: BoxDecoration(
              color: SportoScoringTokens.orange.withValues(alpha: .15),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.emoji_events_rounded,
              color: SportoScoringTokens.orange,
              size: 23 * scale,
            ),
          ),
          SizedBox(width: 10 * scale),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Winner',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: SportoScoringTokens.blue,
                      fontSize: 12 * scale,
                    ),
              ),
              SizedBox(height: 3 * scale),
              Text(
                winner,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: SportoScoringTokens.orange,
                      fontSize: 15 * scale,
                    ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ============================================================
// PRIMARY BUTTON
// ============================================================

class SportoLivePrimaryButton extends StatelessWidget {
  final String text;

  final bool disabled;

  final VoidCallback? onTap;

  const SportoLivePrimaryButton({
    super.key,
    required this.text,
    this.disabled = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final scale = context.sportoScale;

    return Center(
      child: PrimaryButton(
        width: 270 * scale,
        height: 49 * scale,
        radius: 14 * scale,
        label: text,
        disabled: disabled,
        onPressed: onTap,
      ),
    );
  }
}

class SportoLiveInningsBreakCard extends StatelessWidget {
  final String completedTeam;
  final String completedScore;

  final String chasingTeam;

  final int target;

  const SportoLiveInningsBreakCard({
    super.key,
    required this.completedTeam,
    required this.completedScore,
    required this.chasingTeam,
    required this.target,
  });

  @override
  Widget build(BuildContext context) {
    final scale = context.sportoScale;
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(
        16 * scale,
        17 * scale,
        16 * scale,
        18 * scale,
      ),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [
            Color(0xFF56332C),
            Color(0xFF073D2A),
            Color(0xFF46530D),
          ],
        ),
        borderRadius: BorderRadius.circular(
          20 * scale,
        ),
        border: Border.all(
          color: SportoScoringTokens.green.withValues(alpha: .25),
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: 18 * scale,
                height: 18 * scale,
                child: const FittedBox(
                  child: SportoCheckBox(
                    checked: true,
                  ),
                ),
              ),
              SizedBox(width: 7 * scale),
              Text(
                '1st Innings Completed',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colors.onSurfaceVariant,
                  fontSize: 14 * scale,
                ),
              ),
            ],
          ),
          SizedBox(height: 15 * scale),
          Text(
            completedTeam,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: SportoScoringTokens.blue,
              fontSize: 14 * scale,
            ),
          ),
          SizedBox(height: 7 * scale),
          Text(
            completedScore,
            style: theme.textTheme.displayLarge?.copyWith(
              color: SportoScoringTokens.orange,
              fontSize: 31 * scale,
              height: 1,
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(height: 17 * scale),
          const SportoScoringDashedDivider(),
          SizedBox(height: 15 * scale),
          Text(
            '$chasingTeam needs',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colors.onSurfaceVariant,
              fontSize: 13 * scale,
            ),
          ),
          SizedBox(height: 4 * scale),
          Text(
            '$target Runs to Win',
            style: theme.textTheme.titleLarge?.copyWith(
              color: SportoScoringTokens.green,
              fontSize: 18 * scale,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
