import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ui_kit/ui_kit.dart';

class MatchHistoryScreen extends StatefulWidget {
  const MatchHistoryScreen({super.key});

  @override
  State<MatchHistoryScreen> createState() => _MatchHistoryScreenState();
}

class _MatchHistoryScreenState extends State<MatchHistoryScreen> {
  int _selectedTab = 0; // 0: This Week, 1: This Month, 2: All Matches
  final List<String> _tabs = ['This Week', 'This Month', 'All Matches'];

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: cs.onSurface),
          onPressed: () => context.pop(),
        ),
        title: Text('Match History',
            style: GoogleFonts.spaceGrotesk(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: cs.onSurface)),
      ),
      body: Column(
        children: [
          // --- Tabs ---
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: SportoSegmentedControl(
              items: _tabs,
              selectedIndex: _selectedTab,
              onChanged: (i) => setState(() => _selectedTab = i),
            ),
          ),

          // Sort/Filter Bar (Only visible on 'All Matches')
          if (_selectedTab == 2)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  RichText(
                      text: TextSpan(style: TextStyle(fontSize: 13), children: [
                    TextSpan(
                        text: 'Sort By: ',
                        style: TextStyle(color: cs.onSurfaceVariant)),
                    TextSpan(
                        text: 'Popularity',
                        style: TextStyle(
                            color: cs.onTertiary, fontWeight: FontWeight.w600)),
                  ])),
                  TextButton.icon(
                    onPressed: () {},
                    icon: Icon(Icons.filter_list_rounded,
                        color: cs.onSurfaceVariant, size: 18),
                    label: Text('Filter',
                        style: TextStyle(
                            color: cs.onSurfaceVariant, fontSize: 13)),
                  ),
                ],
              ),
            ),

          // --- Match List ---
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: 4, // Demo count
              separatorBuilder: (_, __) => const SizedBox(height: 16),
              itemBuilder: (context, index) => const SportoMatchCard(
                variant: SportoMatchCardVariant.completed,
                tournamentName: 'Jaipur Super Over',
                location: 'Hyderabad',
                timeLabel: 'Yesterday, 06:30 PM',
                teamA: 'Delhi Warriors',
                scoreA: '90/2',
                teamB: 'Hyd Highlanders',
                scoreB: '85/3',
                noteLabel: 'Delhi Warriors Won',
              ),
            ),
          ),
        ],
      ),
    );
  }
}
