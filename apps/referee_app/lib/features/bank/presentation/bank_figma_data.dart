import 'bank_icons.dart';
import 'bank_models.dart';

/// Figma-accurate placeholder data for the referee bank-account flow.
///
/// TODO(bank-api): Replace every value below with the real API payload once the
/// referee bank endpoints exist. `GET /v1/referee/bank-account` is currently
/// missing (see `docs/referee_new_ui_backend_gaps.md`), as are the create,
/// change, and re-verify mutations. Do not treat this data as production data.
abstract final class BankFigmaData {
  /// Sample accounts matching the three cards in the Figma "Back Account"
  /// frame (SBI, HDFC, BOB). Account numbers are fabricated and are rendered
  /// masked everywhere in the UI.
  static const List<BankAccount> accounts = <BankAccount>[
    BankAccount(
      id: 'sbi-9012',
      bankName: 'SBI Bank',
      branchName: 'Hyderabad Main',
      ifscCode: 'SBIN0001234',
      accountHolderName: 'Mayank Reddy',
      accountNumber: '123456789012',
      upiId: 'mayank@okhdfcbank',
      logoAsset: BankIcons.logoSbi,
    ),
    BankAccount(
      id: 'hdfc-7812',
      bankName: 'HDFC Bank',
      branchName: 'Gachibowli',
      ifscCode: 'HDFC0001234',
      accountHolderName: 'Rajesh Kumar',
      accountNumber: '501234567812',
      upiId: 'turfenergy@okhdfcbank',
      logoAsset: BankIcons.logoHdfc,
    ),
    BankAccount(
      id: 'bob-1050',
      bankName: 'BOB Bank',
      branchName: 'Banjara Hills',
      ifscCode: 'BARB0VJBOB0',
      accountHolderName: 'Mayank Reddy',
      accountNumber: '987654321050',
      upiId: 'mayank.reddy@okhdfcbank',
      logoAsset: BankIcons.logoBob,
    ),
  ];

  /// Verified HDFC account shown on the Figma "Bank Account Details" frame.
  static const BankAccountDetails details = BankAccountDetails(
    bankName: 'HDFC Bank',
    branchName: 'Gachibowli',
    ifscCode: 'HDFC0001234',
    accountHolderName: 'Rajesh Kumar',
    accountNumber: '50100123454521',
    upiId: 'turfenergy@okhdfcbank',
  );
}
