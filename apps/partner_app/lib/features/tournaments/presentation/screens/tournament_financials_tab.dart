import 'package:flutter/material.dart';
import 'package:partner_data/partner_data.dart';
import 'package:ui_kit/ui_kit.dart';

import '../widgets/redesign/tournament_cards.dart';
import '../widgets/redesign/tournament_navigation.dart';
import '../widgets/redesign/tournament_redesign_data.dart';
import '../widgets/redesign/tournament_visuals.dart';

class TournamentFinancialsTab extends StatefulWidget {
  const TournamentFinancialsTab({
    super.key,
    this.review,
  });

  final PartnerTournamentReviewData? review;

  @override
  State<TournamentFinancialsTab> createState() =>
      _TournamentFinancialsTabState();
}

class _TournamentFinancialsTabState extends State<TournamentFinancialsTab> {
  int _subTab = 0;

  static const _labels = [
    'Summary',
    'Income',
    'Sponsorship',
    'Prize',
    'Expenses',
    'Profit',
  ];

  @override
  Widget build(BuildContext context) {
    final t = context.sportoTournament;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TournamentSubTabs(
          labels: _labels,
          selectedIndex: _subTab,
          onChanged: (index) => setState(() => _subTab = index),
          accentColor: t.gold,
        ),
        const SizedBox(height: 16),
        TournamentSurface(
          radius: t.r11,
          padding: const EdgeInsets.all(14),
          child: switch (_subTab) {
            0 => _summary(context),
            1 => _transactionList(
                context,
                'Income',
                demoIncomeTransactions,
              ),
            2 => _transactionList(
                context,
                'Sponsorship',
                demoSponsorshipTransactions,
              ),
            3 => _transactionList(
                context,
                'Prize',
                demoPrizeTransactions,
              ),
            4 => _transactionList(
                context,
                'Expenses',
                demoExpenseTransactions,
              ),
            _ => _profit(context),
          },
        ),
      ],
    );
  }

  Widget _summary(BuildContext context) {
    final t = context.sportoTournament;
    final summary = widget.review?.financialSummary;
    final estimated = summary?.estimatedCollection ?? 40000;
    final sponsorship = 18804;
    final platformFee = summary?.platformFeeAmount ?? 2800;
    final prize = summary?.totalPrizeMoney ?? '12000';
    final referee = 9500;
    final net = summary?.netEarnings ?? 23196;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Financial Summary',
          style: SportoTextStyles.text(
            size: SportoTextStyles.size15,
            color: t.muted,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _summaryTile(
                context,
                '+${formatCurrencyValue(estimated)}',
                'Registration revenue',
                t.green,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _summaryTile(
                context,
                formatCurrencyValue(sponsorship),
                'Sponsorship Received',
                t.warm,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: _summaryTile(
                context,
                '-${formatCurrencyValue(platformFee)}',
                'SPOTO platform fee',
                t.gold,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _summaryTile(
                context,
                formatCurrency(prize),
                'Prize money paid',
                t.warm,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: _summaryTile(
                context,
                '-${formatCurrencyValue(referee)}',
                'Referee Booking Paid',
                t.green,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _summaryTile(
                context,
                '0',
                'Refunds',
                t.green,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Center(
          child: Container(
            width: 190,
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: t.cardAlt,
              borderRadius: BorderRadius.circular(t.r11),
              border: Border.all(color: t.green.withValues(alpha: .3)),
            ),
            child: Column(
              children: [
                Text(
                  '+${formatCurrencyValue(net)}',
                  style: SportoTextStyles.text(
                    size: SportoTextStyles.size16,
                    weight: FontWeight.w700,
                    color: t.green,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  'Net profit / loss',
                  style: SportoTextStyles.text(
                    size: SportoTextStyles.size12,
                    color: t.muted,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _summaryTile(
    BuildContext context,
    String value,
    String label,
    Color valueColor,
  ) {
    final t = context.sportoTournament;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: t.cardAlt,
        borderRadius: BorderRadius.circular(t.r9),
        border: Border.all(color: t.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.trending_up_rounded, size: 14, color: valueColor),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: SportoTextStyles.text(
                    size: SportoTextStyles.size15,
                    weight: FontWeight.w600,
                    color: valueColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: SportoTextStyles.text(
              size: SportoTextStyles.size11,
              color: t.muted,
            ),
          ),
        ],
      ),
    );
  }

  Widget _transactionList(
    BuildContext context,
    String title,
    List<DemoTransaction> items,
  ) {
    final t = context.sportoTournament;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: SportoTextStyles.text(
            size: SportoTextStyles.size15,
            color: t.muted,
          ),
        ),
        const SizedBox(height: 12),
        for (var i = 0; i < items.length; i++) ...[
          TournamentTransactionRow(
            title: items[i].title,
            dateText: items[i].date,
            code: items[i].code,
            amount: items[i].amount,
            positive: items[i].positive,
          ),
          if (i != items.length - 1) const SizedBox(height: 8),
        ],
      ],
    );
  }

  Widget _profit(BuildContext context) {
    final t = context.sportoTournament;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Profit Calculation',
          style: SportoTextStyles.text(
            size: SportoTextStyles.size15,
            color: t.muted,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: t.card,
            borderRadius: BorderRadius.circular(t.r11),
            border: Border.all(color: t.gold.withValues(alpha: .25)),
          ),
          child: Column(
            children: [
              for (var i = 0; i < demoProfitRows.length; i++)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 9,
                  ),
                  decoration: BoxDecoration(
                    border: i == demoProfitRows.length - 1
                        ? null
                        : Border(
                            bottom: BorderSide(color: t.border),
                          ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          demoProfitRows[i].label,
                          style: SportoTextStyles.text(
                            size: SportoTextStyles.size13,
                            color:
                                demoProfitRows[i].emphasis ? t.warm : t.muted,
                          ),
                        ),
                      ),
                      Text(
                        demoProfitRows[i].amount,
                        style: SportoTextStyles.text(
                          size: SportoTextStyles.size13,
                          weight: FontWeight.w600,
                          color: demoProfitRows[i].amount.startsWith('-')
                              ? t.red
                              : t.green,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 18),
        Text(
          'Settlement',
          style: SportoTextStyles.text(
            size: SportoTextStyles.size15,
            color: t.muted,
          ),
        ),
        const SizedBox(height: 12),
        for (var i = 0; i < demoSettlements.length; i++) ...[
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: t.cardAlt,
              borderRadius: BorderRadius.circular(t.r9),
              border: Border.all(color: t.border),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        demoSettlements[i].title,
                        style: SportoTextStyles.text(
                          size: SportoTextStyles.size14,
                          color: t.warm,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        demoSettlements[i].subtitle,
                        style: SportoTextStyles.text(
                          size: SportoTextStyles.size11,
                          color: t.dim,
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '16 Jul 2026, 10:45 am',
                      style: SportoTextStyles.text(
                        size: SportoTextStyles.size11,
                        color: t.muted,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      demoSettlements[i].amount,
                      style: SportoTextStyles.text(
                        size: SportoTextStyles.size14,
                        weight: FontWeight.w600,
                        color: t.green,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          if (i != demoSettlements.length - 1) const SizedBox(height: 8),
        ],
      ],
    );
  }
}
