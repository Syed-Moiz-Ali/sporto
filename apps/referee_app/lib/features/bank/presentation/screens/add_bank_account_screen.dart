import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:referee_data/referee_data.dart';
import 'package:ui_kit/ui_kit.dart';

import '../../../../core/di/dependency_injector.dart';
import '../bank_models.dart';
import '../widgets/bank_shared_widgets.dart';

/// Injected submit hook so widget tests can verify the real request body
/// without touching the live network.
typedef BankDetailsSubmitter = Future<RefereeBankDetails> Function(
  RefereeBankDetailsRequest request, {
  RefereeBankDetails? existing,
});

/// Working "Add Bank Account" form from the Figma `02_Add-Bank-Account` frame.
///
/// Submits `RefereeBankDetailsRequest.bankAccount(...)` to the live referee
/// bank endpoint. When [existing] is supplied the same form updates that row
/// through `updateBankDetails(existing.id, request)` instead of POSTing a new
/// account. Account numbers and IFSC values are never logged.
class AddBankAccountScreen extends StatefulWidget {
  const AddBankAccountScreen({
    super.key,
    this.existing,
    this.makeDefault = false,
    this.submit,
  });

  /// Existing bank row to edit/change. UPI rows are not editable here because
  /// the API form only supports bank account details.
  final RefereeBankDetails? existing;

  /// Used when adding the first account so payouts have a default destination.
  final bool makeDefault;

  /// Test/preview override for the network call.
  final BankDetailsSubmitter? submit;

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

  bool get _isEditing =>
      widget.existing != null &&
      widget.existing!.isBank &&
      widget.existing!.id != null;

  @override
  void initState() {
    super.initState();
    final existing = widget.existing;
    if (_isEditing && existing != null) {
      _bankNameController.text = existing.bankName?.trim() ?? '';
      _branchNameController.text = existing.branchName?.trim() ?? '';
      _ifscController.text = existing.ifscCode?.trim().toUpperCase() ?? '';
      _holderNameController.text = existing.accountHolderName?.trim() ?? '';
      final fullNumber = bankFullAccountNumber(existing);
      if (fullNumber != null) {
        _accountNumberController.text = fullNumber;
      }
    }
  }

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

  Future<RefereeBankDetails> _sendRequest(
    RefereeBankDetailsRequest request,
  ) {
    final injected = widget.submit;
    if (injected != null) {
      return injected(
        request,
        existing: _isEditing ? widget.existing : null,
      );
    }

    final remote = DependencyInjector.instance.refereeRemoteDataSource;
    final existingId = _isEditing ? widget.existing?.id : null;
    if (existingId != null) {
      return remote.updateBankDetails(existingId, request);
    }
    return remote.addBankDetails(request);
  }

  Future<void> _submit() async {
    if (_isSaving) return;
    FocusScope.of(context).unfocus();
    if (!(_formKey.currentState?.validate() ?? false)) {
      setState(() => _autovalidateMode = AutovalidateMode.always);
      return;
    }

    setState(() => _isSaving = true);

    final accountNumber =
        _accountNumberController.text.replaceAll(RegExp(r'\D'), '');
    final request = RefereeBankDetailsRequest.bankAccount(
      accountNumber: accountNumber,
      accountHolder: _holderNameController.text.trim(),
      ifsc: _ifscController.text.trim().toUpperCase(),
      bankName: _bankNameController.text.trim(),
      branchName: _branchNameController.text.trim(),
      isDefault: _isEditing
          ? (widget.existing?.isDefault ?? false)
          : widget.makeDefault,
    );

    try {
      await _sendRequest(request);
      if (!mounted) return;

      setState(() => _isSaving = false);
      showBankSnackBar(
        context,
        _isEditing
            ? 'Bank account updated.'
            : 'Bank account added. Verification is pending.',
      );

      final navigator = Navigator.of(context);
      if (navigator.canPop()) navigator.pop(true);
    } catch (_) {
      if (!mounted) return;
      setState(() => _isSaving = false);
      showBankSnackBar(
        context,
        "Couldn't save bank account. Please try again.",
        isError: true,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final scale = context.sportoScale;
    final savingLabel = _isEditing ? 'Updating…' : 'Saving…';

    return Scaffold(
      backgroundColor: context.sporto.canvas,
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            BankHeader(
              title: _isEditing ? 'Change Bank Account' : 'Add Bank Account',
            ),
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
                            hint: _isEditing
                                ? 'Re-enter account number'
                                : 'Enter account number',
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
                        label: _isSaving
                            ? savingLabel
                            : (_isEditing ? 'Update Bank' : 'Save Bank'),
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
