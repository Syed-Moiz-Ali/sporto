import 'package:flutter/material.dart';
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
  final _venueNameCtrl =
      TextEditingController(text: 'Miyapur Community Ground');
  final _locationCtrl = TextEditingController(text: 'Miyapur, Hyderabad');
  final _capacityCtrl = TextEditingController(text: '6');
  final _entryFeeCtrl = TextEditingController(text: '400');
  final _prizePoolCtrl = TextEditingController(text: '20000');

  // State
  bool _isPaid = true;
  bool _confirmReview = false;
  int _numberOfTeams = 128;
  late String _selectedSport;
  _TournamentSport _selectedSportPreset = _TournamentSport.cricket;
  String _selectedFormat = 'Knockout';
  String _selectedBallType = 'Tennis Ball';
  int _miniOvers = 3;
  int _ballsPerOver = 3;
  int _playersPerTeam = 5;

  List<Map<String, dynamic>> _venues = [
    {'name': 'Venue 1', "round": 'Round of 128', "matches": '64 Matches'},
  ];

  @override
  void initState() {
    super.initState();
    _currentStep = widget.initialStep.clamp(0, _totalSteps - 1);
    _selectedSport = 'Mini Cricket - Super Over Challenge';
  }

  @override
  void dispose() {
    _venueNameCtrl.dispose();
    _locationCtrl.dispose();
    _capacityCtrl.dispose();
    _entryFeeCtrl.dispose();
    _prizePoolCtrl.dispose();
    super.dispose();
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
                SportoBulletPoint(text: 'Up to 64 Teams'),
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
            label: 'Tournament Name', hint: 'e.g. hyderabad super over cup'),
        const SizedBox(height: 20),
        SportoTextField(
            label: 'Title Sponsor (Optional)',
            hint: 'e.g. CoolBreeze Beverages'),
        const SizedBox(height: 20),
        SportoTextField(
            label: 'Tournament Start',
            hint: 'Select date',
            suffixIcon: Icon(Icons.calendar_today_outlined,
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
                  suffixIcon: Icon(Icons.calendar_today_outlined,
                      color: cs.onSurfaceVariant, size: 18))),
          const SizedBox(width: 12),
          Expanded(
              child: SportoTextField(
                  hint: 'Select time',
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
                    label: 'Match Duration (mins)', hint: 'Select date')),
            const SizedBox(width: 12),
            Expanded(
                child:
                    SportoTextField(label: 'Start Time', hint: 'Select time')),
          ]),
          const SizedBox(height: 16),
          SportoTextField(
              label: 'Break Between Matches (mins)', hint: 'Select time'),
          const SizedBox(height: 16),
          Text('Lunch Break',
              style: TextStyle(
                  color: cs.onSurface,
                  fontSize: 14,
                  fontWeight: FontWeight.w500)),
          const SizedBox(height: 8),
          Row(children: [
            Expanded(
                child: SportoTextField(label: 'From', hint: 'Select time')),
            const SizedBox(width: 12),
            Expanded(child: SportoTextField(label: 'To', hint: 'Select time')),
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
                    if (_numberOfTeams > 2) _numberOfTeams ~/= 2;
                  })),
          const SizedBox(width: 16),
          Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              decoration: BoxDecoration(
                  color: context.sporto.field,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: context.sporto.fieldBorder)),
              child: Text('$_numberOfTeams Teams',
                  style: TextStyle(
                      color: cs.onSurface,
                      fontSize: 16,
                      fontWeight: FontWeight.w600))),
          const SizedBox(width: 16),
          SportoStepperButton(
              icon: Icons.add,
              onPressed: () => setState(() => _numberOfTeams *= 2)),
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
            Text(
                '128 Teams → 64 Teams → 32 Teams → 16 Teams → Quarter Finals → Semi Finals → Final',
                style: TextStyle(
                    color: cs.onSurfaceVariant, fontSize: 12, height: 1.5)),
          ]),
        ),
        const SizedBox(height: 32),
        PrimaryButton(
            width: double.infinity,
            height: 56,
            label: 'Continue',
            onPressed: () => setState(() => _currentStep = 3)),
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
              onTap: () => setState(() => _selectedBallType = 'Leather Ball')),
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
                child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('• ',
                          style: TextStyle(
                              color: cs.onSurfaceVariant, fontSize: 12)),
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
          (_TournamentSport.football,
              'Mini Football - Goal Shootout Challenge'),
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
            child: Column(mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Choose Sport',
                  style: theme.textTheme.titleLarge
                      ?.copyWith(fontSize: 18, fontWeight: FontWeight.w600)),
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
                      _playersPerTeam = option.$1 == _TournamentSport.badminton
                          ? 2
                          : 5;
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
            Text(
                '128 Teams → 64 Teams → 32 Teams → 16 Teams → Quarter Finals → Semi Finals → Final',
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
        ..._venues.map((v) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: SportoCard(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                  Text(v['name'],
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
                              Text(v['round'],
                                  style: TextStyle(
                                      color: cs.onSurface,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500)),
                              Text(v['matches'],
                                  style: TextStyle(
                                      color: cs.onSurfaceVariant,
                                      fontSize: 12)),
                            ]),
                        TextButton(
                            key: const Key('add_venue_details'),
                            onPressed: () =>
                                _showVenueModal(context, v['name']),
                            child: Row(mainAxisSize: MainAxisSize.min, children: [
                              Text('Add Venue Details', style: TextStyle(
                                  color: cs.tertiary, fontSize: 13,
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
                setState(() {
                  _venues.add({
                    'name': 'Venue ${_venues.length + 1}',
                    "round": 'Round of 64',
                    "matches": '32 Matches'
                  });
                });
                _showVenueModal(context, 'Venue ${_venues.length + 1}');
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
            onPressed: () => setState(() => _currentStep = 4)),
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
        builder: (ctx) => DraggableScrollableSheet(
              initialChildSize: 0.9,
              minChildSize: 0.5,
              maxChildSize: 0.95,
              builder: (_, controller) => Container(
                decoration: BoxDecoration(
                    color: const Color(0xFF121418),
                    borderRadius:
                        const BorderRadius.vertical(top: Radius.circular(24))),
                padding: const EdgeInsets.all(24),
                child: SingleChildScrollView(
                  controller: controller,
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(venueName,
                                        style: TextStyle(
                                            color: cs.onTertiary,
                                            fontSize: 20,
                                            fontWeight: FontWeight.w600)),
                                    Text('Round of 128 • 64 Matches',
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
                            controller: _venueNameCtrl),
                        const SizedBox(height: 20),
                        SportoTextField(
                            label: 'Location',
                            hint: 'e.g. Kondapur, hyderabad',
                            controller: _locationCtrl),
                        const SizedBox(height: 20),
                        SportoTextField(
                            label: 'Daily Match Capacity',
                            hint: 'e.g. 20',
                            controller: _capacityCtrl),
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
                                  label: 'Date', hint: 'Select date')),
                          const SizedBox(width: 12),
                          Expanded(
                              child: SportoTextField(
                                  label: 'Start Time', hint: 'Select time')),
                        ]),
                        const SizedBox(height: 32),
                        Row(
                          children: [
                            Expanded(
                                child: SecondaryButton(
                                    label: 'Save',
                                    onPressed: () => Navigator.pop(ctx))),
                            const SizedBox(width: 12),
                            Expanded(
                              flex: 2,
                              child: PrimaryButton(
                                  width: double.infinity,
                                  height: 56,
                                  label: 'Save & Add Next',
                                  onPressed: () => Navigator.pop(ctx)),
                            ),
                          ],
                        ),
                      ]),
                ),
              ),
            ));
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
              controller: _entryFeeCtrl),
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
              controller: _prizePoolCtrl),
          const SizedBox(height: 16),
          Row(children: [
            Expanded(
                child: SportoTextField(
                    label: 'Winner Prize', hint: 'e.g. ₹15,000')),
            const SizedBox(width: 12),
            Expanded(
                child: SportoTextField(
                    label: 'Runner-up Prize', hint: 'e.g. ₹5,000'))
          ]),
          const SizedBox(height: 16),
          Row(children: [
            Expanded(
                child: SportoTextField(
                    label: 'Semi-finalists', hint: 'e.g. ₹15,000')),
            const SizedBox(width: 12),
            Expanded(
                child: SportoTextField(
                    label: 'Quarter-finalists', hint: 'e.g. ₹5,000'))
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
          SportoTextField(label: 'Batsman - Most Runs', hint: 'e.g. ₹20,000'),
          const SizedBox(height: 16),
          Row(children: [
            Expanded(
                child: SportoTextField(
                    label: 'Batsman - More 4\'s', hint: 'e.g. ₹20,000')),
            const SizedBox(width: 12),
            Expanded(
                child: SportoTextField(
                    label: 'Batsman - More 6\'s', hint: 'e.g. ₹20,000'))
          ]),
          const SizedBox(height: 16),
          SportoTextField(
              label: 'Batsman - Highest Strike Rate', hint: 'e.g. ₹20,000'),
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
          SportoTextField(label: 'Bowler - Most Wickets', hint: 'e.g. ₹20,000'),
          const SizedBox(height: 16),
          SportoTextField(label: 'Bowler Best Economy', hint: 'e.g. ₹20,000'),
          const SizedBox(height: 16),
          Row(children: [
            Expanded(
                child: SportoTextField(
                    label: 'Winner Prize', hint: 'e.g. ₹15,000')),
            const SizedBox(width: 12),
            Expanded(
                child: SportoTextField(
                    label: 'Runner-up Prize', hint: 'e.g. ₹5,000'))
          ]),
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
          SportoTextField(label: 'Prize 1', hint: 'e.g. ₹20,000'),
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

        // Sponsor
        SportoCard(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Sponsor',
              style: TextStyle(
                  color: cs.onTertiary,
                  fontSize: 14,
                  fontWeight: FontWeight.w600)),
          const SizedBox(height: 12),
          Row(children: [
            Expanded(
                child: SportoTextField(
                    label: 'Sponsor Contribution', hint: 'e.g. ₹20,000')),
            const SizedBox(width: 8),
            IconButton(
                icon: Icon(Icons.close, color: cs.onSurfaceVariant),
                onPressed: () {})
          ]),
          const SizedBox(height: 12),
          Row(children: [
            Expanded(
                child:
                    SportoTextField(label: 'Co-Sponsor', hint: 'e.g. ₹15,000')),
            const SizedBox(width: 8),
            IconButton(
                icon: Icon(Icons.close, color: cs.onSurfaceVariant),
                onPressed: () {})
          ]),
          const SizedBox(height: 12),
          Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                  onPressed: () {},
                  icon: Icon(Icons.add, color: cs.onTertiary),
                  label: Text('Add More',
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
              SportoSummaryRow(label: 'Estimated Collection', value: '₹12,800'),
              SportoSummaryRow(label: 'Prize Money', value: '-₹15,000'),
              SportoSummaryRow(label: 'Platform Fee', value: '₹1,280'),
              const SportoDivider(height: 24),
              SportoSummaryRow(
                  label: 'Net Earnings', value: '₹11,520', highlight: true),
            ])),
        const SizedBox(height: 32),
        PrimaryButton(
            width: double.infinity,
            height: 56,
            label: 'Continue',
            onPressed: () => setState(() => _currentStep = 5)),
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
            Text('Miyapur Super Over Cup',
                style: TextStyle(
                    color: cs.onSurface,
                    fontSize: 20,
                    fontWeight: FontWeight.w600)),
            RichText(
                text: TextSpan(
                    style: DefaultTextStyle.of(context)
                        .style
                        .copyWith(fontSize: 13),
                    children: [
              TextSpan(
                  text: 'Presented by: ',
                  style: TextStyle(color: cs.onSurfaceVariant)),
              TextSpan(
                  text: 'CoolBreeze Beverages',
                  style: TextStyle(color: cs.onTertiary))
            ])),
            const SizedBox(height: 16),
            Row(children: [
              Icon(Icons.location_on_outlined, color: cs.secondary, size: 16),
              const SizedBox(width: 4),
              Text('Miyapur Community Ground',
                  style: TextStyle(color: cs.secondary, fontSize: 14))
            ]),
            const SizedBox(height: 4),
            Text('03 Aug 2026',
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
                  Text('Edit', style: TextStyle(color: cs.tertiary,
                      fontSize: 12, fontWeight: FontWeight.w600)),
                  const SizedBox(width: 4),
                  Icon(Icons.arrow_forward_ios_rounded,
                      color: cs.tertiary, size: 11),
                ]))
          ]),
          const SizedBox(height: 12),
          Text('Knockout Format',
              style: TextStyle(
                  color: cs.onSurface,
                  fontSize: 14,
                  fontWeight: FontWeight.w500)),
          Text(
              'Wind Ball • 3 Overs • 3 Balls/over • 5 Overs • 20 mins Match • 10 mins Buffers',
              style: TextStyle(
                  color: cs.onSurfaceVariant, fontSize: 12, height: 1.5)),
          const SizedBox(height: 12),
          const SportoDivider(height: 1),
          const SizedBox(height: 12),
          SportoSummaryRow(label: 'Maximum Teams', value: '32'),
          SportoSummaryRow(label: 'Registration Fee', value: '₹400'),
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
                  Text('Edit', style: TextStyle(color: cs.tertiary,
                      fontSize: 12, fontWeight: FontWeight.w600)),
                  const SizedBox(width: 4),
                  Icon(Icons.arrow_forward_ios_rounded,
                      color: cs.tertiary, size: 11),
                ]))
          ]),
          const SizedBox(height: 12),
          SportoSummaryRow(label: 'Location', value: 'Miyapur, Hyderabad'),
          SportoSummaryRow(label: 'Daily Match Capacity', value: '6'),
          SportoSummaryRow(label: 'Max Duration', value: '30 mins'),
          SportoSummaryRow(label: 'Tournament Date', value: '03 Aug 2026'),
          SportoSummaryRow(label: 'Start Time', value: '09:00 AM'),
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
              SportoSummaryRow(label: 'Estimated Collection', value: '₹12,800'),
              SportoSummaryRow(label: 'Prize Money', value: '-₹15,000'),
              SportoSummaryRow(label: 'Platform Fee', value: '₹1,280'),
              const SportoDivider(height: 24),
              SportoSummaryRow(
                  label: 'Net Earnings', value: '₹11,520', highlight: true),
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
                  onPressed: () {})),
        ]),
      ],
    );
  }
}
