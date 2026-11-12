import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:referee_data/referee_data.dart';

import '../../../../core/di/dependency_injector.dart';

class MatchResultScreen extends StatefulWidget {
  final String? matchId;

  const MatchResultScreen({super.key, this.matchId});

  @override
  State<MatchResultScreen> createState() => _MatchResultScreenState();
}

class _MatchResultScreenState extends State<MatchResultScreen> {
  RefereeRemoteDataSource get _remote =>
      DependencyInjector.instance.refereeRemoteDataSource;

  late Future<_ResultPayload> _future;

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  Future<_ResultPayload> _load() async {
    final id = int.tryParse(widget.matchId ?? '');
    if (id == null) {
      throw const FormatException('Match id is missing.');
    }
    RefereeMatchResultResponse? result;
    RefereeScorecardResponse? scorecard;
    RefereeScoreEventsPage? events;
    try {
      result = await _remote.getMatchResult(id);
    } catch (_) {}
    try {
      scorecard = await _remote.getMatchScorecard(id);
    } catch (_) {}
    try {
      events = await _remote.listMatchScoreEvents(
        id,
        perPage: 100,
        order: 'desc',
      );
    } catch (_) {}
    return _ResultPayload(
      result: result,
      scorecard: scorecard,
      events: events,
    );
  }

  void _retry() {
    setState(() => _future = _load());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF090C10),
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            _Header(onBack: () => context.pop()),
            Expanded(
              child: FutureBuilder<_ResultPayload>(
                future: _future,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(
                        color: Color(0xFF2BB673),
                      ),
                    );
                  }
                  if (snapshot.hasError || !snapshot.hasData) {
                    return _ErrorView(
                      message: snapshot.error?.toString() ??
                          'Unable to load the match result.',
                      onRetry: _retry,
                    );
                  }
                  return _ResultBody(payload: snapshot.data!);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ResultPayload {
  const _ResultPayload({this.result, this.scorecard, this.events});

  final RefereeMatchResultResponse? result;
  final RefereeScorecardResponse? scorecard;
  final RefereeScoreEventsPage? events;
}

class _Header extends StatelessWidget {
  final VoidCallback onBack;

