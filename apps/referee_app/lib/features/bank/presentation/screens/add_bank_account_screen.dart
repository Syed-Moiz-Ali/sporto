import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ui_kit/ui_kit.dart';

import '../bank_icons.dart';
import '../bank_models.dart';
import '../bank_store.dart';
import '../widgets/bank_shared_widgets.dart';

/// Working "Add Bank Account" form from the Figma `02_Add-Bank-Account` frame.
///
/// Submission is intentionally local for now: no referee bank endpoint exists
/// yet. Account numbers stay in memory only and are never logged or persisted.
class AddBankAccountScreen extends StatefulWidget {
  const AddBankAccountScreen({
    super.key,
    this.onSaved,
    this.submitDelay = const Duration(milliseconds: 350),
  });

  final ValueChanged<BankAccountDetails>? onSaved;

  /// Simulated network latency so the saving state is observable. Remove when
  /// the real API call lands.
  final Duration submitDelay;

  @override
  State<AddBankAccountScreen> createState() => _AddBankAccountScreenState();
}

class _AddBankAccountScreenState extends State<AddBankAccountScreen> {
  final _formKey = GlobalKey<FormState>();
  final _bankNameController = TextEditingController();
  final _branchNameController = TextEditingController();
  final _ifscController = TextEditingController();
  final _holderNameController = TextEditingController();
  final _accountNumberController = TextEditingController();

  final _branchNameFocus = FocusNode();
  final _ifscFocus = FocusNode();
  final _holderNameFocus = FocusNode();
  final _accountNumberFocus = FocusNode();

  bool _isSaving = false;
  AutovalidateMode _autovalidateMode = AutovalidateMode.disabled;

  @override
  void dispose() {
    _bankNameController.dispose();
    _branchNameController.dispose();
    _ifscController.dispose();
    _holderNameController.dispose();
    _accountNumberController.dispose();
    _branchNameFocus.dispose();
    _ifscFocus.dispose();
    _holderNameFocus.dispose();
    _accountNumberFocus.dispose();
    super.dispose();
  }

  String? _required(String? value, String message) {
    if (value == null || value.trim().isEmpty) return message;
    return null;
  }

  Future<void> _submit() async {
    if (_isSaving) return;
    FocusScope.of(context).unfocus();
    if (!(_formKey.currentState?.validate() ?? false)) {
      setState(() => _autovalidateMode = AutovalidateMode.always);
      return;
    }

    setState(() => _isSaving = true);

    final details = BankAccountDetails(
      bankName: _bankNameController.text.trim(),
      branchName: _branchNameController.text.trim(),
      ifscCode: _ifscController.text.trim().toUpperCase(),
      accountHolderName: _holderNameController.text.trim(),
      accountNumber: _accountNumberController.text.trim(),
      upiId: '',
    );

    // TODO(bank-api): POST the details to `/v1/referee/bank-account` once the
    // endpoint exists, then re-verify via penny-drop before showing success.
    await Future<void>.delayed(widget.submitDelay);
    if (!mounted) return;

    final account = BankAccount(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      bankName: details.bankName,
      branchName: details.branchName,
      ifscCode: details.ifscCode,
      accountHolderName: details.accountHolderName,
      accountNumber: details.accountNumber,
      upiId: details.upiId,
      logoAsset: BankIcons.logoForBank(details.bankName),
      isVerified: false,
    );
    BankAccountsStore.instance.add(account);

    setState(() => _isSaving = false);
    widget.onSaved?.call(details);
    showBankSnackBar(
      context,
      'Bank account added. Verification is pending.',
    );

    final navigator = Navigator.of(context);
    if (navigator.canPop()) navigator.pop();
  }

