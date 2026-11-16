import 'package:flutter/material.dart';
import 'package:ui_kit/ui_kit.dart';

import 'notification_icons.dart';

/// Shared palette for the notification settings flow.
///
/// Values mirror `redesign/notifications_settings/tokens/tokens.json`.
abstract final class NotificationPalette {
  static const Color canvas = Color(0xFF090C10);
  static const Color card = Color(0xFF1C2026);
  static const Color white = Color(0xFFFFFFFF);
  static const Color muted = Color(0xFFA0A0A0);
  static const Color divider = Color(0x1AFFFFFF);
  static const Color backButton = Color(0x1AFFFFFF);
  static const Color offTrack = Color(0x33FFFFFF);
  static const Color iconTile = Color(0x6617191E);
  static const Color onTrack = Color(0x332BB673);
  static const Color onKnob = Color(0xFF2BB673);
  static const Color onTrackStart = Color(0xFF2BB673);
  static const Color onTrackEnd = Color(0xFF28A166);
}

/// Screen header shared by the notification settings list and category pages.
///
/// Matches the Figma header: 20 px side padding, a 36 px back affordance,
/// 10 px gap and a 44 px row followed by a 6 px bottom inset.
class NotificationPageHeader extends StatelessWidget {
  const NotificationPageHeader({
    super.key,
    required this.title,
    required this.scale,
    required this.onBack,
  });

  final String title;
  final double scale;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 6 * scale),
      child: Container(
        height: 44 * scale,
        padding: EdgeInsets.symmetric(horizontal: 20 * scale),
        decoration: const BoxDecoration(
          border: Border(
            bottom: BorderSide(color: NotificationPalette.divider),
          ),
        ),
        child: Row(
          children: [
            _BackButton(scale: scale, onTap: onBack),
            SizedBox(width: 2 * scale),
            Expanded(
              child: Semantics(
                header: true,
                child: Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: SportoTextStyles.text(
                    size: 16 * scale,
                    weight: FontWeight.w700,
                    color: NotificationPalette.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BackButton extends StatelessWidget {
  const _BackButton({required this.scale, required this.onTap});

  final double scale;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      key: const ValueKey<String>('notification_back_button'),
      button: true,
      label: 'Back',
      excludeSemantics: true,
      onTap: onTap,
      child: SizedBox(
        width: 44 * scale,
        height: 44 * scale,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            excludeFromSemantics: true,
            borderRadius: BorderRadius.circular(12 * scale),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Ink(
                width: 36 * scale,
                height: 36 * scale,
                decoration: BoxDecoration(
                  color: NotificationPalette.backButton,
                  borderRadius: BorderRadius.circular(10 * scale),
                ),
                child: Center(
                  child: SportoSvgIcon(
                    NotificationIcons.back,
                    width: 12 * scale,
                    height: 18 * scale,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// A tappable card used by every row in the flow.
///
/// The whole card is the tap target (57-72 px tall), which comfortably clears
/// the 44 px accessibility minimum while keeping the 40x20 switch visually
/// faithful to Figma.
class NotificationCard extends StatelessWidget {
  const NotificationCard({
    super.key,
    required this.scale,
    required this.child,
    this.onTap,
    this.minHeight = 0,
  });

  final double scale;
  final Widget child;
  final VoidCallback? onTap;
  final double minHeight;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: NotificationPalette.card,
      borderRadius: BorderRadius.circular(14 * scale),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        excludeFromSemantics: true,
        child: ConstrainedBox(
          constraints: BoxConstraints(minHeight: minHeight * scale),
          child: Padding(
            padding: EdgeInsets.all(10 * scale),
            child: child,
          ),
        ),
      ),
    );
  }
}

/// Figma-faithful 40x20 switch with a white knob.
///
/// The surrounding row owns the tap gesture; this widget only exposes the
/// semantic state/action so screen readers announce `<title>, on/off`.
class NotificationToggle extends StatelessWidget {
  const NotificationToggle({
    super.key,
    required this.toggleKey,
    required this.value,
    required this.semanticLabel,
    required this.scale,
    required this.onChanged,
  });

  final Key toggleKey;
  final bool value;
  final String semanticLabel;
  final double scale;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final reduceMotion =
        MediaQuery.maybeOf(context)?.disableAnimations ?? false;
    final duration =
        reduceMotion ? Duration.zero : const Duration(milliseconds: 180);

    return Semantics(
      key: toggleKey,
      label: semanticLabel,
      toggled: value,
      onTap: () => onChanged(!value),
      child: ExcludeSemantics(
        child: AnimatedContainer(
          duration: duration,
          curve: Curves.easeOutCubic,
          width: 40 * scale,
          height: 20 * scale,
          padding: EdgeInsets.all(2 * scale),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20 * scale),
            color: value
                ? NotificationPalette.onTrack
                : NotificationPalette.offTrack,
          ),
          child: AnimatedAlign(
            duration: duration,
            curve: Curves.easeOutCubic,
            alignment: value ? Alignment.centerRight : Alignment.centerLeft,
            child: Container(
              width: 16 * scale,
              height: 16 * scale,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: value
                    ? NotificationPalette.onKnob
                    : NotificationPalette.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.18),
                    blurRadius: 2 * scale,
                    offset: Offset(0, 1 * scale),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