  const _Header({required this.onBack});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      child: Row(
        children: [
          IconButton(
            onPressed: onBack,
            icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
            color: Colors.white,
          ),
          const SizedBox(width: 4),
          const Expanded(
            child: Text(
              'Match Result',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ResultBody extends StatelessWidget {
  final _ResultPayload payload;

  const _ResultBody({required this.payload});

  @override
  Widget build(BuildContext context) {
    final result = payload.result;
    final scorecard = payload.scorecard;
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 32),
      children: [
        _WinnerCard(result: result),
        if (scorecard != null) ...[
          const SizedBox(height: 14),
          _AvailabilityBanner(availability: scorecard.dataAvailability),
          const SizedBox(height: 14),
          _TeamTotalsCard(scorecard: scorecard),
          if (scorecard.playerOfMatch != null) ...[
            const SizedBox(height: 14),
            _InfoCard(
              title: 'Player of the Match',
              value: scorecard.playerOfMatch!,
            ),
          ],
          for (final innings in scorecard.innings) ...[
            const SizedBox(height: 14),
            _InningsCard(innings: innings),
          ],
          for (final innings in scorecard.superOvers) ...[
            const SizedBox(height: 14),
            _InningsCard(innings: innings, superOver: true),
          ],
        ],
        if (payload.events != null && payload.events!.items.isNotEmpty) ...[
          const SizedBox(height: 14),
          _EventsCard(events: payload.events!),
        ],
      ],
    );
  }
}

class _EventsCard extends StatelessWidget {
  final RefereeScoreEventsPage events;

  const _EventsCard({required this.events});

  @override
  Widget build(BuildContext context) {
    return _Panel(
      title: 'Ball-by-Ball',
      trailing: '${events.total}',
      child: Column(
        children: [
          for (final event in events.items.take(30))
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 3),
              child: Row(
                children: [
                  SizedBox(
                    width: 52,
                    child: Text(
                      event.inningsNumber == null
                          ? '—'
                          : '${event.inningsNumber}.${event.overNumber ?? 0}'
                              '.${event.ballNumber ?? 0}',
                      style: const TextStyle(
                        color: Color(0xFFA0A0A0),
                        fontSize: 10,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      _eventLabel(event),
                      style: TextStyle(
                        color: event.isReversed
                            ? const Color(0xFFA0A0A0)
                            : Colors.white,
                        fontSize: 11,
                        decoration: event.isReversed
                            ? TextDecoration.lineThrough
                            : null,
                      ),
                    ),
                  ),
                  Text(
                    event.isReversed ? 'reversed' : _eventValue(event),
                    style: TextStyle(
                      color: event.isReversed
                          ? const Color(0xFFA0A0A0)
                          : const Color(0xFF2BB673),
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          if (events.items.length > 30)
            const Padding(
              padding: EdgeInsets.only(top: 6),
              child: Text(
                'Showing the latest 30 events',
                style: TextStyle(color: Color(0xFFA0A0A0), fontSize: 10),
              ),
            ),
        ],
      ),
    );
  }

  String _eventLabel(RefereeScoreEventLedgerItem event) {
    final type = event.eventType ?? '';
    final wicketType = event.eventData['wicket_type']?.toString();
    if (event.isWicket && wicketType != null && wicketType.isNotEmpty) {
      return 'WICKET · $wicketType';
    }
    return type.replaceAll('_', ' ');
  }

  String _eventValue(RefereeScoreEventLedgerItem event) {
    if (event.isWicket) return 'W';
    if (event.extrasValue > 0) return '+${event.extrasValue}';
    return '${event.scoreValue}';
  }
}

class _WinnerCard extends StatelessWidget {
  final RefereeMatchResultResponse? result;

  const _WinnerCard({required this.result});

  @override
  Widget build(BuildContext context) {
    final winner = result?.winnerTeamName;
    final message = result?.message;
    final pending = result == null || result!.isPending;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF121A14),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0x802BB673)),
      ),
      child: Column(
        children: [
          Icon(
            pending ? Icons.hourglass_top_rounded : Icons.emoji_events_rounded,
            color: const Color(0xFF2BB673),
            size: 34,
          ),
          const SizedBox(height: 10),
          Text(
            pending ? 'Result pending' : (winner ?? 'Match ended'),
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
          ),
          if (message != null && message.trim().isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Color(0xFFA0A0A0),
                fontSize: 13,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _AvailabilityBanner extends StatelessWidget {
  final RefereeScorecardAvailability availability;

  const _AvailabilityBanner({required this.availability});

  @override
  Widget build(BuildContext context) {
    final complete = availability.isComplete;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: complete ? const Color(0x142BB673) : const Color(0x14F4B41A),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: complete ? const Color(0x802BB673) : const Color(0x80F4B41A),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            complete ? Icons.verified_rounded : Icons.info_outline_rounded,
            color: complete ? const Color(0xFF2BB673) : const Color(0xFFF4B41A),
            size: 18,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              availability.message ??
                  (complete
                      ? 'Scorecard verified from the ball-by-ball ledger.'
                      : 'Player statistics are not available for this match.'),
              style: const TextStyle(
                color: Color(0xFFA0A0A0),
                fontSize: 12,
                height: 1.35,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TeamTotalsCard extends StatelessWidget {
  final RefereeScorecardResponse scorecard;

  const _TeamTotalsCard({required this.scorecard});

  @override
  Widget build(BuildContext context) {
    final names = {
      for (final team in scorecard.match.teams) '${team.id}': team.name,
    };
    return _Panel(
      title: 'Score Summary',
      child: Column(
        children: [
          for (final entry in scorecard.teamTotals.entries)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      names[entry.key] ?? 'Team ${entry.key}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Text(
                    entry.value.scoreText,
                    style: const TextStyle(
                      color: Color(0xFF2BB673),
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    '${entry.value.overs ?? '0.0'} ov',
                    style: const TextStyle(
                      color: Color(0xFFA0A0A0),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _InningsCard extends StatelessWidget {
  final RefereeScorecardInnings innings;
  final bool superOver;

  const _InningsCard({required this.innings, this.superOver = false});

  @override
  Widget build(BuildContext context) {
    final title = superOver
        ? 'Super Over ${innings.inningsNumber}'
        : 'Innings ${innings.inningsNumber}';
    return _Panel(
      title: '$title · ${innings.battingTeamName ?? ''}',
      trailing: innings.totals.scoreText,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (innings.batting.isNotEmpty) ...[
            const _SectionLabel('Batting'),
            for (final bat in innings.batting)
              _StatRow(
                name: bat.name,
                value: '${bat.runs} (${bat.ballsFaced})',
                detail: bat.dismissal ?? bat.status ?? '',
              ),
          ],
          if (innings.bowling.isNotEmpty) ...[
            const SizedBox(height: 10),
            const _SectionLabel('Bowling'),
            for (final bowl in innings.bowling)
              _StatRow(
                name: bowl.name,
                value: '${bowl.wickets}/${bowl.runsConceded}',
                detail: '${bowl.overs ?? '0.0'} ov',
              ),
          ],
          if (innings.fallOfWickets.isNotEmpty) ...[
            const SizedBox(height: 10),
            const _SectionLabel('Fall of Wickets'),
            Wrap(
              spacing: 8,
              runSpacing: 6,
              children: [
                for (final fow in innings.fallOfWickets)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0x1AFFFFFF),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '${fow.score ?? ''}/${fow.wicketNumber}',
                      style: const TextStyle(
                        color: Color(0xFFA0A0A0),
                        fontSize: 11,
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _Panel extends StatelessWidget {
  final String title;
  final String? trailing;
  final Widget child;

  const _Panel({required this.title, this.trailing, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF12161C),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0x1AFFFFFF)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              if (trailing != null)
                Text(
                  trailing!,
                  style: const TextStyle(
                    color: Color(0xFF2BB673),
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 10),
          child,
        ],
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String text;

  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        text.toUpperCase(),
        style: const TextStyle(
          color: Color(0xFF7AD3FF),
          fontSize: 10,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.6,
        ),
      ),
    );
  }
}

class _StatRow extends StatelessWidget {
  final String name;
  final String value;
  final String detail;

  const _StatRow({
    required this.name,
    required this.value,
    required this.detail,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          Expanded(
            child: Text(
              name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: Colors.white, fontSize: 12),
            ),
          ),
          if (detail.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(right: 10),
              child: Text(
                detail,
                style: const TextStyle(
                  color: Color(0xFFA0A0A0),
                  fontSize: 10,
                ),
              ),
            ),
          Text(
            value,
            style: const TextStyle(
              color: Color(0xFF2BB673),
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final String title;
  final String value;

  const _InfoCard({required this.title, required this.value});

  @override
  Widget build(BuildContext context) {
    return _Panel(
      title: title,
      child: Text(
        value,
        style: const TextStyle(
          color: Color(0xFF2BB673),
          fontSize: 16,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorView({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, color: Color(0xFFFE464B)),
            const SizedBox(height: 10),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Color(0xFFA0A0A0), fontSize: 12),
            ),
            const SizedBox(height: 14),
            FilledButton(onPressed: onRetry, child: const Text('Retry')),
          ],
        ),
      ),
    );
  }
}
