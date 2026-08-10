import 'package:flutter/material.dart';

import '../theme/sporto_design_tokens.dart';
import 'sporto_pill_button.dart';

class SportoTeamVerificationCard extends StatelessWidget {
  const SportoTeamVerificationCard({
    super.key,
    required this.teamName,
    required this.subName,
    required this.players,
    required this.isPresent,
    required this.onTogglePresent,
    this.onMarkAbsent,
  });

  final String teamName;
  final String subName;
  final List<String> players;
  final bool isPresent;
  final VoidCallback onTogglePresent;
  final VoidCallback? onMarkAbsent;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final radius = BorderRadius.circular(context.sportoLayout.radius14);

    return Column(
      children: [
        Container(
          height: 64,
          padding: const EdgeInsets.symmetric(horizontal: 10),
          decoration: BoxDecoration(color: context.sporto.card, borderRadius: radius),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(teamName,
                        style: theme.textTheme.titleLarge
                            ?.copyWith(color: context.sporto.info)),
                    Text(subName, style: theme.textTheme.titleLarge),
                  ],
                ),
              ),
              Icon(Icons.check_circle_rounded, color: cs.secondary, size: 18),
              const SizedBox(width: 6),
              Text('Team Ready',
                  style: theme.textTheme.bodyLarge?.copyWith(color: cs.secondary)),
            ],
          ),
        ),
        const SizedBox(height: 2),
        Container(
          height: 159,
          padding: const EdgeInsets.fromLTRB(10, 10, 10, 9),
          decoration: BoxDecoration(color: context.sporto.card, borderRadius: radius),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (final player in players)
                Text.rich(
                  TextSpan(
                    style: theme.textTheme.bodyLarge,
                    children: _playerSpans(player, theme, cs),
                  ),
                ),
              const Spacer(),
              Divider(height: 1, color: cs.outline),
              const SizedBox(height: 7),
              Row(
                children: [
                  Expanded(
                    child: SportoPillButton(
                      label: isPresent ? '✓  Present' : 'Mark As Present',
                      color: cs.secondary,
                      filled: isPresent,
                      height: 38,
                      padding: EdgeInsets.zero,
                      onTap: isPresent ? null : onTogglePresent,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: SportoPillButton(
                      label: 'Mark As Absent',
                      color: cs.outline,
                      height: 38,
                      padding: EdgeInsets.zero,
                      onTap: onMarkAbsent,
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

  List<InlineSpan> _playerSpans(
      String player, ThemeData theme, ColorScheme cs) {
    const marker = ' (Captain)';
    if (!player.endsWith(marker)) return [TextSpan(text: player)];
    return [
      TextSpan(text: player.substring(0, player.length - marker.length)),
      TextSpan(
        text: marker,
        style: theme.textTheme.bodyLarge?.copyWith(color: cs.primary),
      ),
    ];
  }
}
