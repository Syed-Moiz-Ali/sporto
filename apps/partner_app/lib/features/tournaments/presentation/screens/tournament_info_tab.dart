import 'package:flutter/material.dart';
import 'package:partner_data/partner_data.dart';
import 'package:ui_kit/ui_kit.dart';

import '../widgets/redesign/tournament_cards.dart';
import '../widgets/redesign/tournament_redesign_data.dart';
import '../widgets/redesign/tournament_screen_parts.dart';
import '../widgets/redesign/tournament_visuals.dart';

class TournamentInfoTab extends StatelessWidget {
  const TournamentInfoTab({
    super.key,
    required this.tournament,
    required this.matches,
    this.review,
    this.onOpenVenue,
    this.onOpenPrize,
    this.onEdit,
  });

  final PartnerTournamentResponse tournament;
  final List<PartnerTournamentMatchResponse> matches;
  final PartnerTournamentReviewData? review;
  final VoidCallback? onOpenVenue;
  final VoidCallback? onOpenPrize;
  final VoidCallback? onEdit;

  @override
  Widget build(BuildContext context) {
    final t = context.sportoTournament;
    final registered = tournament.registeredTeams ?? 0;
    final maxTeams = tournament.maximumTeams ?? 0;
    final upcoming = matches.where((m) => !m.isLive && !m.isCompleted).length;
    final live = matches.where((m) => m.isLive).length;
    final completed = matches.where((m) => m.isCompleted).length;
    final prize = review?.financialSummary.totalPrizeMoney ??
        tournament.totalPrizeMoney ??
        '0';
    final sponsor = tournament.tournamentSponsors.isNotEmpty
        ? tournament.tournamentSponsors.first
        : null;
    final coSponsor = tournament.tournamentSponsors.length > 1
        ? tournament.tournamentSponsors[1]
        : null;
    final description = '${tournament.description ?? ''}'.toLowerCase();
    final hasChanges = tournament.approvalStatus == 5 ||
        (tournament.approvalStatus == 2 &&
            (description.contains('change') ||
                description.contains('revision')));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (tournament.approvalStatus == 2 && !hasChanges) ...[
          const TournamentBanner(
            title: 'Under Review',
            message: 'Your tournament has been submitted for admin review.',
          ),
          const SizedBox(height: 12),
        ],
        if (hasChanges) ...[
          TournamentBanner(
            title: 'Admin Requested Changes',
            message: tournament.description?.isNotEmpty == true
                ? tournament.description!
                : 'Please revise the tournament configuration and submit again.',
            color: t.red,
          ),
          const SizedBox(height: 12),
        ],
        TournamentSurface(
          radius: t.r11,
          gradient: t.cardFadeGradient,
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Community Tournament',
                style: SportoTextStyles.text(
                  size: SportoTextStyles.size15,
                  weight: FontWeight.w500,
                  color: t.gold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                tournament.sportFormat?.name ??
                    tournament.tournamentType?.name ??
                    'Tournament',
                style: SportoTextStyles.text(
                  size: SportoTextStyles.size14,
                  color: t.warm,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        TournamentSurface(
          radius: t.r11,
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Tournament Details',
                      style: SportoTextStyles.text(
                        size: SportoTextStyles.size14,
                        color: t.muted,
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: onEdit,
                    child: Row(
                      children: [
                        Text(
                          'Edit',
                          style: SportoTextStyles.text(
                            size: SportoTextStyles.size12,
                            color: t.blue,
                          ),
                        ),
                        const SizedBox(width: 2),
                        Icon(Icons.arrow_forward_rounded,
                            size: 14, color: t.blue),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                'Knockout Format',
                style: SportoTextStyles.text(
                  size: SportoTextStyles.size15,
                  color: t.green,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Leather Ball · 3 Overs · 3 Balls/over · 5 Players/team\n'
                '20 mins Match · 10 mins Buffers',
                style: SportoTextStyles.text(
                  size: SportoTextStyles.size12,
                  color: t.muted,
                  height: 1.35,
                ),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: t.cardAlt,
                  borderRadius: BorderRadius.circular(t.r9),
                  border: Border.all(color: t.border),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      tournament.name,
                      style: SportoTextStyles.text(
                        size: SportoTextStyles.size16,
                        weight: FontWeight.w600,
                        color: t.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.location_on_outlined,
                            size: 14, color: t.green),
                        const SizedBox(width: 3),
                        Expanded(
                          child: Text(
                            tournamentVenueLabel(tournament),
                            style: SportoTextStyles.text(
                              size: SportoTextStyles.size12,
                              color: t.green,
                            ),
                          ),
                        ),
                      ],
                    ),
                    if (sponsor != null) ...[
                      const SizedBox(height: 8),
                      Text.rich(
                        TextSpan(
                          children: [
                            TextSpan(
                              text: 'Sponsor by: ',
                              style: SportoTextStyles.text(
                                size: SportoTextStyles.size12,
                                color: t.muted,
                              ),
                            ),
                            TextSpan(
                              text: sponsor.name,
                              style: SportoTextStyles.text(
                                size: SportoTextStyles.size12,
                                color: t.blue,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 12),
              TournamentInfoRow(
                label: '${tournament.maximumTeams ?? 0} Max Teams',
                value: '${formatCurrency(tournament.registrationFee)} Reg. Fee',
                valueColor: t.gold,
                boldValue: true,
              ),
              const SizedBox(height: 4),
              TournamentInfoRow(
                label: 'Tournament Start',
                value: formatTournamentDay(tournament.tournamentStartAt),
              ),
              TournamentInfoRow(
                label: 'Registration Deadline',
                value: formatTournamentDate(tournament.registrationEndAt),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: TournamentStatTile(
                value: '$registered/$maxTeams',
                label: 'Teams',
              ),
            ),
            const SizedBox(width: 6),
            Expanded(
              child: TournamentStatTile(
                value: '${(maxTeams - registered).clamp(0, maxTeams)}',
                label: 'Slots left',
                valueColor: t.gold,
              ),
            ),
            const SizedBox(width: 6),
            Expanded(
              child: TournamentStatTile(
                value: '${matches.length}',
                label: 'Matches',
              ),
            ),
            const SizedBox(width: 6),
            Expanded(
              child: TournamentStatTile(
                value: '$upcoming',
                label: 'Upcoming',
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Row(
          children: [
            Expanded(
              child: TournamentStatTile(
                value: '$live',
                label: 'Live',
                valueColor: t.live,
              ),
            ),
            const SizedBox(width: 6),
            Expanded(
              child: TournamentStatTile(
                value: '$completed',
                label: 'Done',
                valueColor: t.green,
              ),
            ),
            const SizedBox(width: 6),
            Expanded(
              child: TournamentStatTile(
                value: '$completed',
                label: 'Refs assigned',
                valueColor: t.green,
              ),
            ),
            const SizedBox(width: 6),
            Expanded(
              child: TournamentStatTile(
                value: '$incompleteReferees',
                label: 'Need referee',
                valueColor: t.live,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        TournamentSurface(
          radius: t.r9,
          padding: const EdgeInsets.symmetric(vertical: 11),
          onTap: onEdit,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'View more details',
                style: SportoTextStyles.text(
                  size: SportoTextStyles.size13,
                  color: t.blue,
                ),
              ),
              const SizedBox(width: 4),
              Icon(Icons.arrow_forward_rounded, size: 15, color: t.blue),
            ],
          ),
        ),
        const SizedBox(height: 16),
        _PrizePoolStrip(
          amount: formatCurrency(prize),
          onViewAll: onOpenPrize,
          onEdit: onOpenPrize,
        ),
        const SizedBox(height: 12),
        TournamentSectionCard(
          title: 'Sponsor',
          trailing: GestureDetector(
            onTap: onOpenPrize,
            child: Row(
              children: [
                Text(
                  'Edit',
                  style: SportoTextStyles.text(
                    size: SportoTextStyles.size12,
                    color: t.blue,
                  ),
                ),
                const SizedBox(width: 2),
                Icon(Icons.arrow_forward_rounded, size: 14, color: t.blue),
              ],
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: _SponsorTile(
                  label: 'Sponsor Contribution',
                  amount: formatCurrency(
                    sponsor?.contributionAmount,
                    fallback: '₹0',
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _SponsorTile(
                  label: 'Co-Sponsor',
                  amount: formatCurrency(
                    coSponsor?.contributionAmount,
                    fallback: '₹0',
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        TournamentSectionCard(
          title: 'Match Configuration',
          trailing: GestureDetector(
            onTap: onEdit,
            child: Row(
              children: [
                Text(
                  'Edit',
                  style: SportoTextStyles.text(
                    size: SportoTextStyles.size12,
                    color: t.blue,
                  ),
                ),
                const SizedBox(width: 2),
                Icon(Icons.arrow_forward_rounded, size: 14, color: t.blue),
              ],
            ),
          ),
          child: Column(
            children: [
              TournamentInfoRow(label: 'Match Duration', value: '90 mins'),
              TournamentInfoRow(label: 'Start Time', value: '07:00 PM'),
              TournamentInfoRow(
                label: 'Break Between Matches',
                value: '02:00 mins',
              ),
              TournamentInfoRow(
                label: 'Lunch Break',
                value: '08:00 PM - 08:45 PM',
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        TournamentSurface(
          radius: t.r11,
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: TournamentSectionLabel(
                      'Venue & Schedule',
                      color: t.gold,
                    ),
                  ),
                  TournamentActionPill(
                    label: 'View All',
                    background: t.cardAlt,
                    foreground: t.blue,
                    border: t.border,
                    onTap: onOpenVenue,
                    height: 30,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: onOpenVenue,
                    child: Row(
                      children: [
                        Text(
                          'Edit',
                          style: SportoTextStyles.text(
                            size: SportoTextStyles.size12,
                            color: t.blue,
                          ),
                        ),
                        const SizedBox(width: 2),
                        Icon(Icons.arrow_forward_rounded,
                            size: 14, color: t.blue),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Number of Teams',
                      style: SportoTextStyles.text(
                        size: SportoTextStyles.size13,
                        color: t.muted,
                      ),
                    ),
                  ),
                  Text(
                    '${tournament.maximumTeams ?? 0} Teams',
                    style: SportoTextStyles.text(
                      size: SportoTextStyles.size13,
                      color: t.warm,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              const TournamentBracketStrip(
                isExpanded: true,
              ),
              if (tournament.tournamentVenues.isNotEmpty) ...[
                const SizedBox(height: 12),
                TournamentVenueCard(
                  index: 1,
                  roundText: tournament.tournamentVenues.first.roundName ??
                      'Round of 64',
                  matchesText: '32 Matches',
                  name: tournament.tournamentVenues.first.venueName,
                  location: tournament.tournamentVenues.first.location ?? '--',
                  groundType:
                      tournament.tournamentVenues.first.groundType ?? 'Turf',
                  matchDate: formatTournamentDay(
                    tournament.tournamentVenues.first.date,
                  ),
                  startTime:
                      tournament.tournamentVenues.first.startTime ?? '08:00 PM',
                  onEdit: onOpenVenue,
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 12),
        TournamentSectionCard(
          title: 'Financial Summary',
          child: Column(
            children: [
              TournamentInfoRow(
                label: 'Estimated Collection',
                value: formatCurrencyValue(
                  review?.financialSummary.estimatedCollection ?? 12800,
                ),
              ),
              TournamentInfoRow(
                label: 'Prize Money',
                value: '-${formatCurrency(prize)}',
                valueColor: t.gold,
              ),
              TournamentInfoRow(
                label: 'Platform Fee',
                value: formatCurrencyValue(
                  review?.financialSummary.platformFeeAmount ?? 1280,
                ),
              ),
              const SizedBox(height: 6),
              TournamentDivider(color: t.border),
              const SizedBox(height: 6),
              TournamentInfoRow(
                label: 'Net Earnings',
                value: formatCurrencyValue(
                  review?.financialSummary.netEarnings ?? 11520,
                ),
                valueColor: t.gold,
                boldValue: true,
              ),
            ],
          ),
        ),
      ],
    );
  }

  int get incompleteReferees => matches.isEmpty ? 0 : 2;
}

class _PrizePoolStrip extends StatelessWidget {
  const _PrizePoolStrip({
    required this.amount,
    this.onViewAll,
    this.onEdit,
  });

  final String amount;
  final VoidCallback? onViewAll;
  final VoidCallback? onEdit;

  @override
  Widget build(BuildContext context) {
    final t = context.sportoTournament;
    return TournamentSurface(
      radius: t.r11,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      borderColor: t.gold.withValues(alpha: .42),
      child: Row(
        children: [
          Icon(Icons.emoji_events_rounded, size: 20, color: t.gold),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              gradient: t.goldPillGradient,
              borderRadius: BorderRadius.circular(100),
            ),
            child: Text(
              amount,
              style: SportoTextStyles.text(
                size: SportoTextStyles.size13,
                weight: FontWeight.w700,
                color: t.screenBase,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            'Prize Pool',
            style: SportoTextStyles.text(
              size: SportoTextStyles.size14,
              color: t.warm,
            ),
          ),
          const Spacer(),
          TournamentActionPill(
            label: 'View All',
            background: t.cardAlt,
            foreground: t.blue,
            border: t.border,
            onTap: onViewAll,
            height: 30,
            padding: const EdgeInsets.symmetric(horizontal: 12),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: onEdit,
            child: Row(
              children: [
                Text(
                  'Edit',
                  style: SportoTextStyles.text(
                    size: SportoTextStyles.size12,
                    color: t.blue,
                  ),
                ),
                const SizedBox(width: 2),
                Icon(Icons.arrow_forward_rounded, size: 14, color: t.blue),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SponsorTile extends StatelessWidget {
  const _SponsorTile({required this.label, required this.amount});

  final String label;
  final String amount;

  @override
  Widget build(BuildContext context) {
    final t = context.sportoTournament;
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            t.panel.withValues(alpha: .55),
            t.cardAlt,
          ],
        ),
        borderRadius: BorderRadius.circular(t.r9),
        border: Border.all(color: t.border),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: SportoTextStyles.text(
              size: SportoTextStyles.size11,
              color: t.muted,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            amount,
            style: SportoTextStyles.text(
              size: SportoTextStyles.size15,
              weight: FontWeight.w600,
              color: t.gold,
            ),
          ),
        ],
      ),
    );
  }
}
