import 'package:flutter/material.dart';

import '../theme/sporto_design_tokens.dart';

class SportoProfileStatData {
  final String value;
  final String label;

  const SportoProfileStatData({
    required this.value,
    required this.label,
  });
}

class SportoProfileMenuItemData {
  final String title;
  final IconData icon;
  final VoidCallback? onTap;
  final Color? iconColor;
  final bool showDot;

  const SportoProfileMenuItemData({
    required this.title,
    required this.icon,
    this.onTap,
    this.iconColor,
    this.showDot = true,
  });
}

enum SportoProfileBottomTab {
  home,
  matches,
  scoring,
  profile,
}

class SportoProfileHeaderCard extends StatelessWidget {
  final String name;
  final String phone;
  final ImageProvider? avatarImage;
  final VoidCallback? onTap;

  const SportoProfileHeaderCard({
    super.key,
    required this.name,
    required this.phone,
    this.avatarImage,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final scale = context.sportoScale;
    final theme = Theme.of(context);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(22 * scale),
        onTap: onTap,
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(
            horizontal: 14 * scale,
            vertical: 14 * scale,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(22 * scale),
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFF5A2837),
                Color(0xFF3A2B46),
                Color(0xFF4E491F),
              ],
            ),
            border: Border.all(
              color: const Color(0x33FFFFFF),
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 52 * scale,
                height: 52 * scale,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: const Color(0xFFFF8A2A),
                    width: 2,
                  ),
                ),
                child: Padding(
                  padding: EdgeInsets.all(2 * scale),
                  child: CircleAvatar(
                    backgroundColor: const Color(0xFF232A3B),
                    backgroundImage: avatarImage,
                    child: avatarImage == null
                        ? Text(
                            name.isNotEmpty ? name[0] : 'P',
                            style: theme.textTheme.titleLarge?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                            ),
                          )
                        : null,
                  ),
                ),
              ),
              SizedBox(width: 12 * scale),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontSize: 17 * scale,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                        height: 1.1,
                      ),
                    ),
                    SizedBox(height: 6 * scale),
                    Text(
                      phone,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontSize: 13 * scale,
                        color: const Color(0xB8FFFFFF),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class SportoCertifiedBadge extends StatelessWidget {
  final String title;

  const SportoCertifiedBadge({
    super.key,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    final scale = context.sportoScale;
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: 14 * scale,
        vertical: 11 * scale,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16 * scale),
        gradient: const LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [
            Color(0xFF232322),
            Color(0xFF113322),
            Color(0xFF1A3C23),
          ],
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 18 * scale,
            height: 18 * scale,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: const Color(0xFF7CFF80),
              ),
            ),
            alignment: Alignment.center,
            child: Icon(
              Icons.check,
              size: 12 * scale,
              color: const Color(0xFF7CFF80),
            ),
          ),
          SizedBox(width: 8 * scale),
          Expanded(
            child: Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text: 'Certified Referee',
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: const Color(0xFF8AFF8F),
                      fontWeight: FontWeight.w600,
                      fontSize: 14 * scale,
                    ),
                  ),
                  TextSpan(
                    text: '  ·  $title',
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                      fontSize: 14 * scale,
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
}

class SportoProfileStatsRow extends StatelessWidget {
  final List<SportoProfileStatData> stats;

  const SportoProfileStatsRow({
    super.key,
    required this.stats,
  }) : assert(stats.length == 3, 'Pass exactly 3 stat tiles');

  @override
  Widget build(BuildContext context) {
    final scale = context.sportoScale;

    return Row(
      children: List.generate(
        stats.length,
        (index) {
          return Expanded(
            child: Padding(
              padding: EdgeInsets.only(
                right: index == stats.length - 1 ? 0 : 14 * scale,
              ),
              child: SportoProfileStatCard(
                value: stats[index].value,
                label: stats[index].label,
              ),
            ),
          );
        },
      ),
    );
  }
}

class SportoProfileStatCard extends StatelessWidget {
  final String value;
  final String label;

  const SportoProfileStatCard({
    super.key,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    final scale = context.sportoScale;
    final theme = Theme.of(context);

    return Container(
      height: 66 * scale,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16 * scale),
        color: const Color(0xFF18233A),
        border: Border.all(
          color: const Color(0xFF2D5A92),
          width: 1,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            value,
            style: theme.textTheme.headlineSmall?.copyWith(
              color: const Color(0xFFFFB317),
              fontSize: 18 * scale,
              fontWeight: FontWeight.w700,
              height: 1,
            ),
          ),
          SizedBox(height: 8 * scale),
          Text(
            label,
            style: theme.textTheme.bodyLarge?.copyWith(
              color: const Color(0xFFD0D4DD),
              fontSize: 13 * scale,
              fontWeight: FontWeight.w500,
              height: 1,
            ),
          ),
        ],
      ),
    );
  }
}

class SportoProfileMenuCard extends StatelessWidget {
  final List<SportoProfileMenuItemData> items;

