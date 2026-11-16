import 'package:flutter/material.dart';
import 'package:referee_data/referee_data.dart';
import 'package:ui_kit/ui_kit.dart';

import '../wallet_adapters.dart';
import '../wallet_formatters.dart';
import '../wallet_icons.dart';
import '../widgets/wallet_shared_widgets.dart';

/// Screen 04 - full transaction receipt (Figma `04_Transaction-Details`).
///
/// There is no transaction-detail endpoint yet, so the screen renders the row
/// that was tapped. Fields the backend did not send are hidden; opening the
/// screen without data shows an explicit "not available yet" state.
class TransactionDetailsScreen extends StatelessWidget {
  final RefereeWalletTransaction? transaction;

  const TransactionDetailsScreen({
    super.key,
    this.transaction,
  });

  @override
  Widget build(BuildContext context) {
    final scale = context.sportoScale;
    final tokens = context.sporto;
    final transaction = this.transaction;

    if (transaction == null) {
      return Scaffold(
        backgroundColor: tokens.canvas,
        body: SafeArea(
          bottom: false,
          child: Column(
            children: [
              const WalletScreenHeader(title: 'Transaction Details'),
              Expanded(
                child: Center(
                  child: Padding(
                    padding: EdgeInsets.all(20 * scale),
                    child: Text(
                      'Transaction details are not available yet.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14 * scale,
                        color: tokens.muted,
                        height: 1.4,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    final view = WalletTransactionView(transaction);
    final bottomInset = MediaQuery.paddingOf(context).bottom;
    final directionColor = switch (view.direction) {
      WalletLedgerDirection.credit => tokens.accentGreen,
      WalletLedgerDirection.debit => tokens.red,
      WalletLedgerDirection.unknown => tokens.muted,
    };
    final statusColor = switch (walletStatusTone(view.statusLabel)) {
      WalletStatusTone.positive => tokens.accentGreen,
      WalletStatusTone.pending => tokens.gold,
      WalletStatusTone.negative => tokens.red,
      WalletStatusTone.neutral => tokens.muted,
    };
    final subtitle = [
      if (view.referenceLabel != null) view.referenceLabel!,
      if (view.dateLabel != '—') view.dateLabel,
    ].join(' · ');

    final hasDescription = view.title != null || view.description != null;
    final hasTournament = view.tournamentName != null;

    return Scaffold(
      backgroundColor: tokens.canvas,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            WalletScreenHeader(
              title: 'Transaction Details',
              subtitle: subtitle.isEmpty ? null : subtitle,
            ),
            Expanded(
              child: ListView(
                padding: EdgeInsets.fromLTRB(
                  20 * scale,
                  10 * scale,
                  20 * scale,
                  24 * scale + bottomInset,
                ),
                children: [
                  _HeroCard(
                    view: view,
                    scale: scale,
                    amountLabel: view.amountLabel,
                    directionColor: directionColor,
                    statusColor: statusColor,
                    statusLabel:
                        view.statusLabel == '—' ? null : view.statusLabel,
                  ),
                  if (hasDescription) ...[
                    SizedBox(height: 20 * scale),
                    _SectionLabel(label: 'Description', scale: scale),
                    SizedBox(height: 10 * scale),
                    _DescriptionCard(
                      view: view,
                      scale: scale,
                      amount: view.transaction.amount,
                      currency: view.transaction.currency,
                    ),
                  ],
                  if (hasTournament) ...[
                    SizedBox(height: 20 * scale),
                    _SectionLabel(label: 'Tournament Details', scale: scale),
                    SizedBox(height: 10 * scale),
                    _TournamentCard(view: view, scale: scale),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HeroCard extends StatelessWidget {
  final WalletTransactionView view;
  final double scale;
  final String amountLabel;
  final Color directionColor;
  final Color statusColor;
  final String? statusLabel;

  const _HeroCard({
    required this.view,
    required this.scale,
    required this.amountLabel,
    required this.directionColor,
    required this.statusColor,
    required this.statusLabel,
  });

  @override
  Widget build(BuildContext context) {
    final tokens = context.sporto;
    final rows = <_DetailEntry>[
      if (view.referenceLabel != null)
        _DetailEntry(label: 'Transaction Ref', value: view.referenceLabel!),
      if (view.paymentMethodLabel != null)
        _DetailEntry(
          label: 'Payment Method',
          value: view.paymentMethodLabel!,
        ),
      if (view.matchLabel != null)
        _DetailEntry(label: 'Match', value: view.matchLabel!),
      if (view.directionLabel != null)
        _DetailEntry(
          label: 'Direction',
          value: view.directionLabel!,
          valueColor: directionColor,
        ),
    ];

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(14 * scale),
      decoration: BoxDecoration(
        color: tokens.card,
        borderRadius: BorderRadius.circular(16 * scale),
      ),
      child: Column(
        children: [
          Container(
            width: 40 * scale,
            height: 40 * scale,
            decoration: BoxDecoration(
              color: tokens.canvas.withValues(alpha: 0.5),
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: SportoSvgIcon(
              WalletIcons.cricketBat,
              size: 20 * scale,
            ),
          ),
          SizedBox(height: 8 * scale),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              amountLabel,
              maxLines: 1,
              style: TextStyle(
                fontSize: 20 * scale,
                fontWeight: FontWeight.w600,
                color: directionColor,
                height: 1.2,
              ),
            ),
          ),
          if (view.categoryLabel != null) ...[
            SizedBox(height: 10 * scale),
            Text(
              view.categoryLabel!,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 14 * scale,
                fontWeight: FontWeight.w500,
                color: tokens.muted,
                height: 1.2,
              ),
            ),
          ],
          if (statusLabel != null) ...[
            SizedBox(height: 8 * scale),
            _StatusPill(
              label: statusLabel!,
              color: statusColor,
              scale: scale,
            ),
          ],
          if (rows.isNotEmpty) ...[
            SizedBox(height: 14 * scale),
            SizedBox(
              width: double.infinity,
              child: Container(
                height: 1 * scale,
                color: tokens.border.withValues(alpha: 0.5),
              ),
            ),
            SizedBox(height: 12 * scale),
            for (var i = 0; i < rows.length; i++) ...[
              SizedBox(
                width: double.infinity,
                child: _DetailRow(
                  label: rows[i].label,
                  value: rows[i].value,
                  scale: scale,
                  valueColor: rows[i].valueColor,
                ),
              ),
              if (i != rows.length - 1) SizedBox(height: 4 * scale),
            ],
          ],
        ],
      ),
    );
  }
}

class _DetailEntry {
  const _DetailEntry({
    required this.label,
    required this.value,
    this.valueColor,
  });

  final String label;
  final String value;
  final Color? valueColor;
}

class _StatusPill extends StatelessWidget {
  final String label;
  final Color color;
  final double scale;

  const _StatusPill({
    required this.label,
    required this.color,
    required this.scale,
  });

  @override
  Widget build(BuildContext context) {
    final isPositive = walletStatusTone(label) == WalletStatusTone.positive;
    return Container(
      height: 21 * scale,
      padding: EdgeInsets.symmetric(horizontal: 8 * scale),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(30 * scale),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (isPositive) ...[
            SportoSvgIcon(
              WalletIcons.checkCircle,
              size: 12 * scale,
              color: color,
            ),
            SizedBox(width: 3 * scale),
          ],
          Text(
            label,
            maxLines: 1,
            style: TextStyle(
              fontSize: 10 * scale,
              fontWeight: FontWeight.w500,
              color: color,
              height: 1.2,
            ),
          ),
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;
  final double scale;
  final Color? valueColor;

  const _DetailRow({
    required this.label,
    required this.value,
    required this.scale,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    final tokens = context.sporto;
    final valueStyle = TextStyle(
      fontSize: 12 * scale,
      fontWeight: FontWeight.w500,
      color: valueColor ?? tokens.muted,
      height: 1.2,
    );
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 12 * scale,
              fontWeight: FontWeight.w500,
              color: tokens.muted,
              height: 1.2,
            ),
          ),
        ),
        SizedBox(width: 12 * scale),
        Expanded(
          child: Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.right,
            style: valueStyle,
          ),
        ),
      ],
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String label;
  final double scale;

  const _SectionLabel({required this.label, required this.scale});

  @override
  Widget build(BuildContext context) {
    final tokens = context.sporto;
    return Text(
      label,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: TextStyle(
        fontSize: 14 * scale,
        fontWeight: FontWeight.w500,
        color: tokens.muted,
        height: 1.2,
      ),
    );
  }
}

class _DescriptionCard extends StatelessWidget {
  final WalletTransactionView view;
  final double scale;
  final double? amount;
  final String? currency;

  const _DescriptionCard({
    required this.view,
    required this.scale,
    required this.amount,
    required this.currency,
  });

  @override
  Widget build(BuildContext context) {
    final tokens = context.sporto;
    final amount = this.amount;
    final title = view.title ?? view.description!;
    final subtitle = view.title != null &&
            view.description != null &&
            view.description != view.title
        ? view.description
        : null;
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(12 * scale),
      decoration: BoxDecoration(
        color: tokens.cardElevated.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(12 * scale),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 14 * scale,
              fontWeight: FontWeight.w500,
              color: Colors.white,
              height: 1.25,
            ),
          ),
          if (subtitle != null || amount != null) ...[
            SizedBox(height: 6 * scale),
            Row(
              children: [
                if (subtitle != null)
                  Expanded(
                    child: Text(
                      subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 14 * scale,
                        fontWeight: FontWeight.w500,
                        color: Colors.white,
                        height: 1.25,
                      ),
                    ),
                  )
                else
                  const Spacer(),
                if (amount != null) ...[
                  SizedBox(width: 8 * scale),
                  Text(
                    formatCurrencyAmount(amount,
                        currency: currency, space: false),
                    maxLines: 1,
                    style: TextStyle(
                      fontSize: 14 * scale,
                      fontWeight: FontWeight.w500,
                      color: Colors.white,
                      height: 1.25,
                    ),
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

class _TournamentCard extends StatelessWidget {
  final WalletTransactionView view;
  final double scale;

  const _TournamentCard({required this.view, required this.scale});

  @override
  Widget build(BuildContext context) {
    final tokens = context.sporto;
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(12 * scale),
      decoration: BoxDecoration(
        color: tokens.cardElevated.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(12 * scale),
      ),
      child: Row(
        children: [
          Container(
            width: 30 * scale,
            height: 30 * scale,
            decoration: BoxDecoration(
              color: tokens.iconTile.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(10 * scale),
            ),
            alignment: Alignment.center,
            child: SportoSvgIcon(
              WalletIcons.cricketBat,
              size: 16 * scale,
            ),
          ),
          SizedBox(width: 8 * scale),
          Expanded(
            child: Text(
              view.tournamentName!,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 14 * scale,
                fontWeight: FontWeight.w600,
                color: Colors.white,
                height: 1.25,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
