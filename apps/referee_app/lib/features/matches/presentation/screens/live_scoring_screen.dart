import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ui_kit/ui_kit.dart';

class LiveScoringScreen extends StatefulWidget {
  const LiveScoringScreen({super.key});

  @override
  State<LiveScoringScreen> createState() => _LiveScoringScreenState();
}

class _LiveScoringScreenState extends State<LiveScoringScreen> {
  int _currentOver = 2;
  int _currentBall = 1;
  int _totalRuns = 28;
  int _wickets = 1;

  // Last 6 balls history
  final List<String> _ballHistory = ['1', '4', '0', 'W', '2', '1'];

  void _addRun(int runs) {
    setState(() {
      _totalRuns += runs;
      _ballHistory.add(runs.toString());
      if (_ballHistory.length > 6) _ballHistory.removeAt(0);

      _currentBall++;
      if (_currentBall > 6) {
        _currentBall = 1;
        _currentOver++;
      }
    });
  }

  void _addWicket() {
    setState(() {
      _wickets++;
      _ballHistory.add('W');
      if (_ballHistory.length > 6) _ballHistory.removeAt(0);

      _currentBall++;
      if (_currentBall > 6) {
        _currentBall = 1;
        _currentOver++;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
            icon: Icon(Icons.arrow_back_ios_new_rounded, color: cs.onSurface),
            onPressed: () => context.pop()),
        title: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Live Scoring',
              style: GoogleFonts.spaceGrotesk(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: cs.onSurface)),
          Text('Match #SPT-20481',
              style: TextStyle(fontSize: 12, color: cs.onSurfaceVariant)),
        ]),
      ),
      body: SingleChildScrollView(
        physics: const ClampingScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
        child: Column(
          children: [
            // --- Main Scoreboard ---
            SportoGradientCard(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              radius: 24,
              colors: const [Color(0xFF4A2515), Color(0xFF2A1510)],
              borderColor: Colors.redAccent.withOpacity(0.3),
              child: Column(children: [
                Text('Jaipur Super Over',
                    style: TextStyle(
                        color: Colors.orange,
                        fontSize: 16,
                        fontWeight: FontWeight.w700)),
                const SizedBox(height: 16),
                Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Text('$_totalRuns/$_wickets',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 48,
                          fontWeight: FontWeight.w700)),
                  const SizedBox(width: 16),
                  Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Over $_currentOver.$_currentBall',
                            style:
                                TextStyle(color: Colors.white70, fontSize: 14)),
                        Text('Target: 45',
                            style:
                                TextStyle(color: Colors.white70, fontSize: 12)),
                      ]),
                ]),
                const SizedBox(height: 24),
                Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Column(children: [
                        Text('CRR',
                            style:
                                TextStyle(color: Colors.white54, fontSize: 12)),
                        Text('14.00',
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w700))
                      ]),
                      Container(width: 1, height: 30, color: Colors.white24),
                      Column(children: [
                        Text('RRR',
                            style:
                                TextStyle(color: Colors.white54, fontSize: 12)),
                        Text('8.50',
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w700))
                      ]),
                    ]),
              ]),
            ),
            const SizedBox(height: 24),

            // --- Current Players ---
            Row(children: [
              Expanded(
                  child: _PlayerStatCard(
                      name: 'Rahul',
                      role: 'Batter',
                      runs: '12',
                      balls: '8',
                      fours: '2',
                      sixes: '0',
                      sr: '150.0',
                      isStriker: true)),
              const SizedBox(width: 12),
              Expanded(
                  child: _PlayerStatCard(
                      name: 'Amit',
                      role: 'Bowler',
                      overs: '1.1',
                      maidens: '0',
                      runs: '14',
                      wickets: '1',
                      eco: '12.0',
                      isStriker: false)),
            ]),
            const SizedBox(height: 24),

            // --- This Over History ---
            SportoCard(
              padding: const EdgeInsets.all(16),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('This Over',
                        style: TextStyle(
                            color: cs.onSurfaceVariant,
                            fontSize: 12,
                            fontWeight: FontWeight.w600)),
                    const SizedBox(height: 12),
                    Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: List.generate(
                            6,
                            (i) => Container(
                                  width: 36,
                                  height: 36,
                                  decoration: BoxDecoration(
                                    color: i < _ballHistory.length
                                        ? (_ballHistory[i] == 'W'
                                            ? Colors.redAccent
                                            : _ballHistory[i] == '4' ||
                                                    _ballHistory[i] == '6'
                                                ? Colors.green
                                                : SportoTextField.inputFill)
                                        : SportoTextField.inputFill,
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                        color: SportoCard.defaultBorder),
                                  ),
                                  alignment: Alignment.center,
                                  child: Text(
                                      i < _ballHistory.length
                                          ? _ballHistory[i]
                                          : '-',
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 14,
                                          fontWeight: FontWeight.w700)),
                                ))),
                  ]),
            ),
            const SizedBox(height: 24),

            // --- Scoring Actions Grid ---
            GridView.count(
              crossAxisCount: 3,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 1.8,
              children: [
                _ActionBtn(
                    label: '0 Runs',
                    color: SportoTextField.inputFill,
                    onTap: () => _addRun(0)),
                _ActionBtn(
                    label: '1 Run',
                    color: SportoTextField.inputFill,
                    onTap: () => _addRun(1)),
                _ActionBtn(
                    label: '2 Runs',
                    color: SportoTextField.inputFill,
                    onTap: () => _addRun(2)),
                _ActionBtn(
                    label: '3 Runs',
                    color: SportoTextField.inputFill,
                    onTap: () => _addRun(3)),
                _ActionBtn(
                    label: '4 Runs',
                    color: Colors.green,
                    onTap: () => _addRun(4)),
                _ActionBtn(
                    label: '6 Runs',
                    color: Colors.green,
                    onTap: () => _addRun(6)),
                _ActionBtn(
                    label: 'Wide',
                    color: Colors.orange,
                    onTap: () => _addRun(1)),
                _ActionBtn(
                    label: 'No Ball',
                    color: Colors.orange,
                    onTap: () => _addRun(1)),
                _ActionBtn(
                    label: 'Wicket',
                    color: Colors.redAccent,
                    onTap: _addWicket),
              ],
            ),
            const SizedBox(height: 24),

            // --- Undo / End Over ---
            Row(children: [
              Expanded(
                  child: OutlinedButton(
                      onPressed: () {},
                      style: OutlinedButton.styleFrom(
                          foregroundColor: cs.onSurfaceVariant,
                          side: BorderSide(
                              color: cs.onSurfaceVariant.withOpacity(0.3)),
                          minimumSize: const Size(double.infinity, 50),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12))),
                      child: const Text('Undo Last Ball'))),
              const SizedBox(width: 12),
              Expanded(
                  child: ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                          backgroundColor: cs.secondary,
                          foregroundColor: Colors.black,
                          minimumSize: const Size(double.infinity, 50),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12))),
                      child: const Text('End Over'))),
            ]),
          ],
        ),
      ),
    );
  }
}

