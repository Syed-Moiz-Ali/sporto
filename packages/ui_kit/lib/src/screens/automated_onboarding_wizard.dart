import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_domain/shared_domain.dart';
import 'package:ui_kit/ui_kit.dart';

// Review card widget
class _ReviewCard extends StatelessWidget {
  final String? label;
  final String value;
  final String? sub;
  const _ReviewCard({this.label, required this.value, this.sub});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final scale = context.sportoScale;
    final isHeader = label == null;
    return Container(
      width: double.infinity,
      padding: EdgeInsets.only(bottom: 6 * scale),
      child: SportoCard(
        width: double.infinity,
        padding: EdgeInsets.symmetric(
          horizontal: 16 * scale,
          vertical: 14 * scale,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (label != null) ...[
              Text(label!,
                  style: tt.bodyMedium?.copyWith(
                      color: cs.onSurfaceVariant, fontSize: 13 * scale)),
              SizedBox(height: 4 * scale),
            ],
            Text(
              value,
              style: tt.bodyLarge?.copyWith(
                color: isHeader ? cs.onSurface : cs.onTertiary,
                fontSize: 15 * scale,
                fontWeight: FontWeight.w500,
              ),
            ),
            if (sub != null) ...[
              SizedBox(height: 4 * scale),
              Text(sub!,
                  style: tt.bodyMedium
                      ?.copyWith(color: cs.onTertiary, fontSize: 13 * scale)),
            ],
          ],
        ),
      ),
    );
  }
}

// ============================================================
// MAIN WIDGET
// ============================================================
class AutomatedOnboardingWizard extends StatefulWidget {
  final UserEntity user;
  final Function(UserEntity updatedUser) onComplete;
  final VoidCallback? onTrackApplication;
  final VoidCallback? onGoHome;

  const AutomatedOnboardingWizard({
    super.key,
    required this.user,
    required this.onComplete,
    this.onTrackApplication,
    this.onGoHome,
  });

  @override
  State<AutomatedOnboardingWizard> createState() =>
      _AutomatedOnboardingWizardState();
}

class _AutomatedOnboardingWizardState extends State<AutomatedOnboardingWizard> {
  int _currentStep = 1;
  final int _totalSteps = 6;

  // Step 1
  late TextEditingController _firstNameController;
  late TextEditingController _lastNameController;
  late TextEditingController _emailController;
  final _dobController = TextEditingController();
  String? _selectedGender;

  // Step 2
  final _addressLineController = TextEditingController();
  final _cityController = TextEditingController();
  final _stateController = TextEditingController();
  final _pinCodeController = TextEditingController();
  final _countryController = TextEditingController();

  // Step 3
  final List<String> _allSports = [
    'Cricket',
    'Football',
    'Basketball',
    'Volleyball',
    'Badminton'
  ];
  final Set<String> _selectedSports = {'Cricket', 'Football'};
  final _experienceController = TextEditingController();
  final _qualificationController = TextEditingController();

  // Step 4
  final List<String> _allDays = [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday'
  ];
  final Set<String> _selectedDays = {'Monday', 'Tuesday'};
  final _preferredCityController = TextEditingController();
  final _travelRadiusController = TextEditingController();
  final _emergencyContactController = TextEditingController();

  // Step 5
  bool _profilePhotoUploaded = false;
  bool _govIdUploaded = false;
  bool _sportsCertUploaded = false;
  bool _resumeUploaded = false;

  // Step 6
  bool _confirmAccuracy = false;

  // Post-submit state
  UserEntity? _pendingUser;
  bool _applicationSubmitted = false;
  late final ConfettiController _confettiController;
  static const String _applicationRef = 'RF202600124';

