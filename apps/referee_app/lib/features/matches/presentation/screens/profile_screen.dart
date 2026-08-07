import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:core/core.dart';
import 'package:ui_kit/ui_kit.dart';
import '../../../../app/router/app_router.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: cs.onSurface),
          onPressed: () => context.pop(),
        ),
        title: Text('Profile',
            style: GoogleFonts.spaceGrotesk(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: cs.onSurface)),
      ),
      body: Stack(
        children: [
          const SportoAmbientBackground(),
          SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
            child: Column(
              children: [
                // --- Profile Header Card ---
                SportoGradientCard(
                  radius: 24,
                  colors: const [Color(0xFF4A3B5C), Color(0xFF2A4B40)],
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 32,
                        backgroundImage: NetworkImage(
                            'https://i.pravatar.cc/150?img=5'), // Placeholder avatar
                      ),
                      const SizedBox(width: 16),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Priya Agrawal',
                              style: GoogleFonts.spaceGrotesk(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white)),
                          const SizedBox(height: 4),
                          Text('+91 98765XXXXX',
                              style: TextStyle(
                                  color: Colors.white.withOpacity(0.7),
                                  fontSize: 13)),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // --- Certification Badge ---
                SportoCard(
                  radius: 16,
                  padding:
                      const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                  backgroundColor: cs.secondary.withOpacity(0.1),
                  borderColor: cs.secondary.withOpacity(0.3),
                  child: Row(
                    children: [
                      Icon(Icons.verified_rounded,
                          color: cs.secondary, size: 20),
                      const SizedBox(width: 8),
                      RichText(
                          text: TextSpan(
                              style: TextStyle(
                                  fontSize: 14, fontWeight: FontWeight.w600),
                              children: [
                            TextSpan(
                                text: 'Certified Referee ',
                                style: TextStyle(color: cs.secondary)),
                            TextSpan(
                                text: '• Cricket',
                                style: TextStyle(color: cs.onSurface)),
                          ])),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // --- Stats Row ---
                Row(
                  children: [
                    SportoStatCard(
                      label: 'Matches',
                      value: '48',
                      highlight: true,
                      highlightColor: cs.tertiary,
                      fontSize: 22,
                      labelSize: 12,
                    ),
                    const SizedBox(width: 12),
                    SportoStatCard(
                      label: 'Rating',
                      value: '4.9',
                      highlight: true,
                      highlightColor: cs.tertiary,
                      fontSize: 22,
                      labelSize: 12,
                    ),
                    const SizedBox(width: 12),
                    SportoStatCard(
                      label: 'Disputes',
                      value: '2',
                      highlight: true,
                      highlightColor: cs.tertiary,
                      fontSize: 22,
                      labelSize: 12,
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // --- Menu Sections ---
                _MenuSection(items: [
                  _MenuItem(
                      icon: Icons.bar_chart_outlined,
                      label: 'Statistic',
                      onTap: () {}),
                  _MenuItem(
                      icon: Icons.emoji_events_outlined,
                      label: 'My Tournaments',
                      onTap: () => context.push(AppRouter.matchesRoute)),
                ]),
                const SizedBox(height: 16),

                _MenuSection(items: [
                  _MenuItem(
                      icon: Icons.headset_mic_outlined,
                      label: 'Add Customer Support',
                      onTap: () {}),
                ]),
                const SizedBox(height: 16),

                _MenuSection(items: [
                  _MenuItem(
                      icon: Icons.info_outline,
                      label: 'About Us',
                      isMuted: true),
                  _MenuItem(
                      icon: Icons.description_outlined,
                      label: 'Terms & Condition',
                      isMuted: true),
                  _MenuItem(
                      icon: Icons.policy_outlined,
                      label: 'Privacy Policy',
                      isMuted: true),
                  _MenuItem(
                      icon: Icons.support_agent_outlined,
                      label: 'Customer Service',
                      isMuted: true),
                ]),
                const SizedBox(height: 32),

                // --- Logout Button ---
                SecondaryButton(
                  label: 'Logout',
                  icon: Icons.logout_rounded,
                  onPressed: () {
                    context.read<AuthBloc>().add(LogoutRequestedEvent());
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MenuSection extends StatelessWidget {
  final List<_MenuItem> items;
  const _MenuSection({required this.items});

  @override
  Widget build(BuildContext context) {
    return SportoCard(
      radius: 20,
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Column(
        children: items.asMap().entries.map((entry) {
          final item = entry.value;
          final isLast = entry.key == items.length - 1;
          return Column(
            children: [
              ListTile(
                leading: Icon(item.icon,
                    color: item.isMuted
                        ? Colors.grey[600]
                        : Theme.of(context).colorScheme.onSurface,
                    size: 22),
                title: Text(item.label,
                    style: TextStyle(
                        color: item.isMuted
                            ? Colors.grey[500]
                            : Theme.of(context).colorScheme.onSurface,
                        fontSize: 15,
                        fontWeight: FontWeight.w500)),
                trailing: Icon(Icons.chevron_right_rounded,
                    color: Colors.grey[700], size: 20),
                onTap: item.onTap,
              ),
              if (!isLast)
                Padding(
                    padding: const EdgeInsets.only(left: 56),
                    child: Divider(height: 1, color: Colors.grey[800])),
            ],
          );
        }).toList(),
      ),
    );
  }
}

class _MenuItem {
  final IconData icon;
  final String label;
  final bool isMuted;
  final VoidCallback? onTap;
  const _MenuItem(
      {required this.icon,
      required this.label,
      this.isMuted = false,
      this.onTap});
}
