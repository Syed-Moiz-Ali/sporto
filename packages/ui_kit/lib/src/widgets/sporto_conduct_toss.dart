import 'package:flutter/material.dart';

import '../theme/sporto_design_tokens.dart';
import 'primary_button.dart';
import 'sporto_check_box.dart';

// ============================================================
// SHELL
// ============================================================

class SportoTossShell extends StatelessWidget {
  final Widget child;

  const SportoTossShell({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0E0C08),
      body: Stack(
        children: [
          const Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  stops: [
                    0,
                    .12,
                    .18,
                    .85,
                    1,
                  ],
                  colors: [
                    Color(0xFF131924),
                    Color(0xFF10141E),
                    Color(0xFF0E0C08),
                    Color(0xFF0E0C08),
                    Color(0xFF171718),
                  ],
                ),
              ),
            ),
          ),
          child,
        ],
      ),
    );
  }
}

// ============================================================
// HEADER + PROGRESS
// ============================================================

class SportoTossHeader extends StatelessWidget {
  final String title;
  final String matchId;

  /// 0, 1, 2
  final int currentStep;

  final VoidCallback? onBack;

  const SportoTossHeader({
    super.key,
    required this.title,
    required this.matchId,
    required this.currentStep,
    this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    final scale = context.sportoScale;
    final theme = Theme.of(context);

    return Column(
      children: [
        SizedBox(
          height: 36 * scale,
          child: Row(
            children: [
              Material(
                color: const Color(0xFF293141),
                borderRadius: BorderRadius.circular(
                  11 * scale,
                ),
                child: InkWell(
                  onTap: onBack,
                  borderRadius: BorderRadius.circular(
                    11 * scale,
                  ),
                  child: SizedBox(
                    width: 36 * scale,
                    height: 36 * scale,
                    child: Icon(
                      Icons.chevron_left_rounded,
                      size: 28 * scale,
                    ),
                  ),
                ),
              ),
              SizedBox(width: 10 * scale),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: theme.textTheme.headlineMedium?.copyWith(
                        fontSize: 18 * scale,
                        height: 1,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    SizedBox(
                      height: 4 * scale,
                    ),
                    Text(
                      'Match #$matchId',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurface,
                        fontSize: 11 * scale,
                        height: 1,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        // Screenshot:
        // header ends ~81
        // progress starts ~104
        SizedBox(height: 23 * scale),

        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            3,
            (index) {
              final active = index <= currentStep;

              return Padding(
                padding: EdgeInsets.only(
                  right: index == 2 ? 0 : 12 * scale,
                ),
                child: AnimatedContainer(
                  duration: const Duration(
                    milliseconds: 180,
                  ),
                  width: 50 * scale,
                  height: 4 * scale,
                  decoration: BoxDecoration(
                    color: active
                        ? Theme.of(context).colorScheme.tertiary
                        : const Color(
                            0xFF303847,
                          ),
                    borderRadius: BorderRadius.circular(
                      4 * scale,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

// ============================================================
// SMALL TEAM MATCH STRIP
// ============================================================

class SportoTossMatchStrip extends StatelessWidget {
  final String team1;
  final String team2;

  const SportoTossMatchStrip({
    super.key,
    required this.team1,
    required this.team2,
  });

  @override
  Widget build(BuildContext context) {
    final scale = context.sportoScale;
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Container(
      width: double.infinity,
      height: 46 * scale,
      padding: EdgeInsets.symmetric(
        horizontal: 14 * scale,
      ),
      decoration: BoxDecoration(
        color: context.sporto.cardElevated,
        borderRadius: BorderRadius.circular(
          12 * scale,
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              team1,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colors.onSurface,
                fontSize: 13 * scale,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Text(
            'Vs',
            style: theme.textTheme.bodySmall?.copyWith(
              color: colors.onSurfaceVariant,
              fontSize: 11 * scale,
            ),
          ),
          Expanded(
            child: Text(
              team2,
              textAlign: TextAlign.end,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colors.onSurface,
                fontSize: 13 * scale,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// COIN CARD
// ============================================================

class SportoTossCoinCard extends StatelessWidget {
  final String coinAsset;

  final bool isFlipping;

  final String? landedText;
  final String? winnerText;

  final String buttonText;

  final VoidCallback? onButtonPressed;

  const SportoTossCoinCard({
    super.key,
    required this.coinAsset,
    required this.buttonText,
    required this.onButtonPressed,
    this.isFlipping = false,
    this.landedText,
    this.winnerText,
  });

  bool get hasResult => landedText != null;

  @override
  Widget build(BuildContext context) {
    final scale = context.sportoScale;
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Container(
      width: double.infinity,
      height: (hasResult ? 431 : 336) * scale,
      padding: EdgeInsets.fromLTRB(
        20 * scale,
        28 * scale,
        20 * scale,
        29 * scale,
      ),
      decoration: BoxDecoration(
        color: context.sporto.cardElevated,
        borderRadius: BorderRadius.circular(
          20 * scale,
        ),
      ),
      child: Column(
        children: [
          SizedBox(
            width: 150 * scale,
            height: 150 * scale,
            child: _AnimatedCoin(
              asset: coinAsset,
              spinning: isFlipping,
            ),
          ),
          if (!hasResult) ...[
            const Spacer(),
            Text(
              isFlipping
                  ? 'Flipping coin...'
                  : 'Flip coin to decide who chooses first',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: colors.onSurfaceVariant,
                fontSize: 15 * scale,
                fontWeight: FontWeight.w500,
              ),
            ),
            const Spacer(),
          ],
          if (hasResult) ...[
            SizedBox(height: 24 * scale),
            Text(
              'Coin landed on',
              style: theme.textTheme.bodyLarge?.copyWith(
                color: colors.onSurfaceVariant,
                fontSize: 15 * scale,
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(height: 17 * scale),
            Text(
              landedText!,
              style: theme.textTheme.displaySmall?.copyWith(
                color: colors.tertiary,
                fontSize: 26 * scale,
                height: 1,
                fontWeight: FontWeight.w700,
              ),
            ),
            SizedBox(height: 20 * scale),
            if (winnerText != null)
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: 12 * scale,
                  vertical: 7 * scale,
                ),
                decoration: BoxDecoration(
                  color: context.sporto.assigned.withValues(
                    alpha: .10,
                  ),
                  borderRadius: BorderRadius.circular(
                    18 * scale,
                  ),
                ),
                child: Text(
                  winnerText!,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: context.sporto.assigned,
                    fontSize: 11 * scale,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            const Spacer(),
          ],
          PrimaryButton(
            width: 270 * scale,
            height: 49 * scale,
            radius: 14 * scale,
            label: buttonText,
            loading: isFlipping,
            disabled: isFlipping,
            onPressed: onButtonPressed,
          ),
        ],
      ),
    );
  }
}

// ============================================================
// COIN SPIN
// ============================================================

class _AnimatedCoin extends StatefulWidget {
  final String asset;
  final bool spinning;

  const _AnimatedCoin({
    required this.asset,
    required this.spinning,
  });

  @override
  State<_AnimatedCoin> createState() => _AnimatedCoinState();
}

class _AnimatedCoinState extends State<_AnimatedCoin>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(
        milliseconds: 450,
      ),
    );

    if (widget.spinning) {
      _controller.repeat();
    }
  }

  @override
  void didUpdateWidget(
    covariant _AnimatedCoin oldWidget,
  ) {
    super.didUpdateWidget(oldWidget);

    if (widget.spinning && !oldWidget.spinning) {
      _controller.repeat();
    }

    if (!widget.spinning && oldWidget.spinning) {
      _controller
        ..stop()
        ..reset();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RotationTransition(
      turns: _controller,
      child: Image.asset(
        widget.asset,
        fit: BoxFit.contain,
      ),
    );
  }
}

// ============================================================
// WINNER CARD
// ============================================================

class SportoTossWinnerCard extends StatelessWidget {
  final String winner;

  const SportoTossWinnerCard({
    super.key,
    required this.winner,
  });

  @override
  Widget build(BuildContext context) {
    final scale = context.sportoScale;
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      height: 68 * scale,
      padding: EdgeInsets.symmetric(
        horizontal: 14 * scale,
      ),
      decoration: BoxDecoration(
        color: context.sporto.cardElevated,
        borderRadius: BorderRadius.circular(
          13 * scale,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Toss Winner',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: context.sporto.assigned,
              fontSize: 13 * scale,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 7 * scale),
          Text(
            winner,
            style: theme.textTheme.titleLarge?.copyWith(
              color: theme.colorScheme.onSurface,
              fontSize: 16 * scale,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// CHOICE
// ============================================================

enum SportoTossChoice {
  bat,
  bowl,
}

class SportoTossChoicePanel extends StatelessWidget {
  final String winner;

  final SportoTossChoice? selected;

  final ValueChanged<SportoTossChoice> onSelected;

  /// Optional exact artwork.
  ///
  /// If null, Material icon fallback is used.
  final String? batAsset;
  final String? ballAsset;

  const SportoTossChoicePanel({
    super.key,
    required this.winner,
    required this.selected,
    required this.onSelected,
    this.batAsset,
    this.ballAsset,
  });

  @override
  Widget build(BuildContext context) {
    final scale = context.sportoScale;

    return Container(
      width: double.infinity,
      height: 201 * scale,
      padding: EdgeInsets.fromLTRB(
        14 * scale,
        14 * scale,
        14 * scale,
        14 * scale,
      ),
      decoration: BoxDecoration(
        color: context.sporto.cardElevated,
        borderRadius: BorderRadius.circular(
          13 * scale,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$winner chooses to',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: context.sporto.assigned,
                  fontSize: 15 * scale,
                  fontWeight: FontWeight.w600,
                ),
          ),
          SizedBox(height: 14 * scale),
          Expanded(
            child: Row(
              children: [
                Expanded(
                  child: _TossChoiceCard(
                    label: 'Bat First',
                    selected: selected == SportoTossChoice.bat,
                    icon: Icons.sports_cricket,
                    asset: batAsset,
                    onTap: () {
                      onSelected(
                        SportoTossChoice.bat,
                      );
                    },
                  ),
                ),
                SizedBox(width: 14 * scale),
                Expanded(
                  child: _TossChoiceCard(
                    label: 'Bowl First',
                    selected: selected == SportoTossChoice.bowl,
                    icon: Icons.sports_baseball,
                    asset: ballAsset,
                    onTap: () {
                      onSelected(
                        SportoTossChoice.bowl,
                      );
                    },
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

class _TossChoiceCard extends StatelessWidget {
  final String label;

  final bool selected;

  final IconData icon;

  final String? asset;

  final VoidCallback onTap;

  const _TossChoiceCard({
    required this.label,
    required this.selected,
    required this.icon,
    required this.asset,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final scale = context.sportoScale;
    final theme = Theme.of(context);

    return Material(
      color: selected ? const Color(0xFF243C49) : const Color(0xFF182130),
      borderRadius: BorderRadius.circular(
        15 * scale,
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(
          15 * scale,
        ),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(
              15 * scale,
            ),
            border: Border.all(
              color: selected
                  ? context.sporto.info
                  : const Color(
                      0xFF2C4C66,
                    ),
              width: 1,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 67 * scale,
                height: 67 * scale,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: const Color(
                    0xFFE6F0FF,
                  ),
                  borderRadius: BorderRadius.circular(
                    14 * scale,
                  ),
                  border: Border.all(
                    color: const Color(
                      0xFF9AC8F5,
                    ),
                    width: 2,
                  ),
                ),
                child: asset != null
                    ? Padding(
                        padding: EdgeInsets.all(
                          5 * scale,
                        ),
                        child: Image.asset(
                          asset!,
                          fit: BoxFit.contain,
                        ),
                      )
                    : Icon(
                        icon,
                        color: const Color(
                          0xFFB25D2E,
                        ),
                        size: 42 * scale,
                      ),
              ),
              SizedBox(height: 14 * scale),
              Text(
                label,
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: theme.colorScheme.onSurface,
                  fontSize: 14 * scale,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ============================================================
// BATTING / BOWLING STRIP
// ============================================================

class SportoTossRoleStrip extends StatelessWidget {
  final String battingTeam;
  final String bowlingTeam;

  const SportoTossRoleStrip({
    super.key,
    required this.battingTeam,
    required this.bowlingTeam,
  });

  @override
  Widget build(BuildContext context) {
    final scale = context.sportoScale;
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      height: 68 * scale,
      padding: EdgeInsets.symmetric(
        horizontal: 14 * scale,
      ),
      decoration: BoxDecoration(
        color: context.sporto.cardElevated,
        borderRadius: BorderRadius.circular(
          13 * scale,
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  battingTeam,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: context.sporto.assigned,
                    fontSize: 13 * scale,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 8 * scale),
                Text(
                  'Batting',
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: theme.colorScheme.onSurface,
                    fontSize: 15 * scale,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          Text(
            'Vs',
            style: theme.textTheme.bodySmall?.copyWith(
              fontSize: 11 * scale,
            ),
          ),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  bowlingTeam,
                  textAlign: TextAlign.end,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: context.sporto.assigned,
                    fontSize: 13 * scale,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 8 * scale),
                Text(
                  'Bowling',
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: theme.colorScheme.onSurface,
                    fontSize: 15 * scale,
                    fontWeight: FontWeight.w600,
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

// ============================================================
// PLAYER VIEW MODEL
// ============================================================

class SportoTossPlayerOption {
  final String id;
  final String name;

  final bool captain;
  final bool selected;
  final bool enabled;

  const SportoTossPlayerOption({
    required this.id,
    required this.name,
    this.captain = false,
    required this.selected,
    required this.enabled,
  });
}

// ============================================================
// PLAYER SELECTOR
// ============================================================

class SportoTossPlayerSelector extends StatelessWidget {
  final String title;
  final String? teamName;

  final List<SportoTossPlayerOption> players;

  final ValueChanged<String> onSelected;

  const SportoTossPlayerSelector({
    super.key,
    required this.title,
    this.teamName,
    required this.players,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    final scale = context.sportoScale;
    final theme = Theme.of(context);

    return ClipRRect(
      borderRadius: BorderRadius.circular(
        12 * scale,
      ),
      child: Column(
        children: [
          Container(
            width: double.infinity,
            height: 49 * scale,
            padding: EdgeInsets.symmetric(
              horizontal: 14 * scale,
            ),
            color: context.sporto.cardElevated,
            child: Row(
              children: [
                Text(
                  title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: context.sporto.info,
                    fontSize: 15 * scale,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (teamName != null) ...[
                  const Spacer(),
                  Text(
                    teamName!,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: theme.colorScheme.onSurface,
                      fontSize: 14 * scale,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ],
            ),
          ),
          SizedBox(height: 2 * scale),
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(
              horizontal: 14 * scale,
              vertical: 10 * scale,
            ),
            color: context.sporto.cardElevated,
            child: Column(
              children: players
                  .map(
                    (player) => _TossPlayerRow(
                      player: player,
                      onTap: () {
                        if (player.enabled) {
                          onSelected(
                            player.id,
                          );
                        }
                      },
                    ),
                  )
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }
}

class _TossPlayerRow extends StatelessWidget {
  final SportoTossPlayerOption player;

  final VoidCallback onTap;

  const _TossPlayerRow({
    required this.player,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final scale = context.sportoScale;
    final theme = Theme.of(context);

    return InkWell(
      onTap: player.enabled ? onTap : null,
      child: SizedBox(
        height: 32 * scale,
        child: Row(
          children: [
            SizedBox(
              width: 17 * scale,
              height: 17 * scale,
              child: FittedBox(
                child: SportoCheckBox(
                  checked: player.selected,
                ),
              ),
            ),
            SizedBox(width: 8 * scale),
            Expanded(
              child: Opacity(
                opacity: player.enabled ? 1 : .35,
                child: Text.rich(
                  TextSpan(
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: theme.colorScheme.onSurface,
                      fontSize: 13 * scale,
                      fontWeight: FontWeight.w500,
                    ),
                    children: [
                      TextSpan(
                        text: player.name,
                      ),
                      if (player.captain)
                        TextSpan(
                          text: ' (Captain)',
                          style: TextStyle(
                            color: theme.colorScheme.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================
// EXACT FLOW BUTTON
// ============================================================

class SportoTossPrimaryButton extends StatelessWidget {
  final String text;

  final bool disabled;

  final VoidCallback? onTap;

  const SportoTossPrimaryButton({
    super.key,
    required this.text,
    this.disabled = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final scale = context.sportoScale;

    return Center(
      child: PrimaryButton(
        width: 270 * scale,
        height: 49 * scale,
        radius: 14 * scale,
        label: text,
        disabled: disabled,
        onPressed: onTap,
      ),
    );
  }
}
