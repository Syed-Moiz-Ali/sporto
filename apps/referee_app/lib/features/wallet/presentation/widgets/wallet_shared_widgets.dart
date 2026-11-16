import 'package:flutter/material.dart';
import 'package:ui_kit/ui_kit.dart';

import '../wallet_adapters.dart';
import '../wallet_icons.dart';

/// Renders a formatted money string with the Figma's lighter rupee symbol.
///
/// The symbol keeps [symbolStyle] (e.g. Quicksand Regular) while the grouped
/// digits keep [amountStyle] (e.g. Quicksand Bold), matching the Figma text
/// segments for the balance and stat cards.
class WalletMoneyText extends StatelessWidget {
  final String formatted;
  final TextStyle symbolStyle;
  final TextStyle amountStyle;
  final TextAlign textAlign;
  final int? maxLines;

  const WalletMoneyText(
    this.formatted, {
    super.key,
    required this.symbolStyle,
    required this.amountStyle,
    this.textAlign = TextAlign.start,
    this.maxLines,
  });

  @override
  Widget build(BuildContext context) {
    final spaceIndex = formatted.indexOf(' ');
    final symbol =
        spaceIndex == -1 ? '' : formatted.substring(0, spaceIndex + 1);
    final amount =
        spaceIndex == -1 ? formatted : formatted.substring(spaceIndex + 1);

    return Text.rich(
      TextSpan(
        children: [
          if (symbol.isNotEmpty) TextSpan(text: symbol, style: symbolStyle),
          TextSpan(text: amount, style: amountStyle),
        ],
      ),
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: maxLines == null ? TextOverflow.clip : TextOverflow.ellipsis,
    );
  }
}

// ---------------------------------------------------------------------------
// Reusable wallet chrome
// ---------------------------------------------------------------------------

