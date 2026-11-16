import 'package:flutter/material.dart';
import 'package:ui_kit/ui_kit.dart';

import '../wallet_icons.dart';
import '../wallet_models.dart';

// ---------------------------------------------------------------------------
// Money formatting (pure, unit-testable)
// ---------------------------------------------------------------------------

/// Formats [rupees] using the Indian digit grouping (1,20,400 / 3,800).
///
/// The default renders `₹ 1,20,400`; pass `space: false` for Figma variants
/// such as `+₹1,000` and `₹1000`.
String formatIndianRupees(
  int rupees, {
  bool space = true,
  bool grouping = true,
}) {
  final negative = rupees < 0;
  final digits = rupees.abs().toString();
  final grouped = grouping ? _groupIndianDigits(digits) : digits;
  final symbol = space ? '₹ ' : '₹';
  return '${negative ? '-' : ''}$symbol$grouped';
}

/// Compact Indian money label used by the Total Earnings card (`₹ 8.40L`).
String formatIndianCompactRupees(int rupees) {
  final negative = rupees < 0;
  final value = rupees.abs();
  final sign = negative ? '-' : '';
  if (value >= 10000000) {
    return '₹ $sign${(value / 10000000).toStringAsFixed(2)}Cr';
  }
  if (value >= 100000) {
    return '₹ $sign${(value / 100000).toStringAsFixed(2)}L';
  }
  return formatIndianRupees(rupees);
}

String _groupIndianDigits(String digits) {
  if (digits.length <= 3) return digits;
  final lastThree = digits.substring(digits.length - 3);
  var rest = digits.substring(0, digits.length - 3);
  final groups = <String>[];
  while (rest.length > 2) {
    groups.insert(0, rest.substring(rest.length - 2));
    rest = rest.substring(0, rest.length - 2);
  }
  if (rest.isNotEmpty) groups.insert(0, rest);
  return '${groups.join(',')},$lastThree';
}

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

/// Gradient "by User" / "by Partner" chip on transaction rows.
class WalletPartyChip extends StatelessWidget {
  final WalletTransactionParty party;

  const WalletPartyChip({super.key, required this.party});

  @override
  Widget build(BuildContext context) {
    final scale = context.sportoScale;
    final tokens = context.sporto;
    final isUser = party == WalletTransactionParty.user;
    final gradient = isUser ? tokens.gradientBlue : tokens.gradientPink;
    final softGradient = LinearGradient(
      begin: gradient.begin,
      end: gradient.end,
      colors: gradient.colors
          .map((color) => color.withValues(alpha: 0.14))
          .toList(growable: false),
    );

    return Container(
      height: 19 * scale,
      padding: EdgeInsets.symmetric(horizontal: 6 * scale),
      decoration: BoxDecoration(
        gradient: softGradient,
        borderRadius: BorderRadius.circular(10 * scale),
      ),
      alignment: Alignment.center,
      child: SportoGradientText(
        isUser ? 'by User' : 'by Partner',
        gradient: gradient,
        maxLines: 1,
        style: TextStyle(
          fontSize: 11 * scale,
          fontWeight: FontWeight.w500,
          color: Colors.white,
          height: 1.1,
        ),
      ),
    );
  }
}

/// Wallet history row used by the overview (02) and history (03) screens.
class WalletTransactionTile extends StatelessWidget {
  final WalletTransaction transaction;
  final VoidCallback? onTap;

  const WalletTransactionTile({
    super.key,
    required this.transaction,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final scale = context.sportoScale;
    final tokens = context.sporto;
    final isPaid = transaction.status == WalletTransactionStatus.paid;
    final statusColor = isPaid ? tokens.accentGreen : tokens.red;
    final statusLabel = isPaid ? 'Paid' : 'Processing';
    final amount = formatIndianRupees(transaction.amountRupees);

    return Semantics(
      button: onTap != null,
      label: '${transaction.name}, ${transaction.tournamentName}, '
          '$statusLabel, $amount',
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
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              transaction.name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 14 * scale,
                                fontWeight: FontWeight.w400,
                                color: tokens.muted,
                                height: 1.25,
                              ),
                            ),
                          ),
                          SizedBox(width: 6 * scale),
                          WalletPartyChip(party: transaction.party),
                        ],
                      ),
                      SizedBox(height: 2 * scale),
                      Text(
                        transaction.tournamentName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 14 * scale,
                          fontWeight: FontWeight.w500,
                          color: Colors.white,
                          height: 1.25,
                        ),
                      ),
                      SizedBox(height: 2 * scale),
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              statusLabel,
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
                WalletMoneyText(
                  amount,
                  maxLines: 1,
                  symbolStyle: TextStyle(
                    fontSize: 14 * scale,
                    fontWeight: FontWeight.w400,
                    color: statusColor,
                    height: 1.25,
                  ),
                  amountStyle: TextStyle(
                    fontSize: 14 * scale,
                    fontWeight: FontWeight.w600,
                    color: statusColor,
                    height: 1.25,
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
