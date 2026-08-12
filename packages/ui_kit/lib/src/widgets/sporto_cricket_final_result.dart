import 'package:flutter/material.dart';

import '../theme/sporto_design_tokens.dart';
import '../theme/sporto_scoring_tokens.dart';
import 'primary_button.dart';
import 'sporto_badge.dart';
import 'sporto_check_box.dart';

// ============================================================
// DATA MODEL
// ============================================================

class SportoCricketInningsResultData {
  final String title;

  final String teamA;
  final String teamARole;
  final String teamAScore;

  final String teamB;
  final String teamBRole;
  final String teamBScore;

  const SportoCricketInningsResultData({
    required this.title,
    required this.teamA,
    required this.teamARole,
    required this.teamAScore,
    required this.teamB,
    required this.teamBRole,
    required this.teamBScore,
  });
}

// ============================================================
// FINAL RESULT CONTENT
//
// IMPORTANT:
// This does NOT contain Scaffold/SafeArea.
// It is reusable content composed inside the scoring screen.
//
// Reference:
// 390 x 844
// Content width:
// 350 px
// ============================================================

class SportoCricketFinalResult extends StatelessWidget {
  final String tournament;
  final String location;
  final String stage;

  final SportoCricketInningsResultData regulation;

  final SportoCricketInningsResultData? superOver;

  final String winner;

  final VoidCallback? onSubmit;

  const SportoCricketFinalResult({
    super.key,
    this.tournament = 'Asia Cup 2026',
    this.location = 'Hyderabad',
    this.stage = 'Quarter Final',
    required this.regulation,
    this.superOver,
    required this.winner,
    this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    final scale = context.sportoScale;

    return Column(
      children: [
        // ====================================================
        // Y = 104
        // H = 95
        // ====================================================

        SportoCricketFinalMatchHeader(
          stage: stage,
          tournament: tournament,
          location: location,
        ),

        SizedBox(height: 20 * scale),

        // ====================================================
        // Y = 219
        // H = 129
        // ====================================================

        SportoCricketFinalInningsCard(
          data: regulation,
          height: 129,
        ),

        if (superOver != null) ...[
          SizedBox(height: 21 * scale),

          // ==================================================
          // Y = 369
          // H = 111
          // ==================================================

          SportoCricketFinalInningsCard(
            data: superOver!,
            height: 111,
            superOver: true,
          ),
        ],

        SizedBox(height: 21 * scale),

        // ====================================================
        // Y ≈ 501
        // H = 70
        // ====================================================

        SportoCricketFinalWinnerCard(
          winner: winner,
        ),

        SizedBox(height: 20 * scale),

        // ====================================================
        // X = 60
        // W = 270
        // H = 49
        // ====================================================

        PrimaryButton(
          width: 270 * scale,
          height: 49 * scale,
          radius: 14 * scale,
          label: 'Submit Final Result',
          onPressed: onSubmit,
        ),
      ],
    );
  }
}

// ============================================================
// COMPACT MATCH HEADER
// Exact final-result screenshot card.
// ============================================================

class SportoCricketFinalMatchHeader extends StatelessWidget {
  final String stage;
  final String tournament;
  final String location;

  const SportoCricketFinalMatchHeader({
    super.key,
    required this.stage,
    required this.tournament,
    required this.location,
  });

