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

/// Prize Pool — Figma `Partner App / Prize Pool` (export screen 07).
class PrizePoolRedesignScreen extends StatefulWidget {
  const PrizePoolRedesignScreen({
    super.key,
    required this.tournamentId,
    this.tournamentOverride,
    this.isLoading,
  });

  final String tournamentId;

  /// Test injection: skips the API call.
  final PartnerTournamentResponse? tournamentOverride;
  final bool? isLoading;

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
    if (widget.tournamentOverride != null) {
      _tournament = widget.tournamentOverride;
      _loading = false;
      return;
    }
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
    final scale = context.sportoScale;
    final tournament = _tournament;
    final loading = widget.isLoading ?? (_loading && tournament == null);

    return Scaffold(
      backgroundColor: t.screenBase,
      body: Column(
        children: [
          TournamentScreenHeader(
            title: 'Prize Pool',
            subtitle: tournament == null
                ? 'SPT-${widget.tournamentId}'
                : '${tournamentCode(tournament)} · ${tournament.name}',
            onBack: () => context.pop(),
            padding: EdgeInsets.fromLTRB(
              20 * scale,
              MediaQuery.of(context).padding.top,
              20 * scale,
              6 * scale,
            ),
            rowHeight: 44 * scale,
            titleSize: SportoTextStyles.size16,
            subtitleSize: SportoTextStyles.size11,
            backSize: 36 * scale,
            backGap: 10 * scale,
            backBackground: t.white.withValues(alpha: .10),
          ),
          if (loading)
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
                padding: EdgeInsets.fromLTRB(
                  20 * scale,
                  10 * scale,
                  20 * scale,
                  28 * scale,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TournamentStatusStrip(tournament: tournament),
                    SizedBox(height: 16 * scale),
                    TournamentIdentityCard(tournament: tournament),
                    SizedBox(height: 10 * scale),
                    _PrizeCard(
                      tournament: tournament,
                      onEdit: () => _editHint(context),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  void _editHint(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Prize editing will open here.')),
    );
  }
}

/// Total + special prizes + ranked breakdown (export: 350×318, r16).
class _PrizeCard extends StatelessWidget {
  const _PrizeCard({required this.tournament, required this.onEdit});

  final PartnerTournamentResponse tournament;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    final t = context.sportoTournament;
    final scale = context.sportoScale;
    final prizes = [
      ...tournament.tournamentPrizes
    ]..sort((a, b) => (a.displayOrder ?? 999).compareTo(b.displayOrder ?? 999));
    final placements =
        prizes.where((p) => _isPlacement(p.title)).toList(growable: false);
    final specials =
        prizes.where((p) => !_isPlacement(p.title)).toList(growable: false);
    final total = tournament.totalPrizeMoney?.trim();

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
          ConstrainedBox(
            constraints: BoxConstraints(minHeight: 28 * scale),
            child: Row(
              children: [
                const Text('🏆', style: TextStyle(fontSize: 14)),
                SizedBox(width: 5 * scale),
                Expanded(
                  child: Row(
                    children: [
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
                            formatCurrency(
                                total == null || total.isEmpty ? '0' : total),
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
                      SizedBox(width: 12 * scale),
                      Flexible(
                        child: Text(
                          'Prize Pool',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: SportoTextStyles.text(
                            size: SportoTextStyles.size12,
                            weight: FontWeight.w500,
                            color: t.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: onEdit,
                  behavior: HitTestBehavior.opaque,
                  child: Row(
                    children: [
                      Text(
                        'Edit',
                        style: SportoTextStyles.text(
                          size: SportoTextStyles.size11,
                          color: t.blue,
                        ),
                      ),
                      SizedBox(width: 2 * scale),
                      SportoSvgIcon(
                        SportoHomeRedesignIcons.arrowRight,
                        width: 11,
                        height: 7,
                        color: t.blue,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          if (specials.isNotEmpty) ...[
            SizedBox(height: 10 * scale),
            LayoutBuilder(
              builder: (context, constraints) {
                final tile = (constraints.maxWidth - 10 * scale) / 2;
                return Wrap(
                  spacing: 10 * scale,
                  runSpacing: 10 * scale,
                  children: [
                    for (final prize in specials)
                      SizedBox(
                        width: tile,
                        child: _SpecialPrizeTile(
                          label: prize.title,
                          amount: formatCurrency(prize.amount),
                        ),
                      ),
                  ],
                );
              },
            ),
          ],
          if (placements.isEmpty)
            Padding(
              padding: EdgeInsets.only(top: 12 * scale),
              child: Text(
                'No ranked prizes have been added yet.',
                style: SportoTextStyles.text(
                  size: SportoTextStyles.size12,
                  color: t.muted,
                ),
              ),
            )
          else ...[
            SizedBox(height: 10 * scale),
            Container(
              decoration: BoxDecoration(
                color: t.cardElevated,
                borderRadius: BorderRadius.circular(t.r14),
              ),
              padding: EdgeInsets.symmetric(vertical: 3 * scale),
              child: Column(
                children: [
                  for (var i = 0; i < placements.length; i++) ...[
                    if (i > 0)
                      TournamentDivider(
                        height: 1,
                        color: t.screenBase,
                      ),
                    TournamentPrizeRow(
                      rank: '${i + 1}',
                      label: placements[i].title,
                      amount: formatCurrency(placements[i].amount),
                      mutedRank: i > 2,
                    ),
                  ],
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  static bool _isPlacement(String title) {
    final lower = title.toLowerCase();
    return lower.contains('winner') ||
        lower.contains('runner') ||
        lower.contains('place') ||
        lower.contains('finalist');
  }
}

/// `Best Batsman — ₹5,000` tile (export: 158×49, r14).
class _SpecialPrizeTile extends StatelessWidget {
  const _SpecialPrizeTile({required this.label, required this.amount});

  final String label;
  final String amount;

  @override
  Widget build(BuildContext context) {
    final t = context.sportoTournament;
    final scale = context.sportoScale;
    return Container(
      constraints: BoxConstraints(minHeight: 49 * scale),
      padding:
          EdgeInsets.symmetric(horizontal: 14 * scale, vertical: 8 * scale),
      decoration: BoxDecoration(
        color: t.cardElevated,
        borderRadius: BorderRadius.circular(t.r14),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            label,
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
              amount,
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
