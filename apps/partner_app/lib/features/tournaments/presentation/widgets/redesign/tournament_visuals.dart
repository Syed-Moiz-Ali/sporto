import 'package:flutter/material.dart';
import 'package:ui_kit/ui_kit.dart';

/// Shared building blocks for the tournament redesign.
///
/// These widgets intentionally do not use the legacy glass widgets
/// (`SportoCard`, `SportoPillButton`, ...) because the new Figma tournament
/// surfaces use a different visual language. They consume the additive
/// [SportoTournamentTokens] from the theme instead.

class TournamentSurface extends StatelessWidget {
  const TournamentSurface({
    super.key,
    required this.child,
    this.padding = EdgeInsets.zero,
    this.radius,
    this.color,
    this.gradient,
    this.borderColor,
    this.borderGradient,
    this.borderWidth = 1,
    this.shadow,
    this.onTap,
    this.width,
    this.height,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final double? radius;
  final Color? color;
  final Gradient? gradient;
  final Color? borderColor;
  final Gradient? borderGradient;
  final double borderWidth;
  final List<BoxShadow>? shadow;
  final VoidCallback? onTap;
  final double? width;
  final double? height;

  @override
  Widget build(BuildContext context) {
    final t = context.sportoTournament;
    final resolvedRadius = radius ?? t.r11;
    final borderRadius = BorderRadius.circular(resolvedRadius);

    Widget body = Container(
      width: width,
      height: height,
      padding: padding,
      decoration: BoxDecoration(
        color: gradient == null ? (color ?? t.card) : null,
        gradient: gradient,
        borderRadius: borderRadius,
        border: borderGradient == null
            ? Border.all(color: borderColor ?? t.border, width: borderWidth)
            : null,
        boxShadow: shadow,
      ),
      child: child,
    );

    if (borderGradient != null) {
      body = Container(
        width: width,
        height: height,
        padding: EdgeInsets.all(borderWidth),
        decoration: BoxDecoration(
          gradient: borderGradient,
          borderRadius: borderRadius,
          boxShadow: shadow,
        ),
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            color: gradient == null ? (color ?? t.card) : null,
            gradient: gradient,
            borderRadius: BorderRadius.circular(resolvedRadius - borderWidth),
          ),
          child: child,
        ),
      );
    }

    if (onTap == null) return body;
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: body,
    );
  }
}

class TournamentStatusChip extends StatelessWidget {
  const TournamentStatusChip({
    super.key,
    required this.label,
    required this.color,
    this.background,
    this.border,
    this.dot = false,
    this.height,
    this.fontSize,
  });

  final String label;
  final Color color;
  final Color? background;
  final Color? border;
  final bool dot;
  final double? height;
  final double? fontSize;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      decoration: BoxDecoration(
        color: background ?? color.withValues(alpha: .10),
        borderRadius: BorderRadius.circular(100),
        border: Border.all(color: border ?? color.withValues(alpha: .28)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (dot) ...[
            Container(
              width: 7,
              height: 7,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            ),
            const SizedBox(width: 6),
          ],
          Text(
            label,
            style: SportoTextStyles.text(
              size: fontSize ?? SportoTextStyles.size12,
              weight: FontWeight.w600,
              color: color,
              height: 1.1,
            ),
          ),
        ],
      ),
    );
  }
}

class TournamentActionPill extends StatelessWidget {
  const TournamentActionPill({
    super.key,
    required this.label,
    this.onTap,
    this.gradient,
    this.background,
    this.foreground,
    this.border,
    this.icon,
    this.height = 36,
    this.padding = const EdgeInsets.symmetric(horizontal: 16),
    this.fontSize = SportoTextStyles.size12,
    this.radius,
    this.width,
  });

  final String label;
  final VoidCallback? onTap;
  final Gradient? gradient;
  final Color? background;
  final Color? foreground;
  final Color? border;
  final Widget? icon;
  final double height;
  final EdgeInsetsGeometry padding;
  final double fontSize;
  final double? radius;
  final double? width;

