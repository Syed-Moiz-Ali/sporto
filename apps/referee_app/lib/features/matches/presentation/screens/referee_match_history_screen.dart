import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:ui_kit/ui_kit.dart';

class RefereeMatchHistoryScreen extends StatefulWidget {
  final int initialTab;
  const RefereeMatchHistoryScreen({super.key, this.initialTab = 0});

  @override
  State<RefereeMatchHistoryScreen> createState() =>
      _RefereeMatchHistoryScreenState();
}

class _RefereeMatchHistoryScreenState extends State<RefereeMatchHistoryScreen> {
  late int selected = widget.initialTab;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    return Scaffold(
      backgroundColor: context.sporto.canvas,
      body: Stack(children: [
        const SportoAmbientBackground(),
        SafeArea(
            child: Column(children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 23),
            child: Row(children: [
              Material(
                  color: const Color(0xFF252C3B),
                  borderRadius: BorderRadius.circular(10),
                  child: InkWell(
                      onTap: () => context.pop(),
                      borderRadius: BorderRadius.circular(10),
                      child: const SizedBox(
                          width: 36,
                          height: 36,
                          child: Icon(Icons.arrow_back_ios_new_rounded,
                              size: 18)))),
              const SizedBox(width: 11),
              Text('Match History',
                  style: theme.textTheme.titleLarge
                      ?.copyWith(fontSize: 18, fontWeight: FontWeight.w700)),
            ]),
          ),
          Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                height: 42,
                padding: const EdgeInsets.all(5),
                decoration: BoxDecoration(
                    gradient: const LinearGradient(
                        colors: [Color(0xFF23202C), Color(0xFF1C2427)]),
                    borderRadius: BorderRadius.circular(15)),
                child: Row(
                    children: List.generate(3, (index) {
                  final active = selected == index;
                  return Expanded(
                      child: GestureDetector(
                    onTap: () => setState(() => selected = index),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 160),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                          gradient: active
                              ? const LinearGradient(colors: [
                                  Color(0xFFFF8500),
                                  Color(0xFFD9A81B)
                                ])
                              : null,
                          borderRadius: BorderRadius.circular(10)),
                      child: Text(
                          const [
                            'This Week',
                            'This Month',
                            'All Matches'
                          ][index],
                          style: theme.textTheme.bodyMedium?.copyWith(
                              color:
                                  active ? Colors.white : cs.onSurfaceVariant,
                              fontWeight:
                                  active ? FontWeight.w700 : FontWeight.w500)),
                    ),
                  ));
                })),
              )),
          if (selected == 2) ...[
            const SizedBox(height: 16),
            Container(
                height: 40,
                color: const Color(0xFF1D2941),
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(children: [
                  Text('Sort By: ',
                      style: theme.textTheme.bodyMedium
                          ?.copyWith(color: cs.onSurfaceVariant)),
                  const Text('Popularity',
                      style: TextStyle(color: Color(0xFF58C6F5), fontSize: 14)),
                  const Spacer(),
                  Icon(Icons.filter_list_rounded,
                      size: 20, color: cs.onSurfaceVariant),
                  const SizedBox(width: 7),
                  Text('Filter',
                      style: theme.textTheme.bodyMedium
                          ?.copyWith(color: cs.onSurfaceVariant)),
                ])),
          ],
          Expanded(
              child: ListView.separated(
            padding: EdgeInsets.fromLTRB(20, selected == 2 ? 16 : 21, 20, 30),
            itemCount: 2,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (_, __) => const _HistoryResultCard(),
          )),
        ])),
      ]),
    );
  }
}

class _HistoryResultCard extends StatelessWidget {
  const _HistoryResultCard();
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    return Container(
      padding: const EdgeInsets.fromLTRB(10, 12, 10, 11),
      decoration: BoxDecoration(
          gradient: const LinearGradient(
              colors: [Color(0xFF251C20), Color(0xFF1B292F)]),
          borderRadius: BorderRadius.circular(15)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Text('Jaipur Super Over',
              style: TextStyle(
                  color: cs.tertiary,
                  fontSize: 15,
                  fontWeight: FontWeight.w600)),
          const Spacer(),
          Text('Yesterday, 06:30 PM',
              style: theme.textTheme.bodySmall?.copyWith(fontSize: 12)),
        ]),
        const SizedBox(height: 2),
        Row(children: [
          Icon(Icons.location_on_outlined,
              size: 14, color: cs.onSurfaceVariant),
          const SizedBox(width: 2),
          Text('Hyderabad', style: theme.textTheme.bodySmall)
        ]),
        const SizedBox(height: 9),
        Divider(height: 1, color: cs.onSurfaceVariant.withValues(alpha: .22)),
        const SizedBox(height: 8),
        Row(children: [
          const Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                Text('Delhi Warriors', style: TextStyle(fontSize: 12)),
                Text('90/2',
                    style: TextStyle(
                        color: Color(0xFF42F58D),
                        fontSize: 14,
                        fontWeight: FontWeight.w700))
              ])),
          Text('Vs', style: theme.textTheme.bodySmall),
          const Expanded(
              child:
                  Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
            Text('Hyd Highlanders', style: TextStyle(fontSize: 12)),
            Text('85/3',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700))
          ])),
        ]),
        const SizedBox(height: 8),
        Divider(height: 1, color: cs.onSurfaceVariant.withValues(alpha: .22)),
        const SizedBox(height: 8),
        const Center(
            child: Row(mainAxisSize: MainAxisSize.min, children: [
          CircleAvatar(radius: 4, backgroundColor: Color(0xFF55F58E)),
          SizedBox(width: 4),
          Text('Delhi Warriors Won',
              style: TextStyle(
                  color: Color(0xFF55F58E),
                  fontSize: 14,
                  fontWeight: FontWeight.w600)),
        ])),
      ]),
    );
  }
}
