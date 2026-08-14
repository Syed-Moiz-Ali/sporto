import 'package:flutter/material.dart';
import 'package:ui_kit/ui_kit.dart';

import 'matches_list_screen.dart';
import 'profile_screen.dart';
import 'referee_home_screen.dart';
import 'referee_scoring_tab_screen.dart';

/// Authenticated shell: bottom navigation between Home / Matches /
/// Scoring / Profile tabs.
class RefereeShellScreen extends StatefulWidget {
  const RefereeShellScreen({super.key});

  @override
  State<RefereeShellScreen> createState() => _RefereeShellScreenState();
}

class _RefereeShellScreenState extends State<RefereeShellScreen> {
  final _shellKey = GlobalKey<SportoBottomTabShellState>();

  @override
  Widget build(BuildContext context) {
    return SportoBottomTabShell(
      key: _shellKey,
      tabs: [
        RefereeHomeScreen(
          onViewAll: () => _shellKey.currentState?.setIndex(1),
        ),
        const MatchesListScreen(),
        const RefereeScoringTabScreen(),
        const RefereeProfileScreen(),
      ],
      items: const [
        SportoNavItem(Icons.home_rounded, 'Home'),
        SportoNavItem(Icons.calendar_month_rounded, 'Matches'),
        SportoNavItem(Icons.sports_cricket_rounded, 'Scoring'),
        SportoNavItem(Icons.person_outline_rounded, 'Profile'),
      ],
    );
  }
}
