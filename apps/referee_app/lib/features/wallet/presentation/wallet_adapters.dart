import 'package:referee_data/referee_data.dart';

import 'wallet_formatters.dart';

/// The ledger bucket a wallet row belongs to.
enum WalletLedgerCategory { earnings, withdrawal, other }

/// Direction of money movement, parsed defensively from the API row.
enum WalletLedgerDirection { credit, debit, unknown }

/// Semantic colour bucket for a status label. Status text itself always comes
/// from the API; only its tone is inferred so colours stay meaningful.
enum WalletStatusTone { positive, pending, negative, neutral }

WalletStatusTone walletStatusTone(String label) {
  final value = label.toLowerCase();
  if (value.contains('paid') ||
      value.contains('complete') ||
      value.contains('settled') ||
      value.contains('success') ||
      value.contains('credit')) {
    return WalletStatusTone.positive;
  }
  if (value.contains('processing') ||
      value.contains('pending') ||
      value.contains('progress')) {
    return WalletStatusTone.pending;
  }
  if (value.contains('failed') ||
      value.contains('cancel') ||
      value.contains('reject') ||
      value.contains('debit')) {
    return WalletStatusTone.negative;
  }
  return WalletStatusTone.neutral;
}

/// Read-only adapter that exposes only fields the backend actually returns.
///
/// Nothing is derived that the API did not send: missing values render `—` and
/// the direction is left [WalletLedgerDirection.unknown] when absent.
class WalletTransactionView {
  const WalletTransactionView(this.transaction);

  final RefereeWalletTransaction transaction;

  /// Category parsed from `category`/`type`, then from the direction as a
  /// last-resort hint. Unknown rows stay [WalletLedgerCategory.other] so they
  /// still appear under the "All" tab without being mislabelled.
  WalletLedgerCategory get category {
    final candidates = <Object?>[
      transaction.category,
      transaction.type,
      transaction.raw['category'],
      transaction.raw['transaction_type'],
      transaction.raw['ledger_type'],
      transaction.raw['entry_type'],
    ];
    for (final candidate in candidates) {
      final value = candidate?.toString().trim().toLowerCase();
      if (value == null || value.isEmpty) continue;
      if (value.contains('withdraw') ||
          value.contains('payout') ||
          value.contains('debit')) {
        return WalletLedgerCategory.withdrawal;
      }
      if (value.contains('earn') ||
          value.contains('credit') ||
          value.contains('fee') ||
          value.contains('prize')) {
        return WalletLedgerCategory.earnings;
      }
    }
    return switch (direction) {
      WalletLedgerDirection.credit => WalletLedgerCategory.earnings,
      WalletLedgerDirection.debit => WalletLedgerCategory.withdrawal,
      WalletLedgerDirection.unknown => WalletLedgerCategory.other,
    };
  }

  WalletLedgerDirection get direction {
    final value = (transaction.direction ??
            transaction.raw['direction'] ??
            transaction.raw['type'])
        ?.toString()
        .trim()
        .toLowerCase();
    if (value == null || value.isEmpty) return WalletLedgerDirection.unknown;
    if (value.contains('credit')) return WalletLedgerDirection.credit;
    if (value.contains('debit')) return WalletLedgerDirection.debit;
    return WalletLedgerDirection.unknown;
  }

  String get displayTitle =>
      _firstNonEmpty([
        transaction.title,
        transaction.description,
        transaction.tournamentName,
      ]) ??
      '—';

  /// Secondary line built from the remaining real fields (description and
  /// tournament) without repeating the title.
  String? get displaySubtitle {
    final values = <String>{};
    for (final candidate in [
      transaction.description,
      transaction.tournamentName,
    ]) {
      final value = _clean(candidate);
      if (value != null && value != displayTitle) values.add(value);
    }
    return values.isEmpty ? null : values.join(' · ');
  }

  String get statusLabel =>
      formatStatusLabel(transaction.statusLabel ?? transaction.status);

  String get dateLabel => formatApiDate(transaction.createdAt) ?? '—';

  String? get categoryLabel =>
      _clean(transaction.category) == null && _clean(transaction.type) == null
          ? null
          : formatStatusLabel(transaction.category ?? transaction.type);

  String? get referenceLabel =>
      _firstNonEmpty([transaction.reference, transaction.id?.toString()]);

  String? get paymentMethodLabel => _clean(transaction.paymentMethod);

  String? get directionLabel => switch (direction) {
        WalletLedgerDirection.credit => 'Credited',
        WalletLedgerDirection.debit => 'Debited',
        WalletLedgerDirection.unknown => null,
      };

  String? get tournamentName => _clean(transaction.tournamentName);

  String? get description => _clean(transaction.description);

  String? get title => _clean(transaction.title);

  String? get matchLabel =>
      transaction.matchId == null ? null : '#${transaction.matchId}';

  String get amountLabel {
    final amount = transaction.amount;
    if (amount == null) return '—';
    final signed =
        direction == WalletLedgerDirection.unknown ? amount : amount.abs();
    final formatted =
        formatCurrencyAmount(signed, currency: transaction.currency);
    return switch (direction) {
      WalletLedgerDirection.credit => '+$formatted',
      WalletLedgerDirection.debit => '-$formatted',
      WalletLedgerDirection.unknown => formatted,
    };
  }

  String get semanticLabel {
    final parts = <String>[
      displayTitle,
      if (displaySubtitle != null) displaySubtitle!,
      statusLabel,
      dateLabel,
      amountLabel,
    ];
    return parts.join(', ');
  }
}

/// Tournament status codes returned by `GET /v1/referee/tournaments`.
///
/// The live payload only carries `{id, name, code, status, currency}`. There is
/// no venue/date/team/fee data, so those Figma fields are intentionally not
/// rendered.
abstract final class RefereeTournamentStatus {
  static const int completed = 7;
  static const int cancelled = 8;

  static String? _statusText(RefereeTournamentHistoryItem item) => _clean(
        item.raw['status_label'] ??
            item.raw['status_text'] ??
            item.raw['state'],
      );

  static bool isCompleted(RefereeTournamentHistoryItem item) {
    if (item.status == completed) return true;
    final text = _statusText(item)?.toLowerCase();
    return text != null &&
        (text.contains('complete') || text.contains('finish'));
  }

  static bool isCancelled(RefereeTournamentHistoryItem item) {
    if (item.status == cancelled) return true;
    final text = _statusText(item)?.toLowerCase();
    return text != null && text.contains('cancel');
  }

  static String labelFor(RefereeTournamentHistoryItem item) {
    if (item.status == completed) return 'Completed';
    if (item.status == cancelled) return 'Cancelled';
    final text = _statusText(item);
    return text == null ? '—' : formatStatusLabel(text);
  }

  static String codeFor(RefereeTournamentHistoryItem item) =>
      _clean(item.code) ?? '—';

  static String currencyFor(RefereeTournamentHistoryItem item) =>
      _clean(item.currency) ?? '—';
}

String? _clean(String? value) {
  final text = value?.trim();
  return text == null || text.isEmpty ? null : text;
}

String? _firstNonEmpty(Iterable<String?> values) {
  for (final value in values) {
    final clean = _clean(value);
    if (clean != null) return clean;
  }
  return null;
}
