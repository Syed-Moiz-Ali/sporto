import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ui_kit/ui_kit.dart';
import '../../../../app/router/app_router.dart';

class MatchesListScreen extends StatefulWidget {
  const MatchesListScreen({super.key});

  @override
  State<MatchesListScreen> createState() => _MatchesListScreenState();
}

class _MatchesListScreenState extends State<MatchesListScreen> {
  int _selectedTab = 0;
  final List<String> _tabs = ['All', 'Upcoming', 'Live', 'Completed'];

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (Navigator.of(context).canPop())
                    Align(
                      alignment: Alignment.centerLeft,
                      child: IconButton(
                        icon: Icon(Icons.arrow_back_ios_new_rounded,
                            color: cs.onSurface, size: 20),
                        onPressed: () => context.pop(),
                      ),
                    ),
                  Text('Today\'s Matches',
                      style: GoogleFonts.spaceGrotesk(
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                          color: cs.onSurface)),
                  const SizedBox(height: 4),
                  Text('6 Matches Assigned',
                      style: TextStyle(
                          color: Colors.blue.shade300,
                          fontSize: 14,
                          fontWeight: FontWeight.w500)),
                ],
              ),
            ),

            // Tabs
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: List.generate(
                    _tabs.length,
                    (i) => Padding(
                          padding: const EdgeInsets.only(right: 24),
                          child: GestureDetector(
                            onTap: () => setState(() => _selectedTab = i),
                            child: Column(
                              children: [
                                Text(_tabs[i],
                                    style: TextStyle(
                                        color: _selectedTab == i
                                            ? cs.onSurface
                                            : cs.onSurfaceVariant
                                                .withOpacity(0.6),
                                        fontSize: 15,
                                        fontWeight: _selectedTab == i
                                            ? FontWeight.w600
                                            : FontWeight.normal)),
                                const SizedBox(height: 8),
                                Container(
                                  height: 2,
                                  width: 24,
                                  color: _selectedTab == i
                                      ? cs.tertiary
                                      : Colors.transparent,
                                ),
                              ],
                            ),
                          ),
                        )),
              ),
            ),
            const SizedBox(height: 16),

            // Match List
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: 4,
                separatorBuilder: (_, __) => const SizedBox(height: 16),
                itemBuilder: (context, index) {
                  if (index == 0) return _LiveMatchCard();
                  if (index == 1) return _UpcomingMatchCard();
                  if (index == 2) return _CompletedMatchCard();
                  return _DelayedMatchCard();
                },
              ),
            ),
          ],
        ),
      ),
      // Demo Toggle
      floatingActionButton: FloatingActionButton.small(
        onPressed: () => context.push(AppRouter.liveScoringRoute),
        child: const Icon(Icons.play_arrow_rounded),
      ),
    );
  }

  // --- MATCH CARDS ---

  // --- MATCH CARDS (centralized SportoMatchCard) ---

  Widget _LiveMatchCard() {
    return SportoMatchCard(
      variant: SportoMatchCardVariant.live,
      tournamentName: 'Jaipur Super Over',
      location: 'Hyderabad',
      stage: 'Final',
      overLabel: 'Over - 2.1',
      teamA: 'Thunder Titans',
      scoreA: '28/1',
      teamB: 'Royal Strikers',
      scoreB: 'Yet to Bat',
      infoLabel: 'Duration',
      infoValue: '08:25',
      middle: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          RichText(
              text: TextSpan(style: TextStyle(fontSize: 12), children: [
            TextSpan(
                text: 'Current Batter ',
                style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurfaceVariant)),
            TextSpan(
                text: 'Rahul',
                style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurface,
                    fontWeight: FontWeight.w600))
          ])),
          RichText(
              text: TextSpan(style: TextStyle(fontSize: 12), children: [
            TextSpan(
                text: 'Current Bowler ',
                style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurfaceVariant)),
            TextSpan(
                text: 'Amit',
                style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurface,
                    fontWeight: FontWeight.w600))
          ])),
        ],
      ),
      actionLabel: 'Continue Scoring',
      actionColor: Colors.redAccent,
      onAction: () => context.push(AppRouter.liveScoringRoute),
    );
  }

  Widget _UpcomingMatchCard() {
    return SportoMatchCard(
      variant: SportoMatchCardVariant.upcoming,
      tournamentName: 'Asia Cup 2026',
      location: 'Hyderabad',
      stage: 'Quarter Final',
      timeLabel: 'Today, 06:30 PM',
      teamA: 'Delhi Warriors',
      teamB: 'Hyd Highlanders',
      startsInLabel: '24 mins',
      statusItems: const [
        SportoStatusItem(Icons.check_circle_outline_rounded, Color(0xFF27A166),
            'Teams Verified'),
        SportoStatusItem(Icons.check_circle_outline_rounded, Color(0xFF27A166),
            'Ground Ready'),
        SportoStatusItem(
            Icons.warning_amber_rounded, Colors.orange, 'Toss Pending'),
      ],
      actionLabel: 'Verify Teams',
      actionColor: Colors.blue,
      onAction: () => context.push(AppRouter.matchVerificationRoute),
    );
  }

  Widget _CompletedMatchCard() {
    return SportoMatchCard(
      variant: SportoMatchCardVariant.completed,
      tournamentName: 'Asia Cup 2026',
      location: 'Hyderabad',
      stage: 'Final',
      timeLabel: 'Today, 10:30 AM',
      teamA: 'Delhi Warriors',
      scoreA: '90/2',
      teamB: 'Hyd Highlanders',
      scoreB: '85/3',
      noteLabel: 'Delhi Warriors Won',
      actionLabel: 'View Report',
    );
  }

  Widget _DelayedMatchCard() {
    return SportoMatchCard(
      variant: SportoMatchCardVariant.delayed,
      tournamentName: 'Asia Cup 2026',
      location: 'Hyderabad',
      stage: 'Final',
      timeLabel: 'Today, 08:30 PM',
      teamA: 'Thunder Titans',
      scoreA: '28/1',
      teamB: 'Royal Strikers',
      scoreB: 'Yet to Bat',
      noteLabel: 'Heavy Rain',
      noteColor: Colors.redAccent,
      infoLabel: 'Resume Time',
      infoValue: '4:00 PM',
      actionLabel: 'Update Status',
      actionColor: Colors.orange,
    );
  }
}
