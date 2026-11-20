import 'package:flutter/material.dart';
import 'package:referee_app/core/di/dependency_injector.dart';
import 'package:referee_data/referee_data.dart';
import 'package:ui_kit/ui_kit.dart';

import '../wallet_adapters.dart';
import '../wallet_formatters.dart';
import '../static_wallet_transactions.dart';
import '../widgets/wallet_shared_widgets.dart';
import 'transaction_details_screen.dart';

enum _WalletTab { all, earnings, withdrawals }

/// Screen 03 - wallet transaction history with All / Earnings / Withdrawals.
///
/// The API returns a paged ledger; tabs filter locally on the parsed
/// category/type and the sort control reverses the local ordering.
class WalletTransactionsScreen extends StatefulWidget {
  final Future<RefereeWalletTransactionsPage>? transactionsFuture;

  const WalletTransactionsScreen({
    super.key,
    this.transactionsFuture,
  });

  @override
  State<WalletTransactionsScreen> createState() =>
      _WalletTransactionsScreenState();
}

class _WalletTransactionsScreenState extends State<WalletTransactionsScreen> {
  _WalletTab _tab = _WalletTab.all;
  bool _newestFirst = true;
  late Future<RefereeWalletTransactionsPage> _future;

  RefereeRemoteDataSource get _remote =>
      DependencyInjector.instance.refereeRemoteDataSource;

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  Future<RefereeWalletTransactionsPage> _load() {
    return widget.transactionsFuture ??
        _remote.listWalletTransactionsData(perPage: 50);
  }

  void _retry() {
    setState(() => _future = _load());
  }

  List<WalletTransactionView> _visible(
    List<RefereeWalletTransaction> items,
  ) {
    final views = items.map(WalletTransactionView.new).toList(growable: false);
    final filtered = switch (_tab) {
      _WalletTab.all => views,
      _WalletTab.earnings => views
          .where((view) => view.category == WalletLedgerCategory.earnings)
          .toList(growable: false),
      _WalletTab.withdrawals => views
          .where((view) => view.category == WalletLedgerCategory.withdrawal)
          .toList(growable: false),
    };
    final indexed = filtered.asMap().entries.toList(growable: false);
    indexed.sort((a, b) {
      final aDate = parseApiDate(a.value.transaction.createdAt);
      final bDate = parseApiDate(b.value.transaction.createdAt);
      if (aDate == null && bDate == null) {
        return _newestFirst ? a.key.compareTo(b.key) : b.key.compareTo(a.key);
      }
      // Rows without a date stay at the end regardless of sort direction.
      if (aDate == null) return 1;
      if (bDate == null) return -1;
      return _newestFirst ? bDate.compareTo(aDate) : aDate.compareTo(bDate);
    });
    return indexed.map((entry) => entry.value).toList(growable: false);
  }

  String get _emptyMessage => switch (_tab) {
        _WalletTab.all => 'No transactions yet',
        _WalletTab.earnings => 'No earnings yet',
        _WalletTab.withdrawals => 'No withdrawals yet',
      };

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
            const WalletScreenHeader(title: 'Wallet Transaction'),
            Padding(
              padding: EdgeInsets.fromLTRB(
                20 * scale,
                8 * scale,
                12 * scale,
                0,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      clipBehavior: Clip.none,
                      child: Row(
                        children: [
                          _TabChip(
                            label: 'All',
                            selected: _tab == _WalletTab.all,
                            onTap: () => setState(() => _tab = _WalletTab.all),
                          ),
                          SizedBox(width: 10 * scale),
                          _TabChip(
                            label: 'Earnings',
                            selected: _tab == _WalletTab.earnings,
                            onTap: () =>
                                setState(() => _tab = _WalletTab.earnings),
                          ),
                          SizedBox(width: 10 * scale),
                          _TabChip(
                            label: 'Withdrawals',
                            selected: _tab == _WalletTab.withdrawals,
                            onTap: () =>
                                setState(() => _tab = _WalletTab.withdrawals),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(width: 6 * scale),
                  WalletSortButton(
                    onTap: () => setState(() => _newestFirst = !_newestFirst),
                  ),
                ],
              ),
            ),
            Expanded(
              child: FutureBuilder<RefereeWalletTransactionsPage>(
                future: _future,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting ||
                      snapshot.connectionState == ConnectionState.none) {
                    return const _TransactionsSkeleton();
                  }
                  if (snapshot.hasError) {
                    return Center(
                      child: SportoErrorView(
                        headline: 'Unable to load transactions',
                        description: 'Check your connection and try again.',
                        onRetry: _retry,
                      ),
                    );
                  }
                  final apiItems = snapshot.data?.items ?? const [];
                  // TODO(backend): temporary Figma rows until the transaction
                  // endpoint returns a populated, documented row schema.
                  final items =
                      apiItems.isEmpty && widget.transactionsFuture == null
                          ? kStaticWalletTransactions
                          : apiItems;
                  final visible = _visible(items);
                  return ListView(
                    padding: EdgeInsets.fromLTRB(
                      20 * scale,
                      10 * scale,
                      20 * scale,
                      24 * scale + MediaQuery.paddingOf(context).bottom,
                    ),
                    children: [
                      if (visible.isEmpty)
                        WalletEmptyState(message: _emptyMessage)
                      else
                        for (var i = 0; i < visible.length; i++) ...[
                          WalletLedgerTile(
                            transaction: visible[i],
                            onTap: () =>
                                _openDetails(context, visible[i].transaction),
                          ),
                          if (i != visible.length - 1)
                            SizedBox(height: 10 * scale),
                        ],
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _openDetails(
    BuildContext context,
    RefereeWalletTransaction transaction,
  ) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => TransactionDetailsScreen(transaction: transaction),
      ),
    );
  }
}

class _TransactionsSkeleton extends StatelessWidget {
  const _TransactionsSkeleton();

  @override
  Widget build(BuildContext context) {
    final scale = context.sportoScale;
    return Semantics(
      label: 'Loading transactions',
      child: ListView(
        padding: EdgeInsets.fromLTRB(
          20 * scale,
          10 * scale,
          20 * scale,
          24 * scale + MediaQuery.paddingOf(context).bottom,
        ),
        children: const [
          SportoSkeletonList(
            itemCount: 4,
            itemBuilder: _transactionSkeleton,
            gap: 10,
          ),
        ],
      ),
    );
  }

  static Widget _transactionSkeleton(BuildContext context) {
    return const BookingListItemSkeleton();
  }
}

class _TabChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _TabChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return WalletFilterChip(
      label: label,
      selected: selected,
      onTap: onTap,
      fontSize: 14,
      selectedWeight: FontWeight.w700,
      unselectedWeight: FontWeight.w400,
    );
  }
}