/// Sticky page header used by all four wallet screens.
class WalletScreenHeader extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback? onBack;
  final bool showDivider;

  const WalletScreenHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.trailing,
    this.onBack,
    this.showDivider = true,
  });

  @override
  Widget build(BuildContext context) {
    final scale = context.sportoScale;
    final tokens = context.sporto;
    final hasSubtitle = subtitle != null && subtitle!.isNotEmpty;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: tokens.canvas,
        border: showDivider
            ? Border(
                bottom: BorderSide(
                  color: tokens.border.withValues(alpha: 0.55),
                  width: 1,
                ),
              )
            : null,
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16 * scale),
        child: SizedBox(
          height: (hasSubtitle ? 48 : 44) * scale,
          child: Row(
            children: [
              WalletCircleIconButton(
                semanticLabel: 'Back',
                onTap: onBack ?? () => Navigator.of(context).pop(),
                child: SportoSvgIcon(
                  WalletIcons.back,
                  width: 12 * scale,
                  height: 16 * scale,
                ),
              ),
              SizedBox(width: 6 * scale),
              Expanded(
                child: hasSubtitle
                    ? Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 18 * scale,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                              height: 1.2,
                            ),
                          ),
                          SizedBox(height: 2 * scale),
                          Text(
                            subtitle!,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 12 * scale,
                              fontWeight: FontWeight.w500,
                              color: tokens.muted,
                              height: 1.2,
                            ),
                          ),
                        ],
                      )
                    : Text(
                        title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 18 * scale,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                          height: 1.2,
                        ),
                      ),
              ),
              if (trailing != null) ...[
                SizedBox(width: 8 * scale),
                trailing!,
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// 44 px touch target around a 36 px rounded-square glass button.
class WalletCircleIconButton extends StatelessWidget {
  final String semanticLabel;
  final VoidCallback onTap;
  final Widget child;

  const WalletCircleIconButton({
    super.key,
    required this.semanticLabel,
    required this.onTap,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final scale = context.sportoScale;
    final tokens = context.sporto;
    return Semantics(
      button: true,
      label: semanticLabel,
      child: SizedBox(
        width: 44 * scale,
        height: 44 * scale,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(22 * scale),
            child: Center(
              child: Container(
                width: 36 * scale,
                height: 36 * scale,
                decoration: BoxDecoration(
                  color: tokens.cardElevated,
                  borderRadius: BorderRadius.circular(10 * scale),
                ),
                alignment: Alignment.center,
                child: child,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Small header pill ("Create", "Add bank", "Withdraw").
class WalletPill extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;
  final Gradient? gradient;
  final Color? background;
  final Color? borderColor;
  final Color textColor;
  final Widget? leading;

  /// Visual pill height (the tap target is always 44 px).
  final double height;
  final EdgeInsetsGeometry? padding;
  final double fontSize;
  final FontWeight fontWeight;

  const WalletPill({
    super.key,
    required this.label,
    this.onTap,
    this.gradient,
    this.background,
    this.borderColor,
    this.textColor = Colors.white,
    this.leading,
    this.height = 27,
    this.padding,
    this.fontSize = 12,
    this.fontWeight = FontWeight.w600,
  });

  @override
  Widget build(BuildContext context) {
    final scale = context.sportoScale;
    return Semantics(
      button: onTap != null,
      label: label,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(10 * scale),
          child: SizedBox(
            height: 44 * scale,
            child: Center(
              child: Container(
                height: height * scale,
                padding:
                    padding ?? EdgeInsets.symmetric(horizontal: 10 * scale),
                decoration: BoxDecoration(
                  color: background,
                  gradient: gradient,
                  borderRadius: BorderRadius.circular(10 * scale),
                  border: borderColor == null
                      ? null
                      : Border.all(color: borderColor!, width: 1),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (leading != null) ...[
                      leading!,
                      SizedBox(width: 4 * scale),
                    ],
                    Text(
                      label,
                      maxLines: 1,
                      style: TextStyle(
                        fontSize: fontSize * scale,
                        fontWeight: fontWeight,
                        color: textColor,
                        height: 1.2,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Filter / tab chip (Tournaments History + Wallet transaction tabs).
class WalletFilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  final double fontSize;
  final FontWeight selectedWeight;
  final FontWeight unselectedWeight;

  const WalletFilterChip({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
    this.fontSize = 12,
    this.selectedWeight = FontWeight.w500,
    this.unselectedWeight = FontWeight.w500,
  });

  @override
  Widget build(BuildContext context) {
    final scale = context.sportoScale;
    final tokens = context.sporto;
    return Semantics(
      button: true,
      selected: selected,
      label: label,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(30 * scale),
          child: SizedBox(
            height: 44 * scale,
            child: Center(
              child: Container(
                height: 26 * scale,
                padding: EdgeInsets.symmetric(horizontal: 10 * scale),
                decoration: BoxDecoration(
                  color: selected ? tokens.gold : tokens.cardElevated,
                  borderRadius: BorderRadius.circular(30 * scale),
                ),
                alignment: Alignment.center,
                child: Text(
                  label,
                  maxLines: 1,
                  style: TextStyle(
                    fontSize: fontSize * scale,
                    fontWeight: selected ? selectedWeight : unselectedWeight,
                    color: selected ? const Color(0xFF0E0C08) : Colors.white,
                    height: 1.2,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Right-aligned sort control. Reverses the list order when tapped.
class WalletSortButton extends StatelessWidget {
  final VoidCallback onTap;

  const WalletSortButton({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final scale = context.sportoScale;
    return Semantics(
      button: true,
      label: 'Sort',
      child: SizedBox(
        width: 44 * scale,
        height: 44 * scale,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(22 * scale),
            child: Center(
              child: SportoSvgIcon(
                WalletIcons.sort,
                size: 24 * scale,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Gold "Local" / green "Approved" tournament badge.
class WalletBadge extends StatelessWidget {
  final String label;
  final Color color;

  const WalletBadge({super.key, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    final scale = context.sportoScale;
    return Container(
      height: 25 * scale,
      padding: EdgeInsets.symmetric(horizontal: 10 * scale),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(30 * scale),
      ),
      alignment: Alignment.center,
      child: Text(
        label,
        maxLines: 1,
        style: TextStyle(
          fontSize: 12 * scale,
          fontWeight: FontWeight.w500,
          color: color,
          height: 1.2,
        ),
      ),
    );
  }
}

/// Wallet ledger row backed exclusively by the API model.
///
/// Missing fields render `—`; nothing (party, method, status, direction) is
/// invented when the backend did not send it.
class WalletLedgerTile extends StatelessWidget {
  final WalletTransactionView transaction;
  final VoidCallback? onTap;

  const WalletLedgerTile({
    super.key,
    required this.transaction,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final scale = context.sportoScale;
    final tokens = context.sporto;
    final statusColor = _statusColor(transaction.statusLabel, tokens);
    final amountColor = switch (transaction.direction) {
      WalletLedgerDirection.credit => tokens.accentGreen,
      WalletLedgerDirection.debit => tokens.red,
      WalletLedgerDirection.unknown => tokens.muted,
    };
    final subtitle = transaction.displaySubtitle;

    return Semantics(
      button: onTap != null,
      label: transaction.semanticLabel,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(14 * scale),
          child: Container(
            width: double.infinity,
            padding: EdgeInsets.all(12 * scale),
            decoration: BoxDecoration(
              color: tokens.card,
              borderRadius: BorderRadius.circular(14 * scale),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        transaction.displayTitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 14 * scale,
                          fontWeight: FontWeight.w500,
                          color: Colors.white,
                          height: 1.25,
                        ),
                      ),
                      if (subtitle != null) ...[
                        SizedBox(height: 2 * scale),
                        Text(
                          subtitle,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 12 * scale,
                            fontWeight: FontWeight.w400,
                            color: tokens.muted,
                            height: 1.2,
                          ),
                        ),
                      ],
                      SizedBox(height: 2 * scale),
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              transaction.statusLabel,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 12 * scale,
                                fontWeight: FontWeight.w500,
                                color: statusColor,
                                height: 1.2,
                              ),
                            ),
                          ),
                          SizedBox(width: 6 * scale),
                          Container(
                            width: 2 * scale,
                            height: 2 * scale,
                            decoration: BoxDecoration(
                              color: tokens.textTertiary,
                              shape: BoxShape.circle,
                            ),
                          ),
                          SizedBox(width: 6 * scale),
                          Flexible(
                            child: Text(
                              transaction.dateLabel,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 12 * scale,
                                fontWeight: FontWeight.w400,
                                color: tokens.muted,
                                height: 1.2,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 8 * scale),
                Flexible(
                  child: Align(
                    alignment: Alignment.topRight,
                    child: WalletMoneyText(
                      transaction.amountLabel,
                      maxLines: 1,
                      textAlign: TextAlign.end,
                      symbolStyle: TextStyle(
                        fontSize: 14 * scale,
                        fontWeight: FontWeight.w400,
                        color: amountColor,
                        height: 1.25,
                      ),
                      amountStyle: TextStyle(
                        fontSize: 14 * scale,
                        fontWeight: FontWeight.w600,
                        color: amountColor,
                        height: 1.25,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

Color _statusColor(String label, SportoDesignTokens tokens) {
  return switch (walletStatusTone(label)) {
    WalletStatusTone.positive => tokens.accentGreen,
    WalletStatusTone.pending => tokens.gold,
    WalletStatusTone.negative => tokens.red,
    WalletStatusTone.neutral => tokens.muted,
  };
}

/// Honest empty state used when a list has no rows.
class WalletEmptyState extends StatelessWidget {
  final String message;

  const WalletEmptyState({
    super.key,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    final scale = context.sportoScale;
    final tokens = context.sporto;
    return Semantics(
      label: message,
      readOnly: true,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(
          horizontal: 20 * scale,
          vertical: 32 * scale,
        ),
        decoration: BoxDecoration(
          color: tokens.card,
          borderRadius: BorderRadius.circular(16 * scale),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.receipt_long_outlined,
              size: 32 * scale,
              color: tokens.muted,
            ),
            SizedBox(height: 10 * scale),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14 * scale,
                fontWeight: FontWeight.w500,
                color: tokens.muted,
                height: 1.3,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
