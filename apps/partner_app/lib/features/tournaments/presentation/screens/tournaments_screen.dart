import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:partner_data/partner_data.dart';
import 'package:ui_kit/ui_kit.dart';

import '../../../../app/router/app_router.dart';
import '../../../partner_api/application/partner_api_bloc.dart';
import '../widgets/partner_tournament_card.dart';

class TournamentsScreen extends StatefulWidget {
  final bool embedded;
  final bool? isLoading;

  const TournamentsScreen({super.key, this.embedded = false, this.isLoading});

  @override
  State<TournamentsScreen> createState() => _TournamentsScreenState();
}

class _TournamentsScreenState extends State<TournamentsScreen> {
  int _selectedTab = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      try {
        final bloc = context.read<PartnerApiBloc>();
        if (bloc.state is! PartnerApiLoadedState) {
          bloc.add(const LoadPartnerApiBootstrapEvent());
        } else {
          final loaded = bloc.state as PartnerApiLoadedState;
          if (loaded.tournaments.isEmpty) {
            bloc.add(const LoadPartnerTournamentsEvent());
          }
        }
      } catch (_) {}
    });
  }

  static const _tabs = ['All', 'Draft', 'Published'];

  /// Backend tournament statuses observed live: 1 = draft, 2 = published.
  /// (The contract lists 3-9, but the server only ever returns 1/2, so
  /// Live/Completed tabs were permanently empty — remapped to real states.)
  int? _getApiStatusForTab(int index) {
    switch (index) {
      case 1:
        return 1; // Draft
      case 2:
        return 2; // Published (submitted / approved)
      default:
        return null; // All
    }
  }

  List<PartnerTournamentResponse> _filterTournaments(
    List<PartnerTournamentResponse> all,
  ) {
    switch (_selectedTab) {
      case 1: // Draft
        return all.where((t) => t.status == 1).toList();
      case 2: // Published
        return all.where((t) => t.status == 2).toList();
      default: // All
        return all;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final scale = context.sportoScale;

    PartnerApiLoadedState? loaded;
    bool isApiLoading = false;
    String? apiError;
    try {
      final bloc = BlocProvider.of<PartnerApiBloc>(context, listen: true);
      isApiLoading = bloc.state is PartnerApiLoadingState ||
          bloc.state is PartnerApiInitialState;
      if (bloc.state is PartnerApiLoadedState) {
        loaded = bloc.state as PartnerApiLoadedState;
      } else if (bloc.state is PartnerApiErrorState) {
        apiError =
            (bloc.state as PartnerApiErrorState).message;
      }
    } catch (_) {}

    final isLoading = widget.isLoading ?? isApiLoading;
    final all = loaded?.tournaments ?? [];
    final filtered = _filterTournaments(all);
    final count = loaded != null ? filtered.length : 0;
    final listNotice = loaded?.tournamentsError;

    if (apiError != null && !isLoading) {
      return SportoScreenShell(
        body: Center(
          child: Padding(
            padding: EdgeInsets.all(24 * scale),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Tournaments could not be loaded.',
                  style: theme.textTheme.titleMedium,
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 6 * scale),
                Text(
                  apiError,
                  style: theme.textTheme.bodySmall
                      ?.copyWith(color: cs.onSurfaceVariant),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 16 * scale),
                SportoPillButton(
                  label: 'Try Again',
                  color: cs.primary,
                  gradient: context.sporto.primaryGradient,
                  filled: true,
                  foregroundColor: Colors.black,
                  height: 44 * scale,
                  onTap: () => context.read<PartnerApiBloc>().add(
                        const LoadPartnerApiBootstrapEvent(),
                      ),
                ),
              ],
            ),
          ),
        ),
      );
    }

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
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Tournaments',
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontSize: 18 * scale,
                          ),
                        ),
                        if (isLoading)
                          Padding(
                            padding: EdgeInsets.only(top: 4 * scale),
                            child: SportoShimmer(
                              width: 110 * scale,
                              height: 14 * scale,
                              borderRadius: 4,
                            ),
                          )
                        else
                          Text(
                            '$count Tournaments',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: context.sporto.info,
                            ),
                          ),
                      ],
                    ),
                  ),
                  SportoPillButton(
                    label: '+ Create',
                    color: cs.primary,
                    gradient: context.sporto.primaryGradient,
                    filled: true,
                    foregroundColor: Colors.black,
                    height: 32 * scale,
                    padding: EdgeInsets.symmetric(horizontal: 12 * scale),
                    fontSize: 12 * scale,
                    onTap: () => context.push(AppRouter.createTournamentRoute),
                  ),
                ],
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
                      try {
                        context.read<PartnerApiBloc>().add(
                              LoadPartnerTournamentsEvent(status: apiStatus),
                            );
                      } catch (_) {}
                    }
                  },
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        _tabs[index],
                        style: theme.textTheme.bodyLarge?.copyWith(
                          fontSize: 13 * scale,
                          color: index == _selectedTab
                              ? cs.onSurface
                              : cs.onSurfaceVariant,
                        ),
                      ),
                      SizedBox(height: 8 * scale),
                      Container(
                        width: 18 * scale,
                        height: 2 * scale,
                        color: index == _selectedTab
                            ? cs.tertiary
                            : Colors.transparent,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Divider(height: 1, color: context.sporto.border),
            if (listNotice != null && !isLoading)
              _ListNoticeBar(
                scale: scale,
                message: listNotice,
                onRetry: () {
                  try {
                    context.read<PartnerApiBloc>().add(
                          LoadPartnerTournamentsEvent(
                            status: _getApiStatusForTab(_selectedTab),
                          ),
                        );
                  } catch (_) {}
                },
              ),
            Expanded(
              child: ListView(
                padding: EdgeInsets.fromLTRB(
                  context.sportoResponsive.horizontalPadding,
                  26 * scale,
                  context.sportoResponsive.horizontalPadding,
                  context.sportoResponsive.bottomContentPadding(context),
                ),
                children: _matchCards(scale, filtered, isLoading: isLoading),
              ),
            ),
          ],
        ),
      ),
    );
    return widget.embedded ? content : SportoScreenShell(body: content);
  }

  List<Widget> _matchCards(
    double scale,
    List<PartnerTournamentResponse> tournaments, {
    bool isLoading = false,
  }) {
    if (isLoading) {
      // Skeleton shimmer placeholders matching match card layout
      return [
        for (var index = 0; index < 3; index++) ...[
          _buildTournamentCardShimmer(scale),
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

    // Partner-only cards populated with tournament API data.
    return [
      for (var index = 0; index < tournaments.length; index++) ...[
        _buildDynamicMatchCard(tournaments[index]),
        if (index != tournaments.length - 1) SizedBox(height: 16 * scale),
      ],
    ];
  }

  Widget _buildTournamentCardShimmer(double scale) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(12 * scale),
      decoration: BoxDecoration(
        color: const Color(0xFF13171E),
        borderRadius: BorderRadius.circular(16 * scale),
        border: Border.all(color: const Color(0xFF1F242C)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              SportoShimmer(
                width: 76 * scale,
                height: 22 * scale,
                borderRadius: 6 * scale,
              ),
              SportoShimmer(
                width: 100 * scale,
                height: 14 * scale,
                borderRadius: 4 * scale,
              ),
              SportoShimmer(
                width: 76 * scale,
                height: 22 * scale,
                borderRadius: 6 * scale,
              ),
            ],
          ),
          SizedBox(height: 10 * scale),
          SportoShimmer(
            width: 190 * scale,
            height: 16 * scale,
            borderRadius: 4 * scale,
          ),
          SizedBox(height: 7 * scale),
          Row(
            children: [
              SportoShimmer(
                width: 14 * scale,
                height: 14 * scale,
                borderRadius: 7 * scale,
              ),
              SizedBox(width: 6 * scale),
              SportoShimmer(
                width: 110 * scale,
                height: 12 * scale,
                borderRadius: 4 * scale,
              ),
            ],
          ),
          SizedBox(height: 12 * scale),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              SportoShimmer(
                width: 120 * scale,
                height: 12 * scale,
                borderRadius: 4 * scale,
              ),
              SportoShimmer(
                width: 100 * scale,
                height: 12 * scale,
                borderRadius: 4 * scale,
              ),
            ],
          ),
          SizedBox(height: 10 * scale),
          Container(height: 1, color: const Color(0xFF1F242C)),
          SizedBox(height: 10 * scale),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              SportoShimmer(
                width: 80 * scale,
                height: 12 * scale,
                borderRadius: 4 * scale,
              ),
              SportoShimmer(
                width: 115 * scale,
                height: 28 * scale,
                borderRadius: 100,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDynamicMatchCard(PartnerTournamentResponse t) {
    final venue =
        t.tournamentVenues.isNotEmpty ? t.tournamentVenues.first : null;
    final timeStr = t.tournamentStartAt != null
        ? _formatDate(t.tournamentStartAt!)
        : 'Schedule not set';
    final venueLocation =
        venue?.location ?? venue?.venueName ?? 'Venue not set';

    return PartnerTournamentCard(
      name: t.name,
      location: venueLocation,
      stage: venue?.roundName ?? t.workflowStatus.label,
      status: t.workflowStatus.label,
      date: timeStr,
      registeredTeams: t.registeredTeams ?? 0,
      maximumTeams: t.maximumTeams,
      isLive: t.status == 6,
      onTap: () => context.push(AppRouter.tournamentDetailRoute('${t.id}')),
    );
  }

  String _formatDate(String raw) {
    try {
      final dt = DateTime.parse(raw);
      const months = [
        'Jan',
        'Feb',
        'Mar',
        'Apr',
        'May',
        'Jun',
        'Jul',
        'Aug',
        'Sep',
        'Oct',
        'Nov',
        'Dec',
      ];
      return '${dt.day} ${months[dt.month - 1]} ${dt.year}';
    } catch (_) {
      return raw;
    }
  }
}

/// Slim inline banner for non-fatal list refresh failures. The saved list
/// stays visible; retry re-fires the current tab's filter.
class _ListNoticeBar extends StatelessWidget {
  final double scale;
  final String message;
  final VoidCallback onRetry;

  const _ListNoticeBar({
    required this.scale,
    required this.message,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: EdgeInsets.fromLTRB(
        context.sportoResponsive.horizontalPadding,
        8 * scale,
        context.sportoResponsive.horizontalPadding,
        0,
      ),
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: 12 * scale,
          vertical: 8 * scale,
        ),
        decoration: BoxDecoration(
          color: const Color(0x1AFEBD38),
          borderRadius: BorderRadius.circular(10 * scale),
          border: Border.all(color: const Color(0x4DFEBD38)),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                message,
                style: theme.textTheme.bodySmall,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            SizedBox(width: 8 * scale),
            InkWell(
              onTap: onRetry,
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: 4 * scale,
                  vertical: 2 * scale,
                ),
                child: Text(
                  'Retry',
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFFFEBD38),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
