import 'package:flutter/material.dart';
import 'package:referee_app/core/di/dependency_injector.dart';
import 'package:referee_app/features/bank/presentation/screens/bank_accounts_screen.dart';
import 'package:referee_data/referee_data.dart';
import 'package:ui_kit/ui_kit.dart';

import '../wallet_adapters.dart';
import '../wallet_formatters.dart';
import '../wallet_icons.dart';
import '../widgets/wallet_shared_widgets.dart';
import 'transaction_details_screen.dart';
import 'wallet_transactions_screen.dart';

/// Screen 02 - wallet overview (Figma `02_Wallet`).
///
/// Loads the live wallet summary and the five most recent ledger rows in
/// parallel. Both futures can be injected by tests so no network is required.
class WalletScreen extends StatefulWidget {
  final Future<RefereeWalletSummary>? walletFuture;
  final Future<RefereeWalletTransactionsPage>? transactionsFuture;

  const WalletScreen({
    super.key,
    this.walletFuture,
    this.transactionsFuture,
  });

  @override
  State<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends State<WalletScreen> {
  late Future<_WalletScreenData> _future;

  RefereeRemoteDataSource get _remote =>
      DependencyInjector.instance.refereeRemoteDataSource;

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  Future<_WalletScreenData> _load() async {
    final walletFuture = widget.walletFuture ?? _remote.getWalletData();
    final transactionsFuture = widget.transactionsFuture ??
        _remote.listWalletTransactionsData(perPage: 5);
    final results = await Future.wait<Object>([
      walletFuture,
      transactionsFuture,
    ]);
    return _WalletScreenData(
      wallet: results[0] as RefereeWalletSummary,
      transactions: results[1] as RefereeWalletTransactionsPage,
    );
  }

  void _retry() {
    setState(() => _future = _load());
  }

  @override
  Widget build(BuildContext context) {
    final scale = context.sportoScale;
    final tokens = context.sporto;

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
                onTap: _openBankAccounts,
              ),
            ),
            Expanded(
              child: FutureBuilder<_WalletScreenData>(
                future: _future,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting ||
                      snapshot.connectionState == ConnectionState.none) {
                    return const _WalletScreenSkeleton();
                  }
                  if (snapshot.hasError) {
                    return Center(
                      child: SportoErrorView(
                        headline: 'Unable to load wallet',
                        description: 'Check your connection and try again.',
                        onRetry: _retry,
                      ),
                    );
                  }
                  final data = snapshot.data;
                  if (data == null) {
                    return Center(
                      child: SportoErrorView(
                        headline: 'Unable to load wallet',
                        description: 'Check your connection and try again.',
                        onRetry: _retry,
                      ),
                    );
                  }
                  return _buildBody(context, data, scale);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBody(
    BuildContext context,
    _WalletScreenData data,
    double scale,
  ) {
    final bottomInset = MediaQuery.paddingOf(context).bottom;
    final wallet = data.wallet;
    final transactions = data.transactions.items;

    return ListView(
      padding: EdgeInsets.fromLTRB(
        20 * scale,
        10 * scale,
        20 * scale,
        24 * scale + bottomInset,
      ),
      children: [
        _BalanceCard(
          amount: formatCurrencyAmount(
            wallet.balance,
            currency: wallet.currency,
          ),
          scale: scale,
          onWithdraw: () => _showComingSoon(
            'Withdrawals are not available yet.',
          ),
        ),
        SizedBox(height: 8 * scale),
        Row(
          children: [
            Expanded(
              child: _StatCard(
                amount: formatCurrencyAmount(
                  wallet.pendingEarnings,
                  currency: wallet.currency,
                ),
                label: 'Pending Settlement',
                scale: scale,
              ),
            ),
            SizedBox(width: 12 * scale),
            Expanded(
              child: _StatCard(
                amount: formatCompactCurrencyAmount(
                  wallet.totalEarned,
                  currency: wallet.currency,
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
                onTap: _openHistory,
              ),
            ),
            SizedBox(width: 8 * scale),
            Expanded(
              child: _ActionButton(
                label: 'Download Statement',
                icon: WalletIcons.download,
                scale: scale,
                onTap: () => _showComingSoon(
                  'Statement downloads are not available yet.',
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 8 * scale),
        if (transactions.isNotEmpty) ...[
          _RecentHeader(
            scale: scale,
            onViewAll: _openHistory,
          ),
          SizedBox(height: 10 * scale),
          for (var i = 0; i < transactions.length; i++) ...[
            WalletLedgerTile(
              transaction: WalletTransactionView(transactions[i]),
              onTap: () => _openDetails(transactions[i]),
            ),
            if (i != transactions.length - 1) SizedBox(height: 10 * scale),
          ],
        ] else if (!_hasWalletData(wallet))
          const WalletEmptyState(message: 'Wallet not set up yet'),
      ],
    );
  }

  bool _hasWalletData(RefereeWalletSummary wallet) {
    if (wallet.walletExists) return true;
    // `reserved_balance` is often present as `0` even when no wallet exists,
    // so only a non-zero money value proves the wallet is set up.
    return (wallet.balance ?? 0) != 0 ||
        (wallet.totalEarned ?? 0) != 0 ||
        (wallet.pendingEarnings ?? 0) != 0;
  }

  void _openBankAccounts() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => const BankAccountsScreen(),
      ),
    );
  }

  void _openHistory() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => const WalletTransactionsScreen(),
      ),
    );
  }

