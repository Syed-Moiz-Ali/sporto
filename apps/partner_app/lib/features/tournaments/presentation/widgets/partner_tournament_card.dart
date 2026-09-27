import 'package:flutter/material.dart';
import 'package:ui_kit/ui_kit.dart';

/// Tournament summary used only by the Partner application's Tournaments tab.
class PartnerTournamentCard extends StatelessWidget {
  const PartnerTournamentCard({
    super.key,
    required this.name,
    required this.stage,
    required this.status,
    required this.location,
    required this.date,
    required this.registeredTeams,
    required this.maximumTeams,
    required this.isLive,
    required this.onTap,
  });

  final String name;
  final String stage;
  final String status;
  final String location;
  final String date;
  final int registeredTeams;
  final int? maximumTeams;
  final bool isLive;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final scale = context.sportoScale;
    final accent = isLive ? const Color(0xFFFF6846) : cs.secondary;

    return SportoCard(
      onTap: onTap,
      radius: 16 * scale,
      padding: EdgeInsets.all(14 * scale),
      backgroundColor: cs.surfaceContainerHigh.withValues(alpha: .88),
      borderColor: accent.withValues(alpha: .25),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              SportoBadge(text: stage, color: accent, outlined: true),
              const Spacer(),
              if (isLive) ...[
                Container(
                  width: 7 * scale,
                  height: 7 * scale,
                  decoration: const BoxDecoration(
                    color: Color(0xFFFF4D43),
                    shape: BoxShape.circle,
                  ),
                ),
                SizedBox(width: 5 * scale),
              ],
              Text(
                status,
                style: TextStyle(
                  color: accent,
                  fontSize: 11 * scale,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          SizedBox(height: 12 * scale),
          Text(
            name,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: cs.onSurface,
              fontSize: 16 * scale,
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(height: 8 * scale),
          _detail(context, Icons.location_on_outlined, location),
          SizedBox(height: 5 * scale),
          _detail(context, Icons.calendar_today_outlined, date),
          SizedBox(height: 12 * scale),
          Divider(height: 1, color: cs.outlineVariant.withValues(alpha: .5)),
          SizedBox(height: 12 * scale),
          Row(
            children: [
              Expanded(
                child: Text(
                  maximumTeams == null
                      ? '$registeredTeams teams registered'
                      : '$registeredTeams / $maximumTeams teams registered',
                  style: TextStyle(
                    color: cs.onSurfaceVariant,
                    fontSize: 12 * scale,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Text(
                'View Tournament',
                style: TextStyle(
                  color: cs.tertiary,
                  fontSize: 12 * scale,
                  fontWeight: FontWeight.w700,
                ),
              ),
              SizedBox(width: 4 * scale),
              Icon(
                Icons.arrow_forward_rounded,
                color: cs.tertiary,
                size: 17 * scale,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _detail(BuildContext context, IconData icon, String text) {
    final cs = Theme.of(context).colorScheme;
    final scale = context.sportoScale;
    return Row(
      children: [
        Icon(icon, color: cs.onSurfaceVariant, size: 15 * scale),
        SizedBox(width: 6 * scale),
        Expanded(
          child: Text(
            text,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(color: cs.onSurfaceVariant, fontSize: 11 * scale),
          ),
        ),
      ],
    );
  }
}
