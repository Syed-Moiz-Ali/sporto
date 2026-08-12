import 'package:flutter/material.dart';

import '../theme/sporto_cricket_scoring_theme.dart';
import '../theme/sporto_design_tokens.dart';
import 'primary_button.dart';
import 'sporto_check_box.dart';
import 'sporto_divider.dart';

// ============================================================
// PAGE HEADER
// ============================================================

class SportoCricketScoringHeader extends StatelessWidget {
  final String title;
  final String matchId;
  final VoidCallback? onBack;

  const SportoCricketScoringHeader({
    super.key,
    required this.title,
    this.matchId = 'Match #SPT-20481',
    this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    final s = context.sportoScale;
    final theme = Theme.of(context);

    return SizedBox(
      height: 36 * s,
      child: Row(
        children: [
          Material(
            color: const Color(0xFF293141),
            borderRadius: BorderRadius.circular(11 * s),
            child: InkWell(
              onTap: onBack,
              borderRadius: BorderRadius.circular(11 * s),
              child: SizedBox(
                width: 36 * s,
                height: 36 * s,
                child: Icon(
                  Icons.chevron_left_rounded,
                  size: 27 * s,
                ),
              ),
            ),
          ),
          SizedBox(width: 10 * s),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontSize: 18 * s,
                    height: 1,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 4 * s),
                Text(
                  matchId,
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontSize: 11 * s,
                    height: 1,
                    color: theme.colorScheme.onSurface,
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
// STATUS BADGE
// ============================================================

class SportoCricketStatusBadge extends StatelessWidget {
  final String text;
  final Color color;

  final bool outlined;
  final bool dot;
  final bool lightSurface;

  const SportoCricketStatusBadge({
    super.key,
    required this.text,
    required this.color,
    this.outlined = false,
    this.dot = false,
    this.lightSurface = false,
  });

  @override
  Widget build(BuildContext context) {
    final s = context.sportoScale;

    return Container(
      height: 20 * s,
      padding: EdgeInsets.symmetric(
        horizontal: 6 * s,
      ),
      decoration: BoxDecoration(
        color: lightSurface
            ? const Color(0xFFF4ECE7)
            : outlined
                ? Colors.transparent
                : color.withValues(alpha: .14),
        borderRadius: BorderRadius.circular(8 * s),
        border: outlined
            ? Border.all(
                color: color,
                width: 1,
              )
            : null,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (dot) ...[
            Container(
              width: 8 * s,
              height: 8 * s,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
              ),
            ),
            SizedBox(width: 4 * s),
          ],
          Text(
            text,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: color,
                  fontSize: 11 * s,
                  height: 1,
                  fontWeight: FontWeight.w500,
                ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// MATCH HEADER
// ============================================================

class SportoCricketMatchHeaderCard extends StatelessWidget {
  final bool showTeams;
  final bool showScores;

  final String? teamAScore;
  final String? teamBScore;

  const SportoCricketMatchHeaderCard({
    super.key,
    this.showTeams = true,
    this.showScores = false,
    this.teamAScore,
    this.teamBScore,
  });

  @override
  Widget build(BuildContext context) {
    final s = context.sportoScale;
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final t = context.cricketScoring;

    final height = !showTeams
        ? 95.0
        : showScores
            ? 176.0
            : 154.0;

    return Container(
      width: double.infinity,
      height: height * s,
      padding: EdgeInsets.fromLTRB(
        14 * s,
        13 * s,
        14 * s,
        13 * s,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            t.matchStart,
            t.matchMiddle,
            t.matchEnd,
          ],
        ),
        borderRadius: BorderRadius.circular(20 * s),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              SportoCricketStatusBadge(
                text: 'Quarter Final',
                color: t.green,
                outlined: true,
              ),
              SizedBox(width: 6 * s),
              SportoCricketStatusBadge(
                text: 'Live Now',
                color: t.red,
                dot: true,
                lightSurface: true,
              ),
            ],
          ),
          SizedBox(height: 9 * s),
          Text(
            'Asia Cup 2026',
            style: theme.textTheme.titleLarge?.copyWith(
              color: t.orange,
              fontSize: 15 * s,
              height: 1,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 5 * s),
          Row(
            children: [
              Icon(
                Icons.location_on_outlined,
                size: 14 * s,
                color: cs.onSurfaceVariant,
              ),
              SizedBox(width: 3 * s),
              Text(
                'Hyderabad',
                style: theme.textTheme.bodySmall?.copyWith(
                  fontSize: 11 * s,
                  height: 1,
                ),
              ),
            ],
          ),
          if (showTeams) ...[
            SizedBox(height: 11 * s),
            SportoDivider(
              dashed: true,
              color: cs.outline.withValues(alpha: .75),
            ),
            SizedBox(height: 11 * s),
            _TeamRow(
              showScores: showScores,
              teamAScore: teamAScore,
              teamBScore: teamBScore,
            ),
          ],
        ],
      ),
    );
  }
}

class _TeamRow extends StatelessWidget {
  final bool showScores;
  final String? teamAScore;
  final String? teamBScore;

  const _TeamRow({
    required this.showScores,
    this.teamAScore,
    this.teamBScore,
  });

  @override
  Widget build(BuildContext context) {
    final s = context.sportoScale;
    final cs = Theme.of(context).colorScheme;
    final t = context.cricketScoring;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Hyd Highlanders',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: cs.onSurface,
                      fontSize: 13 * s,
                      height: 1,
                    ),
              ),
              SizedBox(height: 5 * s),
              Text(
                'Batting',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: t.green,
                      fontSize: 11 * s,
                      height: 1,
                    ),
              ),
              if (showScores) ...[
                SizedBox(height: 4 * s),
                Text(
                  teamAScore ?? '90/2',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: t.orange,
                        fontSize: 16 * s,
                        height: 1,
                      ),
                ),
              ],
            ],
          ),
        ),
        Text(
          'Vs',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                fontSize: 11 * s,
              ),
        ),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                'Delhi Warriors',
                textAlign: TextAlign.end,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: cs.onSurface,
                      fontSize: 13 * s,
                      height: 1,
                    ),
              ),
              SizedBox(height: 5 * s),
              Text(
                'Bowling',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: t.blue,
                      fontSize: 11 * s,
                      height: 1,
                    ),
              ),
              if (showScores) ...[
                SizedBox(height: 4 * s),
                Text(
                  teamBScore ?? '85/3',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: cs.onSurfaceVariant,
                        fontSize: 16 * s,
                        height: 1,
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
// SCORE PANEL
// ============================================================

enum SportoCricketBallStyle {
  normal,
  four,
  six,
  empty,
}

class SportoCricketBall {
  final String value;
  final SportoCricketBallStyle style;

  const SportoCricketBall(
    this.value, {
    this.style = SportoCricketBallStyle.normal,
  });

  const SportoCricketBall.empty()
      : value = '',
        style = SportoCricketBallStyle.empty;
}

class SportoCricketScoreCard extends StatelessWidget {
  final String? title;

  final String score;
  final String progress;

  final String? bowler;

  final List<SportoCricketBall>? balls;

  /// Use the exact screenshot height.
  final double height;

  const SportoCricketScoreCard({
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
    final s = context.sportoScale;
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final t = context.cricketScoring;

    return Container(
      width: double.infinity,
      height: height * s,
      padding: EdgeInsets.symmetric(
        horizontal: 14 * s,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [
            t.scoreStart,
            t.scoreMiddle,
            t.scoreEnd,
          ],
        ),
        borderRadius: BorderRadius.circular(20 * s),
        border: Border.all(
          color: t.green.withValues(alpha: .25),
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (title != null) ...[
            Text(
              title!,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: t.blue,
                fontSize: 14 * s,
                height: 1,
              ),
            ),
            SizedBox(height: 9 * s),
          ],
          Text(
            'Runs / Wicket',
            style: theme.textTheme.bodySmall?.copyWith(
              color: cs.onSurfaceVariant,
              fontSize: 12 * s,
              height: 1,
            ),
          ),
          SizedBox(height: 8 * s),
          Text(
            score,
            style: theme.textTheme.displayLarge?.copyWith(
              color: t.orange,
              fontSize: 31 * s,
              height: 1,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 11 * s),
          Text(
            progress,
            style: theme.textTheme.bodyLarge?.copyWith(
              color: cs.onSurface,
              fontSize: 14 * s,
              height: 1,
              fontWeight: FontWeight.w500,
            ),
          ),
          if (balls != null) ...[
            SizedBox(height: 13 * s),
            SportoDivider(
              dashed: true,
              color: cs.outline.withValues(alpha: .7),
            ),
            SizedBox(height: 12 * s),
            Align(
              alignment: Alignment.centerLeft,
              child: Text.rich(
                TextSpan(
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: cs.onSurfaceVariant,
                    fontSize: 14 * s,
                  ),
                  children: [
                    const TextSpan(
                      text: 'This Over - ',
                    ),
                    TextSpan(
                      text: bowler ?? 'Amit Kumar',
                      style: TextStyle(
                        color: cs.onSurface,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 11 * s),
            Align(
              alignment: Alignment.centerLeft,
              child: Row(
                children: [
                  for (final ball in balls!) ...[
                    _BallChip(ball: ball),
                    if (ball != balls!.last) SizedBox(width: 10 * s),
                  ],
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _BallChip extends StatelessWidget {
  final SportoCricketBall ball;

  const _BallChip({
    required this.ball,
  });

  @override
  Widget build(BuildContext context) {
    final s = context.sportoScale;
    final t = context.cricketScoring;

    final color = switch (ball.style) {
      SportoCricketBallStyle.four => t.ballBlue,
      SportoCricketBallStyle.six => t.ballSix,
      SportoCricketBallStyle.normal => t.ballNeutral,
      SportoCricketBallStyle.empty => t.ballNeutral,
    };

    final darkText = ball.style == SportoCricketBallStyle.four ||
        ball.style == SportoCricketBallStyle.six;

    return Container(
      width: 30 * s,
      height: 30 * s,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
      ),
      child: Text(
        ball.value,
        style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: darkText ? const Color(0xFF061018) : Colors.white,
              fontSize: 12 * s,
              fontWeight: FontWeight.w600,
            ),
      ),
    );
  }
}

// ============================================================
// PLAYER SELECT
// ============================================================

class SportoCricketPlayerOption extends StatelessWidget {
  final String name;
  final bool selected;
  final bool enabled;

  final VoidCallback? onTap;

  const SportoCricketPlayerOption({
    super.key,
    required this.name,
    this.selected = false,
    this.enabled = true,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final s = context.sportoScale;
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final t = context.cricketScoring;

    return Material(
      color: t.inputSurface,
      borderRadius: BorderRadius.circular(11 * s),
      child: InkWell(
        onTap: enabled ? onTap : null,
        borderRadius: BorderRadius.circular(11 * s),
        child: Container(
          height: 40 * s,
          padding: EdgeInsets.symmetric(
            horizontal: 14 * s,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(11 * s),
            border: Border.all(
              color:
                  selected ? t.blue.withValues(alpha: .27) : Colors.transparent,
            ),
          ),
          child: Row(
            children: [
              SportoCheckBox(
                checked: selected,
              ),
              SizedBox(width: 8 * s),
              Expanded(
                child: Text(
                  name,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: enabled
                        ? cs.onSurfaceVariant
                        : cs.onSurfaceVariant.withValues(alpha: .45),
                    fontSize: 13 * s,
                    height: 1,
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
// INNINGS CARD
// ============================================================

class SportoCricketInningsCard extends StatelessWidget {
  final String title;
  final String scoreA;
  final String scoreB;

  final double height;

  const SportoCricketInningsCard({
    super.key,
    required this.title,
    required this.scoreA,
    required this.scoreB,
    this.height = 129,
  });

  @override
  Widget build(BuildContext context) {
    final s = context.sportoScale;
    final cs = Theme.of(context).colorScheme;
    final t = context.cricketScoring;

    return Container(
      width: double.infinity,
      height: height * s,
      padding: EdgeInsets.all(14 * s),
      decoration: BoxDecoration(
        color: t.inningsSurface,
        borderRadius: BorderRadius.circular(12 * s),
        border: Border.all(
          color: t.inningsBorder,
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              SportoCheckBox(
                checked: true,
              ),
              SizedBox(width: 8 * s),
              Expanded(
                child: Text(
                  title,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: cs.onSurfaceVariant,
                        fontSize: 14 * s,
                      ),
                ),
              ),
            ],
          ),
          SizedBox(height: 11 * s),
          SportoDivider(
            dashed: true,
            color: cs.outline.withValues(alpha: .7),
          ),
          SizedBox(height: 11 * s),
          _TeamRow(
            showScores: true,
            teamAScore: scoreA,
            teamBScore: scoreB,
          ),
        ],
      ),
    );
  }
}

// ============================================================
// TIE BREAKER
// ============================================================

class SportoCricketTieBreakerCard extends StatelessWidget {
  const SportoCricketTieBreakerCard({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final s = context.sportoScale;
    final cs = Theme.of(context).colorScheme;
    final t = context.cricketScoring;

    return Container(
      width: double.infinity,
      height: 120 * s,
      padding: EdgeInsets.all(14 * s),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            t.tieStart,
            t.tieEnd,
          ],
        ),
        borderRadius: BorderRadius.circular(12 * s),
        border: Border.all(
          color: t.tieBorder,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              SportoCheckBox(
                checked: true,
              ),
              SizedBox(width: 8 * s),
              Text(
                'Tie - Breaker',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: cs.onSurfaceVariant,
                      fontSize: 14 * s,
                    ),
              ),
            ],
          ),
          SizedBox(height: 12 * s),
          SportoDivider(
            dashed: true,
            color: cs.outline.withValues(alpha: .65),
          ),
          SizedBox(height: 11 * s),
          Text(
            'Regulation tied 90–90.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: cs.onSurface,
                  fontSize: 13 * s,
                ),
          ),
          SizedBox(height: 4 * s),
          Text(
            'One extra over each, Delhi Warriors’s Super Over already\nposted 9.',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: cs.onSurface,
                  fontSize: 11 * s,
                  height: 1.2,
                ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// NOTICE BAR
// ============================================================

class SportoCricketNoticeBar extends StatelessWidget {
  final String text;

  const SportoCricketNoticeBar({
    super.key,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    final s = context.sportoScale;
    final cs = Theme.of(context).colorScheme;
    final t = context.cricketScoring;

    return Container(
      width: double.infinity,
      height: 47 * s,
      padding: EdgeInsets.symmetric(
        horizontal: 14 * s,
      ),
      decoration: BoxDecoration(
        color: t.inningsSurface,
        borderRadius: BorderRadius.circular(10 * s),
        border: Border.all(
          color: t.inningsBorder,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SportoCheckBox(
            checked: true,
          ),
          SizedBox(width: 8 * s),
          Text(
            text,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: cs.onSurfaceVariant,
                  fontSize: 13 * s,
                ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// SCORING PAD
// ============================================================

class SportoCricketScoringPad extends StatelessWidget {
  final String bowler;

  final ValueChanged<int>? onRun;
  final VoidCallback? onWicket;
  final VoidCallback? onWide;
  final VoidCallback? onNoBall;

  const SportoCricketScoringPad({
    super.key,
    required this.bowler,
    this.onRun,
    this.onWicket,
    this.onWide,
    this.onNoBall,
  });

  @override
  Widget build(BuildContext context) {
    final s = context.sportoScale;
    final t = context.cricketScoring;
    final cs = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'This Over — $bowler',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: t.orange,
                fontSize: 15 * s,
                fontWeight: FontWeight.w500,
              ),
        ),
        SizedBox(height: 14 * s),
        Row(
          children: [
            for (final run in const [0, 1, 2, 4, 6]) ...[
              Expanded(
                child: _ScoreAction(
                  text: '$run',
                  onTap: () => onRun?.call(run),
                ),
              ),
              if (run != 6) SizedBox(width: 16 * s),
            ],
          ],
        ),
        SizedBox(height: 20 * s),
        Row(
          children: [
            Expanded(
              child: _ScoreAction(
                text: 'WKT',
                danger: true,
                onTap: onWicket,
              ),
            ),
            SizedBox(width: 16 * s),
            Expanded(
              child: _ScoreAction(
                text: 'Wide',
                orange: true,
                onTap: onWide,
              ),
            ),
            SizedBox(width: 16 * s),
            Expanded(
              child: _ScoreAction(
                text: 'No Ball',
                orange: true,
                onTap: onNoBall,
              ),
            ),
          ],
        ),
        SizedBox(height: 19 * s),
        Divider(
          height: 1,
          color: cs.outline.withValues(alpha: .28),
        ),
        SizedBox(height: 10 * s),
        Center(
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: 9 * s,
              vertical: 4 * s,
            ),
            decoration: BoxDecoration(
              color: t.orange.withValues(alpha: .07),
              borderRadius: BorderRadius.circular(6 * s),
            ),
            child: Text(
              '“One Wide in One Doesn’t Count. Re-bowled It',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: t.orange,
                    fontSize: 10 * s,
                  ),
            ),
          ),
        ),
      ],
    );
  }
}

class _ScoreAction extends StatelessWidget {
  final String text;
  final bool danger;
  final bool orange;
  final VoidCallback? onTap;

  const _ScoreAction({
    required this.text,
    this.danger = false,
    this.orange = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final s = context.sportoScale;
    final t = context.cricketScoring;
    final cs = Theme.of(context).colorScheme;

    return Material(
      color: danger ? t.red : t.inputSurface,
      borderRadius: BorderRadius.circular(11 * s),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(11 * s),
        child: Container(
          height: 45 * s,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(11 * s),
            border: danger
                ? null
                : Border.all(
                    color: t.inputBorder,
                  ),
          ),
          child: Text(
            text,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: danger
                      ? Colors.white
                      : orange
                          ? t.orange
                          : cs.onSurface,
                  fontSize: 18 * s,
                  fontWeight: FontWeight.w500,
                ),
          ),
        ),
      ),
    );
  }
}

// ============================================================
// WINNER
// ============================================================

class SportoCricketWinnerCard extends StatelessWidget {
  const SportoCricketWinnerCard({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final s = context.sportoScale;
    final t = context.cricketScoring;

    return Container(
      width: double.infinity,
      height: 70 * s,
      padding: EdgeInsets.symmetric(
        horizontal: 14 * s,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [
            t.winnerStart,
            t.winnerMiddle,
            t.winnerEnd,
          ],
        ),
        borderRadius: BorderRadius.circular(20 * s),
        border: Border.all(
          color: t.green.withValues(alpha: .25),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 40 * s,
            height: 40 * s,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: t.orange.withValues(alpha: .14),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.emoji_events_rounded,
              color: t.orange,
              size: 23 * s,
            ),
          ),
          SizedBox(width: 10 * s),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Winner',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: t.blue,
                      fontSize: 12 * s,
                    ),
              ),
              SizedBox(height: 3 * s),
              Text(
                'Hyd Highlanders',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: t.orange,
                      fontSize: 15 * s,
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
// PRIMARY CTA
// ============================================================

class SportoCricketPrimaryButton extends StatelessWidget {
  final String text;
  final VoidCallback? onTap;

  const SportoCricketPrimaryButton({
    super.key,
    required this.text,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: PrimaryButton(
        width: 270 * context.sportoScale,
        height: 49 * context.sportoScale,
        radius: 14 * context.sportoScale,
        label: text,
        onPressed: onTap,
      ),
    );
  }
}
