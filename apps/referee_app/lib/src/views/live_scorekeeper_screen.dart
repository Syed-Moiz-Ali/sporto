import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ui_kit/ui_kit.dart';
import 'package:shared_domain/shared_domain.dart';
import '../bloc/match_scoring_bloc.dart';

class LiveScorekeeperScreen extends StatefulWidget {
  final CricketMatchEntity match;

  const LiveScorekeeperScreen({super.key, required this.match});

  @override
  State<LiveScorekeeperScreen> createState() => _LiveScorekeeperScreenState();
}

class _LiveScorekeeperScreenState extends State<LiveScorekeeperScreen> {
  late CricketMatchEntity _match;
  final String _striker = 'John Smith';
  final String _bowler = 'David Miller';

  @override
  void initState() {
    super.initState();
    _match = widget.match;
  }

  void _recordBall({required int runs, bool isWide = false, bool isNoBall = false, bool isWicket = false, WicketType? wicketType}) {
    final newBall = BallScoreEntity(
      ballNumber: _match.commentary.length + 1,
      runs: runs,
      isWide: isWide,
      isNoBall: isNoBall,
      isWicket: isWicket,
      wicketType: wicketType,
      strikerName: _striker,
      bowlerName: _bowler,
    );

    context.read<MatchScoringBloc>().add(RecordBallEvent(_match.id, newBall));
  }

  void _showWicketModal() {
    final colorScheme = Theme.of(context).colorScheme;
    GlassModal.show(
      context: context,
      title: 'Select Wicket Type',
      child: Column(
        children: WicketType.values.map((wType) {
          return ListTile(
            title: Text(wType.name.toUpperCase(), style: TextStyle(color: colorScheme.onSurface, fontWeight: FontWeight.bold)),
            trailing: Icon(Icons.arrow_forward_ios, color: colorScheme.primary, size: 16),
            onTap: () {
              Navigator.of(context).pop();
              _recordBall(runs: 0, isWicket: true, wicketType: wType);
            },
          );
        }).toList(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text('${widget.match.teamA.name} vs ${widget.match.teamB.name}'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.check_circle_outline, color: colorScheme.primary),
            onPressed: () {
              context.read<MatchScoringBloc>().add(CompleteMatchEvent(widget.match.id));
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
      body: BlocConsumer<MatchScoringBloc, MatchScoringState>(
        listener: (context, state) {
          if (state is MatchScoringLoadedState) {
            setState(() => _match = state.match);
          }
        },
        builder: (context, state) {
          final isInning1 = _match.currentInning == 1;
          final score = isInning1 ? _match.teamAScore : _match.teamBScore;
          final wickets = isInning1 ? _match.teamAWickets : _match.teamBWickets;
          final overs = isInning1 ? _match.teamAOvers : _match.teamBOvers;
          final battingTeam = isInning1 ? _match.teamA : _match.teamB;

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Live Scorecard Header Card
                GlassContainer(
                  padding: const EdgeInsets.all(16),
                  hasGlow: true,
                  borderColor: colorScheme.primary,
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Text(battingTeam.logoEmoji, style: const TextStyle(fontSize: 24)),
                              const SizedBox(width: 8),
                              Text(battingTeam.name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: colorScheme.error.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text('LIVE SCOREKEEPER', style: TextStyle(color: colorScheme.error, fontSize: 11, fontWeight: FontWeight.bold)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.baseline,
                        textBaseline: TextBaseline.alphabetic,
                        children: [
                          Text('$score/$wickets', style: TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: colorScheme.primary)),
                          Text('Overs: ${overs.toStringAsFixed(1)} / ${_match.totalOvers}', style: TextStyle(fontSize: 16, color: colorScheme.onSurfaceVariant)),
                        ],
                      ),
                      Divider(color: colorScheme.outline, height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Striker: 🏏 $_striker', style: TextStyle(fontSize: 13, color: colorScheme.onSurface)),
                          Text('Bowler: 🎯 $_bowler', style: TextStyle(fontSize: 13, color: colorScheme.onSurfaceVariant)),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Quick Run Buttons
                Text('Quick Runs', style: TextStyle(fontWeight: FontWeight.bold, color: colorScheme.onSurface)),
                const SizedBox(height: 8),
                Row(
                  children: [0, 1, 2, 3, 4, 6].map((run) {
                    return Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 3.0),
                        child: GlassButton(
                          label: '$run',
                          height: 48,
                          isPrimary: run == 4 || run == 6,
                          onPressed: () => _recordBall(runs: run),
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 12),

                // Extras & Wickets
                Row(
                  children: [
                    Expanded(
                      child: GlassButton(
                        label: 'WIDE (+1)',
                        height: 44,
                        isPrimary: false,
                        onPressed: () => _recordBall(runs: 0, isWide: true),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: GlassButton(
                        label: 'NO BALL (+1)',
                        height: 44,
                        isPrimary: false,
                        onPressed: () => _recordBall(runs: 0, isNoBall: true),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: GlassButton(
                        label: 'WICKET 🔴',
                        height: 44,
                        isPrimary: true,
                        onPressed: _showWicketModal,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Commentary log
                Text('Ball Commentary Feed', style: TextStyle(fontWeight: FontWeight.bold, color: colorScheme.onSurface)),
                const SizedBox(height: 8),
                Expanded(
                  child: GlassContainer(
                    padding: const EdgeInsets.all(12),
                    child: _match.commentary.isEmpty
                        ? Center(child: Text('No balls recorded yet', style: TextStyle(color: colorScheme.onSurfaceVariant)))
                        : ListView.builder(
                            itemCount: _match.commentary.length,
                            reverse: true,
                            itemBuilder: (context, index) {
                              final ball = _match.commentary[index];
                              final desc = ball.isWicket
                                  ? 'WICKET (${ball.wicketType?.name.toUpperCase()})'
                                  : (ball.isWide ? 'WIDE +1' : (ball.isNoBall ? 'NO BALL +1' : '${ball.runs} Run(s)'));

                              return Padding(
                                padding: const EdgeInsets.symmetric(vertical: 4.0),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 28,
                                      height: 28,
                                      decoration: BoxDecoration(
                                        color: ball.isWicket ? colorScheme.error : colorScheme.primary.withValues(alpha: 0.2),
                                        shape: BoxShape.circle,
                                      ),
                                      child: Center(
                                        child: Text(
                                          '${ball.ballNumber}',
                                          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Text(
                                        'Ball #${ball.ballNumber}: $desc by ${ball.strikerName}',
                                        style: TextStyle(
                                          color: ball.isWicket ? colorScheme.error : colorScheme.onSurface,
                                          fontWeight: ball.isWicket ? FontWeight.bold : FontWeight.normal,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
