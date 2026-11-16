import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:referee_data/referee_data.dart';
import 'package:ui_kit/ui_kit.dart';

import '../../../../core/di/dependency_injector.dart';
import '../bank_icons.dart';
import '../bank_models.dart';
import '../widgets/bank_shared_widgets.dart';
import 'add_bank_account_screen.dart';
import 'bank_account_details_screen.dart';
import 'bank_onboarding_screen.dart';

/// Saved-account list from the Figma `03_Back-Account` frame.
///
/// Production loads the referee bank endpoint. Tests can inject either a
/// [accountsFuture] or a [loadAccounts] callback so no live network is touched.
class BankAccountsScreen extends StatefulWidget {
  const BankAccountsScreen({
    super.key,
    this.accountsFuture,
    this.loadAccounts,
    this.submit,
    this.setDefault,
    this.deleteAccount,
  });

  /// One-shot future override for tests/previews.
  final Future<List<RefereeBankDetails>>? accountsFuture;

  /// Reloadable override used by tests to exercise retry/reload flows.
  final Future<List<RefereeBankDetails>> Function()? loadAccounts;

  /// Test/preview override forwarded to the add/change form.
  final BankDetailsSubmitter? submit;

  /// Test/preview overrides for bank mutations.
  final Future<void> Function(int id)? setDefault;
  final Future<void> Function(int id)? deleteAccount;

  @override
  State<BankAccountsScreen> createState() => _BankAccountsScreenState();
}

class _BankAccountsScreenState extends State<BankAccountsScreen> {
  late Future<List<RefereeBankDetails>> _accounts;
  int? _busyAccountId;

  RefereeRemoteDataSource get _remote =>
      DependencyInjector.instance.refereeRemoteDataSource;

  @override
  void initState() {
    super.initState();
    _accounts = _resolveAccounts();
  }

  Future<List<RefereeBankDetails>> _resolveAccounts() {
    final injected = widget.accountsFuture;
    if (injected != null) return injected;
    final loader = widget.loadAccounts;
    if (loader != null) return loader();
    return DependencyInjector.instance.refereeRemoteDataSource
        .listBankDetailsData();
  }

  void _reload() {
    setState(() {
      _accounts = _resolveAccounts();
    });
  }

  Future<void> _openAddAccount({required bool makeDefault}) async {
    final saved = await Navigator.of(context).push<bool>(
      MaterialPageRoute<bool>(
        builder: (_) => AddBankAccountScreen(
          makeDefault: makeDefault,
          submit: widget.submit,
        ),
      ),
    );
    if (saved == true && mounted) _reload();
  }

  Future<void> _openOnboarding() async {
    final saved = await Navigator.of(context).push<bool>(
      MaterialPageRoute<bool>(
        builder: (_) => const BankOnboardingScreen(),
      ),
    );
    if (saved == true && mounted) _reload();
  }

  Future<void> _openDetails(RefereeBankDetails details) async {
    final changed = await Navigator.of(context).push<bool>(
      MaterialPageRoute<bool>(
        builder: (_) => BankAccountDetailsScreen(details: details),
      ),
    );
    if (changed == true && mounted) _reload();
  }

  Future<void> _setDefault(RefereeBankDetails account) async {
    if (_busyAccountId != null) return;
    final id = account.id;
    if (id == null) {
      showBankSnackBar(context, 'Bank account id is missing.');
      return;
    }
    setState(() => _busyAccountId = id);
    try {
      final mutation = widget.setDefault;
      if (mutation != null) {
        await mutation(id);
      } else {
        await _remote.setDefaultBank(id);
      }
      if (!mounted) return;
      showBankSnackBar(context, 'Default bank updated.');
      _reload();
    } catch (error) {
      if (mounted) {
        showBankSnackBar(context, 'Unable to set default bank: $error');
      }
    } finally {
      if (mounted) setState(() => _busyAccountId = null);
    }
  }

  Future<void> _delete(RefereeBankDetails account) async {
    if (_busyAccountId != null) return;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: context.sporto.cardElevated,
        title: const Text(
          'Delete bank account?',
          style: TextStyle(color: Colors.white),
        ),
        content: Text(
          '${bankDetailsTitle(account)} will be removed from your payout '
          'accounts. This cannot be undone.',
          style: TextStyle(color: context.sporto.muted),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: context.sporto.red,
            ),
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    final id = account.id;
    if (id == null) {
      showBankSnackBar(context, 'Bank account id is missing.');
      return;
    }

    setState(() => _busyAccountId = id);
    try {
      final mutation = widget.deleteAccount;
      if (mutation != null) {
        await mutation(id);
      } else {
        await _remote.deleteBankDetails(id);
      }
      if (!mounted) return;
      showBankSnackBar(context, 'Bank account deleted.');
      _reload();
    } catch (error) {
      if (mounted) {
        showBankSnackBar(context, 'Unable to delete bank account: $error');
      }
    } finally {
      if (mounted) setState(() => _busyAccountId = null);
    }
  }

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
              child: FutureBuilder<List<RefereeBankDetails>>(
                future: _accounts,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const _AccountsLoadingState();
                  }
                  if (snapshot.hasError) {
                    return _AccountsErrorState(onRetry: _reload);
                  }
                  return _accountsContent(
                    context,
                    scale: scale,
                    accounts: snapshot.data ?? const [],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _accountsContent(
    BuildContext context, {
    required double scale,
    required List<RefereeBankDetails> accounts,
  }) {
    return SingleChildScrollView(
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
            onAdd: () => _openAddAccount(makeDefault: accounts.isEmpty),
          ),
          SizedBox(height: 20 * scale),
          if (accounts.isEmpty)
            _EmptyAccountsCard(
              scale: scale,
              onAdd: _openOnboarding,
            )
          else
            for (var index = 0; index < accounts.length; index++) ...[
              if (index > 0) SizedBox(height: 12 * scale),
              _BankAccountCard(
                scale: scale,
                account: accounts[index],
                busy: _busyAccountId == accounts[index].id,
                onTap: () => _openDetails(accounts[index]),
                onSetDefault: () => _setDefault(accounts[index]),
                onDelete: () => _delete(accounts[index]),
              ),
            ],
        ],
      ),
    );
  }
}

