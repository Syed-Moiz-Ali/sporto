import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:ui_kit/ui_kit.dart';

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
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
              child: SizedBox(
                width: double.infinity,
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
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontSize: 18, fontWeight: FontWeight.w700)),
                    const SizedBox(height: 4),
                    Text('6 Matches Assigned',
                        style: TextStyle(
                            color: Colors.blue.shade300,
                            fontSize: 14,
                            fontWeight: FontWeight.w500)),
                  ],
                ),
              ),
            ),

            // Tabs
            Align(
              alignment: Alignment.centerLeft,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 20),
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
            ),
            const SizedBox(height: 16),

            // Match List
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 90),
                itemCount: _selectedTab == 0 ? 4 : 1,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final state = _selectedTab == 0
                      ? SportoCricketMatchState.values[index]
                      : switch (_selectedTab) {
                          1 => SportoCricketMatchState.upcoming,
                          2 => SportoCricketMatchState.live,
                          _ => SportoCricketMatchState.completed,
                        };
                  return SportoCricketMatchCard(state: state);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
