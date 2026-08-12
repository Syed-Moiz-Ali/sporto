import 'package:flutter/material.dart';

import '../theme/sporto_design_tokens.dart';
import 'sporto_pill_button.dart';

class SportoTeamVerificationCard extends StatelessWidget {
  const SportoTeamVerificationCard({
    super.key,
    required this.teamLabel,
    required this.teamName,
    required this.players,
    required this.isPresent,
    required this.onMarkPresent,
    required this.onMarkAbsent,
  });

  final String teamLabel;
  final String teamName;

  final List<String> players;

  final bool isPresent;

  final VoidCallback onMarkPresent;
  final VoidCallback onMarkAbsent;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final scale = context.sportoScale;

    final radius = BorderRadius.circular(
      12 * scale,
    );

    final readyColor =
        isPresent ? context.sporto.assigned : context.sporto.live;

    return Column(
      children: [
        // =====================================================
        // TEAM HEADER
        // =====================================================

        Container(
          width: double.infinity,
          height: 63 * scale,
          padding: EdgeInsets.symmetric(
            horizontal: 10 * scale,
          ),
          decoration: BoxDecoration(
            color: context.sporto.cardElevated,
            borderRadius: radius,
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      teamLabel,
                      style: theme.textTheme.titleLarge?.copyWith(
                        color: context.sporto.info,
                        fontSize: 15 * scale,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 5 * scale),
                    Text(
                      teamName,
                      style: theme.textTheme.titleLarge?.copyWith(
                        color: cs.onSurface,
                        fontSize: 16 * scale,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                width: 17 * scale,
                height: 17 * scale,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: readyColor,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  isPresent ? Icons.check_rounded : Icons.priority_high_rounded,
                  size: 11 * scale,
                  color: Colors.white,
                ),
              ),
              SizedBox(width: 6 * scale),
              Text(
                isPresent ? 'Team Ready' : 'Team Not Ready',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: readyColor,
                  fontSize: 11 * scale,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),

        SizedBox(height: 2 * scale),

        // =====================================================
        // PLAYERS + ACTIONS
        // =====================================================

        Container(
          width: double.infinity,
          height: 160 * scale,
          padding: EdgeInsets.fromLTRB(
            10 * scale,
            10 * scale,
            10 * scale,
            9 * scale,
          ),
          decoration: BoxDecoration(
            color: context.sporto.cardElevated,
            borderRadius: radius,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (final player in players)
                _PlayerName(
                  value: player,
                ),
              const Spacer(),
              Divider(
                height: 1,
                thickness: 1,
                color: cs.outline.withValues(
                  alpha: .55,
                ),
              ),
              SizedBox(height: 7 * scale),
              Row(
                children: [
                  // ===========================================
                  // PRESENT
                  // ===========================================

                  Expanded(
                    child: SportoPillButton(
                      label: isPresent ? '✓  Present' : 'Mark As Present',
                      color: isPresent ? context.sporto.assigned : cs.outline,
                      filled: isPresent,
                      height: 38 * scale,
                      padding: EdgeInsets.zero,
                      onTap: isPresent ? null : onMarkPresent,
                    ),
                  ),

                  SizedBox(width: 12 * scale),

                  // ===========================================
                  // ABSENT
                  // ===========================================

                  Expanded(
                    child: SportoPillButton(
                      label: isPresent ? 'Mark As Absent' : '✓  Absent',
                      color: isPresent ? cs.outline : context.sporto.live,
                      filled: !isPresent,
                      height: 38 * scale,
                      padding: EdgeInsets.zero,
                      onTap: isPresent ? onMarkAbsent : null,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _PlayerName extends StatelessWidget {
  const _PlayerName({
    required this.value,
  });

  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final scale = context.sportoScale;

    const captainText = ' (Captain)';

    if (!value.endsWith(captainText)) {
      return Text(
        value,
        style: theme.textTheme.bodyLarge?.copyWith(
          color: cs.onSurface,
          fontSize: 13 * scale,
          height: 1.35,
          fontWeight: FontWeight.w500,
        ),
      );
    }

    final name = value.substring(
      0,
      value.length - captainText.length,
    );

    return Text.rich(
      TextSpan(
        style: theme.textTheme.bodyLarge?.copyWith(
          color: cs.onSurface,
          fontSize: 13 * scale,
          height: 1.35,
          fontWeight: FontWeight.w500,
        ),
        children: [
          TextSpan(
            text: name,
          ),
          TextSpan(
            text: captainText,
            style: TextStyle(
              color: cs.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
