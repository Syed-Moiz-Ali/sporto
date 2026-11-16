import 'package:flutter/material.dart';
import 'package:referee_app/core/config/referee_demo_data.dart';
import 'package:ui_kit/ui_kit.dart';

import '../wallet_figma_data.dart';
import '../wallet_models.dart';
import '../widgets/wallet_shared_widgets.dart';
import 'transaction_details_screen.dart';

enum _WalletTab { all, earnings, withdrawals }

/// Screen 03 - wallet transaction history with All / Earnings / Withdrawals.
class WalletTransactionsScreen extends StatefulWidget {
  final List<WalletTransaction>? transactions;

  const WalletTransactionsScreen({
    super.key,
    this.transactions,
  });

  @override
  State<WalletTransactionsScreen> createState() =>
      _WalletTransactionsScreenState();
}

class _WalletTransactionsScreenState extends State<WalletTransactionsScreen> {
  _WalletTab _tab = _WalletTab.all;
  bool _newestFirst = true;

  List<WalletTransaction> get _transactions =>
      widget.transactions ??
      (kRefereeDemoData ? WalletFigmaData.transactions : const []);

  List<WalletTransaction> get _visibleTransactions {
    final filtered = switch (_tab) {
      _WalletTab.all => _transactions,
      _WalletTab.earnings => _transactions
          .where((t) => t.category == WalletTransactionCategory.earnings)
          .toList(growable: false),
      _WalletTab.withdrawals => _transactions
          .where((t) => t.category == WalletTransactionCategory.withdrawal)
          .toList(growable: false),
    };
    if (!_newestFirst) {
      return filtered.reversed.toList(growable: false);
    }
    return filtered;
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
    final bottomInset = MediaQuery.paddingOf(context).bottom;
    final visible = _visibleTransactions;

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
              child: ListView(
                padding: EdgeInsets.fromLTRB(
                  20 * scale,
                  10 * scale,
                  20 * scale,
                  24 * scale + bottomInset,
                ),
                children: [
                  if (visible.isEmpty)
                    WalletEmptyState(message: _emptyMessage)
                  else
                    for (var i = 0; i < visible.length; i++) ...[
                      WalletTransactionTile(
                        transaction: visible[i],
                        onTap: () => _openDetails(context, visible[i]),
                      ),
                      if (i != visible.length - 1) SizedBox(height: 10 * scale),
                    ],
                ],
              ),
            ),
          ],
        ),
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