class _AccountsLoadingState extends StatelessWidget {
  const _AccountsLoadingState();

  @override
  Widget build(BuildContext context) {
    final sporto = context.sporto;

    return Semantics(
      liveRegion: true,
      label: 'Loading bank accounts',
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(color: sporto.gold),
            SizedBox(height: 16 * context.sportoScale),
            Text(
              'Loading bank accounts…',
              style: SportoTextStyles.text(
                size: 14,
                weight: FontWeight.w400,
                color: sporto.muted,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AccountsErrorState extends StatelessWidget {
  const _AccountsErrorState({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final scale = context.sportoScale;
    final sporto = context.sporto;

    return Center(
      child: Padding(
        padding: EdgeInsets.all(24 * scale),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.cloud_off_rounded,
              size: 44 * scale,
              color: sporto.muted,
            ),
            SizedBox(height: 16 * scale),
            Text(
              "Couldn't load bank accounts.",
              textAlign: TextAlign.center,
              style: SportoTextStyles.text(
                size: 16,
                weight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
            SizedBox(height: 8 * scale),
            Text(
              'Check your connection and try again.',
              textAlign: TextAlign.center,
              style: SportoTextStyles.text(
                size: 14,
                weight: FontWeight.w400,
                color: sporto.muted,
              ),
            ),
            SizedBox(height: 20 * scale),
            BankGradientButton.gold(
              label: 'Retry',
              width: 160 * scale,
              onPressed: onRetry,
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
    required this.onSetDefault,
    required this.onDelete,
    this.busy = false,
  });

  final double scale;
  final RefereeBankDetails account;
  final VoidCallback onTap;
  final VoidCallback onSetDefault;
  final VoidCallback onDelete;
  final bool busy;

  @override
  Widget build(BuildContext context) {
    final sporto = context.sporto;
    final title = bankDetailsTitle(account);
    final masked = bankMaskedAccountLabel(account);
    final holder = account.accountHolderName?.trim() ?? '';
    final verification = bankVerificationLabel(account);
    final logoAsset = BankIcons.logoForBank(title);

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
                  child: logoAsset.isEmpty
                      ? Icon(
                          account.isUpi
                              ? Icons.account_balance_wallet_rounded
                              : Icons.account_balance_rounded,
                          size: 24 * scale,
                          color: sporto.gold,
                        )
                      : SportoSvgIcon(
                          logoAsset,
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
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: SportoTextStyles.text(
                              size: 14,
                              weight: FontWeight.w700,
                              color: Colors.white,
                              height: 18 / 14,
                            ),
                          ),
                        ),
                        if (account.isDefault) ...[
                          SizedBox(width: 6 * scale),
                          const BankDefaultPill(),
                        ],
                      ],
                    ),
                    SizedBox(height: 6 * scale),
                    if (holder.isNotEmpty) ...[
                      Text(
                        'Account Name: $holder',
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
                    ],
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            account.isUpi
                                ? (masked.isEmpty ? 'UPI ID' : masked)
                                : 'A/c ${masked.isEmpty ? '—' : masked}',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: SportoTextStyles.text(
                              size: 12,
                              weight: FontWeight.w400,
                              color: sporto.muted,
                              height: 15 / 12,
                            ),
                          ),
                        ),
                        SizedBox(width: 6 * scale),
                        BankStatusPill(
                          label: verification,
                          positive: bankIsVerified(account),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              SizedBox(width: 2 * scale),
              if (busy)
                SizedBox(
                  width: 44 * scale,
                  height: 44 * scale,
                  child: Center(
                    child: SizedBox(
                      width: 18 * scale,
                      height: 18 * scale,
                      child: CircularProgressIndicator(
                        strokeWidth: 2 * scale,
                        color: sporto.gold,
                      ),
                    ),
                  ),
                )
              else
                Semantics(
                  label: 'Bank actions for $title',
                  button: true,
                  child: PopupMenuButton<_BankCardAction>(
                    tooltip: 'Bank actions',
                    icon: Icon(
                      Icons.more_vert_rounded,
                      size: 20 * scale,
                      color: sporto.muted,
                    ),
                    color: sporto.cardElevated,
                    onSelected: (action) {
                      switch (action) {
                        case _BankCardAction.setDefault:
                          onSetDefault();
                        case _BankCardAction.delete:
                          onDelete();
                      }
                    },
                    itemBuilder: (context) => [
                      if (!account.isDefault)
                        const PopupMenuItem(
                          value: _BankCardAction.setDefault,
                          child: Text('Set as default'),
                        ),
                      PopupMenuItem(
                        value: _BankCardAction.delete,
                        child: Text(
                          'Delete',
                          style: TextStyle(color: sporto.red),
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
      label: [
        title,
        if (holder.isNotEmpty) 'Account Name: $holder',
        if (masked.isNotEmpty)
          account.isUpi ? 'UPI ID: $masked' : 'Account ending $masked',
        verification,
        if (account.isDefault) 'Default account',
      ].join(', '),
      onTap: onTap,
      child: card,
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

enum _BankCardAction { setDefault, delete }
