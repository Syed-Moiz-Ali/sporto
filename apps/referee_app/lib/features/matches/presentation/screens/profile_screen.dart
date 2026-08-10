import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:core/core.dart';
import 'package:ui_kit/ui_kit.dart';
import '../../../../app/router/app_router.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return SingleChildScrollView(
      physics: const ClampingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(20, 26, 20, 84),
      child: Column(
        children: [
          // --- Profile Header Card ---
          SportoGradientCard(
            radius: 20,
            padding: const EdgeInsets.all(14),
            colors: const [Color(0xFF7A315D), Color(0xFF343B38)],
            child: Row(
              children: [
                CircleAvatar(
                  radius: 24,
                  foregroundImage:
                      const NetworkImage('https://i.pravatar.cc/150?img=5'),
                  onForegroundImageError: (_, __) {},
                  child: const Icon(Icons.person_rounded),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Priya Agrawal',
                          style: Theme.of(context)
                              .textTheme
                              .titleLarge
                              ?.copyWith(fontSize: 16, color: Colors.white)),
                      const SizedBox(height: 4),
                      Text('+91 98765XXXXX',
                          style: TextStyle(
                              color: Colors.white.withOpacity(0.7),
                              fontSize: 13)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // --- Certification Badge ---
          SportoCard(
            radius: 16,
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            backgroundColor: cs.secondary.withOpacity(0.1),
            borderColor: cs.secondary.withOpacity(0.3),
            child: Row(
              children: [
                Icon(Icons.verified_rounded, color: cs.secondary, size: 20),
                const SizedBox(width: 8),
                Expanded(
                    child: RichText(
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
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
                            ]))),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // --- Stats Row ---
          SizedBox(
            height: 66,
            child: Row(
              children: [
                Expanded(
                    child: SportoStatCard(
                  label: 'Matches',
                  value: '48',
                  highlight: true,
                  highlightColor: cs.tertiary,
                  fontSize: 18,
                  labelSize: 12,
                )),
                const SizedBox(width: 12),
                Expanded(
                    child: SportoStatCard(
                  label: 'Rating',
                  value: '4.9',
                  highlight: true,
                  highlightColor: cs.tertiary,
                  fontSize: 18,
                  labelSize: 12,
                )),
                const SizedBox(width: 12),
                Expanded(
                    child: SportoStatCard(
                  label: 'Disputes',
                  value: '2',
                  highlight: true,
                  highlightColor: cs.tertiary,
                  fontSize: 18,
                  labelSize: 12,
                )),
              ],
            ),
          ),
          const SizedBox(height: 20),

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
          const SizedBox(height: 20),

          _MenuSection(items: [
            _MenuItem(
                icon: Icons.headset_mic_outlined,
                label: 'Add Customer Support',
                onTap: () {}),
          ]),
          const SizedBox(height: 20),

          _MenuSection(items: [
            _MenuItem(
                icon: Icons.info_outline, label: 'About Us', isMuted: true),
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
          const SizedBox(height: 20),

          // --- Logout Button ---
          SecondaryButton(
            label: 'Logout',
            icon: Icons.logout_rounded,
            width: 160,
            height: 59,
            onPressed: () {
              context.read<AuthBloc>().add(LogoutRequestedEvent());
            },
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
    final cs = Theme.of(context).colorScheme;
    final emphasized = items.any((item) => !item.isMuted);
    return Material(
      color: Colors.transparent,
      child: SportoCard(
        radius: 16,
        padding: const EdgeInsets.symmetric(vertical: 5),
        backgroundColor:
            emphasized ? const Color(0xFF19243A) : cs.surfaceContainerHigh,
        borderColor: emphasized
            ? cs.onTertiary.withValues(alpha: .26)
            : Colors.transparent,
        child: Column(
          children: items.asMap().entries.map((entry) {
            final item = entry.value;
            return SizedBox(
                height: 44,
                child: ListTile(
                  dense: true,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 20),
                  minLeadingWidth: 22,
                  horizontalTitleGap: 12,
                  leading: Icon(item.icon,
                      color: item.isMuted
                          ? Colors.grey[600]
                          : Theme.of(context).colorScheme.onSurface,
                      size: 20),
                  title: Text(item.label,
                      style: TextStyle(
                          color: item.isMuted
                              ? Colors.grey[500]
                              : Theme.of(context).colorScheme.onSurface,
                          fontSize: 14,
                          fontWeight: FontWeight.w600)),
                  onTap: item.onTap,
                ));
          }).toList(),
        ),
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
