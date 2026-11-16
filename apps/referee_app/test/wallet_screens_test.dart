import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:referee_app/features/bank/presentation/screens/bank_accounts_screen.dart';
import 'package:referee_app/features/wallet/presentation/screens/tournaments_history_screen.dart';
import 'package:referee_app/features/wallet/presentation/screens/transaction_details_screen.dart';
import 'package:referee_app/features/wallet/presentation/screens/wallet_screen.dart';
import 'package:referee_app/features/wallet/presentation/screens/wallet_transactions_screen.dart';
import 'package:referee_app/features/wallet/presentation/wallet_formatters.dart';
import 'package:referee_app/features/wallet/presentation/widgets/wallet_shared_widgets.dart';
import 'package:referee_data/referee_data.dart';
import 'package:ui_kit/ui_kit.dart';

void main() {
  Widget app(Widget home) {
    return MaterialApp(
      theme: SportoTheme.darkTheme,
      home: home,
    );
  }

  void setSurface(
    WidgetTester tester, {
    Size size = const Size(390, 844),
  }) {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
  }

  Future<void> pumpScreen(WidgetTester tester, Widget widget) async {
    await tester.pumpWidget(app(widget));
    await tester.pump();
    await tester.pump();
  }

  RefereeWalletSummary walletSummary({
    double? balance = 120400,
    double? pending = 98600,
    double? total = 840000,
    String? currency = 'INR',
    bool walletExists = true,
  }) {
    return RefereeWalletSummary(
      balance: balance,
      reservedBalance: 0,
      totalEarned: total,
      pendingEarnings: pending,
      currency: currency,
      walletExists: walletExists,
      earningsAvailable: true,
    );
  }

  RefereeWalletTransaction earningTx({
    int id = 1,
    String? title = 'Match earnings',
    String? description = 'Referee fee',
    String? tournament = 'Gachibowli Super Over Qualifier',
    double? amount = 3000,
    String? createdAt = '2026-09-09T19:42:00Z',
  }) {
    return RefereeWalletTransaction(
      id: id,
      reference: 'TXN-$id',
      amount: amount,
      status: 'paid',
      statusLabel: 'Paid',
      category: 'earnings',
      description: description,
      title: title,
      tournamentName: tournament,
      createdAt: createdAt,
      direction: 'CREDIT',
      currency: 'INR',
      paymentMethod: 'Spoto Wallet Credit',
    );
  }

  RefereeWalletTransaction withdrawalTx({
    int id = 2,
    String? title = 'Bank payout',
    double? amount = 1000,
    String? createdAt = '2026-09-10T10:00:00Z',
  }) {
    return RefereeWalletTransaction(
      id: id,
      reference: 'TXN-$id',
      amount: amount,
      status: 'processing',
      statusLabel: 'Processing',
      category: 'withdrawal',
      description: 'Wallet withdrawal',
      title: title,
      createdAt: createdAt,
      direction: 'DEBIT',
      currency: 'INR',
      paymentMethod: 'Bank Payout',
    );
  }

  RefereeWalletTransactionsPage transactionsPage(
    List<RefereeWalletTransaction> items,
  ) {
    return RefereeWalletTransactionsPage(
      items: items,
      total: items.length,
      currentPage: 1,
      lastPage: 1,
    );
  }

  RefereeTournamentHistoryItem tournament({
    required int id,
    required String name,
    String? code,
    int? status,
    String? currency,
  }) {
    return RefereeTournamentHistoryItem(
      id: id,
      name: name,
      code: code,
      status: status,
      currency: currency,
    );
  }

  RefereeTournamentHistoryPage tournamentsPage(
    List<RefereeTournamentHistoryItem> items,
  ) {
    return RefereeTournamentHistoryPage(
      items: items,
      total: items.length,
      page: 1,
      lastPage: 1,
    );
  }

  group('money formatting', () {
    test('uses Indian digit grouping', () {
      expect(formatIndianRupees(120400), '₹ 1,20,400');
      expect(formatIndianRupees(98600), '₹ 98,600');
      expect(formatIndianRupees(3800), '₹ 3,800');
      expect(formatIndianRupees(0), '₹ 0');
      expect(formatIndianRupees(10000000), '₹ 1,00,00,000');
      expect(formatIndianRupees(-4500), '-₹ 4,500');
    });

    test('can omit the space after the rupee symbol', () {
      expect(formatIndianRupees(1000, space: false), '₹1,000');
      expect(formatIndianRupees(120400, space: false), '₹1,20,400');
    });

    test('formats API decimals with currency-aware grouping', () {
      expect(
        formatCurrencyAmount(120400, currency: 'INR'),
        '₹ 1,20,400',
      );
      expect(
        formatCurrencyAmount(1234.56, currency: 'INR'),
        '₹ 1,234.56',
      );
      expect(
        formatCurrencyAmount(1234.5, currency: 'USD'),
        'USD 1,234.50',
      );
      expect(formatCurrencyAmount(null), '—');
    });

    test('formats compact wallet amounts', () {
      expect(
        formatCompactCurrencyAmount(840000, currency: 'INR'),
        '₹ 8.40L',
      );
      expect(
        formatCompactCurrencyAmount(98600, currency: 'INR'),
        '₹ 98,600',
      );
      expect(
        formatCompactCurrencyAmount(1500, currency: 'USD'),
        'USD 1,500',
      );
    });

    test('formats status labels and dates defensively', () {
      expect(formatStatusLabel('in_progress'), 'In Progress');
      expect(formatStatusLabel(null), '—');
      expect(formatApiDate(null), isNull);
      expect(formatApiDate('2026-09-09'), '09 Sep 2026');
    });
  });

  group('WalletScreen', () {
    testWidgets('shows a loading skeleton', (tester) async {
      setSurface(tester);
      final wallet = Completer<RefereeWalletSummary>();
      final transactions = Completer<RefereeWalletTransactionsPage>();

      await tester.pumpWidget(
        app(
          WalletScreen(
            walletFuture: wallet.future,
            transactionsFuture: transactions.future,
          ),
        ),
      );
      await tester.pump();

      expect(find.byType(SportoShimmer), findsWidgets);
      expect(find.text('Wallet balance'), findsNothing);

      wallet.complete(walletSummary());
      transactions.complete(transactionsPage(const []));
      await tester.pump();
    });

    testWidgets('shows an error with retry when the wallet fails',
        (tester) async {
      setSurface(tester);
      final wallet = Completer<RefereeWalletSummary>();
      final transactions = Completer<RefereeWalletTransactionsPage>();

      await tester.pumpWidget(
        app(
          WalletScreen(
            walletFuture: wallet.future,
            transactionsFuture: transactions.future,
          ),
        ),
      );
      await tester.pump();

      wallet.completeError(Exception('offline'));
      transactions.complete(transactionsPage(const []));
      await tester.pump();
      await tester.pump();

      expect(find.text('Unable to load wallet'), findsOneWidget);
      expect(find.text('Retry'), findsOneWidget);
    });

    testWidgets('renders API balance, stats and recent transactions',
        (tester) async {
      setSurface(tester);
      await pumpScreen(
        tester,
        WalletScreen(
          walletFuture: Future.value(walletSummary()),
          transactionsFuture: Future.value(
            transactionsPage([earningTx()]),
          ),
        ),
      );

      expect(find.text('Wallet balance'), findsOneWidget);
      expect(find.text('₹ 1,20,400'), findsOneWidget);
      expect(find.text('Pending Settlement'), findsOneWidget);
      expect(find.text('₹ 98,600'), findsOneWidget);
      expect(find.text('Total Earnings'), findsOneWidget);
      expect(find.text('₹ 8.40L'), findsOneWidget);
      expect(find.text('Recent Transactions'), findsOneWidget);
      expect(find.byType(WalletLedgerTile), findsOneWidget);
      expect(find.text('Match earnings'), findsOneWidget);
      expect(find.textContaining('Gachibowli'), findsOneWidget);
      expect(find.text('Paid'), findsOneWidget);
      expect(find.text('+₹ 3,000'), findsOneWidget);
    });

    testWidgets('hides the recent section when the ledger is empty',
        (tester) async {
      setSurface(tester);
      await pumpScreen(
        tester,
        WalletScreen(
          walletFuture: Future.value(walletSummary()),
          transactionsFuture: Future.value(transactionsPage(const [])),
        ),
      );

      expect(find.text('Recent Transactions'), findsNothing);
      expect(find.byType(WalletLedgerTile), findsNothing);
      expect(find.text('Wallet not set up yet'), findsNothing);
    });

    testWidgets('shows a setup empty state when no wallet data exists',
        (tester) async {
      setSurface(tester);
      await pumpScreen(
        tester,
        WalletScreen(
          walletFuture: Future.value(
            walletSummary(
              balance: null,
              pending: null,
              total: null,
              walletExists: false,
            ),
          ),
          transactionsFuture: Future.value(transactionsPage(const [])),
        ),
      );

      expect(find.text('Wallet not set up yet'), findsOneWidget);
      expect(find.text('Recent Transactions'), findsNothing);
    });

    testWidgets('download statement shows an honest snackbar', (tester) async {
      setSurface(tester);
      await pumpScreen(
        tester,
        WalletScreen(
          walletFuture: Future.value(walletSummary()),
          transactionsFuture: Future.value(transactionsPage(const [])),
        ),
      );

      await tester.tap(find.text('Download Statement'));
      await tester.pump();

      expect(
        find.text('Statement downloads are not available yet.'),
        findsOneWidget,
      );
    });

    testWidgets('withdraw shows an honest snackbar', (tester) async {
      setSurface(tester);
      await pumpScreen(
        tester,
        WalletScreen(
          walletFuture: Future.value(walletSummary()),
          transactionsFuture: Future.value(transactionsPage(const [])),
        ),
      );

      await tester.tap(find.text('Withdraw'));
      await tester.pump();

      expect(
        find.text('Withdrawals are not available yet.'),
        findsOneWidget,
      );
    });

    testWidgets('Add bank opens the bank accounts screen', (tester) async {
      setSurface(tester);
      await pumpScreen(
        tester,
        WalletScreen(
          walletFuture: Future.value(walletSummary()),
          transactionsFuture: Future.value(transactionsPage(const [])),
        ),
      );

      await tester.tap(find.text('Add bank'));
      await tester.pumpAndSettle();

      expect(find.byType(BankAccountsScreen), findsOneWidget);
    });
  });

  group('WalletTransactionsScreen', () {
    testWidgets('shows a loading skeleton', (tester) async {
      setSurface(tester);
      final page = Completer<RefereeWalletTransactionsPage>();

      await tester.pumpWidget(
        app(WalletTransactionsScreen(transactionsFuture: page.future)),
      );
      await tester.pump();

      expect(find.byType(SportoShimmer), findsWidgets);

      page.complete(transactionsPage(const []));
      await tester.pump();
    });

    testWidgets('shows an error with retry', (tester) async {
      setSurface(tester);
      final page = Completer<RefereeWalletTransactionsPage>();

      await tester.pumpWidget(
        app(WalletTransactionsScreen(transactionsFuture: page.future)),
      );
      await tester.pump();

      page.completeError(Exception('offline'));
      await tester.pump();
      await tester.pump();

      expect(find.text('Unable to load transactions'), findsOneWidget);
      expect(find.text('Retry'), findsOneWidget);
    });

    testWidgets('All tab renders real rows and tabs filter by category',
        (tester) async {
      setSurface(tester);
      await pumpScreen(
        tester,
        WalletTransactionsScreen(
          transactionsFuture: Future.value(
            transactionsPage([
              earningTx(
                id: 1,
                title: 'Older earning',
                createdAt: '2026-09-09T10:00:00Z',
              ),
              withdrawalTx(
                id: 2,
                title: 'Newer payout',
                createdAt: '2026-09-10T10:00:00Z',
              ),
            ]),
          ),
        ),
      );

      expect(find.byType(WalletLedgerTile), findsNWidgets(2));
      expect(find.text('Older earning'), findsOneWidget);
      expect(find.text('Newer payout'), findsOneWidget);

      await tester.tap(find.text('Earnings'));
      await tester.pump();
      expect(find.byType(WalletLedgerTile), findsOneWidget);
      expect(find.text('Older earning'), findsOneWidget);
      expect(find.text('Newer payout'), findsNothing);

      await tester.tap(find.text('Withdrawals'));
      await tester.pump();
      expect(find.byType(WalletLedgerTile), findsOneWidget);
      expect(find.text('Newer payout'), findsOneWidget);
      expect(find.text('Older earning'), findsNothing);

      await tester.tap(find.text('All'));
      await tester.pump();
      expect(find.byType(WalletLedgerTile), findsNWidgets(2));
    });

    testWidgets('sort toggles the local ordering', (tester) async {
      setSurface(tester);
      await pumpScreen(
        tester,
        WalletTransactionsScreen(
          transactionsFuture: Future.value(
            transactionsPage([
              earningTx(
                id: 1,
                title: 'Older earning',
                createdAt: '2026-09-09T10:00:00Z',
              ),
              withdrawalTx(
                id: 2,
                title: 'Newer payout',
                createdAt: '2026-09-10T10:00:00Z',
              ),
            ]),
          ),
        ),
      );

      List<String> visibleTitles() => tester
          .widgetList<WalletLedgerTile>(find.byType(WalletLedgerTile))
          .map((tile) => tile.transaction.displayTitle)
          .toList(growable: false);

      expect(visibleTitles().first, 'Newer payout');

      await tester.tap(find.byType(WalletSortButton));
      await tester.pump();

      expect(visibleTitles().first, 'Older earning');
    });

    testWidgets('empty tabs show their own empty states', (tester) async {
      setSurface(tester);
      await pumpScreen(
        tester,
        WalletTransactionsScreen(
          transactionsFuture: Future.value(transactionsPage(const [])),
        ),
      );

      expect(find.text('No transactions yet'), findsOneWidget);

      await tester.tap(find.text('Earnings'));
      await tester.pump();
      expect(find.text('No earnings yet'), findsOneWidget);

      await tester.tap(find.text('Withdrawals'));
      await tester.pump();
      expect(find.text('No withdrawals yet'), findsOneWidget);
    });

    testWidgets('missing fields render em dashes, never invented values',
        (tester) async {
      setSurface(tester);
      await pumpScreen(
        tester,
        WalletTransactionsScreen(
          transactionsFuture: Future.value(
            transactionsPage([RefereeWalletTransaction(id: 9)]),
          ),
        ),
      );

      expect(find.byType(WalletLedgerTile), findsOneWidget);
      expect(find.text('—'), findsWidgets);
    });

    testWidgets('tapping a row opens the details screen', (tester) async {
      setSurface(tester);
      await pumpScreen(
        tester,
        WalletTransactionsScreen(
          transactionsFuture: Future.value(
            transactionsPage([earningTx(id: 7, title: 'Older earning')]),
          ),
        ),
      );

      await tester.tap(find.text('Older earning'));
      await tester.pumpAndSettle();

      expect(find.byType(TransactionDetailsScreen), findsOneWidget);
      expect(find.text('Transaction Details'), findsOneWidget);
      expect(find.text('+₹ 3,000'), findsOneWidget);
      expect(find.text('TXN-7'), findsOneWidget);
    });
  });

  group('TransactionDetailsScreen', () {
    testWidgets('shows an explicit state without a transaction',
        (tester) async {
      setSurface(tester);
      await pumpScreen(tester, const TransactionDetailsScreen());

      expect(
        find.text('Transaction details are not available yet.'),
        findsOneWidget,
      );
    });

    testWidgets('renders only fields present on the tapped row',
        (tester) async {
      setSurface(tester);
      await pumpScreen(
        tester,
        TransactionDetailsScreen(transaction: earningTx()),
      );

      expect(find.text('Transaction Details'), findsOneWidget);
      expect(find.text('+₹ 3,000'), findsOneWidget);
      expect(find.text('Earnings'), findsOneWidget);
      expect(find.text('Paid'), findsOneWidget);
      expect(find.text('Transaction Ref'), findsOneWidget);
      expect(find.text('TXN-1'), findsOneWidget);
      expect(find.text('Payment Method'), findsOneWidget);
      expect(find.text('Spoto Wallet Credit'), findsOneWidget);
      expect(find.text('Direction'), findsOneWidget);
      expect(find.text('Credited'), findsOneWidget);
      expect(find.text('Description'), findsOneWidget);
      expect(find.text('Match earnings'), findsOneWidget);
      expect(find.text('Referee fee'), findsOneWidget);
      expect(find.text('Tournament Details'), findsOneWidget);
      expect(
        find.text('Gachibowli Super Over Qualifier'),
        findsOneWidget,
      );
    });

    testWidgets('omits sections whose fields are absent', (tester) async {
      setSurface(tester);
      await pumpScreen(
        tester,
        TransactionDetailsScreen(
          transaction: RefereeWalletTransaction(id: 9),
        ),
      );

      expect(find.text('Transaction Ref'), findsOneWidget);
      expect(find.text('Payment Method'), findsNothing);
      expect(find.text('Direction'), findsNothing);
      expect(find.text('Description'), findsNothing);
      expect(find.text('Tournament Details'), findsNothing);
      expect(find.text('—'), findsWidgets);
    });
  });

  group('TournamentsHistoryScreen', () {
    testWidgets('shows a loading skeleton', (tester) async {
      setSurface(tester);
      final page = Completer<RefereeTournamentHistoryPage>();

      await tester.pumpWidget(
        app(TournamentsHistoryScreen(tournamentsFuture: page.future)),
      );
      await tester.pump();

      expect(find.byType(SportoShimmer), findsWidgets);

      page.complete(tournamentsPage(const []));
      await tester.pump();
    });

    testWidgets('shows an error with retry', (tester) async {
      setSurface(tester);
      final page = Completer<RefereeTournamentHistoryPage>();

      await tester.pumpWidget(
        app(TournamentsHistoryScreen(tournamentsFuture: page.future)),
      );
      await tester.pump();

      page.completeError(Exception('offline'));
      await tester.pump();
      await tester.pump();

      expect(find.text('Unable to load tournaments'), findsOneWidget);
      expect(find.text('Retry'), findsOneWidget);
    });

    testWidgets('renders only the fields supplied by the API', (tester) async {
      setSurface(tester);
      await pumpScreen(
        tester,
        TournamentsHistoryScreen(
          tournamentsFuture: Future.value(
            tournamentsPage([
              tournament(
                id: 1,
                name: 'Hitech City Super Over Cup',
                code: 'T-1001',
                status: 7,
                currency: 'INR',
              ),
              tournament(
                id: 2,
                name: 'Cancelled Cup',
                code: 'T-1002',
                status: 8,
                currency: 'USD',
              ),
            ]),
          ),
        ),
      );

      expect(find.text('Hitech City Super Over Cup'), findsOneWidget);
      expect(find.text('T-1001'), findsOneWidget);
      expect(find.text('INR'), findsOneWidget);
      expect(find.text('Cancelled Cup'), findsNothing);
      expect(find.textContaining('Teams'), findsNothing);
      expect(find.textContaining('Venue'), findsNothing);

      await tester.tap(find.text('Cancelled'));
      await tester.pump();

      expect(find.text('Cancelled Cup'), findsOneWidget);
      expect(find.text('T-1002'), findsOneWidget);
      expect(find.text('USD'), findsOneWidget);
      expect(find.text('Hitech City Super Over Cup'), findsNothing);
    });

    testWidgets('missing code and currency render em dashes', (tester) async {
      setSurface(tester);
      await pumpScreen(
        tester,
        TournamentsHistoryScreen(
          tournamentsFuture: Future.value(
            tournamentsPage([
              tournament(
                id: 1,
                name: 'Hitech City Super Over Cup',
                status: 7,
              ),
            ]),
          ),
        ),
      );

      expect(find.text('—'), findsNWidgets(2));
    });

    testWidgets('cancelled filter shows its empty state', (tester) async {
      setSurface(tester);
      await pumpScreen(
        tester,
        TournamentsHistoryScreen(
          tournamentsFuture: Future.value(
            tournamentsPage([
              tournament(id: 1, name: 'Completed Cup', status: 7),
            ]),
          ),
        ),
      );

      await tester.tap(find.text('Cancelled'));
      await tester.pump();

      expect(find.text('No cancelled tournaments yet'), findsOneWidget);
      expect(find.text('Completed Cup'), findsNothing);
    });

    testWidgets('card actions show honest snackbars', (tester) async {
      setSurface(tester);
      await pumpScreen(
        tester,
        TournamentsHistoryScreen(
          tournamentsFuture: Future.value(
            tournamentsPage([
              tournament(id: 1, name: 'Completed Cup', status: 7),
            ]),
          ),
        ),
      );

      await tester.tap(find.text('View'));
      await tester.pump();
      expect(find.text('View is not available yet.'), findsOneWidget);
    });

    testWidgets('create shows an honest snackbar', (tester) async {
      setSurface(tester);
      await pumpScreen(
        tester,
        TournamentsHistoryScreen(
          tournamentsFuture: Future.value(tournamentsPage(const [])),
        ),
      );

      await tester.tap(find.text('Create'));
      await tester.pump();

      expect(
        find.text('Tournament creation is not available yet.'),
        findsOneWidget,
      );
    });
  });

  group('responsive layout', () {
    testWidgets('all four screens fit between 320 and 430 px', (tester) async {
      final screens = <Widget>[
        TournamentsHistoryScreen(
          tournamentsFuture: Future.value(
            tournamentsPage([
              tournament(
                id: 1,
                name: 'Hitech City Super Over Cup',
                code: 'T-1001',
                status: 7,
                currency: 'INR',
              ),
            ]),
          ),
        ),
        WalletScreen(
          walletFuture: Future.value(walletSummary()),
          transactionsFuture: Future.value(
            transactionsPage([earningTx()]),
          ),
        ),
        WalletTransactionsScreen(
          transactionsFuture: Future.value(
            transactionsPage([earningTx(), withdrawalTx()]),
          ),
        ),
        TransactionDetailsScreen(transaction: earningTx()),
      ];
      for (final size in const [Size(320, 800), Size(430, 900)]) {
        setSurface(tester, size: size);
        for (final screen in screens) {
          await tester.pumpWidget(app(screen));
          await tester.pump();
          await tester.pump();
          expect(
            tester.takeException(),
            isNull,
            reason: '${screen.runtimeType} overflowed at $size',
          );
        }
      }
    });
  });
}
