import 'package:flutter/material.dart';
import 'package:partner_data/partner_data.dart';
import 'package:ui_kit/ui_kit.dart';

import '../widgets/redesign/tournament_cards.dart';
import '../widgets/redesign/tournament_navigation.dart';
import '../widgets/redesign/tournament_visuals.dart';

/// Teams tab — Figma `Partner App / Teams` (export 17).
///
/// Real data only: registrations carry team name, status and players.
class TournamentTeamsTab extends StatefulWidget {
  const TournamentTeamsTab({
    super.key,
    required this.registrations,
    this.onViewTeam,
  });

  final List<TournamentRegistration> registrations;
  final ValueChanged<TournamentRegistration>? onViewTeam;

  @override
  State<TournamentTeamsTab> createState() => _TournamentTeamsTabState();
}

class _TournamentTeamsTabState extends State<TournamentTeamsTab> {
  int _filter = 0;

  bool _approved(TournamentRegistration r) {
    final s = r.status.toLowerCase();
    return s.contains('approv') ||
        s.contains('confirm') ||
        s.contains('accept');
  }

  @override
  Widget build(BuildContext context) {
    final t = context.sportoTournament;
    final all = widget.registrations;
    final approved = all.where(_approved).toList();
    final filters = [
      'All (${all.length})',
      'Approved (${approved.length})',
    ];
    final index = _filter.clamp(0, filters.length - 1);
    final list = index == 0 ? all : approved;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: 34,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: filters.length,
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemBuilder: (_, i) => TournamentFilterChip(
              label: filters[i],
              selected: index == i,
              onTap: () => setState(() => _filter = i),
              selectedColor: t.green,
              selectedForeground: t.screenBase,
            ),
          ),
        ),
        const SizedBox(height: 14),
        if (list.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 40),
            child: Center(
              child: Text(
                'No teams registered yet.',
                style: SportoTextStyles.text(
                  size: SportoTextStyles.size14,
                  color: t.muted,
                ),
              ),
            ),
          )
        else
          for (var i = 0; i < list.length; i++) ...[
            _TeamCard(
              rank: i + 1,
              registration: list[i],
              onView: widget.onViewTeam == null
                  ? null
                  : () => widget.onViewTeam!(list[i]),
            ),
            if (i != list.length - 1) const SizedBox(height: 10),
          ],
      ],
    );
  }
}

class _TeamCard extends StatelessWidget {
  const _TeamCard({
    required this.rank,
    required this.registration,
    this.onView,
  });

  final int rank;
  final TournamentRegistration registration;
  final VoidCallback? onView;

  @override
  Widget build(BuildContext context) {
    final t = context.sportoTournament;
    final scale = context.sportoScale;
    final players = registration.players.length;
    final initials = _initials(registration.name);
    return TournamentSurface(
      radius: t.r12,
      padding: EdgeInsets.all(12 * scale),
      color: t.cardAlt,
      borderColor: t.border,
      onTap: onView,
      child: Row(
        children: [
          TournamentAvatar(
            label: initials,
            size: 42 * scale,
            radius: t.r10,
            color: t.greenDeep,
            background: t.greenDeep.withValues(alpha: .10),
            fontSize: SportoTextStyles.size16,
            showBorder: false,
          ),
          SizedBox(width: 10 * scale),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      '#$rank Team',
                      style: SportoTextStyles.text(
                        size: SportoTextStyles.size11,
                        weight: FontWeight.w600,
                        color: t.gold,
                      ),
                    ),
                    const Spacer(),
                    if (registration.status.trim().isNotEmpty)
                      Text(
                        registration.status,
                        style: SportoTextStyles.text(
                          size: SportoTextStyles.size11,
                          color: t.muted,
                        ),
                      ),
                  ],
                ),
                SizedBox(height: 2 * scale),
                Text(
                  registration.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: SportoTextStyles.text(
                    size: SportoTextStyles.size14,
                    weight: FontWeight.w600,
                    color: t.white,
                  ),
                ),
                SizedBox(height: 2 * scale),
                Text(
                  players == 1 ? '1 player' : '$players players',
                  style: SportoTextStyles.text(
                    size: SportoTextStyles.size12,
                    color: t.muted,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static String _initials(String name) {
    final words =
        name.trim().split(RegExp(r'\s+')).where((w) => w.isNotEmpty).toList();
    if (words.length >= 2) {
      return (words[0][0] + words[1][0]).toUpperCase();
    }
    return name.isEmpty ? '--' : name.substring(0, 1).toUpperCase();
  }
}
