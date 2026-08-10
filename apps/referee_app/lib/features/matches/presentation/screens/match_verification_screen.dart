import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:ui_kit/ui_kit.dart';

import '../../../../app/router/app_router.dart';

class MatchVerificationScreen extends StatefulWidget {
  const MatchVerificationScreen({super.key});

  @override
  State<MatchVerificationScreen> createState() =>
      _MatchVerificationScreenState();
}

class _MatchVerificationScreenState extends State<MatchVerificationScreen> {
  bool _team1Verified = true;
  bool _team2Verified = true;
  bool _tossDone = false;
  bool _team1Present = true;
  bool _team2Present = true;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Scaffold(
      backgroundColor: context.sporto.canvas,
      body: Stack(
        children: [
          const SportoAmbientBackground(),
          SafeArea(
            child: Column(
              children: [
                _VerificationHeader(onBack: () => context.pop()),
                Expanded(
                  child: SingleChildScrollView(
                    physics: const ClampingScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(
                          height: 140,
                          child: _MatchSummaryCard(),
                        ),
                        const SizedBox(height: 19),
                        Text(
                          'Team Verification',
                          style: theme.textTheme.titleLarge
                              ?.copyWith(color: cs.onSurfaceVariant),
                        ),
                        const SizedBox(height: 12),
                        SportoTeamVerificationCard(
                          teamName: 'Team 1',
                          subName: 'Delhi Warriors',
                          players: const [
                            'Shrvn Prajapati (Captain)',
                            'Amit Kumar',
                            'Manish K',
                            'Sumit Nai',
                            'Mayank S',
                          ],
                          isPresent: _team1Present,
                          onTogglePresent: () =>
                              setState(() => _team1Present = !_team1Present),
                          onMarkAbsent: () =>
                              setState(() => _team1Present = false),
                        ),
                        const SizedBox(height: 10),
                        SportoTeamVerificationCard(
                          teamName: 'Team 2',
                          subName: 'Hyd Highlanders',
                          players: const [
                            'Vikram Reddy (Captain)',
                            'Dev Kumar',
                            'Pankaj S',
                            'Rohan A',
                            'Vinayak L',
                          ],
                          isPresent: _team2Present,
                          onTogglePresent: () =>
                              setState(() => _team2Present = !_team2Present),
                          onMarkAbsent: () =>
                              setState(() => _team2Present = false),
                        ),
                        const SizedBox(height: 24),
                        Text(
                          'Final Checklist',
                          style: theme.textTheme.titleLarge
                              ?.copyWith(color: cs.onSurfaceVariant),
                        ),
                        const SizedBox(height: 12),
                        SportoCard(
                          radius: context.sportoLayout.radius14,
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          child: Column(
                            children: [
                              _ChecklistItem(
                                label: 'Team 1',
                                checked: _team1Verified,
                                onTap: () => setState(
                                  () => _team1Verified = !_team1Verified,
                                ),
                              ),
                              _ChecklistItem(
                                label: 'Team 2',
                                checked: _team2Verified,
                                onTap: () => setState(
                                  () => _team2Verified = !_team2Verified,
                                ),
                              ),
                              _ChecklistItem(
                                label: 'Toss',
                                checked: _tossDone,
                                onTap: () =>
                                    setState(() => _tossDone = !_tossDone),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 4),
                        Center(
                          child: PrimaryButton(
                            width: 270,
                            height: 48,
                            radius: context.sportoLayout.radius16,
                            label: 'Ready To Toss',
                            onPressed: () =>
                                context.push(AppRouter.conductTossRoute),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _VerificationHeader extends StatelessWidget {
  const _VerificationHeader({required this.onBack});
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SizedBox(
      height: 76,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Row(
          children: [
            Material(
              color: context.sporto.cardElevated,
              borderRadius: BorderRadius.circular(context.sportoLayout.radius12),
              child: InkWell(
                onTap: onBack,
                borderRadius:
                    BorderRadius.circular(context.sportoLayout.radius12),
                child: const SizedBox(
                  width: 36,
                  height: 36,
                  child: Icon(Icons.chevron_left_rounded, size: 30),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Match Verification',
                    style: theme.textTheme.headlineMedium),
                Text('Match #SPT-20481', style: theme.textTheme.bodyMedium),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _MatchSummaryCard extends StatelessWidget {
  const _MatchSummaryCard();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    return SportoCard(
      radius: context.sportoLayout.radius16,
      padding: const EdgeInsets.all(10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              SportoBadge(text: 'Quarter Final', color: cs.secondary, outlined: true),
              const Spacer(),
              Text('Today, 06:30 PM',
                  style: theme.textTheme.bodyMedium?.copyWith(height: 1)),
              const Spacer(),
              SportoBadge(text: 'Upcoming', color: context.sporto.upcoming),
            ],
          ),
          const SizedBox(height: 6),
          Text('Asia Cup 2026',
              style: theme.textTheme.titleLarge?.copyWith(height: 1)),
          Row(
            children: [
              Icon(Icons.location_on_outlined,
                  size: 14, color: cs.onSurfaceVariant),
              const SizedBox(width: 4),
              Text('Hyderabad',
                  style: theme.textTheme.bodyMedium?.copyWith(height: 1)),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: Text('Delhi Warriors',
                    style: theme.textTheme.bodyLarge?.copyWith(height: 1)),
              ),
              Text('Vs',
                  style: theme.textTheme.bodyMedium?.copyWith(height: 1)),
              Expanded(
                child: Text('Hyd Highlanders',
                    textAlign: TextAlign.end,
                    style: theme.textTheme.bodyLarge?.copyWith(height: 1)),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Divider(height: 1, color: cs.outline),
          const SizedBox(height: 9),
          Center(
            child: Text.rich(
              TextSpan(
                style: theme.textTheme.bodyLarge?.copyWith(height: 1),
                children: [
                  const TextSpan(text: 'Starts in '),
                  TextSpan(
                    text: '24 mins',
                    style: theme.textTheme.bodyLarge
                        ?.copyWith(color: context.sporto.assigned),
                  ),
                  const TextSpan(text: '  ·  at 06:30 PM'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ChecklistItem extends StatelessWidget {
  const _ChecklistItem({
    required this.label,
    required this.checked,
    required this.onTap,
  });

  final String label;
  final bool checked;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: onTap,
      child: SizedBox(
        height: 34,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Row(
            children: [
              SportoCheckBox(checked: checked),
              const SizedBox(width: 10),
              Text(
                label,
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: checked
                      ? theme.colorScheme.onTertiary
                      : theme.colorScheme.onSurface,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