// Player Stat Card Helper
class _PlayerStatCard extends StatelessWidget {
  final String name, role;
  final String? runs, balls, fours, sixes, sr;
  final String? overs, maidens, wickets, eco;
  final bool isStriker;

  const _PlayerStatCard(
      {required this.name,
      required this.role,
      this.runs,
      this.balls,
      this.fours,
      this.sixes,
      this.sr,
      this.overs,
      this.maidens,
      this.wickets,
      this.eco,
      required this.isStriker});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return SportoCard(
      padding: const EdgeInsets.all(16),
      borderColor:
          isStriker ? cs.tertiary.withOpacity(0.5) : SportoCard.defaultBorder,
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text(name,
              style: TextStyle(
                  color: cs.onSurface,
                  fontSize: 16,
                  fontWeight: FontWeight.w700)),
          if (isStriker) Icon(Icons.circle, color: cs.tertiary, size: 8),
        ]),
        Text(role, style: TextStyle(color: cs.onSurfaceVariant, fontSize: 12)),
        const SizedBox(height: 12),
        if (role == 'Batter')
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            _MiniStat(label: 'R', value: runs!),
            _MiniStat(label: 'B', value: balls!),
            _MiniStat(label: '4s', value: fours!),
            _MiniStat(label: '6s', value: sixes!),
            _MiniStat(label: 'SR', value: sr!),
          ])
        else
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            _MiniStat(label: 'O', value: overs!),
            _MiniStat(label: 'M', value: maidens!),
            _MiniStat(label: 'R', value: runs!),
            _MiniStat(label: 'W', value: wickets!),
            _MiniStat(label: 'Eco', value: eco!),
          ]),
      ]),
    );
  }
}

Widget _MiniStat({required String label, required String value}) {
  return Column(children: [
    Text(value,
        style: const TextStyle(
            color: Colors.white, fontSize: 14, fontWeight: FontWeight.w700)),
    Text(label, style: TextStyle(color: Colors.grey[500], fontSize: 10))
  ]);
}

// Action Button Helper
class _ActionBtn extends StatelessWidget {
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _ActionBtn(
      {required this.label, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
              decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: SportoCard.defaultBorder)),
              alignment: Alignment.center,
              child: Text(label,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w600)))),
    );
  }
}
