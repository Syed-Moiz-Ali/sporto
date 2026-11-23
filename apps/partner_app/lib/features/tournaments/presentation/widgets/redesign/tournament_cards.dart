import 'package:flutter/material.dart';
import 'package:ui_kit/ui_kit.dart';

import 'tournament_visuals.dart';

/// Badge fill from the export: the status gradient at ~6 % over the card.
Gradient? _fadedGradient(Gradient? gradient, {double alpha = .06}) {
  if (gradient is LinearGradient) {
    return LinearGradient(
      begin: gradient.begin,
      end: gradient.end,
      stops: gradient.stops,
      colors: [for (final c in gradient.colors) c.withValues(alpha: alpha)],
    );
  }
  return gradient;
}

String tournamentInitials(String name) {
  final words =
      name.trim().split(RegExp(r'\s+')).where((w) => w.isNotEmpty).toList();
  if (words.length >= 2) {
    return (words[0][0] + words[1][0]).toUpperCase();
  }
  return name.isNotEmpty
      ? name.substring(0, name.length.clamp(0, 2)).toUpperCase()
      : '--';
}

class TournamentAvatar extends StatelessWidget {
  const TournamentAvatar({
    super.key,
    required this.label,
    this.size = 56,
    this.color,
    this.background,
    this.radius,
    this.fontSize,
    this.showBorder = true,
  });

  final String label;
  final double size;
  final Color? color;
  final Color? background;
  final double? radius;
  final double? fontSize;
  final bool showBorder;

  @override
  Widget build(BuildContext context) {
    final t = context.sportoTournament;
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        gradient: background == null
            ? LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  (color ?? t.green).withValues(alpha: .20),
                  (color ?? t.green).withValues(alpha: .06),
                ],
              )
            : null,
        color: background,
        borderRadius: BorderRadius.circular(radius ?? t.r11),
        border: showBorder
            ? Border.all(color: (color ?? t.green).withValues(alpha: .25))
            : null,
      ),
      alignment: Alignment.center,
      child: Text(
        label,
        style: SportoTextStyles.text(
          size: fontSize ?? size * .38,
          weight: FontWeight.w700,
          color: color ?? t.greenBright,
          height: 1,
        ),
      ),
    );
  }
}

class LiveTournamentCard extends StatelessWidget {
  const LiveTournamentCard({
    super.key,
    required this.name,
    required this.venue,
    required this.code,
    required this.dateText,
    this.teamsText = '0/0 Teams',
    this.slotsText = '0 slots left',
    this.refereeText,
    this.upcoming = '0',
    this.live = '0',
    this.completed = '0',
    this.onOpen,
    this.onMonitor,
    this.width,
  });

  final String name;
  final String venue;
  final String code;
  final String dateText;
  final String teamsText;
  final String slotsText;
  final String? refereeText;
  final String upcoming;
  final String live;
  final String completed;
  final VoidCallback? onOpen;
  final VoidCallback? onMonitor;
  final double? width;

