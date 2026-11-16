import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:referee_app/features/bank/presentation/bank_models.dart';
import 'package:referee_app/features/bank/presentation/bank_store.dart';
import 'package:referee_app/features/bank/presentation/screens/add_bank_account_screen.dart';
import 'package:referee_app/features/bank/presentation/screens/bank_account_details_screen.dart';
import 'package:referee_app/features/bank/presentation/screens/bank_accounts_screen.dart';
import 'package:referee_app/features/bank/presentation/screens/bank_onboarding_screen.dart';
import 'package:ui_kit/ui_kit.dart';

Widget _app(Widget child, {bool productionTextScale = false}) {
  if (!productionTextScale) {
    return MaterialApp(theme: SportoTheme.darkTheme, home: child);
  }
  return MaterialApp(
    theme: SportoTheme.darkTheme,
    builder: (context, routeChild) => SportoAppTextScale(
      child: routeChild ?? const SizedBox.shrink(),
    ),
    home: child,
  );
}

void _useScreenSize(WidgetTester tester, Size size) {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(() {
    tester.view.resetPhysicalSize();
    tester.view.resetDevicePixelRatio();
  });
}

Future<void> _fillValidForm(WidgetTester tester) async {
  await tester.enterText(
    find.byKey(const ValueKey('bank_field_bank_name')),
    'HDFC Bank',
  );
  await tester.enterText(
    find.byKey(const ValueKey('bank_field_branch_name')),
    'Gachibowli',
  );
  await tester.enterText(
    find.byKey(const ValueKey('bank_field_ifsc')),
    'HDFC0001234',
  );
  await tester.enterText(
    find.byKey(const ValueKey('bank_field_holder_name')),
    'Rajesh Kumar',
  );
  await tester.enterText(
    find.byKey(const ValueKey('bank_field_account_number')),
    '50100123454521',
  );
}

