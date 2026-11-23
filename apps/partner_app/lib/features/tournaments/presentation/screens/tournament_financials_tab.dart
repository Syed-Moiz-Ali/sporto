import 'package:flutter/material.dart';
import 'package:partner_data/partner_data.dart';
import 'package:ui_kit/ui_kit.dart';

import '../widgets/redesign/tournament_redesign_data.dart';
import '../widgets/redesign/tournament_visuals.dart';

/// Financials tab — Figma `Partner App / Financials` (export 29–34, 47).
///
/// Only the summary is backed by the API (`/review` → `financial_summary`)
/// plus the tournament's sponsors. Income / expense ledgers have no endpoint,
/// so those sub-tabs are not fabricated.
class TournamentFinancialsTab extends StatelessWidget {
  const TournamentFinancialsTab({super.key, this.review, this.tournament});

  final PartnerTournamentReviewData? review;
  final PartnerTournamentResponse? tournament;

  @override
  Widget build(BuildContext context) {
    final t = context.sportoTournament;
    final scale = context.sportoScale;
    final summary = review?.financialSummary;
    final sponsors = tournament?.tournamentSponsors ?? const [];
    final sponsorTotal = sponsors.fold<int>(
      0,
      (sum, s) => sum + (int.tryParse(s.contributionAmount) ?? 0),
    );

    if (summary == null && sponsors.isEmpty) {
      return Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(
          horizontal: 16 * scale,
          vertical: 36 * scale,
        ),
        decoration: BoxDecoration(
          color: t.cardAlt,
          borderRadius: BorderRadius.circular(t.r16),
          border: Border.all(color: t.border),
        ),
        child: Column(
          children: [
            Icon(Icons.receipt_long_outlined, size: 32, color: t.dim),
            SizedBox(height: 10 * scale),
            Text(
              'No financial summary available',
              textAlign: TextAlign.center,
              style: SportoTextStyles.text(
                size: SportoTextStyles.size14,
                weight: FontWeight.w600,
                color: t.white,
              ),
            ),
          ],
        ),
      );
    }

    final net = summary?.netEarnings ?? 0;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SummaryCard(
          rows: [
            if (summary != null)
              _Row(
                'Registration revenue',
                formatCurrencyValue(summary.estimatedCollection),
                t.green,
              ),
            if (sponsorTotal > 0)
              _Row(
                'Sponsorship Received',
                formatCurrencyValue(sponsorTotal),
                t.green,
              ),
            if (summary != null)
              _Row(
                'SPOTO platform fee',
                '-${formatCurrencyValue(summary.platformFeeAmount)}',
                t.red,
              ),
            if (summary != null)
              _Row(
                'Prize money paid',
                '-${formatCurrency(summary.totalPrizeMoney)}',
                t.red,
              ),
          ],
          netLabel: 'Net profit / loss',
          netValue: formatCurrencyValue(net),
          netPositive: net >= 0,
        ),
        if (sponsors.isNotEmpty) ...[
          SizedBox(height: 10 * scale),
          _SponsorBreakdown(sponsors: sponsors),
        ],
        SizedBox(height: 10 * scale),
        Text(
          'Income, prize and expense ledgers are not exposed by the partner '
          'API yet, so only the summary is shown.',
          style: SportoTextStyles.text(
            size: SportoTextStyles.size10,
            color: t.dim,
          ),
        ),
      ],
    );
  }
}

class _Row {
  const _Row(this.label, this.value, this.color);

  final String label;
  final String value;
  final Color color;
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.rows,
    required this.netLabel,
    required this.netValue,
    required this.netPositive,
  });

  final List<_Row> rows;
  final String netLabel;
  final String netValue;
  final bool netPositive;

  @override
  Widget build(BuildContext context) {
    final t = context.sportoTournament;
    final scale = context.sportoScale;
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(12 * scale),
      decoration: BoxDecoration(
        color: t.cardAlt,
        borderRadius: BorderRadius.circular(t.r16),
        border: GradientBorder.all(
          gradient: t.whiteBorderGradient,
          width: 1,
          radius: t.r16,
        ),
        boxShadow: t.softCardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Summary',
            style: SportoTextStyles.text(
              size: SportoTextStyles.size12,
              weight: FontWeight.w500,
              color: t.dim,
            ),
          ),
          SizedBox(height: 10 * scale),
          for (var i = 0; i < rows.length; i++) ...[
            _Line(
                label: rows[i].label,
                value: rows[i].value,
                color: rows[i].color),
            SizedBox(height: 8 * scale),
          ],
          TournamentDivider(
            height: .8,
            color: t.border.withValues(alpha: .5),
          ),
          SizedBox(height: 10 * scale),
          _Line(
            label: netLabel,
            value: netValue,
            color: netPositive ? t.greenBright : t.red,
            bold: true,
          ),
        ],
      ),
    );
  }
}

class _SponsorBreakdown extends StatelessWidget {
  const _SponsorBreakdown({required this.sponsors});

  final List<PartnerTournamentSponsorResponse> sponsors;

  @override
  Widget build(BuildContext context) {
    final t = context.sportoTournament;
    final scale = context.sportoScale;
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(12 * scale),
      decoration: BoxDecoration(
        color: t.cardAlt,
        borderRadius: BorderRadius.circular(t.r16),
        border: Border.all(color: t.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Sponsors',
            style: SportoTextStyles.text(
              size: SportoTextStyles.size12,
              weight: FontWeight.w500,
              color: t.dim,
            ),
          ),
          SizedBox(height: 8 * scale),
          for (var i = 0; i < sponsors.length; i++) ...[
            _Line(
              label: sponsors[i].name,
              value: formatCurrency(sponsors[i].contributionAmount),
              color: t.gold,
            ),
            if (i != sponsors.length - 1) SizedBox(height: 8 * scale),
          ],
        ],
      ),
    );
  }
}

class _Line extends StatelessWidget {
  const _Line({
    required this.label,
    required this.value,
    required this.color,
    this.bold = false,
  });

  final String label;
  final String value;
  final Color color;
  final bool bold;

  @override
  Widget build(BuildContext context) {
    final t = context.sportoTournament;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Flexible(
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: SportoTextStyles.text(
              size: SportoTextStyles.size12,
              weight: bold ? FontWeight.w600 : FontWeight.w400,
              color: bold ? t.white : t.muted,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Flexible(
          child: Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.right,
            style: SportoTextStyles.text(
              size: SportoTextStyles.size12,
              weight: bold ? FontWeight.w700 : FontWeight.w500,
              color: color,
            ),
          ),
        ),
      ],
    );
  }
}
