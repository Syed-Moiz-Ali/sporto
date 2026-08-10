import 'package:flutter/material.dart';
import 'package:ui_kit/ui_kit.dart';

// Reusable Player Selection Card
class _PlayerSelectionCard extends StatelessWidget {
  final String title;
  final String teamName;
  final List<String> players;
  final String? selectedPlayer;
  final ValueChanged<String> onSelected;
  final String? excludePlayer;

  const _PlayerSelectionCard({
    required this.title,
    required this.teamName,
    required this.players,
    required this.selectedPlayer,
    required this.onSelected,
    this.excludePlayer,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return SportoCard(
        padding: EdgeInsets.zero,
        child: Column(children: [
          Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(title,
                        style: TextStyle(
                            color: cs.onTertiary,
                            fontSize: 16,
                            fontWeight: FontWeight.w700)),
                    Text(teamName,
                        style: TextStyle(
                            color: cs.onSurface,
                            fontSize: 14,
                            fontWeight: FontWeight.w600)),
                  ])),
          const SportoDivider(height: 1),
          ...players.map((p) {
            final isSelected = selectedPlayer == p;
            final isExcluded = p == excludePlayer;
            return ListTile(
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              enabled: !isExcluded,
              leading: GestureDetector(
                  onTap:
                      isExcluded ? null : () => onSelected(isSelected ? '' : p),
                  child: SportoCheckBox(checked: isSelected)),
              title: Text(p,
                  style: TextStyle(
                    color: isExcluded
                        ? cs.onSurfaceVariant.withOpacity(0.3)
                        : (isSelected ? cs.onSurface : cs.onSurfaceVariant),
                    fontSize: 14,
                    fontWeight:
                        isSelected ? FontWeight.w600 : FontWeight.normal,
                  )),
              onTap: isExcluded ? null : () => onSelected(isSelected ? '' : p),
            );
          }).toList(),
        ]));
  }
}

// ============================================================
// MAIN CONDUCT TOSS WIZARD (ALL 4 STEPS)
// ============================================================
class ConductTossWizard extends StatefulWidget {
  final int initialStep;

  const ConductTossWizard({super.key, this.initialStep = 0});

  @override
  State<ConductTossWizard> createState() => _ConductTossWizardState();
}

class _ConductTossWizardState extends State<ConductTossWizard> {
  late int _currentStep;

  // Toss State
  bool _isFlipping = false;
  String? _tossWinner;
  String? _tossChoice;

  // Opener Selection State
  String? _striker;
  String? _nonStriker;
  String? _openingBowler;

  final List<String> _team1Players = [
    'Shrvn Prajapati (Captain)',
    'Amit Kumar',
    'Manish K',
    'Sumit Nai',
    'Mayank S'
  ];
  final List<String> _team2Players = [
    'Vikram Reddy (Captain)',
    'Dev Kumar',
    'Pankaj S',
    'Rohan A',
    'Vinayak L'
  ];

  @override
  void initState() {
    super.initState();
    _currentStep = widget.initialStep.clamp(0, 4);
    if (_currentStep > 0) _tossWinner = 'Hyd Highlanders';
    if (_currentStep > 2) _tossChoice = 'Bat First';
    if (_currentStep > 3) {
      _striker = _team1Players.first;
      _nonStriker = _team1Players[1];
      _openingBowler = _team2Players[1];
    }
  }

