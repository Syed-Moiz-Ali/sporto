import 'package:referee_data/referee_data.dart';

/// Temporary Figma rows for Wallet History/Receipt.
///
/// `/wallet/transactions` and `/earnings` currently return `items: []` and the
/// row schema is undocumented. These rows render only when the live endpoint
/// returns no rows; as soon as the API returns data it is used instead.
///
/// TODO(backend): delete this file once the transaction row contract is live.
const List<RefereeWalletTransaction> kStaticWalletTransactions = [
  RefereeWalletTransaction(
    id: 9001,
    reference: 'TXN-2026-1042',
    amount: 1500,
    status: 'PAID',
    statusLabel: 'Paid',
    type: 'EARNING',
    category: 'EARNING',
    title: 'Match Fee - SP-10245',
    description: 'Hyderabad Corporate Cricket Tournament',
    tournamentName: 'Hyderabad Corporate Cricket Tournament',
    matchId: 4195,
    createdAt: '2026-11-14T18:30:00',
    direction: 'CREDIT',
    currency: 'INR',
    paymentMethod: 'Spoto Wallet Credit',
  ),
  RefereeWalletTransaction(
    id: 9002,
    reference: 'TXN-2026-1038',
    amount: 2500,
    status: 'PROCESSING',
    statusLabel: 'Processing',
    type: 'WITHDRAWAL',
    category: 'WITHDRAWAL',
    title: 'Withdrawal to HDFC Bank',
    description: 'Bank payout request',
    createdAt: '2026-11-12T10:15:00',
    direction: 'DEBIT',
    currency: 'INR',
    paymentMethod: 'Bank Payout',
  ),
  RefereeWalletTransaction(
    id: 9003,
    reference: 'TXN-2026-1021',
    amount: 2000,
    status: 'PAID',
    statusLabel: 'Paid',
    type: 'EARNING',
    category: 'EARNING',
    title: 'Match Fee - SP-4197',
    description: '1017 T Cricket League',
    tournamentName: '1017 T Cricket League',
    matchId: 4197,
    createdAt: '2026-11-08T20:05:00',
    direction: 'CREDIT',
    currency: 'INR',
    paymentMethod: 'Spoto Wallet Credit',
  ),
];