  @override
  Widget build(BuildContext context) {
    final scale = context.sportoScale;

    return Scaffold(
      backgroundColor: context.sporto.canvas,
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            const BankHeader(title: 'Add Bank Account'),
            Expanded(
              child: SingleChildScrollView(
                keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.onDrag,
                padding: EdgeInsets.fromLTRB(
                  20 * scale,
                  20 * scale,
                  20 * scale,
                  24 * scale,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const BankInfoStrip(),
                    SizedBox(height: 30 * scale),
                    Form(
                      key: _formKey,
                      autovalidateMode: _autovalidateMode,
                      child: Column(
                        children: [
                          BankTextField(
                            label: 'Bank Name',
                            hint: 'Enter bank name',
                            fieldKey: const ValueKey('bank_field_bank_name'),
                            controller: _bankNameController,
                            textCapitalization: TextCapitalization.words,
                            textInputAction: TextInputAction.next,
                            inputFormatters: [
                              LengthLimitingTextInputFormatter(80),
                            ],
                            validator: (value) =>
                                _required(value, 'Enter bank name'),
                            onFieldSubmitted: (_) =>
                                _branchNameFocus.requestFocus(),
                          ),
                          SizedBox(height: 20 * scale),
                          BankTextField(
                            label: 'Branch Name',
                            hint: 'Enter branch Name',
                            fieldKey: const ValueKey('bank_field_branch_name'),
                            controller: _branchNameController,
                            focusNode: _branchNameFocus,
                            textCapitalization: TextCapitalization.words,
                            textInputAction: TextInputAction.next,
                            inputFormatters: [
                              LengthLimitingTextInputFormatter(80),
                            ],
                            validator: (value) =>
                                _required(value, 'Enter branch name'),
                            onFieldSubmitted: (_) => _ifscFocus.requestFocus(),
                          ),
                          SizedBox(height: 20 * scale),
                          BankTextField(
                            label: 'IFSC Code',
                            hint: 'Enter IFSC code',
                            fieldKey: const ValueKey('bank_field_ifsc'),
                            controller: _ifscController,
                            focusNode: _ifscFocus,
                            keyboardType: TextInputType.text,
                            textCapitalization: TextCapitalization.characters,
                            textInputAction: TextInputAction.next,
                            enableSuggestions: false,
                            autocorrect: false,
                            enableIMEPersonalizedLearning: false,
                            inputFormatters: [
                              TextInputFormatter.withFunction(
                                (oldValue, newValue) {
                                  final upper = newValue.text.toUpperCase();
                                  return upper == newValue.text
                                      ? newValue
                                      : newValue.copyWith(
                                          text: upper,
                                          selection: TextSelection.collapsed(
                                            offset: upper.length,
                                          ),
                                        );
                                },
                              ),
                              LengthLimitingTextInputFormatter(11),
                            ],
                            validator: validateBankIfsc,
                            onFieldSubmitted: (_) =>
                                _holderNameFocus.requestFocus(),
                          ),
                          SizedBox(height: 20 * scale),
                          BankTextField(
                            label: 'Account Holder Name',
                            hint: 'Enter branch Name',
                            fieldKey: const ValueKey('bank_field_holder_name'),
                            controller: _holderNameController,
                            focusNode: _holderNameFocus,
                            textCapitalization: TextCapitalization.words,
                            textInputAction: TextInputAction.next,
                            inputFormatters: [
                              LengthLimitingTextInputFormatter(80),
                            ],
                            validator: (value) => _required(
                              value,
                              'Enter account holder name',
                            ),
                            onFieldSubmitted: (_) =>
                                _accountNumberFocus.requestFocus(),
                          ),
                          SizedBox(height: 20 * scale),
                          BankTextField(
                            label: 'Account Number',
                            hint: 'Enter account number',
                            fieldKey: const ValueKey(
                              'bank_field_account_number',
                            ),
                            controller: _accountNumberController,
                            focusNode: _accountNumberFocus,
                            keyboardType: TextInputType.number,
                            textInputAction: TextInputAction.done,
                            enableSuggestions: false,
                            autocorrect: false,
                            enableIMEPersonalizedLearning: false,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                              LengthLimitingTextInputFormatter(18),
                            ],
                            validator: validateBankAccountNumber,
                            onFieldSubmitted: (_) => _submit(),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 30 * scale),
                    Center(
                      child: BankGradientButton.sky(
                        label: _isSaving ? 'Saving…' : 'Save Bank',
                        width: 270 * scale,
                        isLoading: _isSaving,
                        onPressed: _isSaving ? null : _submit,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