  void _openDetails(RefereeWalletTransaction transaction) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => TransactionDetailsScreen(transaction: transaction),
      ),
    );
  }

  void _showComingSoon(String message) {
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

class _WalletScreenData {
  const _WalletScreenData({
    required this.wallet,
    required this.transactions,
  });

  final RefereeWalletSummary wallet;
  final RefereeWalletTransactionsPage transactions;
}

class _WalletScreenSkeleton extends StatelessWidget {
  const _WalletScreenSkeleton();

  @override
  Widget build(BuildContext context) {
    final scale = context.sportoScale;
    final bottomInset = MediaQuery.paddingOf(context).bottom;
    return Semantics(
      label: 'Loading wallet',
      child: ListView(
        padding: EdgeInsets.fromLTRB(
          20 * scale,
          10 * scale,
          20 * scale,
          24 * scale + bottomInset,
        ),
        children: [
          SportoSkeletonCard(height: 76 * scale, borderRadius: 20 * scale),
          SizedBox(height: 8 * scale),
          Row(
            children: [
              Expanded(
                child: SportoSkeletonCard(
                  height: 66 * scale,
                  borderRadius: 16 * scale,
                ),
              ),
              SizedBox(width: 12 * scale),
              Expanded(
                child: SportoSkeletonCard(
                  height: 66 * scale,
                  borderRadius: 16 * scale,
                ),
              ),
            ],
          ),
          SizedBox(height: 8 * scale),
          Row(
            children: [
              Expanded(
                child: SportoSkeletonCard(
                  height: 40 * scale,
                  borderRadius: 14 * scale,
                ),
              ),
              SizedBox(width: 8 * scale),
              Expanded(
                child: SportoSkeletonCard(
                  height: 40 * scale,
                  borderRadius: 14 * scale,
                ),
              ),
            ],
          ),
          SizedBox(height: 16 * scale),
          const SkeletonLine(width: 140, height: 14),
          SizedBox(height: 10 * scale),
          const BookingListItemSkeleton(),
          SizedBox(height: 10 * scale),
          const BookingListItemSkeleton(),
        ],
      ),
    );
  }
}

class _BalanceCard extends StatelessWidget {
  final String amount;
  final double scale;
  final VoidCallback onWithdraw;

  const _BalanceCard({
    required this.amount,
    required this.scale,
    required this.onWithdraw,
  });

  @override
  Widget build(BuildContext context) {
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
                    amount,
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
            onTap: onWithdraw,
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
