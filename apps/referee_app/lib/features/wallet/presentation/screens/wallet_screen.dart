import 'package:flutter/material.dart';
import 'package:referee_app/core/config/referee_demo_data.dart';
import 'package:referee_app/features/bank/presentation/screens/bank_accounts_screen.dart';
import 'package:ui_kit/ui_kit.dart';

import '../wallet_figma_data.dart';
import '../wallet_icons.dart';
import '../wallet_models.dart';
import '../widgets/wallet_shared_widgets.dart';
import 'transaction_details_screen.dart';
import 'wallet_transactions_screen.dart';

/// Screen 02 - wallet overview (Figma `02_Wallet`).
class WalletScreen extends StatelessWidget {
  final WalletOverview? overview;

  const WalletScreen({
    super.key,
    this.overview,
  });

  @override
  Widget build(BuildContext context) {
    final overview = this.overview ??
        (kRefereeDemoData
            ? WalletFigmaData.overview
            : const WalletOverview(
                balanceRupees: 0,
                pendingSettlementRupees: 0,
                totalEarningsRupees: 0,
              ));
    final scale = context.sportoScale;
    final tokens = context.sporto;
    final bottomInset = MediaQuery.paddingOf(context).bottom;

    return Scaffold(
      backgroundColor: tokens.canvas,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            WalletScreenHeader(
              title: 'Wallet Transaction',
              trailing: WalletPill(
                label: 'Add bank',
                background: tokens.accentGreen.withValues(alpha: 0.06),
                borderColor: tokens.accentGreen.withValues(alpha: 0.20),
                textColor: tokens.accentGreen,
                leading: SportoSvgIcon(
                  WalletIcons.plus,
                  size: 12 * scale,
                ),
                fontSize: 14,
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => const BankAccountsScreen(),
                  ),
                ),
              ),
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
                  _BalanceCard(overview: overview, scale: scale),
                  SizedBox(height: 8 * scale),
                  Row(
                    children: [
                      Expanded(
                        child: _StatCard(
                          amount: formatIndianRupees(
                            overview.pendingSettlementRupees,
                          ),
                          label: 'Pending Settlement',
                          scale: scale,
                        ),
                      ),
                      SizedBox(width: 12 * scale),
                      Expanded(
                        child: _StatCard(
                          amount: formatIndianCompactRupees(
                            overview.totalEarningsRupees,
                          ),
                          label: 'Total Earnings',
                          scale: scale,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8 * scale),
                  Row(
                    children: [
                      Expanded(
                        child: _ActionButton(
                          label: 'Transaction History',
                          scale: scale,
                          onTap: () => _openHistory(context),
                        ),
                      ),
                      SizedBox(width: 8 * scale),
                      Expanded(
                        child: _ActionButton(
                          label: 'Download Statement',
                          icon: WalletIcons.download,
                          scale: scale,
                          onTap: () => _comingSoon(
                            context,
                            'Statement downloads will be available soon.',
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8 * scale),
                  _RecentHeader(
                    scale: scale,
                    onViewAll: () => _openHistory(context),
                  ),
                  SizedBox(height: 10 * scale),
                  if (overview.recentTransactions.isEmpty)
                    const WalletEmptyState(message: 'No transactions yet')
                  else
                    for (var i = 0;
                        i < overview.recentTransactions.length;
                        i++) ...[
                      WalletTransactionTile(
                        transaction: overview.recentTransactions[i],
                        onTap: () => _openDetails(
                            context, overview.recentTransactions[i]),
                      ),
                      if (i != overview.recentTransactions.length - 1)
                        SizedBox(height: 10 * scale),
                    ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _openHistory(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => const WalletTransactionsScreen(),
      ),
    );
  }

  void _openDetails(BuildContext context, WalletTransaction transaction) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => TransactionDetailsScreen(transaction: transaction),
      ),
    );
  }

  void _comingSoon(BuildContext context, String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: context.sporto.cardElevated,
          behavior: SnackBarBehavior.floating,
        ),
      );
  }
}

class _BalanceCard extends StatelessWidget {
  final WalletOverview overview;
  final double scale;

  const _BalanceCard({required this.overview, required this.scale});

  @override
  Widget build(BuildContext context) {
    final tokens = context.sporto;
    return Container(
      height: 76 * scale,
      padding: EdgeInsets.symmetric(horizontal: 14 * scale),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFFFD36A), Color(0xFFF4B41A)],
        ),
        borderRadius: BorderRadius.circular(20 * scale),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Wallet balance',
                  style: TextStyle(
                    fontSize: 12 * scale,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF222222),
                    height: 1.2,
                  ),
                ),
                SizedBox(height: 2 * scale),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: WalletMoneyText(
                    formatIndianRupees(overview.balanceRupees),
                    maxLines: 1,
                    symbolStyle: TextStyle(
                      fontSize: 18 * scale,
                      fontWeight: FontWeight.w400,
                      color: const Color(0xFF0E0C08),
                      height: 1.15,
                    ),
                    amountStyle: TextStyle(
                      fontSize: 20 * scale,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF0E0C08),
                      height: 1.15,
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: 10 * scale),
          WalletPill(
            label: 'Withdraw',
            background: const Color(0x1A0E0C08),
            textColor: const Color(0xFF090C10),
            height: 27,
            fontSize: 12,
            onTap: () => ScaffoldMessenger.of(context)
              ..hideCurrentSnackBar()
              ..showSnackBar(
                SnackBar(
                  content: const Text('Withdrawals are not available yet.'),
                  backgroundColor: tokens.cardElevated,
                  behavior: SnackBarBehavior.floating,
                ),
              ),
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String amount;
  final String label;
  final double scale;

  const _StatCard({
    required this.amount,
    required this.label,
    required this.scale,
  });

  @override
  Widget build(BuildContext context) {
    final tokens = context.sporto;
    return Container(
      height: 66 * scale,
      padding: EdgeInsets.symmetric(horizontal: 12 * scale),
      decoration: BoxDecoration(
        color: tokens.cardElevated,
        borderRadius: BorderRadius.circular(16 * scale),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          FittedBox(
            fit: BoxFit.scaleDown,
            child: WalletMoneyText(
              amount,
              maxLines: 1,
              symbolStyle: TextStyle(
                fontSize: 16 * scale,
                fontWeight: FontWeight.w400,
                color: Colors.white,
                height: 1.15,
              ),
              amountStyle: TextStyle(
                fontSize: 18 * scale,
                fontWeight: FontWeight.w700,
                color: Colors.white,
                height: 1.15,
              ),
            ),
          ),
          SizedBox(height: 4 * scale),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              label,
              maxLines: 1,
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
    );
  }
}

class _ActionButton extends StatelessWidget {
  final String label;
  final String? icon;
  final double scale;
  final VoidCallback onTap;

  const _ActionButton({
    required this.label,
    required this.scale,
    required this.onTap,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final tokens = context.sporto;
    return Semantics(
      button: true,
      label: label,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(14 * scale),
          child: SizedBox(
            height: 44 * scale,
            child: Center(
              child: Container(
                height: 40 * scale,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: tokens.panel.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(14 * scale),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (icon != null) ...[
                      SportoSvgIcon(icon!, size: 18 * scale),
                      SizedBox(width: 6 * scale),
                    ],
                    Flexible(
                      child: SportoGradientText(
                        label,
                        gradient: tokens.gradientBlue,
                        maxLines: 1,
                        style: TextStyle(
                          fontSize: 12 * scale,
                          fontWeight: FontWeight.w500,
                          color: Colors.white,
                          height: 1.2,
                        ),
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

class _RecentHeader extends StatelessWidget {
  final double scale;
  final VoidCallback onViewAll;

  const _RecentHeader({required this.scale, required this.onViewAll});

  @override
  Widget build(BuildContext context) {
    final tokens = context.sporto;
    return Row(
      children: [
        Expanded(
          child: Text(
            'Recent Transactions',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 14 * scale,
              fontWeight: FontWeight.w500,
              color: tokens.muted,
              height: 1.2,
            ),
          ),
        ),
        Semantics(
          button: true,
          label: 'View all transactions',
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onViewAll,
              borderRadius: BorderRadius.circular(10 * scale),
              child: SizedBox(
                height: 44 * scale,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'View All',
                      style: TextStyle(
                        fontSize: 12 * scale,
                        fontWeight: FontWeight.w600,
                        color: tokens.muted,
                        height: 1.2,
                      ),
                    ),
                    SizedBox(width: 3 * scale),
                    SportoSvgIcon(
                      WalletIcons.arrowRight,
                      width: 13 * scale,
                      height: 8 * scale,
                      color: tokens.muted,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
