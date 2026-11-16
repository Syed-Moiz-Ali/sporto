import 'dart:async';

import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:referee_app/features/bank/presentation/bank_models.dart';
import 'package:referee_app/features/bank/presentation/screens/add_bank_account_screen.dart';
import 'package:referee_app/features/bank/presentation/screens/bank_account_details_screen.dart';
import 'package:referee_app/features/bank/presentation/screens/bank_accounts_screen.dart';
import 'package:referee_app/features/bank/presentation/screens/bank_onboarding_screen.dart';
import 'package:referee_data/referee_data.dart';
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
    'hdfc0001234',
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

RefereeBankDetails _bank({
  int id = 1,
  bool isDefault = false,
  String verificationLabel = 'Verified',
}) {
  return RefereeBankDetails(
    id: id,
    type: 'BANK',
    accountHolderName: 'Rajesh Kumar',
    accountNumber: '********9012',
    maskedAccountNumber: '********9012',
    ifscCode: 'HDFC0001234',
    bankName: 'HDFC Bank',
    branchName: 'Gachibowli',
    summary: 'Bank account ending 9012',
    status: 1,
    statusLabel: 'Active',
    isActive: true,
    verificationStatus: verificationLabel == 'Verified' ? 2 : 1,
    verificationStatusLabel: verificationLabel,
    isDefault: isDefault,
  );
}

RefereeBankDetails _upi({int id = 2}) {
  return RefereeBankDetails(
    id: id,
    type: 'UPI',
    upiId: 'rahul@okaxis',
    summary: 'ra***@okaxis',
    status: 1,
    statusLabel: 'Active',
    isActive: true,
    verificationStatus: 1,
    verificationStatusLabel: 'Pending',
  );
}

