import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:ui_kit/ui_kit.dart';

enum RefereeScoringView {
  selectBowler,
  scoring,
  overComplete,
  inningsComplete,
  tied,
  superOverBowler,
  superOverScoring,
  superOverComplete,
  finalResult,
  superOverFinalResult,
  submitted,
  superOverSubmitted,
}

class LiveScoringScreen extends StatefulWidget {
  final RefereeScoringView initialView;

  const LiveScoringScreen({
    super.key,
    this.initialView = RefereeScoringView.selectBowler,
  });

  @override
  State<LiveScoringScreen> createState() => _LiveScoringScreenState();
}

class _LiveScoringScreenState extends State<LiveScoringScreen> {
  late RefereeScoringView _view;

  @override
  void initState() {
    super.initState();
    _view = widget.initialView;
  }

  @override
  Widget build(BuildContext context) {
    final scale = context.sportoScale;
    final submitted = _view == RefereeScoringView.submitted ||
        _view == RefereeScoringView.superOverSubmitted;
    return SportoScreenShell(
      ambient: true,
      body: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          physics: const ClampingScrollPhysics(),
          padding: EdgeInsets.fromLTRB(
              20 * scale, submitted ? 36 * scale : 21 * scale, 20 * scale, 40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (!submitted) ...[
                _Header(
                  title: _view == RefereeScoringView.finalResult ||
                          _view == RefereeScoringView.superOverFinalResult
                      ? 'Final Result'
                      : 'Cricket Score Entry',
                  onBack: () => context.canPop() ? context.pop() : null,
                ),
                SizedBox(height: 22 * scale),
              ],
              _content(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _content(BuildContext context) => switch (_view) {
        RefereeScoringView.selectBowler => _selectBowler(context),
        RefereeScoringView.scoring => _scoring(context),
        RefereeScoringView.overComplete => _overComplete(context),
        RefereeScoringView.inningsComplete => _inningsComplete(context),
        RefereeScoringView.tied => _tied(context),
        RefereeScoringView.superOverBowler => _superOverBowler(context),
        RefereeScoringView.superOverScoring =>
          _scoring(context, superOver: true),
        RefereeScoringView.superOverComplete => _superOverComplete(context),
        RefereeScoringView.finalResult => _finalResult(context),
        RefereeScoringView.superOverFinalResult =>
          _finalResult(context, superOver: true),
        RefereeScoringView.submitted => _submitted(context),
        RefereeScoringView.superOverSubmitted =>
          _submitted(context, superOver: true),
      };

  Widget _selectBowler(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _MatchHeaderCard(),
          const SizedBox(height: 22),
          const _ScoreCard(score: '0/0', meta: 'Over 1/5  •  Ball 0/6'),
          const SizedBox(height: 20),
          Text('Select Bowler for — Over 1',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: context.sporto.assigned,
                    fontSize: 15,
                  )),
          const SizedBox(height: 12),
          _PlayerChoice(
              label: 'Vikram Reddy (Captain)', selected: false, enabled: false),
          const SizedBox(height: 8),
          _PlayerChoice(
              key: const Key('select_bowler_dev'),
              label: 'Dev Kumar',
              selected: true,
              onTap: () => setState(() => _view = RefereeScoringView.scoring)),
          const SizedBox(height: 8),
          const _PlayerChoice(label: 'Pankaj S'),
          const SizedBox(height: 8),
          const _PlayerChoice(label: 'Rohan A'),
          const SizedBox(height: 8),
          const _PlayerChoice(label: 'Vinayak L'),
        ],
      );

  Widget _scoring(BuildContext context, {bool superOver = false}) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _MatchHeaderCard(),
          const SizedBox(height: 22),
          _ScoreCard(
            title:
                superOver ? 'Super Over - Hyd Highlanders' : 'Hyd Highlanders',
            score: superOver ? '0/0' : '80/2',
            meta: superOver ? 'Ball 0/6' : 'Over 4/5  •  Ball 2/6',
            showBalls: true,
          ),
          const SizedBox(height: 20),
          Text('This Over — Dev Kumar',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Theme.of(context).colorScheme.tertiary,
                    fontSize: 15,
                  )),
          const SizedBox(height: 12),
          _runButtons(context),
          const SizedBox(height: 10),
          _extrasButtons(context),
          const SizedBox(height: 18),
          Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: Theme.of(context)
                    .colorScheme
                    .tertiary
                    .withValues(alpha: .08),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text('“One Wide in One Doesn’t Count. Re-bowled It',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.tertiary,
                        fontSize: 10,
                      )),
            ),
          ),
        ],
      );

  Widget _overComplete(BuildContext context) => Column(children: [
        const _MatchHeaderCard(),
        const SizedBox(height: 22),
        const _ScoreCard(
            score: '80/2', meta: 'Over 4/5  •  Ball 6/6', showBalls: true),
        const SizedBox(height: 20),
        _notice(context, '✓  Over 4 completed.', context.sporto.assigned),
        const SizedBox(height: 20),
        _primary(context, 'Let’s Begin 5 Last Over',
            () => setState(() => _view = RefereeScoringView.scoring)),
      ]);

  Widget _inningsComplete(BuildContext context) => Column(children: [
        const _MatchHeaderCard(),
        const SizedBox(height: 22),
        const _ScoreCard(score: '90/2', meta: 'Over 5/5  •  Ball 6/6'),
        const SizedBox(height: 20),
        const _InningsCard(title: '✓  Innings Completed'),
        const SizedBox(height: 20),
        _primary(context, 'Proceed to Submit Result',
            () => setState(() => _view = RefereeScoringView.finalResult)),
      ]);

  Widget _tied(BuildContext context) => Column(children: [
        const _MatchHeaderCard(),
        const SizedBox(height: 22),
        const _ScoreCard(score: '90/2', meta: 'Over 5/5  •  Ball 6/6'),
        const SizedBox(height: 20),
        _notice(context, '⚠  Tied 90–90 — Super Over required.',
            Theme.of(context).colorScheme.error),
        const SizedBox(height: 20),
        _primary(context, 'Start Super Over',
            () => setState(() => _view = RefereeScoringView.superOverBowler)),
      ]);

  Widget _superOverBowler(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _MatchHeaderCard(),
          const SizedBox(height: 22),
          _tieBreakerNotice(context),
          const SizedBox(height: 20),
          const _ScoreCard(
              title: 'Super Over - Hyd Highlanders',
              score: '0/0',
              meta: 'Ball 0/6'),
          const SizedBox(height: 20),
          Text('Select Super Over Bowler',
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(color: context.sporto.assigned, fontSize: 15)),
          const SizedBox(height: 12),
          _PlayerChoice(
              label: 'Dev Kumar',
              selected: true,
              onTap: () =>
                  setState(() => _view = RefereeScoringView.superOverScoring)),
          const SizedBox(height: 8),
          const _PlayerChoice(label: 'Vinayak L'),
        ],
      );

  Widget _superOverComplete(BuildContext context) => Column(children: [
        const _MatchHeaderCard(),
        const SizedBox(height: 22),
        const _ScoreCard(
            title: 'Super Over - Hyd Highlanders',
            score: '10/0',
            meta: 'Ball 6/6'),
        const SizedBox(height: 20),
        const _InningsCard(
            title: '✓  Super Over Innings Completed', superOver: true),
        const SizedBox(height: 20),
        _primary(
            context,
            'Proceed to Submit Result',
            () => setState(
                () => _view = RefereeScoringView.superOverFinalResult)),
      ]);

  Widget _finalResult(BuildContext context, {bool superOver = false}) =>
      Column(children: [
        _MatchHeaderCard(finalResult: superOver, resultScores: !superOver),
        const SizedBox(height: 20),
        if (superOver) ...[
          const _InningsCard(title: '✓  Regulation'),
          const SizedBox(height: 20),
          const _InningsCard(
              title: '✓  Super Over Innings Completed', superOver: true),
          const SizedBox(height: 20),
        ],
        _winner(context),
        const SizedBox(height: 20),
        _primary(
            context,
            'Submit Final Result',
            () => setState(() => _view = superOver
                ? RefereeScoringView.superOverSubmitted
                : RefereeScoringView.submitted)),
      ]);

  Widget _submitted(BuildContext context, {bool superOver = false}) =>
      Column(children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(24, 56, 24, 38),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainerHigh,
            borderRadius: BorderRadius.circular(30),
            border: Border.all(
                color: context.sporto.assigned.withValues(alpha: .2)),
          ),
          child: Column(children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: .08),
                borderRadius: BorderRadius.circular(40),
              ),
              alignment: Alignment.center,
              child: Container(
                width: 74,
                height: 74,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Color(0xFF9CF177), Color(0xFF09BE09)]),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(color: Color(0x5525D329), blurRadius: 16)
                  ],
                ),
                child: const Icon(Icons.check_rounded,
                    color: Colors.white, size: 56),
              ),
            ),
            const SizedBox(height: 38),
            Text('RESULT SUBMITTED',
                style: Theme.of(context)
                    .textTheme
                    .titleLarge
                    ?.copyWith(fontSize: 18, fontWeight: FontWeight.w700)),
            const SizedBox(height: 10),
            Text('Bracket, stats, and leaderboards have been\nupdated.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium),
          ]),
        ),
        const SizedBox(height: 20),
        _MatchHeaderCard(completed: true, superOver: superOver),
        const SizedBox(height: 20),
        _winner(context),
        const SizedBox(height: 20),
        SizedBox(
          width: 270,
          child: SportoPillButton(
            label: 'View Match History',
            color: context.sporto.info,
            foregroundColor: const Color(0xFF10202A),
            filled: true,
            height: 49,
            onTap: () {},
          ),
        ),
      ]);

  Widget _winner(BuildContext context) => Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          gradient: const LinearGradient(colors: [
            Color(0xFF4A2924),
            Color(0xFF063A27),
            Color(0xFF39460A)
          ]),
          borderRadius: BorderRadius.circular(20),
          border:
              Border.all(color: context.sporto.assigned.withValues(alpha: .25)),
        ),
        child: Row(children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
                color: Theme.of(context)
                    .colorScheme
                    .tertiary
                    .withValues(alpha: .15),
                shape: BoxShape.circle),
            child: Icon(Icons.emoji_events_rounded,
                color: Theme.of(context).colorScheme.tertiary),
          ),
          const SizedBox(width: 10),
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Winner',
                style: Theme.of(context)
                    .textTheme
                    .bodySmall
                    ?.copyWith(color: context.sporto.info)),
            Text('Hyd Highlanders',
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(color: Theme.of(context).colorScheme.tertiary)),
          ]),
        ]),
      );

  Widget _runButtons(BuildContext context) => Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: ['0', '1', '2', '4', '6']
            .map((value) => _scoreButton(context, value, 57))
            .toList(),
      );

  Widget _extrasButtons(BuildContext context) => Row(children: [
        Expanded(
            child: _scoreButton(context, 'WKT', double.infinity, danger: true)),
        const SizedBox(width: 16),
        Expanded(child: _scoreButton(context, 'Wide', double.infinity)),
        const SizedBox(width: 16),
        Expanded(child: _scoreButton(context, 'No Ball', double.infinity)),
      ]);

  Widget _scoreButton(BuildContext context, String label, double width,
          {bool danger = false}) =>
      Material(
        color:
            danger ? Theme.of(context).colorScheme.error : context.sporto.field,
        borderRadius: BorderRadius.circular(11),
        child: InkWell(
          onTap: () {},
          borderRadius: BorderRadius.circular(11),
          child: Container(
            width: width,
            height: 45,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(11),
              border:
                  Border.all(color: context.sporto.info.withValues(alpha: .25)),
            ),
            child: Text(label,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: danger
                        ? Colors.white
                        : label == 'Wide' || label == 'No Ball'
                            ? Theme.of(context).colorScheme.tertiary
                            : Theme.of(context).colorScheme.onSurface)),
          ),
        ),
      );

  Widget _notice(BuildContext context, String text, Color color) => Container(
        width: double.infinity,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: color.withValues(alpha: .12),
          border: Border.all(color: color.withValues(alpha: .28)),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          if (text.startsWith('✓')) ...[
            Container(
                width: 17,
                height: 17,
                decoration: BoxDecoration(
                    color: context.sporto.assigned,
                    borderRadius: BorderRadius.circular(4)),
                child: const Icon(Icons.check_rounded,
                    size: 13, color: Colors.white)),
            const SizedBox(width: 7),
          ] else if (text.startsWith('⚠')) ...[
            Icon(Icons.warning_amber_rounded, size: 17, color: color),
            const SizedBox(width: 7),
          ],
          Flexible(
              child: Text(text.replaceFirst(RegExp(r'^[✓⚠]\s*'), ''),
                  style: Theme.of(context)
                      .textTheme
                      .bodyMedium
                      ?.copyWith(color: color))),
        ]),
      );

  Widget _tieBreakerNotice(BuildContext context) => Container(
        width: double.infinity,
        constraints: const BoxConstraints(minHeight: 120),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
            gradient: const LinearGradient(
                colors: [Color(0xFF241B12), Color(0xFF252319)]),
            border: Border.all(color: const Color(0xFF6B5310)),
            borderRadius: BorderRadius.circular(12)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Container(
                width: 17,
                height: 17,
                decoration: BoxDecoration(
                    color: context.sporto.assigned,
                    borderRadius: BorderRadius.circular(4)),
                child: const Icon(Icons.check_rounded,
                    size: 13, color: Colors.white)),
            const SizedBox(width: 7),
            Text('Tie - Breaker',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant)),
          ]),
          const SizedBox(height: 13),
          Text('Regulation tied 90–90.',
              style: Theme.of(context).textTheme.bodyMedium),
          const SizedBox(height: 3),
          Text(
              'One extra over each, Delhi Warriors’s Super Over already\nposted 9.',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurface,
                  height: 1.25)),
        ]),
      );

  Widget _primary(BuildContext context, String label, VoidCallback onTap) =>
      Center(
        child: PrimaryButton(
          width: 270,
          height: 49,
          radius: 14,
          label: label,
          onPressed: onTap,
        ),
      );
}

