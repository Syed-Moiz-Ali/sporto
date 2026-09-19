import 'package:flutter/material.dart';
import 'package:referee_data/referee_data.dart';
import '../../../../core/di/dependency_injector.dart';
import 'package:ui_kit/ui_kit.dart';

class RefereeProfileScreen extends StatefulWidget {
  const RefereeProfileScreen({super.key});
  @override
  State<RefereeProfileScreen> createState() => _RefereeProfileScreenState();
}

class _RefereeProfileScreenState extends State<RefereeProfileScreen> {
  late final Future<RefereeProfileResponse> _profile =
      DependencyInjector.instance.refereeRemoteDataSource.getProfile();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<RefereeProfileResponse>(
      future: _profile,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Center(
              child: snapshot.hasError
                  ? Text('Unable to load profile: ${snapshot.error}')
                  : const CircularProgressIndicator());
        }
        final profile = snapshot.data!;
        return SportoProfileTab(
          name: profile.name,
          phone: profile.mobile ?? 'Phone not available',
          certificationLabel: 'Certified Referee',
          certificationTitle: profile.sports.join(' • '),
          avatarImage: const AssetImage('assets/images/profile_avatar.png'),
          onAvatarTap: () {
            // open edit profile / profile details
          },
          stats: [
            SportoProfileStatData(
                value: '${profile.experienceYears ?? 0}', label: 'Experience'),
            SportoProfileStatData(
                value: '${profile.sports.length}', label: 'Sports'),
            SportoProfileStatData(
                value: profile.email == null ? '—' : '✓', label: 'Email'),
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
      },
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
