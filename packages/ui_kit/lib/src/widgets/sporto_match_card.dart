// ============================================================
// sporto_match_card.dart
// Data-driven match card used across home & match list screens.
// ============================================================
import 'package:flutter/material.dart';
import 'sporto_badge.dart';
import 'sporto_card.dart';
import 'sporto_divider.dart';
import 'sporto_gradient_card.dart';
import 'sporto_pill_button.dart';

enum SportoMatchCardVariant { live, upcoming, completed, delayed }

/// Small status chip (icon + color + label) e.g. "Teams Verified".
class SportoStatusItem {
  final IconData icon;
  final Color color;
  final String label;

  const SportoStatusItem(this.icon, this.color, this.label);
}

class SportoMatchCard extends StatelessWidget {
  final SportoMatchCardVariant variant;

  final String tournamentName;
  final String? location;
  final String? stage;
  final String? timeLabel;
  final String? overLabel;

  final String teamA;
  final String? scoreA;
  final String teamB;
  final String? scoreB;

  /// Custom middle section (e.g. current batter/bowler rows).
  final Widget? middle;

  /// Footer-left: "Starts in 00:28:35" style label.
  final String? startsInLabel;

  /// Footer-left: dot + note text (result / warning).
  final String? noteLabel;
  final Color? noteColor;

  /// Footer-left: label/value column (e.g. Duration 08:25, Resume Time 4:00 PM).
  final String? infoLabel;
  final String? infoValue;

  final List<SportoStatusItem>? statusItems;

  final String? actionLabel;
  final Color? actionColor;
  final VoidCallback? onAction;

  /// Live variant background gradient (defaults to the red live look).
  final List<Color>? gradientColors;

  const SportoMatchCard({
    super.key,
    required this.variant,
    required this.tournamentName,
    this.stage,
    required this.teamA,
    required this.teamB,
    this.location,
    this.timeLabel,
    this.overLabel,
    this.scoreA,
    this.scoreB,
    this.middle,
    this.startsInLabel,
    this.noteLabel,
    this.noteColor,
    this.infoLabel,
    this.infoValue,
    this.statusItems,
    this.actionLabel,
    this.actionColor,
    this.onAction,
    this.gradientColors,
  });

  bool get _isLive => variant == SportoMatchCardVariant.live;

  Color? get _statusColor {
    switch (variant) {
      case SportoMatchCardVariant.live:
        return Colors.redAccent;
      case SportoMatchCardVariant.upcoming:
        return Colors.orange;
      case SportoMatchCardVariant.completed:
        return null; // uses theme tertiary
      case SportoMatchCardVariant.delayed:
        return Colors.orange;
    }
  }

