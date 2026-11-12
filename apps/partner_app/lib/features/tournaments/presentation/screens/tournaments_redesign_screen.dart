import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:partner_data/partner_data.dart';
import 'package:ui_kit/ui_kit.dart';

import '../../../../app/router/app_router.dart';
import '../../../partner_api/application/partner_api_bloc.dart';
import '../widgets/redesign/tournament_cards.dart';
import '../widgets/redesign/tournament_navigation.dart';
import '../widgets/redesign/tournament_redesign_data.dart';
import '../widgets/redesign/tournament_shimmer.dart';
import '../widgets/redesign/tournament_visuals.dart';

class TournamentsRedesignScreen extends StatefulWidget {
  final bool embedded;
  final bool? isLoading;

  const TournamentsRedesignScreen({
    super.key,
    this.embedded = false,
    this.isLoading,
  });

  @override
  State<TournamentsRedesignScreen> createState() =>
      _TournamentsRedesignScreenState();
}

class _TournamentsRedesignScreenState extends State<TournamentsRedesignScreen> {
  TournamentListTab _selectedTab = TournamentListTab.applications;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      try {
        final bloc = context.read<PartnerApiBloc>();
        if (bloc.state is! PartnerApiLoadedState) {
          bloc.add(const LoadPartnerApiBootstrapEvent());
        }
      } catch (_) {}
    });
  }

  @override
  Widget build(BuildContext context) {
    final t = context.sportoTournament;
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
        apiError = (bloc.state as PartnerApiErrorState).message;
      }
    } catch (_) {}

    final isLoading = widget.isLoading ?? (isApiLoading && loaded == null);
    final tournaments =
        loaded?.tournaments ?? const <PartnerTournamentResponse>[];
    final filtered = tournaments
        .where((tournament) => tournamentMatchesTab(tournament, _selectedTab))
        .toList();

    final content = SafeArea(
      bottom: false,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(20, 14 * scale, 20, 8 * scale),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'Tournaments',
                    style: SportoTextStyles.text(
                      size: SportoTextStyles.size20,
                      weight: FontWeight.w700,
                      color: t.white,
                    ),
                  ),
                ),
                TournamentActionPill(
                  label: 'Create',
                  icon: Icon(Icons.add_rounded, size: 15, color: t.screenBase),
                  gradient: t.bluePillGradient,
                  foreground: t.screenBase,
                  height: 34,
                  fontSize: SportoTextStyles.size12,
                  onTap: () async {
                    final refreshed = await context
                        .push<bool>(AppRouter.createTournamentRoute);
                    if (refreshed == true && mounted) {
                      context
                          .read<PartnerApiBloc>()
                          .add(const LoadPartnerApiBootstrapEvent());
                    }
                  },
                ),
              ],
            ),
          ),
          if (isLoading)
            const Expanded(child: TournamentListScreenShimmer())
          else if (apiError != null)
            Expanded(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Tournaments could not be loaded.',
                        style: SportoTextStyles.text(
                          size: SportoTextStyles.size15,
                          color: t.white,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        apiError,
                        textAlign: TextAlign.center,
                        style: SportoTextStyles.text(
                          size: SportoTextStyles.size12,
                          color: t.muted,
                        ),
                      ),
                      const SizedBox(height: 16),
                      TournamentActionPill(
                        label: 'Try Again',
                        gradient: t.bluePillGradient,
                        foreground: t.screenBase,
                        onTap: () => context
                            .read<PartnerApiBloc>()
                            .add(const LoadPartnerApiBootstrapEvent()),
                      ),
                    ],
                  ),
                ),
              ),
            )
          else
            Expanded(
              child: RefreshIndicator(
                color: t.green,
                onRefresh: () async {
                  context
                      .read<PartnerApiBloc>()
                      .add(const LoadPartnerApiBootstrapEvent());
                  await Future<void>.delayed(const Duration(milliseconds: 450));
                },
                child: ListView(
                  padding: EdgeInsets.fromLTRB(20, 0, 20, 24 * scale),
                  children: [
                    const SizedBox(height: 6),
                    _LiveSection(
                      live: loaded?.liveTournaments ?? const [],
                      onViewAll: () =>
                          context.push(AppRouter.liveTournamentsRoute),
                      onOpen: (tournament) => context.push(
                        AppRouter.tournamentDetailRoute('${tournament.id}'),
                      ),
                    ),
                    const SizedBox(height: 18),
                    _TabRow(
                      tournaments: tournaments,
                      selected: _selectedTab,
                      onSelected: (tab) => setState(() => _selectedTab = tab),
                    ),
                    const SizedBox(height: 14),
                    if (filtered.isEmpty)
                      _EmptyState(label: _selectedTab.label)
                    else
                      for (var i = 0; i < filtered.length; i++) ...[
                        _buildTournamentCard(context, filtered[i]),
                        if (i != filtered.length - 1)
                          const SizedBox(height: 14),
                      ],
                  ],
                ),
              ),
            ),
        ],
      ),
    );

    return widget.embedded
        ? content
        : Scaffold(
            backgroundColor: t.screenBase,
            body: content,
          );
  }

  Widget _buildTournamentCard(
    BuildContext context,
    PartnerTournamentResponse tournament,
  ) {
    final t = context.sportoTournament;
    final statusColor = tournamentStatusColor(tournament, t);
    final registered = tournament.registeredTeams ?? 0;
    final maxTeams = tournament.maximumTeams;
    final slots =
        maxTeams == null ? null : (maxTeams - registered).clamp(0, maxTeams);
    final detailRoute = AppRouter.tournamentDetailRoute('${tournament.id}');

    final isLive = tournament.status == 6;
    final isCompleted = tournament.status == 7;
    final isRejected = tournament.approvalStatus == 5 ||
        tournament.status == 8 ||
        tournament.status == 9;
    final isUnderReview = tournament.approvalStatus == 2;

    return TournamentListCard(
      name: tournament.name,
      sport: tournamentSportLabel(tournament),
      venue: tournamentVenueLabel(tournament),
      statusLabel: tournamentStatusLabel(tournament),
      statusColor: statusColor,
      code: tournamentCode(tournament),
      dateText: formatTournamentDate(
        tournament.tournamentStartAt,
        fallback: '',
      ),
      location: tournamentLocationLabel(tournament),
      dateRange: _dateRange(tournament),
      registrationOpen: tournament.status == 3,
      teamsRegistered:
          isLive || isCompleted || !isUnderReview ? registered : null,
      maxTeams: isLive || isCompleted || !isUnderReview ? maxTeams : null,
      slotsLeft: isLive ? slots : null,
      matchesScheduled: isLive ? 63 : null,
      champions: isCompleted ? 'Hyd Highlanders' : null,
      noteText: isRejected
          ? 'Venue could not be verified for the selected dates.'
          : isUnderReview
              ? 'Submitted for admin review.'
              : null,
      noteColor: isRejected ? t.red : t.underReview,
      actionLabel: isUnderReview || isRejected ? 'Edit' : 'Open Tournament',
      actionIcon: isUnderReview || isRejected
          ? Icon(Icons.edit_outlined, size: 14, color: statusColor)
          : null,
      onAction: () => context.push(detailRoute),
      onTap: () => context.push(detailRoute),
    );
  }

  String? _dateRange(PartnerTournamentResponse tournament) {
    final start = tournament.tournamentStartAt;
    final end = tournament.tournamentEndAt;
    if (start == null || start.isEmpty) return null;
    final startLabel = formatTournamentDay(start);
    if (end == null || end.isEmpty) return startLabel;
    return '$startLabel – ${formatTournamentDay(end)}';
  }
}

