import 'package:flutter/material.dart';

import '../theme/sporto_design_tokens.dart';
import 'sporto_bottom_nav.dart';
import 'sporto_responsive_layout.dart';
import 'sporto_screen_shell.dart';

typedef SportoTabOverlayBuilder = Widget? Function(
  BuildContext context,
  int currentIndex,
  ValueChanged<int> setIndex,
);

class SportoBottomTabShell extends StatefulWidget {
  final List<Widget> tabs;
  final List<SportoNavItem> items;
  final int initialIndex;
  final ValueChanged<int>? onIndexChanged;
  final SportoTabOverlayBuilder? overlayBuilder;

  const SportoBottomTabShell({
    super.key,
    required this.tabs,
    required this.items,
    this.initialIndex = 0,
    this.onIndexChanged,
    this.overlayBuilder,
  })  : assert(tabs.length == items.length),
        assert(tabs.length > 1);

  @override
  State<SportoBottomTabShell> createState() => SportoBottomTabShellState();
}

class SportoBottomTabShellState extends State<SportoBottomTabShell> {
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = _normalizeIndex(widget.initialIndex);
  }

  @override
  void didUpdateWidget(covariant SportoBottomTabShell oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialIndex != widget.initialIndex ||
        oldWidget.tabs.length != widget.tabs.length) {
      _currentIndex = _normalizeIndex(widget.initialIndex);
    }
  }

  int _normalizeIndex(int index) =>
      index.clamp(0, widget.tabs.length - 1).toInt();

  void setIndex(int index) {
    final nextIndex = _normalizeIndex(index);
    if (_currentIndex == nextIndex) {
      return;
    }
    setState(() => _currentIndex = nextIndex);
    widget.onIndexChanged?.call(nextIndex);
  }

  @override
  Widget build(BuildContext context) {
    final metrics = context.sportoResponsive;
    final scale = context.sportoScale;
    final overlay = widget.overlayBuilder?.call(context, _currentIndex, setIndex);
    final bottomNav = SportoBottomNav(
      currentIndex: _currentIndex,
      onTap: setIndex,
      items: widget.items,
    );

    return SportoScreenShell(
      body: Stack(
        fit: StackFit.expand,
        children: [
          Positioned.fill(
            child: IndexedStack(
              index: _currentIndex,
              children: widget.tabs,
            ),
          ),
          if (overlay != null)
            Positioned(
              left: 0,
              right: 0,
              bottom: metrics.bottomContentPadding(context) + 8 * scale,
              child: SportoResponsiveContent(
                child: overlay,
              ),
            ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: metrics.isTablet
                ? SafeArea(
                    top: false,
                    minimum: EdgeInsets.only(bottom: 8 * scale),
                    child: Center(
                      child: bottomNav,
                    ),
                  )
                : bottomNav,
          ),
        ],
      ),
    );
  }
}
