import 'wallet_models.dart';

/// Static Figma sample data for the Wallet / Tournaments History flow.
///
/// TODO(backend): Replace with `GET /v1/referee/wallet`,
/// `GET /v1/referee/wallet/transactions` and the tournaments-history endpoint
/// when the backend ships. These endpoints are currently missing — see
/// `docs/referee_new_ui_backend_gaps.md` and
/// `docs/REFEREE_BACKEND_API_REQUIREMENTS.md`.
///
/// Screens accept these models through their constructors, so swapping the
/// values for API responses requires no UI rewrites. No fake API clients are
/// wired here on purpose.
abstract final class WalletFigmaData {
  static const transactions = <WalletTransaction>[
    WalletTransaction(
      id: 'TXN-88213',
      name: 'Rahul Kumar',
      party: WalletTransactionParty.user,
      tournamentName: 'Gachibowli Super Over Qualifier',
      status: WalletTransactionStatus.processing,
      dateLabel: 'Mon 09 Sep, 07:42 PM',
      amountRupees: 3000,
      category: WalletTransactionCategory.earnings,
    ),
    WalletTransaction(
      id: 'TXN-88214',
      name: 'Rahul Kumar',
      party: WalletTransactionParty.partner,
      tournamentName: 'Hyd Super Over Premier League',
      status: WalletTransactionStatus.paid,
      dateLabel: 'Mon 09 Sep, 07:42 PM',
      amountRupees: 3800,
      category: WalletTransactionCategory.earnings,
    ),
  ];

  static const overview = WalletOverview(
    balanceRupees: 120400,
    pendingSettlementRupees: 98600,
    totalEarningsRupees: 840000,
    recentTransactions: transactions,
  );

  static const transactionDetail = TransactionDetail(
    reference: 'TXN-88213',
    dateLabel: 'Aug 2, 2026',
    amountRupees: 1000,
    category: 'Sponsorship',
    direction: WalletTransactionDirection.credited,
    statusLabel: 'Completed',
    transactionRef: 'TXN-88301',
    paymentMethod: 'Spoto Wallet Credit',
    descriptionTitle: 'Kondapur Super Over Cup',
    descriptionSubtitle: 'Winner Prize (your split)',
    tournamentName: 'Spoto Kondapur Super Over Cup',
  );

  static const tournaments = <TournamentHistoryItem>[
    TournamentHistoryItem(
      id: 'T-1001',
      name: 'Hitech City Super Over Cup',
      venue: 'Hitech Box Cricket Arena',
      dateLabel: 'Aug 5',
      registeredTeams: 41,
      totalTeams: 64,
      earningsRupees: 3800,
      levelLabel: 'Local',
      approvalLabel: 'Approved',
      status: TournamentHistoryStatus.completed,
    ),
    TournamentHistoryItem(
      id: 'T-1002',
      name: 'Hitech City Super Over Cup',
      venue: 'Hitech Box Cricket Arena',
      dateLabel: 'Aug 5',
      registeredTeams: 41,
      totalTeams: 64,
      earningsRupees: 3800,
      levelLabel: 'Local',
      approvalLabel: 'Approved',
      status: TournamentHistoryStatus.completed,
    ),
  ];
}