class _LiveSection extends StatelessWidget {
  const _LiveSection({
    required this.live,
    required this.onViewAll,
    required this.onOpen,
  });

  final List<PartnerTournamentResponse> live;
  final VoidCallback onViewAll;
  final ValueChanged<PartnerTournamentResponse> onOpen;

  @override
  Widget build(BuildContext context) {
    final t = context.sportoTournament;
    if (live.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(color: t.live, shape: BoxShape.circle),
            ),
            const SizedBox(width: 6),
            Text(
              'Live Tournaments (${live.length})',
              style: SportoTextStyles.text(
                size: SportoTextStyles.size14,
                weight: FontWeight.w600,
                color: t.warm,
              ),
            ),
            const Spacer(),
            GestureDetector(
              onTap: onViewAll,
              child: Row(
                children: [
                  Text(
                    'View All',
                    style: SportoTextStyles.text(
                      size: SportoTextStyles.size12,
                      color: t.blue,
                    ),
                  ),
                  const SizedBox(width: 2),
                  Icon(Icons.arrow_forward_rounded, size: 14, color: t.blue),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: 282,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: live.length,
            clipBehavior: Clip.none,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (_, index) {
              final tournament = live[index];
              final registered = tournament.registeredTeams ?? 0;
              final maxTeams = tournament.maximumTeams ?? 0;
              return LiveTournamentCard(
                width: 330,
                name: tournament.name,
                venue: tournamentVenueLabel(tournament),
                code: tournamentCode(tournament),
                dateText: formatTournamentDate(tournament.tournamentStartAt),
                teamsText: '$registered/$maxTeams Teams',
                slotsText:
                    '${(maxTeams - registered).clamp(0, maxTeams)} slots left',
                refereeText: '2 awaiting referee',
                onOpen: () => onOpen(tournament),
                onMonitor: () => onOpen(tournament),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _TabRow extends StatelessWidget {
  const _TabRow({
    required this.tournaments,
    required this.selected,
    required this.onSelected,
  });

  final List<PartnerTournamentResponse> tournaments;
  final TournamentListTab selected;
  final ValueChanged<TournamentListTab> onSelected;

  @override
  Widget build(BuildContext context) {
    final t = context.sportoTournament;
    return SizedBox(
      height: 36,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: TournamentListTab.values.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (_, index) {
          final tab = TournamentListTab.values[index];
          final count = tournamentCountFor(tournaments, tab);
          return TournamentDotTab(
            label: '${tab.label} ($count)',
            selected: selected == tab,
            dotColor: tab == TournamentListTab.live ? t.live : null,
            onTap: () => onSelected(tab),
          );
        },
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final t = context.sportoTournament;
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 60),
      alignment: Alignment.center,
      child: Column(
        children: [
          Icon(Icons.emoji_events_outlined, size: 40, color: t.dim),
          const SizedBox(height: 10),
          Text(
            'No $label tournaments',
            style: SportoTextStyles.text(
              size: SportoTextStyles.size14,
              color: t.muted,
            ),
          ),
        ],
      ),
    );
  }
}