class _Header extends StatelessWidget {
  final String title;
  final VoidCallback onBack;
  const _Header({required this.title, required this.onBack});

  @override
  Widget build(BuildContext context) => Row(children: [
        Material(
          color: context.sporto.cardElevated,
          borderRadius: BorderRadius.circular(11),
          child: InkWell(
            onTap: onBack,
            borderRadius: BorderRadius.circular(11),
            child: const SizedBox(
                width: 36,
                height: 36,
                child: Icon(Icons.chevron_left_rounded, size: 28)),
          ),
        ),
        const SizedBox(width: 10),
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  )),
          Text('Match #SPT-20481',
              style: Theme.of(context).textTheme.bodySmall),
        ]),
      ]);
}

class _MatchHeaderCard extends StatelessWidget {
  final bool finalResult;
  final bool completed;
  final bool superOver;
  final bool resultScores;
  const _MatchHeaderCard(
      {this.finalResult = false,
      this.completed = false,
      this.superOver = false,
      this.resultScores = false});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 21.5),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
            colors: [Color(0xFF2A2028), Color(0xFF1A2024)]),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          _miniBadge(context, 'Quarter Final', cs.secondary, outlined: true),
          if (!completed) ...[
            const SizedBox(width: 6),
            _miniBadge(context, '● Live Now', const Color(0xFFFF5257)),
          ] else ...[
            const Spacer(),
            _miniBadge(context, 'Completed', context.sporto.info),
          ],
        ]),
        const SizedBox(height: 8),
        Text('Asia Cup 2026',
            style: Theme.of(context)
                .textTheme
                .titleLarge
                ?.copyWith(color: cs.tertiary, fontSize: 15)),
        Row(children: [
          Icon(Icons.location_on_outlined,
              size: 14, color: cs.onSurfaceVariant),
          const SizedBox(width: 3),
          Text('Hyderabad', style: Theme.of(context).textTheme.bodySmall),
        ]),
        if (!finalResult || completed) ...[
          const SizedBox(height: 10),
          const _Dashes(),
          const SizedBox(height: 10),
          _teamLine(context, completed: completed || resultScores),
          if (superOver) ...[
            const SizedBox(height: 12),
            Text('Super Over Innings Completed',
                style: Theme.of(context).textTheme.bodyMedium),
            const SizedBox(height: 5),
            _teamLine(context, completed: true, superOver: true),
          ],
        ],
      ]),
    );
  }

  Widget _teamLine(BuildContext context,
      {required bool completed, bool superOver = false}) {
    final cs = Theme.of(context).colorScheme;
    return Row(children: [
      Expanded(
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('Hyd Highlanders', style: Theme.of(context).textTheme.bodyMedium),
        Text('Batting',
            style: Theme.of(context)
                .textTheme
                .bodySmall
                ?.copyWith(color: cs.secondary)),
        if (completed)
          Text(superOver ? '10/0' : '90/2',
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(color: cs.tertiary)),
      ])),
      Text('Vs', style: Theme.of(context).textTheme.bodySmall),
      Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
        Text('Delhi Warriors', style: Theme.of(context).textTheme.bodyMedium),
        Text('Bowling',
            style: Theme.of(context)
                .textTheme
                .bodySmall
                ?.copyWith(color: context.sporto.info)),
        if (completed)
          Text(superOver ? '9/0' : '85/3',
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(color: cs.onSurfaceVariant)),
      ])),
    ]);
  }
}