void main() {
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

  group('API display mapping', () {
    test('maps BANK and UPI rows without exposing full numbers', () {
      final bank = _bank(isDefault: true);
      final upi = _upi();

      expect(bankDetailsTitle(bank), 'HDFC Bank');
      expect(bankMaskedAccountLabel(bank), '********9012');
      expect(bankFullAccountNumber(bank), isNull);
      expect(bankVerificationLabel(bank), 'Verified');
      expect(bankIsVerified(bank), isTrue);

      expect(bankDetailsTitle(upi), 'rahul@okaxis');
      expect(bankMaskedAccountLabel(upi), 'ra***@okaxis');
      expect(bankFullAccountNumber(upi), isNull);
      expect(bankVerificationLabel(upi), 'Pending');
      expect(bankIsVerified(upi), isFalse);
    });

    test('accepts an actually unmasked account number for optional reveal', () {
      final bank = RefereeBankDetails(
        id: 3,
        type: 'BANK',
        accountNumber: '50100123454521',
        maskedAccountNumber: '********4521',
        verificationStatusLabel: 'Verified',
      );

      expect(bankFullAccountNumber(bank), '50100123454521');
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
      var submitCalls = 0;
      await tester.pumpWidget(
        _app(
          AddBankAccountScreen(
            submit: (request, {existing}) async {
              submitCalls++;
              return _bank();
            },
          ),
        ),
      );

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
      expect(submitCalls, 0);
    });

    testWidgets(
        'submits the canonical request, blocks double taps and shows success',
        (tester) async {
      _useScreenSize(tester, const Size(390, 844));
      final completer = Completer<RefereeBankDetails>();
      RefereeBankDetailsRequest? captured;
      var submitCalls = 0;

      await tester.pumpWidget(
        _app(
          AddBankAccountScreen(
            makeDefault: true,
            submit: (request, {existing}) {
              submitCalls++;
              captured = request;
              return completer.future;
            },
          ),
        ),
      );

      await _fillValidForm(tester);
      await tester.ensureVisible(find.text('Save Bank'));
      await tester.tap(find.text('Save Bank'));
      await tester.pump();

      expect(find.text('Saving…'), findsOneWidget);
      await tester.tap(find.text('Saving…'));
      await tester.pump();
      expect(submitCalls, 1);

      completer.complete(_bank());
      await tester.pumpAndSettle();

      expect(captured?.toJson(), {
        'type': 'BANK',
        'details': {
          'account_number': '50100123454521',
          'account_holder': 'Rajesh Kumar',
          'ifsc': 'HDFC0001234',
        },
        'bank_name': 'HDFC Bank',
        'branch_name': 'Gachibowli',
        'is_default': true,
      });
      expect(
        find.text('Bank account added. Verification is pending.'),
        findsOneWidget,
      );
    });

    testWidgets('defaults is_default to false when the list is not empty',
        (tester) async {
      _useScreenSize(tester, const Size(390, 844));
      RefereeBankDetailsRequest? captured;

      await tester.pumpWidget(
        _app(
          AddBankAccountScreen(
            submit: (request, {existing}) async {
              captured = request;
              return _bank();
            },
          ),
        ),
      );

      await _fillValidForm(tester);
      await tester.ensureVisible(find.text('Save Bank'));
      await tester.tap(find.text('Save Bank'));
      await tester.pumpAndSettle();

      expect(captured?.toJson()['is_default'], isFalse);
    });

    testWidgets('shows an error SnackBar and re-enables the form on failure',
        (tester) async {
      _useScreenSize(tester, const Size(390, 844));
      await tester.pumpWidget(
        _app(
          AddBankAccountScreen(
            submit: (request, {existing}) async {
              throw const SportoApiException('down');
            },
          ),
        ),
      );

      await _fillValidForm(tester);
      await tester.ensureVisible(find.text('Save Bank'));
      await tester.tap(find.text('Save Bank'));
      await tester.pumpAndSettle();

      expect(
        find.text("Couldn't save bank account. Please try again."),
        findsOneWidget,
      );
      expect(find.text('Save Bank'), findsOneWidget);
      expect(find.text('Saving…'), findsNothing);
    });

    testWidgets('prefills and updates an existing bank instead of adding one',
        (tester) async {
      _useScreenSize(tester, const Size(390, 844));
      final existing = _bank(isDefault: true);
      RefereeBankDetailsRequest? captured;
      RefereeBankDetails? capturedExisting;

      await tester.pumpWidget(
        _app(
          AddBankAccountScreen(
            existing: existing,
            submit: (request, {existing}) async {
              captured = request;
              capturedExisting = existing;
              return _bank();
            },
          ),
        ),
      );

      expect(find.text('Change Bank Account'), findsOneWidget);
      expect(find.text('Update Bank'), findsOneWidget);
      expect(find.text('HDFC Bank'), findsOneWidget);
      expect(find.text('Gachibowli'), findsOneWidget);
      expect(find.text('HDFC0001234'), findsOneWidget);
      expect(find.text('Rajesh Kumar'), findsOneWidget);

      await tester.enterText(
        find.byKey(const ValueKey('bank_field_account_number')),
        '50100123454521',
      );
      await tester.ensureVisible(find.text('Update Bank'));
      await tester.tap(find.text('Update Bank'));
      await tester.pumpAndSettle();

      expect(capturedExisting?.id, existing.id);
      expect(captured?.toJson(), {
        'type': 'BANK',
        'details': {
          'account_number': '50100123454521',
          'account_holder': 'Rajesh Kumar',
          'ifsc': 'HDFC0001234',
        },
        'bank_name': 'HDFC Bank',
        'branch_name': 'Gachibowli',
        'is_default': true,
      });
      expect(find.text('Bank account updated.'), findsOneWidget);
    });
  });

  group('Bank accounts list', () {
    testWidgets('shows a loading state while the API future is pending',
        (tester) async {
      _useScreenSize(tester, const Size(390, 844));
      final completer = Completer<List<RefereeBankDetails>>();

      await tester.pumpWidget(
        _app(BankAccountsScreen(accountsFuture: completer.future)),
      );
      await tester.pump();

      expect(find.text('Loading bank accounts…'), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      completer.complete([_bank(), _upi()]);
      await tester.pumpAndSettle();

      expect(find.text('2 Banks Accounts'), findsOneWidget);
      expect(find.text('HDFC Bank'), findsOneWidget);
    });

    testWidgets('renders populated BANK and UPI rows with API status',
        (tester) async {
      _useScreenSize(tester, const Size(390, 844));
      await tester.pumpWidget(
        _app(
          BankAccountsScreen(
            accountsFuture: Future.value([
              _bank(isDefault: true),
              _upi(),
            ]),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Back Account'), findsOneWidget);
      expect(find.text('2 Banks Accounts'), findsOneWidget);
      expect(find.text('Add bank'), findsOneWidget);
      expect(find.text('HDFC Bank'), findsOneWidget);
      expect(find.text('Account Name: Rajesh Kumar'), findsOneWidget);
      expect(find.text('A/c ********9012'), findsOneWidget);
      expect(find.text('Verified'), findsOneWidget);
      expect(find.text('Default'), findsOneWidget);

      expect(find.text('rahul@okaxis'), findsOneWidget);
      expect(find.text('ra***@okaxis'), findsOneWidget);
      expect(find.text('Pending'), findsOneWidget);
      expect(find.textContaining('50100123454521'), findsNothing);
    });

    testWidgets('renders an explicit empty state with onboarding CTA',
        (tester) async {
      _useScreenSize(tester, const Size(390, 844));
      await tester.pumpWidget(
        _app(
          BankAccountsScreen(
            accountsFuture: Future.value(const <RefereeBankDetails>[]),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('0 Banks Accounts'), findsOneWidget);
      expect(find.text('No Bank Account'), findsOneWidget);
      expect(
        find.text('Please add your bank account to receive payouts.'),
        findsOneWidget,
      );
      expect(find.text('Add Bank'), findsOneWidget);
    });

    testWidgets('shows an error state and retries the API call',
        (tester) async {
      _useScreenSize(tester, const Size(390, 844));
      var attempts = 0;
      Future<List<RefereeBankDetails>> load() async {
        attempts++;
        if (attempts == 1) {
          throw const SportoApiException('offline');
        }
        return [_bank()];
      }

      await tester.pumpWidget(_app(BankAccountsScreen(loadAccounts: load)));
      await tester.pumpAndSettle();

      expect(find.text("Couldn't load bank accounts."), findsOneWidget);
      expect(find.text('Retry'), findsOneWidget);

      await tester.tap(find.text('Retry'));
      await tester.pumpAndSettle();

      expect(attempts, 2);
      expect(find.text('HDFC Bank'), findsOneWidget);
      expect(find.text('1 Bank Account'), findsOneWidget);
    });

    testWidgets('reloads the list after a successful add', (tester) async {
      _useScreenSize(tester, const Size(390, 844));
      var loadCalls = 0;
      RefereeBankDetailsRequest? captured;

      Future<List<RefereeBankDetails>> load() async {
        loadCalls++;
        return loadCalls == 1 ? <RefereeBankDetails>[] : [_bank()];
      }

      await tester.pumpWidget(
        _app(
          BankAccountsScreen(
            loadAccounts: load,
            submit: (request, {existing}) async {
              captured = request;
              return _bank();
            },
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('0 Banks Accounts'), findsOneWidget);

      await tester.tap(find.text('Add bank'));
      await tester.pumpAndSettle();
      await _fillValidForm(tester);
      await tester.ensureVisible(find.text('Save Bank'));
      await tester.tap(find.text('Save Bank'));
      await tester.pumpAndSettle();

      expect(captured?.toJson()['is_default'], isTrue);
      expect(loadCalls, 2);
      expect(find.text('1 Bank Account'), findsOneWidget);
      expect(find.text('HDFC Bank'), findsOneWidget);
    });

    testWidgets('opens details for a tapped account', (tester) async {
      _useScreenSize(tester, const Size(390, 844));
      await tester.pumpWidget(
        _app(
          BankAccountsScreen(
            accountsFuture: Future.value([_bank()]),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('HDFC Bank'));
      await tester.pumpAndSettle();

      expect(find.text('Bank Account Details'), findsOneWidget);
      expect(find.text('********9012'), findsOneWidget);
      expect(find.text('HDFC0001234'), findsOneWidget);
    });
  });

  group('Bank account details', () {
    testWidgets(
        'keeps the masked number and explains when reveal is unavailable',
        (tester) async {
      _useScreenSize(tester, const Size(390, 844));
      await tester.pumpWidget(
        _app(BankAccountDetailsScreen(details: _bank())),
      );

      expect(find.text('********9012'), findsOneWidget);
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

      await tester.tap(find.byKey(const ValueKey('bank_eye_toggle')));
      await tester.pump();

      expect(
        find.text("Full account number isn't available for security"),
        findsOneWidget,
      );
      expect(find.text('********9012'), findsOneWidget);
      expect(find.text('50100123454521'), findsNothing);
      expect(find.byTooltip('Show account number'), findsOneWidget);
    });

    testWidgets('reveals only when the API truly returned a full number',
        (tester) async {
      _useScreenSize(tester, const Size(390, 844));
      final full = RefereeBankDetails(
        id: 4,
        type: 'BANK',
        accountNumber: '50100123454521',
        maskedAccountNumber: '********4521',
        verificationStatusLabel: 'Verified',
      );
      await tester.pumpWidget(_app(BankAccountDetailsScreen(details: full)));

      expect(find.text('********4521'), findsOneWidget);
      await tester.tap(find.byKey(const ValueKey('bank_eye_toggle')));
      await tester.pump();

      expect(find.text('50100123454521'), findsOneWidget);
      expect(find.byTooltip('Hide account number'), findsOneWidget);
    });

    testWidgets('renders UPI details without an account reveal toggle',
        (tester) async {
      _useScreenSize(tester, const Size(390, 844));
      await tester.pumpWidget(
        _app(BankAccountDetailsScreen(details: _upi())),
      );

      expect(find.text('rahul@okaxis'), findsOneWidget);
      expect(find.text('ra***@okaxis'), findsOneWidget);
      expect(find.text('Pending'), findsOneWidget);
      expect(find.byKey(const ValueKey('bank_eye_toggle')), findsNothing);

      await tester.ensureVisible(find.text('Change Bank Account'));
      await tester.tap(find.text('Change Bank Account'));
      await tester.pump();

      expect(
        find.text("Changing a UPI ID isn't available yet"),
        findsOneWidget,
      );
    });

    testWidgets('re-verify stays honest about the missing endpoint',
        (tester) async {
      _useScreenSize(tester, const Size(390, 844));
      await tester.pumpWidget(
        _app(BankAccountDetailsScreen(details: _bank())),
      );

      await tester.ensureVisible(find.text('Re-verify Bank Account'));
      await tester.tap(find.text('Re-verify Bank Account'));
      await tester.pump();

      expect(
        find.text('Re-verification is not available yet'),
        findsOneWidget,
      );
    });

    testWidgets('renders an explicit no-selection state', (tester) async {
      _useScreenSize(tester, const Size(390, 844));
      await tester.pumpWidget(_app(const BankAccountDetailsScreen()));

      expect(find.text('No bank account selected.'), findsOneWidget);
    });
  });

  group('Responsive layouts', () {
    for (final size in const [Size(320, 640), Size(430, 932)]) {
      testWidgets('bank screens have no overflow at ${size.width.toInt()} px',
          (tester) async {
        _useScreenSize(tester, size);

        final screens = <Widget>[
          const BankOnboardingScreen(),
          const AddBankAccountScreen(),
          BankAccountsScreen(
            accountsFuture: Future.value([_bank(), _upi()]),
          ),
          BankAccountDetailsScreen(details: _bank()),
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
