import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:ui_kit/ui_kit.dart';

import '../../application/booking_bloc.dart';
import '../widgets/booking_primary_button.dart';
import '../widgets/booking_venue_card.dart';

/// Screen 10 / 16 - Payment (Figma E1-10 quick, E1-16 choose-referee).
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
    final isReferee =
        context.watch<BookingBloc>().state.bookingMode == BookingMode.choose;
    final total = isReferee ? '\u20B91440' : '\u20B91385';

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
              if (isReferee)
                const _RefereeSummaryHeaderCard()
              else
                const BookingVenueCard(
                  sport: 'Cricket',
                  venue: 'KPHB Indoor Stadium',
                  area: 'Kompally, Hyderabad',
                ),
              SizedBox(height: gap.space20),
              SportoPriceSummaryCard(
                rows: [
                  SportoPriceRow('Referee', isReferee ? 'Vijay Mohan' : 'To Be Assigned'),
                ],
                totalLabel: 'Total Amount',
                totalValue: total,
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
                trailing: _SavedCheck(onTap: () => setState(() => _method = 1)),
              ),
              SizedBox(height: gap.space16),
              const _MethodRow(
                label: 'Add UPI',
                trailing:
                    SportoSvgIcon(SportoRefereeBookingIcons.addSquare, size: 24),
              ),
              SizedBox(height: gap.space16),
              const _MethodRow(
                label: 'Add New Wallet',
                trailing:
                    SportoSvgIcon(SportoRefereeBookingIcons.addSquare, size: 24),
              ),
              SizedBox(height: gap.space30),
              BookingPrimaryButton(
                label: 'Pay $total',
                onTap: () => context.go('/book-referee/success'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RefereeSummaryHeaderCard extends StatelessWidget {
  const _RefereeSummaryHeaderCard();

  @override
  Widget build(BuildContext context) {
    final tokens = context.sporto;
    final layout = context.sportoLayout;
    final onSurface = Theme.of(context).colorScheme.onSurface;
    final pink = LinearGradient(
      colors:
          tokens.gradientPink.colors.map((c) => c.withValues(alpha: 0.2)).toList(),
    );
    return SportoGlassSurface(
      radius: layout.radius20,
      blur: layout.glassBlur,
      gradient: pink,
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Referee',
            style: SportoTextStyles.text(
              size: SportoTextStyles.size14,
              weight: SportoTextStyles.medium,
              color: tokens.muted,
            ),
          ),
          SizedBox(height: layout.space10),
          Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: tokens.avatarGreen.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(13.16),
                ),
                clipBehavior: Clip.antiAlias,
                child: const SportoAssetIcon(
                  SportoRefereeBookingIcons.avatarReferee,
                  size: 50,
                  fit: BoxFit.cover,
                ),
              ),
              SizedBox(width: layout.space10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Vijay Mohan',
                      style: SportoTextStyles.text(
                        size: SportoTextStyles.size16,
                        weight: SportoTextStyles.semiBold,
                        color: onSurface,
                      ),
                    ),
                    Text(
                      'Cricket',
                      style: SportoTextStyles.text(
                        size: SportoTextStyles.size12,
                        weight: SportoTextStyles.medium,
                        color: tokens.accentGreen,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: layout.space10),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SportoSvgIcon(SportoRefereeBookingIcons.pinGreen,
                  width: 11, height: 12),
              SizedBox(width: layout.space4),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'KPHB Indoor Stadium',
                      style: SportoTextStyles.text(
                        size: SportoTextStyles.size14,
                        weight: SportoTextStyles.medium,
                        color: onSurface,
                      ),
                    ),
                    Text(
                      'Kompally, Hyderabad',
                      style: SportoTextStyles.text(
                        size: SportoTextStyles.size12,
                        weight: SportoTextStyles.regular,
                        color: tokens.muted,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
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

