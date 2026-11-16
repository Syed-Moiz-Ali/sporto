import 'package:flutter/material.dart';
import 'package:referee_data/referee_data.dart';
import 'package:ui_kit/ui_kit.dart';

import 'referee_request_widgets.dart';

/// SVG icons used by the completed-match redesign screens.
///
/// The assets live in `packages/ui_kit/assets/schedule_redesign/icons/`
/// (already registered in the ui_kit pubspec).
abstract final class ScorecardRedesignIcons {
  static const _dir = 'assets/schedule_redesign/icons';

  static const back = '$_dir/back.svg';
  static const trophy = '$_dir/trophy.svg';
  static const scoreboard = '$_dir/scoreboard.svg';
  static const pin = '$_dir/pin.svg';
  static const sort = '$_dir/sort.svg';

  static const all = [back, trophy, scoreboard, pin, sort];
}

// =============================================================================
// Shared palette / gradients
// =============================================================================
const _white = Color(0xFFFFFFFF);
const _muted = Color(0xFFA0A0A0);
const _mutedAlt = Color(0xFFAAAAAA);
// The design uses #666666 for tertiary text, but that falls below WCAG AA on
// the #0D1116 table surface. #8A8A8A keeps the same visual weight while
// clearing 4.5:1 for the 12–13 px headers / dismissal lines.
const _faint = Color(0xFF8A8A8A);
const _green = Color(0xFF2BB673);
const _gold = Color(0xFFF4B41A);
const _darkText = Color(0xFF0E0C08);

const _goldGradient = LinearGradient(
  colors: [Color(0xFFED7B00), Color(0xFFCF9E24)],
);
const _skyGradient = LinearGradient(
  colors: [Color(0xFF7AD3FF), Color(0xFF4FBAF0)],
);
const _pinkGradient = LinearGradient(
  colors: [Color(0xFFFF58DD), Color(0xFFDC65AC)],
);
const _greenActionGradient = LinearGradient(
  colors: [Color(0xFF99FFA3), Color(0xFF68EE76)],
);
const _winnerCardGradient = LinearGradient(
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
  colors: [Color(0xFF173824), Color(0xFF0E2418)],
  stops: [0.0, 0.7],
);
const _ticketGradient = LinearGradient(
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
  colors: [Color(0xFF231D24), Color(0xFF1B2129), Color(0xFF211C23)],
  stops: [0.0, 0.55, 1.0],
);
const _neutralSummaryGradient = LinearGradient(
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
  colors: [Color(0xFF241D24), Color(0xFF1B2129), Color(0xFF221D23)],
  stops: [0.0, 0.55, 1.0],
);

// =============================================================================
// Header
// =============================================================================
class ScorecardRedesignHeader extends StatelessWidget {
  final double scale;
  final String title;
  final String location;
  final String dateLabel;
  final VoidCallback? onBack;

  const ScorecardRedesignHeader({
    super.key,
    required this.scale,
    required this.title,
    this.location = '',
    this.dateLabel = '',
    this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        20 * scale,
        12 * scale,
        20 * scale,
        12 * scale,
      ),
      child: Row(
        children: [
          Semantics(
            button: true,
            label: 'Back',
            excludeSemantics: true,
            child: SizedBox(
              width: 44 * scale,
              height: 44 * scale,
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  key: const ValueKey('scorecard-back'),
                  onTap: onBack,
                  borderRadius: BorderRadius.circular(12 * scale),
                  child: Center(
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
                          ScorecardRedesignIcons.back,
                          width: 6 * scale,
                          height: 12 * scale,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          SizedBox(width: 10 * scale),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 16 * scale,
                    fontWeight: FontWeight.w700,
                    color: _white,
                  ),
                ),
                if (location.isNotEmpty || dateLabel.isNotEmpty) ...[
                  SizedBox(height: 2 * scale),
                  Row(
                    children: [
                      if (location.isNotEmpty) ...[
                        Flexible(
                          child: Text(
                            'by $location',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 10 * scale,
                              fontWeight: FontWeight.w500,
                              color: _muted,
                            ),
                          ),
                        ),
                      ],
                      if (location.isNotEmpty && dateLabel.isNotEmpty)
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 6 * scale),
                          child: const _Dot(size: 3),
                        ),
                      if (dateLabel.isNotEmpty)
                        Flexible(
                          child: Text(
                            dateLabel,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 10 * scale,
                              fontWeight: FontWeight.w600,
                              color: _muted,
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// =============================================================================
// Sport / code / source / status strip
// =============================================================================
class ScorecardRedesignMetaPills extends StatelessWidget {
  final double scale;
  final String sport;
  final String code;
  final String source;
  final String status;

  const ScorecardRedesignMetaPills({
    super.key,
    required this.scale,
    this.sport = 'Cricket',
    this.code = '',
    this.source = 'by Partner',
    this.status = 'Completed',
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: 14 * scale,
        vertical: 12 * scale,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16 * scale),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0x14FF58DD), Color(0x0A7AD3FF), Color(0x0FFEBD38)],
          stops: [0.0, 0.55, 1.0],
        ),
        border: Border.all(color: const Color(0x14F3EEE2), width: 0.6),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 5,
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
                      color: _green,
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 6 * scale),
                  child: const _Dot(size: 2),
                ),
                Flexible(
                  child: Text(
                    code,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 14 * scale,
                      fontWeight: FontWeight.w500,
                      color: _faint,
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: 6 * scale),
          _MetaPill(
            scale: scale,
            label: source,
            background: const LinearGradient(
              colors: [Color(0x1AFF58DD), Color(0x1ADC65AC)],
            ),
            textGradient: _pinkGradient,
          ),
          SizedBox(width: 6 * scale),
          _MetaPill(
            scale: scale,
            label: status,
            background: const LinearGradient(
              colors: [Color(0x1A7AD3FF), Color(0x1A4FBAF0)],
            ),
            textGradient: _skyGradient,
            vertical: 4,
          ),
        ],
      ),
    );
  }
}

class _MetaPill extends StatelessWidget {
  final double scale;
  final String label;
  final Gradient background;
  final Gradient textGradient;
  final double vertical;