  @override
  void initState() {
    super.initState();
    final nameParts = widget.user.name.trim().split(RegExp(r'\s+'));
    final hasName = widget.user.name.trim().isNotEmpty;
    _firstNameController =
        TextEditingController(text: hasName ? nameParts.first : '');
    _lastNameController = TextEditingController(
      text: hasName && nameParts.length > 1 ? nameParts.skip(1).join(' ') : '',
    );
    _emailController = TextEditingController(
      text: widget.user.email,
    );
    _confettiController =
        ConfettiController(duration: const Duration(seconds: 3));
  }

  @override
  void dispose() {
    _confettiController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _dobController.dispose();
    _addressLineController.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _pinCodeController.dispose();
    _countryController.dispose();
    _experienceController.dispose();
    _qualificationController.dispose();
    _preferredCityController.dispose();
    _travelRadiusController.dispose();
    _emergencyContactController.dispose();
    super.dispose();
  }

  // FIXED: Don't call onComplete here — defer to Track/Back buttons
  void _finishOnboarding() {
    if (!_confirmAccuracy) return;

    _pendingUser = widget.user.copyWith(
      name:
          '${_firstNameController.text.trim()} ${_lastNameController.text.trim()}',
      email: _emailController.text.trim(),
      dob: _dobController.text.trim(),
      gender: _selectedGender,
      city: _cityController.text.trim(),
      state: _stateController.text.trim(),
      favoriteSports: _selectedSports.toList(),
      isProfileComplete: true,
    );

    if (!mounted) return;
    setState(() => _applicationSubmitted = true);
    _confettiController.play();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final tt = theme.textTheme;
    final scale = context.sportoScale;
    double scaled(double value) => value * scale;

    // SHORT-CIRCUIT: Show submitted screen when flag is true
    if (_applicationSubmitted) {
      return _buildSubmittedScreen(cs, tt);
    }

    final isLastStep = _currentStep == _totalSteps;
    final submitDisabled = isLastStep && !_confirmAccuracy;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Stack(
        children: [
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: context.sporto.authBackgroundGradient,
              ),
            ),
          ),
          SafeArea(
            bottom: false,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // App bar
                Padding(
                  padding: EdgeInsets.fromLTRB(
                    scaled(16),
                    scaled(20),
                    scaled(16),
                    0,
                  ),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () {
                          if (_currentStep > 1) {
                            setState(() => _currentStep--);
                          } else {
                            widget.onGoHome?.call();
                          }
                        },
                        behavior: HitTestBehavior.opaque,
                        child: GlassContainer(
                          width: scaled(40),
                          height: scaled(40),
                          borderRadius: scaled(12),
                          blur: scaled(12),
                          borderWidth: scale,
                          borderColor: SportoCard.defaultBorder,
                          backgroundColor: cs.onSurface.withValues(alpha: 0.10),
                          padding: EdgeInsets.zero,
                          child: Center(
                            child: Icon(Icons.arrow_back_ios_new_rounded,
                                color: cs.onSurface, size: scaled(18)),
                          ),
                        ),
                      ),
                      SizedBox(width: scaled(14)),
                      Expanded(
                        child: Text(
                          'Apply as Referee',
                          style: tt.titleLarge?.copyWith(
                            fontSize: scaled(18),
                            fontWeight: FontWeight.w600,
                            color: cs.onSurface,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: scaled(12)),

                // Progress bar
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: scaled(20)),
                  child: Row(
                    children: List.generate(_totalSteps, (index) {
                      final done = index < _currentStep;
                      return Expanded(
                        child: Container(
                          height: scaled(3),
                          margin: EdgeInsets.only(
                              right: index == _totalSteps - 1 ? 0 : scaled(6)),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(scaled(3)),
                            gradient: done
                                ? LinearGradient(
                                    colors: [cs.primary, cs.tertiary])
                                : null,
                            color: done ? null : cs.surfaceContainerHigh,
                          ),
                        ),
                      );
                    }),
                  ),
                ),
                SizedBox(height: scaled(22)),

