import 'dart:async';

import 'package:flutter/material.dart';
import 'package:referee_app/core/config/referee_demo_data.dart';
import 'package:ui_kit/ui_kit.dart';

import '../bank_figma_data.dart';
import '../bank_icons.dart';
import '../bank_models.dart';
import '../widgets/bank_shared_widgets.dart';
import 'add_bank_account_screen.dart';

/// Verified bank account details from the Figma `04_Bank-Account-Details` frame.
class BankAccountDetailsScreen extends StatefulWidget {
  const BankAccountDetailsScreen({
    super.key,
    this.details,
  });

  final BankAccountDetails? details;

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
    final next = !_revealed;
    setState(() => _revealed = next);
    _hideTimer?.cancel();
    if (next) {
      _hideTimer = Timer(const Duration(seconds: 15), () {
        if (mounted) setState(() => _revealed = false);
      });
    }
  }

  void _openAddAccount() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => const AddBankAccountScreen(),
      ),
    );
  }

  void _requestReverification() {
    showBankSnackBar(context, 'Re-verification is not available yet');
  }

  @override
  Widget build(BuildContext context) {
    final scale = context.sportoScale;
    final details =
        widget.details ?? (kRefereeDemoData ? BankFigmaData.details : null);
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
    final number =
        _revealed ? details.accountNumber : details.maskedAccountNumber;

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
                          ? 'Account not available'
                          : number,
                      onToggleReveal: _toggleReveal,
                    ),
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
                          onTap: _openAddAccount,
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
    required this.onToggleReveal,
  });

  final double scale;
  final BankAccountDetails details;
  final bool revealed;
  final String displayNumber;
  final VoidCallback onToggleReveal;

  String _value(String value) => value.trim().isEmpty ? '—' : value;

  @override
  Widget build(BuildContext context) {
    final sporto = context.sporto;

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
                  ),
                ),
                SizedBox(width: 8 * scale),
                _VerifiedPill(scale: scale, isVerified: details.isVerified),
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

class _VerifiedPill extends StatelessWidget {
  const _VerifiedPill({required this.scale, required this.isVerified});

  final double scale;
  final bool isVerified;

  @override
  Widget build(BuildContext context) {
    final sporto = context.sporto;
    final color = isVerified ? sporto.accentGreen : sporto.muted;

    return Container(
      constraints: BoxConstraints(minHeight: 21 * scale),
      padding: EdgeInsets.fromLTRB(
        5 * scale,
        4 * scale,
        7 * scale,
        4 * scale,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: .06),
        borderRadius: BorderRadius.circular(50 * scale),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (isVerified)
            SportoSvgIcon(
              BankIcons.checkCircle,
              width: 12 * scale,
              height: 12 * scale,
            )
          else
            Icon(
              Icons.info_outline_rounded,
              size: 12 * scale,
              color: color,
            ),
          SizedBox(width: 3 * scale),
          Text(
            isVerified ? 'Verified' : 'Unverified',
            style: SportoTextStyles.text(
              size: 10,
              weight: FontWeight.w500,
              color: color,
              height: 13 / 10,
            ),
          ),
        ],
      ),
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
