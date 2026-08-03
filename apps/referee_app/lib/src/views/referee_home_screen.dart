import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:core/core.dart';
import 'package:ui_kit/ui_kit.dart';
import 'package:shared_domain/shared_domain.dart';
import '../bloc/match_scoring_bloc.dart';
import 'match_verification_screen.dart';
import 'conduct_toss_screen.dart';
import 'live_scorekeeper_screen.dart';

class RefereeHomeScreen extends StatefulWidget {
  const RefereeHomeScreen({super.key});

  @override
  State<RefereeHomeScreen> createState() => _RefereeHomeScreenState();
}

class _RefereeHomeScreenState extends State<RefereeHomeScreen> {
  @override
  void initState() {
    super.initState();
    context.read<MatchScoringBloc>().add(LoadMatchesEvent());
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(70),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(Icons.sports_score, color: colorScheme.primary, size: 28),
                    const SizedBox(width: 8),
                    Text(
                      'SPORTO Referee',
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: colorScheme.onSurface,
                          ),
                    ),
                  ],
                ),
                BlocBuilder<ConnectivityBloc, ConnectivityState>(
                  builder: (context, state) {
                    final isConn = state is ConnectivityStatusState ? state.isConnected : true;
                    final pending = state is ConnectivityStatusState ? state.pendingItemsCount : 0;
                    final isSyncing = state is ConnectivityStatusState ? state.isSyncing : false;

                    return SyncIndicatorBadge(
                      isConnected: isConn,
                      isSyncing: isSyncing,
                      pendingItemsCount: pending,
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Official Umpire Banner
            GlassContainer(
              padding: const EdgeInsets.all(16),
              hasGlow: true,
              backgroundColor: colorScheme.primary.withValues(alpha: 0.12),
              borderColor: colorScheme.primary.withValues(alpha: 0.35),
              child: Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: colorScheme.primary.withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                      border: Border.all(color: colorScheme.primary, width: 2),
                    ),
                    child: Icon(Icons.badge, color: colorScheme.primary, size: 26),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Official Ref. Alex Vance',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: colorScheme.onSurface),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Certified Umpire Badge ID: #UM-9921',
                          style: TextStyle(color: colorScheme.primary, fontSize: 12, fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            Text(
              'Assigned Matches Dashboard',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: colorScheme.onSurface),
            ),
            const SizedBox(height: 12),

            Expanded(
              child: BlocConsumer<MatchScoringBloc, MatchScoringState>(
                listener: (context, state) {
                  if (state is MatchCompletedState) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Match Completed! Winner: ${state.winnerName}'),
                        backgroundColor: colorScheme.primary,
                      ),
                    );
                  }
                },
                builder: (context, state) {
                  if (state is MatchScoringLoadingState) {
                    return Center(child: CircularProgressIndicator(color: colorScheme.primary));
                  } else if (state is MatchScoringListLoadedState) {
                    if (state.matches.isEmpty) {
                      return const Center(child: Text('No assigned matches found.'));
                    }

                    return ListView.builder(
                      itemCount: state.matches.length,
                      itemBuilder: (context, index) {
                        final m = state.matches[index];
                        return _buildMatchCard(context, m, colorScheme);
                      },
                    );
                  }
                  return const Center(child: Text('Loading assigned matches...'));
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMatchCard(BuildContext context, CricketMatchEntity match, ColorScheme colorScheme) {
    String actionLabel;
    VoidCallback? onAction;

    switch (match.status) {
      case MatchStatus.upcoming:
        actionLabel = 'Verify Roster';
        onAction = () {
          Navigator.of(context).push(MaterialPageRoute(
            builder: (_) => MatchVerificationScreen(match: match),
          ));
        };
        break;

      case MatchStatus.verification:
      case MatchStatus.toss:
        actionLabel = match.tossResult == null ? 'Conduct Toss' : 'Open Scorekeeper';
        onAction = () {
          if (match.tossResult == null) {
            Navigator.of(context).push(MaterialPageRoute(
              builder: (_) => ConductTossScreen(match: match),
            ));
          } else {
            Navigator.of(context).push(MaterialPageRoute(
              builder: (_) => LiveScorekeeperScreen(match: match),
            ));
          }
        };
        break;

      case MatchStatus.live:
        actionLabel = 'Open Scorekeeper Engine';
        onAction = () {
          Navigator.of(context).push(MaterialPageRoute(
            builder: (_) => LiveScorekeeperScreen(match: match),
          ));
        };
        break;

      case MatchStatus.completed:
        actionLabel = 'View Result';
        onAction = () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Match Completed - Results Synced')),
          );
        };
        break;
    }

    final statusColor = _getStatusColor(match.status, colorScheme);

    return GlassContainer(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      backgroundColor: colorScheme.surfaceContainer,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(match.tournamentName, style: TextStyle(color: colorScheme.primary, fontWeight: FontWeight.bold, fontSize: 12)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  match.status.name.toUpperCase(),
                  style: TextStyle(color: statusColor, fontSize: 10, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '${match.teamA.logoEmoji} ${match.teamA.name} vs ${match.teamB.logoEmoji} ${match.teamB.name}',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: colorScheme.onSurface),
          ),
          const SizedBox(height: 4),
          Text('Venue: ${match.venue}', style: TextStyle(color: colorScheme.onSurfaceVariant, fontSize: 12)),
          const SizedBox(height: 14),
          GlassButton(
            label: actionLabel,
            height: 44,
            isPrimary: match.status != MatchStatus.completed,
            onPressed: onAction,
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(MatchStatus status, ColorScheme colorScheme) {
    switch (status) {
      case MatchStatus.upcoming:
        return colorScheme.primary;
      case MatchStatus.verification:
        return colorScheme.secondary;
      case MatchStatus.toss:
        return colorScheme.primary;
      case MatchStatus.live:
        return colorScheme.error;
      case MatchStatus.completed:
        return colorScheme.onSurfaceVariant;
    }
  }
}
