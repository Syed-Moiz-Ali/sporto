import 'package:flutter/material.dart';
import 'package:ui_kit/ui_kit.dart';

/// Loading placeholders for the tournament redesign. All blocks use the
/// shared [SportoShimmer] so the loading language stays consistent with the
/// rest of the partner app.
class TournamentCardShimmer extends StatelessWidget {
  const TournamentCardShimmer({super.key, this.height = 190});

  final double height;

  @override
  Widget build(BuildContext context) {
    final t = context.sportoTournament;
    return Container(
      height: height,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: t.card,
        borderRadius: BorderRadius.circular(t.r11),
        border: Border.all(color: t.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              SportoShimmer(width: 78, height: 22, borderRadius: t.r11),
              const SizedBox(width: 10),
              SportoShimmer(width: 90, height: 12, borderRadius: 4),
              const Spacer(),
              SportoShimmer(width: 70, height: 12, borderRadius: 4),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              SportoShimmer(width: 54, height: 54, borderRadius: t.r11),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SportoShimmer(width: 170, height: 16, borderRadius: 4),
                    const SizedBox(height: 7),
                    SportoShimmer(width: 130, height: 12, borderRadius: 4),
                    const SizedBox(height: 7),
                    SportoShimmer(width: 100, height: 11, borderRadius: 4),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          SportoShimmer(height: 12, borderRadius: 4),
          const SizedBox(height: 8),
          SportoShimmer(height: 4, borderRadius: 99),
        ],
      ),
    );
  }
}

class LiveCardShimmer extends StatelessWidget {
  const LiveCardShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    final t = context.sportoTournament;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: t.liveCardGradient,
        borderRadius: BorderRadius.circular(t.r11),
        border: Border.all(color: t.live.withValues(alpha: .2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              SportoShimmer(width: 80, height: 22, borderRadius: 99),
              const SizedBox(width: 10),
              SportoShimmer(width: 80, height: 11, borderRadius: 4),
              const Spacer(),
              SportoShimmer(width: 90, height: 11, borderRadius: 4),
            ],
          ),
          const SizedBox(height: 14),
          SportoShimmer(width: 210, height: 18, borderRadius: 4),
          const SizedBox(height: 8),
          SportoShimmer(width: 140, height: 12, borderRadius: 4),
          const SizedBox(height: 14),
          SportoShimmer(height: 54, borderRadius: t.r9),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: SportoShimmer(height: 38, borderRadius: t.r9)),
              const SizedBox(width: 10),
              Expanded(child: SportoShimmer(height: 38, borderRadius: t.r9)),
            ],
          ),
        ],
      ),
    );
  }
}

class TournamentListScreenShimmer extends StatelessWidget {
  const TournamentListScreenShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 24),
      children: const [
        Row(
          children: [
            SportoShimmer(width: 130, height: 20, borderRadius: 4),
            Spacer(),
            SportoShimmer(width: 76, height: 28, borderRadius: 10),
          ],
        ),
        SizedBox(height: 18),
        LiveCardShimmer(),
        SizedBox(height: 18),
        Row(
          children: [
            SportoShimmer(width: 96, height: 32, borderRadius: 99),
            SizedBox(width: 8),
            SportoShimmer(width: 84, height: 32, borderRadius: 99),
            SizedBox(width: 8),
            SportoShimmer(width: 90, height: 32, borderRadius: 99),
          ],
        ),
        SizedBox(height: 16),
        TournamentCardShimmer(),
        SizedBox(height: 14),
        TournamentCardShimmer(),
        SizedBox(height: 14),
        TournamentCardShimmer(),
      ],
    );
  }
}

class TournamentDetailScreenShimmer extends StatelessWidget {
  const TournamentDetailScreenShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    final t = context.sportoTournament;
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
      children: [
        Row(
          children: [
            SportoShimmer(width: 38, height: 38, borderRadius: t.r11),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SportoShimmer(width: 190, height: 18, borderRadius: 4),
                  const SizedBox(height: 6),
                  SportoShimmer(width: 120, height: 11, borderRadius: 4),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        SportoShimmer(height: 44, borderRadius: t.r10),
        const SizedBox(height: 18),
        const Row(
          children: [
            SportoShimmer(width: 44, height: 15, borderRadius: 4),
            SizedBox(width: 18),
            SportoShimmer(width: 60, height: 15, borderRadius: 4),
            SizedBox(width: 18),
            SportoShimmer(width: 52, height: 15, borderRadius: 4),
            SizedBox(width: 18),
            SportoShimmer(width: 44, height: 15, borderRadius: 4),
          ],
        ),
        const SizedBox(height: 18),
        SportoShimmer(height: 54, borderRadius: t.r10),
        const SizedBox(height: 12),
        SportoShimmer(height: 130, borderRadius: t.r11),
        const SizedBox(height: 12),
        SportoShimmer(height: 130, borderRadius: t.r11),
        const SizedBox(height: 12),
        SportoShimmer(height: 130, borderRadius: t.r11),
      ],
    );
  }
}

