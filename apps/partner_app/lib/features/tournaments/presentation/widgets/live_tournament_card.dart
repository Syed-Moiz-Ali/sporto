import 'package:flutter/material.dart';
import 'package:ui_kit/ui_kit.dart';

class LiveTournamentCard extends StatelessWidget {
  final String name;
  final String stage;
  final String sport;
  final String teams;
  final bool liveNow;
  final VoidCallback? onViewTournament;

  const LiveTournamentCard({
    super.key,
    required this.name,
    required this.stage,
    required this.sport,
    required this.teams,
    this.liveNow = false,
    this.onViewTournament,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return SportoCard(
      onTap: onViewTournament,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: cs.secondary.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                alignment: Alignment.center,
                child: Text(
                  _initials(name),
                  style: TextStyle(
                      color: cs.secondary,
                      fontSize: 18,
                      fontWeight: FontWeight.w700),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(name,
                        style: TextStyle(
                            color: cs.onSurface,
                            fontSize: 16,
                            fontWeight: FontWeight.w600)),
                    const SizedBox(height: 4),
                    RichText(
                      text: TextSpan(
                        style: TextStyle(fontSize: 13),
                        children: [
                          TextSpan(
                              text: '$sport • ',
                              style: TextStyle(color: cs.tertiary)),
                          TextSpan(
                              text: teams,
                              style: TextStyle(color: cs.secondary)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              SportoBadge(text: stage, color: cs.secondary, outlined: true),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  if (liveNow) ...[
                    Container(
                        width: 6,
                        height: 6,
                        decoration: const BoxDecoration(
                            shape: BoxShape.circle, color: Colors.redAccent)),
                    const SizedBox(width: 6),
                  ],
                  Text(liveNow ? 'Live Now' : '',
                      style: TextStyle(
                          color: cs.onSurface,
                          fontSize: 12,
                          fontWeight: FontWeight.w500)),
                ],
              ),
              GestureDetector(
                onTap: onViewTournament,
                child: Row(
                  children: [
                    Text('View Tournament',
                        style: TextStyle(
                            color: cs.tertiary,
                            fontSize: 12,
                            fontWeight: FontWeight.w600)),
                    const SizedBox(width: 4),
                    Icon(Icons.arrow_forward_ios_rounded,
                        color: cs.tertiary, size: 12),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _initials(String name) {
    final words = name.split(' ');
    if (words.length >= 2) {
      return words[0][0] + words[1][0];
    }
    return name.isNotEmpty ? name.substring(0, 2).toUpperCase() : 'SP';
  }
}
