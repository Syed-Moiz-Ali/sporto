import 'package:flutter/material.dart';

import '../assets/sporto_assets.dart';
import '../theme/sporto_design_tokens.dart';
import '../theme/sporto_text_styles.dart';
import 'sporto_doc_card.dart';

/// List card for a referee or venue (Figma `DocCard` 350x70/77/94).
///
/// Composition-based: screens supply the title, the meta rows and the trailing
/// column so the same widget covers the referee list, venue list and profile
/// variants without duplicating layout.
class SportoBookingTile extends StatelessWidget {
  final String title;
  final Widget? subtitle;
  final Widget? meta;
  final Widget? trailing;
  final Widget? footer;
  final Widget? leading;
  final VoidCallback? onTap;

  const SportoBookingTile({
    super.key,
    required this.title,
    this.subtitle,
    this.meta,
    this.trailing,
    this.footer,
    this.leading,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final tokens = context.sporto;
    return SportoDocCard(
      padding: const EdgeInsets.all(10),
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              leading ?? const _DefaultAvatar(),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: SportoTextStyles.text(
                        size: SportoTextStyles.size16,
                        weight: SportoTextStyles.semiBold,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(height: 2),
                      subtitle!,
                    ],
                    if (meta != null) ...[
                      const SizedBox(height: 2),
                      meta!,
                    ],
                  ],
                ),
              ),
              if (trailing != null) ...[
                const SizedBox(width: 10),
                trailing!,
              ],
            ],
          ),
          if (footer != null) ...[
            const SizedBox(height: 10),
            Container(height: 1, color: tokens.border.withValues(alpha: 0.5)),
            const SizedBox(height: 10),
            footer!,
          ],
        ],
      ),
    );
  }
}

/// Default referee avatar: faint green tile behind the bundled raster.
class _DefaultAvatar extends StatelessWidget {
  const _DefaultAvatar();

  @override
  Widget build(BuildContext context) {
    final tokens = context.sporto;
    return Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(
        color: tokens.avatarGreen.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(13.16),
      ),
      clipBehavior: Clip.antiAlias,
      child: const SportoAssetIcon(
        SportoRefereeBookingIcons.avatarReferee,
        size: 50,
        fit: BoxFit.cover,
      ),
    );
  }
}
