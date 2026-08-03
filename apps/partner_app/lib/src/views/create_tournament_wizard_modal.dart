import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ui_kit/ui_kit.dart';
import 'package:shared_domain/shared_domain.dart';
import '../bloc/tournament_bloc.dart';

class CreateTournamentWizardModal extends StatefulWidget {
  const CreateTournamentWizardModal({super.key});

  @override
  State<CreateTournamentWizardModal> createState() => _CreateTournamentWizardModalState();
}

class _CreateTournamentWizardModalState extends State<CreateTournamentWizardModal> {
  int _currentStep = 1;

  final _nameController = TextEditingController(text: 'Winter Super League 2026');
  SportType _selectedSport = SportType.cricket;
  String _category = 'T20 Knockout';
  int _oversPerInning = 20;
  int _totalTeams = 8;
  int _matchDurationMinutes = 60;
  int _breakMinutes = 15;
  final _entryFeeController = TextEditingController(text: '350');
  final _prizePoolController = TextEditingController(text: '3500');
  String _venue = 'National Cricket Stadium Pitch 1';
  bool _agreedToTerms = false;

  @override
  void dispose() {
    _nameController.dispose();
    _entryFeeController.dispose();
    _prizePoolController.dispose();
    super.dispose();
  }

  void _submitTournament() {
    if (!_agreedToTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please agree to Partner Guidelines')),
      );
      return;
    }

    final newTournament = TournamentEntity(
      id: 't-${DateTime.now().millisecondsSinceEpoch}',
      name: _nameController.text.trim(),
      sportType: _selectedSport,
      category: _category,
      startDate: DateTime.now().add(const Duration(days: 7)),
      oversPerInning: _oversPerInning,
      totalTeams: _totalTeams,
      matchDurationMinutes: _matchDurationMinutes,
      breakMinutes: _breakMinutes,
      venues: [_venue],
      entryFee: double.tryParse(_entryFeeController.text) ?? 300,
      prizePool: double.tryParse(_prizePoolController.text) ?? 3000,
      status: 'Open Registration',
      syncStatus: SyncStatus.pendingSync,
    );

