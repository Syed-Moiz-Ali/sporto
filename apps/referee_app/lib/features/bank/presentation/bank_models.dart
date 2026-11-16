import 'package:flutter/foundation.dart';

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
