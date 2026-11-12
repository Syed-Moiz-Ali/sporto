import 'package:flutter/material.dart';
import 'package:partner_data/partner_data.dart';
import 'package:ui_kit/ui_kit.dart';

import '../widgets/redesign/tournament_cards.dart';
import '../widgets/redesign/tournament_navigation.dart';

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

  @override
  Widget build(BuildContext context) {
    final t = context.sportoTournament;
    final registrations = widget.registrations;
    final demo = registrations.isEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: 34,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [
              TournamentFilterChip(
                label: demo ? 'All (64)' : 'All (${registrations.length})',
                selected: _filter == 0,
                onTap: () => setState(() => _filter = 0),
                selectedColor: t.green,
                selectedForeground: t.screenBase,
              ),
              const SizedBox(width: 8),
              TournamentFilterChip(
                label: demo
                    ? 'Participated (64)'
                    : 'Participated (${registrations.length})',
                selected: _filter == 1,
                onTap: () => setState(() => _filter = 1),
                selectedColor: t.green,
                selectedForeground: t.screenBase,
              ),
              const SizedBox(width: 8),
              TournamentFilterChip(
                label: "Didn't Participate (0)",
                selected: _filter == 2,
                onTap: () => setState(() => _filter = 2),
                selectedColor: t.green,
                selectedForeground: t.screenBase,
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        if (demo)
          for (var i = 0; i < _demoTeams.length; i++) ...[
            _demoTeams[i],
            if (i != _demoTeams.length - 1) const SizedBox(height: 12),
          ]
        else
          for (var i = 0; i < registrations.length; i++) ...[
            TournamentTeamRankCard(
              rank: i + 1,
              name: registrations[i].name,
              captain: registrations[i].players.isNotEmpty
                  ? registrations[i].players.first.name
                  : '--',
              played: '6',
              wins: '6',
              prizes: '2',
              rankLabel: i == 0
                  ? 'Winner'
                  : i == 1
                      ? 'Runner-up'
                      : i < 4
                          ? 'Semi-finalist'
                          : 'Quarter-finalist',
              rankColor: i == 0
                  ? t.gold
                  : i == 1
                      ? t.dim
                      : t.orange,
              onView: widget.onViewTeam == null
                  ? null
                  : () => widget.onViewTeam!(registrations[i]),
            ),
            if (i != registrations.length - 1) const SizedBox(height: 12),
          ],
      ],
    );
  }

  List<Widget> get _demoTeams => const [
        TournamentTeamRankCard(
          rank: 1,
          name: 'Hyd Highlanders',
          captain: 'Teja Nair',
          played: '6',
          wins: '6',
          prizes: '10',
          rankLabel: 'Winner',
          rankColor: Color(0xFFF4B41A),
        ),
        TournamentTeamRankCard(
          rank: 2,
          name: 'Delhi Warriors',
          captain: 'Teja Nair',
          played: '6',
          wins: '6',
          prizes: '2',
          rankLabel: 'Runner-up',
          rankColor: Color(0xFFAAAAAA),
        ),
        TournamentTeamRankCard(
          rank: 3,
          name: 'Falcons XI',
          captain: 'Teja Nair',
          played: '6',
          wins: '6',
          prizes: '2',
          rankLabel: 'Semi-finalist',
          rankColor: Color(0xFFF9794C),
        ),
        TournamentTeamRankCard(
          rank: 4,
          name: 'Hitech Hurricanes',
          captain: 'Teja Nair',
          played: '6',
          wins: '6',
          prizes: '2',
          rankLabel: 'Semi-finalist',
          rankColor: Color(0xFFF9794C),
        ),
        TournamentTeamRankCard(
          rank: 5,
          name: 'Habsiguda Hawks',
          captain: 'Teja Nair',
          played: '6',
          wins: '6',
          prizes: '2',
          rankLabel: 'Quarter-finalist',
          rankColor: Color(0xFFAAAAAA),
        ),
      ];
}
