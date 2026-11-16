import 'package:flutter/material.dart';
import 'package:ui_kit/ui_kit.dart';

import '../notification_models.dart';
import '../notification_shared.dart';
import '../notification_store.dart';

/// Category detail page (Figma screens 02-06).
///
/// Preferences are local widget state until the referee notification
/// preferences API is available.
///
/// TODO(referee-notifications): Persist toggles through the referee
/// notification-preferences endpoint once it exists. The missing endpoint is
/// documented in `docs/referee_new_ui_backend_gaps.md`.
class NotificationCategoryScreen extends StatefulWidget {
  const NotificationCategoryScreen({
    super.key,
    required this.category,
    this.initialPreferences,
  });

  final NotificationCategory category;

  /// Optional starting snapshot. Missing ids fall back to the Figma defaults.
  final NotificationPreferences? initialPreferences;

  @override
  State<NotificationCategoryScreen> createState() =>
      _NotificationCategoryScreenState();
}

class _NotificationCategoryScreenState
    extends State<NotificationCategoryScreen> {
  static const String _subtitle = 'Choose what you want to be notified about.';

  late NotificationPreferences _preferences;

  @override
  void initState() {
    super.initState();
    _preferences = _resolvedPreferences();
  }

  @override
  void didUpdateWidget(covariant NotificationCategoryScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.category != widget.category ||
        oldWidget.initialPreferences != widget.initialPreferences) {
      _preferences = _resolvedPreferences();
    }
  }

  NotificationPreferences _resolvedPreferences() {
    if (widget.initialPreferences != null) {
      return widget.initialPreferences!.resolvedFor(widget.category);
    }
    return NotificationPreferencesStore.instance
        .preferencesFor(widget.category);
  }

  void _toggle(String id) {
    setState(() {
      _preferences = _preferences.toggled(id);
    });
    if (widget.initialPreferences == null) {
      NotificationPreferencesStore.instance.update(
        widget.category,
        _preferences,
      );
    }
  }

  void _pop() {
    final NavigatorState navigator = Navigator.of(context);
    if (navigator.canPop()) {
      navigator.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final double scale = context.sportoScale;

    return Scaffold(
      backgroundColor: NotificationPalette.canvas,
      body: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            NotificationPageHeader(
              title: widget.category.title,
              scale: scale,
              onBack: _pop,
            ),
            Expanded(
              child: SingleChildScrollView(
                physics: const ClampingScrollPhysics(),
                padding: EdgeInsets.fromLTRB(
                  20 * scale,
                  10 * scale,
                  20 * scale,
                  20 * scale,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      _subtitle,
                      style: SportoTextStyles.text(
                        size: 14 * scale,
                        weight: FontWeight.w500,
                        color: NotificationPalette.muted,
                        height: 1.3,
                      ),
                    ),
                    SizedBox(height: 10 * scale),
                    for (var i = 0;
                        i < widget.category.preferences.length;
                        i++) ...[
                      if (i > 0) SizedBox(height: 6 * scale),
                      _PreferenceRow(
                        preference: widget.category.preferences[i],
                        value: _preferences
                            .isEnabled(widget.category.preferences[i].id),
                        scale: scale,
                        onChanged: _toggle,
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PreferenceRow extends StatelessWidget {
  const _PreferenceRow({
    required this.preference,
    required this.value,
    required this.scale,
    required this.onChanged,
  });

  final NotificationPreference preference;
  final bool value;
  final double scale;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return NotificationCard(
      key: ValueKey<String>('notification_pref_row_${preference.id}'),
      scale: scale,
      minHeight: 57,
      onTap: () => onChanged(preference.id),
      child: Row(
        children: [
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  preference.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: SportoTextStyles.text(
                    size: 14 * scale,
                    weight: FontWeight.w500,
                    color: NotificationPalette.white,
                    height: 1.3,
                  ),
                ),
                SizedBox(height: 4 * scale),
                Text(
                  preference.description,
                  style: SportoTextStyles.text(
                    size: 12 * scale,
                    weight: FontWeight.w400,
                    color: NotificationPalette.muted,
                    height: 1.25,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: 8 * scale),
          NotificationToggle(
            toggleKey: ValueKey<String>('notification_toggle_${preference.id}'),
            value: value,
            semanticLabel: preference.title,
            scale: scale,
            onChanged: (_) => onChanged(preference.id),
          ),
        ],
      ),
    );
  }
}