  @override
  Widget build(BuildContext context) {
    final scale = context.sportoScale;
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Container(
      width: double.infinity,
      height: 95 * scale,
      padding: EdgeInsets.fromLTRB(
        14 * scale,
        13 * scale,
        14 * scale,
        11 * scale,
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
              // Reuse centralized badge.
              SportoBadge(
                text: stage,
                color: SportoScoringTokens.green,
                outlined: true,
              ),

              SizedBox(width: 6 * scale),

              const _FinalLiveBadge(),
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
                  color: colors.onSurfaceVariant,
                  fontSize: 11 * scale,
                  height: 1,
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
// LIVE BADGE
//
// Existing SportoBadge doesn't currently support this exact
// white/live-dot combination, so this is intentionally part
// of the centralized cricket-result component.
// ============================================================

class _FinalLiveBadge extends StatelessWidget {
  const _FinalLiveBadge();

  @override
  Widget build(BuildContext context) {
    final scale = context.sportoScale;
    final theme = Theme.of(context);

    return Container(
      height: 20 * scale,
      padding: EdgeInsets.symmetric(
        horizontal: 6 * scale,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFFF5EEEA),
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
            style: theme.textTheme.labelSmall?.copyWith(
              color: SportoScoringTokens.red,
              fontSize: 11 * scale,
              height: 1,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// INNINGS RESULT CARD
// ============================================================

class SportoCricketFinalInningsCard extends StatelessWidget {
  final SportoCricketInningsResultData data;

  /// Figma/reference height.
  final double height;

  final bool superOver;

  const SportoCricketFinalInningsCard({
    super.key,
    required this.data,
    required this.height,
    this.superOver = false,
  });

  @override
  Widget build(BuildContext context) {
    final scale = context.sportoScale;
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Container(
      width: double.infinity,
      height: height * scale,
      padding: EdgeInsets.fromLTRB(
        14 * scale,
        14 * scale,
        14 * scale,
        11 * scale,
      ),
      decoration: BoxDecoration(
        color: superOver ? const Color(0xFF15281B) : null,
        gradient: superOver
            ? null
            : const LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                colors: [
                  Color(0xFF21171C),
                  Color(0xFF292128),
                  Color(0xFF1B2427),
                ],
              ),
        borderRadius: BorderRadius.circular(
          12 * scale,
        ),
        border: superOver
            ? Border.all(
                color: const Color(0xFF245538),
                width: 1,
              )
            : null,
      ),
      child: Column(
        children: [
          // ==================================================
          // TITLE
          // ==================================================

          Row(
            children: [
              SizedBox(
                width: 17 * scale,
                height: 17 * scale,
                child: FittedBox(
                  child: const SportoCheckBox(
                    checked: true,
                  ),
                ),
              ),
              SizedBox(width: 8 * scale),
              Expanded(
                child: Text(
                  data.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: colors.onSurfaceVariant,
                    fontSize: 14 * scale,
                    height: 1,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),

          SizedBox(height: 11 * scale),

          const _FinalDashedDivider(),

          SizedBox(height: 11 * scale),

          // ==================================================
          // TEAMS
          // ==================================================

          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: _FinalResultTeam(
                    name: data.teamA,
                    role: data.teamARole,
                    score: data.teamAScore,
                    right: false,
                    scoreColor: SportoScoringTokens.orange,
                    roleColor: SportoScoringTokens.green,
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(
                    top: 17 * scale,
                  ),
                  child: Text(
                    'Vs',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colors.onSurfaceVariant,
                      fontSize: 11 * scale,
                      height: 1,
                    ),
                  ),
                ),
                Expanded(
                  child: _FinalResultTeam(
                    name: data.teamB,
                    role: data.teamBRole,
                    score: data.teamBScore,
                    right: true,
                    scoreColor: colors.onSurfaceVariant,
                    roleColor: SportoScoringTokens.blue,
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

class _FinalResultTeam extends StatelessWidget {
  final String name;
  final String role;
  final String score;

  final bool right;

  final Color roleColor;
  final Color scoreColor;

  const _FinalResultTeam({
    required this.name,
    required this.role,
    required this.score,
    required this.right,
    required this.roleColor,
    required this.scoreColor,
  });

  @override
  Widget build(BuildContext context) {
    final scale = context.sportoScale;
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Column(
      crossAxisAlignment:
          right ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        Text(
          name,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          textAlign: right ? TextAlign.right : TextAlign.left,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: colors.onSurface,
            fontSize: 13 * scale,
            height: 1,
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(height: 6 * scale),
        Text(
          role,
          style: theme.textTheme.bodySmall?.copyWith(
            color: roleColor,
            fontSize: 11 * scale,
            height: 1,
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(height: 5 * scale),
        Text(
          score,
          style: theme.textTheme.titleMedium?.copyWith(
            color: scoreColor,
            fontSize: 16 * scale,
            height: 1,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

// ============================================================
// WINNER CARD
// ============================================================

class SportoCricketFinalWinnerCard extends StatelessWidget {
  final String winner;

  const SportoCricketFinalWinnerCard({
    super.key,
    required this.winner,
  });

  @override
  Widget build(BuildContext context) {
    final scale = context.sportoScale;
    final theme = Theme.of(context);

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
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 40 * scale,
            height: 40 * scale,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: SportoScoringTokens.orange.withValues(alpha: .14),
              shape: BoxShape.circle,
              border: Border.all(
                color: SportoScoringTokens.orange.withValues(alpha: .18),
              ),
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
                style: theme.textTheme.bodySmall?.copyWith(
                  color: SportoScoringTokens.blue,
                  fontSize: 12 * scale,
                  height: 1,
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: 5 * scale),
              Text(
                winner,
                style: theme.textTheme.titleMedium?.copyWith(
                  color: SportoScoringTokens.orange,
                  fontSize: 15 * scale,
                  height: 1,
                  fontWeight: FontWeight.w700,
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
// DASHED DIVIDER
// ============================================================

class _FinalDashedDivider extends StatelessWidget {
  const _FinalDashedDivider();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 1,
      width: double.infinity,
      child: CustomPaint(
        painter: _FinalDashPainter(
          Theme.of(context).colorScheme.onSurfaceVariant.withValues(alpha: .35),
        ),
      ),
    );
  }
}

class _FinalDashPainter extends CustomPainter {
  final Color color;

  const _FinalDashPainter(
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
    covariant _FinalDashPainter oldDelegate,
  ) {
    return oldDelegate.color != color;
  }
}
