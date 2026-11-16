import 'package:flutter/material.dart';
import 'package:ui_kit/ui_kit.dart';

import '../notification_icons.dart';
import '../notification_models.dart';
import '../notification_shared.dart';
import 'notification_category_screen.dart';

/// Notification settings landing page (Figma screen 01).
///
/// This page is intentionally static: there is no loading or error state.
/// Preferences themselves are owned by [NotificationCategoryScreen] because no
/// referee notification-preferences endpoint exists yet. See
/// `docs/referee_new_ui_backend_gaps.md`.
class NotificationSettingsScreen extends StatelessWidget {
  const NotificationSettingsScreen({super.key});

  static const String subtitle = 'Choose what you want to be notified about.';

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
              title: 'Notification Settings',
              scale: scale,
              onBack: () => Navigator.of(context).maybePop(),
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
                      subtitle,
                      style: SportoTextStyles.text(
                        size: 14 * scale,
                        weight: FontWeight.w500,
                        color: NotificationPalette.muted,
                        height: 1.3,
                      ),
                    ),
                    SizedBox(height: 10 * scale),
                    for (var i = 0;
                        i < NotificationCategory.values.length;
                        i++) ...[
                      if (i > 0) SizedBox(height: 6 * scale),
                      _CategoryRow(
                        category: NotificationCategory.values[i],
                        scale: scale,
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

class _CategoryRow extends StatelessWidget {
  const _CategoryRow({required this.category, required this.scale});

  final NotificationCategory category;
  final double scale;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      key: ValueKey<String>('notification_row_${category.id}'),
      container: true,
      button: true,
      label: '${category.title}. ${category.summary}',
      excludeSemantics: true,
      onTap: () => _open(context),
      child: NotificationCard(
        scale: scale,
        minHeight: 48,
        onTap: () => _open(context),
        child: Row(
          children: [
            Container(
              width: 40 * scale,
              height: 40 * scale,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: NotificationPalette.iconTile,
                borderRadius: BorderRadius.circular(14 * scale),
              ),
              child: SportoSvgIcon(
                category.iconAsset,
                width: 24 * scale,
                height: 24 * scale,
              ),
            ),
            SizedBox(width: 8 * scale),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    category.title,
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
                    category.summary,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: SportoTextStyles.text(
                      size: 10 * scale,
                      weight: FontWeight.w400,
                      color: NotificationPalette.muted,
                      height: 1.3,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(width: 10 * scale),
            SportoSvgIcon(
              NotificationIcons.chevronRight,
              width: 16 * scale,
              height: 16 * scale,
            ),
          ],
        ),
      ),
    );
  }

  void _open(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => NotificationCategoryScreen(category: category),
      ),
    );
  }
}
