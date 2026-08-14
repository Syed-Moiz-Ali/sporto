import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../theme/sporto_design_tokens.dart';

enum SportoDeviceClass {
  compactPhone,
  phone,
  largePhone,
  tablet,
}

@immutable
class SportoResponsiveMetrics {
  final double width;
  final SportoDeviceClass deviceClass;
  final double horizontalPadding;
  final double contentMaxWidth;
  final double navMaxWidth;
  final double bottomNavHeight;
  final double bottomNavGap;

  const SportoResponsiveMetrics({
    required this.width,
    required this.deviceClass,
    required this.horizontalPadding,
    required this.contentMaxWidth,
    required this.navMaxWidth,
    required this.bottomNavHeight,
    required this.bottomNavGap,
  });

  bool get isTablet => deviceClass == SportoDeviceClass.tablet;

  double bottomContentPadding(BuildContext context) =>
      bottomNavHeight + bottomNavGap + MediaQuery.paddingOf(context).bottom;

  static SportoResponsiveMetrics of(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final scale = context.sportoScale;

    final deviceClass = width >= 600
        ? SportoDeviceClass.tablet
        : width >= 414
            ? SportoDeviceClass.largePhone
            : width <= 340
                ? SportoDeviceClass.compactPhone
                : SportoDeviceClass.phone;

    final horizontalPadding = switch (deviceClass) {
      SportoDeviceClass.compactPhone => 16 * scale,
      SportoDeviceClass.phone => 20 * scale,
      SportoDeviceClass.largePhone => 22 * scale,
      SportoDeviceClass.tablet => 28 * scale,
    };

    return SportoResponsiveMetrics(
      width: width,
      deviceClass: deviceClass,
      horizontalPadding: horizontalPadding,
      contentMaxWidth: deviceClass == SportoDeviceClass.tablet ? 720 : width,
      navMaxWidth: deviceClass == SportoDeviceClass.tablet ? 460 : 420,
      bottomNavHeight: 62 * scale,
      bottomNavGap: 12 * scale,
    );
  }
}

extension SportoResponsiveContext on BuildContext {
  SportoResponsiveMetrics get sportoResponsive =>
      SportoResponsiveMetrics.of(this);
}

class SportoResponsiveContent extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final bool applyHorizontalPadding;
  final bool applyBottomInset;
  final double? maxWidth;
  final AlignmentGeometry alignment;

  const SportoResponsiveContent({
    super.key,
    required this.child,
    this.padding,
    this.applyHorizontalPadding = true,
    this.applyBottomInset = false,
    this.maxWidth,
    this.alignment = Alignment.topCenter,
  });

  @override
  Widget build(BuildContext context) {
    final metrics = context.sportoResponsive;
    final resolvedPadding = padding ??
        EdgeInsets.fromLTRB(
          applyHorizontalPadding ? metrics.horizontalPadding : 0,
          0,
          applyHorizontalPadding ? metrics.horizontalPadding : 0,
          applyBottomInset ? metrics.bottomContentPadding(context) : 0,
        );

    return Align(
      alignment: alignment,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: math.min(maxWidth ?? metrics.contentMaxWidth, metrics.width),
        ),
        child: Padding(
          padding: resolvedPadding,
          child: child,
        ),
      ),
    );
  }
}
