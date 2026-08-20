import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:partner_data/partner_data.dart';
import 'package:ui_kit/ui_kit.dart';

import '../../../../app/router/app_router.dart';
import '../../../partner_api/application/partner_api_bloc.dart';

class MatchHistoryScreen extends StatefulWidget {
  final bool embedded;

  const MatchHistoryScreen({
    super.key,
    this.embedded = false,
  });

  @override
  State<MatchHistoryScreen> createState() => _MatchHistoryScreenState();
}

class _MatchHistoryScreenState extends State<MatchHistoryScreen> {
  int _selectedTab = 0;
  static const _tabs = ['All', 'Upcoming', 'Live', 'Completed'];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final bloc = context.read<PartnerApiBloc>();
      if (bloc.state is! PartnerApiLoadedState) {
        bloc.add(const LoadPartnerApiBootstrapEvent());
      } else {
        final loaded = bloc.state as PartnerApiLoadedState;
        if (loaded.tournaments.isEmpty) {
          bloc.add(const LoadPartnerTournamentsEvent());
        }
      }
    });
  }

  int? _getApiStatusForTab(int index) {
    switch (index) {
      case 1:
        return 1; // Draft / Upcoming (status 1)
      case 2:
        return 6; // Live (status 6)
      case 3:
        return 7; // Completed (status 7)
      default:
        return null; // All
    }
  }

  List<PartnerTournamentResponse> _filterTournaments(
      List<PartnerTournamentResponse> all) {
    switch (_selectedTab) {
      case 1: // Upcoming / Drafts (status 1 to 5)
        return all.where((t) => t.status >= 1 && t.status <= 5).toList();
      case 2: // Live (status 6)
        return all.where((t) => t.status == 6).toList();
      case 3: // Completed (status 7)
        return all.where((t) => t.status == 7).toList();
      default: // All
        return all;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final scale = context.sportoScale;

    final content = SafeArea(
      bottom: false,
      child: SportoResponsiveContent(
        padding: EdgeInsets.zero,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(
                context.sportoResponsive.horizontalPadding,
                20 * scale,
                context.sportoResponsive.horizontalPadding,
                8 * scale,
              ),
              child: BlocBuilder<PartnerApiBloc, PartnerApiState>(
                builder: (context, state) {
                  final loaded = state is PartnerApiLoadedState ? state : null;
                  final all = loaded?.tournaments ?? [];
                  final filtered = _filterTournaments(all);
                  final count = loaded != null ? filtered.length : 0;
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Partner Tournaments",
                          style: theme.textTheme.titleLarge
                              ?.copyWith(fontSize: 18 * scale)),
                      Text('$count Tournaments',
                          style: theme.textTheme.bodyMedium
                              ?.copyWith(color: context.sporto.info)),
                    ],
                  );
                },
              ),
            ),
            SizedBox(
              height: 42 * scale,
              child: ListView.separated(
                padding: EdgeInsets.symmetric(
                  horizontal: context.sportoResponsive.horizontalPadding,
                ),
                scrollDirection: Axis.horizontal,
                itemCount: _tabs.length,
                separatorBuilder: (_, __) => SizedBox(width: 28 * scale),
                itemBuilder: (_, index) => InkWell(
                  onTap: () {
                    if (_selectedTab != index) {
                      setState(() => _selectedTab = index);
                      final apiStatus = _getApiStatusForTab(index);
                      context
                          .read<PartnerApiBloc>()
                          .add(LoadPartnerTournamentsEvent(status: apiStatus));
                    }
                  },
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(_tabs[index],
                          style: theme.textTheme.bodyLarge?.copyWith(
                              fontSize: 13 * scale,
                              color: index == _selectedTab
                                  ? cs.onSurface
                                  : cs.onSurfaceVariant)),
                      SizedBox(height: 8 * scale),
                      Container(
                          width: 18 * scale,
                          height: 2 * scale,
                          color: index == _selectedTab
                              ? cs.tertiary
                              : Colors.transparent),
                    ],
                  ),
                ),
              ),
            ),
            Divider(height: 1, color: context.sporto.border),
            Expanded(
              child: BlocBuilder<PartnerApiBloc, PartnerApiState>(
                builder: (context, state) {
                  final isLoading = state is PartnerApiLoadingState || state is PartnerApiInitialState;
                  final loaded = state is PartnerApiLoadedState ? state : null;
                  final all = loaded?.tournaments ?? [];
                  final filtered = _filterTournaments(all);

                  return ListView(
                    padding: EdgeInsets.fromLTRB(
                      context.sportoResponsive.horizontalPadding,
                      26 * scale,
                      context.sportoResponsive.horizontalPadding,
                      context.sportoResponsive.bottomContentPadding(context),
                    ),
                    children: _matchCards(scale, filtered, isLoading: isLoading),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
    return widget.embedded ? content : SportoScreenShell(body: content);
  }

  List<Widget> _matchCards(
      double scale, List<PartnerTournamentResponse> tournaments,
      {bool isLoading = false}) {
    if (isLoading) {
      // Skeleton shimmer placeholders while loading
      return [
        for (var index = 0; index < 3; index++) ...[
          SportoSkeletonCard(height: 140 * scale),
          if (index != 2) SizedBox(height: 16 * scale),
        ],
      ];
    }

    if (tournaments.isEmpty) {
      return [
        Padding(
          padding: EdgeInsets.only(top: 40 * scale),
          child: Center(
            child: Text(
              'No tournaments found',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
                fontSize: 14 * scale,
              ),
            ),
          ),
        ),
      ];
    }

    // Dynamic rendering using exact SportoCricketMatchCard UI populated with API properties
    return [
      for (var index = 0; index < tournaments.length; index++) ...[
        _buildDynamicMatchCard(tournaments[index]),
        if (index != tournaments.length - 1) SizedBox(height: 16 * scale),
      ],
    ];
  }

  Widget _buildDynamicMatchCard(PartnerTournamentResponse t) {
    final matchState = switch (t.status) {
      6 => SportoCricketMatchState.live,
      7 => SportoCricketMatchState.completed,
      8 => SportoCricketMatchState.delayed,
      _ => SportoCricketMatchState.upcoming,
    };
    final venue =
        t.tournamentVenues.isNotEmpty ? t.tournamentVenues.first : null;
    final timeStr = t.tournamentStartAt != null
        ? _formatDate(t.tournamentStartAt!)
        : 'Today, 06:30 PM';
    final venueLocation = venue?.location ?? venue?.venueName ?? 'Hyderabad';

    return SportoCricketMatchCard(
      state: matchState,
      tournamentName: t.name,
      locationName: venueLocation,
      stageName: venue?.roundName ?? t.workflowStatus.label,
      statusLabel: t.workflowStatus.label,
      timeLabel: timeStr,
      teamALabel: 'Registered: ${t.registeredTeams ?? 0} Teams',
      teamBLabel: t.maximumTeams != null
          ? 'Max: ${t.maximumTeams} Teams'
          : 'Open Registration',
      onTap: () => context.push(AppRouter.tournamentDetailRoute('${t.id}')),
    );
  }

  String _formatDate(String raw) {
    try {
      final dt = DateTime.parse(raw);
      const months = [
        'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
        'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
      ];
      return '${dt.day} ${months[dt.month - 1]} ${dt.year}';
    } catch (_) {
      return raw;
    }
  }
}
