import 'package:flutter/material.dart';
import 'package:referee_app/core/config/referee_demo_data.dart';
import 'package:ui_kit/ui_kit.dart';

import '../wallet_figma_data.dart';
import '../wallet_icons.dart';
import '../wallet_models.dart';
import '../widgets/wallet_shared_widgets.dart';

/// Screen 01 - referee tournaments history (Figma `01_My-Tournaments`).
class TournamentsHistoryScreen extends StatefulWidget {
  const TournamentsHistoryScreen({super.key, this.tournaments});

  /// Test/preview override. Production uses the backend list when available.
  final List<TournamentHistoryItem>? tournaments;

  @override
  State<TournamentsHistoryScreen> createState() =>
      _TournamentsHistoryScreenState();
}

class _TournamentsHistoryScreenState extends State<TournamentsHistoryScreen> {
  TournamentHistoryStatus _status = TournamentHistoryStatus.completed;
  bool _newestFirst = true;

  List<TournamentHistoryItem> get _tournaments =>
      widget.tournaments ??
      (kRefereeDemoData ? WalletFigmaData.tournaments : const []);

  List<TournamentHistoryItem> get _visibleTournaments {
    final filtered = _tournaments
        .where((tournament) => tournament.status == _status)
        .toList(growable: false);
    if (!_newestFirst) {
      return filtered.reversed.toList(growable: false);
    }
    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    final scale = context.sportoScale;
    final tokens = context.sporto;
    final bottomInset = MediaQuery.paddingOf(context).bottom;
    final visible = _visibleTournaments;

    return Scaffold(
      backgroundColor: tokens.canvas,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            WalletScreenHeader(
              title: 'Tournaments History',
              trailing: WalletPill(
                label: 'Create',
                gradient: const LinearGradient(
                  colors: [Color(0xFF7AD3FF), Color(0xFF4FBAF0)],
                ),
                textColor: const Color(0xFF090C10),
                fontWeight: FontWeight.w700,
                leading: SportoSvgIcon(
                  WalletIcons.plus,
                  size: 10 * scale,
                  color: const Color(0xFF090C10),
                ),
                onTap: () => _comingSoon(
                  context,
                  'Tournament creation is not available yet.',
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(
                20 * scale,
                8 * scale,
                12 * scale,
                0,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      clipBehavior: Clip.none,
                      child: Row(
                        children: [
                          WalletFilterChip(
                            label: 'Completed',
                            selected:
                                _status == TournamentHistoryStatus.completed,
                            onTap: () => setState(
                              () => _status = TournamentHistoryStatus.completed,
                            ),
                          ),
                          SizedBox(width: 10 * scale),
                          WalletFilterChip(
                            label: 'Cancelled',
                            selected:
                                _status == TournamentHistoryStatus.cancelled,
                            onTap: () => setState(
                              () => _status = TournamentHistoryStatus.cancelled,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(width: 6 * scale),
                  WalletSortButton(
                    onTap: () => setState(() => _newestFirst = !_newestFirst),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: EdgeInsets.fromLTRB(
                  20 * scale,
                  10 * scale,
                  20 * scale,
                  24 * scale + bottomInset,
                ),
                children: [
                  if (visible.isEmpty)
                    WalletEmptyState(
                      message: _status == TournamentHistoryStatus.completed
                          ? 'No completed tournaments yet'
                          : 'No cancelled tournaments yet',
                    )
                  else
                    for (var i = 0; i < visible.length; i++) ...[
                      _TournamentCard(
                        tournament: visible[i],
                        scale: scale,
                        onAction: (label) => _comingSoon(
                          context,
                          '$label is not available yet.',
                        ),
                      ),
                      if (i != visible.length - 1) SizedBox(height: 20 * scale),
                    ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _comingSoon(BuildContext context, String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: context.sporto.cardElevated,
          behavior: SnackBarBehavior.floating,
        ),
      );
  }
}

class _TournamentCard extends StatelessWidget {
  final TournamentHistoryItem tournament;
  final double scale;
  final ValueChanged<String> onAction;

  const _TournamentCard({
    required this.tournament,
    required this.scale,
    required this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    final tokens = context.sporto;
    return Container(
      padding: EdgeInsets.all(12 * scale),
      decoration: BoxDecoration(
        color: tokens.card,
        borderRadius: BorderRadius.circular(16 * scale),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              WalletBadge(
                label: tournament.levelLabel,
                color: tokens.accentGreen,
              ),
              const Spacer(),
              WalletBadge(
                label: tournament.approvalLabel,
                color: tokens.accentGreen,
              ),
            ],
          ),
          SizedBox(height: 12 * scale),
          Text(
            tournament.name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 14 * scale,
              fontWeight: FontWeight.w600,
              color: Colors.white,
              height: 1.25,
            ),
          ),
          SizedBox(height: 2 * scale),
          Row(
            children: [
              Flexible(
                child: Text(
                  tournament.venue,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 12 * scale,
                    fontWeight: FontWeight.w500,
                    color: tokens.muted,
                    height: 1.2,
                  ),
                ),
              ),
              SizedBox(width: 4 * scale),
              Container(
                width: 2 * scale,
                height: 2 * scale,
                decoration: BoxDecoration(
                  color: tokens.textTertiary,
                  shape: BoxShape.circle,
                ),
              ),
              SizedBox(width: 4 * scale),
              Text(
                tournament.dateLabel,
                maxLines: 1,
                style: TextStyle(
                  fontSize: 12 * scale,
                  fontWeight: FontWeight.w500,
                  color: tokens.muted,
                  height: 1.2,
                ),
              ),
            ],
          ),
          SizedBox(height: 12 * scale),
          Container(
            height: 1 * scale,
            color: tokens.border.withValues(alpha: 0.5),
          ),
          SizedBox(height: 6 * scale),
          Row(
            children: [
              Expanded(
                child: Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(
                        text:
                            '${tournament.registeredTeams}/${tournament.totalTeams}',
                        style: TextStyle(
                          fontSize: 14 * scale,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                      TextSpan(
                        text: ' Teams',
                        style: TextStyle(
                          fontSize: 12 * scale,
                          fontWeight: FontWeight.w500,
                          color: tokens.muted,
                        ),
                      ),
                    ],
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              SizedBox(width: 8 * scale),
              WalletMoneyText(
                formatIndianRupees(tournament.earningsRupees),
                maxLines: 1,
                symbolStyle: TextStyle(
                  fontSize: 14 * scale,
                  fontWeight: FontWeight.w500,
                  color: tokens.gold,
                  height: 1.2,
                ),
                amountStyle: TextStyle(
                  fontSize: 14 * scale,
                  fontWeight: FontWeight.w600,
                  color: tokens.gold,
                  height: 1.2,
                ),
              ),
            ],
          ),
          SizedBox(height: 12 * scale),
          Row(
            children: [
              Expanded(
                child: _CardAction(
                  label: 'View',
                  scale: scale,
                  onTap: () => onAction('View'),
                ),
              ),
              SizedBox(width: 8 * scale),
              Expanded(
                child: _CardAction(
                  label: 'Manage',
                  scale: scale,
                  onTap: () => onAction('Manage'),
                ),
              ),
              SizedBox(width: 8 * scale),
              Expanded(
                child: _CardAction(
                  label: 'Earnings',
                  scale: scale,
                  onTap: () => onAction('Earnings'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _CardAction extends StatelessWidget {
  final String label;
  final double scale;
  final VoidCallback onTap;

  const _CardAction({
    required this.label,
    required this.scale,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final tokens = context.sporto;
    return Semantics(
      button: true,
      label: label,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12 * scale),
          child: SizedBox(
            height: 44 * scale,
            width: double.infinity,
            child: Center(
              child: Container(
                height: 31 * scale,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: tokens.canvas.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(12 * scale),
                ),
                alignment: Alignment.center,
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 12 * scale,
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                    height: 1.2,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
