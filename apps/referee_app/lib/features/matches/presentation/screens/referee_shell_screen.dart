import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:ui_kit/ui_kit.dart';

import '../../../../app/router/app_router.dart';
import 'schedule_matches_screen.dart';
import 'profile_screen.dart';
import 'referee_home_screen.dart';
import 'referee_scoring_tab_screen.dart';

/// Authenticated shell screen with exact Figma `Navbar` implementation
/// based on `figma/Scoring.json` and `Home.json`.
///
/// Specs:
/// - Navbar height: 54px (+ safe area bottom inset)
/// - Top corners: 14px radius (topLeft: 14, topRight: 14)
/// - Background: Color(0x802C2C2A) (50% #2C2C2A)
/// - Background blur: BackdropFilter sigma 20 (blur 80px)
/// - Drop shadow: radius 3, Color(0x1A000000)
/// - 4 Tabs: Home, Matches, Scoring, Profile
/// - Active tab: Amber gradient [Color(0xFFED7B00), Color(0xFFCF9E24)]
/// - Inactive tab: Slate gray Color(0xFFAAAAAA)
class RefereeShellScreen extends StatefulWidget {
  final int initialIndex;

  const RefereeShellScreen({
    super.key,
    this.initialIndex = 0,
  });

  @override
  State<RefereeShellScreen> createState() => RefereeShellScreenState();
}

class RefereeShellScreenState extends State<RefereeShellScreen> {
  final GlobalKey<RefereeHomeScreenState> _homeKey =
      GlobalKey<RefereeHomeScreenState>();
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
  }

  void setIndex(int index) {
    final clamped = index.clamp(0, 3);
    if (_currentIndex != clamped) {
      setState(() => _currentIndex = clamped);
    }
    // Refetch pending requests / matches whenever Home is opened so newly
    // assigned matches are not hidden behind a stale first load.
    if (clamped == 0) {
      _homeKey.currentState?.refresh();
    }
  }

  @override
  Widget build(BuildContext context) {
    final scale = context.sportoScale;
    final bottomInset = MediaQuery.paddingOf(context).bottom;

    return Scaffold(
      backgroundColor: const Color(0xFF0E0C08),
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Indexed tabs preserving state
          Positioned.fill(
            child: IndexedStack(
              index: _currentIndex,
              children: [
                RefereeHomeScreen(
                  key: _homeKey,
                  onViewAll: () => setIndex(1),
                  onAvailability: () =>
                      context.push(AppRouter.availabilityPath),
                ),
                const ScheduleMatchesScreen(),
                const RefereeScoringTabScreen(),
                const RefereeProfileScreen(),
              ],
            ),
          ),

          // Glassmorphic Figma Navbar
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: _FigmaRefereeNavBar(
              currentIndex: _currentIndex,
              onTap: setIndex,
              scale: scale,
              bottomInset: bottomInset,
            ),
          ),
        ],
      ),
    );
  }
}

/// Exact Figma bottom navigation bar matching Frame `Navbar` in `figma/Scoring.json`.
class _FigmaRefereeNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  final double scale;
  final double bottomInset;

  const _FigmaRefereeNavBar({
    required this.currentIndex,
    required this.onTap,
    required this.scale,
    required this.bottomInset,
  });

  static const _items = [
    _NavBarItemData(
      label: 'Home',
      asset: SportoHomeRedesignIcons.navHome,
      iconSize: 30,
    ),
    _NavBarItemData(
      label: 'Matches',
      asset: SportoHomeRedesignIcons.navSchedule,
      iconSize: 20,
    ),
    _NavBarItemData(
      label: 'Scoring',
      asset: SportoHomeRedesignIcons.navScoring,
      iconSize: 30,
    ),
    _NavBarItemData(
      label: 'Profile',
      asset: SportoHomeRedesignIcons.navProfile,
      iconSize: 30,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final navHeight = 54 * scale;

    return ClipRRect(
      borderRadius: BorderRadius.vertical(
        top: Radius.circular(14 * scale),
      ),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          height: navHeight + bottomInset,
          padding: EdgeInsets.only(bottom: bottomInset),
          decoration: BoxDecoration(
            color: const Color(0x802C2C2A), // 50% opacity #2c2c2a
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(14 * scale),
            ),
            border: const Border(
              top: BorderSide(
                color: Color(0x1AFFFFFF),
                width: 0.8,
              ),
            ),
            boxShadow: const [
              BoxShadow(
                color: Color(0x1A000000),
                blurRadius: 3,
                offset: Offset(0, 0),
              ),
            ],
          ),
          child: Row(
            children: List.generate(_items.length, (index) {
              final item = _items[index];
              final isActive = index == currentIndex;

              return Expanded(
                child: Semantics(
                  button: true,
                  selected: isActive,
                  label: item.label,
                  child: InkWell(
                    key: ValueKey('referee_nav_tab_${item.label}'),
                    onTap: () => onTap(index),
                    splashColor: const Color(0x1AED7B00),
                    highlightColor: Colors.transparent,
                    child: SizedBox(
                      height: navHeight,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 30 * scale,
                            height: 30 * scale,
                            child: Center(
                              child: _buildIcon(
                                item.asset,
                                isActive,
                                item.iconSize,
                              ),
                            ),
                          ),
                          SizedBox(height: 1 * scale),
                          _buildLabel(item.label, isActive),
                          if (isActive) ...[
                            SizedBox(height: 1 * scale),
                            Container(
                              width: 6 * scale,
                              height: 6 * scale,
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                color: Color(0xFFF4B41A),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }

  Widget _buildIcon(String asset, bool isActive, double iconSize) {
    // The Home asset already contains the gold body + white door accent.
    final tint = !isActive
        ? const Color(0xFFA0A0A0)
        : asset == SportoHomeRedesignIcons.navHome
            ? null
            : const Color(0xFFF4B41A);
    return SportoSvgIcon(
      asset,
      size: iconSize * scale,
      color: tint,
    );
  }

  Widget _buildLabel(String label, bool isActive) {
    return Text(
      label,
      maxLines: 1,
      style: TextStyle(
        fontSize: 12 * scale,
        fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
        color: isActive ? const Color(0xFFF4B41A) : const Color(0xFFA0A0A0),
        height: 1.1,
      ),
    );
  }
}

class _NavBarItemData {
  final String label;
  final String asset;
  final double iconSize;

  const _NavBarItemData({
    required this.label,
    required this.asset,
    required this.iconSize,
  });
}
