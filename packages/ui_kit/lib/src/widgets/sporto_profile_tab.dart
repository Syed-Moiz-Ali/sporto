import 'package:flutter/material.dart';

import '../theme/sporto_design_tokens.dart';
import 'sporto_referee_profile.dart';

class SportoProfileMenuSectionData {
  final List<SportoProfileMenuItemData> items;

  const SportoProfileMenuSectionData({
    required this.items,
  });
}

class SportoProfileTab extends StatelessWidget {
  final String name;
  final String phone;
  final ImageProvider? avatarImage;
  final String certificationLabel;
  final String certificationTitle;
  final List<SportoProfileStatData> stats;
  final List<SportoProfileMenuSectionData> sections;
  final VoidCallback? onAvatarTap;
  final VoidCallback? onLogoutTap;
  final EdgeInsetsGeometry? padding;

  const SportoProfileTab({
    super.key,
    required this.name,
    required this.phone,
    required this.certificationLabel,
    required this.certificationTitle,
    required this.stats,
    required this.sections,
    this.avatarImage,
    this.onAvatarTap,
    this.onLogoutTap,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    final scale = context.sportoScale;

    return SafeArea(
      bottom: false,
      child: SingleChildScrollView(
        physics: const ClampingScrollPhysics(),
        padding: padding ??
            EdgeInsets.fromLTRB(
              20 * scale,
              18 * scale,
              20 * scale,
              84 * scale,
            ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SportoProfileHeaderCard(
              name: name,
              phone: phone,
              avatarImage: avatarImage,
              onTap: onAvatarTap,
            ),
            SizedBox(height: 22 * scale),
            SportoCertifiedBadge(
              label: certificationLabel,
              title: certificationTitle,
            ),
            SizedBox(height: 22 * scale),
            SportoProfileStatsRow(stats: stats),
            for (final section in sections) ...[
              SizedBox(height: 20 * scale),
              SportoProfileMenuCard(items: section.items),
            ],
            SizedBox(height: 22 * scale),
            Center(
              child: SportoLogoutButton(onTap: onLogoutTap),
            ),
          ],
        ),
      ),
    );
  }
}
