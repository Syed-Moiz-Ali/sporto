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
    context.read<TournamentBloc>().add(const LoadTournamentsEvent());
    context.read<PartnerApiBloc>().add(const LoadPartnerApiBootstrapEvent());
  }

  @override
  Widget build(BuildContext context) {
    return SportoBottomTabShell(
      initialIndex: widget.initialIndex,
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
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Shrvn's Sporto",
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontSize: 18 * scale,
                            fontWeight: FontWeight.w600,
                            color: colorScheme.onSurface,
                          ),
                        ),
                        Text(
                          'Good Morning',
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
                                borderRadius: BorderRadius.circular(5 * scale),
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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildOverviewSection(colorScheme),
                    SizedBox(height: 20 * scale),
                    _buildQuickActions(colorScheme),
                    SizedBox(height: 12 * scale),
                    _buildAnnouncementsBanner(colorScheme),
                    SizedBox(height: 22 * scale),
                    _buildLiveTournaments(colorScheme),
                    SizedBox(height: 20 * scale),
                    _buildTodaysSchedule(colorScheme),
                    SizedBox(height: 20 * scale),
                    _buildAdsBanner(colorScheme),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOverviewSection(ColorScheme cs) {
    final scale = context.sportoScale;
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
              value: 'Rs 12,850',
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
              value: '2',
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
              value: '50',
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
              value: '10',
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
              onTap: () => context.push(AppRouter.createTournamentRoute),
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
          // SportoAssetIcon(SportoAssets.announcement,
          //     color: cs.onSurfaceVariant, size: 14 * scale),
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

  Widget _buildLiveTournaments(ColorScheme cs) {
    final scale = context.sportoScale;
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
        LiveTournamentCard(
          name: 'Hyderabad Super Cup',
          stage: 'Quarter Final',
          sport: 'Cricket',
          teams: '128 Teams',
          liveNow: true,
          onViewTournament: () => context
              .push(AppRouter.tournamentDetailRoute('t-hyderabad-super-cup')),
        ),
        SizedBox(height: 12 * scale),
        LiveTournamentCard(
          name: 'Royal Smashers',
          stage: 'Final',
          sport: 'Cricket',
          teams: '18 Teams',
          liveNow: true,
          onViewTournament: () =>
              context.push(AppRouter.tournamentDetailRoute('t-royal-smashers')),
        ),
      ],
    );
  }

  Widget _buildTodaysSchedule(ColorScheme cs) {
    final scale = context.sportoScale;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text("Today's Schedule (4)",
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
        _ScheduleCard(time: '10:00 AM, 26 July 2026', startIn: '25 mins'),
        SizedBox(height: 12 * scale),
        _ScheduleCard(time: '10:00 AM, 26 July 2026', startIn: '25 mins'),
      ],
    );
  }

  Widget _ScheduleCard({required String time, required String startIn}) {
    return Builder(builder: (context) {
      final cs = Theme.of(context).colorScheme;
      final scale = context.sportoScale;
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
                    child: Text('HS',
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
                        Text('Hyderabad Super Cup',
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
                                  text: 'Cricket - ',
                                  style: TextStyle(
                                      color: cs.tertiary,
                                      fontWeight: FontWeight.w700)),
                              TextSpan(
                                  text: '18 Teams',
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
                  GestureDetector(
                    onTap: () {},
                    child: Row(
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
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    });
  }
}
