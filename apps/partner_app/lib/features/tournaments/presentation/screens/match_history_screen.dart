import 'package:flutter/material.dart';
import 'package:ui_kit/ui_kit.dart';

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
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final scale = context.sportoScale;
    final content = SafeArea(
      bottom: false,
      child: SportoResponsiveContent(
        padding: EdgeInsets.zero,
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Padding(
            padding: EdgeInsets.fromLTRB(
              context.sportoResponsive.horizontalPadding,
              20 * scale,
              context.sportoResponsive.horizontalPadding,
              8 * scale,
            ),
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
              padding: EdgeInsets.symmetric(
                horizontal: context.sportoResponsive.horizontalPadding,
              ),
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
                context.sportoResponsive.horizontalPadding,
                26 * scale,
                context.sportoResponsive.horizontalPadding,
                context.sportoResponsive.bottomContentPadding(context),
              ),
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
    );
    return widget.embedded ? content : SportoScreenShell(body: content);
  }
}
