import 'package:flutter/material.dart';
import 'package:ui_kit/ui_kit.dart';

class TeamDetailsScreen extends StatelessWidget {
  const TeamDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final scale = context.sportoScale;
    return SportoScreenShell(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => Navigator.maybePop(context),
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
        ),
        title: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Team Details', style: theme.textTheme.titleLarge),
          Text('TT-2048', style: theme.textTheme.bodySmall),
        ]),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(20 * scale, 0, 20 * scale, 32 * scale),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          SportoCard(
              child: Column(children: [
            Row(children: [
              _avatar(cs, 'ZW', const Color(0xFF5A2A18), 40 * scale),
              SizedBox(width: 12 * scale),
              Expanded(
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                    Text('Zoto Warrior', style: theme.textTheme.titleLarge),
                    Wrap(spacing: 8, children: [
                      SportoBadge(text: 'Paid', color: cs.secondary),
                      SportoBadge(
                          text: '✓ Approved', color: context.sporto.info),
                    ]),
                    const SizedBox(height: 6),
                    Text('Contact: +91 900XX XXXXX',
                        style: theme.textTheme.bodySmall),
                  ])),
            ]),
            const SportoDivider(height: 22),
            Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
              _metric(theme, 'Player', '5/5'),
              _metric(theme, 'Joined On', '01 Jul 2026'),
              _metric(theme, 'Status', 'Active', valueColor: cs.secondary),
            ]),
          ])),
          SizedBox(height: 20 * scale),
          _personCard(context, 'Captain:', const [
            ('Shravan Prajapati', 'Batsman', '+91 900XX XXXXX'),
          ]),
          SizedBox(height: 12 * scale),
          _personCard(context, 'Players', const [
            ('Amit Kumar', 'Batsman', '+91 900XX XXXXX'),
            ('Manish K', 'Bowler', '+91 900XX XXXXX'),
            ('Sumit Nai', 'Allrounder', '+91 900XX XXXXX'),
            ('Mayank S', 'Wicketkeeper', '+91 900XX XXXXX'),
          ]),
        ]),
      ),
    );
  }

  Widget _avatar(ColorScheme cs, String text, Color fill, double size) =>
      Container(
        width: size,
        height: size,
        alignment: Alignment.center,
        decoration:
            BoxDecoration(color: fill, borderRadius: BorderRadius.circular(10)),
        child: Text(text,
            style: TextStyle(color: cs.onSurface, fontWeight: FontWeight.w600)),
      );

  Widget _metric(ThemeData theme, String label, String value,
          {Color? valueColor}) =>
      Column(children: [
        Text(label, style: theme.textTheme.labelSmall),
        const SizedBox(height: 4),
        Text(value,
            style: theme.textTheme.bodySmall?.copyWith(color: valueColor)),
      ]);

  Widget _personCard(BuildContext context, String title,
      List<(String, String, String)> people) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    return SportoCard(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(title,
          style: theme.textTheme.titleMedium
              ?.copyWith(color: context.sporto.info)),
      const SizedBox(height: 12),
      for (final person in people) ...[
        Text(person.$1, style: theme.textTheme.bodyLarge),
        const SizedBox(height: 4),
        Text('• Active  • ${person.$2}  • ${person.$3}',
            style: theme.textTheme.bodySmall
                ?.copyWith(color: cs.onSurfaceVariant)),
        if (person != people.last) const SizedBox(height: 12),
      ],
    ]));
  }
}
