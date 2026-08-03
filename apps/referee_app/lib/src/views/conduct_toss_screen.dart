import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ui_kit/ui_kit.dart';
import 'package:shared_domain/shared_domain.dart';
import '../bloc/match_scoring_bloc.dart';

class ConductTossScreen extends StatefulWidget {
  final CricketMatchEntity match;

  const ConductTossScreen({super.key, required this.match});

  @override
  State<ConductTossScreen> createState() => _ConductTossScreenState();
}

class _ConductTossScreenState extends State<ConductTossScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  String? _tossWinnerTeamId;
  TossChoice _tossChoice = TossChoice.bat;
  bool _isFlipping = false;
  String _coinSide = 'HEADS';

  @override
  void initState() {
    super.initState();
    _tossWinnerTeamId = widget.match.teamA.id;

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );

    _animation = Tween<double>(begin: 0, end: 10 * pi).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        setState(() {
          _isFlipping = false;
          _coinSide = Random().nextBool() ? 'HEADS' : 'TAILS';
        });
      }
    });
  }

  void _flipCoin() {
    if (_isFlipping) return;
    setState(() => _isFlipping = true);
    _controller.forward(from: 0);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Conduct Coin Toss'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Coin flip widget
            Center(
              child: GestureDetector(
                onTap: _flipCoin,
                child: AnimatedBuilder(
                  animation: _animation,
                  builder: (context, child) {
                    final transform = Matrix4.identity()
                      ..setEntry(3, 2, 0.001)
                      ..rotateY(_animation.value);

                    return Transform(
                      transform: transform,
                      alignment: Alignment.center,
                      child: GlassContainer(
                        width: 140,
                        height: 140,
                        borderRadius: 70,
                        hasGlow: true,
                        backgroundColor: colorScheme.primary.withValues(alpha: 0.2),
                        borderColor: colorScheme.primary,
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.monetization_on, color: colorScheme.primary, size: 40),
                              const SizedBox(height: 4),
                              Text(
                                _isFlipping ? 'Flipping...' : _coinSide,
                                style: TextStyle(fontWeight: FontWeight.bold, color: colorScheme.primary, fontSize: 16),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
            const SizedBox(height: 8),
            Center(
              child: Text('Tap coin to flip', style: TextStyle(color: colorScheme.onSurfaceVariant, fontSize: 12)),
            ),
            const SizedBox(height: 24),

            Text('Coin Toss Winner', style: TextStyle(fontWeight: FontWeight.bold, color: colorScheme.onSurface)),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: GlassButton(
                    label: widget.match.teamA.name,
                    isPrimary: _tossWinnerTeamId == widget.match.teamA.id,
                    onPressed: () => setState(() => _tossWinnerTeamId = widget.match.teamA.id),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: GlassButton(
                    label: widget.match.teamB.name,
                    isPrimary: _tossWinnerTeamId == widget.match.teamB.id,
                    onPressed: () => setState(() => _tossWinnerTeamId = widget.match.teamB.id),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            Text('Toss Decision', style: TextStyle(fontWeight: FontWeight.bold, color: colorScheme.onSurface)),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: GlassButton(
                    label: 'Elect to BAT',
                    isPrimary: _tossChoice == TossChoice.bat,
                    onPressed: () => setState(() => _tossChoice = TossChoice.bat),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: GlassButton(
                    label: 'Elect to BOWL',
                    isPrimary: _tossChoice == TossChoice.bowl,
                    onPressed: () => setState(() => _tossChoice = TossChoice.bowl),
                  ),
                ),
              ],
            ),

            const Spacer(),
            GlassButton(
              label: 'Start Live Scorekeeper Engine',
              isPrimary: true,
              onPressed: () {
                if (_tossWinnerTeamId != null) {
                  final toss = TossResultEntity(winnerTeamId: _tossWinnerTeamId!, choice: _tossChoice);
                  context.read<MatchScoringBloc>().add(ConductTossEvent(widget.match.id, toss));
                  Navigator.of(context).pop();
                }
              },
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
