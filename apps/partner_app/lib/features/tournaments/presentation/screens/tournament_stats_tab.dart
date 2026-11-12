import 'package:flutter/material.dart';
import 'package:ui_kit/ui_kit.dart';

import '../widgets/redesign/tournament_cards.dart';
import '../widgets/redesign/tournament_navigation.dart';
import '../widgets/redesign/tournament_redesign_data.dart';
import '../widgets/redesign/tournament_visuals.dart';

class TournamentStatsTab extends StatefulWidget {
  const TournamentStatsTab({
    super.key,
    this.onViewPlayer,
  });

  final ValueChanged<DemoLeaderboardEntry>? onViewPlayer;

  @override
  State<TournamentStatsTab> createState() => _TournamentStatsTabState();
}

class _TournamentStatsTabState extends State<TournamentStatsTab> {
  int _mode = 0;
  int _subTab = 0;

  List<DemoStatTab> get _tabs {
    return switch (_mode) {
      0 => demoBattingTabs,
      1 => demoBowlingTabs,
      _ => demoOverallTabs,
    };
  }

  @override
  Widget build(BuildContext context) {
    final t = context.sportoTournament;
    final tabs = _tabs;
    final safeSub = _subTab.clamp(0, tabs.length - 1);
    final active = tabs[safeSub];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Center(
          child: TournamentSegmentedControl(
            labels: const ['Batting', 'Bowling', 'Overall'],
            selectedIndex: _mode,
            onChanged: (index) => setState(() {
              _mode = index;
              _subTab = 0;
            }),
          ),
        ),
        const SizedBox(height: 16),
        TournamentSubTabs(
          labels: tabs.map((tab) => tab.label).toList(),
          selectedIndex: safeSub,
          onChanged: (index) => setState(() => _subTab = index),
        ),
        const SizedBox(height: 14),
        TournamentSurface(
          radius: t.r11,
          padding: const EdgeInsets.all(12),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      active.label,
                      style: SportoTextStyles.text(
                        size: SportoTextStyles.size15,
                        color: t.muted,
                      ),
                    ),
                  ),
                  Text(
                    active.unit,
                    style: SportoTextStyles.text(
                      size: SportoTextStyles.size12,
                      color: t.dim,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              for (var i = 0; i < active.entries.length; i++) ...[
                TournamentLeaderboardRow(
                  rank: i + 1,
                  name: active.entries[i].name,
                  subtitle:
                      '${active.entries[i].team} · ${active.entries[i].subtitle}',
                  value: active.entries[i].value,
                  onTap: widget.onViewPlayer == null
                      ? null
                      : () => widget.onViewPlayer!(active.entries[i]),
                ),
                if (i != active.entries.length - 1) const SizedBox(height: 8),
              ],
              const SizedBox(height: 12),
              TournamentSurface(
                radius: t.r9,
                color: t.cardAlt,
                borderColor: t.border,
                padding: const EdgeInsets.symmetric(vertical: 10),
                onTap: () {},
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'View All (64)',
                      style: SportoTextStyles.text(
                        size: SportoTextStyles.size13,
                        color: t.blue,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Icon(Icons.arrow_forward_rounded, size: 15, color: t.blue),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
