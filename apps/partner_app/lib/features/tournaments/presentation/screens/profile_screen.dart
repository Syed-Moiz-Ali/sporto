import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ui_kit/ui_kit.dart';

import '../../../partner_api/application/partner_api_bloc.dart';
import 'partner_profile_detail_screens.dart';

class PartnerProfileScreen extends StatelessWidget {
  const PartnerProfileScreen({super.key});

  static const _gold = Color(0xFFFFB600);
  static const _green = Color(0xFF20C783);
  static const _surface = Color(0xE6171A20);

  void _open(BuildContext context, Widget screen) {
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => screen));
  }

  void _notice(BuildContext context, String label) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$label will be available soon.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PartnerApiBloc, PartnerApiState>(
      builder: (context, state) {
        final loaded = state is PartnerApiLoadedState ? state : null;
        final info = loaded?.profile.personalInformation;
        final application = loaded?.profile.application;
        final name = loaded?.displayName ?? 'Partner';
        final phone = loaded?.mobileNumber.isNotEmpty == true
            ? loaded!.mobileNumber
            : 'Not provided';
        final email = info?.email?.trim().isNotEmpty == true
            ? info!.email!
            : 'Not provided';
        final partnerId = application?.applicationNumber ?? '—';
        final tournaments = loaded?.tournaments ?? const [];
        final dashboard = loaded?.dashboard;
        final tournamentCount = dashboard?.count('total_tournaments') ?? '—';
        final matchCount = dashboard?.count('total_matches') ?? '—';
        final registrationCount =
            dashboard?.count('total_registrations') ?? '—';
        if (state is PartnerApiErrorState) {
          return Center(
              child: Column(mainAxisSize: MainAxisSize.min, children: [
            Text(state.message),
            TextButton(
                onPressed: () => context
                    .read<PartnerApiBloc>()
                    .add(const LoadPartnerApiBootstrapEvent()),
                child: const Text('Try Again')),
          ]));
        }
        if (loaded == null)
          return const Center(child: CircularProgressIndicator());

        return MediaQuery.withNoTextScaling(
          child: SafeArea(
            bottom: false,
            child: SportoResponsiveContent(
              padding: EdgeInsets.zero,
              child: SingleChildScrollView(
                physics: const ClampingScrollPhysics(),
                padding: EdgeInsets.fromLTRB(
                  20,
                  28,
                  20,
                  context.sportoResponsive.bottomContentPadding(context) + 18,
                ),
                child: Column(
                  children: [
                    _identityCard(
                      context,
                      name: name,
                      partnerId: partnerId,
                      phone: phone,
                      email: email,
                      onTap: () => _open(
                        context,
                        PartnerEditProfileScreen(
                          firstName: info?.firstName ?? '',
                          lastName: info?.lastName ?? '',
                          mobile: loaded.mobileNumber,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Expanded(
                            child: _stat('$tournamentCount', 'Tournaments')),
                        const SizedBox(width: 10),
                        Expanded(child: _stat(matchCount, 'Matches')),
                        const SizedBox(width: 10),
                        Expanded(
                            child: _stat(registrationCount, 'Registrations')),
                      ],
                    ),
                    const SizedBox(height: 12),
                    if (loaded.dashboardError != null)
                      TextButton(
                          onPressed: () => context
                              .read<PartnerApiBloc>()
                              .add(const RefreshPartnerProfileEvent()),
                          child: Text(loaded.dashboardError!)),
                    _earningsCard(
                      value: dashboard?.revenueLabel ?? '—',
                      onTap: () => _notice(context, 'Wallet'),
                    ),
                    const SizedBox(height: 20),
                    const SizedBox(height: 14),
                    _menuGroup([
                      _ProfileAction(
                        'Tournaments History',
                        Icons.notifications_none_rounded,
                        () => _open(
                          context,
                          PartnerTournamentsHistoryScreen(
                            tournaments: tournaments,
                          ),
                        ),
                      ),
                      _ProfileAction(
                        'Statistic',
                        Icons.notifications_none_rounded,
                        () => _notice(context, 'Partner score'),
                      ),
                      _ProfileAction(
                        'Bank Account',
                        Icons.notifications_none_rounded,
                        () => _notice(context, 'Bank account'),
                      ),
                      _ProfileAction(
                        'Settlements & Transactions',
                        Icons.notifications_none_rounded,
                        () => _notice(context, 'Settlements & Transactions'),
                      ),
                      _ProfileAction(
                        'Verification & Documents',
                        Icons.notifications_none_rounded,
                        () => _open(context, Scaffold(
                          appBar: AppBar(title: const Text('Verification & Documents')),
                          body: ListView(children: [
                            if (loaded.application.documents.isEmpty)
                              const ListTile(title: Text('No documents available')),
                            for (final document in loaded.application.documents)
                              ListTile(title: Text(document.documentType.replaceAll('_', ' ')),
                                subtitle: Text(document.rejectionReason ?? document.documentPath)),
                          ]),
                        )),
                      ),
                    ]),
                    const SizedBox(height: 14),
                    _menuGroup([
                      _ProfileAction(
                          'Ratings & Reviews',
                          Icons.notifications_none_rounded,
                          () => _notice(context, 'Ratings & Reviews')),
                      _ProfileAction(
                          'Notifications',
                          Icons.notifications_none_rounded,
                          () => _notice(context, 'Notifications')),
                      _ProfileAction(
                        'Account Settings',
                        Icons.notifications_none_rounded,
                        () => _open(
                          context,
                          PartnerAccountSettingsScreen(
                            firstName: info?.firstName ?? '',
                            lastName: info?.lastName ?? '',
                            mobile: loaded.mobileNumber,
                          ),
                        ),
                      ),
                    ]),
                    const SizedBox(height: 14),
                    _menuGroup([
                      _ProfileAction('About Us', Icons.info_outline,
                          () => _notice(context, 'About Us'),
                          muted: true),
                      _ProfileAction('Terms & Condition', Icons.gavel_outlined,
                          () => _notice(context, 'Terms & Condition'),
                          muted: true),
                      _ProfileAction(
                          'Privacy Policy',
                          Icons.privacy_tip_outlined,
                          () => _notice(context, 'Privacy Policy'),
                          muted: true),
                      _ProfileAction('Customer Service', Icons.support_agent,
                          () => _notice(context, 'Customer Service'),
                          muted: true),
                    ]),
                    const SizedBox(height: 18),
                    Row(
                      children: [
                        Expanded(
                          child: _bottomAction(
                            Icons.support_agent_outlined,
                            'Support Center',
                            () => _notice(context, 'Support Center'),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _bottomAction(
                            Icons.logout_rounded,
                            'Logout',
                            () => context
                                .read<AuthBloc>()
                                .add(LogoutRequestedEvent()),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _identityCard(
    BuildContext context, {
    required String name,
    required String partnerId,
    required String phone,
    required String email,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0x775A4A61)),
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0x885F2549), Color(0x88374657), Color(0x665B4D19)],
          ),
        ),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  width: 62,
                  height: 62,
                  padding: const EdgeInsets.all(2),
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    gradient:
                        LinearGradient(colors: [_gold, Color(0xFFFF6B31)]),
                  ),
                  child: ClipOval(
                    child: const ColoredBox(
                      color: Color(0xFF22252D),
                      child: Icon(Icons.person_rounded,
                          color: Color(0xFFA6A1A8), size: 34),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w700)),
                      const SizedBox(height: 4),
                      Text(partnerId,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                              color: Color(0xFFA6A1A8), fontSize: 11)),
                      const SizedBox(height: 7),
                      const SportoBadge(
                        text: 'Partner',
                        color: _green,
                        outlined: true,
                        icon: Icons.check_circle_outline_rounded,
                        radius: 10,
                        fontSize: 10,
                        padding:
                            EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(Icons.star_rounded, color: _gold, size: 15),
                const SizedBox(width: 3),
                const Text('—',
                    style: TextStyle(color: Colors.white, fontSize: 11)),
                const Spacer(),
                Flexible(
                    child: Text(phone,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                            color: Color(0xFFAAA4AA), fontSize: 10))),
                const Spacer(),
                Flexible(
                    child: Text(email,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                            color: Color(0xFFAAA4AA), fontSize: 10))),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _stat(String value, String label) => SizedBox(
        height: 61,
        child: SportoCard(
          radius: 14,
          padding: EdgeInsets.zero,
          backgroundColor: _surface,
          borderColor: const Color(0x443E506D),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(value,
                  style: const TextStyle(
                      color: Color(0xFFFF9100),
                      fontSize: 19,
                      fontWeight: FontWeight.w800)),
              const SizedBox(height: 2),
              Text(label,
                  style:
                      const TextStyle(color: Color(0xFFA9A4AB), fontSize: 12)),
            ],
          ),
        ),
      );

  Widget _earningsCard({required VoidCallback onTap, required String value}) =>
      SizedBox(
        height: 42,
        child: SportoCard(
          onTap: onTap,
          radius: 14,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          backgroundColor: _surface,
          borderColor: const Color(0x222C405A),
          child: Row(
            children: [
              const Text('Registration Revenue',
                  style: TextStyle(color: Color(0xFFAAA5AC), fontSize: 15)),
              Spacer(),
              Text(value,
                  style: TextStyle(
                      color: _green,
                      fontSize: 18,
                      fontWeight: FontWeight.w800)),
            ],
          ),
        ),
      );

  Widget _menuGroup(List<_ProfileAction> actions) => SportoCard(
        padding: const EdgeInsets.symmetric(vertical: 7),
        radius: 20,
        backgroundColor: const Color(0xA8121211),
        borderColor: Colors.transparent,
        child: Column(
          children: actions
              .map((action) => InkWell(
                    onTap: action.onTap,
                    child: SizedBox(
                      height: 43,
                      child: Row(
                        children: [
                          const SizedBox(width: 16),
                          Stack(
                            clipBehavior: Clip.none,
                            children: [
                              Icon(
                                action.icon,
                                color: action.muted
                                    ? const Color(0xFFA19CA2)
                                    : Colors.white,
                                size: 19,
                              ),
                              if (!action.muted)
                                const Positioned(
                                  right: -1,
                                  top: -1,
                                  child: DecoratedBox(
                                    decoration: BoxDecoration(
                                      color: Color(0xFFFF6B31),
                                      shape: BoxShape.circle,
                                    ),
                                    child: SizedBox(width: 5, height: 5),
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(width: 15),
                          Expanded(
                            child: Text(action.label,
                                style: TextStyle(
                                  color: action.muted
                                      ? const Color(0xFFA19CA2)
                                      : Colors.white,
                                  fontSize: 13,
                                )),
                          ),
                          const Icon(Icons.chevron_right_rounded,
                              color: Color(0xFFFF7E24), size: 16),
                          const SizedBox(width: 14),
                        ],
                      ),
                    ),
                  ))
              .toList(),
        ),
      );

  Widget _bottomAction(
    IconData icon,
    String label,
    VoidCallback onTap,
  ) =>
      SecondaryButton(
        label: label,
        onPressed: onTap,
        icon: icon,
        height: 56,
        radius: 18,
        fontSize: 13,
        iconSize: 18,
      );
}

class _ProfileAction {
  const _ProfileAction(this.label, this.icon, this.onTap, {this.muted = false});
  final String label;
  final IconData icon;
  final VoidCallback onTap;
  final bool muted;
}