  @override
  Widget build(BuildContext context) {
    final t = context.sportoTournament;
    final fg = foreground ?? t.white;
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        width: width,
        height: height,
        padding: padding,
        decoration: BoxDecoration(
          gradient: gradient,
          color: gradient == null ? (background ?? t.cardElevated) : null,
          borderRadius: BorderRadius.circular(radius ?? t.r9),
          border: border == null ? null : Border.all(color: border!),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (icon != null) ...[icon!, const SizedBox(width: 6)],
            Flexible(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: SportoTextStyles.text(
                  size: fontSize,
                  weight: FontWeight.w600,
                  color: fg,
                  height: 1.1,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class TournamentIconButton extends StatelessWidget {
  const TournamentIconButton({
    super.key,
    required this.icon,
    this.onTap,
    this.size = 40,
    this.background,
    this.foreground,
    this.radius,
  });

  final Widget icon;
  final VoidCallback? onTap;
  final double size;
  final Color? background;
  final Color? foreground;
  final double? radius;

  @override
  Widget build(BuildContext context) {
    final t = context.sportoTournament;
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: background ?? t.cardElevated,
          borderRadius: BorderRadius.circular(radius ?? t.r11),
        ),
        alignment: Alignment.center,
        child: IconTheme(
          data: IconThemeData(color: foreground ?? t.white, size: size * .48),
          child: icon,
        ),
      ),
    );
  }
}

class TournamentSectionCard extends StatelessWidget {
  const TournamentSectionCard({
    super.key,
    required this.child,
    this.title,
    this.trailing,
    this.padding = const EdgeInsets.all(14),
    this.radius,
    this.color,
    this.gradient,
    this.borderColor,
    this.margin,
  });

  final Widget child;
  final String? title;
  final Widget? trailing;
  final EdgeInsetsGeometry padding;
  final double? radius;
  final Color? color;
  final Gradient? gradient;
  final Color? borderColor;
  final EdgeInsetsGeometry? margin;

  @override
  Widget build(BuildContext context) {
    final t = context.sportoTournament;
    final content = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (title != null) ...[
          Row(
            children: [
              Expanded(
                child: Text(
                  title!,
                  style: SportoTextStyles.text(
                    size: SportoTextStyles.size14,
                    weight: FontWeight.w500,
                    color: t.muted,
                  ),
                ),
              ),
              if (trailing != null) trailing!,
            ],
          ),
          const SizedBox(height: 12),
        ],
        child,
      ],
    );
    final card = TournamentSurface(
      radius: radius,
      color: color,
      gradient: gradient,
      borderColor: borderColor,
      padding: padding,
      child: content,
    );
    if (margin == null) return card;
    return Padding(padding: margin!, child: card);
  }
}

class TournamentInfoRow extends StatelessWidget {
  const TournamentInfoRow({
    super.key,
    required this.label,
    required this.value,
    this.labelColor,
    this.valueColor,
    this.boldValue = false,
    this.fontSize = SportoTextStyles.size13,
    this.padding = const EdgeInsets.symmetric(vertical: 6),
  });

  final String label;
  final String value;
  final Color? labelColor;
  final Color? valueColor;
  final bool boldValue;
  final double fontSize;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    final t = context.sportoTournament;
    return Padding(
      padding: padding,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Text(
              label,
              style: SportoTextStyles.text(
                size: fontSize,
                weight: FontWeight.w400,
                color: labelColor ?? t.muted,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: SportoTextStyles.text(
                size: fontSize,
                weight: boldValue ? FontWeight.w700 : FontWeight.w500,
                color: valueColor ?? t.warm,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class TournamentStatTile extends StatelessWidget {
  const TournamentStatTile({
    super.key,
    required this.value,
    required this.label,
    this.valueColor,
    this.labelColor,
    this.background,
    this.radius,
    this.padding = const EdgeInsets.symmetric(vertical: 10, horizontal: 6),
  });

  final String value;
  final String label;
  final Color? valueColor;
  final Color? labelColor;
  final Color? background;
  final double? radius;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    final t = context.sportoTournament;
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: background ?? t.card,
        borderRadius: BorderRadius.circular(radius ?? t.r6),
        border: Border.all(color: t.border),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: SportoTextStyles.text(
              size: SportoTextStyles.size16,
              weight: FontWeight.w700,
              color: valueColor ?? t.white,
              height: 1.1,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: SportoTextStyles.text(
              size: SportoTextStyles.size11,
              weight: FontWeight.w400,
              color: labelColor ?? t.muted,
              height: 1.1,
            ),
          ),
        ],
      ),
    );
  }
}

class TournamentSectionLabel extends StatelessWidget {
  const TournamentSectionLabel(this.label, {super.key, this.color});

  final String label;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final t = context.sportoTournament;
    return Text(
      label,
      style: SportoTextStyles.text(
        size: SportoTextStyles.size15,
        weight: FontWeight.w500,
        color: color ?? t.green,
      ),
    );
  }
}

class TournamentDivider extends StatelessWidget {
  const TournamentDivider({super.key, this.height = 1, this.color});

  final double height;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final t = context.sportoTournament;
    return Container(
      height: height,
      color: color ?? t.border.withValues(alpha: .7),
    );
  }
}
