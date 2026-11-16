import 'package:flutter/foundation.dart';

/// Who funded the wallet transaction.
enum WalletTransactionParty { user, partner }

/// Lifecycle of a wallet transaction as shown in the wallet history.
enum WalletTransactionStatus { processing, paid }

/// The ledger bucket a transaction belongs to.
enum WalletTransactionCategory { earnings, withdrawal }

/// Direction of money movement inside a transaction detail screen.
enum WalletTransactionDirection { credited, debited }

/// Referee wallet overview (balance + settlement + lifetime earnings).
///
/// TODO(backend): Replace the const sample in `wallet_figma_data.dart` with
/// `GET /v1/referee/wallet` when the endpoint ships. See
/// `docs/referee_new_ui_backend_gaps.md` and
/// `docs/REFEREE_BACKEND_API_REQUIREMENTS.md`.
@immutable
class WalletOverview {
  final int balanceRupees;
  final int pendingSettlementRupees;
  final int totalEarningsRupees;
  final List<WalletTransaction> recentTransactions;

  const WalletOverview({
    required this.balanceRupees,
    required this.pendingSettlementRupees,
    required this.totalEarningsRupees,
    this.recentTransactions = const <WalletTransaction>[],
  });
}

/// A single row in the wallet transaction history.
///
/// TODO(backend): Replace with `GET /v1/referee/wallet/transactions` once the
/// endpoint exists (see `docs/referee_new_ui_backend_gaps.md`).
@immutable
class WalletTransaction {
  final String id;
  final String name;
  final WalletTransactionParty party;
  final String tournamentName;
  final WalletTransactionStatus status;
  final String dateLabel;
  final int amountRupees;
  final WalletTransactionCategory category;

  const WalletTransaction({
    required this.id,
    required this.name,
    required this.party,
    required this.tournamentName,
    required this.status,
    required this.dateLabel,
    required this.amountRupees,
    required this.category,
  });
}

/// Full-screen transaction receipt.
///
/// TODO(backend): Replace with `GET /v1/referee/wallet/transactions/{id}` when
/// the endpoint ships (see `docs/referee_new_ui_backend_gaps.md`).
@immutable
class TransactionDetail {
  final String reference;
  final String dateLabel;
  final int amountRupees;
  final String category;
  final WalletTransactionDirection direction;
  final String statusLabel;
  final String transactionRef;
  final String paymentMethod;
  final String descriptionTitle;
  final String descriptionSubtitle;
  final String tournamentName;

  const TransactionDetail({
    required this.reference,
    required this.dateLabel,
    required this.amountRupees,
    required this.category,
    required this.direction,
    required this.statusLabel,
    required this.transactionRef,
    required this.paymentMethod,
    required this.descriptionTitle,
    required this.descriptionSubtitle,
    required this.tournamentName,
  });

  /// Maps a ledger row to the receipt shown when that row is opened.
  factory TransactionDetail.fromTransaction(WalletTransaction transaction) {
    final isWithdrawal =
        transaction.category == WalletTransactionCategory.withdrawal;
    return TransactionDetail(
      reference: transaction.id,
      dateLabel: transaction.dateLabel,
      amountRupees: transaction.amountRupees,
      category: isWithdrawal ? 'Withdrawal' : 'Earnings',
      direction: isWithdrawal
          ? WalletTransactionDirection.debited
          : WalletTransactionDirection.credited,
      statusLabel: transaction.status == WalletTransactionStatus.paid
          ? 'Completed'
          : 'Processing',
      transactionRef: transaction.id,
      paymentMethod: isWithdrawal ? 'Bank Payout' : 'Spoto Wallet Credit',
      descriptionTitle: transaction.tournamentName,
      descriptionSubtitle:
          isWithdrawal ? 'Wallet withdrawal' : 'Match earnings',
      tournamentName: transaction.tournamentName,
    );
  }
}

/// Completed/cancelled tournament entry shown inside Tournaments History.
///
/// TODO(backend): Replace with the referee tournaments-history endpoint when it
/// ships. It is currently missing from the referee API surface; see
/// `docs/referee_new_ui_backend_gaps.md`.
@immutable
class TournamentHistoryItem {
  final String id;
  final String name;
  final String venue;
  final String dateLabel;
  final int registeredTeams;
  final int totalTeams;
  final int earningsRupees;
  final String levelLabel;
  final String approvalLabel;
  final TournamentHistoryStatus status;

  const TournamentHistoryItem({
    required this.id,
    required this.name,
    required this.venue,
    required this.dateLabel,
    required this.registeredTeams,
    required this.totalTeams,
    required this.earningsRupees,
    required this.levelLabel,
    required this.approvalLabel,
    required this.status,
  });
}

/// Completed / cancelled filter state for [TournamentHistoryItem].
enum TournamentHistoryStatus { completed, cancelled }
