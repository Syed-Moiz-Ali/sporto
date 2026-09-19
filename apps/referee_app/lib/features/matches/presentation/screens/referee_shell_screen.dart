import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:ui_kit/ui_kit.dart';

import 'matches_list_screen.dart';
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
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
  }

  void setIndex(int index) {
    final clamped = index.clamp(0, 3);
    if (_currentIndex == clamped) return;
    setState(() => _currentIndex = clamped);
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
                  onViewAll: () => setIndex(1),
                ),
                const MatchesListScreen(),
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
      asset: SportoAssets.home,
    ),
    _NavBarItemData(
      label: 'Matches',
      asset: SportoAssets.matches,
    ),
    _NavBarItemData(
      label: 'Scoring',
      asset: SportoAssets.tournaments,
    ),
    _NavBarItemData(
      label: 'Profile',
      asset: SportoAssets.profile,
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
                          _buildIcon(item.asset, isActive),
                          SizedBox(height: 3 * scale),
                          _buildLabel(item.label, isActive),
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

  Widget _buildIcon(String asset, bool isActive) {
    final size = 20 * scale;

    if (!isActive) {
      return SportoAssetIcon(
        asset,
        size: size,
        color: const Color(0xFFAAAAAA),
      );
    }

    return ShaderMask(
      blendMode: BlendMode.srcIn,
      shaderCallback: (bounds) => const LinearGradient(
        colors: [
          Color(0xFFED7B00),
          Color(0xFFCF9E24),
        ],
      ).createShader(
        Rect.fromLTWH(0, 0, bounds.width, bounds.height),
      ),
      child: SportoAssetIcon(
        asset,
        size: size,
        color: Colors.white,
      ),
    );
  }

  Widget _buildLabel(String label, bool isActive) {
    if (!isActive) {
      return Text(
        label,
        maxLines: 1,
        style: TextStyle(
          fontSize: 11 * scale,
          fontWeight: FontWeight.w500,
          color: const Color(0xFFAAAAAA),
          height: 1.1,
        ),
      );
    }

    return ShaderMask(
      blendMode: BlendMode.srcIn,
      shaderCallback: (bounds) => const LinearGradient(
        colors: [
          Color(0xFFED7B00),
          Color(0xFFCF9E24),
        ],
      ).createShader(
        Rect.fromLTWH(0, 0, bounds.width, bounds.height),
      ),
      child: Text(
        label,
        maxLines: 1,
        style: TextStyle(
          fontSize: 11 * scale,
          fontWeight: FontWeight.w700,
          color: Colors.white,
          height: 1.1,
        ),
      ),
    );
  }
}

class _NavBarItemData {
  final String label;
  final String asset;

  const _NavBarItemData({
    required this.label,
    required this.asset,
  });
}
