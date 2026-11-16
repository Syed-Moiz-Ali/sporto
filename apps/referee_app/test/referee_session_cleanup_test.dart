import 'package:flutter_test/flutter_test.dart';
import 'package:referee_app/core/session/referee_session_cleanup.dart';
import 'package:referee_app/features/bank/presentation/bank_models.dart';
import 'package:referee_app/features/bank/presentation/bank_store.dart';
import 'package:referee_app/features/notifications/presentation/notification_models.dart';
import 'package:referee_app/features/notifications/presentation/notification_store.dart';

void main() {
  test('logout clears per-referee bank and notification state', () {
    BankAccountsStore.instance.reset();
    expect(BankAccountsStore.instance.count, greaterThan(0));

    BankAccountsStore.instance.add(
      const BankAccount(
        id: 'session-test',
        bankName: 'HDFC Bank',
        branchName: 'Gachibowli',
        ifscCode: 'HDFC0001234',
        accountHolderName: 'Referee A',
        accountNumber: '50100123454521',
        upiId: 'referee.a@okhdfcbank',
        logoAsset: '',
      ),
    );
    final category = NotificationCategory.match;
    NotificationPreferencesStore.instance.update(
      category,
      NotificationPreferences.defaultsFor(category).toggled('match_reminders'),
    );

    clearRefereeUserState();

    expect(BankAccountsStore.instance.count, 0);
    expect(
      NotificationPreferencesStore.instance
          .preferencesFor(category)
          .isEnabled('match_reminders'),
      isFalse,
    );
  });
}