  const SportoProfileMenuCard({
    super.key,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    final scale = context.sportoScale;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: 14 * scale,
        vertical: 10 * scale,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFF18233A),
        borderRadius: BorderRadius.circular(18 * scale),
        border: Border.all(
          color: const Color(0x1FFFFFFF),
        ),
      ),
      child: Column(
        children: List.generate(
          items.length,
          (index) {
            final item = items[index];
            return Padding(
              padding: EdgeInsets.only(
                bottom: index == items.length - 1 ? 0 : 8 * scale,
              ),
              child: SportoProfileMenuItem(
                item: item,
              ),
            );
          },
        ),
      ),
    );
  }
}

class SportoProfileMenuItem extends StatelessWidget {
  final SportoProfileMenuItemData item;

  const SportoProfileMenuItem({
    super.key,
    required this.item,
  });

  @override
  Widget build(BuildContext context) {
    final scale = context.sportoScale;
    final theme = Theme.of(context);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(12 * scale),
        onTap: item.onTap,
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: 4 * scale,
            vertical: 10 * scale,
          ),
          child: Row(
            children: [
              Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    width: 26 * scale,
                    height: 26 * scale,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: const Color(0x11111111),
                      border: Border.all(
                        color: const Color(0x33FFFFFF),
                      ),
                    ),
                    child: Icon(
                      item.icon,
                      size: 16 * scale,
                      color: item.iconColor ?? Colors.white,
                    ),
                  ),
                  if (item.showDot)
                    Positioned(
                      right: -1,
                      top: -1,
                      child: Container(
                        width: 7 * scale,
                        height: 7 * scale,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Color(0xFFFF7E29),
                        ),
                      ),
                    ),
                ],
              ),
              SizedBox(width: 14 * scale),
              Expanded(
                child: Text(
                  item.title,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: Colors.white,
                    fontSize: 15 * scale,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class SportoLogoutButton extends StatelessWidget {
  final VoidCallback? onTap;

  const SportoLogoutButton({
    super.key,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final scale = context.sportoScale;
    final theme = Theme.of(context);

    return SizedBox(
      width: 160 * scale,
      height: 60 * scale,
      child: Material(
        color: const Color(0xFF18233A),
        borderRadius: BorderRadius.circular(18 * scale),
        child: InkWell(
          borderRadius: BorderRadius.circular(18 * scale),
          onTap: onTap,
          child: Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.logout_rounded,
                  size: 18 * scale,
                  color: const Color(0xFFFF8A2A),
                ),
                SizedBox(width: 10 * scale),
                Text(
                  'Logout',
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: Colors.white,
                    fontSize: 15 * scale,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class SportoProfileBottomNav extends StatelessWidget {
  final SportoProfileBottomTab selectedTab;
  final ValueChanged<SportoProfileBottomTab>? onChanged;

  const SportoProfileBottomNav({
    super.key,
    required this.selectedTab,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final scale = context.sportoScale;

    return Container(
      height: 72 * scale,
      padding: EdgeInsets.symmetric(
        horizontal: 8 * scale,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFF1B1B1A).withOpacity(.92),
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(20 * scale),
        ),
        border: const Border(
          top: BorderSide(
            color: Color(0x14FFFFFF),
          ),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: _BottomNavItem(
              label: 'Home',
              icon: Icons.home_outlined,
              selected: selectedTab == SportoProfileBottomTab.home,
              onTap: () => onChanged?.call(SportoProfileBottomTab.home),
            ),
          ),
          Expanded(
            child: _BottomNavItem(
              label: 'Matches',
              icon: Icons.calendar_month_outlined,
              selected: selectedTab == SportoProfileBottomTab.matches,
              onTap: () => onChanged?.call(SportoProfileBottomTab.matches),
            ),
          ),
          Expanded(
            child: _BottomNavItem(
              label: 'Scoring',
              icon: Icons.sports_cricket_outlined,
              selected: selectedTab == SportoProfileBottomTab.scoring,
              onTap: () => onChanged?.call(SportoProfileBottomTab.scoring),
            ),
          ),
          Expanded(
            child: _BottomNavItem(
              label: 'Profile',
              icon: Icons.person_outline,
              selected: selectedTab == SportoProfileBottomTab.profile,
              onTap: () => onChanged?.call(SportoProfileBottomTab.profile),
            ),
          ),
        ],
      ),
    );
  }
}

class _BottomNavItem extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback? onTap;

  const _BottomNavItem({
    required this.label,
    required this.icon,
    required this.selected,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final scale = context.sportoScale;
    final theme = Theme.of(context);

    final color = selected ? const Color(0xFFFFC625) : const Color(0xFFA7A7A7);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14 * scale),
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 8 * scale),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 22 * scale,
                color: color,
              ),
              SizedBox(height: 4 * scale),
              Text(
                label,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: color,
                  fontSize: 12 * scale,
                  fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                ),
              ),
              SizedBox(height: 3 * scale),
              AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                width: selected ? 6 * scale : 0,
                height: selected ? 6 * scale : 0,
                decoration: const BoxDecoration(
                  color: Color(0xFFFFC625),
                  shape: BoxShape.circle,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