                // Step content
                Expanded(
                  child: AnimatedSwitcher(
                    layoutBuilder: (currentChild, previousChildren) => Stack(
                      alignment: Alignment.topCenter,
                      children: [
                        ...previousChildren,
                        if (currentChild != null) currentChild
                      ],
                    ),
                    duration: const Duration(milliseconds: 350),
                    switchInCurve: Curves.easeOutCubic,
                    switchOutCurve: Curves.easeInCubic,
                    transitionBuilder: (child, anim) =>
                        FadeTransition(opacity: anim, child: child),
                    child: SingleChildScrollView(
                      key: ValueKey<int>(_currentStep),
                      physics: const ClampingScrollPhysics(),
                      padding: EdgeInsets.fromLTRB(
                        scaled(20),
                        scaled(4),
                        scaled(20),
                        scaled(24),
                      ),
                      child: Column(
                        children: [
                          _buildCurrentStepContent(cs, tt),
                          SizedBox(height: scaled(40)),
                          PrimaryButton(
                            width: scaled(270),
                            height: scaled(48),
                            radius: scaled(14),
                            label:
                                isLastStep ? 'Submit Application' : 'Continue',
                            disabled: submitDisabled,
                            onPressed: () {
                              if (submitDisabled) return;
                              if (_currentStep < _totalSteps) {
                                setState(() => _currentStep++);
                              } else {
                                _finishOnboarding();
                              }
                            },
                          ),
                          SizedBox(height: scaled(28)),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // STEP ROUTER
  // ============================================================
  Widget _buildCurrentStepContent(ColorScheme cs, TextTheme tt) {
    switch (_currentStep) {
      case 1:
        return _buildStep1PersonalInfo(cs, tt);
      case 2:
        return _buildStep2Address(cs, tt);
      case 3:
        return _buildStep3Sports(cs, tt);
      case 4:
        return _buildStep4Availability(cs, tt);
      case 5:
        return _buildStep5Identity(cs, tt);
      case 6:
        return _buildStep6Review(cs, tt);
      default:
        return const SizedBox.shrink();
    }
  }

  // --- STEP 1: Personal Info ---
  Widget _buildStep1PersonalInfo(ColorScheme cs, TextTheme tt) {
    final scale = context.sportoScale;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('Personal Information', null, cs, tt),
        _buildGlassInput(
            label: 'First Name',
            controller: _firstNameController,
            hint: 'Enter your first name',
            cs: cs,
            tt: tt),
        _buildGlassInput(
            label: 'Last Name',
            controller: _lastNameController,
            hint: 'Enter your last name',
            cs: cs,
            tt: tt),
        _buildGlassInput(
            label: 'Email Address',
            controller: _emailController,
            hint: 'Enter your email address',
            keyboardType: TextInputType.emailAddress,
            cs: cs,
            tt: tt),
        _buildGlassInput(
            label: 'Date of Birth',
            controller: _dobController,
            hint: 'DD/MM/YYYY',
            cs: cs,
            tt: tt),
        SizedBox(height: 4 * scale),
        Text('Gender',
            style: tt.bodyMedium
                ?.copyWith(color: cs.onSurfaceVariant, fontSize: 13 * scale)),
        SizedBox(height: 12 * scale),
        Row(
          children: [
            _buildGenderPill('Male', Icons.male_rounded, cs, tt),
            SizedBox(width: 12 * scale),
            _buildGenderPill('Female', Icons.female_rounded, cs, tt),
            SizedBox(width: 12 * scale),
            _buildGenderPill('Others', null, cs, tt),
          ],
        ),
      ],
    );
  }

  Widget _buildGenderPill(
      String gender, IconData? icon, ColorScheme cs, TextTheme tt) {
    final isSelected = _selectedGender == gender;
    final scale = context.sportoScale;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedGender = gender),
        behavior: HitTestBehavior.opaque,
        child: GlassContainer(
          height: 48 * scale,
          borderRadius: 12 * scale,
          blur: 14 * scale,
          borderWidth: scale,
          borderColor: isSelected
              ? cs.tertiary.withValues(alpha: 0.6)
              : SportoCard.defaultBorder,
          backgroundColor: isSelected
              ? cs.tertiary.withValues(alpha: 0.2)
              : SportoCard.defaultFill.withValues(alpha: 0.6),
          padding: EdgeInsets.zero,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (icon != null) ...[
                Icon(icon,
                    size: 18 * scale,
                    color: isSelected ? cs.tertiary : cs.onSurfaceVariant),
                SizedBox(width: 6 * scale),
              ],
              Text(
                gender,
                style: tt.bodyLarge?.copyWith(
                  color: isSelected ? cs.onSurface : cs.onSurfaceVariant,
                  fontSize: 14 * scale,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --- STEP 2: Address ---
  Widget _buildStep2Address(ColorScheme cs, TextTheme tt) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('Address Details', 'Current Address', cs, tt),
        _buildGlassInput(
            label: 'Address Line',
            controller: _addressLineController,
            hint: 'Enter your address line',
            cs: cs,
            tt: tt),
        _buildGlassInput(
            label: 'City',
            controller: _cityController,
            hint: 'Enter your city name',
            cs: cs,
            tt: tt),
        _buildGlassInput(
            label: 'State',
            controller: _stateController,
            hint: 'Enter your state name',
            cs: cs,
            tt: tt),
        _buildGlassInput(
            label: 'PIN Code',
            controller: _pinCodeController,
            hint: 'Enter PIN code',
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            cs: cs,
            tt: tt),
        _buildGlassInput(
            label: 'Country',
            controller: _countryController,
            hint: 'Enter your country',
            cs: cs,
            tt: tt),
      ],
    );
  }

  // --- STEP 3: Sports ---
  Widget _buildStep3Sports(ColorScheme cs, TextTheme tt) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(
            'Sports & Experience', 'Sports You Can Officiate', cs, tt),
        ..._allSports.map((sport) => _buildCheckRow(
              label: sport,
              isSelected: _selectedSports.contains(sport),
              onTap: () => setState(() {
                _selectedSports.contains(sport)
                    ? _selectedSports.remove(sport)
                    : _selectedSports.add(sport);
              }),
              cs: cs,
              tt: tt,
            )),
        const SizedBox(height: 28),
        _buildGlassInput(
            label: 'Years of Experience',
            controller: _experienceController,
            hint: 'Enter your years of experience',
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            cs: cs,
            tt: tt),
        _buildGlassInput(
            label: 'Highest Qualification',
            controller: _qualificationController,
            hint: 'Enter your highest qualification',
            cs: cs,
            tt: tt),
      ],
    );
  }

