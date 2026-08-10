import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:ui_kit/ui_kit.dart';

import '../../../../app/router/app_router.dart';

/// Profile tab content. The Partner shell owns the background and bottom nav.
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final scale = context.sportoScale;

    return SingleChildScrollView(
      physics: const ClampingScrollPhysics(),
      padding: EdgeInsets.fromLTRB(
        20 * scale,
        26 * scale,
        20 * scale,
        84 * scale,
      ),
      child: Column(
        children: [
          SportoGradientCard(
            radius: 20 * scale,
            padding: EdgeInsets.all(14 * scale),
            colors: const [Color(0xFF7A315D), Color(0xFF343B38)],
            child: Row(
              children: [
                Container(
                  width: 48 * scale,
                  height: 48 * scale,
                  padding: EdgeInsets.all(2 * scale),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: cs.tertiary, width: 1.5),
                  ),
                  child: CircleAvatar(
                    foregroundImage:
                        const NetworkImage('https://i.pravatar.cc/150?img=5'),
                    onForegroundImageError: (_, __) {},
                    backgroundColor: cs.surfaceContainerHigh,
                    child: Icon(Icons.person_rounded,
                        color: cs.onSurfaceVariant, size: 28 * scale),
                  ),
                ),
                SizedBox(width: 14 * scale),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Priya Agrawal',
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontSize: 16 * scale,
                            fontWeight: FontWeight.w700,
                            color: cs.onSurface,
                          )),
                      SizedBox(height: 3 * scale),
                      Text('+91 98765XXXXX',
                          style: theme.textTheme.bodySmall?.copyWith(
                            fontSize: 11 * scale,
                            color: cs.onSurfaceVariant,
                          )),
                    ],
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 20 * scale),
          SportoCard(
            radius: 18 * scale,
            padding: EdgeInsets.symmetric(
                horizontal: 15 * scale, vertical: 10 * scale),
            backgroundColor: cs.secondary.withValues(alpha: .10),
            borderColor: cs.secondary.withValues(alpha: .20),
            child: Row(
              children: [
                Icon(Icons.check_circle_outline_rounded,
                    color: cs.secondary, size: 18 * scale),
                SizedBox(width: 6 * scale),
                Text('Certified Referee',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: cs.secondary,
                      fontSize: 13 * scale,
                      fontWeight: FontWeight.w600,
                    )),
                Text('  •  Cricket',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: cs.onSurface,
                      fontSize: 13 * scale,
                    )),
              ],
            ),
          ),
          SizedBox(height: 20 * scale),
          Row(
            children: [
              _ProfileStat(value: '48', label: 'Matches', scale: scale),
              SizedBox(width: 15 * scale),
              _ProfileStat(value: '4.9', label: 'Rating', scale: scale),
              SizedBox(width: 15 * scale),
              _ProfileStat(value: '2', label: 'Disputes', scale: scale),
            ],
          ),
          SizedBox(height: 20 * scale),
          _MenuSection(
            emphasized: true,
            items: [
              _MenuItem(
                  icon: Icons.notifications_none_rounded, label: 'Statistic'),
              _MenuItem(
                icon: Icons.notifications_none_rounded,
                label: 'My Tournaments',
                onTap: () => context.push(AppRouter.matchHistoryRoute),
              ),
            ],
          ),
          SizedBox(height: 20 * scale),
          _MenuSection(
            emphasized: true,
            items: const [
              _MenuItem(
                  icon: Icons.notifications_none_rounded,
                  label: 'Add Customer Support'),
            ],
          ),
          SizedBox(height: 20 * scale),
          const _MenuSection(
            items: [
              _MenuItem(icon: Icons.error_outline_rounded, label: 'About Us'),
              _MenuItem(
                  icon: Icons.error_outline_rounded,
                  label: 'Terms & Condition'),
              _MenuItem(
                  icon: Icons.error_outline_rounded, label: 'Privacy Policy'),
              _MenuItem(
                  icon: Icons.support_agent_outlined,
                  label: 'Customer Service'),
            ],
          ),
          SizedBox(height: 20 * scale),
          SecondaryButton(
            label: 'Logout',
            icon: Icons.logout_rounded,
            width: 160 * scale,
            height: 59 * scale,
            radius: 16 * scale,
            onPressed: () =>
                context.read<AuthBloc>().add(LogoutRequestedEvent()),
          ),
        ],
      ),
    );
  }
}

class _ProfileStat extends StatelessWidget {
  final String value;
  final String label;
  final double scale;

  const _ProfileStat({
    required this.value,
    required this.label,
    required this.scale,
  });

  @override
  Widget build(BuildContext context) => Expanded(
        child: SizedBox(
          height: 66 * scale,
          child: SportoStatCard(
            value: value,
            label: label,
            highlight: true,
            highlightColor: Theme.of(context).colorScheme.tertiary,
            fontSize: 18 * scale,
            labelSize: 12 * scale,
            backgroundColor: const Color(0xFF19243A),
            borderColor:
                Theme.of(context).colorScheme.onTertiary.withValues(alpha: .28),
            radius: 16 * scale,
            padding: EdgeInsets.symmetric(vertical: 6 * scale),
          ),
        ),
      );
}

class _MenuSection extends StatelessWidget {
  final List<_MenuItem> items;
  final bool emphasized;

  const _MenuSection({required this.items, this.emphasized = false});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final scale = context.sportoScale;
    return Material(
      color: Colors.transparent,
      child: SportoCard(
        radius: 16 * scale,
        padding: EdgeInsets.symmetric(vertical: 5 * scale),
        backgroundColor:
            emphasized ? const Color(0xFF19243A) : cs.surfaceContainerHigh,
        borderColor: emphasized
            ? cs.onTertiary.withValues(alpha: .26)
            : Colors.transparent,
        child: Column(
          children: items
              .map((item) => SizedBox(
                    height: 44 * scale,
                    child: ListTile(
                      dense: true,
                      minLeadingWidth: 22 * scale,
                      horizontalTitleGap: 12 * scale,
                      contentPadding:
                          EdgeInsets.symmetric(horizontal: 20 * scale),
                      leading: Stack(
                        clipBehavior: Clip.none,
                        children: [
                          Icon(item.icon,
                              color: emphasized
                                  ? cs.onSurface
                                  : cs.onSurfaceVariant,
                              size: 20 * scale),
                          if (emphasized)
                            Positioned(
                              right: -1,
                              top: 0,
                              child: Container(
                                width: 5 * scale,
                                height: 5 * scale,
                                decoration: BoxDecoration(
                                    color: cs.primary, shape: BoxShape.circle),
                              ),
                            ),
                        ],
                      ),
                      title: Text(item.label,
                          style:
                              Theme.of(context).textTheme.bodyLarge?.copyWith(
                                    fontSize: 14 * scale,
                                    color: emphasized
                                        ? cs.onSurface
                                        : cs.onSurfaceVariant,
                                  )),
                      onTap: item.onTap,
                    ),
                  ))
              .toList(),
        ),
      ),
    );
  }
}

class _MenuItem {
  final IconData icon;
  final String label;
  final VoidCallback? onTap;

  const _MenuItem({required this.icon, required this.label, this.onTap});
}