class LeaderboardShimmer extends StatelessWidget {
  const LeaderboardShimmer({super.key, this.rows = 6});

  final int rows;

  @override
  Widget build(BuildContext context) {
    final t = context.sportoTournament;
    return Column(
      children: [
        for (var i = 0; i < rows; i++) ...[
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            decoration: BoxDecoration(
              color: t.cardAlt,
              borderRadius: BorderRadius.circular(t.r9),
              border: Border.all(color: t.border),
            ),
            child: Row(
              children: [
                SportoShimmer(width: 28, height: 28, borderRadius: t.r6),
                const SizedBox(width: 10),
                SportoShimmer(width: 38, height: 38, borderRadius: t.r6),
                const SizedBox(width: 10),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SportoShimmer(width: 150, height: 14, borderRadius: 4),
                      SizedBox(height: 6),
                      SportoShimmer(width: 110, height: 11, borderRadius: 4),
                    ],
                  ),
                ),
                SportoShimmer(width: 32, height: 18, borderRadius: 4),
              ],
            ),
          ),
          if (i != rows - 1) const SizedBox(height: 8),
        ],
      ],
    );
  }
}

class VenueScheduleShimmer extends StatelessWidget {
  const VenueScheduleShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    final t = context.sportoTournament;
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
      children: [
        SportoShimmer(width: 210, height: 18, borderRadius: 4),
        const SizedBox(height: 16),
        SportoShimmer(height: 44, borderRadius: t.r10),
        const SizedBox(height: 14),
        SportoShimmer(height: 72, borderRadius: t.r11),
        const SizedBox(height: 14),
        SportoShimmer(height: 120, borderRadius: t.r11),
        const SizedBox(height: 14),
        for (var i = 0; i < 3; i++) ...[
          SportoShimmer(height: 190, borderRadius: t.r11),
          const SizedBox(height: 12),
        ],
      ],
    );
  }
}

class PrizePoolShimmer extends StatelessWidget {
  const PrizePoolShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    final t = context.sportoTournament;
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
      children: [
        SportoShimmer(width: 110, height: 18, borderRadius: 4),
        const SizedBox(height: 16),
        SportoShimmer(height: 44, borderRadius: t.r10),
        const SizedBox(height: 14),
        SportoShimmer(height: 72, borderRadius: t.r11),
        const SizedBox(height: 14),
        SportoShimmer(height: 210, borderRadius: t.r11),
        const SizedBox(height: 12),
        SportoShimmer(height: 56, borderRadius: t.r11),
        const SizedBox(height: 12),
        for (var i = 0; i < 4; i++) ...[
          SportoShimmer(height: 48, borderRadius: t.r9),
          const SizedBox(height: 8),
        ],
      ],
    );
  }
}

class PlayerDetailsShimmer extends StatelessWidget {
  const PlayerDetailsShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    final t = context.sportoTournament;
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
      children: [
        SportoShimmer(width: 210, height: 18, borderRadius: 4),
        const SizedBox(height: 16),
        SportoShimmer(height: 310, borderRadius: t.r14),
        const SizedBox(height: 18),
        SportoShimmer(width: 90, height: 15, borderRadius: 4),
        const SizedBox(height: 10),
        SportoShimmer(height: 140, borderRadius: t.r11),
        const SizedBox(height: 18),
        SportoShimmer(width: 130, height: 15, borderRadius: 4),
        const SizedBox(height: 10),
        SportoShimmer(height: 170, borderRadius: t.r11),
        const SizedBox(height: 18),
        for (var i = 0; i < 4; i++) ...[
          SportoShimmer(height: 58, borderRadius: t.r9),
          const SizedBox(height: 8),
        ],
      ],
    );
  }
}