    context.read<TournamentBloc>().add(AddTournamentEvent(newTournament));
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      constraints: const BoxConstraints(maxHeight: 580),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: List.generate(4, (index) {
              final stepNum = index + 1;
              final isActive = stepNum <= _currentStep;
              return Expanded(
                child: Container(
                  height: 4,
                  margin: const EdgeInsets.symmetric(horizontal: 2),
                  decoration: BoxDecoration(
                    color: isActive ? colorScheme.primary : colorScheme.outline,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              );
            }),
          ),
          const SizedBox(height: 16),

          Text(
            'Step $_currentStep of 4: ${_getStepTitle()}',
            style: TextStyle(
              color: colorScheme.primary,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 12),

          Expanded(
            child: SingleChildScrollView(
              child: _buildStepContent(colorScheme),
            ),
          ),

          const SizedBox(height: 16),
          Row(
            children: [
              if (_currentStep > 1)
                Expanded(
                  child: GlassButton(
                    label: 'Back',
                    isPrimary: false,
                    onPressed: () => setState(() => _currentStep--),
                  ),
                ),
              if (_currentStep > 1) const SizedBox(width: 12),
              Expanded(
                child: GlassButton(
                  label: _currentStep == 4 ? 'Save Tournament' : 'Next Step',
                  isPrimary: true,
                  onPressed: () {
                    if (_currentStep < 4) {
                      setState(() => _currentStep++);
                    } else {
                      _submitTournament();
                    }
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _getStepTitle() {
    switch (_currentStep) {
      case 1:
        return 'Basic Info & Sport';
      case 2:
        return 'Format & Structure';
      case 3:
        return 'Timers & Duration';
      case 4:
        return 'Fees, Venue & Agreement';
      default:
        return '';
    }
  }

  Widget _buildStepContent(ColorScheme colorScheme) {
    switch (_currentStep) {
      case 1:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Tournament Name', style: TextStyle(color: colorScheme.onSurfaceVariant)),
            const SizedBox(height: 6),
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                filled: true,
                fillColor: colorScheme.surfaceContainer,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 14),
            Text('Sport Type', style: TextStyle(color: colorScheme.onSurfaceVariant)),
            const SizedBox(height: 6),
            DropdownButtonFormField<SportType>(
              initialValue: _selectedSport,
              dropdownColor: colorScheme.surface,
              decoration: InputDecoration(
                filled: true,
                fillColor: colorScheme.surfaceContainer,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
              items: SportType.values
                  .map((s) => DropdownMenuItem(
                        value: s,
                        child: Text(s.name.toUpperCase()),
                      ))
                  .toList(),
              onChanged: (val) => setState(() => _selectedSport = val!),
            ),
            const SizedBox(height: 14),
            Text('Category', style: TextStyle(color: colorScheme.onSurfaceVariant)),
            const SizedBox(height: 6),
            DropdownButtonFormField<String>(
              initialValue: _category,
              dropdownColor: colorScheme.surface,
              decoration: InputDecoration(
                filled: true,
                fillColor: colorScheme.surfaceContainer,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
              items: const [
                DropdownMenuItem(value: 'T20 Knockout', child: Text('T20 Knockout')),
                DropdownMenuItem(value: 'T10 League', child: Text('T10 League')),
                DropdownMenuItem(value: 'Box Cricket', child: Text('Box Cricket')),
              ],
              onChanged: (val) => setState(() => _category = val!),
            ),
          ],
        );

      case 2:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Overs Per Inning', style: TextStyle(color: colorScheme.onSurfaceVariant)),
            const SizedBox(height: 6),
            Row(
              children: [10, 15, 20].map((overs) {
                final isSel = _oversPerInning == overs;
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: GlassButton(
                      label: '$overs Overs',
                      isPrimary: isSel,
                      height: 44,
                      onPressed: () => setState(() => _oversPerInning = overs),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
            Text('Total Teams', style: TextStyle(color: colorScheme.onSurfaceVariant)),
            const SizedBox(height: 6),
            Row(
              children: [4, 8, 12, 16].map((teams) {
                final isSel = _totalTeams == teams;
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(right: 6.0),
                    child: GlassButton(
                      label: '$teams Teams',
                      isPrimary: isSel,
                      height: 44,
                      onPressed: () => setState(() => _totalTeams = teams),
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        );

      case 3:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Match Duration', style: TextStyle(color: colorScheme.onSurfaceVariant)),
            const SizedBox(height: 6),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [20, 30, 40, 50, 60].map((dur) {
                final isSel = _matchDurationMinutes == dur;
                return SizedBox(
                  width: 90,
                  child: GlassButton(
                    label: '$dur mins',
                    isPrimary: isSel,
                    height: 42,
                    onPressed: () => setState(() => _matchDurationMinutes = dur),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
            Text('Break Between Matches', style: TextStyle(color: colorScheme.onSurfaceVariant)),
            const SizedBox(height: 6),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [5, 10, 15, 20].map((brk) {
                final isSel = _breakMinutes == brk;
                return SizedBox(
                  width: 90,
                  child: GlassButton(
                    label: '$brk mins',
                    isPrimary: isSel,
                    height: 42,
                    onPressed: () => setState(() => _breakMinutes = brk),
                  ),
                );
              }).toList(),
            ),
          ],
        );

      case 4:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Entry Fee (\$)'),
                      const SizedBox(height: 4),
                      TextField(
                        controller: _entryFeeController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: colorScheme.surfaceContainer,
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Prize Pool (\$)'),
                      const SizedBox(height: 4),
                      TextField(
                        controller: _prizePoolController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: colorScheme.surfaceContainer,
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            const Text('Venue Selection'),
            const SizedBox(height: 4),
            DropdownButtonFormField<String>(
              initialValue: _venue,
              dropdownColor: colorScheme.surface,
              decoration: InputDecoration(
                filled: true,
                fillColor: colorScheme.surfaceContainer,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
              items: const [
                DropdownMenuItem(value: 'National Cricket Stadium Pitch 1', child: Text('National Stadium Pitch 1')),
                DropdownMenuItem(value: 'Sporto Arena Turf A', child: Text('Sporto Arena Turf A')),
                DropdownMenuItem(value: 'City Sports Complex', child: Text('City Sports Complex')),
              ],
              onChanged: (val) => setState(() => _venue = val!),
            ),
            const SizedBox(height: 14),
            GlassContainer(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              backgroundColor: colorScheme.surfaceContainer,
              child: CheckboxListTile(
                value: _agreedToTerms,
                activeColor: colorScheme.primary,
                title: Text(
                  'I confirm tournament details & agree to Sporto Partner Guidelines.',
                  style: TextStyle(fontSize: 12, color: colorScheme.onSurfaceVariant),
                ),
                onChanged: (val) => setState(() => _agreedToTerms = val ?? false),
              ),
            ),
          ],
        );

      default:
        return const SizedBox.shrink();
    }
  }
}
