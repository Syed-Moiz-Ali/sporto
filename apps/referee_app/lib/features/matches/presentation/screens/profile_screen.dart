import 'package:flutter/material.dart';
import 'package:ui_kit/ui_kit.dart';

class RefereeProfileScreen extends StatelessWidget {
  const RefereeProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final scale = context.sportoScale;

    return SafeArea(
      bottom: false,
      child: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              physics: const ClampingScrollPhysics(),
              padding: EdgeInsets.fromLTRB(
                20 * scale,
                18 * scale,
                20 * scale,
                20 * scale,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SportoProfileHeaderCard(
                    name: 'Priya Agrawal',
                    phone: '+91 98765XXXXX',
                    avatarImage: const AssetImage(
                      'assets/images/profile_avatar.png',
                    ),
                    onTap: () {
                      // open edit profile / profile details
                    },
                  ),
                  SizedBox(height: 22 * scale),
                  const SportoCertifiedBadge(
                    title: 'Cricket',
                  ),
                  SizedBox(height: 22 * scale),
                  SportoProfileStatsRow(
                    stats: [
                      SportoProfileStatData(
                        value: '48',
                        label: 'Matches',
                      ),
                      SportoProfileStatData(
                        value: '4.9',
                        label: 'Rating',
                      ),
                      SportoProfileStatData(
                        value: '2',
                        label: 'Disputes',
                      ),
                    ],
                  ),
                  SizedBox(height: 20 * scale),
                  SportoProfileMenuCard(
                    items: [
                      SportoProfileMenuItemData(
                        title: 'Statistic',
                        icon: Icons.notifications_none_rounded,
                        onTap: () {
                          // context.push('/statistics');
                        },
                      ),
                      SportoProfileMenuItemData(
                        title: 'My Tournaments',
                        icon: Icons.notifications_none_rounded,
                        onTap: () {
                          // context.push('/my-tournaments');
                        },
                      ),
                    ],
                  ),
                  SizedBox(height: 20 * scale),
                  SportoProfileMenuCard(
                    items: [
                      SportoProfileMenuItemData(
                        title: 'Add Customer Support',
                        icon: Icons.notifications_none_rounded,
                        onTap: () {
                          // context.push('/customer-support');
                        },
                      ),
                    ],
                  ),
                  SizedBox(height: 20 * scale),
                  SportoProfileMenuCard(
                    items: [
                      SportoProfileMenuItemData(
                        title: 'About Us',
                        icon: Icons.priority_high_rounded,
                        onTap: () {
                          // context.push('/about-us');
                        },
                      ),
                      SportoProfileMenuItemData(
                        title: 'Terms & Condition',
                        icon: Icons.priority_high_rounded,
                        onTap: () {
                          // context.push('/terms');
                        },
                      ),
                      SportoProfileMenuItemData(
                        title: 'Privacy Policy',
                        icon: Icons.priority_high_rounded,
                        onTap: () {
                          // context.push('/privacy-policy');
                        },
                      ),
                      SportoProfileMenuItemData(
                        title: 'Customer Service',
                        icon: Icons.support_agent_rounded,
                        onTap: () {
                          // context.push('/customer-service');
                        },
                      ),
                    ],
                  ),
                  SizedBox(height: 22 * scale),
                  Center(
                    child: SportoLogoutButton(
                      onTap: () {
                        _showLogoutDialog(context);
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: const Color(0xFF18233A),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          title: const Text(
            'Logout',
            style: TextStyle(color: Colors.white),
          ),
          content: const Text(
            'Are you sure you want to logout?',
            style: TextStyle(color: Colors.white70),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();

                // call logout bloc / auth bloc here
                // context.read<AuthBloc>().add(LogoutRequested());

                if (context.mounted) {
                  // context.go('/login');
                }
              },
              child: const Text('Logout'),
            ),
          ],
        );
      },
    );
  }
}