class _ScoreCard extends StatelessWidget {
  final String title;
  final String score;
  final String meta;
  final bool showBalls;
  const _ScoreCard({
    this.title = 'Hyd Highlanders',
    required this.score,
    required this.meta,
    this.showBalls = false,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(14, 23, 14, 22),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
            colors: [Color(0xFF56332C), Color(0xFF023D2B), Color(0xFF46530D)]),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: cs.secondary.withValues(alpha: .22)),
      ),
      child: Column(children: [
        Text(title,
            style: Theme.of(context)
                .textTheme
                .bodyMedium
                ?.copyWith(color: context.sporto.info)),
        const SizedBox(height: 6),
        Text('Runs / Wicket', style: Theme.of(context).textTheme.bodySmall),
        const SizedBox(height: 4),
        Text(score,
            style: Theme.of(context)
                .textTheme
                .displayLarge
                ?.copyWith(color: cs.tertiary, fontSize: 31)),
        const SizedBox(height: 4),
        Text(meta,
            style: Theme.of(context)
                .textTheme
                .bodyLarge
                ?.copyWith(color: cs.onSurface)),
        if (showBalls) ...[
          const SizedBox(height: 12),
          const _Dashes(),
          const SizedBox(height: 10),
          Align(
            alignment: Alignment.centerLeft,
            child: Text.rich(TextSpan(
                style: Theme.of(context).textTheme.bodyMedium,
                children: const [
                  TextSpan(text: 'This Over - '),
                  TextSpan(
                      text: 'Amit Kumar',
                      style: TextStyle(fontWeight: FontWeight.w700)),
                ])),
          ),
          const SizedBox(height: 10),
          Row(children: const [
            _Ball('4', Color(0xFF53C4F2)),
            _Ball('1', Color(0xFF28314A)),
            _Ball('', Color(0xFF28314A)),
            _Ball('', Color(0xFF28314A)),
            _Ball('', Color(0xFF28314A)),
            _Ball('', Color(0xFF28314A)),
          ]),
        ],
      ]),
    );
  }
}

