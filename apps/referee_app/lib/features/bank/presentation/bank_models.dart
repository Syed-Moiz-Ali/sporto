import 'package:flutter/foundation.dart';
import 'package:referee_data/referee_data.dart';

/// Masks a bank account number so only the final four characters stay visible.
///
/// The Figma flow renders the masked value as `XXXX XXXX 4521`. Values of four
/// characters or fewer are returned unchanged because there is nothing to hide.
String maskAccountNumber(String accountNumber) {
  final value = accountNumber.replaceAll(RegExp(r'\s+'), '');
  if (value.isEmpty) return '';
  // Never reveal more than the final four characters, and hide short values
  // entirely because their "last four" is the whole account.
  if (value.length <= 8) return 'XXXX XXXX';
  return 'XXXX XXXX ${value.substring(value.length - 4)}';
}

/// IFSC format used by Indian banks: four letters, a literal `0`, then six
/// alphanumeric characters (for example `HDFC0001234`).
final RegExp bankIfscPattern = RegExp(r'^[A-Z]{4}0[A-Z0-9]{6}$');

final RegExp _bankAccountNumberPattern = RegExp(r'^\d{9,18}$');

/// Validates an IFSC value and returns the inline Form error, if any.
String? validateBankIfsc(String? value) {
  final normalised = (value ?? '').trim().toUpperCase();
  if (normalised.isEmpty) return 'Enter IFSC code';
  if (!bankIfscPattern.hasMatch(normalised)) {
    return 'Enter a valid IFSC code';
  }
  return null;
}

/// Validates an account number. UPI-linked Indian accounts are 9–18 digits.
String? validateBankAccountNumber(String? value) {
  final normalised = (value ?? '').trim();
  if (normalised.isEmpty) return 'Enter account number';
  if (!_bankAccountNumberPattern.hasMatch(normalised)) {
    return 'Account number must be 9-18 digits';
  }
  return null;
}

/// A saved bank account shown in the "Back Account" list.
///
/// The account number is kept in memory only and must never be logged or
/// persisted locally; [maskedAccountNumber] is the display-safe value.
@immutable
class BankAccount {
  const BankAccount({
    required this.id,
    required this.bankName,
    required this.branchName,
    required this.ifscCode,
    required this.accountHolderName,
    required this.accountNumber,
    required this.upiId,
    required this.logoAsset,
    this.isVerified = true,
  });

  final String id;
  final String bankName;
  final String branchName;
  final String ifscCode;
  final String accountHolderName;
  final String accountNumber;
  final String upiId;
  final String logoAsset;
  final bool isVerified;

  String get maskedAccountNumber => maskAccountNumber(accountNumber);

  String get lastFourDigits {
    final value = accountNumber.replaceAll(RegExp(r'\s+'), '');
    if (value.length <= 4) return '';
    return value.substring(value.length - 4);
  }

  BankAccountDetails get details => BankAccountDetails(
        bankName: bankName,
        branchName: branchName,
        ifscCode: ifscCode,
        accountHolderName: accountHolderName,
        accountNumber: accountNumber,
        upiId: upiId,
        isVerified: isVerified,
      );
}

/// Read-only bank-account information rendered by the details screen.
@immutable
class BankAccountDetails {
  const BankAccountDetails({
    required this.bankName,
    required this.ifscCode,
    required this.accountHolderName,
    required this.accountNumber,
    required this.upiId,
    this.branchName = '',
    this.isVerified = true,
  });

  final String bankName;
  final String branchName;
  final String ifscCode;
  final String accountHolderName;
  final String accountNumber;
  final String upiId;
  final bool isVerified;

  String get maskedAccountNumber => maskAccountNumber(accountNumber);

  String get lastFourDigits {
    final value = accountNumber.replaceAll(RegExp(r'\s+'), '');
    if (value.length <= 4) return '';
    return value.substring(value.length - 4);
  }
}

// ============================================================
// API model display helpers
// ============================================================

String _nonEmpty(String? value) {
  final trimmed = value?.trim();
  return trimmed == null || trimmed.isEmpty ? '' : trimmed;
}

/// Title shown on bank cards: the bank name for BANK rows and the UPI handle
/// for UPI rows, with the API summary as a fallback.
String bankDetailsTitle(RefereeBankDetails details) {
  if (details.isUpi) {
    final upi = _nonEmpty(details.upiId);
    if (upi.isNotEmpty) return upi;
  }
  final bankName = _nonEmpty(details.bankName);
  if (bankName.isNotEmpty) return bankName;
  final summary = _nonEmpty(details.summary);
  if (summary.isNotEmpty) return summary;
  return details.isUpi ? 'UPI account' : 'Bank account';
}

/// API-safe masked number. The API never returns the full account number, so
/// [RefereeBankDetails.accountNumber] is deliberately never rendered directly.
String bankMaskedAccountLabel(RefereeBankDetails details) {
  if (details.isUpi) {
    final summary = _nonEmpty(details.summary);
    return summary.isEmpty ? _nonEmpty(details.upiId) : summary;
  }
  final masked = _nonEmpty(details.maskedAccountNumber);
  if (masked.isNotEmpty) return masked;
  final lastFour = details.lastFour;
  if (lastFour == null || lastFour.isEmpty) return '';
  return lastFour.length >= 4
      ? 'XXXX XXXX ${lastFour.substring(lastFour.length - 4)}'
      : 'XXXX XXXX';
}

/// A full account number is only usable when the API response actually
/// contains unmasked digits. Masked values such as `********9012` are rejected.
String? bankFullAccountNumber(RefereeBankDetails details) {
  if (details.isUpi) return null;
  final raw = _nonEmpty(details.accountNumber);
  if (raw.isEmpty) return null;
  final lower = raw.toLowerCase();
  if (lower.contains('*') || lower.contains('x')) return null;
  final digits = raw.replaceAll(RegExp(r'\D'), '');
  if (digits.length < 9 || digits.length > 18) return null;
  return digits;
}

/// Verification label straight from the API; unknown responses stay honest and
/// render as pending instead of claiming the account is verified.
String bankVerificationLabel(RefereeBankDetails details) {
  final label = _nonEmpty(details.verificationStatusLabel);
  return label.isEmpty ? 'Pending' : label;
}

bool bankIsVerified(RefereeBankDetails details) {
  final lower = bankVerificationLabel(details).toLowerCase();
  return lower.contains('verified') &&
      !lower.contains('unverified') &&
      !lower.contains('not verified');
}