  void _flipCoin() {
    setState(() => _isFlipping = true);
    Future.delayed(const Duration(seconds: 2), () {
      if (!mounted) return;
      setState(() {
        _isFlipping = false;
        _tossWinner = 'Hyd Highlanders'; // Hardcoded for demo
        _currentStep = 1;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final spacing = context.sportoLayout;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        toolbarHeight: 64,
        titleSpacing: 0,
        leadingWidth: 56,
        leading: Padding(
          padding: const EdgeInsets.only(left: 20, top: 14, bottom: 14),
          child: Material(
            color: context.sporto.cardElevated,
            borderRadius: BorderRadius.circular(10),
            child: InkWell(
              onTap: () => Navigator.maybePop(context),
              borderRadius: BorderRadius.circular(10),
              child: Icon(Icons.arrow_back_ios_new_rounded,
                  color: cs.onSurface, size: 18),
            ),
          ),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(_screenTitle,
                style: theme.textTheme.titleLarge?.copyWith(
                  color: cs.onSurface,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                )),
            Text('Match #SPT-20481',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: cs.onSurfaceVariant,
                  fontSize: 12,
                )),
          ],
        ),
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(spacing.space24),
          child: Padding(
            padding: EdgeInsets.fromLTRB(
                spacing.space20, 0, spacing.space20, spacing.space4),
            child: Row(
              children: List.generate(
                  3,
                  (i) => Expanded(
                        child: Container(
                          height: 3,
                          margin: EdgeInsets.only(
                              right: i == 2 ? 0 : spacing.space4),
                          decoration: BoxDecoration(
                            color: i <= _progressStep
                                ? cs.tertiary
                                : cs.surfaceContainerHigh,
                            borderRadius:
                                BorderRadius.circular(spacing.radius4),
                          ),
                        ),
                      )),
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        physics: const ClampingScrollPhysics(),
        padding: EdgeInsets.fromLTRB(
            spacing.space20, spacing.space16, spacing.space20, spacing.space30),
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          key: Key('step_$_currentStep'),
          child: _buildCurrentStep(cs),
        ),
      ),
    );
  }

  Widget _buildCurrentStep(ColorScheme cs) {
    switch (_currentStep) {
      case 0:
        return _buildStep1FlipCoin(cs);
      case 1:
        return _buildCoinResult(cs);
      case 2:
        return _buildStep2TossResult(cs);
      case 3:
        return _buildStep3SelectOpeners(cs);
      case 4:
        return _buildStep4MatchReady(cs);
      default:
        return const SizedBox.shrink();
    }
  }

  String get _screenTitle => switch (_currentStep) {
        3 => 'Select Openers',
        4 => 'Match Ready',
        _ => 'Conduct Toss',
      };

  int get _progressStep => switch (_currentStep) {
        0 || 1 => 0,
        2 => 1,
        _ => 2,
      };

  // Shared Match Header for all steps
  Widget _matchHeader(ColorScheme cs) {
    final theme = Theme.of(context);
    final spacing = context.sportoLayout;
    return SportoCard(
        radius: spacing.radius10,
        padding: EdgeInsets.symmetric(
            horizontal: spacing.space16,
            vertical: spacing.space12 + spacing.space2),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Delhi Warriors',
                style: theme.textTheme.bodyMedium?.copyWith(
                    color: cs.onSurface,
                    fontSize: 13,
                    fontWeight: FontWeight.w600)),
            Text('Vs',
                style: theme.textTheme.bodySmall
                    ?.copyWith(color: cs.onSurfaceVariant, fontSize: 12)),
            Text('Hyd Highlanders',
                style: theme.textTheme.bodyMedium?.copyWith(
                    color: cs.onSurface,
                    fontSize: 13,
                    fontWeight: FontWeight.w600)),
          ],
        ));
  }

  // ============================================================
  // STEP 1: FLIP COIN
  // ============================================================
  Widget _buildStep1FlipCoin(ColorScheme cs) {
    final theme = Theme.of(context);
    final spacing = context.sportoLayout;
    return Column(children: [
      _matchHeader(cs),
      SizedBox(height: spacing.space20),
      SportoCard(
          width: double.infinity,
          radius: spacing.radius12,
          backgroundColor: const Color(0xFF1B2027),
          borderColor: Colors.transparent,
          padding: EdgeInsets.fromLTRB(spacing.space20, spacing.space30,
              spacing.space20, spacing.space30),
          child: Column(children: [
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 500),
              child: _isFlipping
                  ? SizedBox.square(
                      dimension: 150,
                      key: const ValueKey('spin'),
                      child: CircularProgressIndicator(
                        color: cs.tertiary,
                        strokeWidth: 3,
                      ),
                    )
                  : Image.asset(
                      'assets/images/toss_coin_heads.png',
                      key: const ValueKey('coin'),
                      width: 150,
                      height: 150,
                      fit: BoxFit.contain,
                    ),
            ),
            SizedBox(height: spacing.space24),
            Text('Flip coin to decide who chooses first',
                style: theme.textTheme.bodyMedium?.copyWith(
                    color: cs.onSurfaceVariant,
                    fontSize: 14,
                    fontWeight: FontWeight.w500)),
            SizedBox(height: spacing.space30),
            PrimaryButton(
                width: 270,
                height: 48,
                radius: spacing.radius12,
                label: 'Flip Coin',
                onPressed: _flipCoin),
          ])),
    ]);
  }

  Widget _buildCoinResult(ColorScheme cs) {
    final theme = Theme.of(context);
    return Column(children: [
      _matchHeader(cs),
      const SizedBox(height: 20),
      SportoCard(
        width: double.infinity,
        backgroundColor: const Color(0xFF1B2027),
        borderColor: Colors.transparent,
        padding: const EdgeInsets.fromLTRB(20, 32, 20, 30),
        child: Column(children: [
          Image.asset('assets/images/toss_coin_tails.png',
              width: 150, height: 150, fit: BoxFit.contain),
          const SizedBox(height: 22),
          Text('Coin landed on',
              style: theme.textTheme.bodyLarge
                  ?.copyWith(color: cs.onSurfaceVariant)),
          const SizedBox(height: 14),
          Text('TAILS',
              style: theme.textTheme.displaySmall
                  ?.copyWith(color: cs.tertiary, fontWeight: FontWeight.w700)),
          const SizedBox(height: 18),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
            decoration: BoxDecoration(
              color: cs.secondary.withValues(alpha: .10),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Text('Hyd Highlanders Won The Toss',
                style: theme.textTheme.bodySmall?.copyWith(
                    color: cs.secondary, fontWeight: FontWeight.w600)),
          ),
          const SizedBox(height: 28),
          PrimaryButton(
            width: 270,
            height: 48,
            radius: 12,
            label: 'Continue',
            onPressed: () => setState(() => _currentStep = 2),
          ),
        ]),
      ),
    ]);
  }

  // ============================================================
  // STEP 2: TOSS RESULT & CHOOSE
  // ============================================================
  Widget _buildStep2TossResult(ColorScheme cs) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _matchHeader(cs),
      const SizedBox(height: 24),

      // Winner Card
      SportoCard(
          width: double.infinity,
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Toss Winner',
                style: TextStyle(
                    color: cs.secondary,
                    fontSize: 13,
                    fontWeight: FontWeight.w600)),
            const SizedBox(height: 4),
            Text(_tossWinner ?? '',
                style: TextStyle(
                    color: cs.onSurface,
                    fontSize: 18,
                    fontWeight: FontWeight.w700)),
          ])),
      const SizedBox(height: 24),

      // Choice Section
      Text('${_tossWinner} chooses to',
          style: TextStyle(
              color: cs.secondary, fontSize: 16, fontWeight: FontWeight.w600)),
      const SizedBox(height: 16),
      Row(children: [
        Expanded(
            child: _ChoiceCard(
                label: 'Bat First',
                icon: Icons.sports_cricket,
                isSelected: _tossChoice == 'Bat First',
                onTap: () => setState(() => _tossChoice = 'Bat First'))),
        const SizedBox(width: 16),
        Expanded(
            child: _ChoiceCard(
                label: 'Bowl First',
                icon: Icons.sports_baseball,
                isSelected: _tossChoice == 'Bowl First',
                onTap: () => setState(() => _tossChoice = 'Bowl First'))),
      ]),
      const SizedBox(height: 32),
      PrimaryButton(
        width: double.infinity,
        height: 56,
        label: 'Confirm & Select Openers',
        disabled: _tossChoice == null,
        onPressed: () => setState(() => _currentStep = 3),
      ),
    ]);
  }

  Widget _ChoiceCard(
      {required String label,
      required IconData icon,
      required bool isSelected,
      required VoidCallback onTap}) {
    return Builder(builder: (context) {
      final cs = Theme.of(context).colorScheme;
      return GestureDetector(
        onTap: onTap,
        child: Container(
          height: 140,
          decoration: BoxDecoration(
            color: isSelected
                ? cs.secondary.withOpacity(0.1)
                : SportoCard.defaultFill.withOpacity(0.6),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
                color: isSelected ? cs.secondary : SportoCard.defaultBorder,
                width: isSelected ? 2 : 1),
          ),
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            Icon(icon,
                size: 48,
                color: isSelected ? cs.secondary : cs.onSurfaceVariant),
            const SizedBox(height: 12),
            Text(label,
                style: TextStyle(
                    color: isSelected ? cs.secondary : cs.onSurface,
                    fontSize: 14,
                    fontWeight: FontWeight.w600)),
          ]),
        ),
      );
    });
  }

  // ============================================================
  // STEP 3: SELECT OPENERS
  // ============================================================
  Widget _buildStep3SelectOpeners(ColorScheme cs) {
    final battingTeam =
        _tossChoice == 'Bat First' ? 'Hyd Highlanders' : 'Delhi Warriors';
    final bowlingTeam =
        _tossChoice == 'Bat First' ? 'Delhi Warriors' : 'Hyd Highlanders';
    final battingPlayers =
        _tossChoice == 'Bat First' ? _team1Players : _team2Players;
    final bowlingPlayers =
        _tossChoice == 'Bat First' ? _team2Players : _team1Players;

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      // Batting/Bowling Header
      SportoCard(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(battingTeam,
                    style: TextStyle(
                        color: cs.secondary,
                        fontSize: 14,
                        fontWeight: FontWeight.w600)),
                Text('Batting',
                    style: TextStyle(
                        color: cs.onSurface,
                        fontSize: 16,
                        fontWeight: FontWeight.w700)),
              ]),
              Text('Vs',
                  style: TextStyle(color: cs.onSurfaceVariant, fontSize: 12)),
              Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                Text(bowlingTeam,
                    style: TextStyle(
                        color: cs.secondary,
                        fontSize: 14,
                        fontWeight: FontWeight.w600)),
                Text('Bowling',
                    style: TextStyle(
                        color: cs.onSurface,
                        fontSize: 16,
                        fontWeight: FontWeight.w700)),
              ]),
            ],
          )),
      const SizedBox(height: 24),

      // Striker Selection
      _PlayerSelectionCard(
        title: 'Striker',
        teamName: battingTeam,
        players: battingPlayers,
        selectedPlayer: _striker,
        onSelected: (p) => setState(() => _striker = p),
      ),
      const SizedBox(height: 16),

      // Non-Striker Selection
      _PlayerSelectionCard(
        title: 'Non - Striker',
        teamName: battingTeam,
        players: battingPlayers,
        selectedPlayer: _nonStriker,
        onSelected: (p) => setState(() => _nonStriker = p),
        excludePlayer: _striker,
      ),
      const SizedBox(height: 16),

      // Opening Bowler Selection
      _PlayerSelectionCard(
        title: 'Opening Bowler',
        teamName: bowlingTeam,
        players: bowlingPlayers,
        selectedPlayer: _openingBowler,
        onSelected: (p) => setState(() => _openingBowler = p),
      ),
      const SizedBox(height: 32),

      PrimaryButton(
        width: double.infinity,
        height: 56,
        label: 'Start Scoring',
        disabled:
            _striker == null || _nonStriker == null || _openingBowler == null,
        onPressed: () => setState(() => _currentStep = 4),
      ),
    ]);
  }

  // ============================================================
  // STEP 4: MATCH READY
  // ============================================================
  Widget _buildStep4MatchReady(ColorScheme cs) {
    final battingTeam =
        _tossChoice == 'Bat First' ? 'Hyd Highlanders' : 'Delhi Warriors';
    final bowlingTeam =
        _tossChoice == 'Bat First' ? 'Delhi Warriors' : 'Hyd Highlanders';

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      // Innings Set Card
      SportoCard(
          width: double.infinity,
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Innings Set',
                style: TextStyle(
                    color: cs.secondary,
                    fontSize: 13,
                    fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            RichText(
                text: TextSpan(
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                    children: [
                  TextSpan(
                      text: '$battingTeam ',
                      style: TextStyle(color: cs.onSurface)),
                  TextSpan(
                      text: 'First Batting',
                      style: TextStyle(color: cs.tertiary)),
                ])),
            const SizedBox(height: 4),
            RichText(
                text: TextSpan(style: TextStyle(fontSize: 14), children: [
              TextSpan(
                  text: 'Vs $bowlingTeam ',
                  style: TextStyle(color: cs.onSurfaceVariant)),
              TextSpan(text: 'Bowling', style: TextStyle(color: cs.onTertiary)),
            ])),
          ])),
      const SizedBox(height: 24),

      // On the Field Section
      Text('On the Field',
          style: TextStyle(
              color: cs.onSurface, fontSize: 16, fontWeight: FontWeight.w700)),
      const SizedBox(height: 16),

      SportoCard(
          width: double.infinity,
          padding: EdgeInsets.zero,
          child: Column(children: [
            SportoInfoRow(
                label: 'Striker',
                value: _striker?.split(' (')[0] ?? '',
                suffix: (_striker?.contains('Captain') ?? false)
                    ? ' (Captain)'
                    : null),
            const SportoDivider(height: 1),
            SportoInfoRow(
                label: 'Non-Striker', value: _nonStriker?.split(' (')[0] ?? ''),
            const SportoDivider(height: 1),
            SportoInfoRow(
                label: 'Opening Bowler',
                value: _openingBowler?.split(' (')[0] ?? ''),
          ])),
      const SizedBox(height: 40),

      // Let's Begin Button
      PrimaryButton(
          width: double.infinity,
          height: 56,
          label: 'Let\'s Begin First Over',
          onPressed: () {
            // Navigate to Live Scoring Screen
          }),
    ]);
  }
}
