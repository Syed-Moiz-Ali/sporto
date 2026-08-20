import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:ui_kit/ui_kit.dart';

import '../../../../app/router/app_router.dart';
import '../../../partner_api/application/partner_api_bloc.dart';

class PartnerProfileScreen extends StatelessWidget {
  const PartnerProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PartnerApiBloc, PartnerApiState>(
      builder: (context, state) {
        final loaded = state is PartnerApiLoadedState ? state : null;

        final name = loaded?.displayName ?? 'Partner';
        final phone = loaded?.mobileNumber.isNotEmpty == true
            ? '+91 ${loaded!.mobileNumber}'
            : '—';

        final totalTournaments = loaded?.tournaments.length ?? 0;
        final completed = loaded?.completedTournaments.length ?? 0;
        final live = loaded?.liveTournaments.length ?? 0;

        return SportoProfileTab(
          name: name,
          phone: phone,
          certificationLabel: 'Verified Partner',
          certificationTitle: 'Organizer',
          stats: [
            SportoProfileStatData(
                value: '$totalTournaments', label: 'Tournaments'),
            SportoProfileStatData(value: '$completed', label: 'Completed'),
            SportoProfileStatData(value: '$live', label: 'Live'),
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
      },
    );
  }
}
