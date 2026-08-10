import 'package:flutter/material.dart';

import '../theme/sporto_design_tokens.dart';
import 'sporto_ambient_background.dart';

/// Central SPORTO page surface used instead of recreating backgrounds.
class SportoScreenShell extends StatelessWidget {
  const SportoScreenShell({
    super.key,
    required this.body,
    this.appBar,
    this.bottomNavigationBar,
    this.floatingActionButton,
    this.resizeToAvoidBottomInset,
    this.ambient = false,
  });

  final Widget body;
  final PreferredSizeWidget? appBar;
  final Widget? bottomNavigationBar;
  final Widget? floatingActionButton;
  final bool? resizeToAvoidBottomInset;
  final bool ambient;

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: context.sporto.canvas,
        appBar: appBar,
        body: Stack(fit: StackFit.expand, children: [
          if (ambient) const SportoAmbientBackground(),
          body,
        ]),
        bottomNavigationBar: bottomNavigationBar,
        floatingActionButton: floatingActionButton,
        resizeToAvoidBottomInset: resizeToAvoidBottomInset,
      );
}
