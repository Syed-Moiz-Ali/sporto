import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:core/core.dart';
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
    final scale = context.sportoScale;
    return FutureBuilder<RefereeProfileResponse>(
      future: _profile,
      builder: (context, snapshot) {
        final profile = snapshot.data;
        final name = profile?.name ?? 'Priya Agrawal';
        final phone = profile?.mobile ?? '+91 98765XXXXX';
        final sport =
            (profile?.sports.isNotEmpty == true) ? profile!.sports.first : 'Cricket';
        final matches = '${profile?.experienceYears ?? 48}';

        return Container(
          decoration: const BoxDecoration(
            color: Color(0xFF090C10),
          ),
          child: SafeArea(
            bottom: false,
            child: SingleChildScrollView(
              physics: const ClampingScrollPhysics(),
              padding: EdgeInsets.fromLTRB(
                20 * scale,
                10 * scale,
                20 * scale,
                20 * scale,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ============================================
                  // PROFILE CARD (Frame 1000006730, r20, 350×78)
                  // ============================================
                  _buildProfileCard(
                    scale: scale,
                    name: name,
                    phone: phone,
                  ),

                  SizedBox(height: 20 * scale),

                  // ============================================
                  // CERTIFICATION BADGE (Frame 1171275288, r16, 350×38)
                  // ============================================
                  _buildCertBadge(scale: scale, sport: sport),

                  SizedBox(height: 20 * scale),

                  // ============================================
                  // STATS ROW (Frame 1244830902): Matches, Rating, Disputes
                  // ============================================
                  _buildStatsRow(scale: scale, matches: matches),

                  SizedBox(height: 20 * scale),

                  // ============================================
                  // MENU CARD 1 (Frame 1261154217, r16, #1b2335)
                  // Statistic, My Tournaments, Wallet Transaction, Bank Account
                  // ============================================
                  _buildMenuCard(
                    scale: scale,
                    items: const [
                      _MenuItem(icon: Icons.bar_chart_rounded, label: 'Statistic'),
                      _MenuItem(icon: Icons.emoji_events_outlined, label: 'My Tournaments'),
                      _MenuItem(
                          icon: Icons.account_balance_wallet_outlined,
                          label: 'Wallet Transaction'),
                      _MenuItem(
                          icon: Icons.account_balance_outlined,
                          label: 'Bank Account'),
                    ],
                    opacity: 1.0,
                    labelColor: Colors.white,
                  ),

                  SizedBox(height: 20 * scale),

                  // ============================================
                  // MENU CARD 2 (Frame 1261154218, r16, #1b2335)
                  // Add Customer Support
                  // ============================================
                  _buildMenuCard(
                    scale: scale,
                    items: const [
                      _MenuItem(
                          icon: Icons.headset_mic_outlined,
                          label: 'Add Customer Support'),
                    ],
                    opacity: 1.0,
                    labelColor: Colors.white,
                  ),

                  SizedBox(height: 20 * scale),

                  // ============================================
                  // MENU CARD 3 (Frame 1171275243, r16, 60% #1b2335)
                  // About Us, Terms & Condition, Privacy Policy, Customer Service
                  // Labels gray #a0a0a0 per Figma
                  // ============================================
                  _buildMenuCard(
                    scale: scale,
                    items: const [
                      _MenuItem(icon: Icons.info_outline_rounded, label: 'About Us'),
                      _MenuItem(
                          icon: Icons.description_outlined,
                          label: 'Terms & Condition'),
                      _MenuItem(
                          icon: Icons.privacy_tip_outlined,
                          label: 'Privacy Policy'),
                      _MenuItem(
                          icon: Icons.support_agent_rounded,
                          label: 'Customer Service'),
                    ],
                    opacity: 0.6,
                    labelColor: const Color(0xFFA0A0A0),
                  ),

                  SizedBox(height: 20 * scale),

                  // ============================================
                  // LOGOUT BUTTON (Frame 17, r16, 160×60)
                  // ============================================
                  _buildLogoutButton(scale: scale),

                  SizedBox(height: 20 * scale),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // ==========================================================
  // PROFILE CARD
  // ==========================================================

  Widget _buildProfileCard({
    required double scale,
    required String name,
    required String phone,
  }) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: 16 * scale,
        vertical: 14 * scale,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20 * scale),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFFFF9364).withOpacity(0.20),
            const Color(0xFFF25F33).withOpacity(0.10),
          ],
        ),
        border: Border.all(
          color: const Color(0xFFF53E02).withOpacity(0.20),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          // Avatar: orange gradient ring, initials inside
          Container(
            width: 50 * scale,
            height: 50 * scale,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFFDF3F00), Color(0xFFF65800)],
              ),
            ),
            padding: EdgeInsets.all(2 * scale),
            child: Container(
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Color(0xFF1B2335),
              ),
              child: Center(
                child: Text(
                  _initials(name),
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16 * scale,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ),

          SizedBox(width: 12 * scale),

          // Name + Phone
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16 * scale,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: 4 * scale),
                Text(
                  phone,
                  style: TextStyle(
                    color: const Color(0xFFA0A0A0),
                    fontSize: 12 * scale,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================================
  // CERTIFICATION BADGE (Frame 1171275288)
  // ==========================================================

  Widget _buildCertBadge({required double scale, required String sport}) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: 16 * scale,
        vertical: 10 * scale,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16 * scale),
        color: const Color(0xFF99FFA3).withOpacity(0.08),
        border: Border.all(
          color: const Color(0xFF84F890).withOpacity(0.40),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          // Green checkmark circle
          Container(
            width: 16 * scale,
            height: 16 * scale,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: const Color(0xFF68EE76),
                width: 1,
              ),
            ),
            child: Center(
              child: Icon(
                Icons.check,
                size: 10 * scale,
                color: const Color(0xFF68EE76),
              ),
            ),
          ),

          SizedBox(width: 6 * scale),

          // "Certified Referee" in green gradient text
          ShaderMask(
            shaderCallback: (bounds) => const LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFF99FFA3), Color(0xFF68EE76)],
            ).createShader(bounds),
            child: Text(
              'Certified Referee',
              style: TextStyle(
                color: Colors.white,
                fontSize: 14 * scale,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),

          SizedBox(width: 6 * scale),

          // Dot separator
          Container(
            width: 2 * scale,
            height: 2 * scale,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Color(0xFFA0A0A0),
            ),
          ),

          SizedBox(width: 6 * scale),

          // Sport label in white
          Text(
            sport,
            style: TextStyle(
              color: Colors.white,
              fontSize: 14 * scale,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================================
  // STATS ROW (Frame 1244830902)
  // ==========================================================

  Widget _buildStatsRow({required double scale, required String matches}) {
    return Row(
      children: [
        _buildStatCard(scale: scale, value: matches, label: 'Matches'),
        SizedBox(width: 16 * scale),
        _buildStatCard(scale: scale, value: '4.9', label: 'Rating'),
        SizedBox(width: 16 * scale),
        _buildStatCard(scale: scale, value: '2', label: 'Disputes'),
      ],
    );
  }

  Widget _buildStatCard({
    required double scale,
    required String value,
    required String label,
  }) {
    return Expanded(
      child: Container(
        height: 65 * scale,
        decoration: BoxDecoration(
          color: const Color(0xFF1B2335),
          borderRadius: BorderRadius.circular(16 * scale),
          border: Border.all(
            color: const Color(0xFF7BD0FA).withOpacity(0.30),
            width: 1,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ShaderMask(
              shaderCallback: (bounds) => const LinearGradient(
                colors: [Color(0xFFED7B00), Color(0xFFCF9E24)],
              ).createShader(bounds),
              child: Text(
                value,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20 * scale,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            SizedBox(height: 2 * scale),
            Text(
              label,
              style: TextStyle(
                color: const Color(0xFFA0A0A0),
                fontSize: 14 * scale,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ==========================================================
  // MENU CARD (shared for all 3 card groups)
  // ==========================================================

  Widget _buildMenuCard({
    required double scale,
    required List<_MenuItem> items,
    required double opacity,
    required Color labelColor,
  }) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: 20 * scale,
        vertical: 20 * scale,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFF1B2335).withOpacity(opacity),
        borderRadius: BorderRadius.circular(16 * scale),
        border: opacity >= 1.0
            ? Border.all(
                color: const Color(0xFF7BD0FA).withOpacity(0.30),
                width: 1,
              )
            : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (int i = 0; i < items.length; i++) ...[
            _buildMenuItem(scale: scale, item: items[i], labelColor: labelColor),
            if (i < items.length - 1) SizedBox(height: 20 * scale),
          ],
        ],
      ),
    );
  }

  Widget _buildMenuItem({
    required double scale,
    required _MenuItem item,
    required Color labelColor,
  }) {
    return Row(
      children: [
        SizedBox(
          width: 24 * scale,
          height: 24 * scale,
          child: Icon(
            item.icon,
            color: labelColor,
            size: 18 * scale,
          ),
        ),
        SizedBox(width: 14 * scale),
        Text(
          item.label,
          style: TextStyle(
            color: labelColor,
            fontSize: 14 * scale,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  // ==========================================================
  // LOGOUT BUTTON (Frame 17, r16, 160×60)
  // ==========================================================

  Widget _buildLogoutButton({required double scale}) {
    return GestureDetector(
      onTap: () => _showLogoutDialog(context),
      child: Container(
        width: 160 * scale,
        height: 60 * scale,
        decoration: BoxDecoration(
          color: const Color(0xFF1B2335).withOpacity(0.6),
          borderRadius: BorderRadius.circular(16 * scale),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logout icon with orange-red gradient
            ShaderMask(
              shaderCallback: (bounds) => const LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFFFF9364), Color(0xFFF25F33)],
              ).createShader(bounds),
              child: Icon(
                Icons.logout_rounded,
                color: Colors.white,
                size: 24 * scale,
              ),
            ),
            SizedBox(width: 10 * scale),
            Text(
              'Logout',
              style: TextStyle(
                color: Colors.white,
                fontSize: 14 * scale,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ==========================================================
  // LOGOUT DIALOG
  // ==========================================================

  void _showLogoutDialog(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1B2335),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          title: const Text(
            'Logout',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
          ),
          content: const Text(
            'Are you sure you want to logout?',
            style: TextStyle(color: Color(0xFFA0A0A0)),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text(
                'Cancel',
                style: TextStyle(color: Color(0xFFA0A0A0)),
              ),
            ),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFFED7B00),
              ),
              onPressed: () {
                Navigator.of(dialogContext).pop();
                context.read<AuthBloc>().add(LogoutRequestedEvent());
              },
              child: const Text('Logout'),
            ),
          ],
        );
      },
    );
  }

  String _initials(String name) {
    final parts = name.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name.isNotEmpty ? name[0].toUpperCase() : '?';
  }
}

// ==========================================================
// DATA CLASS
// ==========================================================

class _MenuItem {
  final IconData icon;
  final String label;
  const _MenuItem({required this.icon, required this.label});
}