void main() {
  setUp(BankAccountsStore.instance.reset);

  group('Bank account formatting', () {
    test('masks all but the final four characters', () {
      expect(maskAccountNumber('50100123454521'), 'XXXX XXXX 4521');
      expect(maskAccountNumber('123456789'), 'XXXX XXXX 6789');
      expect(maskAccountNumber('12345678'), 'XXXX XXXX');
      expect(maskAccountNumber('1234'), 'XXXX XXXX');
      expect(maskAccountNumber(''), '');
    });

    test('IFSC validator accepts the Figma value and rejects invalid input',
        () {
      expect(validateBankIfsc('HDFC0001234'), isNull);
      expect(validateBankIfsc('SBIN0001234'), isNull);

      expect(validateBankIfsc(null), 'Enter IFSC code');
      expect(validateBankIfsc(''), 'Enter IFSC code');
      expect(validateBankIfsc('HDFC001234'), 'Enter a valid IFSC code');
      expect(validateBankIfsc('hdfc0001234'), isNull);
      expect(validateBankIfsc('HDFC000123'), 'Enter a valid IFSC code');
    });

    test('account number validator enforces 9-18 digits', () {
      expect(validateBankAccountNumber('123456789'), isNull);
      expect(validateBankAccountNumber('123456789012345678'), isNull);
      expect(validateBankAccountNumber('12345678'),
          'Account number must be 9-18 digits');
      expect(
        validateBankAccountNumber('1234567890123456789'),
        'Account number must be 9-18 digits',
      );
      expect(validateBankAccountNumber('12A456789'),
          'Account number must be 9-18 digits');
      expect(validateBankAccountNumber(''), 'Enter account number');
    });
  });

  group('Bank onboarding screen', () {
    testWidgets('renders the empty copy and opens the add form',
        (tester) async {
      _useScreenSize(tester, const Size(390, 844));
      await tester.pumpWidget(_app(const BankOnboardingScreen()));

      expect(find.text('Back Account'), findsOneWidget);
      expect(
        find.text('No Bank Found! Please add your bank account.'),
        findsOneWidget,
      );
      expect(find.text('No Bank Account'), findsOneWidget);
      expect(find.text('Please Add Your Bank Account'), findsOneWidget);
      expect(find.text('Add Bank'), findsOneWidget);

      await tester.tap(find.text('Add Bank'));
      await tester.pumpAndSettle();

      expect(find.text('Add Bank Account'), findsOneWidget);
      expect(find.text('Save Bank'), findsOneWidget);
    });
  });

  group('Add bank account form', () {
    testWidgets('shows required-field errors for an empty submit',
        (tester) async {
      _useScreenSize(tester, const Size(390, 844));
      await tester.pumpWidget(_app(const AddBankAccountScreen()));

      await tester.ensureVisible(find.text('Save Bank'));
      await tester.tap(find.text('Save Bank'));
      await tester.pump();

      expect(find.text('Enter bank name'), findsWidgets);
      expect(find.text('Enter branch name'), findsOneWidget);
      expect(find.text('Enter IFSC code'), findsWidgets);
      expect(find.text('Enter account holder name'), findsOneWidget);
      expect(find.text('Enter account number'), findsWidgets);
      expect(find.text('Enter a valid IFSC code'), findsNothing);
    });

    testWidgets('rejects an invalid IFSC with an inline error', (tester) async {
      _useScreenSize(tester, const Size(390, 844));
      await tester.pumpWidget(_app(const AddBankAccountScreen()));

      await _fillValidForm(tester);
      await tester.enterText(
        find.byKey(const ValueKey('bank_field_ifsc')),
        'HDFC123',
      );

      await tester.ensureVisible(find.text('Save Bank'));
      await tester.tap(find.text('Save Bank'));
      await tester.pump();

      expect(find.text('Enter a valid IFSC code'), findsOneWidget);
      expect(find.text('Saving…'), findsNothing);
    });

    testWidgets('saves valid details and shows the success SnackBar',
        (tester) async {
      _useScreenSize(tester, const Size(390, 844));
      BankAccountDetails? saved;
      await tester.pumpWidget(
        _app(
          AddBankAccountScreen(
            onSaved: (details) => saved = details,
          ),
        ),
      );

      await _fillValidForm(tester);
      await tester.ensureVisible(find.text('Save Bank'));
      await tester.tap(find.text('Save Bank'));
      await tester.pump();

      expect(find.text('Saving…'), findsOneWidget);

      await tester.pump(const Duration(milliseconds: 400));
      await tester.pump();

      expect(saved?.ifscCode, 'HDFC0001234');
      expect(saved?.accountNumber, '50100123454521');
      expect(find.text('Bank account added. Verification is pending.'),
          findsOneWidget);
    });

    testWidgets('newly added account appears in the bank list', (tester) async {
      _useScreenSize(tester, const Size(390, 844));
      await tester.pumpWidget(
        _app(const AddBankAccountScreen(submitDelay: Duration.zero)),
      );

      await _fillValidForm(tester);
      await tester.ensureVisible(find.text('Save Bank'));
      await tester.tap(find.text('Save Bank'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50));

      await tester.pumpWidget(_app(const BankAccountsScreen()));

      expect(find.text('4 Banks Accounts'), findsOneWidget);
      expect(find.text('HDFC Bank'), findsNWidgets(2));
      expect(find.text('A/c XXXX XXXX 4521'), findsOneWidget);
    });
  });

  group('Bank accounts list', () {
    testWidgets('renders three banks with masked account numbers',
        (tester) async {
      _useScreenSize(tester, const Size(390, 844));
      await tester.pumpWidget(_app(const BankAccountsScreen()));

      expect(find.text('Back Account'), findsOneWidget);
      expect(find.text('3 Banks Accounts'), findsOneWidget);
      expect(find.text('Add bank'), findsOneWidget);

      expect(find.text('SBI Bank'), findsOneWidget);
      expect(find.text('HDFC Bank'), findsOneWidget);
      expect(find.text('BOB Bank'), findsOneWidget);

      expect(find.text('A/c XXXX XXXX 9012'), findsOneWidget);
      expect(find.text('A/c XXXX XXXX 7812'), findsOneWidget);
      expect(find.text('A/c XXXX XXXX 1050'), findsOneWidget);
      expect(find.textContaining('501234567812'), findsNothing);
    });

    testWidgets('opens details for a tapped account', (tester) async {
      _useScreenSize(tester, const Size(390, 844));
      await tester.pumpWidget(_app(const BankAccountsScreen()));

      await tester.tap(find.text('HDFC Bank'));
      await tester.pumpAndSettle();

      expect(find.text('Bank Account Details'), findsOneWidget);
      expect(find.text('XXXX XXXX 7812'), findsOneWidget);
      expect(find.text('HDFC0001234'), findsOneWidget);
    });

    testWidgets('renders an explicit empty state', (tester) async {
      _useScreenSize(tester, const Size(390, 844));
      await tester.pumpWidget(
        _app(const BankAccountsScreen(accounts: <BankAccount>[])),
      );

      expect(find.text('0 Banks Accounts'), findsOneWidget);
      expect(find.text('No Bank Account'), findsOneWidget);
      expect(
        find.text('Please add your bank account to receive payouts.'),
        findsOneWidget,
      );
      expect(find.text('Add Bank'), findsOneWidget);
    });
  });

  group('Bank account details', () {
    testWidgets('masks the number by default and reveals it from the eye',
        (tester) async {
      _useScreenSize(tester, const Size(390, 844));
      await tester.pumpWidget(_app(const BankAccountDetailsScreen()));

      expect(find.text('XXXX XXXX 4521'), findsOneWidget);
      expect(find.text('50100123454521'), findsNothing);
      expect(find.byTooltip('Show account number'), findsOneWidget);
      expect(
        tester.getSize(find.byKey(const ValueKey('bank_eye_toggle'))),
        const Size(44, 44),
      );
      expect(find.text('Verified'), findsOneWidget);
      expect(find.text('HDFC Bank'), findsOneWidget);
      expect(find.text('HDFC0001234'), findsOneWidget);
      expect(find.text('Rajesh Kumar'), findsOneWidget);
      expect(find.text('turfenergy@okhdfcbank'), findsOneWidget);

      await tester.tap(find.byKey(const ValueKey('bank_eye_toggle')));
      await tester.pump();

      expect(find.text('XXXX XXXX 4521'), findsNothing);
      expect(find.text('50100123454521'), findsOneWidget);
      expect(find.byTooltip('Hide account number'), findsOneWidget);

      await tester.tap(find.byKey(const ValueKey('bank_eye_toggle')));
      await tester.pump();

      expect(find.text('XXXX XXXX 4521'), findsOneWidget);
      expect(find.text('50100123454521'), findsNothing);
    });

    testWidgets('re-verify asks for re-verification', (tester) async {
      _useScreenSize(tester, const Size(390, 844));
      await tester.pumpWidget(_app(const BankAccountDetailsScreen()));

      await tester.ensureVisible(find.text('Re-verify Bank Account'));
      await tester.tap(find.text('Re-verify Bank Account'));
      await tester.pump();

      expect(
        find.text('Re-verification is not available yet'),
        findsOneWidget,
      );
    });
  });

  group('Responsive layouts', () {
    for (final size in const [Size(320, 640), Size(430, 932)]) {
      testWidgets('bank screens have no overflow at ${size.width.toInt()} px',
          (tester) async {
        _useScreenSize(tester, size);

        final screens = <Widget>[
          const BankOnboardingScreen(),
          const AddBankAccountScreen(submitDelay: Duration.zero),
          const BankAccountsScreen(),
          const BankAccountDetailsScreen(),
        ];

        for (final screen in screens) {
          await tester.pumpWidget(
            _app(screen, productionTextScale: true),
          );
          await tester.pumpAndSettle();
          expect(
            tester.takeException(),
            isNull,
            reason: '${screen.runtimeType} at ${size.width}px',
          );
        }
      });
    }
  });
}
