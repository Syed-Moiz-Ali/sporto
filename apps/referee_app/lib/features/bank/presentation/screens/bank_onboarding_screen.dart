import 'package:flutter/material.dart';
import 'package:ui_kit/ui_kit.dart';

import '../bank_icons.dart';
import '../widgets/bank_shared_widgets.dart';
import 'add_bank_account_screen.dart';

/// Empty-state entry point for the referee bank-account flow.
///
/// Figma frame: `01_On-boarding-Screen` (390 × 844).
class BankOnboardingScreen extends StatelessWidget {
  const BankOnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final scale = context.sportoScale;

    return Scaffold(
      backgroundColor: context.sporto.canvas,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            const BankHeader(title: 'Back Account'),
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(
                  20 * scale,
                  20 * scale,
                  20 * scale,
                  24 * scale,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const BankAlertBanner(
                      'No Bank Found! Please add your bank account.',
                    ),
                    SizedBox(height: 30 * scale),
                    _EmptyAccountCard(scale: scale),
                    SizedBox(height: 30 * scale),
                    Center(
                      child: BankGradientButton.gold(
                        label: 'Add Bank',
                        width: 270 * scale,
                        icon: SportoSvgIcon(
                          BankIcons.plus,
                          width: 14 * scale,
                          height: 14 * scale,
                        ),
                        onPressed: () async {
                          final saved = await Navigator.of(context).push<bool>(
                            MaterialPageRoute<bool>(
                              builder: (_) => const AddBankAccountScreen(
                                makeDefault: true,
                              ),
                            ),
                          );
                          if (saved == true && context.mounted) {
                            Navigator.of(context).pop(true);
                          }
                        },
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

class _EmptyAccountCard extends StatelessWidget {
  const _EmptyAccountCard({required this.scale});

  final double scale;

  @override
  Widget build(BuildContext context) {
    final sporto = context.sporto;

    return Semantics(
      container: true,
      label: 'No Bank Account. Please Add Your Bank Account',
      child: ExcludeSemantics(
        child: Container(
          padding: EdgeInsets.fromLTRB(
            20 * scale,
            30 * scale,
            20 * scale,
            20 * scale,
          ),
          decoration: BoxDecoration(
            color: sporto.cardElevated,
            borderRadius: BorderRadius.circular(30 * scale),
          ),
          child: Column(
            children: [
              Container(
                width: 140 * scale,
                height: 120 * scale,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10 * scale),
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      const Color(0xFFFF9364).withValues(alpha: .10),
                      const Color(0xFFF25F33).withValues(alpha: .10),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 20 * scale),
              Text(
                'No Bank Account',
                textAlign: TextAlign.center,
                style: SportoTextStyles.text(
                  size: 16,
                  weight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: 10 * scale),
              Text(
                'Please Add Your Bank Account',
                textAlign: TextAlign.center,
                style: SportoTextStyles.text(
                  size: 14,
                  weight: FontWeight.w600,
                  color: sporto.accentGreen,
                  height: 18 / 14,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
