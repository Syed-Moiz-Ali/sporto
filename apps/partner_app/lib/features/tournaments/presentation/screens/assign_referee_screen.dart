import 'package:flutter/material.dart';
import 'package:ui_kit/ui_kit.dart';

class AssignRefereeScreen extends StatelessWidget {
  const AssignRefereeScreen({
    super.key,
    required this.tournamentName,
    required this.tournamentCode,
  });

  final String tournamentName;
  final String tournamentCode;

  static const _referees = <_AvailableReferee>[
    _AvailableReferee('Amit Verma', 3, 'Available'),
    _AvailableReferee('Anu Thakur', 3, 'Available'),
    _AvailableReferee('Kunal Verma', 3, 'Break'),
    _AvailableReferee('Lina Reddy', 3, 'Break'),
  ];

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return MediaQuery.withNoTextScaling(
      child: SportoScreenShell(
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: Padding(
            padding: const EdgeInsets.all(8),
            child: IconButton(
              onPressed: () => Navigator.maybePop(context),
              icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
              style: IconButton.styleFrom(
                backgroundColor: const Color(0xFF292C31),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ),
          title: const Text(
            'Assign Referee',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
        ),
        body: SafeArea(
          top: false,
          child: SportoResponsiveContent(
            padding: EdgeInsets.zero,
            child: ListView(
              physics: const ClampingScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
              children: [
                SportoCard(
                  radius: 15,
                  blur: 0,
                  padding: const EdgeInsets.all(12),
                  backgroundColor: const Color(0xE817191F),
                  borderColor: cs.secondary.withValues(alpha: .16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        tournamentCode,
                        style: TextStyle(
                          color: cs.onSurfaceVariant,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        tournamentName,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Row(
                        children: [
                          _StatusDot(color: Color(0xFFFF334A)),
                          SizedBox(width: 6),
                          Text('Live Matches',
                              style: TextStyle(color: Colors.white)),
                        ],
                      ),
                      const SizedBox(height: 15),
                      Row(
                        children: [
                          Text(
                            'Round of 128',
                            style: TextStyle(
                              color: cs.secondary,
                              fontSize: 12,
                            ),
                          ),
                          const Spacer(),
                          Text(
                            '64 / 127',
                            style: TextStyle(
                              color: cs.secondary,
                              fontSize: 12,
                            ),
                          ),
                          Text(
                            ' Matches Completed',
                            style: TextStyle(
                              color: cs.onSurfaceVariant,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 40),
                SportoTextField(
                  hint: 'Search referees...',
                  prefix: SportoAssetIcon(
                    SportoAssets.searchNormal,
                    size: 20,
                    color: cs.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 23),
                Row(
                  children: [
                    Text(
                      'Sort by |',
                      style: TextStyle(color: cs.onSurfaceVariant),
                    ),
                    const SizedBox(width: 8),
                    Text('Matches',
                        style: TextStyle(color: cs.onSurfaceVariant)),
                    const SizedBox(width: 20),
                    Text('Rating',
                        style: TextStyle(color: cs.onSurfaceVariant)),
                  ],
                ),
                const SizedBox(height: 25),
                Text(
                  'Select a referee',
                  style: TextStyle(color: context.sporto.info, fontSize: 16),
                ),
                const SizedBox(height: 10),
                for (var i = 0; i < _referees.length; i++) ...[
                  _refereeCard(context, _referees[i]),
                  if (i != _referees.length - 1) const SizedBox(height: 10),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _refereeCard(BuildContext context, _AvailableReferee referee) {
    final cs = Theme.of(context).colorScheme;
    final available = referee.status == 'Available';
    final statusColor = available ? cs.secondary : const Color(0xFFFF7545);
    return SportoCard(
      radius: 15,
      blur: 0,
      padding: const EdgeInsets.fromLTRB(14, 13, 14, 12),
      backgroundColor: const Color(0xE817191F),
      borderColor: const Color(0x192F3A48),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  referee.name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  'Level: ${referee.level} referee',
                  style: TextStyle(color: cs.onSurfaceVariant, fontSize: 12),
                ),
                const SizedBox(height: 13),
                Row(
                  children: [
                    _StatusDot(color: statusColor, size: 6),
                    const SizedBox(width: 4),
                    Text(
                      referee.status,
                      style: TextStyle(color: statusColor, fontSize: 12),
                    ),
                  ],
                ),
                Text(
                  'Last Match Finished 1 hr ago',
                  style: TextStyle(color: cs.onSurfaceVariant, fontSize: 12),
                ),
              ],
            ),
          ),
          SportoPillButton(
            label: 'Assign',
            color: available ? cs.primary : const Color(0xFF202532),
            gradient: available
                ? LinearGradient(colors: [cs.primary, cs.tertiary])
                : null,
            filled: true,
            foregroundColor: available
                ? Colors.black
                : cs.onSurfaceVariant.withValues(alpha: .5),
            height: 28,
            padding: const EdgeInsets.symmetric(horizontal: 28),
            fontSize: 12,
            onTap:
                available ? () => Navigator.pop(context, referee.name) : null,
          ),
        ],
      ),
    );
  }
}

class _AvailableReferee {
  const _AvailableReferee(this.name, this.level, this.status);

  final String name;
  final int level;
  final String status;
}

class _StatusDot extends StatelessWidget {
  const _StatusDot({required this.color, this.size = 8});

  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) => DecoratedBox(
        decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        child: SizedBox(width: size, height: size),
      );
}
