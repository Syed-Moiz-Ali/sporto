import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ui_kit/ui_kit.dart';
import 'package:shared_domain/shared_domain.dart';
import '../bloc/match_scoring_bloc.dart';

class MatchVerificationScreen extends StatefulWidget {
  final CricketMatchEntity match;

  const MatchVerificationScreen({super.key, required this.match});

  @override
  State<MatchVerificationScreen> createState() => _MatchVerificationScreenState();
}

class _MatchVerificationScreenState extends State<MatchVerificationScreen> {
  bool _teamARosterChecked = false;
  bool _teamBRosterChecked = false;
  bool _boundaryChecked = false;
  bool _ballsHandedChecked = false;

  bool get _isAllChecked =>
      _teamARosterChecked && _teamBRosterChecked && _boundaryChecked && _ballsHandedChecked;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Pre-Match Roster Verification'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            GlassContainer(
              padding: const EdgeInsets.all(16),
              hasGlow: true,
              child: Column(
                children: [
                  Text(
                    widget.match.tournamentName,
                    style: TextStyle(color: colorScheme.primary, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${widget.match.teamA.name} vs ${widget.match.teamB.name}',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: colorScheme.onSurface),
                  ),
                  const SizedBox(height: 4),
                  Text('Venue: ${widget.match.venue}', style: TextStyle(color: colorScheme.onSurfaceVariant, fontSize: 12)),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Required Official Verification Checklist',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: colorScheme.onSurface),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: ListView(
                children: [
                  _buildCheckTile(
                    title: 'Team A Roster Verified (${widget.match.teamA.name})',
                    value: _teamARosterChecked,
                    onChanged: (val) => setState(() => _teamARosterChecked = val ?? false),
                    colorScheme: colorScheme,
                  ),
                  _buildCheckTile(
                    title: 'Team B Roster Verified (${widget.match.teamB.name})',
                    value: _teamBRosterChecked,
                    onChanged: (val) => setState(() => _teamBRosterChecked = val ?? false),
                    colorScheme: colorScheme,
                  ),
                  _buildCheckTile(
                    title: 'Ground Boundary Markers Inspected',
                    value: _boundaryChecked,
                    onChanged: (val) => setState(() => _boundaryChecked = val ?? false),
                    colorScheme: colorScheme,
                  ),
                  _buildCheckTile(
                    title: 'Match Leather Balls Handed to Captains',
                    value: _ballsHandedChecked,
                    onChanged: (val) => setState(() => _ballsHandedChecked = val ?? false),
                    colorScheme: colorScheme,
                  ),
                ],
              ),
            ),
            GlassButton(
              label: 'Verify & Proceed to Coin Toss',
              isPrimary: true,
              isDisabled: !_isAllChecked,
              onPressed: () {
                context.read<MatchScoringBloc>().add(VerifyMatchRosterEvent(widget.match.id));
                Navigator.of(context).pop();
              },
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildCheckTile({
    required String title,
    required bool value,
    required ValueChanged<bool?> onChanged,
    required ColorScheme colorScheme,
  }) {
    return GlassContainer(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      backgroundColor: colorScheme.surfaceContainer,
      child: CheckboxListTile(
        value: value,
        activeColor: colorScheme.primary,
        title: Text(title, style: TextStyle(fontSize: 14, color: colorScheme.onSurface)),
        onChanged: onChanged,
      ),
    );
  }
}