  @override
  Widget build(BuildContext context) {
    final t = context.sportoTournament;
    return TournamentSurface(
      width: width,
      gradient: t.liveCardGradient,
      borderGradient: t.liveCardBorderGradient,
      radius: t.r11,
      shadow: t.liveGlow,
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Flexible(
                fit: FlexFit.loose,
                child: TournamentStatusChip(
                  label: 'Live Now',
                  color: t.live,
                  background: t.live.withValues(alpha: .12),
                  border: t.live.withValues(alpha: .35),
                  dot: true,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  code,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: SportoTextStyles.text(
                    size: SportoTextStyles.size11,
                    color: t.muted,
                  ),
                ),
              ),
              Flexible(
                child: Text(
                  dateText,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.right,
                  style: SportoTextStyles.text(
                    size: SportoTextStyles.size12,
                    color: t.warm,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: SportoTextStyles.text(
              size: SportoTextStyles.size18,
              weight: FontWeight.w700,
              color: t.white,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Icon(Icons.location_on_outlined, size: 15, color: t.muted),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  venue,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: SportoTextStyles.text(
                    size: SportoTextStyles.size13,
                    color: t.muted,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          TournamentDivider(color: t.live.withValues(alpha: .25)),
          const SizedBox(height: 10),
          Row(
            children: [
              Text.rich(
                TextSpan(
                  children: [
                    TextSpan(
                      text: teamsText,
                      style: SportoTextStyles.text(
                        size: SportoTextStyles.size14,
                        weight: FontWeight.w600,
                        color: t.white,
                      ),
                    ),
                    TextSpan(
                      text: '  •  $slotsText',
                      style: SportoTextStyles.text(
                        size: SportoTextStyles.size12,
                        color: t.muted,
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              if (refereeText != null)
                Text(
                  refereeText!,
                  style: SportoTextStyles.text(
                    size: SportoTextStyles.size12,
                    color: t.live,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(
              color: t.screenBase.withValues(alpha: .38),
              borderRadius: BorderRadius.circular(t.r9),
              border: Border.all(color: t.live.withValues(alpha: .20)),
            ),
            child: Row(
              children: [
                _LiveStat(value: upcoming, label: 'Upcoming'),
                _verticalDivider(t),
                _LiveStat(value: live, label: 'Live', color: t.live),
                _verticalDivider(t),
                _LiveStat(value: completed, label: 'Completed', color: t.green),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: TournamentActionPill(
                  label: 'Open Tournament',
                  background: t.screenBase.withValues(alpha: .35),
                  foreground: t.blue,
                  border: t.border,
                  onTap: onOpen,
                  height: 38,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: TournamentActionPill(
                  label: 'Monitor',
                  gradient: t.goldPillGradient,
                  foreground: t.screenBase,
                  onTap: onMonitor,
                  height: 38,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _verticalDivider(SportoTournamentTokens t) => Container(
        width: 1,
        height: 28,
        color: t.live.withValues(alpha: .25),
      );
}

class _LiveStat extends StatelessWidget {
  const _LiveStat({
    required this.value,
    required this.label,
    this.color,
  });

  final String value;
  final String label;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final t = context.sportoTournament;
    return Expanded(
      child: Column(
        children: [
          Text(
            value,
            style: SportoTextStyles.text(
              size: SportoTextStyles.size15,
              weight: FontWeight.w700,
              color: color ?? t.white,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            label,
            style: SportoTextStyles.text(
              size: SportoTextStyles.size11,
              color: t.muted,
            ),
          ),
        ],
      ),
    );
  }
}

class TournamentListCard extends StatelessWidget {
  const TournamentListCard({
    super.key,
    required this.name,
    required this.sport,
    required this.venue,
    required this.statusLabel,
    required this.statusColor,
    this.statusGradient,
    this.code,
    this.dateText,
    this.location,
    this.dateRange,
    this.registrationOpen = false,
    this.teamsRegistered,
    this.maxTeams,
    this.slotsLeft,
    this.matchesScheduled,
    this.progress,
    this.champions,
    this.noteTitle,
    this.noteText,
    this.noteColor,
    this.submittedText,
    this.actionLabel,
    this.actionIcon,
    this.onAction,
    this.onTap,
    this.onEdit,
    this.secondaryActionLabel,
    this.onSecondaryAction,
    this.avatarColor,
    this.avatarBackground,
    this.entryFee,
    this.prize,
  });

  final String name;
  final String sport;
  final String venue;
  final String statusLabel;
  final Color statusColor;

  /// Gradient of the status badge (export paints each state with its own).
  final Gradient? statusGradient;
  final String? code;
  final String? dateText;
  final String? location;
  final String? dateRange;
  final bool registrationOpen;
  final int? teamsRegistered;
  final int? maxTeams;
  final int? slotsLeft;
  final int? matchesScheduled;
  final double? progress;
  final String? champions;
  final String? noteTitle;
  final String? noteText;
  final Color? noteColor;
  final String? submittedText;
  final String? actionLabel;
  final Widget? actionIcon;
  final VoidCallback? onAction;
  final VoidCallback? onTap;

  /// Renders the `Edit` pill of the draft / under-review / rejected states.
  final VoidCallback? onEdit;
  final String? secondaryActionLabel;
  final VoidCallback? onSecondaryAction;
  final Color? avatarColor;
  final Color? avatarBackground;
  final String? entryFee;
  final String? prize;

  bool get _hasProgress => teamsRegistered != null && maxTeams != null;
  bool get _hasMeta => dateRange != null || entryFee != null || prize != null;

  @override
  Widget build(BuildContext context) {
    final t = context.sportoTournament;
    final meta = <String>[
      if (dateRange != null) dateRange!,
      if (entryFee != null) entryFee!,
      if (prize != null) prize!,
    ];

    return TournamentSurface(
      radius: t.r16,
      padding: const EdgeInsets.all(10),
      color: t.card,
      showBorder: false,
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Status row: badge · code · date (export 23 px high).
          LayoutBuilder(
            builder: (context, constraints) {
              return ConstrainedBox(
                constraints: const BoxConstraints(minHeight: 23),
                child: Row(
                  children: [
                    ConstrainedBox(
                      constraints: BoxConstraints(
                        maxWidth: constraints.maxWidth * .48,
                      ),
                      child: TournamentStatusChip(
                        label: statusLabel,
                        color: statusColor,
                        gradient: _fadedGradient(statusGradient),
                        textGradient: statusGradient,
                        height: 23,
                        fontSize: SportoTextStyles.size12,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Flexible(
                            child: Text(
                              code ?? '',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: SportoTextStyles.text(
                                size: SportoTextStyles.size10,
                                weight: FontWeight.w500,
                                color: t.dim,
                              ),
                            ),
                          ),
                          if (dateText != null) ...[
                            const SizedBox(width: 8),
                            Flexible(
                              child: Text(
                                dateText!,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                textAlign: TextAlign.right,
                                style: SportoTextStyles.text(
                                  size: SportoTextStyles.size10,
                                  weight: FontWeight.w500,
                                  color: t.muted,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
          // Fade divider present on the registration and rejected variants.
          if (_hasProgress || _hasMeta) ...[
            const SizedBox(height: 8),
            TournamentDivider(
              height: .8,
              gradient: LinearGradient(
                colors: [
                  t.dim.withValues(alpha: 0),
                  t.dim.withValues(alpha: .3),
                  t.dim.withValues(alpha: 0),
                ],
                stops: const [0, .5, 1],
              ),
            ),
          ],
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TournamentAvatar(
                label: tournamentInitials(name),
                size: 50,
                radius: t.r10,
                color: avatarColor ?? t.greenDeep,
                background:
                    avatarBackground ?? t.greenDeep.withValues(alpha: .10),
                fontSize: SportoTextStyles.size24,
                showBorder: false,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: SportoTextStyles.text(
                        size: SportoTextStyles.size14,
                        weight: FontWeight.w600,
                        color: t.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Text(
                          sport,
                          style: SportoTextStyles.text(
                            size: SportoTextStyles.size12,
                            weight: FontWeight.w600,
                            color: t.gold,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Container(
                          width: 3,
                          height: 3,
                          decoration: BoxDecoration(
                            color: t.dim,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            venue,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: SportoTextStyles.text(
                              size: SportoTextStyles.size12,
                              weight: FontWeight.w500,
                              color: t.muted,
                            ),
                          ),
                        ),
                      ],
                    ),
                    if (location != null && location!.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          SizedBox(
                            width: 16,
                            height: 16,
                            child: Center(
                              child: SportoSvgIcon(
                                SportoTournamentIcons.mapPin,
                                width: 10,
                                height: 11,
                                color: t.muted,
                              ),
                            ),
                          ),
                          const SizedBox(width: 2),
                          Expanded(
                            child: Text(
                              location!,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: SportoTextStyles.text(
                                size: SportoTextStyles.size12,
                                weight: FontWeight.w500,
                                color: t.muted,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          if (_hasProgress) ...[
            const SizedBox(height: 8),
            _ProgressBlock(
              registrationOpen: registrationOpen,
              teamsRegistered: teamsRegistered!,
              maxTeams: maxTeams!,
              slotsLeft: slotsLeft,
              matchesScheduled: matchesScheduled,
              progress: progress,
            ),
          ],
          if (!_hasProgress && meta.isNotEmpty) ...[
            const SizedBox(height: 8),
            TournamentMetaStrip(items: meta),
          ],
          if (!_hasProgress && noteText != null) ...[
            const SizedBox(height: 8),
            TournamentDivider(
              height: .8,
              gradient: LinearGradient(
                colors: [
                  t.dim.withValues(alpha: 0),
                  t.dim.withValues(alpha: .3),
                  t.dim.withValues(alpha: 0),
                ],
                stops: const [0, .5, 1],
              ),
            ),
            const SizedBox(height: 8),
            TournamentCardNote(
              title: noteTitle,
              message: noteText!,
              color: noteColor,
              onEdit: onEdit,
            ),
          ] else if (!_hasProgress && submittedText != null) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: Text(
                    submittedText!,
                    style: SportoTextStyles.text(
                      size: SportoTextStyles.size10,
                      color: t.warm.withValues(alpha: .98),
                    ),
                  ),
                ),
                if (onEdit != null) _EditPill(onTap: onEdit!),
              ],
            ),
          ] else if (!_hasProgress && onEdit != null) ...[
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerRight,
              child: _EditPill(onTap: onEdit!),
            ),
          ],
          if (champions != null) ...[
            const SizedBox(height: 8),
            TournamentChampionTicket(champion: champions!),
          ],
          if (actionLabel != null || secondaryActionLabel != null) ...[
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (secondaryActionLabel != null) ...[
                  Expanded(
                    child: TournamentActionPill(
                      label: secondaryActionLabel!,
                      background: t.cardAlt,
                      foreground: t.blue,
                      border: t.border,
                      onTap: onSecondaryAction,
                      height: 34,
                    ),
                  ),
                  const SizedBox(width: 10),
                ],
                if (actionLabel != null)
                  TournamentActionPill(
                    label: actionLabel!,
                    icon: actionIcon,
                    background: t.cardAlt,
                    foreground: statusColor,
                    border: statusColor.withValues(alpha: .35),
                    onTap: onAction,
                    height: 34,
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

/// Registration block of the tournament list card: status + ratio + track.
class _ProgressBlock extends StatelessWidget {
  const _ProgressBlock({
    required this.registrationOpen,
    required this.teamsRegistered,
    required this.maxTeams,
    this.slotsLeft,
    this.matchesScheduled,
    this.progress,
  });

  final bool registrationOpen;
  final int teamsRegistered;
  final int maxTeams;
  final int? slotsLeft;
  final int? matchesScheduled;
  final double? progress;

  @override
  Widget build(BuildContext context) {
    final t = context.sportoTournament;
    final ratio = progress ??
        (maxTeams == 0 ? 0.0 : teamsRegistered / maxTeams).clamp(0.0, 1.0);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Flexible(
              child: Text(
                registrationOpen ? 'Registration Open' : 'Teams Registered',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: SportoTextStyles.text(
                  size: SportoTextStyles.size10,
                  weight: FontWeight.w500,
                  color: registrationOpen ? t.green : t.muted,
                ),
              ),
            ),
            const SizedBox(width: 8),
            const Spacer(),
            Flexible(
              child: Text.rich(
                TextSpan(
                  children: [
                    TextSpan(
                      text: '$teamsRegistered/$maxTeams',
                      style: SportoTextStyles.text(
                        size: SportoTextStyles.size10,
                        weight: FontWeight.w600,
                        color: t.white,
                      ),
                    ),
                    TextSpan(
                      text: ' Teams Registered',
                      style: SportoTextStyles.text(
                        size: SportoTextStyles.size10,
                        weight: FontWeight.w500,
                        color: t.muted,
                      ),
                    ),
                  ],
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.right,
              ),
            ),
          ],
        ),
        const SizedBox(height: 3),
        TournamentProgressTrack(
          value: ratio,
          radius: t.r10,
          color: registrationOpen ? t.green : t.completed,
        ),
        const SizedBox(height: 3),
        Row(
          children: [
            if (matchesScheduled != null)
              Text(
                '$matchesScheduled matches scheduled',
                style: SportoTextStyles.text(
                  size: SportoTextStyles.size10,
                  weight: FontWeight.w600,
                  color: t.muted.withValues(alpha: .98),
                ),
              ),
            const Spacer(),
            if (slotsLeft != null)
              Text(
                '$slotsLeft slots left',
                style: SportoTextStyles.text(
                  size: SportoTextStyles.size10,
                  weight: FontWeight.w600,
                  color: t.muted.withValues(alpha: .98),
                ),
              ),
          ],
        ),
      ],
    );
  }
}

/// `Edit` action of the draft / under-review / rejected cards.
class _EditPill extends StatelessWidget {
  const _EditPill({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final t = context.sportoTournament;
    return TournamentActionPill(
      label: 'Edit',
      onTap: onTap,
      background: t.screenBase.withValues(alpha: .50),
      foreground: t.blue,
      radius: t.r10,
      height: 31,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      icon: SportoSvgIcon(SportoTournamentIcons.edit, size: 14),
    );
  }
}

/// `date · ₹entry · ₹prize` strip under the card identity row.
class TournamentMetaStrip extends StatelessWidget {
  const TournamentMetaStrip({super.key, required this.items});

  final List<String> items;

  @override
  Widget build(BuildContext context) {
    final t = context.sportoTournament;
    return ConstrainedBox(
      constraints: const BoxConstraints(minHeight: 13),
      child: Wrap(
        crossAxisAlignment: WrapCrossAlignment.center,
        spacing: 6,
        runSpacing: 2,
        children: [
          for (var i = 0; i < items.length; i++) ...[
            if (i > 0)
              Container(
                width: 2,
                height: 2,
                decoration: BoxDecoration(
                  color: t.muted,
                  shape: BoxShape.circle,
                ),
              ),
            Text(
              items[i],
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: SportoTextStyles.text(
                size: SportoTextStyles.size10,
                color: t.white,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Inline admin note with the optional `Edit` action (rejected/review states).
class TournamentCardNote extends StatelessWidget {
  const TournamentCardNote({
    super.key,
    required this.message,
    this.title,
    this.color,
    this.onEdit,
  });

  final String? title;
  final String message;
  final Color? color;
  final VoidCallback? onEdit;

  @override
  Widget build(BuildContext context) {
    final t = context.sportoTournament;
    final c = color ?? t.red;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (title != null) ...[
                Text(
                  title!,
                  style: SportoTextStyles.text(
                    size: SportoTextStyles.size11,
                    weight: FontWeight.w500,
                    color: c.withValues(alpha: .98),
                  ),
                ),
                const SizedBox(height: 2),
              ],
              Text(
                message,
                style: SportoTextStyles.text(
                  size: title == null
                      ? SportoTextStyles.size12
                      : SportoTextStyles.size10,
                  color: (title == null ? c : t.white).withValues(alpha: .98),
                ),
              ),
            ],
          ),
        ),
        if (onEdit != null) ...[
          const SizedBox(width: 4),
          _EditPill(onTap: onEdit!),
        ],
      ],
    );
  }
}

/// `Champions — <team>` ticket of the completed card (export 32 px high).
class TournamentChampionTicket extends StatelessWidget {
  const TournamentChampionTicket({
    super.key,
    required this.champion,
    this.label = 'Champions',
  });

  final String champion;
  final String label;

  @override
  Widget build(BuildContext context) {
    final t = context.sportoTournament;
    return ClipRRect(
      borderRadius: BorderRadius.circular(t.r10),
      child: SizedBox(
        height: 32,
        child: Stack(
          children: [
            Positioned.fill(
              child: ColoredBox(color: t.red.withValues(alpha: .06)),
            ),
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      const Color(0xFF173824),
                      const Color(0xFF0E2418).withValues(alpha: .7),
                    ],
                    stops: const [0, .7],
                  ),
                ),
              ),
            ),
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    center: const Alignment(-.35, -.6),
                    radius: .9,
                    colors: [
                      t.gold.withValues(alpha: .18),
                      t.gold.withValues(alpha: 0),
                    ],
                    stops: const [0, .5],
                  ),
                ),
              ),
            ),
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    center: const Alignment(-.35, -.6),
                    radius: 1,
                    colors: [
                      t.red.withValues(alpha: .35),
                      t.red.withValues(alpha: 0),
                    ],
                    stops: const [0, .55],
                  ),
                  border: Border.all(
                    color: t.warm.withValues(alpha: .04),
                    width: .8,
                  ),
                  borderRadius: BorderRadius.circular(t.r10),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              child: Row(
                children: [
                  SportoSvgIcon(
                    SportoTournamentIcons.medal,
                    width: 17,
                    height: 17,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    label,
                    style: SportoTextStyles.text(
                      size: SportoTextStyles.size12,
                      weight: FontWeight.w500,
                      color: t.gold,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    champion,
                    style: SportoTextStyles.text(
                      size: SportoTextStyles.size12,
                      weight: FontWeight.w600,
                      color: t.white,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class TournamentLiveMatchCard extends StatelessWidget {
  const TournamentLiveMatchCard({
    super.key,
    required this.teamA,
    required this.teamB,
    required this.scoreA,
    required this.scoreB,
    required this.venue,
    required this.roundText,
    required this.dateText,
    this.referee,
    this.onScorecard,
    this.onManage,
    this.badgeText = 'Live Now',
    this.badgeColor,
    this.winnerA = false,
    this.winnerB = false,
  });

  final String teamA;
  final String teamB;
  final String scoreA;
  final String scoreB;
  final String venue;
  final String roundText;
  final String dateText;
  final String? referee;
  final VoidCallback? onScorecard;
  final VoidCallback? onManage;
  final String badgeText;
  final Color? badgeColor;
  final bool winnerA;
  final bool winnerB;

  @override
  Widget build(BuildContext context) {
    final t = context.sportoTournament;
    final color = badgeColor ?? t.live;
    return TournamentSurface(
      radius: t.r11,
      padding: const EdgeInsets.all(12),
      borderColor: color.withValues(alpha: .22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              TournamentStatusChip(
                label: badgeText,
                color: color,
                background: color.withValues(alpha: .10),
                border: color.withValues(alpha: .26),
                dot: badgeText.toLowerCase().contains('live'),
              ),
              const SizedBox(width: 8),
              Text(
                roundText,
                style: SportoTextStyles.text(
                  size: SportoTextStyles.size11,
                  color: t.muted,
                ),
              ),
              const Spacer(),
              Text(
                dateText,
                style: SportoTextStyles.text(
                  size: SportoTextStyles.size11,
                  color: t.muted,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Icon(Icons.location_on_outlined, size: 13, color: t.green),
              const SizedBox(width: 3),
              Expanded(
                child: Text(
                  venue,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: SportoTextStyles.text(
                    size: SportoTextStyles.size12,
                    color: t.green,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _team(
                  context,
                  teamA,
                  scoreA,
                  winner: winnerA,
                  alignEnd: false,
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Text(
                  'Vs',
                  style: SportoTextStyles.text(
                    size: SportoTextStyles.size12,
                    color: t.muted,
                  ),
                ),
              ),
              Expanded(
                child: _team(
                  context,
                  teamB,
                  scoreB,
                  winner: winnerB,
                  alignEnd: true,
                ),
              ),
            ],
          ),
          if (referee != null) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                Text(
                  'Referee',
                  style: SportoTextStyles.text(
                    size: SportoTextStyles.size12,
                    color: t.muted,
                  ),
                ),
                const Spacer(),
                Text(
                  referee!,
                  style: SportoTextStyles.text(
                    size: SportoTextStyles.size12,
                    weight: FontWeight.w600,
                    color: t.blue,
                  ),
                ),
              ],
            ),
          ],
          if (onScorecard != null || onManage != null) ...[
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (onManage != null)
                  TournamentActionPill(
                    label: 'Manage',
                    background: t.completed.withValues(alpha: .14),
                    foreground: t.completed,
                    border: t.completed.withValues(alpha: .3),
                    onTap: onManage,
                    height: 32,
                  ),
                if (onManage != null && onScorecard != null)
                  const SizedBox(width: 8),
                if (onScorecard != null)
                  TournamentActionPill(
                    label: 'Scorecard',
                    icon: Icon(Icons.visibility_outlined,
                        size: 14, color: t.blue),
                    background: t.cardAlt,
                    foreground: t.blue,
                    border: t.border,
                    onTap: onScorecard,
                    height: 32,
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _team(
    BuildContext context,
    String name,
    String score, {
    required bool winner,
    required bool alignEnd,
  }) {
    final t = context.sportoTournament;
    return Column(
      crossAxisAlignment:
          alignEnd ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment:
              alignEnd ? MainAxisAlignment.end : MainAxisAlignment.start,
          children: [
            if (winner && !alignEnd) ...[
              Icon(Icons.emoji_events_rounded, size: 14, color: t.gold),
              const SizedBox(width: 4),
            ],
            Flexible(
              child: Text(
                name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: alignEnd ? TextAlign.right : TextAlign.left,
                style: SportoTextStyles.text(
                  size: SportoTextStyles.size14,
                  weight: FontWeight.w600,
                  color: winner ? t.gold : t.white,
                ),
              ),
            ),
            if (winner && alignEnd) ...[
              const SizedBox(width: 4),
              Icon(Icons.emoji_events_rounded, size: 14, color: t.gold),
            ],
          ],
        ),
        const SizedBox(height: 2),
        Text(
          score,
          style: SportoTextStyles.text(
            size: SportoTextStyles.size12,
            color: winner ? t.gold : t.muted,
          ),
        ),
      ],
    );
  }
}

class TournamentMatchCard extends StatelessWidget {
  const TournamentMatchCard({
    super.key,
    required this.roundText,
    required this.matchCode,
    required this.dateText,
    required this.teamA,
    required this.teamB,
    this.scoreA,
    this.scoreB,
    this.venue,
    this.resultText,
    this.referee,
    this.statusLabel = 'Scheduled',
    this.statusColor,
    this.onScorecard,
    this.onReferee,
    this.refereeActionLabel = 'Change Referee',
  });

  final String roundText;
  final String matchCode;
  final String dateText;
  final String teamA;
  final String teamB;
  final String? scoreA;
  final String? scoreB;
  final String? venue;
  final String? resultText;
  final String? referee;
  final String statusLabel;
  final Color? statusColor;
  final VoidCallback? onScorecard;
  final VoidCallback? onReferee;
  final String refereeActionLabel;

  @override
  Widget build(BuildContext context) {
    final t = context.sportoTournament;
    final color = statusColor ?? t.completed;
    return TournamentSurface(
      radius: t.r11,
      padding: const EdgeInsets.all(12),
      borderColor: color.withValues(alpha: .20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Flexible(
                child: Text(
                  roundText,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: SportoTextStyles.text(
                    size: SportoTextStyles.size12,
                    color: color,
                  ),
                ),
              ),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  '• $matchCode',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: SportoTextStyles.text(
                    size: SportoTextStyles.size10,
                    color: t.dim,
                  ),
                ),
              ),
              const Spacer(),
              Text(
                dateText,
                maxLines: 1,
                style: SportoTextStyles.text(
                  size: SportoTextStyles.size11,
                  color: t.muted,
                ),
              ),
            ],
          ),
          if (venue != null) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.location_on_outlined, size: 13, color: t.green),
                const SizedBox(width: 3),
                Expanded(
                  child: Text(
                    venue!,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: SportoTextStyles.text(
                      size: SportoTextStyles.size12,
                      color: t.green,
                    ),
                  ),
                ),
              ],
            ),
          ],
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: Text(
                  teamA,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: SportoTextStyles.text(
                    size: SportoTextStyles.size15,
                    weight: FontWeight.w600,
                    color: (scoreA ?? '').isNotEmpty ? t.gold : t.white,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Text(
                  'Vs',
                  style: SportoTextStyles.text(
                    size: SportoTextStyles.size12,
                    color: t.muted,
                  ),
                ),
              ),
              Expanded(
                child: Text(
                  teamB,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.right,
                  style: SportoTextStyles.text(
                    size: SportoTextStyles.size15,
                    weight: FontWeight.w600,
                    color: (scoreB ?? '').isNotEmpty ? t.gold : t.white,
                  ),
                ),
              ),
            ],
          ),
          if (scoreA != null || scoreB != null) ...[
            const SizedBox(height: 2),
            Row(
              children: [
                Text(
                  scoreA ?? '',
                  style: SportoTextStyles.text(
                    size: SportoTextStyles.size12,
                    color: t.muted,
                  ),
                ),
                const Spacer(),
                Text(
                  scoreB ?? '',
                  style: SportoTextStyles.text(
                    size: SportoTextStyles.size12,
                    color: t.muted,
                  ),
                ),
              ],
            ),
          ],
          if (resultText != null) ...[
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: Text(
                    resultText!,
                    style: SportoTextStyles.text(
                      size: SportoTextStyles.size12,
                      color: t.muted,
                    ),
                  ),
                ),
                if (onScorecard != null)
                  TournamentActionPill(
                    label: 'View Scorecard',
                    icon: Icon(Icons.visibility_outlined,
                        size: 14, color: t.blue),
                    background: t.cardAlt,
                    foreground: t.blue,
                    border: t.border,
                    onTap: onScorecard,
                    height: 32,
                  ),
              ],
            ),
          ] else ...[
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Flexible(
                        child: referee == null
                            ? Text(
                                'No Referee yet',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: SportoTextStyles.text(
                                  size: SportoTextStyles.size12,
                                  color: t.live,
                                ),
                              )
                            : Text.rich(
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                TextSpan(
                                  children: [
                                    TextSpan(
                                      text: 'Referee\n',
                                      style: SportoTextStyles.text(
                                        size: SportoTextStyles.size11,
                                        color: t.muted,
                                      ),
                                    ),
                                    TextSpan(
                                      text: referee!,
                                      style: SportoTextStyles.text(
                                        size: SportoTextStyles.size12,
                                        weight: FontWeight.w600,
                                        color: t.pink,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                      ),
                    ],
                  ),
                ),
                if (onReferee != null)
                  TournamentActionPill(
                    label: refereeActionLabel,
                    background: t.gold.withValues(alpha: .12),
                    foreground: t.gold,
                    border: t.gold.withValues(alpha: .3),
                    onTap: onReferee,
                    height: 32,
                  ),
                if (onScorecard != null) ...[
                  const SizedBox(width: 8),
                  TournamentActionPill(
                    label: 'Scorecard',
                    icon: Icon(Icons.visibility_outlined,
                        size: 14, color: t.blue),
                    background: t.cardAlt,
                    foreground: t.blue,
                    border: t.border,
                    onTap: onScorecard,
                    height: 32,
                  ),
                ],
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class TournamentTeamRankCard extends StatelessWidget {
  const TournamentTeamRankCard({
    super.key,
    required this.rank,
    required this.name,
    required this.captain,
    required this.played,
    required this.wins,
    required this.prizes,
    this.rankLabel,
    this.rankColor,
    this.onView,
  });

  final int rank;
  final String name;
  final String captain;
  final String played;
  final String wins;
  final String prizes;
  final String? rankLabel;
  final Color? rankColor;
  final VoidCallback? onView;

  @override
  Widget build(BuildContext context) {
    final t = context.sportoTournament;
    final color = rankColor ?? t.gold;
    return TournamentSurface(
      radius: t.r11,
      padding: const EdgeInsets.all(12),
      color: t.cardAlt,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                '#$rank Team',
                style: SportoTextStyles.text(
                  size: SportoTextStyles.size13,
                  color: t.muted,
                ),
              ),
              const Spacer(),
              if (rankLabel != null) ...[
                Icon(
                  rank == 1
                      ? Icons.emoji_events_rounded
                      : Icons.military_tech_rounded,
                  size: 16,
                  color: color,
                ),
                const SizedBox(width: 4),
                Text(
                  rankLabel!,
                  style: SportoTextStyles.text(
                    size: SportoTextStyles.size13,
                    color: color,
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              TournamentAvatar(
                label: tournamentInitials(name),
                size: 50,
                color: rank == 1 ? t.gold : t.green,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: SportoTextStyles.text(
                        size: SportoTextStyles.size16,
                        weight: FontWeight.w600,
                        color: t.white,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Captain: $captain',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: SportoTextStyles.text(
                        size: SportoTextStyles.size12,
                        color: t.blue,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(
                        text: played,
                        style: SportoTextStyles.text(
                          size: SportoTextStyles.size12,
                          weight: FontWeight.w600,
                          color: t.pink,
                        ),
                      ),
                      TextSpan(
                        text: ' Played  ·  ',
                        style: SportoTextStyles.text(
                          size: SportoTextStyles.size12,
                          color: t.muted,
                        ),
                      ),
                      TextSpan(
                        text: wins,
                        style: SportoTextStyles.text(
                          size: SportoTextStyles.size12,
                          weight: FontWeight.w600,
                          color: t.green,
                        ),
                      ),
                      TextSpan(
                        text: ' Win  ·  ',
                        style: SportoTextStyles.text(
                          size: SportoTextStyles.size12,
                          color: t.muted,
                        ),
                      ),
                      TextSpan(
                        text: prizes,
                        style: SportoTextStyles.text(
                          size: SportoTextStyles.size12,
                          weight: FontWeight.w600,
                          color: t.gold,
                        ),
                      ),
                      TextSpan(
                        text: ' Prizes',
                        style: SportoTextStyles.text(
                          size: SportoTextStyles.size12,
                          color: t.muted,
                        ),
                      ),
                    ],
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (onView != null)
                TournamentActionPill(
                  label: 'View Team',
                  icon:
                      Icon(Icons.visibility_outlined, size: 14, color: t.blue),
                  background: t.card,
                  foreground: t.blue,
                  border: t.border,
                  onTap: onView,
                  height: 32,
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class TournamentLeaderboardRow extends StatelessWidget {
  const TournamentLeaderboardRow({
    super.key,
    required this.rank,
    required this.name,
    required this.subtitle,
    required this.value,
    this.onTap,
    this.rankColor,
  });

  final int rank;
  final String name;
  final String subtitle;
  final String value;
  final VoidCallback? onTap;
  final Color? rankColor;

  @override
  Widget build(BuildContext context) {
    final t = context.sportoTournament;
    final color = rankColor ??
        (rank == 1
            ? t.gold
            : rank == 2
                ? t.green
                : rank == 3
                    ? t.orange
                    : t.dim);
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        decoration: BoxDecoration(
          color: t.cardAlt,
          borderRadius: BorderRadius.circular(t.r9),
          border: Border.all(color: t.border),
        ),
        child: Row(
          children: [
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: color.withValues(alpha: .08),
                borderRadius: BorderRadius.circular(t.r6),
                border: Border.all(color: color.withValues(alpha: .55)),
              ),
              alignment: Alignment.center,
              child: Text(
                '$rank',
                style: SportoTextStyles.text(
                  size: SportoTextStyles.size12,
                  weight: FontWeight.w700,
                  color: color,
                ),
              ),
            ),
            const SizedBox(width: 10),
            TournamentAvatar(
              label: tournamentInitials(name),
              size: 38,
              color: rank == 1 ? t.gold : t.green,
              radius: t.r6,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: SportoTextStyles.text(
                      size: SportoTextStyles.size15,
                      weight: FontWeight.w600,
                      color: t.white,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: SportoTextStyles.text(
                      size: SportoTextStyles.size12,
                      color: t.muted,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Text(
              value,
              style: SportoTextStyles.text(
                size: SportoTextStyles.size16,
                weight: FontWeight.w700,
                color: t.white,
              ),
            ),
            const SizedBox(width: 4),
            Icon(Icons.chevron_right_rounded, size: 18, color: t.blue),
          ],
        ),
      ),
    );
  }
}

class TournamentTransactionRow extends StatelessWidget {
  const TournamentTransactionRow({
    super.key,
    required this.title,
    required this.dateText,
    required this.code,
    required this.amount,
    this.amountColor,
    this.positive = true,
    this.subtitle,
  });

  final String title;
  final String dateText;
  final String code;
  final String amount;
  final Color? amountColor;
  final bool positive;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    final t = context.sportoTournament;
    final color = amountColor ?? (positive ? t.green : t.red);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: t.cardAlt,
        borderRadius: BorderRadius.circular(t.r9),
        border: Border.all(color: t.border),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: SportoTextStyles.text(
                    size: SportoTextStyles.size14,
                    color: t.warm,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  subtitle ?? code,
                  style: SportoTextStyles.text(
                    size: SportoTextStyles.size11,
                    color: t.dim,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                dateText,
                style: SportoTextStyles.text(
                  size: SportoTextStyles.size11,
                  color: t.muted,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                amount,
                style: SportoTextStyles.text(
                  size: SportoTextStyles.size14,
                  weight: FontWeight.w600,
                  color: color,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class TournamentVenueCard extends StatelessWidget {
  const TournamentVenueCard({
    super.key,
    required this.index,
    required this.roundText,
    required this.matchesText,
    required this.name,
    required this.location,
    required this.groundType,
    required this.matchDate,
    required this.startTime,
    this.onEdit,
  });

  final int index;
  final String roundText;
  final String matchesText;
  final String name;
  final String location;
  final String groundType;
  final String matchDate;
  final String startTime;
  final VoidCallback? onEdit;

  @override
  Widget build(BuildContext context) {
    final t = context.sportoTournament;
    final scale = context.sportoScale;
    final fade = LinearGradient(
      colors: [
        t.dim.withValues(alpha: 0),
        t.dim.withValues(alpha: .3),
        t.dim.withValues(alpha: 0),
      ],
      stops: const [0, .5, 1],
    );
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(10 * scale),
      decoration: BoxDecoration(
        color: t.border.withValues(alpha: .30),
        borderRadius: BorderRadius.circular(t.r12),
        boxShadow: t.softCardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Venue $index',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: SportoTextStyles.text(
                    size: SportoTextStyles.size14,
                    color: t.blue,
                  ),
                ),
              ),
              if (onEdit != null)
                GestureDetector(
                  onTap: onEdit,
                  behavior: HitTestBehavior.opaque,
                  child: Row(
                    children: [
                      Text(
                        'Edit',
                        style: SportoTextStyles.text(
                          size: SportoTextStyles.size11,
                          color: t.blue,
                        ),
                      ),
                      const SizedBox(width: 2),
                      SportoSvgIcon(
                        SportoHomeRedesignIcons.arrowRight,
                        width: 11,
                        height: 7,
                        color: t.blue,
                      ),
                    ],
                  ),
                ),
            ],
          ),
          if (roundText.isNotEmpty) ...[
            SizedBox(height: 2 * scale),
            Text(
              matchesText.isEmpty
                  ? roundText
                  : '$roundText  ·  $matchesText',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: SportoTextStyles.text(
                size: SportoTextStyles.size12,
                weight: FontWeight.w500,
                color: t.muted,
              ),
            ),
          ],
          SizedBox(height: 8 * scale),
          TournamentDivider(height: .8, gradient: fade),
          SizedBox(height: 8 * scale),
          Text(
            name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: SportoTextStyles.text(
              size: SportoTextStyles.size14,
              weight: FontWeight.w500,
              color: t.white,
            ),
          ),
          SizedBox(height: 2 * scale),
          Row(
            children: [
              SportoSvgIcon(
                SportoTournamentIcons.mapPin,
                width: 10,
                height: 11,
                color: t.green,
              ),
              SizedBox(width: 4 * scale),
              Expanded(
                child: Text(
                  location,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: SportoTextStyles.text(
                    size: SportoTextStyles.size12,
                    weight: FontWeight.w500,
                    color: t.green,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 8 * scale),
          TournamentDivider(height: .8, gradient: fade),
          SizedBox(height: 8 * scale),
          _VenueInfoRow(label: 'Ground Type', value: groundType),
          SizedBox(height: 4 * scale),
          _VenueInfoRow(label: 'Match Date', value: matchDate),
          SizedBox(height: 4 * scale),
          _VenueInfoRow(label: 'Start Time', value: startTime),
        ],
      ),
    );
  }
}

class _VenueInfoRow extends StatelessWidget {
  const _VenueInfoRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final t = context.sportoTournament;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Flexible(
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: SportoTextStyles.text(
              size: SportoTextStyles.size14,
              color: t.muted,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Flexible(
          child: Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.right,
            style: SportoTextStyles.text(
              size: SportoTextStyles.size14,
              color: t.muted,
            ),
          ),
        ),
      ],
    );
  }
}

class TournamentPrizeRow extends StatelessWidget {
  const TournamentPrizeRow({
    super.key,
    required this.rank,
    required this.label,
    required this.amount,
    this.rankColor,
    this.mutedRank = false,
  });

  final String rank;
  final String label;
  final String amount;
  final Color? rankColor;
  final bool mutedRank;

  @override
  Widget build(BuildContext context) {
    final t = context.sportoTournament;
    final Gradient? grad = switch (rank) {
      '1' => t.goldPillGradient,
      '2' => t.greenPillGradient,
      '3' => t.orangePillGradient,
      _ => null,
    };
    final highlighted = grad != null && !mutedRank;
    final rankStyle = SportoTextStyles.text(
      size: highlighted ? SportoTextStyles.size10 : SportoTextStyles.size11,
      weight: highlighted ? FontWeight.w600 : FontWeight.w700,
      color: highlighted ? t.white : t.muted,
    );
    final rankText = Text(rank, style: rankStyle);
    final amountText = Text(
      amount,
      style: SportoTextStyles.text(
        size: SportoTextStyles.size12,
        color: highlighted ? t.white : t.white,
      ),
    );

    return Container(
      constraints: const BoxConstraints(minHeight: 31),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: Row(
          children: [
            Container(
              width: 18,
              height: 18,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(t.r6),
                border: GradientBorder.all(
                  gradient: highlighted
                      ? grad
                      : LinearGradient(
                          colors: [
                            (rankColor ?? t.warm).withValues(alpha: .2),
                            (rankColor ?? t.warm).withValues(alpha: .2),
                          ],
                        ),
                  width: .6,
                  radius: t.r6,
                ),
              ),
              alignment: Alignment.center,
              child: highlighted
                  ? ShaderMask(
                      blendMode: BlendMode.srcIn,
                      shaderCallback: (rect) => grad.createShader(rect),
                      child: rankText,
                    )
                  : rankText,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: SportoTextStyles.text(
                  size: SportoTextStyles.size12,
                  color: highlighted ? t.white : t.muted,
                ),
              ),
            ),
            if (highlighted)
              ShaderMask(
                blendMode: BlendMode.srcIn,
                shaderCallback: (rect) => t.goldPillGradient.createShader(rect),
                child: amountText,
              )
            else
              amountText,
          ],
        ),
      ),
    );
  }
}

