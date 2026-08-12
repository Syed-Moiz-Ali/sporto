import 'package:flutter/material.dart';
import 'package:ui_kit/ui_kit.dart';

class RefereeProfileScreen extends StatelessWidget {
  const RefereeProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SportoProfileTab(
      name: 'Priya Agrawal',
      phone: '+91 98765XXXXX',
      certificationLabel: 'Certified Referee',
      certificationTitle: 'Cricket',
      avatarImage: const AssetImage('assets/images/profile_avatar.png'),
      onAvatarTap: () {
        // open edit profile / profile details
      },
      stats: const [
        SportoProfileStatData(value: '48', label: 'Matches'),
        SportoProfileStatData(value: '4.9', label: 'Rating'),
        SportoProfileStatData(value: '2', label: 'Disputes'),
      ],
      sections: const [
        SportoProfileMenuSectionData(
          items: [
            SportoProfileMenuItemData(
              title: 'Statistic',
              icon: Icons.notifications_none_rounded,
            ),
            SportoProfileMenuItemData(
              title: 'My Tournaments',
              icon: Icons.notifications_none_rounded,
            ),
          ],
        ),
        SportoProfileMenuSectionData(
          items: [
            SportoProfileMenuItemData(
              title: 'Add Customer Support',
              icon: Icons.notifications_none_rounded,
            ),
          ],
        ),
        SportoProfileMenuSectionData(
          items: [
            SportoProfileMenuItemData(
              title: 'About Us',
              icon: Icons.priority_high_rounded,
            ),
            SportoProfileMenuItemData(
              title: 'Terms & Condition',
              icon: Icons.priority_high_rounded,
            ),
            SportoProfileMenuItemData(
              title: 'Privacy Policy',
              icon: Icons.priority_high_rounded,
            ),
            SportoProfileMenuItemData(
              title: 'Customer Service',
              icon: Icons.support_agent_rounded,
            ),
          ],
        ),
      ],
      onLogoutTap: () => _showLogoutDialog(context),
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
              },
              child: const Text('Logout'),
            ),
          ],
        );
      },
    );
  }
}
