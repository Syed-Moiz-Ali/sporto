import 'package:flutter/material.dart';
import 'package:partner_data/partner_data.dart';
import 'package:ui_kit/ui_kit.dart';

import '../widgets/redesign/tournament_redesign_data.dart';
import '../widgets/redesign/tournament_screen_parts.dart';
import '../widgets/redesign/tournament_visuals.dart';

/// Info tab of the tournament detail screen — Figma `Partner App / Under Review`
/// (export 06) and `Changes Requested` (08/12).
class TournamentInfoTab extends StatelessWidget {
  const TournamentInfoTab({
    super.key,
    required this.tournament,
    required this.matches,
    this.review,
    this.rounds = const [],
    this.onOpenVenue,
    this.onOpenPrize,
    this.onEdit,
  });

  final PartnerTournamentResponse tournament;
  final List<PartnerTournamentMatchResponse> matches;
  final PartnerTournamentReviewData? review;
  final List<TournamentRound> rounds;
  final VoidCallback? onOpenVenue;
  final VoidCallback? onOpenPrize;
  final VoidCallback? onEdit;

  @override
  Widget build(BuildContext context) {
    final scale = context.sportoScale;
    final prize = review?.financialSummary.totalPrizeMoney ??
        tournament.totalPrizeMoney ??
        '';
    final sponsors = tournament.tournamentSponsors;
    final venues = tournament.tournamentVenues;
    final requestedChanges = _changesRequested(tournament);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (requestedChanges != null) ...[
          _ChangesBanner(message: requestedChanges, onEdit: onEdit),
          SizedBox(height: 12 * scale),
        ],
        _CommunityCard(tournament: tournament),
        SizedBox(height: 10 * scale),
        _DetailsPanel(
          tournament: tournament,
          onEdit: onEdit,
          onOpenPrize: onOpenPrize,
        ),
        if (prize.isNotEmpty) ...[
          SizedBox(height: 10 * scale),
          _PrizeBanner(amount: prize, onOpen: onOpenPrize),
        ],
        if (sponsors.isNotEmpty) ...[
          SizedBox(height: 10 * scale),
          _SponsorCard(sponsors: sponsors, onEdit: onEdit),
        ],
        if (venues.isNotEmpty) ...[
          SizedBox(height: 10 * scale),
          _VenueScheduleCard(
            tournament: tournament,
            venues: venues,
            rounds: rounds,
            onOpen: onOpenVenue,
            onEdit: onEdit,
          ),
        ],
        if (review != null) ...[
          SizedBox(height: 10 * scale),
          _FinancialSummaryCard(review: review!),
        ],
      ],
    );
  }

  /// The API has no admin-remark field; the only signal is the tournament
  /// description carrying a change request (same rule the app used before).
  static String? _changesRequested(PartnerTournamentResponse tournament) {
    if (tournament.approvalStatus != 2) return null;
    final text = '${tournament.description ?? ''}'.trim();
    if (text.isEmpty) return null;
    final lower = text.toLowerCase();
    if (!lower.contains('change') && !lower.contains('revision')) return null;
    return text;
  }
}

/// `Community Tournament` + format pill (export: 350×66, r16).
class _CommunityCard extends StatelessWidget {
  const _CommunityCard({required this.tournament});

  final PartnerTournamentResponse tournament;

