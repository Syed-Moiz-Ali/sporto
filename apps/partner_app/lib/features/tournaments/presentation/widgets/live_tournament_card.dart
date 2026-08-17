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
    final scale = context.sportoScale;
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16 * scale),
        boxShadow: [
          BoxShadow(
            color: cs.secondary.withValues(alpha: .045),
            blurRadius: 14 * scale,
            spreadRadius: -10 * scale,
            offset: Offset(0, 6 * scale),
          ),
        ],
      ),
      child: SportoCard(
        onTap: onViewTournament,
        padding: EdgeInsets.all(12 * scale),
        backgroundColor: cs.surfaceContainerHigh.withValues(alpha: .86),
        borderColor: cs.secondary.withValues(alpha: .18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 56 * scale,
                  height: 56 * scale,
                  decoration: BoxDecoration(
                    color: cs.secondary.withValues(alpha: 0.14),
                    borderRadius: BorderRadius.circular(10 * scale),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    _initials(name),
                    style: TextStyle(
                        color: cs.secondary,
                        fontSize: 24 * scale,
                        fontWeight: FontWeight.w700),
                  ),
                ),
                SizedBox(width: 10 * scale),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(name,
                          style: TextStyle(
                              color: cs.onSurface,
                              fontSize: 14 * scale,
                              fontWeight: FontWeight.w700)),
                      SizedBox(height: 6 * scale),
                      RichText(
                        text: TextSpan(
                          style: TextStyle(fontSize: 11 * scale),
                          children: [
                            TextSpan(
                                text: '$sport • ',
                                style: TextStyle(
                                    color: cs.tertiary,
                                    fontWeight: FontWeight.w700)),
                            TextSpan(
                                text: teams,
                                style: TextStyle(
                                    color: cs.secondary,
                                    fontWeight: FontWeight.w600)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                SportoBadge(text: stage, color: cs.secondary, outlined: true),
              ],
            ),
            SizedBox(height: 10 * scale),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    if (liveNow) ...[
                      Container(
                          width: 6 * scale,
                          height: 6 * scale,
                          decoration: const BoxDecoration(
                              shape: BoxShape.circle, color: Colors.redAccent)),
                      SizedBox(width: 4 * scale),
                    ],
                    Text(liveNow ? 'Live Now' : '',
                        style: TextStyle(
                            color: cs.onSurface,
                            fontSize: 11 * scale,
                            fontWeight: FontWeight.w700)),
                  ],
                ),
                GestureDetector(
                  onTap: onViewTournament,
                  child: Row(
                    children: [
                      Text('View Tournament',
                          style: TextStyle(
                              color: cs.tertiary,
                              fontSize: 11 * scale,
                              fontWeight: FontWeight.w700)),
                      SizedBox(width: 4 * scale),
                      Icon(Icons.arrow_forward_rounded,
                          color: cs.tertiary, size: 16 * scale),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
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