class _PlayerChoice extends StatelessWidget {
  final String label;
  final bool selected;
  final bool enabled;
  final VoidCallback? onTap;
  const _PlayerChoice({
    super.key,
    required this.label,
    this.selected = false,
    this.enabled = true,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) => Material(
        color: context.sporto.field,
        borderRadius: BorderRadius.circular(11),
        child: InkWell(
          onTap: enabled ? onTap : null,
          borderRadius: BorderRadius.circular(11),
          child: Container(
            height: 41,
            padding: const EdgeInsets.symmetric(horizontal: 14),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(11),
              border: Border.all(
                  color: selected
                      ? context.sporto.info.withValues(alpha: .3)
                      : Colors.transparent),
            ),
            child: Row(children: [
              SportoCheckBox(checked: selected),
              const SizedBox(width: 8),
              Text(label,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: enabled
                          ? Theme.of(context).colorScheme.onSurfaceVariant
                          : Theme.of(context)
                              .colorScheme
                              .onSurfaceVariant
                              .withValues(alpha: .45))),
            ]),
          ),
        ),
      );
}

class _InningsCard extends StatelessWidget {
  final String title;
  final bool superOver;
  const _InningsCard({required this.title, this.superOver = false});

  @override
  Widget build(BuildContext context) => Container(
        width: double.infinity,
        constraints: const BoxConstraints(minHeight: 129),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: context.sporto.assigned.withValues(alpha: .12),
          borderRadius: BorderRadius.circular(12),
          border:
              Border.all(color: context.sporto.assigned.withValues(alpha: .28)),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Container(
                width: 17,
                height: 17,
                decoration: BoxDecoration(
                    color: context.sporto.assigned,
                    borderRadius: BorderRadius.circular(4)),
                child: const Icon(Icons.check_rounded,
                    size: 13, color: Colors.white)),
            const SizedBox(width: 7),
            Expanded(
                child: Text(title.replaceFirst('✓  ', ''),
                    style: Theme.of(context).textTheme.bodyMedium)),
          ]),
          const SizedBox(height: 10),
          const _Dashes(),
          const SizedBox(height: 10),
          _MatchHeaderCard(superOver: superOver)
              ._teamLine(context, completed: true, superOver: superOver),
        ]),
      );
}

