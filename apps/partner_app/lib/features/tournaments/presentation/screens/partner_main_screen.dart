import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:ui_kit/ui_kit.dart';

import '../../../../app/router/app_router.dart';
import '../../../partner_api/application/partner_api_bloc.dart';
import '../../application/tournament_bloc.dart';
import '../widgets/live_tournament_card.dart';
import 'match_history_screen.dart';
import 'profile_screen.dart';
import 'schedule_screen.dart';

class PartnerMainScreen extends StatefulWidget {
  final int initialIndex;
  static int activeTabIndex = 0;

  const PartnerMainScreen({
    super.key,
    this.initialIndex = 0,
  });

  @override
  State<PartnerMainScreen> createState() => _PartnerMainScreenState();
}

class _PartnerMainScreenState extends State<PartnerMainScreen> {
  @override
  void initState() {
    super.initState();
    if (widget.initialIndex != 0) {
      PartnerMainScreen.activeTabIndex = widget.initialIndex;
    }
    context.read<TournamentBloc>().add(const LoadTournamentsEvent());
    context.read<PartnerApiBloc>().add(const LoadPartnerApiBootstrapEvent());
  }

  @override
  Widget build(BuildContext context) {
    return SportoBottomTabShell(
      initialIndex: PartnerMainScreen.activeTabIndex,
      onIndexChanged: (index) {
        PartnerMainScreen.activeTabIndex = index;
      },
      tabs: [
        _buildHomeTab(context),
        const MatchHistoryScreen(embedded: true),
        const ScheduleScreen(embedded: true),
        const PartnerProfileScreen(),
      ],

      items: const [
        SportoNavItem.asset(
          asset: SportoAssets.home,
          label: 'Home',
        ),
        SportoNavItem.asset(
          asset: SportoAssets.tournaments,
          label: 'Tournaments',
        ),
        SportoNavItem.asset(
          asset: SportoAssets.matches,
          label: 'Schedules',
        ),
        SportoNavItem.asset(
          asset: SportoAssets.profile,
          label: 'Profile',
        ),
      ],
    );
  }

