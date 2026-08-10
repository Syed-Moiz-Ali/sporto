import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:ui_kit/ui_kit.dart';
import '../../../../app/router/app_router.dart';

class MatchHistoryScreen extends StatefulWidget {
  const MatchHistoryScreen({super.key});

  @override
  State<MatchHistoryScreen> createState() => _MatchHistoryScreenState();
}

class _MatchHistoryScreenState extends State<MatchHistoryScreen> {
  int _selectedTab = 0;
  static const _tabs = ['All', 'Upcoming', 'Live', 'Completed'];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final scale = context.sportoScale;
    return SportoScreenShell(
      body: SafeArea(
        bottom: false,
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Padding(
            padding: EdgeInsets.fromLTRB(
                20 * scale, 20 * scale, 20 * scale, 8 * scale),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text("Today's Matches",
                  style: theme.textTheme.titleLarge
                      ?.copyWith(fontSize: 18 * scale)),
              Text('6 Matches Assigned',
                  style: theme.textTheme.bodyMedium
                      ?.copyWith(color: context.sporto.info)),
            ]),
          ),
          SizedBox(
            height: 42 * scale,
            child: ListView.separated(
              padding: EdgeInsets.symmetric(horizontal: 20 * scale),
              scrollDirection: Axis.horizontal,
              itemCount: _tabs.length,
              separatorBuilder: (_, __) => SizedBox(width: 28 * scale),
              itemBuilder: (_, index) => InkWell(
                onTap: () => setState(() => _selectedTab = index),
                child:
                    Column(mainAxisAlignment: MainAxisAlignment.end, children: [
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
                ]),
              ),
            ),
          ),
          Divider(height: 1, color: context.sporto.border),
          Expanded(
            child: ListView(
              padding: EdgeInsets.fromLTRB(
                  20 * scale, 26 * scale, 20 * scale, 90 * scale),
              children: [
                const SportoCricketMatchCard(
                    state: SportoCricketMatchState.live),
                SizedBox(height: 21 * scale),
                const SportoCricketMatchCard(
                    state: SportoCricketMatchState.upcoming),
                SizedBox(height: 11 * scale),
                const SportoCricketMatchCard(
                    state: SportoCricketMatchState.completed),
                SizedBox(height: 13 * scale),
                const SportoCricketMatchCard(
                    state: SportoCricketMatchState.delayed),
              ],
            ),
          ),
        ]),
      ),
      bottomNavigationBar: SportoBottomNav(
        currentIndex: 1,
        items: [
          const SportoNavItem(Icons.home_outlined, 'Home'),
          const SportoNavItem(Icons.emoji_events_outlined, 'Tournaments'),
          const SportoNavItem(Icons.calendar_month_outlined, 'Schedules'),
          const SportoNavItem(Icons.person_outline, 'Profile'),
        ],
        onTap: (index) {
          switch (index) {
            case 0:
              context.go(AppRouter.homePath);
            case 1:
              return;
            case 2:
              context.go(AppRouter.scheduleRoute);
            case 3:
              context.go(AppRouter.profileRoute);
          }
        },
      ),
    );
  }
}
