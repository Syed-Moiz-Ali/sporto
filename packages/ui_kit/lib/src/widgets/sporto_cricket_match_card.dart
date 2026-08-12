import 'package:flutter/material.dart';

import '../theme/sporto_design_tokens.dart';

enum SportoCricketMatchState {
  live,
  upcoming,
  completed,
  delayed,
}

class SportoCricketMatchCard extends StatelessWidget {
  final SportoCricketMatchState state;

  const SportoCricketMatchCard({
    super.key,
    required this.state,
  });

  @override
  Widget build(BuildContext context) {
    final sporto = context.sporto;

    final isLive = state == SportoCricketMatchState.live;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: isLive ? null : sporto.cardElevated,
        gradient: isLive
            ? LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  sporto.liveCardStart,
                  sporto.liveCardEnd,
                ],
              )
            : null,
        borderRadius: BorderRadius.circular(16),
        border: isLive
            ? Border.all(
                color: const Color(0xFF7B2A16).withValues(
                  alpha: .72,
                ),
                width: 1,
              )
            : null,
        boxShadow: isLive
            ? const [
                BoxShadow(
                  color: Color(0x24000000),
                  blurRadius: 18,
                  offset: Offset(0, 6),
                ),
              ]
            : null,
      ),
      child: switch (state) {
        SportoCricketMatchState.live => _live(context),
        SportoCricketMatchState.upcoming => _upcoming(context),
        SportoCricketMatchState.completed => _completed(context),
        SportoCricketMatchState.delayed => _delayed(context),
      },
    );
  }

  // ==========================================================
  // LIVE
  // ==========================================================

  Widget _live(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final sporto = context.sporto;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            _badge(
              context,
              'Final',
              sporto.assigned,
              filled: true,
              solidFill: true,
            ),
            const SizedBox(width: 6),
            _liveBadge(context),
            const Spacer(),
            _badge(
              context,
              'Over - 2.1',
              cs.onSurface,
              filled: true,
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          'Jaipur Super Over',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: cs.tertiary,
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
        ),
        _location(context),
        const SizedBox(height: 7),
        _teams(
          context,
          left: 'Thunder Titans',
          leftScore: '28/1',
          right: 'Royal Strikers',
          rightScore: 'Yet to Bat',
        ),
        const SizedBox(height: 7),
        const _DottedDivider(),
        const SizedBox(height: 7),
        Row(
          children: [
            Expanded(
              child: _inlineMetric(
                context,
                'Current Batter',
                'Rahul',
              ),
            ),
            Expanded(
              child: _inlineMetric(
                context,
                'Current Bowler',
                'Amit',
                alignRight: true,
              ),
            ),
          ],
        ),
        const SizedBox(height: 7),
        const _DottedDivider(),
        const SizedBox(height: 7),
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            _stackedMetric(
              context,
              'Duration',
              '08:25',
            ),
            const Spacer(),
            _action(
              context,
              'Continue Scoring',
              sporto.actionOrange,
              134,
            ),
          ],
        ),
      ],
    );
  }

  // ==========================================================
  // UPCOMING
  // ==========================================================

  Widget _upcoming(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final sporto = context.sporto;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _header(
          context,
          'Quarter Final',
          'Today, 06:30 PM',
          'Upcoming',
          sporto.assigned,
          sporto.upcoming,
        ),
        const SizedBox(height: 7),
        _titleAndLocation(context),
        const SizedBox(height: 8),
        _teams(
          context,
          left: 'Delhi Warriors',
          right: 'Hyd Highlanders',
        ),
        const SizedBox(height: 10),
        FittedBox(
          fit: BoxFit.scaleDown,
          alignment: Alignment.centerLeft,
          child: Row(
            children: [
              _status(
                context,
                'Teams Verified',
                sporto.assigned,
              ),
              _separator(context),
              _status(
                context,
                'Ground Ready',
                sporto.assigned,
              ),
              _separator(context),
              _status(
                context,
                'Toss Pending',
                cs.tertiary,
                warning: true,
              ),
            ],
          ),
        ),
        const SizedBox(height: 7),
        const _DottedDivider(),
        const SizedBox(height: 7),
        Row(
          children: [
            Expanded(
              child: _richFooter(
                context,
                'Starts in ',
                '24 mins',
              ),
            ),
            _action(
              context,
              'Verify Teams',
              sporto.info,
              108,
              foreground: const Color(0xFF08121A),
            ),
          ],
        ),
      ],
    );
  }

  // ==========================================================
  // COMPLETED
  // ==========================================================

  Widget _completed(BuildContext context) {
    final sporto = context.sporto;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _header(
          context,
          'Final',
          'Today, 10:30 AM',
          'Completed',
          sporto.assigned,
          sporto.info,
        ),
        const SizedBox(height: 7),
        _titleAndLocation(context),
        const SizedBox(height: 8),
        _teams(
          context,
          left: 'Delhi Warriors',
          leftScore: '90/2',
          right: 'Hyd Highlanders',
          rightScore: '85/3',
          leftScoreColor: sporto.assigned,
        ),
        const SizedBox(height: 8),
        const _DottedDivider(),
        const SizedBox(height: 7),
        Row(
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: sporto.assigned,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 5),
            Expanded(
              child: Text(
                'Delhi Warriors Won',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: sporto.assigned,
                      fontWeight: FontWeight.w700,
                    ),
              ),
            ),
            _action(
              context,
              'View Report',
              const Color(0xFF262D3A),
              102,
              foreground: Theme.of(context).colorScheme.onSurface,
            ),
          ],
        ),
      ],
    );
  }

  // ==========================================================
  // DELAYED
  // ==========================================================

  Widget _delayed(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final sporto = context.sporto;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _header(
          context,
          'Final',
          'Today, 08:30 PM',
          'Delayed',
          sporto.assigned,
          cs.tertiary,
          warning: true,
        ),
        const SizedBox(height: 5),
        Row(
          children: [
            Container(
              width: 7,
              height: 7,
              decoration: BoxDecoration(
                color: cs.error,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 5),
            Text(
              'Heavy Rain',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: cs.error,
                    fontWeight: FontWeight.w700,
                  ),
            ),
          ],
        ),
        const SizedBox(height: 7),
        _titleAndLocation(context),
        const SizedBox(height: 8),
        _teams(
          context,
          left: 'Thunder Titans',
          leftScore: '28/1',
          right: 'Royal Strikers',
          rightScore: 'Yet to Bat',
        ),
        const SizedBox(height: 8),
        const _DottedDivider(),
        const SizedBox(height: 7),
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            _stackedMetric(
              context,
              'Resume Time',
              '4:00 PM',
            ),
            const Spacer(),
            _action(
              context,
              'Update Status',
              cs.tertiary,
              115,
              filled: false,
            ),
          ],
        ),
      ],
    );
  }

  // ==========================================================
  // COMMON
  // ==========================================================

  Widget _header(
    BuildContext context,
    String stage,
    String time,
    String status,
    Color stageColor,
    Color statusColor, {
    bool warning = false,
  }) {
    return Row(
      children: [
        _badge(
          context,
          stage,
          stageColor,
        ),
        const Spacer(),
        Text(
          time,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context)
                    .colorScheme
                    .onSurfaceVariant
                    .withValues(alpha: .9),
                fontSize: 12,
              ),
        ),
        const Spacer(),
        _badge(
          context,
          status,
          statusColor,
          filled: true,
          warning: warning,
        ),
      ],
    );
  }

  Widget _titleAndLocation(
    BuildContext context,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Asia Cup 2026',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
        ),
        _location(context),
      ],
    );
  }

  Widget _location(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Row(
      children: [
        Icon(
          Icons.location_on_outlined,
          size: 13,
          color: cs.onSurfaceVariant,
        ),
        const SizedBox(width: 3),
        Text(
          'Hyderabad',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: cs.onSurfaceVariant,
                fontSize: 12,
              ),
        ),
      ],
    );
  }

  Widget _teams(
    BuildContext context, {
    required String left,
    String? leftScore,
    required String right,
    String? rightScore,
    Color? leftScoreColor,
  }) {
    final cs = Theme.of(context).colorScheme;

    Widget team(
      String name,
      String? score,
      CrossAxisAlignment alignment,
      Color? scoreColor,
    ) {
      return Expanded(
        child: Column(
          crossAxisAlignment: alignment,
          children: [
            Text(
              name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: cs.onSurfaceVariant,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
            ),
            if (score != null)
              Text(
                score,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: scoreColor ?? cs.onSurface,
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
              ),
          ],
        ),
      );
    }

    return Row(
      children: [
        team(
          left,
          leftScore,
          CrossAxisAlignment.start,
          leftScoreColor,
        ),
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 8,
          ),
          child: Text(
            'Vs',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontSize: 12,
                ),
          ),
        ),
        team(
          right,
          rightScore,
          CrossAxisAlignment.end,
          null,
        ),
      ],
    );
  }

  Widget _inlineMetric(
    BuildContext context,
    String label,
    String value, {
    bool alignRight = false,
  }) {
    return RichText(
      textAlign: alignRight ? TextAlign.end : TextAlign.start,
      text: TextSpan(
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
              fontSize: 12,
            ),
        children: [
          TextSpan(
            text: '$label  ',
          ),
          TextSpan(
            text: value,
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurface,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _stackedMetric(
    BuildContext context,
    String label,
    String value,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                fontSize: 12,
              ),
        ),
        Text(
          value,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontSize: 14,
                fontWeight: FontWeight.w700,
              ),
        ),
      ],
    );
  }

  Widget _richFooter(
    BuildContext context,
    String label,
    String value,
  ) {
    return RichText(
      text: TextSpan(
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurface,
              fontSize: 13,
            ),
        children: [
          TextSpan(
            text: label,
          ),
          TextSpan(
            text: value,
            style: TextStyle(
              color: context.sporto.assigned,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _status(
    BuildContext context,
    String label,
    Color color, {
    bool warning = false,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          warning ? Icons.warning_amber_rounded : Icons.check_rounded,
          color: color,
          size: 13,
        ),
        const SizedBox(width: 2),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: color,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
        ),
      ],
    );
  }

  Widget _separator(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 8,
      ),
      child: Text(
        '•',
        style: Theme.of(context).textTheme.bodySmall,
      ),
    );
  }

  // ==========================================================
  // BADGES
  // ==========================================================

  Widget _liveBadge(BuildContext context) {
    final live = context.sporto.live;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 7,
        vertical: 3,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFFF5EEE9),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: live,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 4),
          Text(
            'Live Now',
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: live,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                ),
          ),
        ],
      ),
    );
  }

  Widget _badge(
    BuildContext context,
    String text,
    Color color, {
    bool filled = false,
    bool solidFill = false,
    bool warning = false,
  }) {
    final background = solidFill
        ? color
        : filled
            ? color.withValues(alpha: .14)
            : Colors.transparent;

    final foreground = solidFill ? Colors.white : color;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 7,
        vertical: 3,
      ),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(8),
        border: filled || solidFill
            ? null
            : Border.all(
                color: color,
              ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (warning) ...[
            Icon(
              Icons.warning_amber_rounded,
              color: foreground,
              size: 12,
            ),
            const SizedBox(width: 2),
          ],
          Text(
            text,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: foreground,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
          ),
        ],
      ),
    );
  }

  // ==========================================================
  // BUTTON
  // ==========================================================

  Widget _action(
    BuildContext context,
    String label,
    Color color,
    double width, {
    bool filled = true,
    Color? foreground,
  }) {
    final fg = foreground ?? (filled ? Colors.white : color);

    return Material(
      color: filled
          ? color
          : color.withValues(
              alpha: .13,
            ),
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        onTap: () {},
        borderRadius: BorderRadius.circular(10),
        child: Container(
          width: width,
          height: 30,
          alignment: Alignment.center,
          decoration: filled
              ? null
              : BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: color.withValues(
                      alpha: .24,
                    ),
                  ),
                ),
          child: Text(
            label,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: fg,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
          ),
        ),
      ),
    );
  }
}

// ============================================================
// DOTTED DIVIDER
// ============================================================

class _DottedDivider extends StatelessWidget {
  const _DottedDivider();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 1,
      child: CustomPaint(
        painter: _DottedDividerPainter(
          Theme.of(context).colorScheme.outline.withValues(
                alpha: .7,
              ),
        ),
      ),
    );
  }
}

class _DottedDividerPainter extends CustomPainter {
  final Color color;

  const _DottedDividerPainter(
    this.color,
  );

  @override
  void paint(
    Canvas canvas,
    Size size,
  ) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1;

    for (double x = 0; x < size.width; x += 6) {
      canvas.drawLine(
        Offset(x, 0),
        Offset(
          (x + 2)
              .clamp(
                0,
                size.width,
              )
              .toDouble(),
          0,
        ),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(
    covariant _DottedDividerPainter oldDelegate,
  ) {
    return oldDelegate.color != color;
  }
}
