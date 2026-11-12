import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:partner_data/partner_data.dart';
import 'package:ui_kit/ui_kit.dart';

import '../widgets/redesign/tournament_cards.dart';
import '../widgets/redesign/tournament_redesign_data.dart';
import '../widgets/redesign/tournament_screen_parts.dart';
import '../widgets/redesign/tournament_shimmer.dart';
import '../widgets/redesign/tournament_visuals.dart';

class PrizePoolRedesignScreen extends StatefulWidget {
  const PrizePoolRedesignScreen({super.key, required this.tournamentId});

  final String tournamentId;

  @override
  State<PrizePoolRedesignScreen> createState() =>
      _PrizePoolRedesignScreenState();
}

class _PrizePoolRedesignScreenState extends State<PrizePoolRedesignScreen> {
  late final PartnerRemoteDataSource _api = PartnerRemoteDataSource(
    apiClient: SportoApiClient(tokenProvider: AuthSessionStore().getToken),
  );

  PartnerTournamentResponse? _tournament;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final tournament = await _api.showTournamentData(widget.tournamentId);
      if (!mounted) return;
      setState(() {
        _tournament = tournament;
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = context.sportoTournament;
    final tournament = _tournament;
    final prizes = tournament?.tournamentPrizes ?? const [];
    final sponsors = tournament?.tournamentSponsors ?? const [];
    final total = tournament?.totalPrizeMoney ?? '0';

    return Scaffold(
      backgroundColor: t.screenBase,
      body: SafeArea(
        child: Column(
          children: [
            TournamentScreenHeader(
              title: 'Prize Pool',
              subtitle: tournament == null
                  ? 'SPT-${widget.tournamentId}'
                  : '${tournamentCode(tournament)} · ${tournament.name}',
              onBack: () => context.pop(),
            ),
            if (_loading)
              const Expanded(child: PrizePoolShimmer())
            else if (tournament == null)
              Expanded(
                child: Center(
                  child: Text(
                    'Prize pool could not be loaded.',
                    style: SportoTextStyles.text(
                      size: SportoTextStyles.size14,
                      color: t.muted,
                    ),
                  ),
                ),
              )
            else
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(20, 2, 20, 28),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TournamentStatusBar(
                        statusLabel: tournamentStatusLabel(tournament),
                        statusColor: tournamentStatusColor(tournament, t),
                        sport: tournamentSportLabel(tournament),
                        dateText: formatTournamentDate(
                          tournament.tournamentStartAt,
                        ),
                        live: tournament.status == 6,
                      ),
                      const SizedBox(height: 14),
                      TournamentSurface(
                        radius: t.r11,
                        padding: const EdgeInsets.all(14),
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
                          ],
                        ),
                      ),
                      const SizedBox(height: 14),
                      TournamentSurface(
                        radius: t.r11,
                        padding: const EdgeInsets.all(14),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Icon(Icons.emoji_events_rounded,
                                    size: 22, color: t.gold),
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    gradient: t.goldPillGradient,
                                    borderRadius: BorderRadius.circular(100),
                                  ),
                                  child: Text(
                                    formatCurrency(total),
                                    style: SportoTextStyles.text(
                                      size: SportoTextStyles.size15,
                                      weight: FontWeight.w700,
                                      color: t.screenBase,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Prize Pool',
                                  style: SportoTextStyles.text(
                                    size: SportoTextStyles.size15,
                                    color: t.warm,
                                  ),
                                ),
                                const Spacer(),
                                GestureDetector(
                                  onTap: () => _editHint(context),
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
                            const SizedBox(height: 14),
                            Row(
                              children: [
                                Expanded(
                                  child: _specialPrize(
                                    context,
                                    'Best Batsman',
                                    '₹5,000',
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: _specialPrize(
                                    context,
                                    'Best Bowler',
                                    '₹5,000',
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 14),
                            if (prizes.isEmpty)
                              for (var i = 0; i < 6; i++) ...[
                                _demoPrizeRow(context, i),
                                if (i != 5) const SizedBox(height: 8),
                              ]
                            else
                              for (var i = 0; i < prizes.length; i++) ...[
                                TournamentPrizeRow(
                                  rank: '${i + 1}',
                                  label: prizes[i].title,
                                  amount: formatCurrency(prizes[i].amount),
                                  mutedRank: i > 2,
                                ),
                                if (i != prizes.length - 1)
                                  const SizedBox(height: 8),
                              ],
                          ],
                        ),
                      ),
                      if (sponsors.isNotEmpty) ...[
                        const SizedBox(height: 14),
                        TournamentSectionCard(
                          title: 'Sponsors',
                          child: Column(
                            children: [
                              for (var i = 0; i < sponsors.length; i++) ...[
                                TournamentInfoRow(
                                  label: sponsors[i].name,
                                  value: formatCurrency(
                                    sponsors[i].contributionAmount,
                                  ),
                                  valueColor: t.gold,
                                ),
                                if (i != sponsors.length - 1)
                                  TournamentDivider(color: t.border),
                              ],
                            ],
                          ),
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

  Widget _specialPrize(BuildContext context, String label, String amount) {
    final t = context.sportoTournament;
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: t.cardAlt,
        borderRadius: BorderRadius.circular(t.r9),
        border: Border.all(color: t.border),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: SportoTextStyles.text(
              size: SportoTextStyles.size12,
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

  Widget _demoPrizeRow(BuildContext context, int index) {
    const labels = [
      'Winner',
      'Runner-up',
      '3rd Place',
      '4th Place',
      '6th Place',
      '7th Place',
    ];
    const amounts = [
      '₹50,000',
      '₹20,000',
      '₹10,000',
      '₹50,000',
      '₹2,500',
      '₹2,500',
    ];
    return TournamentPrizeRow(
      rank: '${index + 1}',
      label: labels[index],
      amount: amounts[index],
      mutedRank: index > 2,
    );
  }

  void _editHint(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Prize editing will open here.')),
    );
  }
}
