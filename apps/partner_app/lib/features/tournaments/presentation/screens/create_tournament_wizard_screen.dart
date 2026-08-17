import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:core/core.dart';
import 'package:partner_data/partner_data.dart';
import 'package:ui_kit/ui_kit.dart';

// ============================================================
// MAIN WIZARD SCREEN
// ============================================================
enum _TournamentSport { cricket, badminton, football }

class CreateTournamentWizardScreen extends StatefulWidget {
  final int initialStep;

  const CreateTournamentWizardScreen({
    super.key,
    this.initialStep = 0,
  });

  @override
  State<CreateTournamentWizardScreen> createState() =>
      _CreateTournamentWizardState();
}

class _CreateTournamentWizardState extends State<CreateTournamentWizardScreen> {
  late int _currentStep;
  final int _totalSteps = 6;

  // Controllers
  final _tournamentNameCtrl = TextEditingController();
  final _tournamentStartDateCtrl = TextEditingController();
  final _registrationEndDateCtrl = TextEditingController();
  final _registrationEndTimeCtrl = TextEditingController();
  final _matchDurationCtrl = TextEditingController();
  final _matchStartTimeCtrl = TextEditingController();
  final _breakBetweenMatchesCtrl = TextEditingController();
  final _lunchFromCtrl = TextEditingController();
  final _lunchToCtrl = TextEditingController();
  final _numberOfTeamsCtrl = TextEditingController();
  final _venueNameCtrl = TextEditingController();
  final _locationCtrl = TextEditingController();
  final _capacityCtrl = TextEditingController();
  final _venueDateCtrl = TextEditingController();
  final _venueStartTimeCtrl = TextEditingController();
  final _entryFeeCtrl = TextEditingController();
  final _prizePoolCtrl = TextEditingController();
  final _winnerPrizeCtrl = TextEditingController();
  final _runnerUpPrizeCtrl = TextEditingController();
  final _semiFinalistPrizeCtrl = TextEditingController();
  final _quarterFinalistPrizeCtrl = TextEditingController();
  final _batsmanMostRunsCtrl = TextEditingController();
  final _batsmanMoreFoursCtrl = TextEditingController();
  final _batsmanMoreSixesCtrl = TextEditingController();
  final _batsmanStrikeRateCtrl = TextEditingController();
  final _bowlerMostWicketsCtrl = TextEditingController();
  final _bowlerBestEconomyCtrl = TextEditingController();
  final _audiencePrizeCtrl = TextEditingController();

  // State
  bool _isPaid = true;
  bool _confirmReview = false;
  late String _selectedSport;
  _TournamentSport _selectedSportPreset = _TournamentSport.cricket;
  String _selectedFormat = 'Knockout';
  String _selectedBallType = 'Tennis Ball';
  int _miniOvers = 3;
  int _ballsPerOver = 3;
  int _playersPerTeam = 5;
  bool _isSubmitting = false;
  String? _submitError;
  final Map<String, String> _fieldErrors = {};
  static const _detailsFieldKeys = {
    'tournamentName',
    'tournamentStartDate',
    'registrationEndDate',
    'registrationEndTime',
    'matchDuration',
    'matchStartTime',
    'breakBetweenMatches',
    'lunchFrom',
    'lunchTo',
    'numberOfTeams',
  };
  static const _venueFieldKeys = {
    'venueName',
    'location',
    'capacity',
    'venueDate',
    'venueStartTime',
  };
  static const _budgetFieldKeys = {
    'entryFee',
    'prizePool',
    'winnerPrize',
    'runnerUpPrize',
    'semiFinalistPrize',
    'quarterFinalistPrize',
    'batsmanMostRuns',
    'batsmanMoreFours',
    'batsmanMoreSixes',
    'batsmanStrikeRate',
    'bowlerMostWickets',
    'bowlerBestEconomy',
    'audiencePrize',
  };

  int get _numberOfTeams => int.tryParse(_numberOfTeamsCtrl.text.trim()) ?? 0;

  bool get _hasValidTeamCount {
    final teams = _numberOfTeams;
    return teams >= 2 && teams <= 256 && _isPowerOfTwo(teams);
  }

  String get _bracketPreviewText {
    if (!_hasValidTeamCount) {
      return 'Enter 2, 4, 8, 16, 32, 64, 128, or 256 teams to generate the bracket.';
    }
    final stages = <String>[];
    var teams = _numberOfTeams;
    while (teams > 2) {
      stages.add(_roundLabelForTeams(teams));
      teams ~/= 2;
    }
    stages.add('Final');
    return stages.join(' → ');
  }

  bool _isPowerOfTwo(int value) => value > 0 && (value & (value - 1)) == 0;

  String _roundLabelForTeams(int teams) {
    if (teams == 2) return 'Final';
    if (teams == 4) return 'Semi Finals';
    if (teams == 8) return 'Quarter Finals';
    return '$teams Teams';
  }

  String _venueRoundLabelFor(int venueIndex) {
    if (!_hasValidTeamCount) return 'Round TBD';
    final teamsForRound = _teamsForVenueRound(venueIndex);
    return _roundLabelForTeams(teamsForRound);
  }

  String _venueMatchesLabelFor(int venueIndex) {
    if (!_hasValidTeamCount) return 'Matches TBD';
    final teamsForRound = _teamsForVenueRound(venueIndex);
    final matches = (teamsForRound / 2).ceil();
    return '$matches ${matches == 1 ? 'Match' : 'Matches'}';
  }

  int _teamsForVenueRound(int venueIndex) {
    var teams = _numberOfTeams;
    for (var index = 0; index < venueIndex && teams > 2; index++) {
      teams ~/= 2;
    }
    return teams < 2 ? 2 : teams;
  }

  final List<Map<String, dynamic>> _venues = [
    {'name': 'Venue 1'},
  ];

  @override
  void initState() {
    super.initState();
    _currentStep = widget.initialStep.clamp(0, _totalSteps - 1);
    _selectedSport = 'Mini Cricket - Super Over Challenge';
  }

  @override
  void dispose() {
    _tournamentNameCtrl.dispose();
    _tournamentStartDateCtrl.dispose();
    _registrationEndDateCtrl.dispose();
    _registrationEndTimeCtrl.dispose();
    _matchDurationCtrl.dispose();
    _matchStartTimeCtrl.dispose();
    _breakBetweenMatchesCtrl.dispose();
    _lunchFromCtrl.dispose();
    _lunchToCtrl.dispose();
    _numberOfTeamsCtrl.dispose();
    _venueNameCtrl.dispose();
    _locationCtrl.dispose();
    _capacityCtrl.dispose();
    _venueDateCtrl.dispose();
    _venueStartTimeCtrl.dispose();
    _entryFeeCtrl.dispose();
    _prizePoolCtrl.dispose();
    _winnerPrizeCtrl.dispose();
    _runnerUpPrizeCtrl.dispose();
    _semiFinalistPrizeCtrl.dispose();
    _quarterFinalistPrizeCtrl.dispose();
    _batsmanMostRunsCtrl.dispose();
    _batsmanMoreFoursCtrl.dispose();
    _batsmanMoreSixesCtrl.dispose();
    _batsmanStrikeRateCtrl.dispose();
    _bowlerMostWicketsCtrl.dispose();
    _bowlerBestEconomyCtrl.dispose();
    _audiencePrizeCtrl.dispose();
    super.dispose();
  }

  void _clearFieldError(String field) {
    if (!_fieldErrors.containsKey(field)) return;
    setState(() => _fieldErrors.remove(field));
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final scale = context.sportoScale;

    return SportoScreenShell(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: cs.onSurface),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('Create Tournament',
            style: tt.titleLarge?.copyWith(
                fontSize: 18 * scale,
                fontWeight: FontWeight.w500,
                color: cs.onSurface)),
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(4 * scale),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 18 * scale),
            child: Row(
              children: List.generate(
                  _totalSteps,
                  (i) => Expanded(
                        child: Container(
                          height: 3 * scale,
                          margin: EdgeInsets.only(
                              right: i == _totalSteps - 1 ? 0 : 4),
                          decoration: BoxDecoration(
                            color: i <= _currentStep
                                ? cs.tertiary
                                : cs.surfaceContainerHigh,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      )),
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        physics: const ClampingScrollPhysics(),
        padding:
            EdgeInsets.fromLTRB(20 * scale, 24 * scale, 20 * scale, 40 * scale),
        child: AnimatedSwitcher(
          key: Key('step_$_currentStep'),
          duration: const Duration(milliseconds: 300),
          child: _buildCurrentStep(cs),
        ),
      ),
    );
  }

