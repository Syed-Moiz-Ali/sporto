import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:ui_kit/ui_kit.dart';

import '../bank_icons.dart';
import '../bank_models.dart';
import '../bank_store.dart';
import '../widgets/bank_shared_widgets.dart';
import 'add_bank_account_screen.dart';
import 'bank_account_details_screen.dart';
import 'bank_onboarding_screen.dart';

/// Saved-account list from the Figma `03_Back-Account` frame.
class BankAccountsScreen extends StatelessWidget {
  const BankAccountsScreen({
    super.key,
    this.accounts,
  });

  /// Test/preview override. Production reads [BankAccountsStore].
  final List<BankAccount>? accounts;

  void _openAddAccount(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => const AddBankAccountScreen(),
      ),
    );
  }

  void _openOnboarding(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => const BankOnboardingScreen(),
      ),
    );
  }

  void _openDetails(BuildContext context, BankAccount account) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => BankAccountDetailsScreen(details: account.details),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: BankAccountsStore.instance,
      builder: (context, _) {
        final items = accounts ?? BankAccountsStore.instance.accounts;
        return _accountsScaffold(context, items);
      },
    );
  }

  Widget _accountsScaffold(BuildContext context, List<BankAccount> accounts) {
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
                    _AccountsSummary(
                      scale: scale,
                      count: accounts.length,
                      onAdd: () => _openAddAccount(context),
                    ),
                    SizedBox(height: 20 * scale),
                    if (accounts.isEmpty)
                      _EmptyAccountsCard(
                        scale: scale,
                        onAdd: () => _openOnboarding(context),
                      )
                    else
                      for (var index = 0; index < accounts.length; index++) ...[
                        if (index > 0) SizedBox(height: 12 * scale),
                        _BankAccountCard(
                          scale: scale,
                          account: accounts[index],
                          onTap: () => _openDetails(context, accounts[index]),
                        ),
                      ],
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

class _AccountsSummary extends StatelessWidget {
  const _AccountsSummary({
    required this.scale,
    required this.count,
    required this.onAdd,
  });

  final double scale;
  final int count;
  final VoidCallback onAdd;

  String get _label => count == 1 ? '1 Bank Account' : '$count Banks Accounts';

  @override
  Widget build(BuildContext context) {
    final sporto = context.sporto;
    final radius = BorderRadius.circular(10 * scale);

    return Container(
      height: 52 * scale,
      padding: EdgeInsets.symmetric(
        horizontal: 14 * scale,
        vertical: 4 * scale,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16 * scale),
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            const Color(0xFF7AD3FF).withValues(alpha: .10),
            const Color(0xFF4FBAF0).withValues(alpha: .10),
          ],
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              _label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: SportoTextStyles.text(
                size: 14,
                weight: FontWeight.w500,
                color: Colors.white,
                height: 18 / 14,
              ),
            ),
          ),
          SizedBox(width: 8 * scale),
          Semantics(
            button: true,
            label: 'Add bank',
            onTap: onAdd,
            excludeSemantics: true,
            child: SizedBox(
              height: 44 * scale,
              child: Center(
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: radius,
                    onTap: onAdd,
                    child: CustomPaint(
                      painter: _DashedRoundedBorderPainter(
                        color: sporto.accentGreen.withValues(alpha: .20),
                        radius: 10 * scale,
                      ),
                      child: Container(
                        constraints: BoxConstraints(minHeight: 30 * scale),
                        padding: EdgeInsets.symmetric(
                          horizontal: 10 * scale,
                          vertical: 5 * scale,
                        ),
                        decoration: BoxDecoration(
                          color: sporto.accentGreen.withValues(alpha: .04),
                          borderRadius: radius,
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            SportoSvgIcon(
                              BankIcons.plusGreen,
                              width: 12 * scale,
                              height: 12 * scale,
                            ),
                            SizedBox(width: 6 * scale),
                            Text(
                              'Add bank',
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
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BankAccountCard extends StatelessWidget {
  const _BankAccountCard({
    required this.scale,
    required this.account,
    required this.onTap,
  });

  final double scale;
  final BankAccount account;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final sporto = context.sporto;

    final card = Material(
      color: sporto.cardElevated,
      borderRadius: BorderRadius.circular(14 * scale),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: EdgeInsets.all(12 * scale),
          child: Row(
            children: [
              Container(
                width: 50 * scale,
                height: 50 * scale,
                decoration: BoxDecoration(
                  color: const Color(0xFF1B2335),
                  borderRadius: BorderRadius.circular(15 * scale),
                ),
                child: Center(
                  child: account.logoAsset.isEmpty
                      ? Icon(
                          Icons.account_balance_rounded,
                          size: 24 * scale,
                          color: sporto.gold,
                        )
                      : SportoSvgIcon(
                          account.logoAsset,
                          size: 26 * scale,
                        ),
                ),
              ),
              SizedBox(width: 9 * scale),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      account.bankName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: SportoTextStyles.text(
                        size: 14,
                        weight: FontWeight.w700,
                        color: Colors.white,
                        height: 18 / 14,
                      ),
                    ),
                    SizedBox(height: 6 * scale),
                    Text(
                      'Account Name: ${account.accountHolderName}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: SportoTextStyles.text(
                        size: 12,
                        weight: FontWeight.w400,
                        color: sporto.muted,
                        height: 15 / 12,
                      ),
                    ),
                    SizedBox(height: 2 * scale),
                    Text(
                      'A/c ${account.maskedAccountNumber}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: SportoTextStyles.text(
                        size: 12,
                        weight: FontWeight.w400,
                        color: sporto.muted,
                        height: 15 / 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );

    return Semantics(
      button: true,
      label: '${account.bankName}, Account Name: '
          '${account.accountHolderName}, account ending '
          '${account.lastFourDigits}',
      onTap: onTap,
      child: ExcludeSemantics(child: card),
    );
  }
}

class _EmptyAccountsCard extends StatelessWidget {
  const _EmptyAccountsCard({required this.scale, required this.onAdd});

  final double scale;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    final sporto = context.sporto;

    return Container(
      padding: EdgeInsets.all(24 * scale),
      decoration: BoxDecoration(
        color: sporto.cardElevated,
        borderRadius: BorderRadius.circular(16 * scale),
      ),
      child: Column(
        children: [
          Icon(
            Icons.account_balance_rounded,
            size: 44 * scale,
            color: sporto.gold,
          ),
          SizedBox(height: 16 * scale),
          Text(
            'No Bank Account',
            textAlign: TextAlign.center,
            style: SportoTextStyles.text(
              size: 16,
              weight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 8 * scale),
          Text(
            'Please add your bank account to receive payouts.',
            textAlign: TextAlign.center,
            style: SportoTextStyles.text(
              size: 14,
              weight: FontWeight.w400,
              color: sporto.muted,
            ),
          ),
          SizedBox(height: 20 * scale),
          BankGradientButton.gold(
            label: 'Add Bank',
            width: 220 * scale,
            icon: SportoSvgIcon(
              BankIcons.plus,
              width: 14 * scale,
              height: 14 * scale,
            ),
            onPressed: onAdd,
          ),
        ],
      ),
    );
  }
}

class _DashedRoundedBorderPainter extends CustomPainter {
  const _DashedRoundedBorderPainter({
    required this.color,
    required this.radius,
  });

  final Color color;
  final double radius;
  static const double dash = 5;
  static const double gap = 5;
  static const double strokeWidth = 1;

  @override
  void paint(Canvas canvas, Size size) {
    if (size.isEmpty) return;
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;
    final path = Path()
      ..addRRect(
        RRect.fromRectAndRadius(
          Offset.zero & size,
          Radius.circular(radius),
        ),
      );

    for (final metric in path.computeMetrics()) {
      var distance = 0.0;
      while (distance < metric.length) {
        final end = math.min(distance + dash, metric.length);
        canvas.drawPath(metric.extractPath(distance, end), paint);
        distance = end + gap;
      }
    }
  }

  @override
  bool shouldRepaint(covariant _DashedRoundedBorderPainter oldDelegate) =>
      color != oldDelegate.color || radius != oldDelegate.radius;
}
