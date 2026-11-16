import 'package:flutter/material.dart';
import 'package:referee_app/core/config/referee_demo_data.dart';
import 'package:ui_kit/ui_kit.dart';

import '../wallet_figma_data.dart';
import '../wallet_icons.dart';
import '../wallet_models.dart';
import '../widgets/wallet_shared_widgets.dart';

/// Screen 04 - full transaction receipt (Figma `04_Transaction-Details`).
class TransactionDetailsScreen extends StatelessWidget {
  final TransactionDetail? detail;
  final WalletTransaction? transaction;

  const TransactionDetailsScreen({
    super.key,
    this.detail,
    this.transaction,
  });

  TransactionDetail? get _resolvedDetail {
    if (transaction != null) {
      return TransactionDetail.fromTransaction(transaction!);
    }
    if (detail != null) return detail;
    return kRefereeDemoData ? WalletFigmaData.transactionDetail : null;
  }

  @override
  Widget build(BuildContext context) {
    final scale = context.sportoScale;
    final tokens = context.sporto;
    final bottomInset = MediaQuery.paddingOf(context).bottom;
    final detail = _resolvedDetail;
    if (detail == null) {
      return Scaffold(
        backgroundColor: tokens.canvas,
        body: SafeArea(
          bottom: false,
          child: Column(
            children: [
              const WalletScreenHeader(title: 'Transaction Details'),
              Expanded(
                child: Center(
                  child: Text(
                    'Transaction details are not available yet.',
                    style: TextStyle(
                      fontSize: 14 * scale,
                      color: tokens.muted,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }
    final isCredit = detail.direction == WalletTransactionDirection.credited;
    final directionColor = isCredit ? tokens.accentGreen : tokens.red;
    final directionLabel = isCredit ? 'Credited' : 'Debited';
    final amountLabel =
        '${isCredit ? '+' : '-'}${formatIndianRupees(detail.amountRupees, space: false)}';

    return Scaffold(
      backgroundColor: tokens.canvas,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            WalletScreenHeader(
              title: 'Transaction Details',
              subtitle: '${detail.reference} · ${detail.dateLabel}',
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
                    detail: detail,
                    scale: scale,
                    amountLabel: amountLabel,
                    directionColor: directionColor,
                    directionLabel: directionLabel,
                  ),
                  SizedBox(height: 20 * scale),
                  _SectionLabel(label: 'Description', scale: scale),
                  SizedBox(height: 10 * scale),
                  _DescriptionCard(detail: detail, scale: scale),
                  SizedBox(height: 20 * scale),
                  _SectionLabel(label: 'Tournament Details', scale: scale),
                  SizedBox(height: 10 * scale),
                  _TournamentCard(detail: detail, scale: scale),
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
  final TransactionDetail detail;
  final double scale;
  final String amountLabel;
  final Color directionColor;
  final String directionLabel;

  const _HeroCard({
    required this.detail,
    required this.scale,
    required this.amountLabel,
    required this.directionColor,
    required this.directionLabel,
  });

  @override
  Widget build(BuildContext context) {
    final tokens = context.sporto;
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
          SizedBox(height: 10 * scale),
          Text(
            detail.category,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 14 * scale,
              fontWeight: FontWeight.w500,
              color: tokens.muted,
              height: 1.2,
            ),
          ),
          SizedBox(height: 8 * scale),
          _StatusPill(label: detail.statusLabel, scale: scale),
          SizedBox(height: 14 * scale),
          SizedBox(
            width: double.infinity,
            child: Container(
              height: 1 * scale,
              color: tokens.border.withValues(alpha: 0.5),
            ),
          ),
          SizedBox(height: 12 * scale),
          SizedBox(
            width: double.infinity,
            child: _DetailRow(
              label: 'Transaction Ref',
              value: detail.transactionRef,
              scale: scale,
            ),
          ),
          SizedBox(height: 4 * scale),
          SizedBox(
            width: double.infinity,
            child: _DetailRow(
              label: 'Payment Method',
              value: detail.paymentMethod,
              scale: scale,
            ),
          ),
          SizedBox(height: 4 * scale),
          SizedBox(
            width: double.infinity,
            child: _DetailRow(
              label: 'Direction',
              value: directionLabel,
              scale: scale,
              valueColor: directionColor,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusPill extends StatelessWidget {
  final String label;
  final double scale;

  const _StatusPill({required this.label, required this.scale});

  @override
  Widget build(BuildContext context) {
    final tokens = context.sporto;
    return Container(
      height: 21 * scale,
      padding: EdgeInsets.symmetric(horizontal: 8 * scale),
      decoration: BoxDecoration(
        color: tokens.accentGreen.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(30 * scale),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SportoSvgIcon(
            WalletIcons.checkCircle,
            size: 12 * scale,
          ),
          SizedBox(width: 3 * scale),
          Text(
            label,
            maxLines: 1,
            style: TextStyle(
              fontSize: 10 * scale,
              fontWeight: FontWeight.w500,
              color: tokens.accentGreen,
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
  final TransactionDetail detail;
  final double scale;

  const _DescriptionCard({required this.detail, required this.scale});

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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            detail.descriptionTitle,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 14 * scale,
              fontWeight: FontWeight.w500,
              color: Colors.white,
              height: 1.25,
            ),
          ),
          SizedBox(height: 6 * scale),
          Row(
            children: [
              Expanded(
                child: Text(
                  detail.descriptionSubtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 14 * scale,
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                    height: 1.25,
                  ),
                ),
              ),
              SizedBox(width: 8 * scale),
              Text(
                formatIndianRupees(
                  detail.amountRupees,
                  space: false,
                  grouping: false,
                ),
                maxLines: 1,
                style: TextStyle(
                  fontSize: 14 * scale,
                  fontWeight: FontWeight.w500,
                  color: Colors.white,
                  height: 1.25,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _TournamentCard extends StatelessWidget {
  final TransactionDetail detail;
  final double scale;

  const _TournamentCard({required this.detail, required this.scale});

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
              detail.tournamentName,
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
