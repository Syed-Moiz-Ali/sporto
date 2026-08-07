// ============================================================
// sporto_team_verification_card.dart
// Team presence verification card used before toss.
// ============================================================
import 'package:flutter/material.dart';
import 'sporto_card.dart';
import 'sporto_divider.dart';
import 'sporto_pill_button.dart';

class SportoTeamVerificationCard extends StatelessWidget {
  final String teamName;
  final String subName;
  final List<String> players;
  final bool isPresent;
  final VoidCallback onTogglePresent;
  final VoidCallback? onMarkAbsent;

  const SportoTeamVerificationCard({
    super.key,
    required this.teamName,
    required this.subName,
    required this.players,
    required this.isPresent,
    required this.onTogglePresent,
    this.onMarkAbsent,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return SportoCard(
      padding: EdgeInsets.zero,
      child: Column(children: [
        // Header
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(teamName,
                      style: TextStyle(
                          color: cs.onTertiary,
                          fontSize: 13,
                          fontWeight: FontWeight.w600)),
                  Text(subName,
                      style: TextStyle(
                          color: cs.onSurface,
                          fontSize: 16,
                          fontWeight: FontWeight.w700)),
                ],
              ),
              Row(children: [
                Icon(Icons.check_circle_rounded, color: cs.secondary, size: 18),
                const SizedBox(width: 6),
                Text('Team Ready',
                    style: TextStyle(
                        color: cs.secondary,
                        fontSize: 12,
                        fontWeight: FontWeight.w600)),
              ]),
            ],
          ),
        ),

        const SportoDivider(),

        // Player list
        Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: players
                .map((p) => Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: Text(p,
                        style: TextStyle(
                            color: p.contains('Captain')
                                ? cs.tertiary
                                : cs.onSurfaceVariant,
                            fontSize: 13))))
                .toList(),
          ),
        ),

        const SportoDivider(),

        // Action buttons
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(children: [
            Expanded(
              child: SportoPillButton(
                label: isPresent ? 'Present' : 'Mark As Present',
                color: cs.secondary,
                filled: isPresent,
                icon: isPresent ? Icons.check_rounded : null,
                height: 48,
                padding: EdgeInsets.zero,
                onTap: isPresent ? null : onTogglePresent,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: SportoPillButton(
                label: 'Mark As Absent',
                color: cs.onSurfaceVariant,
                height: 48,
                padding: EdgeInsets.zero,
                onTap: onMarkAbsent,
              ),
            ),
          ]),
        ),
      ]),
    );
  }
}