  @override
  Widget build(BuildContext context) {
    final t = context.sportoTournament;
    final scale = context.sportoScale;
    final type = tournament.tournamentType?.name;
    final format = tournament.sportFormat?.name;
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(12 * scale),
      decoration: BoxDecoration(
        color: t.cardAlt.withValues(alpha: .60),
        borderRadius: BorderRadius.circular(t.r16),
        border: GradientBorder.all(
          gradient: t.blueEdgeGradient,
          width: 1,
          radius: t.r16,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (type != null)
            Text(
              type,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: SportoTextStyles.text(
                size: SportoTextStyles.size14,
                weight: FontWeight.w500,
                color: t.gold,
              ),
            ),
          if (format != null) ...[
            SizedBox(height: 6 * scale),
            Text(
              format,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: SportoTextStyles.text(
                size: SportoTextStyles.size14,
                weight: FontWeight.w500,
                color: t.white,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// `Tournament Details` panel (export: 350 wide, r14, white hairline).
class _DetailsPanel extends StatelessWidget {
  const _DetailsPanel({
    required this.tournament,
    this.onEdit,
    this.onOpenPrize,
  });

  final PartnerTournamentResponse tournament;
  final VoidCallback? onEdit;
  final VoidCallback? onOpenPrize;

  @override
  Widget build(BuildContext context) {
    final t = context.sportoTournament;
    final scale = context.sportoScale;
    final fee = tournament.registrationFee?.trim();
    final feeLabel =
        (fee == null || fee.isEmpty) ? null : '${formatCurrency(fee)} Reg. Fee';
    final maxTeams = tournament.maximumTeams;
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: t.cardAlt,
        borderRadius: BorderRadius.circular(t.r14),
        border: GradientBorder.all(
          gradient: t.whiteBorderGradient,
          width: 1,
          radius: t.r14,
        ),
        boxShadow: t.softCardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(
                12 * scale, 12 * scale, 12 * scale, 8 * scale),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'Tournament Details',
                    style: SportoTextStyles.text(
                      size: SportoTextStyles.size12,
                      weight: FontWeight.w500,
                      color: t.dim,
                    ),
                  ),
                ),
                if (onEdit != null) _EditLink(onTap: onEdit!),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 12 * scale),
            child: TournamentDivider(
              height: .8,
              color: t.border.withValues(alpha: .5),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(12 * scale),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TournamentIdentityCard(
                  tournament: tournament,
                  showSponsor: true,
                  onTap: onOpenPrize,
                ),
                SizedBox(height: 10 * scale),
                Row(
                  children: [
                    if (maxTeams != null)
                      Expanded(
                        child: Text(
                          '$maxTeams Max Teams',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: SportoTextStyles.text(
                            size: SportoTextStyles.size14,
                            weight: FontWeight.w500,
                            color: t.warm,
                          ),
                        ),
                      ),
                    if (feeLabel != null)
                      Flexible(
                        child: Text(
                          feeLabel,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: SportoTextStyles.text(
                            size: SportoTextStyles.size14,
                            weight: FontWeight.w500,
                            color: t.gold,
                          ),
                        ),
                      ),
                  ],
                ),
                SizedBox(height: 10 * scale),
                TournamentDivider(
                  height: .8,
                  color: t.border.withValues(alpha: .5),
                ),
                SizedBox(height: 10 * scale),
                _InfoRow(
                  label: 'Tournament Start',
                  value: formatTournamentDay(tournament.tournamentStartAt),
                ),
                SizedBox(height: 4 * scale),
                _InfoRow(
                  label: 'Registration Deadline',
                  value: formatTournamentDate(tournament.registrationEndAt),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// `🏆 ₹150,000 Prize Pool — View All` banner (export: 350×52, r16).
class _PrizeBanner extends StatelessWidget {
  const _PrizeBanner({required this.amount, this.onOpen});

  final String amount;
  final VoidCallback? onOpen;

  @override
  Widget build(BuildContext context) {
    final t = context.sportoTournament;
    final scale = context.sportoScale;
    return GestureDetector(
      onTap: onOpen,
      behavior: HitTestBehavior.opaque,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(12 * scale),
        decoration: BoxDecoration(
          gradient: washGradient(t.amberPillGradient, .08),
          borderRadius: BorderRadius.circular(t.r16),
          border: GradientBorder.all(
            gradient: washGradient(t.amberPillGradient, .55),
            width: 1,
            radius: t.r16,
          ),
        ),
        child: Row(
          children: [
            const Text('🏆', style: TextStyle(fontSize: 14)),
            SizedBox(width: 8 * scale),
            Flexible(
              child: Container(
                constraints: BoxConstraints(minHeight: 28 * scale),
                padding: EdgeInsets.symmetric(horizontal: 10 * scale),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  gradient: t.amberPillGradient,
                  borderRadius: BorderRadius.circular(t.r18),
                  boxShadow: t.goldGlow,
                ),
                child: Text(
                  formatCurrency(amount),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: SportoTextStyles.text(
                    size: SportoTextStyles.size16,
                    weight: FontWeight.w700,
                    color: t.screenBase,
                  ),
                ),
              ),
            ),
            SizedBox(width: 8 * scale),
            Expanded(
              child: Text(
                'Prize Pool',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: SportoTextStyles.text(
                  size: SportoTextStyles.size14,
                  weight: FontWeight.w600,
                  color: t.white,
                ),
              ),
            ),
            SizedBox(width: 6 * scale),
            Container(
              height: 25 * scale,
              padding: EdgeInsets.symmetric(horizontal: 10 * scale),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: t.cardElevated,
                borderRadius: BorderRadius.circular(t.r10),
              ),
              child: Text(
                'View All',
                style: SportoTextStyles.text(
                  size: SportoTextStyles.size12,
                  weight: FontWeight.w500,
                  color: t.blue,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// `Sponsor` card with contribution tiles (export: 350×98, r16).
class _SponsorCard extends StatelessWidget {
  const _SponsorCard({required this.sponsors, this.onEdit});

  final List<PartnerTournamentSponsorResponse> sponsors;
  final VoidCallback? onEdit;

  @override
  Widget build(BuildContext context) {
    final t = context.sportoTournament;
    final scale = context.sportoScale;
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(12 * scale),
      decoration: BoxDecoration(
        gradient: washGradient(t.bluePillGradient, .07),
        borderRadius: BorderRadius.circular(t.r16),
        border: GradientBorder.all(
          gradient: t.whiteBorderGradient,
          width: 1,
          radius: t.r16,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Sponsor',
                  style: SportoTextStyles.text(
                    size: SportoTextStyles.size12,
                    weight: FontWeight.w500,
                    color: t.blue,
                  ),
                ),
              ),
              if (onEdit != null) _EditLink(onTap: onEdit!),
            ],
          ),
          SizedBox(height: 10 * scale),
          LayoutBuilder(
            builder: (context, constraints) {
              final tile = sponsors.length == 1
                  ? constraints.maxWidth
                  : (constraints.maxWidth - 10 * scale) / 2;
              return Wrap(
                spacing: 10 * scale,
                runSpacing: 10 * scale,
                children: [
                  for (final sponsor in sponsors)
                    SizedBox(
                      width: tile,
                      child: _SponsorTile(sponsor: sponsor),
                    ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

class _SponsorTile extends StatelessWidget {
  const _SponsorTile({required this.sponsor});

  final PartnerTournamentSponsorResponse sponsor;

  @override
  Widget build(BuildContext context) {
    final t = context.sportoTournament;
    final scale = context.sportoScale;
    return Container(
      constraints: BoxConstraints(minHeight: 49 * scale),
      padding:
          EdgeInsets.symmetric(horizontal: 14 * scale, vertical: 8 * scale),
      decoration: BoxDecoration(
        color: t.screenBase,
        borderRadius: BorderRadius.circular(t.r14),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            sponsor.name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: SportoTextStyles.text(
              size: SportoTextStyles.size10,
              weight: FontWeight.w500,
              color: t.muted,
            ),
          ),
          SizedBox(height: 2 * scale),
          ShaderMask(
            blendMode: BlendMode.srcIn,
            shaderCallback: (rect) => t.goldPillGradient.createShader(rect),
            child: Text(
              formatCurrency(sponsor.contributionAmount),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: SportoTextStyles.text(
                size: SportoTextStyles.size14,
                weight: FontWeight.w600,
                color: t.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// `Venue & Schedule` card with the venue carousel (export: 350 wide, r16).
class _VenueScheduleCard extends StatelessWidget {
  const _VenueScheduleCard({
    required this.tournament,
    required this.venues,
    this.rounds = const [],
    this.onOpen,
    this.onEdit,
  });

  final PartnerTournamentResponse tournament;
  final List<PartnerTournamentVenueResponse> venues;
  final List<TournamentRound> rounds;
  final VoidCallback? onOpen;
  final VoidCallback? onEdit;

  String _matchesFor(String? roundName) {
    if (roundName == null || roundName.trim().isEmpty) return '';
    final round = rounds.where((r) => r.name == roundName).firstOrNull;
    if (round == null) return '';
    final count =
        round.matchCount > 0 ? round.matchCount : round.expectedMatchCount;
    if (count <= 0) return '';
    return count == 1 ? '1 Match' : '$count Matches';
  }

  @override
  Widget build(BuildContext context) {
    final t = context.sportoTournament;
    final scale = context.sportoScale;
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(vertical: 12 * scale),
      decoration: BoxDecoration(
        color: t.cardAlt,
        borderRadius: BorderRadius.circular(t.r16),
        border: GradientBorder.all(
          gradient: t.bluePillBorderGradient,
          width: 1,
          radius: t.r16,
        ),
        boxShadow: t.softCardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 12 * scale),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'Venue & Schedule',
                    style: SportoTextStyles.text(
                      size: SportoTextStyles.size14,
                      weight: FontWeight.w500,
                      color: t.gold,
                    ),
                  ),
                ),
                if (onOpen != null)
                  GestureDetector(
                    onTap: onOpen,
                    behavior: HitTestBehavior.opaque,
                    child: Container(
                      height: 25 * scale,
                      padding: EdgeInsets.symmetric(horizontal: 10 * scale),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: t.cardElevated,
                        borderRadius: BorderRadius.circular(t.r10),
                      ),
                      child: Text(
                        'View All',
                        style: SportoTextStyles.text(
                          size: SportoTextStyles.size12,
                          weight: FontWeight.w500,
                          color: t.blue,
                        ),
                      ),
                    ),
                  ),
                if (onEdit != null) ...[
                  SizedBox(width: 8 * scale),
                  _EditLink(onTap: onEdit!),
                ],
              ],
            ),
          ),
          SizedBox(height: 8 * scale),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 12 * scale),
            child: TournamentDivider(
              height: .8,
              color: t.border.withValues(alpha: .5),
            ),
          ),
          SizedBox(height: 8 * scale),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 12 * scale),
            child: _InfoRow(
              label: 'Number of Teams',
              value: '${tournament.maximumTeams ?? 0} Teams',
            ),
          ),
          if (rounds.isNotEmpty) ...[
            SizedBox(height: 10 * scale),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 12 * scale),
              child: TournamentBracketStrip(rounds: rounds),
            ),
          ],
          SizedBox(height: 10 * scale),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.symmetric(horizontal: 12 * scale),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (var i = 0; i < venues.length; i++) ...[
                  if (i > 0) SizedBox(width: 10 * scale),
                  SizedBox(
                    width: 290 * scale,
                    child: _VenueCard(
                      venue: venues[i],
                      index: i,
                      matchesLabel: _matchesFor(venues[i].roundName),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _VenueCard extends StatelessWidget {
  const _VenueCard({
    required this.venue,
    required this.index,
    this.matchesLabel = '',
  });

  final PartnerTournamentVenueResponse venue;
  final int index;
  final String matchesLabel;

  @override
  Widget build(BuildContext context) {
    final t = context.sportoTournament;
    final scale = context.sportoScale;
    final round = venue.roundName;
    return Container(
      padding: EdgeInsets.all(10 * scale),
      decoration: BoxDecoration(
        color: t.border.withValues(alpha: .30),
        borderRadius: BorderRadius.circular(t.r12),
        boxShadow: t.softCardShadow,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Venue ${index + 1}',
            style: SportoTextStyles.text(
              size: SportoTextStyles.size14,
              color: t.blue,
            ),
          ),
          if (round != null && round.trim().isNotEmpty) ...[
            SizedBox(height: 2 * scale),
            Text(
              matchesLabel.isEmpty ? round : '$round  ·  $matchesLabel',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: SportoTextStyles.text(
                size: SportoTextStyles.size12,
                weight: FontWeight.w500,
                color: t.muted,
              ),
            ),
          ],
          SizedBox(height: 8 * scale),
          Text(
            venue.venueName,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: SportoTextStyles.text(
              size: SportoTextStyles.size14,
              weight: FontWeight.w500,
              color: t.white,
            ),
          ),
          if (venue.location != null) ...[
            SizedBox(height: 2 * scale),
            Row(
              children: [
                SportoSvgIcon(
                  SportoTournamentIcons.mapPin,
                  width: 10,
                  height: 11,
                  color: t.green,
                ),
                SizedBox(width: 4 * scale),
                Expanded(
                  child: Text(
                    venue.location!,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: SportoTextStyles.text(
                      size: SportoTextStyles.size12,
                      weight: FontWeight.w500,
                      color: t.green,
                    ),
                  ),
                ),
              ],
            ),
          ],
          const SizedBox(height: 8),
          if (venue.groundType != null)
            _InfoRow(
              label: 'Ground Type',
              value: venue.groundType!,
              dense: true,
            ),
          if (venue.date != null) ...[
            const SizedBox(height: 4),
            _InfoRow(
              label: 'Match Date',
              value: formatTournamentDay(venue.date),
              dense: true,
            ),
          ],
          if (venue.startTime != null) ...[
            const SizedBox(height: 4),
            _InfoRow(
              label: 'Start Time',
              value: venue.startTime!,
              dense: true,
            ),
          ],
        ],
      ),
    );
  }
}

/// Kept until the Financials tab renders the summary (export screen 47).
class _FinancialSummaryCard extends StatelessWidget {
  const _FinancialSummaryCard({required this.review});

  final PartnerTournamentReviewData review;

  @override
  Widget build(BuildContext context) {
    final t = context.sportoTournament;
    final scale = context.sportoScale;
    final summary = review.financialSummary;
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
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Financial Summary',
            style: SportoTextStyles.text(
              size: SportoTextStyles.size12,
              weight: FontWeight.w500,
              color: t.dim,
            ),
          ),
          SizedBox(height: 10 * scale),
          _InfoRow(
            label: 'Estimated Collection',
            value: formatCurrencyValue(summary.estimatedCollection),
          ),
          SizedBox(height: 4 * scale),
          _InfoRow(
            label: 'Prize Money',
            value: '-${formatCurrency(summary.totalPrizeMoney)}',
          ),
          SizedBox(height: 4 * scale),
          _InfoRow(
            label: 'Platform Fee',
            value: formatCurrencyValue(summary.platformFeeAmount),
          ),
          SizedBox(height: 4 * scale),
          _InfoRow(
            label: 'Net Earnings',
            value: formatCurrencyValue(summary.netEarnings),
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.label,
    required this.value,
    this.dense = false,
  });

  final String label;
  final String value;
  final bool dense;

  @override
  Widget build(BuildContext context) {
    final t = context.sportoTournament;
    final size = dense ? SportoTextStyles.size12 : SportoTextStyles.size14;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Flexible(
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: SportoTextStyles.text(size: size, color: t.muted),
          ),
        ),
        const SizedBox(width: 8),
        Flexible(
          child: Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.right,
            style: SportoTextStyles.text(size: size, color: t.white),
          ),
        ),
      ],
    );
  }
}

class _EditLink extends StatelessWidget {
  const _EditLink({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final t = context.sportoTournament;
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Edit',
            style: SportoTextStyles.text(
              size: SportoTextStyles.size11,
              color: t.blue,
            ),
          ),
          const SizedBox(width: 2),
          SportoSvgIcon(
            SportoHomeRedesignIcons.arrowRight,
            width: 11,
            height: 7,
            color: t.blue,
          ),
        ],
      ),
    );
  }
}

/// Change-request notice (export 08/12): title + admin message + Edit.
class _ChangesBanner extends StatelessWidget {
  const _ChangesBanner({required this.message, this.onEdit});

  final String message;
  final VoidCallback? onEdit;

  @override
  Widget build(BuildContext context) {
    final t = context.sportoTournament;
    final scale = context.sportoScale;
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(12 * scale),
      decoration: BoxDecoration(
        gradient: washGradient(t.orangePillGradient, .08),
        borderRadius: BorderRadius.circular(t.r14),
        border: GradientBorder.all(
          gradient: t.orangePillGradient,
          width: 1,
          radius: t.r14,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Admin Requested Changes',
                  style: SportoTextStyles.text(
                    size: SportoTextStyles.size11,
                    weight: FontWeight.w500,
                    color: t.upcoming.withValues(alpha: .98),
                  ),
                ),
                SizedBox(height: 2 * scale),
                Text(
                  message,
                  style: SportoTextStyles.text(
                    size: SportoTextStyles.size10,
                    color: t.white.withValues(alpha: .98),
                  ),
                ),
              ],
            ),
          ),
          if (onEdit != null) ...[
            SizedBox(width: 4 * scale),
            _EditLink(onTap: onEdit!),
          ],
        ],
      ),
    );
  }
}
