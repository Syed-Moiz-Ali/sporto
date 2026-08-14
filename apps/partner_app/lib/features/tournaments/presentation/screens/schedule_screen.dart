import 'package:flutter/material.dart';
import 'package:ui_kit/ui_kit.dart';

class ScheduleScreen extends StatelessWidget {
  final bool embedded;

  const ScheduleScreen({
    super.key,
    this.embedded = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final scale = context.sportoScale;
    final content = SafeArea(
      bottom: false,
      child: SportoResponsiveContent(
        padding: EdgeInsets.zero,
        child: ListView(
          padding: EdgeInsets.fromLTRB(
            context.sportoResponsive.horizontalPadding,
            10 * scale,
            context.sportoResponsive.horizontalPadding,
            context.sportoResponsive.bottomContentPadding(context),
          ),
          children: [
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text("Shrvn’s Sporto",
                    style: theme.textTheme.titleLarge?.copyWith(fontSize: 18)),
                Text('Good Morning',
                    style: theme.textTheme.bodyMedium
                        ?.copyWith(color: cs.tertiary)),
              ]),
              Icon(Icons.light_mode_outlined, color: cs.onSurface),
            ]),
            const SizedBox(height: 22),
            Text("Today’s Scheduled",
                style: theme.textTheme.bodyLarge
                    ?.copyWith(color: cs.onSurfaceVariant)),
            const SizedBox(height: 12),
            Row(children: [
              Expanded(child: _stat(context, '18', 'Matches')),
              const SizedBox(width: 12),
              Expanded(child: _stat(context, '5', 'Live')),
              const SizedBox(width: 12),
              Expanded(child: _stat(context, '13', 'Upcoming')),
            ]),
            const SizedBox(height: 20),
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              _arrow(context, Icons.chevron_left),
              Expanded(
                  child: Text('August 08, Today',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.titleLarge
                          ?.copyWith(color: cs.onSurfaceVariant))),
              _arrow(context, Icons.chevron_right),
            ]),
            const SizedBox(height: 12),
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              for (final day in const [
                ('Mon', '05'),
                ('Tue', '06'),
                ('Wed', '07'),
                ('Thu', '08'),
                ('Fri', '09'),
                ('Sat', '10'),
                ('Sun', '11')
              ])
                Expanded(child: _day(context, day.$1, day.$2, day.$1 == 'Thu')),
            ]),
            const SizedBox(height: 28),
            SportoTextField(
              hint: 'Search matches...',
              prefix: Icon(Icons.search, color: cs.onSurfaceVariant),
              suffixIcon: Icon(Icons.sort, color: cs.onSurfaceVariant),
            ),
            const SizedBox(height: 24),
            SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(children: [
                  for (final x in const [
                    'All',
                    'Live',
                    'Upcoming',
                    'Completed'
                  ])
                    Padding(
                        padding: const EdgeInsets.only(right: 24),
                        child: Text(x,
                            style: theme.textTheme.bodyMedium?.copyWith(
                                color: x == 'All'
                                    ? cs.tertiary
                                    : cs.onSurfaceVariant))),
                ])),
            const SizedBox(height: 24),
            Text("Today’s Matches",
                style: theme.textTheme.bodyLarge
                    ?.copyWith(color: cs.onSurfaceVariant)),
            const SizedBox(height: 12),
            _match(context, live: true, time: '10:30 AM', ground: 'Ground A'),
            const SizedBox(height: 20),
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Text('Upcoming',
                  style: theme.textTheme.bodyLarge
                      ?.copyWith(color: cs.onSurfaceVariant)),
              Text('View All  ›',
                  style: theme.textTheme.bodySmall
                      ?.copyWith(color: context.sporto.info)),
            ]),
            const SizedBox(height: 12),
            _match(context, time: '10:30 AM', ground: 'Ground B'),
            const SizedBox(height: 12),
            _match(context,
                time: '12:30 PM', ground: 'Ground B', compact: true),
          ],
        ),
      ),
    );
    return embedded ? content : SportoScreenShell(body: content);
  }

  Widget _stat(BuildContext c, String value, String label) => SportoCard(
      padding: const EdgeInsets.all(12),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(value, style: Theme.of(c).textTheme.titleLarge),
        Text(label, style: Theme.of(c).textTheme.bodySmall),
      ]));
  Widget _arrow(BuildContext c, IconData icon) => Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
          color: c.sporto.field, borderRadius: BorderRadius.circular(10)),
      child: Icon(icon, color: c.sporto.info));
  Widget _day(BuildContext c, String day, String date, bool active) =>
      Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
              color: active
                  ? Theme.of(c).colorScheme.tertiary
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(10)),
          child: Column(children: [
            Text(day,
                style: Theme.of(c)
                    .textTheme
                    .bodySmall
                    ?.copyWith(color: active ? Colors.black : null)),
            Text(date,
                style: Theme.of(c)
                    .textTheme
                    .bodyMedium
                    ?.copyWith(color: active ? Colors.black : null))
          ]));
  Widget _match(BuildContext c,
      {required String time,
      required String ground,
      bool live = false,
      bool compact = false}) {
    final cs = Theme.of(c).colorScheme;
    return SportoCard(
        padding: const EdgeInsets.all(12),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Expanded(
                child: Text(live ? '● Live Now' : time,
                    maxLines: 1,
                    style: TextStyle(
                        color: live ? c.sporto.live : c.sporto.info,
                        fontSize: 12))),
            SportoBadge(text: 'Quarter Final', color: cs.secondary)
          ]),
          const SizedBox(height: 10),
          Text('Hyderabad Super Cup', style: Theme.of(c).textTheme.bodyLarge),
          Text('Cricket  •  $ground',
              style: Theme.of(c)
                  .textTheme
                  .bodySmall
                  ?.copyWith(color: cs.tertiary)),
          const SizedBox(height: 14),
          Row(children: [
            Expanded(
                child: Text('Delhi Warriors',
                    style: Theme.of(c).textTheme.bodySmall)),
            Text('Vs', style: Theme.of(c).textTheme.bodySmall),
            Expanded(
                child: Text('Hyd Highlanders',
                    textAlign: TextAlign.end,
                    style: Theme.of(c).textTheme.bodySmall))
          ]),
          if (!compact) ...[
            const SizedBox(height: 14),
            Align(
                alignment: Alignment.centerRight,
                child: SportoPillButton(
                    label: live ? 'Open Live Match' : 'View Details',
                    color: live ? c.sporto.live : c.sporto.info,
                    filled: live,
                    onTap: () {}))
          ],
        ]));
  }
}