  const _MetaPill({
    required this.scale,
    required this.label,
    required this.background,
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
        gradient: background,
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
// Match ticket card
// =============================================================================
class ScorecardRedesignMatchCard extends StatelessWidget {
  final double scale;
  final String clock;
  final String round;
  final String status;
  final String tournament;
  final String sport;
  final String venue;
  final String squareLabel;

  /// Screen 02 uses the compact layout: round pill on the left and the
  /// scheduled time on the right. Screens 03/04 use time / round / completed.
  final bool compact;

  const ScorecardRedesignMatchCard({
    super.key,
    required this.scale,
    required this.clock,
    required this.round,
    required this.tournament,
    required this.sport,
    required this.venue,
    required this.squareLabel,
    this.status = 'Completed',
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(12 * scale),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16 * scale),
        gradient: _ticketGradient,
        border: Border.all(color: const Color(0x14F3EEE2), width: 0.6),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (compact)
            Row(
              children: [
                Flexible(child: _RoundPill(scale: scale, label: round)),
                const Spacer(),
                Flexible(
                  child: RefereeGradientText(
                    clock,
                    gradient: _skyGradient,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.right,
                    style: TextStyle(
                      fontSize: 14 * scale,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            )
          else
            Row(
              children: [
                Flexible(
                  flex: 3,
                  child: RefereeGradientText(
                    clock,
                    gradient: _skyGradient,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 14 * scale,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                SizedBox(width: 8 * scale),
                Flexible(
                  flex: 4,
                  child: Text(
                    round,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 12 * scale,
                      fontWeight: FontWeight.w500,
                      color: _green,
                    ),
                  ),
                ),
                SizedBox(width: 8 * scale),
                if (status.isNotEmpty)
                  Flexible(
                    flex: 4,
                    child: _SkyPill(scale: scale, label: status),
                  ),
              ],
            ),
          SizedBox(height: 10 * scale),
          Row(
            children: [
              Container(
                width: 36 * scale,
                height: 36 * scale,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: const Color(0x1A28A166),
                  borderRadius: BorderRadius.circular(10 * scale),
                ),
                child: Text(
                  squareLabel,
                  maxLines: 1,
                  style: TextStyle(
                    fontSize: 16 * scale,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF28A166),
                  ),
                ),
              ),
              SizedBox(width: 8 * scale),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      tournament,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 12 * scale,
                        fontWeight: FontWeight.w500,
                        color: _white,
                      ),
                    ),
                    SizedBox(height: 2 * scale),
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            sport,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 12 * scale,
                              fontWeight: FontWeight.w500,
                              color: _gold,
                            ),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 6 * scale),
                          child: const _Dot(size: 3),
                        ),
                        SportoSvgIcon(
                          ScorecardRedesignIcons.pin,
                          width: 8 * scale,
                          height: 14 * scale,
                        ),
                        SizedBox(width: 4 * scale),
                        Flexible(
                          child: RefereeGradientText(
                            venue,
                            gradient: _skyGradient,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 12 * scale,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _RoundPill extends StatelessWidget {
  final double scale;
  final String label;

  const _RoundPill({required this.scale, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: 6 * scale,
        vertical: 2 * scale,
      ),
      decoration: BoxDecoration(
        color: const Color(0x3301A34D),
        borderRadius: BorderRadius.circular(10 * scale),
        border: Border.all(color: _green, width: 0.8),
      ),
      child: Text(
        label,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          fontSize: 12 * scale,
          fontWeight: FontWeight.w600,
          color: _white,
          height: 1.2,
        ),
      ),
    );
  }
}

class _SkyPill extends StatelessWidget {
  final double scale;
  final String label;

  const _SkyPill({required this.scale, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: 10 * scale,
        vertical: 5 * scale,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(80 * scale),
        gradient: const LinearGradient(
          colors: [Color(0x1A7AD3FF), Color(0x1A4FBAF0)],
        ),
        border: Border.all(color: const Color(0x337AD3FF), width: 0.5),
      ),
      child: RefereeGradientText(
        label,
        gradient: _skyGradient,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        textAlign: TextAlign.center,
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
// Winner tile + scoreboard action
// =============================================================================
class ScorecardRedesignWinnerPill extends StatelessWidget {
  final double scale;
  final String winner;
  final String? subtitle;
  final String label;

  const ScorecardRedesignWinnerPill({
    super.key,
    required this.scale,
    required this.winner,
    this.subtitle,
    this.label = 'Winner',
  });

  @override
  Widget build(BuildContext context) {
    final title =
        (subtitle == null || subtitle!.trim().isEmpty) ? winner : subtitle!;
    return Semantics(
      label: '$label: $title',
      excludeSemantics: true,
      child: _WinnerSurface(
        scale: scale,
        radius: 14,
        padding: EdgeInsets.all(6 * scale),
        child: Row(
          children: [
            SportoSvgIcon(
              ScorecardRedesignIcons.trophy,
              width: 30 * scale,
              height: 30 * scale,
            ),
            SizedBox(width: 8 * scale),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  RefereeGradientText(
                    label,
                    gradient: _goldGradient,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 10 * scale,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 12 * scale,
                      fontWeight: FontWeight.w600,
                      color: _white,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ScorecardRedesignViewScoreboardButton extends StatelessWidget {
  final double scale;
  final VoidCallback? onTap;
  final String label;

  const ScorecardRedesignViewScoreboardButton({
    super.key,
    required this.scale,
    this.onTap,
    this.label = 'View Full Scoreboard',
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: label,
      excludeSemantics: true,
      child: SizedBox(
        height: 44 * scale,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            key: const ValueKey('view-full-scoreboard'),
            onTap: onTap,
            borderRadius: BorderRadius.circular(14 * scale),
            child: Ink(
              decoration: BoxDecoration(
                gradient: _greenActionGradient,
                borderRadius: BorderRadius.circular(14 * scale),
              ),
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 14 * scale),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SportoSvgIcon(
                      ScorecardRedesignIcons.scoreboard,
                      width: 20 * scale,
                      height: 20 * scale,
                    ),
                    SizedBox(width: 6 * scale),
                    Flexible(
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.centerLeft,
                        child: Text(
                          label,
                          maxLines: 1,
                          style: TextStyle(
                            fontSize: 14 * scale,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF090C10),
                          ),
                        ),
                      ),
                    ),
                  ],
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
// Match summary card
// =============================================================================
class ScorecardRedesignSuperOverRow {
  final String leftScore;
  final String rightScore;

  const ScorecardRedesignSuperOverRow({
    required this.leftScore,
    required this.rightScore,
  });
}

class ScorecardRedesignMatchSummaryCard extends StatelessWidget {
  final double scale;
  final String leftTeam;
  final String leftScore;
  final String rightTeam;
  final String rightScore;
  final List<ScorecardRedesignSuperOverRow> superOvers;
  final String dateLine;
  final String? winnerName;
  final String? winnerSubtitle;
  final bool showWinner;

  const ScorecardRedesignMatchSummaryCard({
    super.key,
    required this.scale,
    required this.leftTeam,
    required this.leftScore,
    required this.rightTeam,
    required this.rightScore,
    this.superOvers = const [],
    this.dateLine = '',
    this.winnerName,
    this.winnerSubtitle,
    this.showWinner = false,
  });

  @override
  Widget build(BuildContext context) {
    final winner = winnerName?.trim();
    final hasWinner = showWinner && winner != null && winner.isNotEmpty;

    final content = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: _SummaryTeam(
                scale: scale,
                name: leftTeam,
                score: leftScore,
                gold: true,
                end: false,
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 8 * scale),
              child: Text(
                'Vs',
                style: TextStyle(
                  fontSize: 12 * scale,
                  fontWeight: FontWeight.w700,
                  color: _mutedAlt,
                ),
              ),
            ),
            Expanded(
              child: _SummaryTeam(
                scale: scale,
                name: rightTeam,
                score: rightScore,
                gold: false,
                end: true,
              ),
            ),
          ],
        ),
        if (superOvers.isNotEmpty) ...[
          SizedBox(height: 10 * scale),
          Text(
            'Super Over Innings Completed',
            style: TextStyle(
              fontSize: 14 * scale,
              fontWeight: FontWeight.w500,
              color: _white,
            ),
          ),
          SizedBox(height: 4 * scale),
          for (final row in superOvers)
            Padding(
              padding: EdgeInsets.only(top: 2 * scale),
              child: Row(
                children: [
                  Expanded(
                    child: RefereeGradientText(
                      row.leftScore,
                      gradient: _goldGradient,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 16 * scale,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8 * scale),
                    child: Text(
                      'Vs',
                      style: TextStyle(
                        fontSize: 12 * scale,
                        fontWeight: FontWeight.w700,
                        color: _mutedAlt,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      row.rightScore,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.right,
                      style: TextStyle(
                        fontSize: 16 * scale,
                        fontWeight: FontWeight.w600,
                        color: _muted,
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
        if (dateLine.isNotEmpty) ...[
          SizedBox(height: 10 * scale),
          Container(height: 0.8 * scale, color: const Color(0x2EF3EEE2)),
          SizedBox(height: 8 * scale),
          Text(
            dateLine,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 12 * scale,
              fontWeight: FontWeight.w500,
              color: _muted,
            ),
          ),
        ],
        if (hasWinner) ...[
          SizedBox(height: 10 * scale),
          ScorecardRedesignWinnerPill(
            scale: scale,
            winner: winner,
            subtitle: winnerSubtitle,
          ),
        ],
      ],
    );

    if (hasWinner) {
      return _WinnerSurface(
        scale: scale,
        radius: 20,
        padding: EdgeInsets.all(14 * scale),
        child: content,
      );
    }

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(14 * scale),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20 * scale),
        gradient: _neutralSummaryGradient,
        border: Border.all(color: const Color(0x14F3EEE2), width: 0.6),
      ),
      child: content,
    );
  }
}

class _SummaryTeam extends StatelessWidget {
  final double scale;
  final String name;
  final String score;
  final bool gold;
  final bool end;

  const _SummaryTeam({
    required this.scale,
    required this.name,
    required this.score,
    required this.gold,
    required this.end,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment:
          end ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        Text(
          name,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          textAlign: end ? TextAlign.right : TextAlign.left,
          style: TextStyle(
            fontSize: 14 * scale,
            fontWeight: FontWeight.w500,
            color: _white,
          ),
        ),
        SizedBox(height: 2 * scale),
        if (gold)
          RefereeGradientText(
            score,
            gradient: _goldGradient,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 16 * scale,
              fontWeight: FontWeight.w600,
            ),
          )
        else
          Text(
            score,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.right,
            style: TextStyle(
              fontSize: 16 * scale,
              fontWeight: FontWeight.w600,
              color: _muted,
            ),
          ),
      ],
    );
  }
}

// =============================================================================
// Team toggles
// =============================================================================
class ScorecardRedesignTeamPillData {
  final int id;
  final String name;

  const ScorecardRedesignTeamPillData({required this.id, required this.name});
}

class ScorecardRedesignTeamToggles extends StatelessWidget {
  final double scale;
  final List<ScorecardRedesignTeamPillData> teams;
  final int? selectedId;
  final ValueChanged<int> onSelected;

  const ScorecardRedesignTeamToggles({
    super.key,
    required this.scale,
    required this.teams,
    required this.selectedId,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    if (teams.isEmpty) return const SizedBox.shrink();

    if (teams.length <= 2) {
      return Row(
        children: [
          for (var i = 0; i < teams.length; i++) ...[
            if (i > 0) SizedBox(width: 10 * scale),
            Expanded(
              child: _TeamToggle(
                scale: scale,
                team: teams[i],
                selected: teams[i].id == selectedId,
                onTap: () => onSelected(teams[i].id),
              ),
            ),
          ],
        ],
      );
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          for (var i = 0; i < teams.length; i++) ...[
            if (i > 0) SizedBox(width: 10 * scale),
            SizedBox(
              width: 170 * scale,
              child: _TeamToggle(
                scale: scale,
                team: teams[i],
                selected: teams[i].id == selectedId,
                onTap: () => onSelected(teams[i].id),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _TeamToggle extends StatelessWidget {
  final double scale;
  final ScorecardRedesignTeamPillData team;
  final bool selected;
  final VoidCallback onTap;

  const _TeamToggle({
    required this.scale,
    required this.team,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: selected,
      label: 'Show ${team.name} scorecard',
      excludeSemantics: true,
      child: SizedBox(
        height: 44 * scale,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            key: ValueKey('scorecard-team-toggle-${team.id}'),
            onTap: onTap,
            borderRadius: BorderRadius.circular(12 * scale),
            child: Center(
              child: Container(
                height: 34 * scale,
                width: double.infinity,
                alignment: Alignment.center,
                padding: EdgeInsets.symmetric(horizontal: 16 * scale),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12 * scale),
                  gradient: selected ? _goldGradient : null,
                  color: selected ? null : const Color(0xFF1B2335),
                  border: Border.all(
                    color: selected
                        ? const Color(0x33FFFFFF)
                        : const Color(0x1AFFFFFF),
                    width: 0.5,
                  ),
                ),
                child: Text(
                  team.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14 * scale,
                    fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                    color: selected ? _darkText : _white,
                  ),
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
// Innings heading + tables
// =============================================================================
class ScorecardRedesignSectionLabel extends StatelessWidget {
  final double scale;
  final String text;

  const ScorecardRedesignSectionLabel({
    super.key,
    required this.scale,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return RefereeGradientText(
      text,
      gradient: _skyGradient,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: TextStyle(fontSize: 14 * scale, fontWeight: FontWeight.w500),
    );
  }
}

class ScorecardRedesignInningsHeader extends StatelessWidget {
  final double scale;
  final String scoreLine;
  final String battingLabel;

  const ScorecardRedesignInningsHeader({
    super.key,
    required this.scale,
    required this.scoreLine,
    this.battingLabel = 'Batting',
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          scoreLine,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: 16 * scale,
            fontWeight: FontWeight.w600,
            color: _white,
          ),
        ),
        SizedBox(height: 2 * scale),
        ScorecardRedesignSectionLabel(scale: scale, text: battingLabel),
      ],
    );
  }
}

class ScorecardRedesignBattingTable extends StatelessWidget {
  final double scale;
  final RefereeScorecardInnings innings;

  const ScorecardRedesignBattingTable({
    super.key,
    required this.scale,
    required this.innings,
  });

  static const _numWidth = 20.0;
  static const _srWidth = 30.0;
  static const _gap = 10.0;

  @override
  Widget build(BuildContext context) {
    final batting = innings.batting;
    final extras = scorecardExtrasText(innings.totals);
    final total = innings.totals.scoreText;
    final overs = scorecardOversText(innings.totals);
    final runRate = scorecardRunRateText(innings.totals);
    final fall = scorecardFallOfWicketsText(innings);

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0x991B2335),
        borderRadius: BorderRadius.circular(16 * scale),
        border: Border.all(color: const Color(0x4D7BD0FA), width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: EdgeInsets.fromLTRB(
              14 * scale,
              14 * scale,
              14 * scale,
              12 * scale,
            ),
            decoration: BoxDecoration(
              color: const Color(0xFF0D1116),
              borderRadius: BorderRadius.circular(16 * scale),
              border: Border.all(color: const Color(0x1AFFFFFF), width: 0.5),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _headerRow(),
                if (batting.isEmpty)
                  Padding(
                    padding: EdgeInsets.only(top: 14 * scale),
                    child: Text(
                      'Batting figures are not available for this innings.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 13 * scale,
                        fontWeight: FontWeight.w500,
                        color: _muted,
                      ),
                    ),
                  )
                else
                  for (var i = 0; i < batting.length; i++)
                    _battingRow(batting[i], highlight: i == 0),
                SizedBox(height: 8 * scale),
                Container(height: 0.8 * scale, color: const Color(0xFF283040)),
                SizedBox(height: 8 * scale),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Extras',
                        style: TextStyle(
                          fontSize: 14 * scale,
                          fontWeight: FontWeight.w400,
                          color: _muted,
                        ),
                      ),
                    ),
                    Text(
                      extras,
                      maxLines: 1,
                      style: TextStyle(
                        fontSize: 14 * scale,
                        fontWeight: FontWeight.w400,
                        color: _white,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(
              14 * scale,
              10 * scale,
              14 * scale,
              10 * scale,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Total ($overs ov, RR $runRate)',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 15 * scale,
                          fontWeight: FontWeight.w600,
                          color: _white,
                        ),
                      ),
                    ),
                    SizedBox(width: 8 * scale),
                    Text(
                      total,
                      maxLines: 1,
                      style: TextStyle(
                        fontSize: 15 * scale,
                        fontWeight: FontWeight.w600,
                        color: _white,
                      ),
                    ),
                  ],
                ),
                if (fall.isNotEmpty) ...[
                  SizedBox(height: 8 * scale),
                  Container(
                    height: 0.8 * scale,
                    color: const Color(0xFF283040),
                  ),
                  SizedBox(height: 8 * scale),
                  Text(
                    fall,
                    style: TextStyle(
                      fontSize: 12 * scale,
                      fontWeight: FontWeight.w400,
                      color: _muted,
                      height: 1.35,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _headerRow() {
    return Row(
      children: [
        Expanded(
          child: Text(
            'Batter',
            style: TextStyle(
              fontSize: 12 * scale,
              fontWeight: FontWeight.w500,
              color: _faint,
            ),
          ),
        ),
        SizedBox(width: _gap * scale),
        for (final label in const ['R', 'B', '4s', '6s']) ...[
          SizedBox(
            width: _numWidth * scale,
            child: Text(
              label,
              textAlign: TextAlign.right,
              style: TextStyle(
                fontSize: 12 * scale,
                fontWeight: FontWeight.w400,
                color: _muted,
              ),
            ),
          ),
          SizedBox(width: _gap * scale),
        ],
        SizedBox(
          width: _srWidth * scale,
          child: Text(
            'SR',
            textAlign: TextAlign.right,
            style: TextStyle(
              fontSize: 12 * scale,
              fontWeight: FontWeight.w400,
              color: _muted,
            ),
          ),
        ),
      ],
    );
  }

  Widget _battingRow(RefereeScorecardBatting bat, {required bool highlight}) {
    final secondary = (bat.dismissal?.trim().isNotEmpty == true)
        ? bat.dismissal!.trim()
        : (bat.status?.trim() ?? '');
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4 * scale),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  bat.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 14 * scale,
                    fontWeight: FontWeight.w600,
                    color: highlight ? _green : _white,
                  ),
                ),
                if (secondary.isNotEmpty)
                  Text(
                    secondary,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 13 * scale,
                      fontWeight: FontWeight.w500,
                      color: _faint,
                    ),
                  ),
              ],
            ),
          ),
          SizedBox(width: _gap * scale),
          _number('${bat.runs}'),
          SizedBox(width: _gap * scale),
          _number('${bat.ballsFaced}'),
          SizedBox(width: _gap * scale),
          _number('${bat.fours}'),
          SizedBox(width: _gap * scale),
          _number('${bat.sixes}'),
          SizedBox(width: _gap * scale),
          SizedBox(
            width: _srWidth * scale,
            child: Text(
              scorecardStrikeRate(bat),
              maxLines: 1,
              textAlign: TextAlign.right,
              style: TextStyle(
                fontSize: 14 * scale,
                fontWeight: FontWeight.w600,
                color: _white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _number(String value) {
    return SizedBox(
      width: _numWidth * scale,
      child: Text(
        value,
        maxLines: 1,
        textAlign: TextAlign.right,
        style: TextStyle(
          fontSize: 14 * scale,
          fontWeight: FontWeight.w500,
          color: _white,
        ),
      ),
    );
  }
}

class ScorecardRedesignBowlingTable extends StatelessWidget {
  final double scale;
  final RefereeScorecardInnings innings;

  const ScorecardRedesignBowlingTable({
    super.key,
    required this.scale,
    required this.innings,
  });

  static const _numWidth = 20.0;
  static const _econWidth = 30.0;
  static const _gap = 10.0;

  @override
  Widget build(BuildContext context) {
    final bowling = innings.bowling;
    final extras = scorecardExtrasTotalText(innings.totals);

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(14 * scale),
      decoration: BoxDecoration(
        color: const Color(0x8012161C),
        borderRadius: BorderRadius.circular(16 * scale),
        border: Border.all(color: const Color(0x1AFFFFFF), width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _headerRow(),
          if (bowling.isEmpty)
            Padding(
              padding: EdgeInsets.only(top: 14 * scale),
              child: Text(
                'Bowling figures are not available for this innings.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13 * scale,
                  fontWeight: FontWeight.w500,
                  color: _muted,
                ),
              ),
            )
          else
            for (final bowl in bowling) _bowlingRow(bowl),
          if (bowling.isNotEmpty && extras != '0') ...[
            SizedBox(height: 8 * scale),
            Container(height: 0.8 * scale, color: const Color(0xFF283040)),
            SizedBox(height: 8 * scale),
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Extras',
                    style: TextStyle(
                      fontSize: 14 * scale,
                      fontWeight: FontWeight.w400,
                      color: _muted,
                    ),
                  ),
                ),
                SizedBox(
                  width: _econWidth * scale,
                  child: Text(
                    extras,
                    maxLines: 1,
                    textAlign: TextAlign.right,
                    style: TextStyle(
                      fontSize: 14 * scale,
                      fontWeight: FontWeight.w400,
                      color: _muted,
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

  Widget _headerRow() {
    return Row(
      children: [
        Expanded(
          child: Text(
            'Bowler',
            style: TextStyle(
              fontSize: 12 * scale,
              fontWeight: FontWeight.w500,
              color: _faint,
            ),
          ),
        ),
        SizedBox(width: _gap * scale),
        for (final label in const ['O', 'M', 'R', 'W']) ...[
          SizedBox(
            width: _numWidth * scale,
            child: Text(
              label,
              textAlign: TextAlign.right,
              style: TextStyle(
                fontSize: 12 * scale,
                fontWeight: FontWeight.w400,
                color: _muted,
              ),
            ),
          ),
          SizedBox(width: _gap * scale),
        ],
        SizedBox(
          width: _econWidth * scale,
          child: Text(
            'Econ',
            textAlign: TextAlign.right,
            style: TextStyle(
              fontSize: 12 * scale,
              fontWeight: FontWeight.w400,
              color: _muted,
            ),
          ),
        ),
      ],
    );
  }

  Widget _bowlingRow(RefereeScorecardBowling bowl) {
    return Padding(
      padding: EdgeInsets.only(top: 10 * scale),
      child: Row(
        children: [
          Expanded(
            child: Text(
              bowl.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 14 * scale,
                fontWeight: FontWeight.w600,
                color: _white,
              ),
            ),
          ),
          SizedBox(width: _gap * scale),
          _number(scorecardBowlerOvers(bowl)),
          SizedBox(width: _gap * scale),
          _number('${bowl.maidens}'),
          SizedBox(width: _gap * scale),
          _number('${bowl.runsConceded}'),
          SizedBox(width: _gap * scale),
          _number('${bowl.wickets}'),
          SizedBox(width: _gap * scale),
          SizedBox(
            width: _econWidth * scale,
            child: Text(
              scorecardEconomy(bowl),
              maxLines: 1,
              textAlign: TextAlign.right,
              style: TextStyle(
                fontSize: 14 * scale,
                fontWeight: FontWeight.w600,
                color: _white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _number(String value) {
    return SizedBox(
      width: _numWidth * scale,
      child: Text(
        value,
        maxLines: 1,
        textAlign: TextAlign.right,
        style: TextStyle(
          fontSize: 14 * scale,
          fontWeight: FontWeight.w500,
          color: _white,
        ),
      ),
    );
  }
}

// =============================================================================
// Player of the match
// =============================================================================
class ScorecardRedesignPlayerOfMatchCard extends StatelessWidget {
  final double scale;
  final String name;
  final int? runs;
  final int? wickets;

  const ScorecardRedesignPlayerOfMatchCard({
    super.key,
    required this.scale,
    required this.name,
    this.runs,
    this.wickets,
  });

  @override
  Widget build(BuildContext context) {
    final hasRuns = runs != null;
    final hasWickets = wickets != null;
    final stats = [
      if (hasRuns) '$runs runs',
      if (hasWickets) '$wickets wickets',
    ].join('  ·  ');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ScorecardRedesignSectionLabel(
          scale: scale,
          text: 'Player of the Match',
        ),
        SizedBox(height: 8 * scale),
        Semantics(
          label: stats.isEmpty
              ? 'Player of the Match: $name'
              : 'Player of the Match: $name, $stats',
          excludeSemantics: true,
          child: _WinnerSurface(
            scale: scale,
            radius: 14,
            padding: EdgeInsets.fromLTRB(
              8 * scale,
              6 * scale,
              10 * scale,
              6 * scale,
            ),
            child: Row(
              children: [
                SportoSvgIcon(
                  ScorecardRedesignIcons.trophy,
                  width: 30 * scale,
                  height: 30 * scale,
                ),
                SizedBox(width: 8 * scale),
                Expanded(
                  child: Text(
                    name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 12 * scale,
                      fontWeight: FontWeight.w600,
                      color: _white,
                    ),
                  ),
                ),
                if (stats.isNotEmpty) ...[
                  SizedBox(width: 8 * scale),
                  Flexible(
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerRight,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (hasRuns)
                            Text(
                              '$runs runs',
                              maxLines: 1,
                              style: TextStyle(
                                fontSize: 12 * scale,
                                fontWeight: FontWeight.w600,
                                color: _white,
                              ),
                            ),
                          if (hasRuns && hasWickets)
                            Padding(
                              padding:
                                  EdgeInsets.symmetric(horizontal: 6 * scale),
                              child: const _Dot(size: 3),
                            ),
                          if (hasWickets)
                            Text(
                              '$wickets wickets',
                              maxLines: 1,
                              style: TextStyle(
                                fontSize: 12 * scale,
                                fontWeight: FontWeight.w600,
                                color: _white,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// =============================================================================
// Empty / error / loading
// =============================================================================
class ScorecardRedesignEmptyCard extends StatelessWidget {
  final double scale;
  final String message;
  final IconData icon;

  const ScorecardRedesignEmptyCard({
    super.key,
    required this.scale,
    required this.message,
    this.icon = Icons.scoreboard_outlined,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: 20 * scale,
        vertical: 32 * scale,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFF12161C),
        borderRadius: BorderRadius.circular(16 * scale),
        border: Border.all(color: const Color(0x1AFFFFFF), width: 0.5),
      ),
      child: Column(
        children: [
          Icon(icon, size: 32 * scale, color: _faint),
          SizedBox(height: 10 * scale),
          Text(
            message,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13 * scale,
              fontWeight: FontWeight.w500,
              color: _muted,
              height: 1.35,
            ),
          ),
        ],
      ),
    );
  }
}

class ScorecardRedesignErrorCard extends StatelessWidget {
  final double scale;
  final String message;
  final VoidCallback onRetry;

  const ScorecardRedesignErrorCard({
    super.key,
    required this.scale,
    required this.message,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(24 * scale),
      decoration: BoxDecoration(
        color: const Color(0xFF12161C),
        borderRadius: BorderRadius.circular(16 * scale),
        border: Border.all(color: const Color(0x33FE464B), width: 0.6),
      ),
      child: Column(
        children: [
          Icon(
            Icons.error_outline_rounded,
            color: const Color(0xFFFE464B),
            size: 32 * scale,
          ),
          SizedBox(height: 10 * scale),
          Text(
            'Unable to load scorecard',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16 * scale,
              fontWeight: FontWeight.w600,
              color: _white,
            ),
          ),
          SizedBox(height: 6 * scale),
          Text(
            message.trim().isEmpty ? 'Please try again.' : message,
            textAlign: TextAlign.center,
            maxLines: 4,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 12 * scale,
              fontWeight: FontWeight.w500,
              color: _muted,
              height: 1.35,
            ),
          ),
          SizedBox(height: 16 * scale),
          FilledButton(
            key: const ValueKey('scorecard-retry'),
            onPressed: onRetry,
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }
}

class ScorecardRedesignSkeleton extends StatelessWidget {
  final double scale;
  final bool showPills;

  const ScorecardRedesignSkeleton({
    super.key,
    required this.scale,
    this.showPills = true,
  });

  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: const NeverScrollableScrollPhysics(),
      padding: EdgeInsets.fromLTRB(
        20 * scale,
        20 * scale,
        20 * scale,
        40 * scale,
      ),
      children: [
        if (showPills) ...[
          SportoShimmer(height: 47 * scale, borderRadius: 16 * scale),
          SizedBox(height: 20 * scale),
        ],
        SportoShimmer(height: 95 * scale, borderRadius: 16 * scale),
        SizedBox(height: 20 * scale),
        SportoShimmer(height: 120 * scale, borderRadius: 20 * scale),
        SizedBox(height: 20 * scale),
        Row(
          children: [
            Expanded(
              child:
                  SportoShimmer(height: 44 * scale, borderRadius: 12 * scale),
            ),
            SizedBox(width: 10 * scale),
            Expanded(
              child:
                  SportoShimmer(height: 44 * scale, borderRadius: 12 * scale),
            ),
          ],
        ),
        SizedBox(height: 20 * scale),
        SportoShimmer(height: 300 * scale, borderRadius: 16 * scale),
      ],
    );
  }
}

// =============================================================================
// Small shared decorations
// =============================================================================
class _Dot extends StatelessWidget {
  final double size;

  const _Dot({required this.size});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        color: _faint,
      ),
    );
  }
}

class _WinnerSurface extends StatelessWidget {
  final double scale;
  final double radius;
  final EdgeInsetsGeometry padding;
  final Widget child;

  const _WinnerSurface({
    required this.scale,
    required this.radius,
    required this.padding,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(radius * scale),
      child: Stack(
        children: [
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: _winnerCardGradient,
                border: Border.all(
                  color: const Color(0x14F3EEE2),
                  width: 0.5,
                ),
              ),
            ),
          ),
          Positioned(
            top: -18 * scale,
            right: -12 * scale,
            width: 90 * scale,
            height: 90 * scale,
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
            bottom: -26 * scale,
            left: -18 * scale,
            width: 100 * scale,
            height: 100 * scale,
            child: DecoratedBox(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    const Color(0xFFE1263F).withValues(alpha: 0.22),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          Padding(padding: padding, child: child),
        ],
      ),
    );
  }
}

// =============================================================================
// Scorecard data mapping helpers
// =============================================================================
const _months = [
  'Jan',
  'Feb',
  'Mar',
  'Apr',
  'May',
  'Jun',
  'Jul',
  'Aug',
  'Sep',
  'Oct',
  'Nov',
  'Dec',
];
const _weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

/// "20.0" – always one decimal; falls back to legal balls when the API omits
/// the formatted overs string.
String scorecardOversText(RefereeScorecardTotals totals) {
  final overs = totals.overs?.trim();
  if (overs != null && overs.isNotEmpty) {
    final parsed = double.tryParse(overs);
    if (parsed != null) return parsed.toStringAsFixed(1);
    return overs;
  }
  if (totals.legalBalls > 0) {
    return _ballsToOvers(totals.legalBalls);
  }
  return '0.0';
}

/// Formats legal balls using cricket notation (`121` balls -> `20.1`).
String _ballsToOvers(int legalBalls) {
  return '${legalBalls ~/ 6}.${legalBalls % 6}';
}

/// "20" – used by the innings heading ("168/6 (20 overs)").
String scorecardOversShort(RefereeScorecardTotals totals) {
  final text = scorecardOversText(totals);
  final parsed = double.tryParse(text);
  if (parsed == null) return text;
  if (parsed == parsed.roundToDouble()) return '${parsed.round()}';
  return text;
}

String scorecardRunRateText(RefereeScorecardTotals totals) {
  final overs = totals.legalBalls > 0
      ? totals.legalBalls / 6
      : _oversToDecimal(totals.overs);
  if (overs <= 0) return '0.00';
  return (totals.runs / overs).toStringAsFixed(2);
}

/// Converts cricket overs notation (`20.2` = 20 overs and 2 balls) to a
/// decimal overs value used for run-rate and economy calculations.
double _oversToDecimal(String? overs) {
  final text = overs?.trim() ?? '';
  if (text.isEmpty) return 0;
  final parts = text.split('.');
  final whole = int.tryParse(parts.first) ?? 0;
  final balls = parts.length > 1 ? (int.tryParse(parts[1]) ?? 0) : 0;
  return whole + balls / 6;
}

int _extrasNumber(Object? value) {
  if (value is num) return value.toInt();
  return int.tryParse(value?.toString() ?? '') ?? 0;
}

String? _extrasLabel(String key) {
  switch (key.toLowerCase()) {
    case 'b':
    case 'byes':
      return 'b';
    case 'lb':
    case 'leg_byes':
    case 'legbyes':
      return 'lb';
    case 'w':
    case 'wd':
    case 'wide':
    case 'wides':
      return 'w';
    case 'nb':
    case 'no_ball':
    case 'no_balls':
    case 'noballs':
      return 'nb';
  }
  return null;
}

/// "2 (b 1, w 1)" – extras total plus a compact breakdown.
String scorecardExtrasText(RefereeScorecardTotals totals) {
  final extras = totals.extras;
  if (extras.isEmpty) return '0';

  final explicit = _extrasNumber(extras['total'] ?? extras['extras']);
  final parts = <String>[];
  var computed = 0;
  extras.forEach((key, value) {
    final lower = key.toLowerCase();
    if (lower == 'total' || lower == 'extras') return;
    final number = _extrasNumber(value);
    if (number <= 0) return;
    computed += number;
    final label = _extrasLabel(key) ?? lower;
    parts.add('$label $number');
  });

  final total = explicit > 0 ? explicit : computed;
  if (parts.isEmpty) return '$total';
  return '$total (${parts.join(', ')})';
}

/// Total extras only (used by the bowling table footer).
String scorecardExtrasTotalText(RefereeScorecardTotals totals) {
  final extras = totals.extras;
  if (extras.isEmpty) return '0';
  final explicit = _extrasNumber(extras['total'] ?? extras['extras']);
  if (explicit > 0) return '$explicit';
  var total = 0;
  extras.forEach((key, value) {
    final lower = key.toLowerCase();
    if (lower == 'total' || lower == 'extras') return;
    total += _extrasNumber(value);
  });
  return '$total';
}

String scorecardFallOfWicketsText(RefereeScorecardInnings innings) {
  if (innings.fallOfWickets.isEmpty) return '';
  final parts = innings.fallOfWickets.map((fall) {
    final score = fall.score?.trim();
    return '${fall.wicketNumber}-${score == null || score.isEmpty ? '?' : score}';
  }).join(', ');
  return 'Fall of wickets: $parts';
}

String scorecardStrikeRate(RefereeScorecardBatting batting) {
  final direct = batting.strikeRate?.trim();
  if (direct != null && direct.isNotEmpty) {
    final parsed = double.tryParse(direct);
    if (parsed == null) return direct;
    if (parsed == parsed.roundToDouble()) return '${parsed.round()}';
    return parsed.toStringAsFixed(2);
  }
  if (batting.ballsFaced <= 0) return '0';
  return '${(batting.runs / batting.ballsFaced * 100).round()}';
}

String scorecardBowlerOvers(RefereeScorecardBowling bowling) {
  final direct = bowling.overs?.trim();
  if (direct != null && direct.isNotEmpty) {
    final parsed = double.tryParse(direct);
    if (parsed != null) return parsed.toStringAsFixed(1);
    return direct;
  }
  if (bowling.legalBalls > 0) {
    return _ballsToOvers(bowling.legalBalls);
  }
  return '0.0';
}

String scorecardEconomy(RefereeScorecardBowling bowling) {
  final direct = bowling.economyRate?.trim();
  if (direct != null && direct.isNotEmpty) {
    final parsed = double.tryParse(direct);
    if (parsed == null) return direct;
    return parsed.toStringAsFixed(2);
  }
  final overs = bowling.legalBalls > 0
      ? bowling.legalBalls / 6
      : _oversToDecimal(scorecardBowlerOvers(bowling));
  if (overs <= 0) return '0.00';
  return (bowling.runsConceded / overs).toStringAsFixed(2);
}

String scorecardTeamInitials(String name) {
  final words = name
      .trim()
      .split(RegExp(r'\s+'))
      .where((word) => word.isNotEmpty)
      .toList();
  if (words.isEmpty) return '?';
  if (words.length == 1) {
    final word = words.first;
    return word.length >= 2
        ? word.substring(0, 2).toUpperCase()
        : word.toUpperCase();
  }
  return '${words[0][0]}${words[1][0]}'.toUpperCase();
}

DateTime? _matchDateTime(RefereeMatchResponse? match) {
  if (match == null) return null;
  final scheduled = DateTime.tryParse(match.scheduledAt ?? '');
  if (scheduled != null) return scheduled.toLocal();

  final date = match.matchDate?.trim();
  if (date == null || date.isEmpty) return null;
  final time = match.startTime?.trim();
  if (time != null && time.isNotEmpty) {
    final combined = DateTime.tryParse('${date}T$time');
    if (combined != null) return combined;
  }
  return DateTime.tryParse(date);
}

String _time12(DateTime date) {
  final hour = date.hour % 12 == 0 ? 12 : date.hour % 12;
  final minute = date.minute.toString().padLeft(2, '0');
  final period = date.hour >= 12 ? 'PM' : 'AM';
  return '$hour:$minute $period';
}

String scorecardClockText(RefereeMatchResponse? match) {
  final direct = match?.startTime?.trim();
  if (direct != null && direct.isNotEmpty) {
    final upper = direct.toUpperCase();
    if (upper.contains('AM') || upper.contains('PM')) return direct;
    final parsed = DateTime.tryParse('2000-01-01T$direct');
    if (parsed != null) return _time12(parsed);
    return direct;
  }
  final scheduled = DateTime.tryParse(match?.scheduledAt ?? '');
  if (scheduled != null) return _time12(scheduled.toLocal());
  return '--:--';
}

String scorecardDateMeta(RefereeMatchResponse? match) {
  final date = _matchDateTime(match);
  if (date == null) return match?.matchDate?.trim() ?? '';
  final base = '${date.day} ${_months[date.month - 1]}';
  final now = DateTime.now();
  final isToday =
      date.year == now.year && date.month == now.month && date.day == now.day;
  if (isToday) return '$base Today';
  final tomorrow = DateTime(now.year, now.month, now.day + 1);
  if (date.year == tomorrow.year &&
      date.month == tomorrow.month &&
      date.day == tomorrow.day) {
    return '$base Tomorrow';
  }
  return base;
}

String scorecardVenueLine(
  RefereeMatchResponse? match, {
  RefereeScorecardResponse? scorecard,
}) {
  final parts = <String>[];
  final date = _matchDateTime(match);
  if (date != null) {
    parts.add(
      '${_weekdays[date.weekday - 1]}, ${date.day} ${_months[date.month - 1]}',
    );
  }
  final venue = scorecardMatchVenue(match, scorecard: scorecard);
  if (venue.isNotEmpty && venue != 'Venue not set') parts.add(venue);
  return parts.join(' \u00B7 ');
}

String scorecardMatchTitle(
  RefereeMatchResponse? match, {
  RefereeScorecardResponse? scorecard,
  String fallback = 'Match Scorecard',
}) {
  final direct = match?.tournamentName?.trim();
  if (direct != null && direct.isNotEmpty) return direct;

  final rawTournament = match?.raw['tournament'];
  if (rawTournament is Map) {
    final name = rawTournament['name']?.toString().trim();
    if (name != null && name.isNotEmpty) return name;
  }
  final rawName = match?.raw['tournament_name']?.toString().trim();
  if (rawName != null && rawName.isNotEmpty) return rawName;

  final rawMatch = scorecard?.raw['match'];
  if (rawMatch is Map) {
    final tournament = rawMatch['tournament'];
    if (tournament is Map) {
      final name = tournament['name']?.toString().trim();
      if (name != null && name.isNotEmpty) return name;
    }
    final name = rawMatch['tournament_name']?.toString().trim();
    if (name != null && name.isNotEmpty) return name;
  }
  return fallback;
}

String scorecardMatchLocation(
  RefereeMatchResponse? match, {
  RefereeScorecardResponse? scorecard,
}) {
  for (final value in [match?.location, match?.venueName]) {
    final text = value?.trim() ?? '';
    if (text.isNotEmpty) return text;
  }
  final rawMatch = scorecard?.raw['match'];
  if (rawMatch is Map) {
    final venue = rawMatch['venue'];
    if (venue is Map) {
      final name = venue['location']?.toString().trim();
      if (name != null && name.isNotEmpty) return name;
    }
  }
  return '';
}

String scorecardMatchVenue(
  RefereeMatchResponse? match, {
  RefereeScorecardResponse? scorecard,
}) {
  final venue = match?.venueName?.trim();
  if (venue != null && venue.isNotEmpty) return venue;
  final location = match?.location?.trim();
  if (location != null && location.isNotEmpty) return location;

  final rawMatch = scorecard?.raw['match'];
  if (rawMatch is Map) {
    final venueName = rawMatch['venue_name']?.toString().trim();
    if (venueName != null && venueName.isNotEmpty) return venueName;
    final venue = rawMatch['venue'];
    if (venue is Map) {
      final name = venue['name']?.toString().trim();
      if (name != null && name.isNotEmpty) return name;
    }
    final rawLocation = rawMatch['location']?.toString().trim();
    if (rawLocation != null && rawLocation.isNotEmpty) return rawLocation;
  }
  return 'Venue not set';
}

String scorecardMatchRound(
  RefereeMatchResponse? match, {
  RefereeScorecardResponse? scorecard,
}) {
  for (final value in [
    match?.roundName,
    match?.matchNumber,
    match?.raw['round_name'],
    match?.raw['stage'],
  ]) {
    final text = value?.toString().trim() ?? '';
    if (text.isNotEmpty) return text;
  }
  final rawMatch = scorecard?.raw['match'];
  if (rawMatch is Map) {
    for (final value in [rawMatch['round_name'], rawMatch['stage']]) {
      final text = value?.toString().trim() ?? '';
      if (text.isNotEmpty) return text;
    }
  }
  return 'Match';
}

String scorecardMatchCode(
  RefereeMatchResponse? match,
  RefereeScorecardResponse? scorecard,
) {
  for (final value in [
    match?.matchNumber,
    scorecard?.matchCode,
    match?.raw['match_code'],
    match?.raw['fixture_code'],
  ]) {
    final text = value?.toString().trim() ?? '';
    if (text.isNotEmpty) return text;
  }
  final id = scorecard?.match.id ?? match?.id;
  return id == null ? 'SP' : 'SP-$id';
}

String scorecardSportLabel(RefereeMatchResponse? match) {
  final rawSport = match?.raw['sport'] ?? match?.raw['sport_name'];
  if (rawSport is Map) {
    final name = rawSport['name']?.toString().trim();
    if (name != null && name.isNotEmpty) return name;
  }
  final direct = match?.raw['sport_name']?.toString().trim();
  if (direct != null && direct.isNotEmpty) return direct;
  return 'Cricket';
}

String scorecardSourceLabel(RefereeMatchResponse? match) {
  final raw = [
    match?.raw['booked_by_type'],
    match?.raw['booking_source'],
    match?.raw['source'],
    match?.raw['created_by'],
    match?.raw['request_type'],
  ]
      .whereType<Object>()
      .map((value) => value.toString().toLowerCase())
      .join(' ');
  if (raw.contains('partner')) return 'by Partner';
  if (raw.contains('user')) return 'by User';
  return 'by Partner';
}

String scorecardStatusLabel(RefereeMatchResponse? match) {
  final label = match?.statusLabel?.trim();
  if (label != null && label.isNotEmpty) return label;
  return 'Completed';
}

/// Resolves the scorecard teams, merging in the optional match teams and
/// falling back to the team-total keys when the API omits the team list.
List<RefereeScorecardTeam> scorecardTeams(
  RefereeScorecardResponse scorecard,
  RefereeMatchResponse? match,
) {
  final teams = <RefereeScorecardTeam>[];
  final seen = <int>{};

  void add(int? id, String? name) {
    if (id == null || id <= 0 || !seen.add(id)) return;
    final clean = name?.trim() ?? '';
    teams.add(
      RefereeScorecardTeam(
        id: id,
        name: clean.isEmpty ? 'Team $id' : clean,
      ),
    );
  }

  for (final team in scorecard.match.teams) {
    add(team.id, team.name);
  }
  add(match?.teamA?.id, match?.teamA?.name);
  add(match?.teamB?.id, match?.teamB?.name);

  if (teams.isEmpty) {
    for (final key in scorecard.teamTotals.keys) {
      add(int.tryParse(key), null);
    }
  }
  return teams;
}

String scorecardTeamScore(
  RefereeScorecardResponse scorecard,
  int teamId,
  RefereeMatchResponse? match,
) {
  final total = scorecard.teamTotals['$teamId'];
  if (total != null) return total.scoreText;
  if (match?.teamA?.id == teamId) {
    final score = match?.teamA?.score?.trim();
    if (score != null && score.isNotEmpty) return score;
  }
  if (match?.teamB?.id == teamId) {
    final score = match?.teamB?.score?.trim();
    if (score != null && score.isNotEmpty) return score;
  }
  return '\u2014';
}

String? scorecardSuperOverScore(
  RefereeScorecardResponse scorecard,
  int teamId,
) {
  final total = scorecard.superOverTotals?['$teamId'];
  if (total is Map) {
    return RefereeScorecardTotals.fromJson(
      Map<String, dynamic>.from(total),
    ).scoreText;
  }
  for (final innings in scorecard.superOvers) {
    if (innings.battingTeamId == teamId) return innings.totals.scoreText;
  }
  return null;
}

String? _firstText(Iterable<Object?> values) {
  for (final value in values) {
    final text = value?.toString().trim();
    if (text != null && text.isNotEmpty) return text;
  }
  return null;
}

String? scorecardWinnerName(
  RefereeScorecardResponse scorecard, {
  RefereeMatchResponse? match,
  RefereeMatchResultResponse? result,
}) {
  final direct = _firstText([
    result?.winnerTeamName,
    scorecard.winnerTeamName,
    scorecard.result['winner_team_name'],
    scorecard.result['winner_name'],
    scorecard.result['winner'],
    match?.raw['winner_team_name'],
    match?.raw['winner_name'],
  ]);
  if (direct != null) return direct;

  final winnerId = scorecard.match.winnerTeamId ??
      result?.winnerTeamId ??
      _nullableInt(match?.raw['winner_team_id']);
  if (winnerId != null) {
    for (final team in scorecardTeams(scorecard, match)) {
      if (team.id == winnerId) return team.name;
    }
  }

  final totals = scorecard.teamTotals.entries.toList()
    ..sort((a, b) => b.value.runs.compareTo(a.value.runs));
  if (totals.length >= 2 && totals[0].value.runs != totals[1].value.runs) {
    final winnerId = int.tryParse(totals.first.key);
    if (winnerId != null) {
      for (final team in scorecardTeams(scorecard, match)) {
        if (team.id == winnerId) return team.name;
      }
    }
  }
  return null;
}

String? scorecardWinnerSubtitle(
  RefereeScorecardResponse scorecard, {
  RefereeMatchResponse? match,
  RefereeMatchResultResponse? result,
  required String? winner,
}) {
  if (winner == null || winner.trim().isEmpty) return null;

  final margin = _firstText([
    result?.margin,
    scorecard.result['margin'],
    scorecard.result['win_margin'],
    scorecard.result['margin_text'],
    match?.raw['margin'],
  ]);
  if (margin != null) {
    if (margin.toLowerCase().contains('won by')) return '$winner $margin';
    return '$winner won by $margin';
  }

  final message = _firstText([
    result?.message,
    scorecard.result['message'],
    scorecard.result['result_text'],
    match?.raw['result_message'],
  ]);
  if (message != null) return message;
  return '$winner won';
}

int? _nullableInt(Object? value) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse(value?.toString() ?? '');
}