  // --- STEP 4: Availability ---
  Widget _buildStep4Availability(ColorScheme cs, TextTheme tt) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('Availability', 'Available Days', cs, tt),
        ..._allDays.map((day) => _buildCheckRow(
              label: day,
              isSelected: _selectedDays.contains(day),
              onTap: () => setState(() {
                _selectedDays.contains(day)
                    ? _selectedDays.remove(day)
                    : _selectedDays.add(day);
              }),
              cs: cs,
              tt: tt,
            )),
        const SizedBox(height: 28),
        _buildGlassInput(
            label: 'Preferred City',
            controller: _preferredCityController,
            hint: 'Enter your preferred city',
            cs: cs,
            tt: tt),
        _buildGlassInput(
            label: 'Travel Radius (in kilometer)',
            controller: _travelRadiusController,
            hint: 'Ex. 20 km',
            keyboardType: TextInputType.number,
            cs: cs,
            tt: tt),
        _buildGlassInput(
            label: 'Emergency Contact',
            controller: _emergencyContactController,
            hint: 'Enter an emergency contact',
            keyboardType: TextInputType.phone,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            cs: cs,
            tt: tt),
      ],
    );
  }

  // --- STEP 5: Identity Verification ---
  Widget _buildStep5Identity(ColorScheme cs, TextTheme tt) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(
            'Identity Verification', 'Upload Required Documents', cs, tt),
        _buildUploadTile(
            label: 'Profile Photo',
            isUploaded: _profilePhotoUploaded,
            onUpload: () => setState(() => _profilePhotoUploaded = true),
            onClear: () => setState(() => _profilePhotoUploaded = false),
            wide: false,
            cs: cs,
            tt: tt),
        _buildUploadTile(
            label: 'Government ID',
            isUploaded: _govIdUploaded,
            onUpload: () => setState(() => _govIdUploaded = true),
            onClear: () => setState(() => _govIdUploaded = false),
            wide: false,
            cs: cs,
            tt: tt),
        _buildUploadTile(
            label: 'Sports Certificate (Optional)',
            isUploaded: _sportsCertUploaded,
            onUpload: () => setState(() => _sportsCertUploaded = true),
            onClear: () => setState(() => _sportsCertUploaded = false),
            wide: false,
            cs: cs,
            tt: tt),
        _buildUploadTile(
            label: 'Resume (Optional)',
            isUploaded: _resumeUploaded,
            onUpload: () => setState(() => _resumeUploaded = true),
            onClear: () => setState(() => _resumeUploaded = false),
            wide: true,
            cs: cs,
            tt: tt),
      ],
    );
  }

  Widget _buildUploadTile({
    required String label,
    required bool isUploaded,
    required VoidCallback onUpload,
    required VoidCallback onClear,
    required bool wide,
    required ColorScheme cs,
    required TextTheme tt,
  }) {
    final scale = context.sportoScale;
    final compactProfile = label == 'Profile Photo';
    final tileWidth = wide ? null : (compactProfile ? 100.0 : 150.0) * scale;
    final tileHeight = (wide ? 48.0 : 100.0) * scale;

    Widget tile = GlassContainer(
      width: tileWidth,
      height: tileHeight,
      borderRadius: 14 * scale,
      blur: 16 * scale,
      borderWidth: scale,
      borderColor: SportoCard.defaultBorder,
      backgroundColor: cs.onSurface.withValues(alpha: 0.12),
      padding: EdgeInsets.zero,
      child: Center(
        child: isUploaded
            ? Icon(Icons.check_rounded,
                color: cs.secondary, size: (wide ? 26 : 30) * scale)
            : Text(
                'Upload',
                style: tt.bodyLarge?.copyWith(
                  color: cs.onSurfaceVariant,
                  fontSize: 15 * scale,
                  fontWeight: FontWeight.w500,
                ),
              ),
      ),
    );

    final tappableTile = GestureDetector(
      onTap: isUploaded ? null : onUpload,
      behavior: HitTestBehavior.opaque,
      child: wide ? SizedBox(width: double.infinity, child: tile) : tile,
    );

    return Padding(
      padding: EdgeInsets.only(bottom: 20 * scale),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: tt.bodyMedium
                  ?.copyWith(color: cs.onSurfaceVariant, fontSize: 13 * scale)),
          SizedBox(height: 10 * scale),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              wide ? Expanded(child: tappableTile) : tappableTile,
              SizedBox(width: 12 * scale),
              GestureDetector(
                onTap: isUploaded ? onClear : null,
                behavior: HitTestBehavior.opaque,
                child: Opacity(
                  opacity: isUploaded ? 1.0 : 0.55,
                  child: GlassContainer(
                    width: 32 * scale,
                    height: 32 * scale,
                    borderRadius: 8 * scale,
                    blur: 12 * scale,
                    borderWidth: scale,
                    borderColor: SportoCard.defaultBorder,
                    backgroundColor: cs.onSurface.withValues(alpha: 0.10),
                    padding: EdgeInsets.zero,
                    child: Center(
                      child: Icon(Icons.close_rounded,
                          color: cs.onSurfaceVariant, size: 18 * scale),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // --- STEP 6: REVIEW APPLICATION (Exact match to image 11) ---
  Widget _buildStep6Review(ColorScheme cs, TextTheme tt) {
    final fullName =
        '${_firstNameController.text.trim()} ${_lastNameController.text.trim()}';
    final sports =
        _selectedSports.isEmpty ? 'None selected' : _selectedSports.join(' • ');
    final experience =
        '${_experienceController.text.isEmpty ? '0' : _experienceController.text}+ Years';
    final docsUploaded = _profilePhotoUploaded ||
        _govIdUploaded ||
        _sportsCertUploaded ||
        _resumeUploaded;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(
            'Review Application', 'Sports You Can Officiate', cs, tt),

        // Card 1: name (white) + sports (blue), NO gray label
        _ReviewCard(value: fullName, sub: sports),

        // Labeled cards: gray label + blue value
        const _ReviewCard(label: 'Mobile', value: '91 XXXXX XXXXX'),
        _ReviewCard(label: 'Email', value: 'rahul@email.com'),
        _ReviewCard(label: 'Experience', value: experience),

        // Documents row: green RING check
        Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: SportoCard(
            width: double.infinity,
            child: Row(
              children: [
                SportoCheckCircle(done: docsUploaded),
                const SizedBox(width: 14),
                Text(
                  docsUploaded ? 'Documents Uploaded' : 'No Documents Uploaded',
                  style: tt.bodyLarge?.copyWith(
                    color: cs.onSurface,
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 6),

        // Confirm row: empty square checkbox
        GestureDetector(
          onTap: () => setState(() => _confirmAccuracy = !_confirmAccuracy),
          behavior: HitTestBehavior.opaque,
          child: SportoCard(
            width: double.infinity,
            child: Row(
              children: [
                SportoCheckBox(checked: _confirmAccuracy),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    'I confirm all information is accurate.',
                    style: tt.bodyLarge?.copyWith(
                      color: cs.onSurface,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ============================================================
  // SHARED BUILDING BLOCKS
  // ============================================================
  Widget _buildSectionHeader(
      String title, String? subtitle, ColorScheme cs, TextTheme tt) {
    final scale = context.sportoScale;
    return Padding(
      padding: EdgeInsets.only(bottom: 18 * scale),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: tt.displaySmall?.copyWith(
              fontSize: 20 * scale,
              fontWeight: FontWeight.w500,
              color: cs.onSurface,
              letterSpacing: -0.3,
            ),
          ),
          if (subtitle != null) ...[
            SizedBox(height: 6 * scale),
            Text(
              subtitle,
              style: tt.bodyLarge?.copyWith(
                color: cs.onTertiary,
                fontSize: 14 * scale,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildGlassInput({
    required String label,
    required TextEditingController controller,
    required String hint,
    required ColorScheme cs,
    required TextTheme tt,
    TextInputType keyboardType = TextInputType.text,
    List<TextInputFormatter>? inputFormatters,
  }) {
    final scale = context.sportoScale;
    return Padding(
      padding: EdgeInsets.only(bottom: 18 * scale),
      child: SportoTextField(
        label: label,
        hint: hint,
        controller: controller,
        keyboardType: keyboardType,
        inputFormatters: inputFormatters,
      ),
    );
  }

  Widget _buildCheckRow({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
    required ColorScheme cs,
    required TextTheme tt,
  }) {
    final scale = context.sportoScale;
    return Padding(
      padding: EdgeInsets.only(bottom: 6 * scale),
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: SportoCard(
          width: double.infinity,
          padding: EdgeInsets.symmetric(
            horizontal: 16 * scale,
            vertical: 11 * scale,
          ),
          child: Row(
            children: [
              SportoCheckBox(checked: isSelected),
              SizedBox(width: 14 * scale),
              Text(
                label,
                style: tt.bodyLarge?.copyWith(
                  color: isSelected ? cs.onSurface : cs.onSurfaceVariant,
                  fontSize: 14 * scale,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ============================================================
  // SCREEN 1: APPLICATION SUBMITTED (Image 10)
  // ============================================================
  Widget _buildSubmittedScreen(ColorScheme cs, TextTheme tt) {
    final scale = context.sportoScale;
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Stack(
        children: [
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: context.sporto.authBackgroundGradient,
              ),
            ),
          ),
          Align(
            alignment: const Alignment(0, -0.42),
            child: ConfettiWidget(
              confettiController: _confettiController,
              blastDirectionality: BlastDirectionality.explosive,
              numberOfParticles: 28,
              emissionFrequency: 0,
              shouldLoop: false,
              colors: [
                cs.primary,
                cs.tertiary,
                cs.onTertiary,
                cs.secondary,
                Colors.pink,
              ],
            ),
          ),
          SafeArea(
            child: Padding(
              padding: EdgeInsets.fromLTRB(
                10 * scale,
                27 * scale,
                10 * scale,
                20 * scale,
              ),
              child: Column(
                children: [
                  // Big card: 🎉 + heading + subtext
                  Expanded(
                    child: SportoCard(
                      width: double.infinity,
                      padding: EdgeInsets.symmetric(horizontal: 24 * scale),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('🎉', style: TextStyle(fontSize: 90 * scale)),
                          SizedBox(height: 30 * scale),
                          Text(
                            'Application Submitted',
                            textAlign: TextAlign.center,
                            style: tt.displaySmall?.copyWith(
                              fontSize: 20 * scale,
                              fontWeight: FontWeight.w500,
                              color: cs.onSurface,
                            ),
                          ),
                          SizedBox(height: 10 * scale),
                          Text(
                            'Thank you for applying as a Sporto Referee.',
                            textAlign: TextAlign.center,
                            style: tt.bodyLarge?.copyWith(
                              color: cs.onSurfaceVariant,
                              fontSize: 14 * scale,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 10 * scale),
                  // Status note card
                  SportoCard(
                    width: double.infinity,
                    child: Column(
                      children: [
                        Text(
                          'Your application has been sent for review.',
                          textAlign: TextAlign.center,
                          style: tt.bodyLarge?.copyWith(
                            color: cs.secondary,
                            fontSize: 14 * scale,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        SizedBox(height: 6 * scale),
                        Text(
                          'Estimated Review 2–5 Working Days',
                          textAlign: TextAlign.center,
                          style: tt.bodyMedium?.copyWith(
                            color: cs.onSurfaceVariant,
                            fontSize: 13 * scale,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 30 * scale),
                  PrimaryButton(
                    label: 'Track Application',
                    onPressed: () {
                      // Deliver completed user ONLY when user navigates away
                      if (_pendingUser != null)
                        widget.onComplete(_pendingUser!);
                      if (widget.onTrackApplication != null) {
                        widget.onTrackApplication!();
                      } else {
                        Navigator.of(context).push(MaterialPageRoute(
                          builder: (_) => ApplicationStatusScreen(
                              applicationRef: _applicationRef),
                        ));
                      }
                    },
                  ),
                  SizedBox(height: 14 * scale),
                  SecondaryButton(
                    width: 270 * scale,
                    height: 48 * scale,
                    radius: 14 * scale,
                    label: 'Back to Login',
                    onPressed: () {
                      // Deliver the completed profile so the app can show
                      // the authenticated home screen.
                      if (_pendingUser != null) {
                        widget.onComplete(_pendingUser!);
                      }
                      widget.onGoHome?.call();
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// SCREEN 3: APPLICATION STATUS (Image 12)
// ============================================================
class ApplicationStatusScreen extends StatelessWidget {
  final String applicationRef;
  final VoidCallback? onRefresh;
  const ApplicationStatusScreen({
    super.key,
    required this.applicationRef,
    this.onRefresh,
  });

  static const List<MapEntry<String, bool>> _stages = [
    MapEntry('Documents Uploaded', true),
    MapEntry('Application Submitted', true),
    MapEntry('Under Review', true),
    MapEntry('Approved', false),
  ];

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final scale = context.sportoScale;
    final progress = _stages.where((e) => e.value).length / _stages.length;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Stack(
        children: [
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: context.sporto.authBackgroundGradient,
              ),
            ),
          ),
          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // App bar
                Padding(
                  padding: EdgeInsets.fromLTRB(
                    20 * scale,
                    20 * scale,
                    20 * scale,
                    0,
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.of(context).pop(),
                        behavior: HitTestBehavior.opaque,
                        child: GlassContainer(
                          width: 36 * scale,
                          height: 36 * scale,
                          borderRadius: 10 * scale,
                          blur: 12 * scale,
                          borderWidth: scale,
                          borderColor: SportoCard.defaultBorder,
                          backgroundColor: cs.onSurface.withValues(alpha: 0.10),
                          padding: EdgeInsets.zero,
                          child: Center(
                            child: Icon(Icons.arrow_back_ios_new_rounded,
                                color: cs.onSurface, size: 18 * scale),
                          ),
                        ),
                      ),
                      SizedBox(width: 10 * scale),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Application Status',
                            style: tt.titleLarge?.copyWith(
                              fontSize: 18 * scale,
                              fontWeight: FontWeight.w600,
                              color: cs.onSurface,
                            ),
                          ),
                          SizedBox(height: 2 * scale),
                          Text(
                            '#$applicationRef',
                            style: tt.bodyMedium?.copyWith(
                              color: cs.onSurfaceVariant,
                              fontSize: 12 * scale,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 25 * scale),
                Expanded(
                  child: SingleChildScrollView(
                    physics: const ClampingScrollPhysics(),
                    padding: EdgeInsets.fromLTRB(
                      10 * scale,
                      0,
                      10 * scale,
                      28 * scale,
                    ),
                    child: Column(
                      children: [
                        // Stage rows
                        ..._stages.map((s) => Padding(
                              padding: EdgeInsets.only(bottom: 5 * scale),
                              child: SportoCard(
                                width: double.infinity,
                                padding: EdgeInsets.symmetric(
                                  horizontal: 16 * scale,
                                  vertical: 11 * scale,
                                ),
                                child: Row(
                                  children: [
                                    SportoCheckCircle(done: s.value),
                                    SizedBox(width: 10 * scale),
                                    Text(
                                      s.key,
                                      style: tt.bodyLarge?.copyWith(
                                        color: s.value
                                            ? cs.onSurface
                                            : cs.onSurfaceVariant,
                                        fontSize: 14 * scale,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            )),
                        // Review progress card
                        SportoCard(
                          width: double.infinity,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Review Progress',
                                  style: tt.bodyMedium?.copyWith(
                                      color: cs.onSurfaceVariant,
                                      fontSize: 13 * scale)),
                              SizedBox(height: 12 * scale),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(4 * scale),
                                child: LinearProgressIndicator(
                                  value: progress,
                                  minHeight: 6 * scale,
                                  backgroundColor: const Color(0xFF2A3346),
                                  valueColor:
                                      AlwaysStoppedAnimation<Color>(cs.primary),
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 30 * scale),
                        // Note card
                        SportoCard(
                          width: double.infinity,
                          child: Column(
                            children: [
                              Text(
                                'Your application has been sent for review.',
                                textAlign: TextAlign.center,
                                style: tt.bodyLarge?.copyWith(
                                  color: cs.secondary,
                                  fontSize: 14 * scale,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              SizedBox(height: 6 * scale),
                              Text(
                                'Estimated Approval 2 Days Remaining',
                                textAlign: TextAlign.center,
                                style: tt.bodyMedium?.copyWith(
                                  color: cs.onSurfaceVariant,
                                  fontSize: 13 * scale,
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 30 * scale),
                        Center(
                          child: PrimaryButton(
                            width: 270 * scale,
                            height: 48 * scale,
                            radius: 14 * scale,
                            label: 'Refresh Status',
                            onPressed: onRefresh ?? () {},
                          ),
                        ),
                      ],
                    ),
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
