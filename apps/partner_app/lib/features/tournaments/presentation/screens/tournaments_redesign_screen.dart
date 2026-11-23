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
import '../widgets/redesign/tournament_screen_parts.dart';
import '../widgets/redesign/tournament_shimmer.dart';
import '../widgets/redesign/tournament_visuals.dart';

/// Tournaments tab — Figma `Partner App / Tournaments` (export screens
/// 09, 10, 14, 36).
///
/// One page, five tab states (draft / live / upcoming / completed / rejected)
/// plus the under-review and approved states the app already had.
class TournamentsRedesignScreen extends StatefulWidget {
  final bool embedded;
  final bool? isLoading;

  /// Test / preview injection: renders this list instead of reading the bloc.
  final List<PartnerTournamentResponse>? tournamentsOverride;

  /// Initial tab (used by golden captures of a specific state).
  final TournamentListTab initialTab;

  const TournamentsRedesignScreen({
    super.key,
    this.embedded = false,
    this.isLoading,
    this.tournamentsOverride,
    this.initialTab = TournamentListTab.applications,
  });

  @override
  State<TournamentsRedesignScreen> createState() =>
      _TournamentsRedesignScreenState();
}

class _TournamentsRedesignScreenState extends State<TournamentsRedesignScreen> {
  late TournamentListTab _selectedTab = widget.initialTab;

  @override
  void initState() {
    super.initState();
    if (widget.tournamentsOverride != null) return;
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
    final horizontal = 20 * scale;

    PartnerApiLoadedState? loaded;
    bool isApiLoading = false;
    String? apiError;
    if (widget.tournamentsOverride == null) {
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
    }

    final isLoading = widget.isLoading ?? (isApiLoading && loaded == null);
    final tournaments = widget.tournamentsOverride ??
        loaded?.tournaments ??
        const <PartnerTournamentResponse>[];
    final live = widget.tournamentsOverride != null
        ? tournaments.where((t) => t.status == 6).toList()
        : loaded?.liveTournaments ?? const <PartnerTournamentResponse>[];
    final filtered = tournaments
        .where((item) => tournamentMatchesTab(item, _selectedTab))
        .toList();

    final content = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TournamentScreenHeader(
          title: 'Tournaments',
          padding: EdgeInsets.fromLTRB(
            horizontal,
            MediaQuery.of(context).padding.top,
            horizontal,
            10 * scale,
          ),
          rowHeight: 44 * scale,
          backgroundColor: t.screenHeader,
          background: t.headerGradient,
          bottomRadius: t.r18,
          trailing: TournamentActionPill(
            label: 'Create',
            icon: SportoSvgIcon(SportoTournamentIcons.plus,
                width: 10, height: 10),
            gradient: t.bluePillGradient,
            foreground: t.screenBase,
            fontWeight: FontWeight.w700,
            height: 27 * scale,
            radius: t.r10,
            padding: EdgeInsets.symmetric(horizontal: 10 * scale),
            onTap: () async {
              final refreshed =
                  await context.push<bool>(AppRouter.createTournamentRoute);
              if (refreshed == true && mounted) {
                context
                    .read<PartnerApiBloc>()
                    .add(const LoadPartnerApiBootstrapEvent());
              }
            },
          ),
        ),
        Expanded(
          child: isLoading
              ? const TournamentListScreenShimmer()
              : apiError != null
                  ? _ErrorState(
                      message: apiError,
                      onRetry: () => context
                          .read<PartnerApiBloc>()
                          .add(const LoadPartnerApiBootstrapEvent()),
                    )
                  : RefreshIndicator(
                      color: t.green,
                      onRefresh: () async {
                        context
                            .read<PartnerApiBloc>()
                            .add(const LoadPartnerApiBootstrapEvent());
                        await Future<void>.delayed(
                          const Duration(milliseconds: 450),
                        );
                      },
                      child: ListView(
                        padding: EdgeInsets.fromLTRB(
                          horizontal,
                          10 * scale,
                          horizontal,
                          (widget.embedded
                                  ? context.sportoResponsive
                                      .bottomContentPadding(context)
                                  : 0) +
                              24 * scale,
                        ),
                        children: [
                          if (live.isNotEmpty) ...[
                            _LiveEntry(
                              count: live.length,
                              onTap: () =>
                                  context.push(AppRouter.liveTournamentsRoute),
                            ),
                            SizedBox(height: 10 * scale),
                          ],
                          _TabRow(
                            tournaments: tournaments,
                            selected: _selectedTab,
                            scale: scale,
                            horizontalPadding: 0,
                            onSelected: (tab) =>
                                setState(() => _selectedTab = tab),
                          ),
                          SizedBox(height: 10 * scale),
                          if (filtered.isEmpty)
                            _EmptyState(label: _selectedTab.label)
                          else
                            for (var i = 0; i < filtered.length; i++) ...[
                              _buildTournamentCard(context, filtered[i]),
                              if (i != filtered.length - 1)
                                SizedBox(height: 10 * scale),
                            ],
                        ],
                      ),
                    ),
        ),
      ],
    );

    return widget.embedded
        ? Scaffold(backgroundColor: t.screenBase, body: content)
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
    final registered = tournament.registeredTeams ?? 0;
    final maxTeams = tournament.maximumTeams;
    final slots =
        maxTeams == null ? null : (maxTeams - registered).clamp(0, maxTeams);
    final detailRoute = AppRouter.tournamentDetailRoute('${tournament.id}');
    final isCompleted = tournament.status == 7;
    final showProgress = tournament.status == 3 || tournament.status == 4;
    final isRejectedOrCancelled = tournament.approvalStatus == 5 ||
        tournament.status == 8 ||
        tournament.status == 9;
    final isReview = tournament.approvalStatus == 2 || tournament.status == 1;

    return TournamentListCard(
      name: tournament.name,
      sport: tournamentSportLabel(tournament),
      venue: tournamentVenueLabel(tournament),
      statusLabel: tournamentBadgeLabel(tournament),
      statusColor: tournamentStatusColor(tournament, t),
      statusGradient: tournamentStatusGradient(t, tournament),
      code: tournamentCode(tournament),
      dateText: _cardDate(tournament.tournamentStartAt),
      location: tournamentLocationLabel(tournament),
      dateRange: (isCompleted || isRejectedOrCancelled)
          ? _dateRange(tournament)
          : null,
      entryFee: tournamentEntryLabel(tournament),
      prize: tournamentPrizeLabel(tournament),
      registrationOpen: tournament.status == 3,
      teamsRegistered: showProgress ? registered : null,
      maxTeams: showProgress ? maxTeams : null,
      slotsLeft: showProgress ? slots : null,
      // `matches scheduled` is not part of the tournament payload — omitted
      // instead of invented (see docs/figma/_coverage.md).
      matchesScheduled: null,
      // Completed cards show a real champion only when the API provides one.
      champions: null,
      submittedText: isReview && tournament.createdAt != null
          ? '${formatTournamentDate(tournament.createdAt)} Submitted'
          : null,
      onEdit: (isReview || isRejectedOrCancelled)
          ? () => context.push(detailRoute)
          : null,
      actionLabel: null,
      onTap: () => context.push(detailRoute),
    );
  }

  String? _cardDate(String? raw) {
    if (raw == null || raw.isEmpty) return null;
    try {
      final dt = DateTime.parse(raw).toLocal();
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
      final hour = dt.hour == 0 ? 12 : (dt.hour > 12 ? dt.hour - 12 : dt.hour);
      final period = dt.hour >= 12 ? 'PM' : 'AM';
      final minute = dt.minute.toString().padLeft(2, '0');
      return '${dt.day.toString().padLeft(2, '0')} ${months[dt.month - 1]} '
          '${dt.year} · $hour:$minute $period';
    } catch (_) {
      return raw;
    }
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

/// `Live Tournaments (n)` entry — the only route into `/tournaments/live`.
class _LiveEntry extends StatelessWidget {
  const _LiveEntry({required this.count, required this.onTap});

  final int count;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final t = context.sportoTournament;
    return ConstrainedBox(
      constraints: const BoxConstraints(minHeight: 29),
      child: Align(
        alignment: Alignment.centerLeft,
        child: TournamentDotTab(
          label: 'Live Tournaments ($count)',
          selected: false,
          dotColor: t.live,
          height: 25,
          radius: t.r50,
          padding: const EdgeInsets.symmetric(horizontal: 8),
          borderGradient: t.bluePillBorderGradient,
          onTap: onTap,
        ),
      ),
    );
  }
}

