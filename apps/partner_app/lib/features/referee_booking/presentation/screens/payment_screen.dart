import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:ui_kit/ui_kit.dart';

import '../widgets/booking_primary_button.dart';
import '../widgets/booking_venue_card.dart';

/// Screen 10 - Payment (Figma E1-10).
class PaymentScreen extends StatefulWidget {
  const PaymentScreen({super.key});

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  int _method = 1; // 0 = Credit Card, 1 = Wallet

  @override
  Widget build(BuildContext context) {
    final tokens = context.sporto;
    final gap = context.sportoLayout;
    return MediaQuery.withNoTextScaling(
      child: Scaffold(
        backgroundColor: tokens.canvas,
        appBar: SportoBookingAppBar(
          title: 'Payment',
          onBack: () => context.canPop() ? context.pop() : context.go('/'),
        ),
        body: SafeArea(
          top: false,
          child: ListView(
            padding: EdgeInsets.fromLTRB(20, gap.space10, 20, gap.space20),
            children: [
              const BookingVenueCard(
                sport: 'Cricket',
                venue: 'KPHB Indoor Stadium',
                area: 'Kompally, Hyderabad',
              ),
              SizedBox(height: gap.space20),
              const SportoPriceSummaryCard(
                rows: [SportoPriceRow('Referee', 'To Be Assigned')],
                totalLabel: 'Total Amount',
                totalValue: '\u20B91385',
              ),
              SizedBox(height: gap.space20),
              Text(
                'Select Your Payment Method',
                style: SportoTextStyles.text(
                  size: SportoTextStyles.size14,
                  weight: SportoTextStyles.medium,
                  color: tokens.textTertiary,
                ),
              ),
              SizedBox(height: gap.space10),
              Row(
                children: [
                  Expanded(
                    child: SportoPaymentMethodTile(
                      label: 'Credit Card',
                      icon: const SportoSvgIcon(
                          SportoRefereeBookingIcons.creditCard,
                          size: 24),
                      selected: _method == 0,
                      onTap: () => setState(() => _method = 0),
                    ),
                  ),
                  SizedBox(width: gap.space16),
                  Expanded(
                    child: SportoPaymentMethodTile(
                      label: 'Wallet',
                      icon: const SportoSvgIcon(
                          SportoRefereeBookingIcons.wallet,
                          size: 24),
                      selected: _method == 1,
                      onTap: () => setState(() => _method = 1),
                    ),
                  ),
                ],
              ),
              SizedBox(height: gap.space16),
              _MethodRow(
                label: 'G Pay',
                trailing: _SavedCheck(
                  onTap: () => setState(() => _method = 1),
                ),
              ),
              SizedBox(height: gap.space16),
              const _MethodRow(
                label: 'Add UPI',
                trailing: SportoSvgIcon(
                    SportoRefereeBookingIcons.addSquare, size: 24),
              ),
              SizedBox(height: gap.space16),
              const _MethodRow(
                label: 'Add New Wallet',
                trailing: SportoSvgIcon(
                    SportoRefereeBookingIcons.addSquare, size: 24),
              ),
              SizedBox(height: gap.space30),
              BookingPrimaryButton(
                label: 'Pay \u20B91385',
                onTap: () => context.go('/book-referee/success'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MethodRow extends StatelessWidget {
  final String label;
  final Widget trailing;

  const _MethodRow({required this.label, required this.trailing});

  @override
  Widget build(BuildContext context) {
    final tokens = context.sporto;
    final layout = context.sportoLayout;
    return SportoGlassSurface(
      radius: layout.radius16,
      blur: layout.glassBlur,
      color: tokens.cardElevated,
      borderGradient: SportoGlassBorders.white,
      padding: EdgeInsets.symmetric(
          horizontal: layout.space16, vertical: layout.space16),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: SportoTextStyles.text(
                size: SportoTextStyles.size16,
                weight: SportoTextStyles.medium,
                color: tokens.muted,
              ),
            ),
          ),
          trailing,
        ],
      ),
    );
  }
}

class _SavedCheck extends StatelessWidget {
  final VoidCallback onTap;
  const _SavedCheck({required this.onTap});

  @override
  Widget build(BuildContext context) {
    final tokens = context.sporto;
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        width: 18,
        height: 18,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: tokens.primaryGradient,
        ),
        child: const Center(
          child: SportoSvgIcon(SportoRefereeBookingIcons.check, size: 10),
        ),
      ),
    );
  }
}