  Widget _buildCurrentStep(ColorScheme cs) {
    switch (_currentStep) {
      case 0:
        return _buildStep1TypeSelection(cs);
      case 1:
        return _buildStep3Configuration(cs);
      case 2:
        return _buildStep2TournamentDetails(cs);
      case 3:
        return _buildStep4VenueSetup(cs);
      case 4:
        return _buildStep5BudgetRegistration(cs);
      case 5:
        return _buildStep6Review(cs);
      default:
        return const SizedBox.shrink();
    }
  }

  // ============================================================
  // STEP 1: CHOOSE TOURNAMENT TYPE
  // ============================================================
  Widget _buildStep1TypeSelection(ColorScheme cs) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Choose Tournament Type',
            style: TextStyle(
                color: cs.secondary,
                fontSize: 18,
                fontWeight: FontWeight.w500)),
        const SizedBox(height: 24),

        // Community Tournament Card
        SportoGradientCard(
          colors: const [Color(0xFF2A2035), Color(0xFF1A1520)],
          borderColor: cs.tertiary.withOpacity(0.3),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 18),
          radius: 16,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Community Tournament',
                  style: TextStyle(
                      color: cs.tertiary,
                      fontSize: 16,
                      fontWeight: FontWeight.w500)),
              const SizedBox(height: 10),
              Wrap(spacing: 24, runSpacing: 12, children: [
                SportoBulletPoint(text: 'Independent'),
                SportoBulletPoint(text: 'Custom Bracket Size'),
                SportoBulletPoint(text: 'You Manage Revenue'),
                SportoBulletPoint(text: 'Create Instantly'),
              ]),
              const SizedBox(height: 12),
              SizedBox(
                  width: double.infinity,
                  child: SportoPillButton(
                      label: 'Create Tournament',
                      color: cs.primary,
                      gradient: context.sporto.primaryGradient,
                      filled: true,
                      height: 48,
                      onTap: () => setState(() => _currentStep = 1))),
            ],
          ),
        ),
        const SizedBox(height: 20),

        // Mega Championship Card
        SportoGradientCard(
          colors: const [Color(0xFF152520), Color(0xFF101A15)],
          borderColor: cs.secondary.withOpacity(0.3),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 18),
          radius: 16,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Mega Championship',
                  style: TextStyle(
                      color: cs.secondary,
                      fontSize: 16,
                      fontWeight: FontWeight.w500)),
              const SizedBox(height: 10),
              Wrap(spacing: 24, runSpacing: 12, children: [
                SportoBulletPoint(text: 'Official Event'),
                SportoBulletPoint(text: 'Featured by Sporto'),
                SportoBulletPoint(text: 'Multi Venue'),
                SportoBulletPoint(text: 'Approval Required'),
              ]),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: SportoPillButton(
                  label: 'Request to Host',
                  color: cs.secondary,
                  filled: true,
                  height: 48,
                  onTap: () {},
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ============================================================
  // STEP 2: TOURNAMENT DETAILS
  // ============================================================
  Widget _buildStep2TournamentDetails(ColorScheme cs) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Tournament Details',
            style: TextStyle(
                color: cs.secondary,
                fontSize: 18,
                fontWeight: FontWeight.w500)),
        Text('Tell players about your tournament.',
            style: TextStyle(color: cs.onSurfaceVariant, fontSize: 13)),
        const SizedBox(height: 24),

        SportoTextField(
            label: 'Tournament Name',
            hint: 'e.g. hyderabad super over cup',
            controller: _tournamentNameCtrl,
            errorText: _fieldErrors['tournamentName'],
            onChanged: (_) => _clearFieldError('tournamentName')),
        const SizedBox(height: 20),
        SportoTextField(
            label: 'Tournament Start',
            hint: 'Select date',
            controller: _tournamentStartDateCtrl,
            readOnly: true,
            onTap: () => _pickDate(
                  controller: _tournamentStartDateCtrl,
                  fieldKey: 'tournamentStartDate',
                  helpText: 'Select tournament start',
                ),
            errorText: _fieldErrors['tournamentStartDate'],
            suffixIcon: SportoAssetIcon(SportoAssets.calendarTick,
                color: cs.onSurfaceVariant, size: 18)),
        const SizedBox(height: 20),

        Text('Registration Deadline',
            style: TextStyle(
                color: cs.onSurface,
                fontSize: 14,
                fontWeight: FontWeight.w500)),
        const SizedBox(height: 8),
        Row(children: [
          Expanded(
              child: SportoTextField(
                  hint: 'Select date',
                  controller: _registrationEndDateCtrl,
                  readOnly: true,
                  onTap: () => _pickDate(
                        controller: _registrationEndDateCtrl,
                        fieldKey: 'registrationEndDate',
                        helpText: 'Select registration deadline',
                      ),
                  errorText: _fieldErrors['registrationEndDate'],
                  suffixIcon: SportoAssetIcon(SportoAssets.calendarTick,
                      color: cs.onSurfaceVariant, size: 18))),
          const SizedBox(width: 12),
          Expanded(
              child: SportoTextField(
                  hint: 'Select time',
                  controller: _registrationEndTimeCtrl,
                  readOnly: true,
                  onTap: () => _pickTime(
                        controller: _registrationEndTimeCtrl,
                        fieldKey: 'registrationEndTime',
                        helpText: 'Select registration time',
                      ),
                  errorText: _fieldErrors['registrationEndTime'],
                  suffixIcon: Icon(Icons.access_time_outlined,
                      color: cs.onSurfaceVariant, size: 18))),
        ]),
        const SizedBox(height: 24),

        SportoSectionTitle(title: 'Match Configuration'),
        SportoCard(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Expanded(
                child: SportoTextField(
                    label: 'Match Duration (mins)',
                    hint: 'e.g. 30',
                    controller: _matchDurationCtrl,
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                    ],
                    errorText: _fieldErrors['matchDuration'],
                    onChanged: (_) => _clearFieldError('matchDuration'))),
            const SizedBox(width: 12),
            Expanded(
                child: SportoTextField(
                    label: 'Start Time',
                    hint: 'Select time',
                    controller: _matchStartTimeCtrl,
                    readOnly: true,
                    onTap: () => _pickTime(
                          controller: _matchStartTimeCtrl,
                          fieldKey: 'matchStartTime',
                          helpText: 'Select match start time',
                        ),
                    errorText: _fieldErrors['matchStartTime'],
                    suffixIcon: Icon(Icons.access_time_outlined,
                        color: cs.onSurfaceVariant, size: 18))),
          ]),
          const SizedBox(height: 16),
          SportoTextField(
              label: 'Break Between Matches (mins)',
              hint: 'e.g. 10',
              controller: _breakBetweenMatchesCtrl,
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
              ],
              errorText: _fieldErrors['breakBetweenMatches'],
              onChanged: (_) => _clearFieldError('breakBetweenMatches')),
          const SizedBox(height: 16),
          Text('Lunch Break',
              style: TextStyle(
                  color: cs.onSurface,
                  fontSize: 14,
                  fontWeight: FontWeight.w500)),
          const SizedBox(height: 8),
          Row(children: [
            Expanded(
                child: SportoTextField(
                    label: 'From',
                    hint: 'Select time',
                    controller: _lunchFromCtrl,
                    readOnly: true,
                    onTap: () => _pickTime(
                          controller: _lunchFromCtrl,
                          fieldKey: 'lunchFrom',
                          helpText: 'Select lunch start time',
                        ),
                    errorText: _fieldErrors['lunchFrom'],
                    suffixIcon: Icon(Icons.access_time_outlined,
                        color: cs.onSurfaceVariant, size: 18))),
            const SizedBox(width: 12),
            Expanded(
                child: SportoTextField(
                    label: 'To',
                    hint: 'Select time',
                    controller: _lunchToCtrl,
                    readOnly: true,
                    onTap: () => _pickTime(
                          controller: _lunchToCtrl,
                          fieldKey: 'lunchTo',
                          helpText: 'Select lunch end time',
                        ),
                    errorText: _fieldErrors['lunchTo'],
                    suffixIcon: Icon(Icons.access_time_outlined,
                        color: cs.onSurfaceVariant, size: 18))),
          ]),
        ])),
        const SizedBox(height: 24),

        // Number of Teams Stepper
        Text('Number of Teams',
            style: TextStyle(
                color: cs.onSurface,
                fontSize: 14,
                fontWeight: FontWeight.w500)),
        const SizedBox(height: 12),
        Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          SportoStepperButton(
              icon: Icons.remove,
              onPressed: () => setState(() {
                    final teams = _numberOfTeams;
                    if (teams > 2) {
                      _numberOfTeamsCtrl.text = (teams ~/ 2).toString();
                      _clearFieldError('numberOfTeams');
                    } else if (teams <= 0) {
                      _numberOfTeamsCtrl.text = '2';
                      _clearFieldError('numberOfTeams');
                    }
                  })),
          const SizedBox(width: 16),
          SizedBox(
            width: 260,
            child: SportoTextField(
              hint: 'e.g. 64',
              controller: _numberOfTeamsCtrl,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              errorText: _fieldErrors['numberOfTeams'],
              onChanged: (_) {
                _clearFieldError('numberOfTeams');
                setState(() {});
              },
            ),
          ),
          const SizedBox(width: 16),
          SportoStepperButton(
              icon: Icons.add,
              onPressed: () => setState(() {
                    final teams = _numberOfTeams;
                    if (teams <= 0) {
                      _numberOfTeamsCtrl.text = '2';
                      _clearFieldError('numberOfTeams');
                    } else if (teams < 256) {
                      _numberOfTeamsCtrl.text = (teams * 2).toString();
                      _clearFieldError('numberOfTeams');
                    }
                  })),
        ]),
        const SizedBox(height: 20),

        // Tournament Bracket Preview
        Container(
          decoration: BoxDecoration(
              color: cs.secondary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: cs.secondary.withOpacity(0.3))),
          padding: const EdgeInsets.all(16),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Tournament Bracket',
                style: TextStyle(
                    color: cs.secondary,
                    fontSize: 14,
                    fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            Text(_bracketPreviewText,
                style: TextStyle(
                    color: cs.onSurfaceVariant, fontSize: 12, height: 1.5)),
          ]),
        ),
        const SizedBox(height: 32),
        PrimaryButton(
            width: double.infinity,
            height: 56,
            label: 'Continue',
            onPressed: () {
              if (_validateTournamentDetailsFields()) {
                setState(() => _currentStep = 3);
              }
            }),
      ],
    );
  }

  // ============================================================
  // STEP 3: CREATE COMMUNITY TOURNAMENT (CONFIGURATION)
  // ============================================================
  Widget _buildStep3Configuration(ColorScheme cs) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Create Community Tournament',
            style: TextStyle(
                color: cs.secondary,
                fontSize: 18,
                fontWeight: FontWeight.w500)),
        const SizedBox(height: 24),

        // Choose Sport
        Text('Choose Sport',
            style: TextStyle(
                color: cs.onSurface,
                fontSize: 18,
                fontWeight: FontWeight.w400)),
        const SizedBox(height: 12),
        SportoSelectableBox(
          key: const Key('choose_sport'),
          selected: true,
          showCheck: true,
          onTap: _showSportSelector,
          height: 46,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          child: Text(_selectedSport,
              style: TextStyle(
                  color: cs.secondary,
                  fontSize: 14,
                  fontWeight: FontWeight.w500)),
        ),
        const SizedBox(height: 24),

        // Tournament Format
        Text('Tournament Format',
            style: TextStyle(color: cs.onSurface, fontSize: 18)),
        const SizedBox(height: 18),
        Row(children: [
          Expanded(
              child: _FormatCard(
                  label: 'Knockout',
                  points: [
                    'Single elimination.',
                    'Fastest tournament.',
                    'Winner advances.'
                  ],
                  active: _selectedFormat == 'Knockout',
                  onTap: () => setState(() => _selectedFormat = 'Knockout'))),
          const SizedBox(width: 12),
          Expanded(
              child: _FormatCard(
                  label: 'League + Knockout',
                  points: [
                    'League stage first.',
                    'Top teams qualify.',
                    'Best for larger tournaments.'
                  ],
                  active: _selectedFormat == 'League + Knockout',
                  onTap: () =>
                      setState(() => _selectedFormat = 'League + Knockout'))),
        ]),
        const SizedBox(height: 24),

        // Match Settings
        Text('Match Settings',
            style: TextStyle(color: cs.onSurface, fontSize: 18)),
        const SizedBox(height: 20),
        if (_selectedSportPreset == _TournamentSport.cricket) ...[
          Text('Ball type',
              style: TextStyle(
                  color: cs.onSurface,
                  fontSize: 14,
                  fontWeight: FontWeight.w500)),
          const SizedBox(height: 12),
          Wrap(spacing: 8, runSpacing: 8, children: [
            SportoFilterChip(
                type: SportoFilterChipType.pill,
                inactiveFill: true,
                label: 'Tennis Ball',
                active: _selectedBallType == 'Tennis Ball',
                hasCheck: true,
                onTap: () => setState(() => _selectedBallType = 'Tennis Ball')),
            SportoFilterChip(
                type: SportoFilterChipType.pill,
                inactiveFill: true,
                label: 'Leather Ball',
                hasCheck: true,
                active: _selectedBallType == 'Leather Ball',
                onTap: () =>
                    setState(() => _selectedBallType = 'Leather Ball')),
            SportoFilterChip(
                type: SportoFilterChipType.pill,
                inactiveFill: true,
                label: 'Rubber Ball',
                hasCheck: true,
                active: _selectedBallType == 'Rubber Ball',
                onTap: () => setState(() => _selectedBallType = 'Rubber Ball')),
            SportoFilterChip(
                type: SportoFilterChipType.pill,
                inactiveFill: true,
                label: 'Wind Ball',
                hasCheck: true,
                active: _selectedBallType == 'Wind Ball',
                onTap: () => setState(() => _selectedBallType = 'Wind Ball')),
          ]),
          const SizedBox(height: 24),
        ],

        // Mini Overs Per Innings
        SportoCounterRow(
            label: switch (_selectedSportPreset) {
              _TournamentSport.cricket => 'Mini Overs Per Innings',
              _TournamentSport.badminton => 'No. of Points per set',
              _TournamentSport.football => 'No. of Goals per round',
            },
            value: _selectedSportPreset == _TournamentSport.cricket
                ? '$_miniOvers Overs'
                : '$_miniOvers',
            onMinus: () => setState(() {
                  if (_miniOvers > 1) _miniOvers--;
                }),
            onPlus: () => setState(() => _miniOvers++)),
        const SizedBox(height: 16),

        // Balls Per Over
        SportoCounterRow(
            label: switch (_selectedSportPreset) {
              _TournamentSport.cricket => 'Balls Per Over',
              _TournamentSport.badminton => 'No. of Sets',
              _TournamentSport.football => 'No. of Rounds',
            },
            value: _selectedSportPreset == _TournamentSport.cricket
                ? '$_ballsPerOver Balls'
                : '$_ballsPerOver',
            onMinus: () => setState(() {
                  if (_ballsPerOver > 1) _ballsPerOver--;
                }),
            onPlus: () => setState(() => _ballsPerOver++)),
        const SizedBox(height: 16),

        // Players Per Team
        SportoCounterRow(
            label: 'Players Per Team',
            value: '$_playersPerTeam Players',
            onMinus: () => setState(() {
                  if (_playersPerTeam > 1) _playersPerTeam--;
                }),
            onPlus: () => setState(() => _playersPerTeam++)),
        const SizedBox(height: 32),

        Align(
          alignment: Alignment.center,
          child: PrimaryButton(
              width: 270 * context.sportoScale,
              height: 48 * context.sportoScale,
              label: 'Continue',
              onPressed: () => setState(() => _currentStep = 2)),
        ),
      ],
    );
  }

  Widget _FormatCard(
      {required String label,
      required List<String> points,
      required bool active,
      required VoidCallback onTap}) {
    return Builder(builder: (context) {
      final cs = Theme.of(context).colorScheme;
      return SportoSelectableBox(
        selected: active,
        onTap: onTap,
        padding: const EdgeInsets.all(14),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(label,
              style: TextStyle(
                  color: active ? cs.secondary : cs.onSurface,
                  fontSize: 14,
                  fontWeight: FontWeight.w500)),
          const SizedBox(height: 8),
          ...points.map((p) => Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child:
                  Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('• ',
                    style: TextStyle(color: cs.onSurfaceVariant, fontSize: 12)),
                Expanded(
                    child: Text(p,
                        style: TextStyle(
                            color: cs.onSurfaceVariant, fontSize: 11)))
              ]))),
        ]),
      );
    });
  }

  void _showSportSelector() {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        final theme = Theme.of(sheetContext);
        final options = <(_TournamentSport, String)>[
          (_TournamentSport.cricket, 'Mini Cricket - Super Over Challenge'),
          (_TournamentSport.badminton, 'Badminton - Challenge'),
          (
            _TournamentSport.football,
            'Mini Football - Goal Shootout Challenge'
          ),
        ];
        return Container(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
          decoration: BoxDecoration(
            color: sheetContext.sporto.cardElevated,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            border: Border(top: BorderSide(color: sheetContext.sporto.border)),
          ),
          child: SafeArea(
            top: false,
            child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Choose Sport',
                      style: theme.textTheme.titleLarge?.copyWith(
                          fontSize: 18, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 16),
                  for (final option in options) ...[
                    SportoSelectableBox(
                      key: Key('sport_${option.$1.name}'),
                      selected: _selectedSportPreset == option.$1,
                      showCheck: true,
                      height: 56,
                      onTap: () {
                        setState(() {
                          _selectedSportPreset = option.$1;
                          _selectedSport = option.$2;
                          _miniOvers = 3;
                          _ballsPerOver = 3;
                          _playersPerTeam =
                              option.$1 == _TournamentSport.badminton ? 2 : 5;
                        });
                        Navigator.pop(sheetContext);
                      },
                      child: Text(option.$2,
                          style: theme.textTheme.bodyLarge?.copyWith(
                            fontWeight: FontWeight.w500,
                            color: _selectedSportPreset == option.$1
                                ? theme.colorScheme.secondary
                                : theme.colorScheme.onSurface,
                          )),
                    ),
                    const SizedBox(height: 10),
                  ],
                ]),
          ),
        );
      },
    );
  }

  // ============================================================
  // STEP 4: VENUE SETUP & SCHEDULE
  // ============================================================
  Widget _buildStep4VenueSetup(ColorScheme cs) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SportoSectionTitle(
            title: 'Venue Setup & Schedule',
            subtitle: 'Where will the tournament be played?'),
        const SizedBox(height: 16),

        // Tournament Bracket Card
        Container(
          decoration: BoxDecoration(
              color: cs.secondary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: cs.secondary.withOpacity(0.3))),
          padding: const EdgeInsets.all(16),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Tournament Bracket',
                style: TextStyle(
                    color: cs.secondary,
                    fontSize: 14,
                    fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            Text(_bracketPreviewText,
                style: TextStyle(
                    color: cs.onSurfaceVariant, fontSize: 12, height: 1.5)),
          ]),
        ),
        const SizedBox(height: 24),

        // Tournament Format Section
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Tournament Format',
                style: TextStyle(
                    color: cs.onSurface,
                    fontSize: 16,
                    fontWeight: FontWeight.w600)),
            Text('Single Venue',
                style: TextStyle(color: cs.secondary, fontSize: 13)),
          ]),
          TextButton(
              onPressed: () {},
              child: Text('Change Venue ∨',
                  style: TextStyle(color: cs.onTertiary, fontSize: 13))),
        ]),
        const SizedBox(height: 16),

        // Venue List
        ..._venues.asMap().entries.map((entry) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: SportoCard(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                  Text(entry.value['name'],
                      style: TextStyle(
                          color: cs.onTertiary,
                          fontSize: 16,
                          fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),
                  Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(_venueRoundLabelFor(entry.key),
                                  style: TextStyle(
                                      color: cs.onSurface,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500)),
                              Text(_venueMatchesLabelFor(entry.key),
                                  style: TextStyle(
                                      color: cs.onSurfaceVariant,
                                      fontSize: 12)),
                            ]),
                        TextButton(
                            key: const Key('add_venue_details'),
                            onPressed: () => _showVenueModal(
                                context, entry.value['name'].toString()),
                            child:
                                Row(mainAxisSize: MainAxisSize.min, children: [
                              Text('Add Venue Details',
                                  style: TextStyle(
                                      color: cs.tertiary,
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600)),
                              const SizedBox(width: 5),
                              Icon(Icons.arrow_forward_ios_rounded,
                                  color: cs.tertiary, size: 13),
                            ])),
                      ]),
                ])))),

        // Add Another Venue Button
        Align(
          alignment: Alignment.centerRight,
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {
                final venueName = 'Venue ${_venues.length + 1}';
                setState(() {
                  _venues.add({
                    'name': venueName,
                  });
                });
                _showVenueModal(context, venueName);
              },
              borderRadius: BorderRadius.circular(20),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                    border: Border.all(
                        color: cs.onTertiary.withOpacity(0.5),
                        style: BorderStyle.solid),
                    borderRadius: BorderRadius.circular(20)),
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  Icon(Icons.add, color: cs.onTertiary, size: 16),
                  const SizedBox(width: 4),
                  Text('Add another venue',
                      style: TextStyle(color: cs.onTertiary, fontSize: 12))
                ]),
              ),
            ),
          ),
        ),
        const SizedBox(height: 32),
        PrimaryButton(
            width: double.infinity,
            height: 56,
            label: 'Continue',
            onPressed: () {
              if (_validateVenueFields()) {
                setState(() => _currentStep = 4);
              }
            }),
      ],
    );
  }

  // VENUE MODAL
  void _showVenueModal(BuildContext context, String venueName) {
    final cs = Theme.of(context).colorScheme;
    showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (ctx) => StatefulBuilder(
            builder: (ctx, sheetSetState) => DraggableScrollableSheet(
                  initialChildSize: 0.9,
                  minChildSize: 0.5,
                  maxChildSize: 0.95,
                  builder: (_, controller) => Container(
                    decoration: BoxDecoration(
                        color: const Color(0xFF121418),
                        borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(24))),
                    padding: const EdgeInsets.all(24),
                    child: SingleChildScrollView(
                      controller: controller,
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(venueName,
                                            style: TextStyle(
                                                color: cs.onTertiary,
                                                fontSize: 20,
                                                fontWeight: FontWeight.w600)),
                                        Text(
                                            '${_venueRoundLabelFor(0)} • ${_venueMatchesLabelFor(0)}',
                                            style: TextStyle(
                                                color: cs.onSurfaceVariant,
                                                fontSize: 13)),
                                      ]),
                                  IconButton(
                                      icon: Icon(Icons.close_rounded,
                                          color: cs.onSurface),
                                      onPressed: () => Navigator.pop(ctx)),
                                ]),
                            const SizedBox(height: 24),
                            SportoTextField(
                                label: 'Venue Name',
                                hint: 'e.g. hyderabad ground',
                                controller: _venueNameCtrl,
                                errorText: _fieldErrors['venueName'],
                                onChanged: (_) {
                                  _clearFieldError('venueName');
                                  sheetSetState(() {});
                                }),
                            const SizedBox(height: 20),
                            SportoTextField(
                                label: 'Location',
                                hint: 'e.g. Kondapur, hyderabad',
                                controller: _locationCtrl,
                                errorText: _fieldErrors['location'],
                                onChanged: (_) {
                                  _clearFieldError('location');
                                  sheetSetState(() {});
                                }),
                            const SizedBox(height: 20),
                            SportoTextField(
                                label: 'Daily Match Capacity',
                                hint: 'e.g. 20',
                                controller: _capacityCtrl,
                                keyboardType: TextInputType.number,
                                inputFormatters: [
                                  FilteringTextInputFormatter.digitsOnly,
                                ],
                                errorText: _fieldErrors['capacity'],
                                onChanged: (_) {
                                  _clearFieldError('capacity');
                                  sheetSetState(() {});
                                }),
                            const SizedBox(height: 20),
                            Text('Ground Type',
                                style: TextStyle(
                                    color: cs.onSurface,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500)),
                            const SizedBox(height: 12),
                            Row(children: [
                              SportoFilterChip(
                                  type: SportoFilterChipType.pill,
                                  inactiveFill: true,
                                  label: 'Indoor',
                                  active: true,
                                  hasCheck: true,
                                  onTap: () {}),
                              const SizedBox(width: 12),
                              SportoFilterChip(
                                  type: SportoFilterChipType.pill,
                                  inactiveFill: true,
                                  label: 'Outdoor',
                                  active: false,
                                  onTap: () {}),
                            ]),
                            const SizedBox(height: 20),
                            Row(children: [
                              Expanded(
                                  child: SportoTextField(
                                      label: 'Date',
                                      hint: 'Select date',
                                      controller: _venueDateCtrl,
                                      readOnly: true,
                                      onTap: () async {
                                        await _pickDate(
                                          controller: _venueDateCtrl,
                                          fieldKey: 'venueDate',
                                          helpText: 'Select venue date',
                                        );
                                        sheetSetState(() {});
                                      },
                                      errorText: _fieldErrors['venueDate'],
                                      onChanged: (_) {
                                        _clearFieldError('venueDate');
                                        sheetSetState(() {});
                                      })),
                              const SizedBox(width: 12),
                              Expanded(
                                  child: SportoTextField(
                                      label: 'Start Time',
                                      hint: 'Select time',
                                      controller: _venueStartTimeCtrl,
                                      readOnly: true,
                                      onTap: () async {
                                        await _pickTime(
                                          controller: _venueStartTimeCtrl,
                                          fieldKey: 'venueStartTime',
                                          helpText: 'Select venue start time',
                                        );
                                        sheetSetState(() {});
                                      },
                                      errorText: _fieldErrors['venueStartTime'],
                                      onChanged: (_) {
                                        _clearFieldError('venueStartTime');
                                        sheetSetState(() {});
                                      })),
                            ]),
                            const SizedBox(height: 32),
                            Row(
                              children: [
                                Expanded(
                                    child: SecondaryButton(
                                        label: 'Save',
                                        onPressed: () {
                                          if (_validateVenueFields()) {
                                            Navigator.pop(ctx);
                                          } else {
                                            sheetSetState(() {});
                                          }
                                        })),
                                const SizedBox(width: 12),
                                Expanded(
                                  flex: 2,
                                  child: PrimaryButton(
                                      width: double.infinity,
                                      height: 56,
                                      label: 'Save & Add Next',
                                      onPressed: () {
                                        if (_validateVenueFields()) {
                                          Navigator.pop(ctx);
                                        } else {
                                          sheetSetState(() {});
                                        }
                                      }),
                                ),
                              ],
                            ),
                          ]),
                    ),
                  ),
                )));
  }

  // ============================================================
  // STEP 5: BUDGET & REGISTRATION
  // ============================================================
  Widget _buildStep5BudgetRegistration(ColorScheme cs) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SportoSectionTitle(
            title: 'Budget & Registration',
            subtitle: 'Set entry fees, prize money and registration details.'),

        // Registration Type
        Row(children: [
          Expanded(
              child: RadioListTile<bool>(
                  title: Text('Paid', style: TextStyle(color: cs.secondary)),
                  value: true,
                  groupValue: _isPaid,
                  onChanged: (v) => setState(() => _isPaid = v!),
                  activeColor: cs.secondary,
                  contentPadding: EdgeInsets.zero)),
          Expanded(
              child: RadioListTile<bool>(
                  title: Text('Free',
                      style: TextStyle(color: cs.onSurfaceVariant)),
                  value: false,
                  groupValue: _isPaid,
                  onChanged: (v) => setState(() => _isPaid = v!),
                  activeColor: cs.secondary,
                  contentPadding: EdgeInsets.zero)),
        ]),
        if (_isPaid) ...[
          const SizedBox(height: 8),
          SportoTextField(
              label: 'Entry Fee Per Team',
              hint: 'e.g. ₹400',
              controller: _entryFeeCtrl,
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
              ],
              errorText: _fieldErrors['entryFee'],
              onChanged: (_) => _clearFieldError('entryFee')),
        ],
        const SizedBox(height: 24),

        // Prize Pool Section
        SportoSectionTitle(title: 'Prize Pool'),
        SportoCard(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Teams',
              style: TextStyle(
                  color: cs.secondary,
                  fontSize: 14,
                  fontWeight: FontWeight.w600)),
          const SizedBox(height: 12),
          SportoTextField(
              label: 'Total Prize Money',
              hint: 'e.g. ₹20,000',
              controller: _prizePoolCtrl,
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
              ],
              errorText: _fieldErrors['prizePool'],
              onChanged: (_) => _clearFieldError('prizePool')),
          const SizedBox(height: 16),
          Row(children: [
            Expanded(
                child: SportoTextField(
                    label: 'Winner Prize',
                    hint: 'e.g. ₹15,000',
                    controller: _winnerPrizeCtrl,
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                    ],
                    errorText: _fieldErrors['winnerPrize'],
                    onChanged: (_) => _clearFieldError('winnerPrize'))),
            const SizedBox(width: 12),
            Expanded(
                child: SportoTextField(
                    label: 'Runner-up Prize',
                    hint: 'e.g. ₹5,000',
                    controller: _runnerUpPrizeCtrl,
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                    ],
                    errorText: _fieldErrors['runnerUpPrize'],
                    onChanged: (_) => _clearFieldError('runnerUpPrize')))
          ]),
          const SizedBox(height: 16),
          Row(children: [
            Expanded(
                child: SportoTextField(
                    label: 'Semi-finalists',
                    hint: 'e.g. ₹15,000',
                    controller: _semiFinalistPrizeCtrl,
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                    ],
                    errorText: _fieldErrors['semiFinalistPrize'],
                    onChanged: (_) => _clearFieldError('semiFinalistPrize'))),
            const SizedBox(width: 12),
            Expanded(
                child: SportoTextField(
                    label: 'Quarter-finalists',
                    hint: 'e.g. ₹5,000',
                    controller: _quarterFinalistPrizeCtrl,
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                    ],
                    errorText: _fieldErrors['quarterFinalistPrize'],
                    onChanged: (_) => _clearFieldError('quarterFinalistPrize')))
          ]),
        ])),
        const SizedBox(height: 16),

        // Player Awards
        SportoCard(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Player',
              style: TextStyle(
                  color: cs.secondary,
                  fontSize: 14,
                  fontWeight: FontWeight.w600)),
          const SizedBox(height: 12),
          SportoTextField(
              label: 'Batsman - Most Runs',
              hint: 'e.g. ₹20,000',
              controller: _batsmanMostRunsCtrl,
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
              ],
              errorText: _fieldErrors['batsmanMostRuns'],
              onChanged: (_) => _clearFieldError('batsmanMostRuns')),
          const SizedBox(height: 16),
          Row(children: [
            Expanded(
                child: SportoTextField(
                    label: 'Batsman - More 4\'s',
                    hint: 'e.g. ₹20,000',
                    controller: _batsmanMoreFoursCtrl,
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                    ],
                    errorText: _fieldErrors['batsmanMoreFours'],
                    onChanged: (_) => _clearFieldError('batsmanMoreFours'))),
            const SizedBox(width: 12),
            Expanded(
                child: SportoTextField(
                    label: 'Batsman - More 6\'s',
                    hint: 'e.g. ₹20,000',
                    controller: _batsmanMoreSixesCtrl,
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                    ],
                    errorText: _fieldErrors['batsmanMoreSixes'],
                    onChanged: (_) => _clearFieldError('batsmanMoreSixes')))
          ]),
          const SizedBox(height: 16),
          SportoTextField(
              label: 'Batsman - Highest Strike Rate',
              hint: 'e.g. ₹20,000',
              controller: _batsmanStrikeRateCtrl,
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
              ],
              errorText: _fieldErrors['batsmanStrikeRate'],
              onChanged: (_) => _clearFieldError('batsmanStrikeRate')),
        ])),
        const SizedBox(height: 16),

        // Bowler Awards
        SportoCard(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Bowler',
              style: TextStyle(
                  color: cs.secondary,
                  fontSize: 14,
                  fontWeight: FontWeight.w600)),
          const SizedBox(height: 12),
          SportoTextField(
              label: 'Bowler - Most Wickets',
              hint: 'e.g. ₹20,000',
              controller: _bowlerMostWicketsCtrl,
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
              ],
              errorText: _fieldErrors['bowlerMostWickets'],
              onChanged: (_) => _clearFieldError('bowlerMostWickets')),
          const SizedBox(height: 16),
          SportoTextField(
              label: 'Bowler Best Economy',
              hint: 'e.g. ₹20,000',
              controller: _bowlerBestEconomyCtrl,
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
              ],
              errorText: _fieldErrors['bowlerBestEconomy'],
              onChanged: (_) => _clearFieldError('bowlerBestEconomy')),
        ])),
        const SizedBox(height: 16),

        // Audience Leaderboard
        SportoCard(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Audience Leaderboard',
              style: TextStyle(
                  color: cs.secondary,
                  fontSize: 14,
                  fontWeight: FontWeight.w600)),
          const SizedBox(height: 12),
          SportoTextField(
              label: 'Prize 1',
              hint: 'e.g. ₹20,000',
              controller: _audiencePrizeCtrl,
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
              ],
              errorText: _fieldErrors['audiencePrize'],
              onChanged: (_) => _clearFieldError('audiencePrize')),
          const SizedBox(height: 12),
          Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                  onPressed: () {},
                  icon: Icon(Icons.add, color: cs.onTertiary),
                  label: Text('Add more',
                      style: TextStyle(color: cs.onTertiary)))),
        ])),
        const SizedBox(height: 16),

        // Your Earnings Summary
        SportoCard(
            backgroundColor: cs.secondary.withOpacity(0.05),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Your Earnings',
                  style: TextStyle(
                      color: cs.secondary,
                      fontSize: 14,
                      fontWeight: FontWeight.w600)),
              const SizedBox(height: 12),
              SportoSummaryRow(
                  label: 'Estimated Collection',
                  value: 'Rs $_estimatedCollection'),
              SportoSummaryRow(
                  label: 'Prize Money', value: '-Rs $_totalPrizeMoney'),
              SportoSummaryRow(
                  label: 'Platform Fee', value: 'Rs $_platformFee'),
              const SportoDivider(height: 24),
              SportoSummaryRow(
                  label: 'Net Earnings',
                  value: 'Rs $_netEarnings',
                  highlight: true),
            ])),
        const SizedBox(height: 32),
        PrimaryButton(
            width: double.infinity,
            height: 56,
            label: 'Continue',
            onPressed: () {
              if (_validateBudgetFields()) {
                setState(() => _currentStep = 5);
              }
            }),
      ],
    );
  }

  // ============================================================
  // STEP 6: REVIEW YOUR TOURNAMENT
  // ============================================================
  Widget _buildStep6Review(ColorScheme cs) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SportoSectionTitle(
            title: 'Review Your Tournament',
            subtitle: 'Review all details before submitting for approval.'),
        const SizedBox(height: 16),

        // Header Card
        SportoGradientCard(
          colors: const [Color(0xFF2A2035), Color(0xFF1A1520)],
          borderColor: cs.tertiary.withOpacity(0.3),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Community Tournament',
                style: TextStyle(
                    color: cs.tertiary,
                    fontSize: 12,
                    fontWeight: FontWeight.w600)),
            const SizedBox(height: 4),
            Text(_tournamentNameCtrl.text.trim(),
                style: TextStyle(
                    color: cs.onSurface,
                    fontSize: 20,
                    fontWeight: FontWeight.w600)),
            const SizedBox(height: 16),
            Row(children: [
              SportoAssetIcon(SportoAssets.locationPin,
                  color: cs.secondary, size: 16),
              const SizedBox(width: 4),
              Text(_venueNameCtrl.text.trim(),
                  style: TextStyle(color: cs.secondary, fontSize: 14))
            ]),
            const SizedBox(height: 4),
            Text(_venueDateCtrl.text.trim(),
                style: TextStyle(color: cs.onSurfaceVariant, fontSize: 13)),
          ]),
        ),
        const SizedBox(height: 16),

        // Tournament Details Card
        SportoCard(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text('Tournament Details',
                style: TextStyle(color: cs.onSurfaceVariant, fontSize: 13)),
            TextButton(
                onPressed: () => setState(() => _currentStep = 2),
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  Text('Edit',
                      style: TextStyle(
                          color: cs.tertiary,
                          fontSize: 12,
                          fontWeight: FontWeight.w600)),
                  const SizedBox(width: 4),
                  Icon(Icons.arrow_forward_ios_rounded,
                      color: cs.tertiary, size: 11),
                ]))
          ]),
          const SizedBox(height: 12),
          Text('$_selectedFormat Format',
              style: TextStyle(
                  color: cs.onSurface,
                  fontSize: 14,
                  fontWeight: FontWeight.w500)),
          Text(
              '$_selectedBallType - $_miniOvers overs - $_ballsPerOver balls/over - $_playersPerTeam players - ${_matchDurationCtrl.text.trim()} mins match - ${_breakBetweenMatchesCtrl.text.trim()} mins break',
              style: TextStyle(
                  color: cs.onSurfaceVariant, fontSize: 12, height: 1.5)),
          const SizedBox(height: 12),
          const SportoDivider(height: 1),
          const SizedBox(height: 12),
          SportoSummaryRow(
              label: 'Maximum Teams', value: '$_numberOfTeams Teams'),
          SportoSummaryRow(
              label: 'Registration Fee',
              value: _isPaid ? 'Rs ${_entryFeeCtrl.text.trim()}' : 'Free'),
        ])),
        const SizedBox(height: 16),

        // Venue & Schedule Card
        SportoCard(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text('Venue & Schedule (1 Venue)',
                style: TextStyle(color: cs.onSurfaceVariant, fontSize: 13)),
            TextButton(
                onPressed: () => setState(() => _currentStep = 3),
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  Text('Edit',
                      style: TextStyle(
                          color: cs.tertiary,
                          fontSize: 12,
                          fontWeight: FontWeight.w600)),
                  const SizedBox(width: 4),
                  Icon(Icons.arrow_forward_ios_rounded,
                      color: cs.tertiary, size: 11),
                ]))
          ]),
          const SizedBox(height: 12),
          SportoSummaryRow(label: 'Location', value: _locationCtrl.text.trim()),
          SportoSummaryRow(
              label: 'Daily Match Capacity', value: _capacityCtrl.text.trim()),
          SportoSummaryRow(
              label: 'Max Duration',
              value: '${_matchDurationCtrl.text.trim()} mins'),
          SportoSummaryRow(
              label: 'Tournament Date', value: _venueDateCtrl.text.trim()),
          SportoSummaryRow(
              label: 'Start Time', value: _venueStartTimeCtrl.text.trim()),
        ])),
        const SizedBox(height: 16),

        // Financial Summary Card
        SportoCard(
            backgroundColor: cs.secondary.withOpacity(0.05),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Financial Summary',
                  style: TextStyle(
                      color: cs.secondary,
                      fontSize: 14,
                      fontWeight: FontWeight.w600)),
              const SizedBox(height: 12),
              SportoSummaryRow(
                  label: 'Estimated Collection',
                  value: 'Rs $_estimatedCollection'),
              SportoSummaryRow(
                  label: 'Prize Money', value: '-Rs $_totalPrizeMoney'),
              SportoSummaryRow(
                  label: 'Platform Fee', value: 'Rs $_platformFee'),
              const SportoDivider(height: 24),
              SportoSummaryRow(
                  label: 'Net Earnings',
                  value: 'Rs $_netEarnings',
                  highlight: true),
            ])),
        const SizedBox(height: 24),

        // Confirmation Checkbox
        GestureDetector(
          onTap: () => setState(() => _confirmReview = !_confirmReview),
          child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                    color: _confirmReview ? cs.secondary : Colors.transparent,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                        color: _confirmReview
                            ? cs.secondary
                            : cs.onSurfaceVariant)),
                alignment: Alignment.center,
                child: _confirmReview
                    ? Icon(Icons.check, color: Colors.black, size: 16)
                    : null),
            const SizedBox(width: 12),
            Expanded(
                child: Text(
                    'I confirm that all tournament information is correct and I agree to Sporto\'s Partner Guidelines.',
                    style: TextStyle(
                        color: cs.onSurfaceVariant,
                        fontSize: 13,
                        height: 1.4))),
          ]),
        ),
        const SizedBox(height: 32),

        // Action Buttons
        Row(children: [
          Expanded(
              child: SecondaryButton(
                  label: 'Back',
                  onPressed: () => setState(() => _currentStep = 4))),
          const SizedBox(width: 12),
          Expanded(
              flex: 2,
              child: PrimaryButton(
                  width: double.infinity,
                  height: 56,
                  label: 'Submit for Approval',
                  loading: _isSubmitting,
                  disabled: !_confirmReview || _isSubmitting,
                  onPressed: _submitTournament)),
        ]),
        if (_submitError != null) ...[
          const SizedBox(height: 12),
          Text(
            _submitError!,
            textAlign: TextAlign.center,
            style: TextStyle(color: cs.error, fontSize: 13),
          ),
        ],
      ],
    );
  }

  Future<void> _submitTournament() async {
    if (!_confirmReview || _isSubmitting) return;
    final validationError = _validateTournamentSubmission();
    if (validationError != null) {
      setState(() => _submitError = validationError);
      return;
    }

    setState(() {
      _isSubmitting = true;
      _submitError = null;
    });

    final remoteDataSource = PartnerRemoteDataSource(
      apiClient: SportoApiClient(tokenProvider: AuthSessionStore().getToken),
    );

    try {
      final draft = await remoteDataSource.storeTournamentDraftData(
        TournamentDraftRequest(
          sportId: _sportId,
          sportFormatId: _sportFormatId,
          tournamentTypeId: _tournamentTypeId,
        ),
      );

      await remoteDataSource.updateTournamentDetailsData(
        draft.id,
        TournamentDetailsRequest(
          name: _tournamentNameCtrl.text.trim(),
          registrationEndAt:
              '${_registrationEndDateCtrl.text.trim()} ${_registrationEndTimeCtrl.text.trim()}:00',
        ),
      );

      await remoteDataSource.updateTournamentRulesData(
        draft.id,
        TournamentRuleRequest(
          rules: [
            TournamentRuleValueRequest(
              sportRuleFieldId: 1,
              value: _selectedSportPreset == _TournamentSport.cricket
                  ? _miniOvers.toString()
                  : _playersPerTeam.toString(),
            ),
          ],
        ),
      );

      await remoteDataSource.storeTournamentVenueData(
        draft.id,
        TournamentVenueRequest(
          venueId: 1,
          venueName: _venueNameCtrl.text.trim().isEmpty
              ? 'Main Ground'
              : _venueNameCtrl.text.trim(),
          notes: _locationCtrl.text.trim(),
          location: _locationCtrl.text.trim(),
          dailyMatchCapacity: int.tryParse(_capacityCtrl.text.trim()),
          groundType: 'turf',
          date: _venueDateCtrl.text.trim(),
          startTime: _venueStartTimeCtrl.text.trim(),
          roundName: _venueRoundLabelFor(0),
        ),
      );

      await remoteDataSource.updateTournamentBudgetData(
        draft.id,
        TournamentBudgetRequest(
          registrationFee: int.tryParse(_entryFeeCtrl.text.trim()) ?? 0,
          currency: 'INR',
          prizes: [
            TournamentPrizeRequest(
              title: 'Winner',
              amount: int.tryParse(_winnerPrizeCtrl.text.trim()) ?? 0,
              category: 'winner',
            ),
          ],
          sponsors: const [],
        ),
      );

      await remoteDataSource.reviewTournament(draft.id);
      final submitted = await remoteDataSource.submitTournamentData(
        draft.id,
        const TournamentSubmitRequest(confirmation: true),
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Tournament ${submitted.workflowStatus.label.toLowerCase()} successfully.',
          ),
        ),
      );
      Navigator.pop(context);
    } catch (error) {
      if (!mounted) return;
      setState(() => _submitError = _readableSubmitError(error));
    } finally {
      if (!mounted) return;
      setState(() => _isSubmitting = false);
    }
  }

  String? _validateTournamentSubmission() {
    final detailsValid = _validateTournamentDetailsFields();
    final venueValid = _validateVenueFields();
    final budgetValid = _validateBudgetFields();
    if (!detailsValid)
      return 'Please fix tournament details before submitting.';
    if (!venueValid) return 'Please fix venue details before submitting.';
    if (!budgetValid) return 'Please fix budget details before submitting.';
    return null;
  }

  bool _validateTournamentDetailsFields() {
    final errors = <String, String>{};
    final name = _tournamentNameCtrl.text.trim();
    if (name.isEmpty) {
      errors['tournamentName'] = 'Tournament name is required.';
    } else if (name.length < 3) {
      errors['tournamentName'] =
          'Tournament name must be at least 3 characters.';
    } else if (name.length > 80) {
      errors['tournamentName'] =
          'Tournament name cannot be more than 80 characters.';
    } else if (!RegExp(r'[A-Za-z]').hasMatch(name)) {
      errors['tournamentName'] = 'Tournament name must include letters.';
    }

    _validateDateField(
      errors,
      'tournamentStartDate',
      _tournamentStartDateCtrl.text.trim(),
      'Tournament start date',
    );
    _validateDateField(
      errors,
      'registrationEndDate',
      _registrationEndDateCtrl.text.trim(),
      'Registration deadline date',
    );
    _validateTimeField(
      errors,
      'registrationEndTime',
      _registrationEndTimeCtrl.text.trim(),
      'Registration deadline time',
    );
    _validateNumberField(
      errors,
      'matchDuration',
      _matchDurationCtrl.text.trim(),
      'Match duration',
      min: 1,
      max: 600,
    );
    _validateTimeField(
      errors,
      'matchStartTime',
      _matchStartTimeCtrl.text.trim(),
      'Start time',
    );
    _validateNumberField(
      errors,
      'breakBetweenMatches',
      _breakBetweenMatchesCtrl.text.trim(),
      'Break between matches',
      min: 0,
      max: 240,
    );
    _validateTimeField(
      errors,
      'lunchFrom',
      _lunchFromCtrl.text.trim(),
      'Lunch from time',
    );
    _validateTimeField(
      errors,
      'lunchTo',
      _lunchToCtrl.text.trim(),
      'Lunch to time',
    );
    final teamsText = _numberOfTeamsCtrl.text.trim();
    final teams = int.tryParse(teamsText);
    if (teamsText.isEmpty) {
      errors['numberOfTeams'] = 'Number of teams is required.';
    } else if (teams == null || teams < 2 || teams > 256) {
      errors['numberOfTeams'] = 'Teams must be between 2 and 256.';
    } else if (!_isPowerOfTwo(teams)) {
      errors['numberOfTeams'] =
          'Use a valid bracket size: 2, 4, 8, 16, 32, 64, 128, or 256.';
    }

    setState(() {
      _fieldErrors.removeWhere((key, _) => _detailsFieldKeys.contains(key));
      _fieldErrors.addAll(errors);
    });
    return errors.isEmpty;
  }

  bool _validateVenueFields() {
    final errors = <String, String>{};
    final venueName = _venueNameCtrl.text.trim();
    final location = _locationCtrl.text.trim();
    final capacityText = _capacityCtrl.text.trim();
    final capacity = int.tryParse(capacityText);

    if (venueName.isEmpty) {
      errors['venueName'] = 'Venue name is required.';
    } else if (venueName.length < 3) {
      errors['venueName'] = 'Enter a valid venue name.';
    }

    if (location.isEmpty) {
      errors['location'] = 'Venue location is required.';
    } else if (location.length < 3) {
      errors['location'] = 'Enter a valid location.';
    }

    if (capacityText.isEmpty) {
      errors['capacity'] = 'Daily match capacity is required.';
    } else if (capacity == null || capacity <= 0) {
      errors['capacity'] = 'Capacity must be greater than 0.';
    } else if (capacity > 100) {
      errors['capacity'] = 'Capacity cannot be more than 100 matches per day.';
    }

    _validateDateField(
      errors,
      'venueDate',
      _venueDateCtrl.text.trim(),
      'Venue date',
    );
    _validateTimeField(
      errors,
      'venueStartTime',
      _venueStartTimeCtrl.text.trim(),
      'Venue start time',
    );

    setState(() {
      _fieldErrors.removeWhere((key, _) => _venueFieldKeys.contains(key));
      _fieldErrors.addAll(errors);
    });
    return errors.isEmpty;
  }

  bool _validateBudgetFields() {
    final errors = <String, String>{};
    final entryFeeText = _entryFeeCtrl.text.trim();
    final prizePoolText = _prizePoolCtrl.text.trim();
    final entryFee = int.tryParse(entryFeeText);
    final prizePool = int.tryParse(prizePoolText);

    if (_isPaid) {
      if (entryFeeText.isEmpty) {
        errors['entryFee'] = 'Entry fee is required for paid tournaments.';
      } else if (entryFee == null || entryFee < 0) {
        errors['entryFee'] = 'Enter a valid entry fee.';
      } else if (entryFee > 100000) {
        errors['entryFee'] = 'Entry fee cannot be more than Rs 100000.';
      }
    }

    if (prizePoolText.isEmpty) {
      errors['prizePool'] = 'Prize pool is required.';
    } else if (prizePool == null || prizePool < 0) {
      errors['prizePool'] = 'Enter a valid prize pool.';
    } else if (prizePool > 10000000) {
      errors['prizePool'] = 'Prize pool cannot be more than Rs 10000000.';
    }

    _validateAmountField(
        errors, 'winnerPrize', _winnerPrizeCtrl.text.trim(), 'Winner prize');
    _validateAmountField(errors, 'runnerUpPrize',
        _runnerUpPrizeCtrl.text.trim(), 'Runner-up prize');
    _validateAmountField(errors, 'semiFinalistPrize',
        _semiFinalistPrizeCtrl.text.trim(), 'Semi-finalist prize');
    _validateAmountField(errors, 'quarterFinalistPrize',
        _quarterFinalistPrizeCtrl.text.trim(), 'Quarter-finalist prize');
    _validateAmountField(errors, 'batsmanMostRuns',
        _batsmanMostRunsCtrl.text.trim(), 'Batsman most runs prize');
    _validateAmountField(errors, 'batsmanMoreFours',
        _batsmanMoreFoursCtrl.text.trim(), 'Batsman more fours prize');
    _validateAmountField(errors, 'batsmanMoreSixes',
        _batsmanMoreSixesCtrl.text.trim(), 'Batsman more sixes prize');
    _validateAmountField(errors, 'batsmanStrikeRate',
        _batsmanStrikeRateCtrl.text.trim(), 'Batsman strike rate prize');
    _validateAmountField(errors, 'bowlerMostWickets',
        _bowlerMostWicketsCtrl.text.trim(), 'Bowler most wickets prize');
    _validateAmountField(errors, 'bowlerBestEconomy',
        _bowlerBestEconomyCtrl.text.trim(), 'Bowler best economy prize');
    _validateAmountField(errors, 'audiencePrize',
        _audiencePrizeCtrl.text.trim(), 'Audience prize');

    final winnerPrize = int.tryParse(_winnerPrizeCtrl.text.trim()) ?? 0;
    final runnerPrize = int.tryParse(_runnerUpPrizeCtrl.text.trim()) ?? 0;
    if (prizePool != null &&
        winnerPrize + runnerPrize > prizePool &&
        !errors.containsKey('winnerPrize') &&
        !errors.containsKey('runnerUpPrize')) {
      errors['winnerPrize'] =
          'Winner and runner-up prizes cannot exceed total prize money.';
    }

    setState(() {
      _fieldErrors.removeWhere((key, _) => _budgetFieldKeys.contains(key));
      _fieldErrors.addAll(errors);
    });
    return errors.isEmpty;
  }

  Future<void> _pickDate({
    required TextEditingController controller,
    required String fieldKey,
    required String helpText,
  }) async {
    FocusScope.of(context).unfocus();
    final today = DateTime.now();
    final firstDate = DateTime(today.year, today.month, today.day);
    final lastDate = DateTime(today.year + 3, today.month, today.day);
    final existingDate = _parseApiDate(controller.text.trim());
    final initialDate = existingDate == null || existingDate.isBefore(firstDate)
        ? firstDate
        : existingDate.isAfter(lastDate)
            ? lastDate
            : existingDate;

    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: firstDate,
      lastDate: lastDate,
      helpText: helpText,
      cancelText: 'Cancel',
      confirmText: 'Done',
      builder: (context, child) => _buildPickerTheme(context, child),
    );

    if (picked == null || !mounted) return;
    setState(() {
      controller.text = _formatApiDate(picked);
      _fieldErrors.remove(fieldKey);
      _submitError = null;
    });
  }

  Future<void> _pickTime({
    required TextEditingController controller,
    required String fieldKey,
    required String helpText,
  }) async {
    FocusScope.of(context).unfocus();
    final initialTime = _parseApiTime(controller.text.trim()) ??
        TimeOfDay.fromDateTime(DateTime.now());
    final picked = await showTimePicker(
      context: context,
      initialTime: initialTime,
      helpText: helpText,
      cancelText: 'Cancel',
      confirmText: 'Done',
      builder: (context, child) {
        final themedChild = _buildPickerTheme(context, child);
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
          child: themedChild,
        );
      },
    );

    if (picked == null || !mounted) return;
    setState(() {
      controller.text = _formatApiTime(picked);
      _fieldErrors.remove(fieldKey);
      _submitError = null;
    });
  }

  Widget _buildPickerTheme(BuildContext context, Widget? child) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    return Theme(
      data: theme.copyWith(
        colorScheme: cs.copyWith(
          primary: cs.tertiary,
          onPrimary: cs.onTertiary,
          surface: cs.surface,
          onSurface: cs.onSurface,
          onSurfaceVariant: cs.onSurfaceVariant,
        ),
        dialogTheme: DialogThemeData(
          backgroundColor: cs.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
            side: BorderSide(color: cs.outlineVariant),
          ),
        ),
        datePickerTheme: DatePickerThemeData(
          backgroundColor: cs.surface,
          headerBackgroundColor: cs.surfaceContainerHighest,
          headerForegroundColor: cs.onSurface,
          dayForegroundColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return Colors.black;
            }
            if (states.contains(WidgetState.disabled)) {
              return cs.onSurfaceVariant.withValues(alpha: .35);
            }
            return cs.onSurface;
          }),
          dayBackgroundColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return cs.tertiary;
            }
            return Colors.transparent;
          }),
          todayBorder: BorderSide(color: cs.tertiary),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
        ),
        timePickerTheme: TimePickerThemeData(
          backgroundColor: cs.surface,
          dialBackgroundColor: cs.surfaceContainerHighest,
          dialHandColor: cs.tertiary,
          entryModeIconColor: cs.tertiary,
          hourMinuteColor: cs.surfaceContainerHighest,
          hourMinuteTextColor: cs.onSurface,
          dayPeriodColor: cs.surfaceContainerHighest,
          dayPeriodTextColor: cs.onSurface,
          helpTextStyle: theme.textTheme.titleMedium?.copyWith(
            color: cs.onSurface,
            fontWeight: FontWeight.w600,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
        ),
      ),
      child: child ?? const SizedBox.shrink(),
    );
  }

  DateTime? _parseApiDate(String value) {
    if (!RegExp(r'^\d{4}-\d{2}-\d{2}$').hasMatch(value)) return null;
    final parsed = DateTime.tryParse(value);
    if (parsed == null || _formatApiDate(parsed) != value) return null;
    return DateTime(parsed.year, parsed.month, parsed.day);
  }

  TimeOfDay? _parseApiTime(String value) {
    final match = RegExp(r'^([01]\d|2[0-3]):([0-5]\d)$').firstMatch(value);
    if (match == null) return null;
    return TimeOfDay(
      hour: int.parse(match.group(1)!),
      minute: int.parse(match.group(2)!),
    );
  }

  String _formatApiDate(DateTime date) {
    return '${date.year.toString().padLeft(4, '0')}-'
        '${date.month.toString().padLeft(2, '0')}-'
        '${date.day.toString().padLeft(2, '0')}';
  }

  String _formatApiTime(TimeOfDay time) {
    return '${time.hour.toString().padLeft(2, '0')}:'
        '${time.minute.toString().padLeft(2, '0')}';
  }

  void _validateDateField(
    Map<String, String> errors,
    String key,
    String value,
    String label,
  ) {
    if (value.isEmpty) {
      errors[key] = '$label is required.';
      return;
    }
    if (_parseApiDate(value) == null) {
      errors[key] = 'Select a valid date.';
    }
  }

  void _validateTimeField(
    Map<String, String> errors,
    String key,
    String value,
    String label,
  ) {
    if (value.isEmpty) {
      errors[key] = '$label is required.';
      return;
    }
    if (_parseApiTime(value) == null) {
      errors[key] = 'Select a valid time.';
    }
  }

  void _validateNumberField(
    Map<String, String> errors,
    String key,
    String value,
    String label, {
    required int min,
    required int max,
  }) {
    final parsed = int.tryParse(value);
    if (value.isEmpty) {
      errors[key] = '$label is required.';
    } else if (parsed == null || parsed < min || parsed > max) {
      errors[key] = '$label must be between $min and $max.';
    }
  }

  void _validateAmountField(
    Map<String, String> errors,
    String key,
    String value,
    String label,
  ) {
    _validateNumberField(
      errors,
      key,
      value,
      label,
      min: 0,
      max: 10000000,
    );
  }

  String _readableSubmitError(Object error) {
    if (error is SportoApiException) {
      final validation = _firstValidationMessage(error.errors);
      if (validation != null) return validation;
      return error.message;
    }
    return error.toString();
  }

  String? _firstValidationMessage(Object? errors) {
    if (errors is Map) {
      for (final value in errors.values) {
        if (value is List && value.isNotEmpty) return value.first.toString();
        if (value != null) return value.toString();
      }
    }
    return null;
  }

  int get _entryFee =>
      _isPaid ? int.tryParse(_entryFeeCtrl.text.trim()) ?? 0 : 0;

  int get _estimatedCollection => _entryFee * _numberOfTeams;

  int get _totalPrizeMoney => int.tryParse(_prizePoolCtrl.text.trim()) ?? 0;

  int get _platformFee => (_estimatedCollection * 0.10).round();

  int get _netEarnings =>
      _estimatedCollection - _totalPrizeMoney - _platformFee;

  int get _sportId {
    return switch (_selectedSportPreset) {
      _TournamentSport.cricket => 1,
      _TournamentSport.football => 2,
      _TournamentSport.badminton => 5,
    };
  }

  int get _sportFormatId => 1;

  int get _tournamentTypeId {
    return switch (_selectedFormat) {
      'League' => 2,
      'League + Knockout' => 3,
      _ => 1,
    };
  }
}