class _Ball extends StatelessWidget {
  final String text;
  final Color color;
  const _Ball(this.text, this.color);
  @override
  Widget build(BuildContext context) => Container(
        width: 30,
        height: 30,
        margin: const EdgeInsets.only(right: 10),
        alignment: Alignment.center,
        decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        child: Text(text,
            style: Theme.of(context)
                .textTheme
                .labelMedium
                ?.copyWith(color: Colors.black, fontWeight: FontWeight.w700)),
      );
}

class _Dashes extends StatelessWidget {
  const _Dashes();
  @override
  Widget build(BuildContext context) => SizedBox(
        width: double.infinity,
        height: 1,
        child: CustomPaint(
            painter: _DashPainter(
                Theme.of(context).colorScheme.outline.withValues(alpha: .8))),
      );
}

class _DashPainter extends CustomPainter {
  final Color color;
  const _DashPainter(this.color);
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1;
    for (double x = 0; x < size.width; x += 6) {
      canvas.drawLine(Offset(x, 0),
          Offset((x + 2).clamp(0, size.width).toDouble(), 0), paint);
    }
  }

  @override
  bool shouldRepaint(covariant _DashPainter oldDelegate) =>
      oldDelegate.color != color;
}

Widget _miniBadge(BuildContext context, String text, Color color,
    {bool outlined = false}) {
  final live = text.startsWith('●');
  final label = text.replaceFirst('● ', '');
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
    decoration: BoxDecoration(
      color: outlined ? Colors.transparent : color.withValues(alpha: .16),
      borderRadius: BorderRadius.circular(8),
      border: outlined ? Border.all(color: color) : null,
    ),
    child: Row(mainAxisSize: MainAxisSize.min, children: [
      if (live) ...[
        Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 3),
      ],
      Text(label,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: color, fontSize: 11, fontWeight: FontWeight.w600)),
    ]),
  );
}
