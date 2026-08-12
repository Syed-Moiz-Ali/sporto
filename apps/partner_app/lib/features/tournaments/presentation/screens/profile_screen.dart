import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:ui_kit/ui_kit.dart';

import '../../../../app/router/app_router.dart';

class PartnerProfileScreen extends StatelessWidget {
  const PartnerProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SportoProfileTab(
      name: "Shrvn's Sporto",
      phone: '+91 98765XXXXX',
      certificationLabel: 'Verified Partner',
      certificationTitle: 'Organizer',
      avatarImage: const AssetImage('assets/images/profile_avatar.png'),
      stats: const [
        SportoProfileStatData(value: '12', label: 'Tournaments'),
        SportoProfileStatData(value: '48', label: 'Matches'),
        SportoProfileStatData(value: '6', label: 'Venues'),
      ],
      sections: [
        SportoProfileMenuSectionData(
          items: [
            const SportoProfileMenuItemData(
              title: 'Statistic',
              icon: Icons.bar_chart_rounded,
            ),
            SportoProfileMenuItemData(
              title: 'My Tournaments',
              icon: Icons.emoji_events_outlined,
              onTap: () => context.push(AppRouter.matchHistoryRoute),
            ),
          ],
        ),
        const SportoProfileMenuSectionData(
          items: [
            SportoProfileMenuItemData(
              title: 'Add Customer Support',
              icon: Icons.support_agent_outlined,
            ),
          ],
        ),
        const SportoProfileMenuSectionData(
          items: [
            SportoProfileMenuItemData(
              title: 'About Us',
              icon: Icons.error_outline_rounded,
            ),
            SportoProfileMenuItemData(
              title: 'Terms & Condition',
              icon: Icons.error_outline_rounded,
            ),
            SportoProfileMenuItemData(
              title: 'Privacy Policy',
              icon: Icons.error_outline_rounded,
            ),
            SportoProfileMenuItemData(
              title: 'Customer Service',
              icon: Icons.support_agent_outlined,
            ),
          ],
        ),
      ],
      onLogoutTap: () => context.read<AuthBloc>().add(LogoutRequestedEvent()),
    );
  }
}
