import 'package:flutter/material.dart';

import '../theme/sporto_design_tokens.dart';
import '../theme/sporto_scoring_tokens.dart';
import 'sporto_badge.dart';

class SportoResultSubmittedHero extends StatelessWidget {
  const SportoResultSubmittedHero({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final scale = context.sportoScale;
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Container(
      width: double.infinity,
      height: 332 * scale,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFF121820),
            Color(0xFF111615),
            Color(0xFF111514),
          ],
        ),
        borderRadius: BorderRadius.circular(
          30 * scale,
        ),
        border: Border.all(
          color: const Color(0xFF153D31),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          SizedBox(
            height: 58 * scale,
          ),

          // ==================================================
          // CHECK BOX
          // ==================================================

          Container(
            width: 120 * scale,
            height: 121 * scale,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: const Color(0xFF303433),
              borderRadius: BorderRadius.circular(
                40 * scale,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(
                    alpha: .18,
                  ),
                  blurRadius: 20 * scale,
                  offset: Offset(
                    0,
                    8 * scale,
                  ),
                ),
              ],
            ),
            child: Container(
              width: 76 * scale,
              height: 76 * scale,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFF94EC68),
                    Color(0xFF03C600),
                    Color(0xFF02A900),
                  ],
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF12E10B).withValues(
                      alpha: .25,
                    ),
                    blurRadius: 16 * scale,
                  ),
                ],
              ),
              child: Icon(
                Icons.check_rounded,
                color: Colors.white,
                size: 55 * scale,
              ),
            ),
          ),

          SizedBox(
            height: 42 * scale,
          ),

          // ==================================================
          // TITLE
          // ==================================================

          Text(
            'RESULT SUBMITTED',
            style: theme.textTheme.titleLarge?.copyWith(
              color: cs.onSurface,
              fontSize: 18 * scale,
              height: 1,
              fontWeight: FontWeight.w600,
              letterSpacing: .2,
            ),
          ),

          SizedBox(
            height: 16 * scale,
          ),

          // ==================================================
          // DESCRIPTION
          // ==================================================

          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: 24 * scale,
            ),
            child: Text(
              'Bracket, stats, and leaderboards have been\nupdated.',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: cs.onSurfaceVariant,
                fontSize: 13 * scale,
                height: 1.35,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// COMPLETED RESULT DATA
// ============================================================

class SportoCompletedResultData {
  final String teamA;
  final String teamARole;
  final String teamAScore;

  final String teamB;
  final String teamBRole;
  final String teamBScore;

  const SportoCompletedResultData({
    required this.teamA,
    required this.teamARole,
    required this.teamAScore,
    required this.teamB,
    required this.teamBRole,
    required this.teamBScore,
  });
}

class SportoSuperOverResultData {
  final String teamA;
  final String teamAScore;

  final String teamB;
  final String teamBScore;

  const SportoSuperOverResultData({
    required this.teamA,
    required this.teamAScore,
    required this.teamB,
    required this.teamBScore,
  });
}

// ============================================================
// COMPLETED MATCH CARD
//
// Normal:
// height ≈ 176
//
// Super Over:
// height ≈ 232
// ============================================================

class SportoCompletedMatchCard extends StatelessWidget {
  final String stage;
  final String tournament;
  final String location;

  final SportoCompletedResultData regulation;

  final SportoSuperOverResultData? superOver;

  const SportoCompletedMatchCard({
    super.key,
    this.stage = 'Quarter Final',
    this.tournament = 'Asia Cup 2026',
    this.location = 'Hyderabad',
    required this.regulation,
    this.superOver,
  });

  bool get hasSuperOver => superOver != null;

  @override
  Widget build(BuildContext context) {
    final scale = context.sportoScale;
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Container(
      width: double.infinity,
      height: (hasSuperOver ? 232 : 176) * scale,
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
            Color(0xFF21181E),
            Color(0xFF282128),
            Color(0xFF192328),
          ],
        ),
        borderRadius: BorderRadius.circular(
          20 * scale,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ==================================================
          // BADGES
          // ==================================================

          Row(
            children: [
              SportoBadge(
                text: stage,
                color: SportoScoringTokens.green,
                outlined: true,
              ),
              const Spacer(),
              Container(
                height: 20 * scale,
                padding: EdgeInsets.symmetric(
                  horizontal: 8 * scale,
                ),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: const Color(0xFF293144),
                  borderRadius: BorderRadius.circular(
                    10 * scale,
                  ),
                ),
                child: Text(
                  'Completed',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: SportoScoringTokens.blue,
                    fontSize: 11 * scale,
                    height: 1,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),

          SizedBox(
            height: 11 * scale,
          ),

          // ==================================================
          // TOURNAMENT
          // ==================================================

          Text(
            tournament,
            style: theme.textTheme.titleLarge?.copyWith(
              color: const Color(0xFFFFBC16),
              fontSize: 15 * scale,
              height: 1,
              fontWeight: FontWeight.w500,
            ),
          ),

          SizedBox(
            height: 5 * scale,
          ),

          Row(
            children: [
              Icon(
                Icons.location_on_outlined,
                size: 14 * scale,
                color: cs.onSurfaceVariant,
              ),
              SizedBox(
                width: 3 * scale,
              ),
              Text(
                location,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: cs.onSurfaceVariant,
                  fontSize: 11 * scale,
                  height: 1,
                ),
              ),
            ],
          ),

          SizedBox(
            height: 12 * scale,
          ),

          _SubmittedDashedDivider(
            color: cs.onSurfaceVariant.withValues(
              alpha: .30,
            ),
          ),

          SizedBox(
            height: 12 * scale,
          ),

          // ==================================================
          // REGULATION SCORE
          // ==================================================

          _CompletedTeamScoreRow(
            teamA: regulation.teamA,
            teamARole: regulation.teamARole,
            teamAScore: regulation.teamAScore,
            teamB: regulation.teamB,
            teamBRole: regulation.teamBRole,
            teamBScore: regulation.teamBScore,
          ),

          // ==================================================
          // SUPER OVER
          // ==================================================

          if (superOver != null) ...[
            SizedBox(
              height: 13 * scale,
            ),
            Text(
              'Super Over Innings Completed',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: cs.onSurface,
                fontSize: 13 * scale,
                height: 1,
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(
              height: 8 * scale,
            ),
            Row(
              children: [
                Expanded(
                  child: Text(
                    superOver!.teamAScore,
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: SportoScoringTokens.orange,
                      fontSize: 16 * scale,
                      height: 1,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Text(
                  'Vs',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: cs.onSurfaceVariant,
                    fontSize: 11 * scale,
                  ),
                ),
                Expanded(
                  child: Text(
                    superOver!.teamBScore,
                    textAlign: TextAlign.end,
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: cs.onSurfaceVariant,
                      fontSize: 16 * scale,
                      height: 1,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

// ============================================================
// TEAM SCORE ROW
// ============================================================

class _CompletedTeamScoreRow extends StatelessWidget {
  final String teamA;
  final String teamARole;
  final String teamAScore;

  final String teamB;
  final String teamBRole;
  final String teamBScore;

  const _CompletedTeamScoreRow({
    required this.teamA,
    required this.teamARole,
    required this.teamAScore,
    required this.teamB,
    required this.teamBRole,
    required this.teamBScore,
  });

  @override
  Widget build(BuildContext context) {
    final scale = context.sportoScale;
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                teamA,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: cs.onSurface,
                  fontSize: 13 * scale,
                  height: 1,
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(
                height: 6 * scale,
              ),
              Text(
                teamARole,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: SportoScoringTokens.green,
                  fontSize: 11 * scale,
                  height: 1,
                ),
              ),
              SizedBox(
                height: 6 * scale,
              ),
              Text(
                teamAScore,
                style: theme.textTheme.titleMedium?.copyWith(
                  color: SportoScoringTokens.orange,
                  fontSize: 16 * scale,
                  height: 1,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: EdgeInsets.only(
            top: 19 * scale,
          ),
          child: Text(
            'Vs',
            style: theme.textTheme.bodySmall?.copyWith(
              color: cs.onSurfaceVariant,
              fontSize: 11 * scale,
            ),
          ),
        ),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                teamB,
                textAlign: TextAlign.end,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: cs.onSurface,
                  fontSize: 13 * scale,
                  height: 1,
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(
                height: 6 * scale,
              ),
              Text(
                teamBRole,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: SportoScoringTokens.blue,
                  fontSize: 11 * scale,
                  height: 1,
                ),
              ),
              SizedBox(
                height: 6 * scale,
              ),
              Text(
                teamBScore,
                style: theme.textTheme.titleMedium?.copyWith(
                  color: cs.onSurfaceVariant,
                  fontSize: 16 * scale,
                  height: 1,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ============================================================
// VIEW MATCH HISTORY BUTTON
// ============================================================

class SportoViewMatchHistoryButton extends StatelessWidget {
  final VoidCallback? onTap;

  const SportoViewMatchHistoryButton({
    super.key,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final scale = context.sportoScale;
    final theme = Theme.of(context);

    return Center(
      child: Container(
        width: 270 * scale,
        height: 49 * scale,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF77D8FF),
              Color(0xFF45BDF2),
            ],
          ),
          borderRadius: BorderRadius.circular(
            14 * scale,
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF40C8FF).withValues(
                alpha: .30,
              ),
              blurRadius: 22 * scale,
              offset: Offset(
                0,
                10 * scale,
              ),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(
              14 * scale,
            ),
            child: Center(
              child: Text(
                'View Match History',
                style: theme.textTheme.titleMedium?.copyWith(
                  color: const Color(0xFF0B1C2A),
                  fontSize: 15 * scale,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ============================================================
// TIED / SUPER OVER REQUIRED BANNER
// Reference:
//
// x = 20
// width = 350
// height = 46
// ============================================================

class SportoSuperOverRequiredBanner extends StatelessWidget {
  final int teamAScore;
  final int teamBScore;

  const SportoSuperOverRequiredBanner({
    super.key,
    required this.teamAScore,
    required this.teamBScore,
  });

  @override
  Widget build(BuildContext context) {
    final scale = context.sportoScale;
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      height: 46 * scale,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFF2A1111),
            Color(0xFF321B1D),
          ],
        ),
        borderRadius: BorderRadius.circular(
          10 * scale,
        ),
        border: Border.all(
          color: const Color(0xFF7D2929),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.warning_rounded,
            color: const Color(0xFFFF565D),
            size: 18 * scale,
          ),
          SizedBox(
            width: 9 * scale,
          ),
          Text(
            'Tied $teamAScore–$teamBScore — Super Over required.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: const Color(0xFFFF5D63),
              fontSize: 13 * scale,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// DASH
// ============================================================

class _SubmittedDashedDivider extends StatelessWidget {
  final Color color;

  const _SubmittedDashedDivider({
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 1,
      width: double.infinity,
      child: CustomPaint(
        painter: _SubmittedDashPainter(
          color,
        ),
      ),
    );
  }
}

class _SubmittedDashPainter extends CustomPainter {
  final Color color;

  const _SubmittedDashPainter(
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

    double x = 0;

    while (x < size.width) {
      canvas.drawLine(
        Offset(
          x,
          0,
        ),
        Offset(
          (x + 2)
              .clamp(
                0,
                size.width,
              )
              .toDouble(),
          0,
        ),
        paint,
      );

      x += 6;
    }
  }

  @override
  bool shouldRepaint(
    covariant _SubmittedDashPainter oldDelegate,
  ) {
    return oldDelegate.color != color;
  }
}
