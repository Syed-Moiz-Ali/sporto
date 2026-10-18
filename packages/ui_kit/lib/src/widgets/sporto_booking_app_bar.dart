import 'package:flutter/material.dart';

import '../assets/sporto_assets.dart';
import '../theme/sporto_design_tokens.dart';
import '../theme/sporto_text_styles.dart';
import 'sporto_glass_surface.dart';

/// Sticky header used on every referee-booking screen.
///
/// Figma: `Frame 1000003334` (canvas @0.2, blur 100) containing a 44-high row
/// (pad 4/20) with a 36x36 back button and a title/subtitle column.
///
/// NOTE: the Figma tinted/blurred header background is intentionally NOT
/// rendered (transparent) so no band shows behind the app bar when the body
/// scrolls.
class SportoBookingAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final String? subtitle;
  final VoidCallback? onBack;
  final List<Widget> actions;

  const SportoBookingAppBar({
    super.key,
    required this.title,
    this.subtitle,
    this.onBack,
    this.actions = const [],
  });

  static const double _rowHeight = 44;

  @override
  Size get preferredSize => const Size.fromHeight(_rowHeight + 10);

  @override
  Widget build(BuildContext context) {
    final tokens = context.sporto;

    return SafeArea(
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 4, 20, 10),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            _BackButton(onTap: onBack),
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
                      weight: SportoTextStyles.bold,
                      color: Theme.of(context).colorScheme.onSurface,
                      height: 1.25,
                    ),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      subtitle!,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: SportoTextStyles.text(
                        size: SportoTextStyles.size11,
                        weight: SportoTextStyles.medium,
                        color: tokens.muted,
                        height: 1.2,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            ...actions,
          ],
        ),
      ),
    );
  }
}

class _BackButton extends StatelessWidget {
  final VoidCallback? onTap;

  const _BackButton({this.onTap});

  @override
  Widget build(BuildContext context) {
    final tokens = context.sporto;
    final layout = context.sportoLayout;
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: SportoGlassSurface(
        width: 36,
        height: 36,
        radius: layout.radius10,
        blur: layout.glassBlur,
        color: tokens.whiteOverlay10,
        shadows: const [
          BoxShadow(color: Color(0x1F000000), blurRadius: 4, offset: Offset(0, 2)),
        ],
        child: const Center(
          child: SportoSvgIcon(SportoRefereeBookingIcons.back, height: 14),
        ),
      ),
    );
  }
}
