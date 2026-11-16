import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:referee_app/features/wallet/presentation/screens/tournaments_history_screen.dart';
import 'package:referee_app/features/wallet/presentation/screens/transaction_details_screen.dart';
import 'package:referee_app/features/wallet/presentation/screens/wallet_screen.dart';
import 'package:referee_app/features/wallet/presentation/screens/wallet_transactions_screen.dart';
import 'package:referee_app/features/wallet/presentation/wallet_figma_data.dart';
import 'package:referee_app/features/wallet/presentation/wallet_models.dart';
import 'package:referee_app/features/wallet/presentation/widgets/wallet_shared_widgets.dart';
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

    test('can skip grouping for the Figma description variant', () {
      expect(
        formatIndianRupees(1000, space: false, grouping: false),
        '₹1000',
      );
    });

    test('formats compact lakh / crore labels', () {
      expect(formatIndianCompactRupees(840000), '₹ 8.40L');
      expect(formatIndianCompactRupees(12500000), '₹ 1.25Cr');
      expect(formatIndianCompactRupees(98600), '₹ 98,600');
    });
  });

  group('WalletScreen', () {
    testWidgets('renders balance, stat cards and recent transactions',
        (tester) async {
      setSurface(tester);
      await tester.pumpWidget(app(const WalletScreen()));
      await tester.pump();

      expect(find.text('Wallet balance'), findsOneWidget);
      expect(find.text('₹ 1,20,400'), findsOneWidget);
      expect(find.text('Pending Settlement'), findsOneWidget);
      expect(find.text('₹ 98,600'), findsOneWidget);
      expect(find.text('Total Earnings'), findsOneWidget);
      expect(find.text('₹ 8.40L'), findsOneWidget);
      expect(find.text('Transaction History'), findsOneWidget);
      expect(find.text('Download Statement'), findsOneWidget);
      expect(find.text('Recent Transactions'), findsOneWidget);

      expect(find.text('Gachibowli Super Over Qualifier'), findsOneWidget);
      expect(find.text('Hyd Super Over Premier League'), findsOneWidget);
      expect(find.text('₹ 3,000'), findsOneWidget);
      expect(find.text('₹ 3,800'), findsOneWidget);
      expect(find.text('Processing'), findsOneWidget);
      expect(find.text('Paid'), findsOneWidget);
      expect(find.text('by User'), findsOneWidget);
      expect(find.text('by Partner'), findsOneWidget);
    });

    testWidgets('transaction tap opens the details screen', (tester) async {
      setSurface(tester);
      await tester.pumpWidget(app(const WalletScreen()));
      await tester.pump();

      await tester.tap(find.text('Gachibowli Super Over Qualifier'));
      await tester.pumpAndSettle();

      expect(find.byType(TransactionDetailsScreen), findsOneWidget);
      expect(find.text('Transaction Details'), findsOneWidget);
      expect(find.text('+₹3,000'), findsOneWidget);
      expect(find.text('Earnings'), findsOneWidget);
      expect(find.text('Processing'), findsOneWidget);
      expect(find.text('Transaction Ref'), findsOneWidget);
      expect(find.text('TXN-88213'), findsOneWidget);
      expect(find.text('Payment Method'), findsOneWidget);
      expect(find.text('Spoto Wallet Credit'), findsOneWidget);
      expect(find.text('Direction'), findsOneWidget);
      expect(find.text('Credited'), findsOneWidget);
      expect(find.text('Description'), findsOneWidget);
      expect(find.text('Gachibowli Super Over Qualifier'), findsWidgets);
      expect(find.text('Match earnings'), findsOneWidget);
      expect(find.text('Tournament Details'), findsOneWidget);
    });

    testWidgets('empty recent transactions show a clean empty state',
        (tester) async {
      setSurface(tester);
      await tester.pumpWidget(
        app(
          const WalletScreen(
            overview: WalletOverview(
              balanceRupees: 0,
              pendingSettlementRupees: 0,
              totalEarningsRupees: 0,
            ),
          ),
        ),
      );
      await tester.pump();

      expect(find.text('No transactions yet'), findsOneWidget);
    });

    testWidgets('does not overflow at 320 px width', (tester) async {
      setSurface(tester, size: const Size(320, 800));
      await tester.pumpWidget(app(const WalletScreen()));
      await tester.pump();

      expect(tester.takeException(), isNull);
    });
  });

  group('WalletTransactionsScreen', () {
    testWidgets('All tab renders every transaction', (tester) async {
      setSurface(tester);
      await tester.pumpWidget(app(const WalletTransactionsScreen()));
      await tester.pump();

      expect(find.byType(WalletTransactionTile), findsNWidgets(2));
      expect(find.text('Gachibowli Super Over Qualifier'), findsOneWidget);
      expect(find.text('Hyd Super Over Premier League'), findsOneWidget);
    });

    testWidgets('Earnings and Withdrawals tabs filter the list',
        (tester) async {
      setSurface(tester);
      await tester.pumpWidget(app(const WalletTransactionsScreen()));
      await tester.pump();

      await tester.tap(find.text('Earnings'));
      await tester.pump();
      expect(find.byType(WalletTransactionTile), findsNWidgets(2));

      await tester.tap(find.text('Withdrawals'));
      await tester.pump();
      expect(find.byType(WalletTransactionTile), findsNothing);
      expect(find.text('No withdrawals yet'), findsOneWidget);

      await tester.tap(find.text('All'));
      await tester.pump();
      expect(find.byType(WalletTransactionTile), findsNWidgets(2));
    });

    testWidgets('empty list shows a clean empty state', (tester) async {
      setSurface(tester);
      await tester.pumpWidget(
        app(const WalletTransactionsScreen(transactions: [])),
      );
      await tester.pump();

      expect(find.text('No transactions yet'), findsOneWidget);
      expect(find.byType(WalletTransactionTile), findsNothing);
    });

    testWidgets('transaction tap opens the details screen', (tester) async {
      setSurface(tester);
      await tester.pumpWidget(app(const WalletTransactionsScreen()));
      await tester.pump();

      await tester.tap(find.text('Hyd Super Over Premier League'));
      await tester.pumpAndSettle();

      expect(find.byType(TransactionDetailsScreen), findsOneWidget);
      expect(find.text('Transaction Details'), findsOneWidget);
      expect(find.text('+₹3,800'), findsOneWidget);
      expect(find.text('TXN-88214'), findsOneWidget);
    });
  });

  group('TournamentsHistoryScreen', () {
    testWidgets('renders badges, team counts and card actions', (tester) async {
      setSurface(tester);
      await tester.pumpWidget(app(const TournamentsHistoryScreen()));
      await tester.pump();

      expect(find.text('Tournaments History'), findsOneWidget);
      expect(find.text('Completed'), findsOneWidget);
      expect(find.text('Cancelled'), findsOneWidget);
      expect(find.text('Create'), findsOneWidget);
      expect(find.text('Local'), findsNWidgets(2));
      expect(find.text('Approved'), findsNWidgets(2));
      expect(find.text('Hitech City Super Over Cup'), findsNWidgets(2));
      expect(find.text('Hitech Box Cricket Arena'), findsNWidgets(2));
      expect(find.text('Aug 5'), findsNWidgets(2));
      expect(find.text('41/64 Teams'), findsNWidgets(2));
      expect(find.text('₹ 3,800'), findsNWidgets(2));
      expect(find.text('View'), findsNWidgets(2));
      expect(find.text('Manage'), findsNWidgets(2));
      expect(find.text('Earnings'), findsNWidgets(2));
    });

    testWidgets('Cancelled filter shows its empty state', (tester) async {
      setSurface(tester);
      await tester.pumpWidget(app(const TournamentsHistoryScreen()));
      await tester.pump();

      await tester.tap(find.text('Cancelled'));
      await tester.pump();

      expect(find.text('No cancelled tournaments yet'), findsOneWidget);
      expect(find.text('Hitech City Super Over Cup'), findsNothing);
    });

    testWidgets('does not overflow at 360 px width', (tester) async {
      setSurface(tester, size: const Size(360, 800));
      await tester.pumpWidget(app(const TournamentsHistoryScreen()));
      await tester.pump();

      expect(tester.takeException(), isNull);
    });
  });

  group('responsive layout', () {
    testWidgets('all four screens fit between 320 and 430 px', (tester) async {
      final screens = <Widget>[
        const TournamentsHistoryScreen(),
        const WalletScreen(),
        const WalletTransactionsScreen(),
        const TransactionDetailsScreen(),
      ];
      for (final size in const [Size(320, 800), Size(430, 900)]) {
        setSurface(tester, size: size);
        for (final screen in screens) {
          await tester.pumpWidget(app(screen));
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

  group('TransactionDetailsScreen', () {
    testWidgets('renders the receipt fields', (tester) async {
      setSurface(tester);
      await tester.pumpWidget(
        app(
          const TransactionDetailsScreen(
            detail: WalletFigmaData.transactionDetail,
          ),
        ),
      );
      await tester.pump();

      expect(find.text('Transaction Details'), findsOneWidget);
      expect(find.textContaining('TXN-88213'), findsOneWidget);
      expect(find.text('+₹1,000'), findsOneWidget);
      expect(find.text('Sponsorship'), findsOneWidget);
      expect(find.text('Completed'), findsOneWidget);
      expect(find.text('Transaction Ref'), findsOneWidget);
      expect(find.text('TXN-88301'), findsOneWidget);
      expect(find.text('Payment Method'), findsOneWidget);
      expect(find.text('Spoto Wallet Credit'), findsOneWidget);
      expect(find.text('Direction'), findsOneWidget);
      expect(find.text('Credited'), findsOneWidget);
      expect(find.text('Description'), findsOneWidget);
      expect(find.text('Kondapur Super Over Cup'), findsOneWidget);
      expect(find.text('Winner Prize (your split)'), findsOneWidget);
      expect(find.text('₹1000'), findsOneWidget);
      expect(find.text('Tournament Details'), findsOneWidget);
      expect(find.text('Spoto Kondapur Super Over Cup'), findsOneWidget);
    });
  });
}
