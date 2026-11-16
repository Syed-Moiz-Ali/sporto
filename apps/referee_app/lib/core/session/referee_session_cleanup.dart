import '../../features/bank/presentation/bank_store.dart';
import '../../features/notifications/presentation/notification_store.dart';

/// Clears per-referee in-memory state that must not leak into the next session
/// on a shared device.
void clearRefereeUserState() {
  BankAccountsStore.instance.clearForSession();
  NotificationPreferencesStore.instance.clearForSession();
}
