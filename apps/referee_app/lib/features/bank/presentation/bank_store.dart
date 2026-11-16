import 'package:flutter/foundation.dart';

import '../../../core/config/referee_demo_data.dart';
import 'bank_figma_data.dart';
import 'bank_models.dart';

/// Session-scoped store for saved bank accounts.
///
/// TODO(bank-api): Replace this in-memory list with the referee bank-account
/// endpoints (`GET/POST /v1/referee/bank-account`) when they ship. Until then
/// this keeps the add-bank flow consistent inside the app instead of reporting
/// a success that disappears on the next screen.
class BankAccountsStore extends ChangeNotifier {
  BankAccountsStore._();

  static final BankAccountsStore instance = BankAccountsStore._();

  final List<BankAccount> _accounts = kRefereeDemoData
      ? List<BankAccount>.of(BankFigmaData.accounts)
      : <BankAccount>[];

  List<BankAccount> get accounts => List<BankAccount>.unmodifiable(_accounts);

  int get count => _accounts.length;

  void add(BankAccount account) {
    _accounts.add(account);
    notifyListeners();
  }

  /// Clears every account for the signed-in referee.
  ///
  /// Must be called when the session ends so the next referee on the same
  /// device cannot see the previous user's payout accounts.
  void clearForSession() {
    _accounts.clear();
    notifyListeners();
  }

  @visibleForTesting
  void reset() {
    _accounts.clear();
    if (kRefereeDemoData) {
      _accounts.addAll(BankFigmaData.accounts);
    }
    notifyListeners();
  }
}