class _TabRow extends StatelessWidget {
  const _TabRow({
    required this.tournaments,
    required this.selected,
    required this.onSelected,
    required this.scale,
    required this.horizontalPadding,
  });

  final List<PartnerTournamentResponse> tournaments;
  final TournamentListTab selected;
  final ValueChanged<TournamentListTab> onSelected;
  final double scale;
  final double horizontalPadding;

  @override
  Widget build(BuildContext context) {
    final t = context.sportoTournament;
    return ConstrainedBox(
      constraints: BoxConstraints(minHeight: 29 * scale),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        clipBehavior: Clip.none,
        padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
        child: Row(
          children: [
            for (var i = 0; i < TournamentListTab.values.length; i++) ...[
              if (i > 0) SizedBox(width: 8 * scale),
              Builder(
                builder: (_) {
                  final tab = TournamentListTab.values[i];
                  final count = tournamentCountFor(tournaments, tab);
                  return TournamentDotTab(
                    label: '${tab.label} ($count)',
                    selected: selected == tab,
                    dotColor: tab == TournamentListTab.live ? t.live : null,
                    height: 25 * scale,
                    radius: t.r50,
                    padding: EdgeInsets.symmetric(horizontal: 8 * scale),
                    borderGradient: t.bluePillBorderGradient,
                    selectedWeight: FontWeight.w700,
                    unselectedWeight: FontWeight.w500,
                    onTap: () => onSelected(tab),
                  );
                },
              ),
            ],
          ],
        ),
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

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final t = context.sportoTournament;
    return Center(
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
              message,
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
              onTap: onRetry,
            ),
          ],
        ),
      ),
    );
  }
}
