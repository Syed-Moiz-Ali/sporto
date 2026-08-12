import 'package:flutter/material.dart';

import '../theme/sporto_design_tokens.dart';
import 'primary_button.dart';
import 'sporto_badge.dart';
import 'sporto_card.dart';
import 'sporto_check_box.dart';

/// ============================================================
/// MATCH VERIFICATION HEADER
/// ============================================================
class SportoMatchVerificationHeader extends StatelessWidget {
  final String title;
  final String matchId;
  final VoidCallback? onBack;

  const SportoMatchVerificationHeader({
    super.key,
    this.title = 'Match Verification',
    required this.matchId,
    this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scale = context.sportoScale;

    return SizedBox(
      height: 76 * scale,
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: 20 * scale,
        ),
        child: Row(
          children: [
            Material(
              color: context.sporto.cardElevated,
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
                    size: 28 * scale,
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
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  SizedBox(height: 3 * scale),
                  Text(
                    'Match #$matchId',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface,
                      fontSize: 11 * scale,
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

/// ============================================================
/// MATCH SUMMARY CARD
/// ============================================================
class SportoVerificationMatchSummaryCard extends StatelessWidget {
  final String stage;
  final String dateTime;
  final String status;

  final String tournament;
  final String location;

  final String team1;
  final String team2;

  final String startsIn;
  final String startTime;

  const SportoVerificationMatchSummaryCard({
    super.key,
    this.stage = 'Quarter Final',
    this.dateTime = 'Today, 06:30 PM',
    this.status = 'Upcoming',
    this.tournament = 'Asia Cup 2026',
    this.location = 'Hyderabad',
    required this.team1,
    required this.team2,
    this.startsIn = '24 mins',
    this.startTime = '06:30 PM',
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final scale = context.sportoScale;

    return Container(
      width: double.infinity,
      height: 140 * scale,
      padding: EdgeInsets.all(
        10 * scale,
      ),
      decoration: BoxDecoration(
        color: context.sporto.cardElevated,
        borderRadius: BorderRadius.circular(
          13 * scale,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// Header
          Row(
            children: [
              SportoBadge(
                text: stage,
                color: context.sporto.assigned,
                outlined: true,
              ),
              const Spacer(),
              Text(
                dateTime,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colors.onSurfaceVariant,
                  fontSize: 11 * scale,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const Spacer(),
              SportoBadge(
                text: status,
                color: context.sporto.upcoming,
              ),
            ],
          ),

          SizedBox(height: 8 * scale),

          /// Tournament
          Text(
            tournament,
            style: theme.textTheme.titleLarge?.copyWith(
              color: colors.onSurface,
              fontSize: 15 * scale,
              height: 1,
              fontWeight: FontWeight.w700,
            ),
          ),

          SizedBox(height: 4 * scale),

          /// Location
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
                ),
              ),
            ],
          ),

          SizedBox(height: 9 * scale),

          /// Teams
          Row(
            children: [
              Expanded(
                child: Text(
                  team1,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: colors.onSurface,
                    fontSize: 13 * scale,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              Text(
                'Vs',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colors.onSurfaceVariant,
                  fontSize: 11 * scale,
                ),
              ),
              Expanded(
                child: Text(
                  team2,
                  textAlign: TextAlign.end,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: colors.onSurface,
                    fontSize: 13 * scale,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),

          SizedBox(height: 9 * scale),

          Divider(
            height: 1,
            thickness: 1,
            color: colors.outline.withValues(
              alpha: .55,
            ),
          ),

          const Spacer(),

          /// Starts in
          Center(
            child: Text.rich(
              TextSpan(
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colors.onSurface,
                  fontSize: 12 * scale,
                  fontWeight: FontWeight.w500,
                ),
                children: [
                  const TextSpan(
                    text: 'Starts in ',
                  ),
                  TextSpan(
                    text: startsIn,
                    style: TextStyle(
                      color: context.sporto.assigned,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  TextSpan(
                    text: '  ·  at $startTime',
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// ============================================================
/// FINAL CHECKLIST
/// ============================================================
class SportoVerificationChecklist extends StatelessWidget {
  final bool team1Checked;
  final bool team2Checked;
  final bool tossChecked;

  const SportoVerificationChecklist({
    super.key,
    required this.team1Checked,
    required this.team2Checked,
    this.tossChecked = false,
  });

  @override
  Widget build(BuildContext context) {
    final scale = context.sportoScale;

    return SportoCard(
      radius: 14 * scale,
      borderColor: Colors.transparent,
      backgroundColor: context.sporto.cardElevated,
      padding: EdgeInsets.symmetric(
        vertical: 7 * scale,
      ),
      child: Column(
        children: [
          _VerificationChecklistItem(
            label: 'Team 1',
            checked: team1Checked,
          ),
          _VerificationChecklistItem(
            label: 'Team 2',
            checked: team2Checked,
          ),
          _VerificationChecklistItem(
            label: 'Toss',
            checked: tossChecked,
          ),
        ],
      ),
    );
  }
}

class _VerificationChecklistItem extends StatelessWidget {
  final String label;
  final bool checked;

  const _VerificationChecklistItem({
    required this.label,
    required this.checked,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scale = context.sportoScale;

    return SizedBox(
      height: 34 * scale,
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: 10 * scale,
        ),
        child: Row(
          children: [
            SizedBox(
              width: 17 * scale,
              height: 17 * scale,
              child: FittedBox(
                child: SportoCheckBox(
                  checked: checked,
                ),
              ),
            ),
            SizedBox(width: 9 * scale),
            Text(
              label,
              style: theme.textTheme.bodyLarge?.copyWith(
                color:
                    checked ? context.sporto.info : theme.colorScheme.onSurface,
                fontSize: 13 * scale,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// ============================================================
/// READY TO TOSS BUTTON
/// ============================================================
class SportoVerificationReadyButton extends StatelessWidget {
  final VoidCallback onTap;

  const SportoVerificationReadyButton({
    super.key,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final scale = context.sportoScale;

    return Center(
      child: PrimaryButton(
        width: 270 * scale,
        height: 49 * scale,
        radius: 14 * scale,
        label: 'Ready To Toss',
        onPressed: onTap,
      ),
    );
  }
}

/// ============================================================
/// ABSENT / GRACE PERIOD EXPIRED CARD
/// ============================================================
class SportoVerificationAbsentDecisionCard extends StatelessWidget {
  final String absentTeamLabel;
  final String absentTeamName;

  final bool team1Ready;
  final bool team2Ready;

  const SportoVerificationAbsentDecisionCard({
    super.key,
    required this.absentTeamLabel,
    required this.absentTeamName,
    required this.team1Ready,
    required this.team2Ready,
  });

  @override
  Widget build(BuildContext context) {
    final scale = context.sportoScale;
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(
        10 * scale,
        13 * scale,
        10 * scale,
        11 * scale,
      ),
      decoration: BoxDecoration(
        color: context.sporto.cardElevated,
        borderRadius: BorderRadius.circular(
          13 * scale,
        ),
      ),
      child: Column(
        children: [
          /// Missing team
          Text(
            '$absentTeamLabel - $absentTeamName\n'
            'hasn’t checked in.',
            textAlign: TextAlign.center,
            style: theme.textTheme.titleMedium?.copyWith(
              color: context.sporto.live,
              fontSize: 15 * scale,
              height: 1.25,
              fontWeight: FontWeight.w700,
            ),
          ),

          SizedBox(height: 17 * scale),

          Text(
            'Grace period expired. Choose how to handle...',
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colors.onSurfaceVariant,
              fontSize: 13 * scale,
              fontWeight: FontWeight.w500,
            ),
          ),

          SizedBox(height: 14 * scale),

          _AbsentTeamChecklistItem(
            label: 'Team 1',
            checked: team1Ready,
          ),

          SizedBox(height: 9 * scale),

          _AbsentTeamChecklistItem(
            label: 'Team 2',
            checked: team2Ready,
          ),
        ],
      ),
    );
  }
}

class _AbsentTeamChecklistItem extends StatelessWidget {
  final String label;
  final bool checked;

  const _AbsentTeamChecklistItem({
    required this.label,
    required this.checked,
  });

  @override
  Widget build(BuildContext context) {
    final scale = context.sportoScale;
    final theme = Theme.of(context);

    return Row(
      children: [
        SizedBox(
          width: 17 * scale,
          height: 17 * scale,
          child: FittedBox(
            child: SportoCheckBox(
              checked: checked,
            ),
          ),
        ),
        SizedBox(width: 9 * scale),
        Text(
          label,
          style: theme.textTheme.bodyLarge?.copyWith(
            color: checked ? context.sporto.info : theme.colorScheme.onSurface,
            fontSize: 13 * scale,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

/// ============================================================
/// WALKOVER ACTIONS
/// ============================================================
class SportoWalkoverActions extends StatelessWidget {
  final String awardToTeam;

  final VoidCallback onAwardWalkover;
  final VoidCallback onMarkAbsent;

  const SportoWalkoverActions({
    super.key,
    required this.awardToTeam,
    required this.onAwardWalkover,
    required this.onMarkAbsent,
  });

  @override
  Widget build(BuildContext context) {
    final scale = context.sportoScale;
    final theme = Theme.of(context);

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: 40 * scale,
      ),
      child: Column(
        children: [
          /// Award walkover
          SizedBox(
            width: double.infinity,
            height: 49 * scale,
            child: FilledButton(
              onPressed: onAwardWalkover,
              style: FilledButton.styleFrom(
                backgroundColor: context.sporto.assigned,
                foregroundColor: Colors.white,
                padding: EdgeInsets.zero,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(
                    14 * scale,
                  ),
                ),
              ),
              child: Text(
                'Award Walkover to $awardToTeam',
                style: theme.textTheme.titleMedium?.copyWith(
                  color: Colors.white,
                  fontSize: 15 * scale,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),

          SizedBox(height: 13 * scale),

          /// Mark absent
          SizedBox(
            width: double.infinity,
            height: 49 * scale,
            child: OutlinedButton(
              onPressed: onMarkAbsent,
              style: OutlinedButton.styleFrom(
                foregroundColor: theme.colorScheme.tertiary,
                padding: EdgeInsets.zero,
                side: BorderSide(
                  color: theme.colorScheme.tertiary,
                  width: 1,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(
                    14 * scale,
                  ),
                ),
              ),
              child: Text(
                'Mark As Absent',
                style: theme.textTheme.titleMedium?.copyWith(
                  color: theme.colorScheme.tertiary,
                  fontSize: 15 * scale,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