  Widget _buildHomeTab(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final scale = context.sportoScale;

    return SafeArea(
      bottom: false,
      child: SportoResponsiveContent(
        padding: EdgeInsets.zero,
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(
                context.sportoResponsive.horizontalPadding,
                10 * scale,
                context.sportoResponsive.horizontalPadding,
                8 * scale,
              ),
              child: BlocBuilder<PartnerApiBloc, PartnerApiState>(
                builder: (context, state) {
                  final loaded = state is PartnerApiLoadedState ? state : null;
                  final name = loaded?.displayName;
                  final greeting = _greeting();
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (name != null)
                              Text(
                                name,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: theme.textTheme.titleLarge?.copyWith(
                                  fontSize: 18 * scale,
                                  fontWeight: FontWeight.w600,
                                  color: colorScheme.onSurface,
                                ),
                              )
                            else
                              Padding(
                                padding: EdgeInsets.symmetric(vertical: 2 * scale),
                                child: SportoShimmer(
                                  width: 140 * scale,
                                  height: 20 * scale,
                                  borderRadius: 4 * scale,
                                ),
                              ),
                            Text(
                              greeting,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 13 * scale,
                                color: colorScheme.tertiary,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(width: 8 * scale),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            padding: EdgeInsets.all(6 * scale),
                            constraints: BoxConstraints.tightFor(
                              width: 36 * scale,
                              height: 36 * scale,
                            ),
                            icon: Icon(
                              Icons.notifications_none_rounded,
                              color: colorScheme.onSurface,
                              size: 22 * scale,
                            ),
                            onPressed: () {},
                          ),
                          SizedBox(width: 4 * scale),
                          SportoCard(
                            radius: 7 * scale,
                            blur: 10 * scale,
                            padding: EdgeInsets.fromLTRB(
                              8 * scale,
                              3 * scale,
                              2 * scale,
                              3 * scale,
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  'Rs 500',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    color: colorScheme.onSurface,
                                    fontSize: 14 * scale,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                SizedBox(width: 5 * scale),
                                Container(
                                  width: 22 * scale,
                                  height: 22 * scale,
                                  decoration: BoxDecoration(
                                    color: colorScheme.tertiary,
                                    borderRadius:
                                        BorderRadius.circular(5 * scale),
                                  ),
                                  alignment: Alignment.center,
                                  child: Icon(
                                    Icons.add_rounded,
                                    color: Colors.black,
                                    size: 16 * scale,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  );
                },
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                physics: const ClampingScrollPhysics(),
                padding: EdgeInsets.fromLTRB(
                  context.sportoResponsive.horizontalPadding,
                  8 * scale,
                  context.sportoResponsive.horizontalPadding,
                  context.sportoResponsive.bottomContentPadding(context) +
                      16 * scale,
                ),
                child: BlocBuilder<PartnerApiBloc, PartnerApiState>(
                  builder: (context, state) {
                    final loaded =
                        state is PartnerApiLoadedState ? state : null;
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildOverviewSection(colorScheme, loaded),
                        SizedBox(height: 20 * scale),
                        _buildQuickActions(colorScheme),
                        SizedBox(height: 12 * scale),
                        _buildAnnouncementsBanner(colorScheme),
                        SizedBox(height: 22 * scale),
                        _buildLiveTournaments(colorScheme, loaded),
                        SizedBox(height: 20 * scale),
                        _buildTodaysSchedule(colorScheme, loaded),
                        SizedBox(height: 20 * scale),
                        _buildAdsBanner(colorScheme),
                      ],
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _greeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning';
    if (hour < 17) return 'Good Afternoon';
    return 'Good Evening';
  }

  Widget _buildOverviewSection(
      ColorScheme cs, PartnerApiLoadedState? loaded) {
    final scale = context.sportoScale;
    final isLoading = loaded == null;
    final tournaments = loaded?.tournaments ?? [];
    final live = tournaments.where((t) => t.status == 6).length;
    final active = tournaments.where((t) => t.status >= 1 && t.status <= 6).length;
    final players = tournaments.fold<int>(
        0, (sum, t) => sum + (t.registeredTeams ?? 0));

    final availableWidth = (context.sportoResponsive.contentMaxWidth -
            context.sportoResponsive.horizontalPadding * 2)
        .clamp(280.0, double.infinity)
        .toDouble();
    final tileWidth = (availableWidth - 12 * scale) / 2;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Today's Overview",
            style: TextStyle(
                color: cs.onSurfaceVariant,
                fontSize: 13 * scale,
                fontWeight: FontWeight.w500)),
        SizedBox(height: 12 * scale),
        if (isLoading)
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 12 * scale,
            crossAxisSpacing: 12 * scale,
            childAspectRatio: tileWidth / (61 * scale),
            children: [
              for (var i = 0; i < 4; i++)
                SportoSkeletonCard(
                  height: 61 * scale,
                  borderRadius: 12 * scale,
                ),
            ],
          )
        else
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 12 * scale,
            crossAxisSpacing: 12 * scale,
            childAspectRatio: tileWidth / (61 * scale),
            children: [
              SportoStatCard(
                label: 'Revenue',
                value: 'Rs 0',
                highlight: true,
                highlightColor: cs.tertiary,
                fontSize: 16 * scale,
                labelSize: 11 * scale,
                alignment: CrossAxisAlignment.start,
                padding: EdgeInsets.symmetric(
                  horizontal: 14 * scale,
                  vertical: 8 * scale,
                ),
              ),
              SportoStatCard(
                label: 'Live Tournaments',
                value: '$live',
                fontSize: 16 * scale,
                labelSize: 11 * scale,
                alignment: CrossAxisAlignment.start,
                padding: EdgeInsets.symmetric(
                  horizontal: 14 * scale,
                  vertical: 8 * scale,
                ),
              ),
              SportoStatCard(
                label: 'Registered Players',
                value: '$players',
                fontSize: 16 * scale,
                labelSize: 11 * scale,
                alignment: CrossAxisAlignment.start,
                padding: EdgeInsets.symmetric(
                  horizontal: 14 * scale,
                  vertical: 8 * scale,
                ),
              ),
              SportoStatCard(
                label: 'Active Tournaments',
                value: '$active',
                fontSize: 16 * scale,
                labelSize: 11 * scale,
                alignment: CrossAxisAlignment.start,
                padding: EdgeInsets.symmetric(
                  horizontal: 14 * scale,
                  vertical: 8 * scale,
                ),
              ),
            ],
          ),
      ],
    );
  }

  Widget _buildQuickActions(ColorScheme cs) {
    final scale = context.sportoScale;
    final availableWidth = (context.sportoResponsive.contentMaxWidth -
            context.sportoResponsive.horizontalPadding * 2)
        .clamp(280.0, double.infinity)
        .toDouble();
    final gap = 12 * scale;
    final tileWidth = (availableWidth - gap * 3) / 4;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Quick Actions',
            style: TextStyle(
                color: cs.onSurfaceVariant,
                fontSize: 13 * scale,
                fontWeight: FontWeight.w500)),
        SizedBox(height: 12 * scale),
        Row(
          children: [
            SportoQuickAction(
              width: tileWidth,
              asset: SportoAssets.addCircle,
              label: 'Create\nTournament',
              onTap: () async {
                final refreshed =
                    await context.push<bool>(AppRouter.createTournamentRoute);
                if (refreshed == true && mounted) {
                  context
                      .read<TournamentBloc>()
                      .add(const LoadTournamentsEvent());
                  context
                      .read<PartnerApiBloc>()
                      .add(const LoadPartnerApiBootstrapEvent());
                }
              },
            ),
            SizedBox(width: gap),
            SportoQuickAction(
                width: tileWidth,
                asset: SportoAssets.locationPin,
                label: 'Manage\nVenue'),
            SizedBox(width: gap),
            SportoQuickAction(
                width: tileWidth,
                asset: SportoAssets.locationPin,
                label: 'Registrations'),
            SizedBox(width: gap),
            SportoQuickAction(
                width: tileWidth,
                asset: SportoAssets.locationPin,
                label: 'Schedule\nMatches'),
          ],
        ),
      ],
    );
  }

  Widget _buildAnnouncementsBanner(ColorScheme cs) {
    final scale = context.sportoScale;
    return SportoCard(
      radius: 8 * scale,
      padding: EdgeInsets.symmetric(vertical: 7 * scale),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.campaign_rounded,
              color: cs.onSurfaceVariant, size: 18 * scale),
          SizedBox(width: 5 * scale),
          Text('Announcements',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                  color: cs.onSurface,
                  fontSize: 11 * scale,
                  fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  Widget _buildAdsBanner(ColorScheme cs) {
    final theme = Theme.of(context);
    final scale = context.sportoScale;
    return Container(
      width: double.infinity,
      height: 60 * scale,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [
            cs.primary,
            cs.tertiary,
          ],
        ),
        borderRadius: BorderRadius.circular(18 * scale),
      ),
      padding: EdgeInsets.fromLTRB(20 * scale, 0, 12 * scale, 0),
      child: Row(
        children: [
          Text(
            'Ads Banner',
            style: theme.textTheme.titleLarge?.copyWith(
              color: Colors.white,
              fontSize: 16 * scale,
              fontWeight: FontWeight.w600,
            ),
          ),
          const Spacer(),
          ClipRRect(
            borderRadius: BorderRadius.circular(10 * scale),
            child: Image.asset(
              SportoAssets.playAndWin,
              package: SportoAssets.package,
              width: 92 * scale,
              height: 52 * scale,
              fit: BoxFit.cover,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLiveTournaments(
      ColorScheme cs, PartnerApiLoadedState? loaded) {
    final scale = context.sportoScale;
    final isLoading = loaded == null;
    final liveTournaments = loaded?.liveTournaments ?? [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
                width: 8 * scale,
                height: 8 * scale,
                decoration: const BoxDecoration(
                    shape: BoxShape.circle, color: Colors.redAccent)),
            SizedBox(width: 6 * scale),
            Text('Live Tournament',
                style: TextStyle(
                    color: cs.onSurfaceVariant,
                    fontSize: 13 * scale,
                    fontWeight: FontWeight.w500)),
          ],
        ),
        SizedBox(height: 12 * scale),
        if (isLoading)
          SportoSkeletonCard(height: 120 * scale)
        else if (liveTournaments.isNotEmpty)
          ...liveTournaments.map((t) => Padding(
                padding: EdgeInsets.only(bottom: 12 * scale),
                child: LiveTournamentCard(
                  name: t.name,
                  stage: t.tournamentVenues.isNotEmpty
                      ? (t.tournamentVenues.first.roundName ?? 'Ongoing')
                      : 'Ongoing',
                  sport: _sportName(t.sportId),
                  teams: t.maximumTeams != null
                      ? '${t.maximumTeams} Teams'
                      : 'TBD',
                  liveNow: true,
                  onViewTournament: () => context
                      .push(AppRouter.tournamentDetailRoute('${t.id}')),
                ),
              ))
        else
          SportoCard(
            padding: EdgeInsets.symmetric(vertical: 20 * scale),
            child: Center(
              child: Text(
                'No live tournaments currently',
                style: TextStyle(
                  color: cs.onSurfaceVariant,
                  fontSize: 13 * scale,
                ),
              ),
            ),
          ),
      ],
    );
  }

  String _sportName(int sportId) {
    switch (sportId) {
      case 1:
        return 'Cricket';
      case 2:
        return 'Football';
      case 5:
        return 'Badminton';
      default:
        return 'Sport';
    }
  }

  Widget _buildTodaysSchedule(
      ColorScheme cs, PartnerApiLoadedState? loaded) {
    final scale = context.sportoScale;
    final isLoading = loaded == null;
    final upcoming = loaded?.upcomingTournaments ?? [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text("Today's Schedule",
                style: TextStyle(
                    color: cs.onSurfaceVariant,
                    fontSize: 13 * scale,
                    fontWeight: FontWeight.w500)),
            GestureDetector(
              onTap: () {},
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('View All',
                      style: TextStyle(
                          color: cs.tertiary,
                          fontSize: 12 * scale,
                          fontWeight: FontWeight.w500)),
                  SizedBox(width: 4 * scale),
                  Icon(Icons.chevron_right_rounded,
                      color: cs.onTertiary, size: 16 * scale),
                ],
              ),
            ),
          ],
        ),
        SizedBox(height: 12 * scale),
        if (isLoading)
          SportoSkeletonCard(height: 100 * scale)
        else if (upcoming.isNotEmpty)
          ...upcoming.take(2).map((t) {
            final venue = t.tournamentVenues.isNotEmpty
                ? t.tournamentVenues.first
                : null;
            final timeStr = _formatScheduleDateTime(
                t.tournamentStartAt, venue?.startTime, venue?.date);
            final startInStr = _calculateStartIn(t.tournamentStartAt);

            return Padding(
              padding: EdgeInsets.only(bottom: 12 * scale),
              child: _ScheduleCard(
                time: timeStr,
                startIn: startInStr,
                tournamentName: t.name,
                sportName: _sportName(t.sportId),
                teamsCount: t.maximumTeams != null
                    ? '${t.maximumTeams} Teams'
                    : '18 Teams',
                onTap: () => context
                    .push(AppRouter.tournamentDetailRoute('${t.id}')),
              ),
            );
          })
        else
          SportoCard(
            padding: EdgeInsets.symmetric(vertical: 20 * scale),
            child: Center(
              child: Text(
                'No scheduled matches today',
                style: TextStyle(
                  color: cs.onSurfaceVariant,
                  fontSize: 13 * scale,
                ),
              ),
            ),
          ),
      ],
    );
  }

  String _formatScheduleDateTime(
      String? rawTournamentStart, String? venueStartTime, String? venueDate) {
    if (venueStartTime != null && venueStartTime.isNotEmpty) {
      final formattedTime = _formatTimeOnly(venueStartTime);
      final formattedDate =
          venueDate != null ? _formatDateOnly(venueDate) : 'Today';
      return '$formattedTime, $formattedDate';
    }
    if (rawTournamentStart != null && rawTournamentStart.isNotEmpty) {
      try {
        final dt = DateTime.parse(rawTournamentStart).toLocal();
        const months = [
          'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
          'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
        ];
        final hour =
            dt.hour == 0 ? 12 : (dt.hour > 12 ? dt.hour - 12 : dt.hour);
        final period = dt.hour >= 12 ? 'PM' : 'AM';
        final minuteStr = dt.minute.toString().padLeft(2, '0');
        final timeFormatted =
            '${hour.toString().padLeft(2, '0')}:$minuteStr $period';
        final dateFormatted = '${dt.day} ${months[dt.month - 1]} ${dt.year}';
        return '$timeFormatted, $dateFormatted';
      } catch (_) {
        return rawTournamentStart;
      }
    }
    return '10:00 AM, 26 July 2026';
  }

  String _formatTimeOnly(String raw) {
    try {
      final dt = DateTime.parse(raw).toLocal();
      final hour = dt.hour == 0 ? 12 : (dt.hour > 12 ? dt.hour - 12 : dt.hour);
      final period = dt.hour >= 12 ? 'PM' : 'AM';
      final minuteStr = dt.minute.toString().padLeft(2, '0');
      return '${hour.toString().padLeft(2, '0')}:$minuteStr $period';
    } catch (_) {
      if (raw.contains(':')) {
        final parts = raw.split(':');
        final h = int.tryParse(parts[0]) ?? 0;
        final period = h >= 12 ? 'PM' : 'AM';
        final displayHour = h == 0 ? 12 : (h > 12 ? h - 12 : h);
        return '${displayHour.toString().padLeft(2, '0')}:${parts[1].padLeft(2, '0')} $period';
      }
      return raw;
    }
  }

  String _formatDateOnly(String raw) {
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

  String _calculateStartIn(String? rawStartAt) {
    if (rawStartAt == null || rawStartAt.isEmpty) return '25 mins';
    try {
      final dt = DateTime.parse(rawStartAt);
      final diff = dt.difference(DateTime.now());
      if (diff.isNegative) return 'Started';
      if (diff.inDays > 0) return '${diff.inDays} days';
      if (diff.inHours > 0) return '${diff.inHours} hrs';
      return '${diff.inMinutes.clamp(1, 59)} mins';
    } catch (_) {
      return '25 mins';
    }
  }


  Widget _ScheduleCard({
    required String time,
    required String startIn,
    String? tournamentName,
    String? sportName,
    String? teamsCount,
    VoidCallback? onTap,
  }) {
    return Builder(builder: (context) {
      final cs = Theme.of(context).colorScheme;
      final scale = context.sportoScale;
      final tName = tournamentName ?? 'Hyderabad Super Cup';
      final sName = sportName ?? 'Cricket';
      final teams = teamsCount ?? '18 Teams';

      return Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16 * scale),
          boxShadow: [
            BoxShadow(
              color: cs.secondary.withValues(alpha: .04),
              blurRadius: 14 * scale,
              spreadRadius: -10 * scale,
              offset: Offset(0, 6 * scale),
            ),
          ],
        ),
        child: SportoCard(
          onTap: onTap,
          padding: EdgeInsets.all(10 * scale),
          backgroundColor: cs.surfaceContainerHigh.withValues(alpha: .86),
          borderColor: cs.secondary.withValues(alpha: .16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(time,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                      color: cs.onSurfaceVariant,
                      fontSize: 11 * scale,
                      fontWeight: FontWeight.w500)),
              SizedBox(height: 10 * scale),
              Row(
                children: [
                  Container(
                    width: 56 * scale,
                    height: 56 * scale,
                    decoration: BoxDecoration(
                      color: cs.secondary.withValues(alpha: 0.14),
                      borderRadius: BorderRadius.circular(10 * scale),
                    ),
                    alignment: Alignment.center,
                    child: Text(_initials(tName),
                        style: TextStyle(
                            color: cs.secondary,
                            fontSize: 24 * scale,
                            fontWeight: FontWeight.w700)),
                  ),
                  SizedBox(width: 10 * scale),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(tName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                                color: cs.onSurface,
                                fontSize: 14 * scale,
                                fontWeight: FontWeight.w700)),
                        SizedBox(height: 4 * scale),
                        RichText(
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          text: TextSpan(
                            style: TextStyle(fontSize: 11 * scale),
                            children: [
                              TextSpan(
                                  text: '$sName - ',
                                  style: TextStyle(
                                      color: cs.tertiary,
                                      fontWeight: FontWeight.w700)),
                              TextSpan(
                                  text: teams,
                                  style: TextStyle(
                                      color: cs.secondary,
                                      fontWeight: FontWeight.w600)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  SportoBadge(
                      text: 'Quarter Final',
                      color: cs.secondary,
                      outlined: true),
                ],
              ),
              SizedBox(height: 10 * scale),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: RichText(
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      text: TextSpan(
                        style: TextStyle(fontSize: 11 * scale),
                        children: [
                          TextSpan(
                              text: 'Start in ',
                              style: TextStyle(color: cs.onSurfaceVariant)),
                          TextSpan(
                              text: startIn,
                              style: TextStyle(
                                  color: cs.tertiary,
                                  fontWeight: FontWeight.w700)),
                        ],
                      ),
                    ),
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('View Tournament',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                              color: cs.onSurfaceVariant,
                              fontSize: 11 * scale,
                              fontWeight: FontWeight.w600)),
                      SizedBox(width: 4 * scale),
                      Icon(Icons.arrow_forward_rounded,
                          color: cs.onSurfaceVariant, size: 16 * scale),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    });
  }

  String _initials(String name) {
    final words = name.trim().split(' ').where((w) => w.isNotEmpty).toList();
    if (words.length >= 2) {
      return (words[0][0] + words[1][0]).toUpperCase();
    }
    return name.isNotEmpty
        ? name.substring(0, name.length.clamp(0, 2)).toUpperCase()
        : 'HS';
  }
}