  String get _statusLabel {
    switch (variant) {
      case SportoMatchCardVariant.live:
        return 'Live Now';
      case SportoMatchCardVariant.upcoming:
        return 'Upcoming';
      case SportoMatchCardVariant.completed:
        return 'Completed';
      case SportoMatchCardVariant.delayed:
        return 'Delayed';
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final nameColor = _isLive ? Colors.orange : cs.onSurface;

    final content = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header row: stage badge + status + time/over
        Row(
          children: [
            if (stage != null) ...[
              SportoBadge(text: stage!, color: cs.secondary),
              const SizedBox(width: 8),
            ],
            if (_isLive)
              Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                        shape: BoxShape.circle, color: Colors.redAccent),
                  ),
                  const SizedBox(width: 4),
                  Text('Live Now',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.w600)),
                ],
              )
            else
              SportoBadge(
                  text: _statusLabel, color: _statusColor ?? cs.onTertiary),
            const Spacer(),
            if (overLabel != null)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(overLabel!,
                    style: TextStyle(
                        color: cs.onSurface,
                        fontSize: 12,
                        fontWeight: FontWeight.w600)),
              )
            else if (timeLabel != null)
              Text(timeLabel!,
                  style: TextStyle(color: cs.onSurfaceVariant, fontSize: 12)),
          ],
        ),
        const SizedBox(height: 12),

        // Tournament name + location
        Text(tournamentName,
            style: TextStyle(
                color: nameColor, fontSize: 18, fontWeight: FontWeight.w700)),
        if (location != null) ...[
          Row(
            children: [
              Icon(Icons.location_on_outlined,
                  size: 14, color: cs.onSurfaceVariant),
              const SizedBox(width: 4),
              Text(location!,
                  style: TextStyle(color: cs.onSurfaceVariant, fontSize: 12)),
            ],
          ),
        ],
        const SizedBox(height: 16),

        // Teams & scores
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(teamA,
                        style: TextStyle(
                            color: scoreA != null
                                ? cs.onSurfaceVariant
                                : cs.onSurface,
                            fontSize: 12,
                            fontWeight: FontWeight.w600)),
                    if (scoreA != null)
                      Text(scoreA!,
                          style: TextStyle(
                              color: _isLive ? cs.onSurface : cs.secondary,
                              fontSize: 16,
                              fontWeight: FontWeight.w700)),
                  ]),
            ),
            Text('Vs',
                style: TextStyle(color: cs.onSurfaceVariant, fontSize: 12)),
            Expanded(
              child:
                  Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                Text(teamB,
                    style: TextStyle(
                        color:
                            scoreB != null ? cs.onSurfaceVariant : cs.onSurface,
                        fontSize: 12,
                        fontWeight: FontWeight.w600)),
                if (scoreB != null)
                  Text(scoreB!,
                      style: TextStyle(
                          color: _isLive ? cs.onSurface : cs.onSurface,
                          fontSize: 16,
                          fontWeight: FontWeight.w700)),
              ]),
            ),
          ],
        ),

        if (middle != null) ...[
          const SizedBox(height: 12),
          const SportoDivider(color: Color(0x33FFFFFF)),
          const SizedBox(height: 12),
          middle!,
        ],
        if (statusItems != null && statusItems!.isNotEmpty) ...[
          const SizedBox(height: 16),
          Wrap(spacing: 8, runSpacing: 8, children: [
            for (final item in statusItems!)
              Row(mainAxisSize: MainAxisSize.min, children: [
                Icon(item.icon, color: item.color, size: 14),
                const SizedBox(width: 4),
                Text(item.label,
                    style: TextStyle(color: item.color, fontSize: 11)),
              ]),
          ]),
        ],
        const SizedBox(height: 12),
        const SportoDivider(color: Color(0x33FFFFFF)),
        const SizedBox(height: 12),

        // Footer row
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            if (infoLabel != null)
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(infoLabel!,
                    style: TextStyle(color: cs.onSurfaceVariant, fontSize: 12)),
                Text(infoValue ?? '',
                    style: TextStyle(
                        color: cs.onSurface,
                        fontSize: 14,
                        fontWeight: FontWeight.w600)),
              ])
            else if (noteLabel != null)
              Row(children: [
                Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: noteColor ?? cs.secondary)),
                const SizedBox(width: 6),
                Text(noteLabel!,
                    style: TextStyle(
                        color: noteColor ?? cs.secondary,
                        fontSize: 13,
                        fontWeight: FontWeight.w600)),
              ])
            else if (startsInLabel != null)
              RichText(
                  text: TextSpan(style: TextStyle(fontSize: 14), children: [
                TextSpan(
                    text: 'Starts in ',
                    style: TextStyle(color: cs.onSurfaceVariant)),
                TextSpan(
                    text: startsInLabel,
                    style: TextStyle(
                        color: cs.secondary, fontWeight: FontWeight.w700))
              ]))
            else
              const SizedBox.shrink(),
            if (actionLabel != null)
              SportoPillButton(
                label: actionLabel!,
                color: actionColor ?? cs.secondary,
                filled: _isLive || (actionColor == Colors.redAccent),
                onTap: onAction,
              ),
          ],
        ),
      ],
    );

    if (_isLive) {
      return SportoGradientCard(
        colors: gradientColors ?? const [Color(0xFF4A1515), Color(0xFF2A0A0A)],
        borderColor: Colors.redAccent.withOpacity(0.3),
        padding: const EdgeInsets.all(16),
        child: content,
      );
    }

    return SportoCard(radius: 20, child: content);
  }
}
