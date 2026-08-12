import 'package:flutter/material.dart';

enum SportoAppBackground {
  referee,
  partner,
}

/// Selects the shared shell artwork once for an entire application.
class SportoAppBackgroundScope extends InheritedWidget {
  const SportoAppBackgroundScope({
    super.key,
    required this.background,
    required super.child,
  });

  final SportoAppBackground background;

  static SportoAppBackground of(BuildContext context) =>
      context
          .dependOnInheritedWidgetOfExactType<SportoAppBackgroundScope>()
          ?.background ??
      SportoAppBackground.referee;

  @override
  bool updateShouldNotify(SportoAppBackgroundScope oldWidget) =>
      background != oldWidget.background;
}

/// The single page shell for every authenticated SPORTO screen.
class SportoScreenShell extends StatelessWidget {
  const SportoScreenShell({
    super.key,
    required this.body,
    this.appBar,
    this.bottomNavigationBar,
    this.floatingActionButton,
    this.resizeToAvoidBottomInset,
  });

  final Widget body;
  final PreferredSizeWidget? appBar;
  final Widget? bottomNavigationBar;
  final Widget? floatingActionButton;
  final bool? resizeToAvoidBottomInset;

  @override
  Widget build(BuildContext context) {
    final background = SportoAppBackgroundScope.of(context);
    final assetName = switch (background) {
      SportoAppBackground.referee => 'assets/backgrounds/referee_app_bg.png',
      SportoAppBackground.partner => 'assets/backgrounds/partner_app_bg.png',
    };

    return Stack(
      fit: StackFit.expand,
      children: [
        Image.asset(
          assetName,
          package: 'ui_kit',
          alignment: Alignment.topCenter,
          fit: BoxFit.cover,
          filterQuality: FilterQuality.high,
          gaplessPlayback: true,
        ),
        Scaffold(
          backgroundColor: Colors.transparent,
          appBar: appBar,
          body: body,
          bottomNavigationBar: bottomNavigationBar,
          floatingActionButton: floatingActionButton,
          resizeToAvoidBottomInset: resizeToAvoidBottomInset,
        ),
      ],
    );
  }
}
