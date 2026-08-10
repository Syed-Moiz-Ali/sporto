import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:ui_kit/ui_kit.dart';

import '../../../../app/router/app_router.dart';

/// Referee shell tab showing matches that currently accept score updates.
class RefereeScoringTabScreen extends StatelessWidget {
  const RefereeScoringTabScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Stack(
      children: [
        const SportoAmbientBackground(),
        SafeArea(
          bottom: false,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 19, 20, 88),
            children: [
              Text(
                "Today's Matches",
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '6 Matches Assigned',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: const Color(0xFF58C6F5),
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 21),
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => context.push(AppRouter.liveScoringPath),
                child: const SportoCricketMatchCard(
                  state: SportoCricketMatchState.live,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
