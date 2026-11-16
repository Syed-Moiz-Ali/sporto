import 'dart:async';

import 'package:flutter/material.dart';
import 'package:referee_data/referee_data.dart';
import 'package:ui_kit/ui_kit.dart';

import '../bank_icons.dart';
import '../bank_models.dart';
import '../widgets/bank_shared_widgets.dart';
import 'add_bank_account_screen.dart';

/// Bank account details from the Figma `04_Bank-Account-Details` frame.
///
/// The API only ever returns a masked account number. If a reveal is attempted
/// without a full number, the screen keeps the masked value and explains why.
class BankAccountDetailsScreen extends StatefulWidget {
  const BankAccountDetailsScreen({
    super.key,
    this.details,
  });

  final RefereeBankDetails? details;

  @override
  State<BankAccountDetailsScreen> createState() =>
      _BankAccountDetailsScreenState();
}

class _BankAccountDetailsScreenState extends State<BankAccountDetailsScreen>
    with WidgetsBindingObserver {
  bool _revealed = false;
  Timer? _hideTimer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    _hideTimer?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state != AppLifecycleState.resumed && _revealed) {
      setState(() => _revealed = false);
    }
  }

  void _toggleReveal() {
    final details = widget.details;
    final fullNumber = details == null ? null : bankFullAccountNumber(details);
    if (fullNumber == null) {
      _hideTimer?.cancel();
      if (_revealed) setState(() => _revealed = false);
      showBankSnackBar(
        context,
        "Full account number isn't available for security",
      );
      return;
    }

    final next = !_revealed;
    setState(() => _revealed = next);
    _hideTimer?.cancel();
    if (next) {
      _hideTimer = Timer(const Duration(seconds: 15), () {
        if (mounted) setState(() => _revealed = false);
      });
    }
  }

  Future<void> _openAddAccount() async {
    final saved = await Navigator.of(context).push<bool>(
      MaterialPageRoute<bool>(
        builder: (_) => const AddBankAccountScreen(),
      ),
    );
    if (saved == true && mounted) _closeWithChange();
  }

  Future<void> _openChangeAccount() async {
    final existing = widget.details;
    if (existing != null && existing.isUpi) {
      showBankSnackBar(
        context,
        "Changing a UPI ID isn't available yet",
      );
      return;
    }
    final editable = existing != null && existing.isBank && existing.id != null;
    final saved = await Navigator.of(context).push<bool>(
      MaterialPageRoute<bool>(
        builder: (_) => AddBankAccountScreen(
          existing: editable ? existing : null,
          makeDefault: editable ? existing.isDefault : false,
        ),
      ),
    );
    if (saved == true && mounted) _closeWithChange();
  }

  void _closeWithChange() {
    final navigator = Navigator.of(context);
    if (navigator.canPop()) navigator.pop(true);
  }

  void _requestReverification() {
    showBankSnackBar(context, 'Re-verification is not available yet');
  }

  @override
  Widget build(BuildContext context) {
    final scale = context.sportoScale;
    final details = widget.details;

    if (details == null) {
      return Scaffold(
        backgroundColor: context.sporto.canvas,
        body: SafeArea(
          bottom: false,
          child: Column(
            children: [
              const BankHeader(title: 'Bank Account Details'),
              Expanded(
                child: Center(
                  child: Text(
                    'No bank account selected.',
                    style: TextStyle(
                      fontSize: 14 * scale,
                      color: context.sporto.muted,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    final fullNumber = bankFullAccountNumber(details);
    final maskedNumber = bankMaskedAccountLabel(details);
    final canReveal = fullNumber != null;
    final number = _revealed && fullNumber != null ? fullNumber : maskedNumber;
    final isUpi = details.isUpi;

    return Scaffold(
      backgroundColor: context.sporto.canvas,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            const BankHeader(title: 'Bank Account Details'),
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(
                  20 * scale,
                  10 * scale,
                  20 * scale,
                  24 * scale,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _DetailsCard(
                      scale: scale,
                      details: details,
                      revealed: _revealed,
                      displayNumber: number.trim().isEmpty
                          ? (isUpi ? 'UPI account' : 'Account not available')
                          : number,
                      showReveal: !isUpi,
                      onToggleReveal: _toggleReveal,
                    ),
                    if (!canReveal && !isUpi) ...[
                      SizedBox(height: 8 * scale),
                      Text(
                        'Full account numbers are hidden for security.',
                        style: SportoTextStyles.text(
                          size: 12,
                          weight: FontWeight.w400,
                          color: context.sporto.muted,
                          height: 15 / 12,
                        ),
                      ),
                    ],
                    SizedBox(height: 20 * scale),
                    LayoutBuilder(
                      builder: (context, constraints) {
                        final addButton = _DetailActionButton(
                          scale: scale,
                          label: 'Add Bank Account',
                          icon: BankIcons.plus,
                          onTap: _openAddAccount,
                        );
                        final changeButton = _DetailActionButton(
                          scale: scale,
                          label: 'Change Bank Account',
                          icon: BankIcons.checkCircle,
                          glowWhite: true,
                          onTap: _openChangeAccount,
                        );
                        final reverifyButton = _DetailActionButton(
                          scale: scale,
                          label: 'Re-verify Bank Account',
                          icon: BankIcons.checkCircle,
                          glowWhite: true,
                          onTap: _requestReverification,
                        );

                        if (constraints.maxWidth < 330 * scale) {
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              addButton,
                              SizedBox(height: 12 * scale),
                              changeButton,
                              SizedBox(height: 12 * scale),
                              reverifyButton,
                            ],
                          );
                        }

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Row(
                              children: [
                                Expanded(child: addButton),
                                SizedBox(width: 12 * scale),
                                Expanded(child: changeButton),
                              ],
                            ),
                            SizedBox(height: 12 * scale),
                            reverifyButton,
                          ],
                        );
                      },
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

class _DetailsCard extends StatelessWidget {
  const _DetailsCard({
    required this.scale,
    required this.details,
    required this.revealed,
    required this.displayNumber,
    required this.showReveal,
    required this.onToggleReveal,
  });

  final double scale;
  final RefereeBankDetails details;
  final bool revealed;
  final String displayNumber;
  final bool showReveal;
  final VoidCallback onToggleReveal;

  String _value(String? value) {
    final trimmed = value?.trim() ?? '';
    return trimmed.isEmpty ? '—' : trimmed;
  }

  @override
  Widget build(BuildContext context) {
    final sporto = context.sporto;
    final verification = bankVerificationLabel(details);

    return Container(
      padding: EdgeInsets.all(14 * scale),
      decoration: BoxDecoration(
        color: sporto.cardElevated,
        borderRadius: BorderRadius.circular(16 * scale),
      ),
      child: Column(
        children: [
          SizedBox(
            height: 44 * scale,
            child: Row(
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Flexible(
                        child: Text(
                          displayNumber,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: SportoTextStyles.text(
                            size: 16,
                            weight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      if (showReveal) ...[
                        SizedBox(width: 8 * scale),
                        SizedBox.square(
                          dimension: 44 * scale,
                          child: IconButton(
                            key: const ValueKey('bank_eye_toggle'),
                            tooltip: revealed
                                ? 'Hide account number'
                                : 'Show account number',
                            padding: EdgeInsets.zero,
                            iconSize: 16 * scale,
                            onPressed: onToggleReveal,
                            icon: SportoSvgIcon(
                              revealed ? BankIcons.eyeOff : BankIcons.eye,
                              width: 16 * scale,
                              height: 16 * scale,
                              color: sporto.muted,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                SizedBox(width: 8 * scale),
                BankStatusPill(
                  label: verification,
                  positive: bankIsVerified(details),
                ),
              ],
            ),
          ),
          SizedBox(height: 8 * scale),
          Container(
            height: 1,
            color: Colors.white.withValues(alpha: .10),
          ),
          SizedBox(height: 8 * scale),
          _DetailRow(
            scale: scale,
            label: 'Bank',
            value: _value(details.bankName),
          ),
          SizedBox(height: 4 * scale),
          _DetailRow(
            scale: scale,
            label: 'IFSC',
            value: _value(details.ifscCode),
          ),
          SizedBox(height: 4 * scale),
          _DetailRow(
            scale: scale,
            label: 'Account holder',
            value: _value(details.accountHolderName),
          ),
          SizedBox(height: 4 * scale),
          _DetailRow(
            scale: scale,
            label: 'UPI ID',
            value: _value(details.upiId),
          ),
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({
    required this.scale,
    required this.label,
    required this.value,
  });

  final double scale;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final style = SportoTextStyles.text(
      size: 12,
      weight: FontWeight.w500,
      color: context.sporto.muted,
      height: 15 / 12,
    );

    return Row(
      children: [
        Text(label, style: style),
        SizedBox(width: 12 * scale),
        Expanded(
          child: Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.end,
            style: style,
          ),
        ),
      ],
    );
  }
}

class _DetailActionButton extends StatelessWidget {
  const _DetailActionButton({
    required this.scale,
    required this.label,
    required this.icon,
    required this.onTap,
    this.glowWhite = false,
  });

  final double scale;
  final String label;
  final String icon;
  final VoidCallback onTap;
  final bool glowWhite;

  @override
  Widget build(BuildContext context) {
    final sporto = context.sporto;

    return Material(
      color: sporto.cardElevated,
      borderRadius: BorderRadius.circular(14 * scale),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: SizedBox(
          height: 44 * scale,
          width: double.infinity,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 12 * scale),
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SportoSvgIcon(
                    icon,
                    width: 14 * scale,
                    height: 14 * scale,
                    color: glowWhite ? Colors.white : null,
                  ),
                  SizedBox(width: 6 * scale),
                  Text(
                    label,
                    maxLines: 1,
                    softWrap: false,
                    style: SportoTextStyles.text(
                      size: 12,
                      weight: FontWeight.w500,
                      color: Colors.white,
                      height: 15 / 12,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
