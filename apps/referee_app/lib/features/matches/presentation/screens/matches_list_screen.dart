import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:ui_kit/ui_kit.dart';

class MatchesListScreen extends StatefulWidget {
  const MatchesListScreen({super.key});

  @override
  State<MatchesListScreen> createState() => _MatchesListScreenState();
}

class _MatchesListScreenState extends State<MatchesListScreen> {
  static const List<String> _tabs = [
    'All',
    'Upcoming',
    'Live',
    'Completed',
  ];

  int _selectedTab = 0;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final layout = context.sportoLayout;
    final sporto = context.sporto;

    return SafeArea(
      bottom: false,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
              20,
              18,
              20,
              16,
            ),
            child: SizedBox(
              width: double.infinity,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (Navigator.of(context).canPop()) ...[
                    IconButton(
                      padding: EdgeInsets.zero,
                      visualDensity: VisualDensity.compact,
                      constraints: const BoxConstraints(
                        minWidth: 32,
                        minHeight: 32,
                      ),
                      icon: Icon(
                        Icons.arrow_back_ios_new_rounded,
                        color: colors.onSurface,
                        size: 19,
                      ),
                      onPressed: () => context.pop(),
                    ),
                    const SizedBox(height: 6),
                  ],
                  Text(
                    'Today\'s Matches',
                    style: theme.textTheme.titleLarge?.copyWith(
                      color: colors.onSurface,
                      fontSize: 18,
                      height: 1.15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '6 Matches Assigned',
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: sporto.info,
                      fontSize: 14,
                      height: 1.15,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
          _MatchTabs(
            tabs: _tabs,
            selectedIndex: _selectedTab,
            onChanged: (index) {
              setState(() {
                _selectedTab = index;
              });
            },
          ),
          const SizedBox(height: 16),
          Expanded(
            child: ListView.separated(
              physics: const BouncingScrollPhysics(),
              padding: EdgeInsets.fromLTRB(
                layout.space20,
                layout.space8,
                layout.space20,
                layout.space12,
              ),
              itemCount: _selectedTab == 0 ? 4 : 1,
              separatorBuilder: (_, __) {
                return SizedBox(
                  height: layout.space12,
                );
              },
              itemBuilder: (context, index) {
                final state = _selectedTab == 0
                    ? SportoCricketMatchState.values[index]
                    : switch (_selectedTab) {
                        1 => SportoCricketMatchState.upcoming,
                        2 => SportoCricketMatchState.live,
                        _ => SportoCricketMatchState.completed,
                      };

                return SportoCricketMatchCard(
                  state: state,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _MatchTabs extends StatelessWidget {
  final List<String> tabs;
  final int selectedIndex;
  final ValueChanged<int> onChanged;

  const _MatchTabs({
    required this.tabs,
    required this.selectedIndex,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final sporto = context.sporto;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: sporto.border.withValues(
              alpha: .9,
            ),
            width: 1,
          ),
        ),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(
          horizontal: 20,
        ),
        child: Row(
          children: List.generate(
            tabs.length,
            (index) {
              final selected = selectedIndex == index;

              return Padding(
                padding: EdgeInsets.only(
                  right: index == tabs.length - 1 ? 0 : 22,
                ),
                child: InkWell(
                  onTap: () => onChanged(index),
                  splashColor: Colors.transparent,
                  highlightColor: Colors.transparent,
                  child: Padding(
                    padding: const EdgeInsets.only(
                      top: 8,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          tabs[index],
                          style: theme.textTheme.bodyLarge?.copyWith(
                            color: selected
                                ? colors.onSurfaceVariant
                                : colors.onSurfaceVariant.withValues(
                                    alpha: .75,
                                  ),
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 7),
                        AnimatedContainer(
                          duration: const Duration(
                            milliseconds: 150,
                          ),
                          width: 18,
                          height: 2,
                          decoration: BoxDecoration(
                            color:
                                selected ? colors.tertiary : Colors.transparent,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
