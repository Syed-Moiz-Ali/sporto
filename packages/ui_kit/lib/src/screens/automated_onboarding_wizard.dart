import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_domain/shared_domain.dart';
import 'package:ui_kit/ui_kit.dart';

// ============================================================
// SHARED REFERENCE STYLING HELPERS
// Exact dark card style used across all 3 screens
// ============================================================
Color _cardFill(ColorScheme cs) => const Color(0xFF15171C).withOpacity(0.55);
Color _cardBorder(ColorScheme cs) => const Color(0x0FFFFFFF); // white 6%
const double _cardRadius = 16;
const double _cardBlur = 14;

Widget _refCard({
  required BuildContext context,
  required Widget child,
  EdgeInsetsGeometry padding =
      const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
}) {
  final cs = Theme.of(context).colorScheme;
  return GlassContainer(
    borderRadius: _cardRadius,
    blur: _cardBlur,
    borderWidth: 1,
    borderColor: _cardBorder(cs),
    backgroundColor: _cardFill(cs),
    padding: padding,
    child: child,
    width: double.infinity,
  );
}

// Green ring check (not filled disc)
class _RingCheck extends StatelessWidget {
  final bool done;
  const _RingCheck({required this.done});
  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      width: 22,
      height: 22,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: done ? cs.secondary : const Color(0xFF4A5160),
          width: 1.6,
        ),
      ),
      alignment: Alignment.center,
      child: done
          ? Icon(Icons.check_rounded, color: cs.secondary, size: 14)
          : null,
    );
  }
}

// Square checkbox for confirm row
class _SquareCheck extends StatelessWidget {
  final bool checked;
  const _SquareCheck({required this.checked});
  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      width: 22,
      height: 22,
      decoration: BoxDecoration(
        color: checked ? cs.secondary : Colors.transparent,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: checked ? cs.secondary : const Color(0xFF4A5160),
          width: 1.5,
        ),
      ),
      alignment: Alignment.center,
      child: checked
          ? const Icon(Icons.check_rounded, color: Colors.white, size: 14)
          : null,
    );
  }
}

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
    final isHeader = label == null;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(bottom: 12),
      child: _refCard(
        context: context,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (label != null) ...[
              Text(label!,
                  style: tt.bodyMedium
                      ?.copyWith(color: cs.onSurfaceVariant, fontSize: 13)),
              const SizedBox(height: 4),
            ],
            Text(
              value,
              style: tt.bodyLarge?.copyWith(
                color: isHeader ? cs.onSurface : cs.onTertiary,
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
            if (sub != null) ...[
              const SizedBox(height: 4),
              Text(sub!,
                  style: tt.bodyMedium
                      ?.copyWith(color: cs.onTertiary, fontSize: 13)),
            ],
          ],
        ),
      ),
    );
  }
}

// Secondary dark button
class _SecondaryButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;
  const _SecondaryButton({required this.label, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final width = MediaQuery.of(context).size.width * 0.7;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          width: width,
          height: 52,
          decoration: BoxDecoration(
            color: const Color(0xFF2A3346),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: _cardBorder(cs)),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: tt.titleLarge?.copyWith(
              color: cs.onSurface,
              fontSize: 16,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.3,
            ),
          ),
        ),
      ),
    );
  }
}

// Ambient background helper
Widget _buildAmbientBackground(ColorScheme cs) {
  final base = Scaffold().backgroundColor ?? Colors.black;
  return IgnorePointer(
    child: Stack(
      children: [
        Container(color: base),
        Container(
          decoration: BoxDecoration(
            gradient: RadialGradient(
              center: const Alignment(0.9, -0.85),
              radius: 0.9,
              colors: [cs.primary.withOpacity(0.14), Colors.transparent],
            ),
          ),
        ),
      ],
    ),
  );
}

// ============================================================
// MAIN WIDGET
// ============================================================
class AutomatedOnboardingWizard extends StatefulWidget {
  final UserEntity user;
  final Function(UserEntity updatedUser) onComplete;
  final VoidCallback? onTrackApplication;
  final VoidCallback? onBackToLogin;

  const AutomatedOnboardingWizard({
    super.key,
    required this.user,
    required this.onComplete,
    this.onTrackApplication,
    this.onBackToLogin,
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
  String _selectedGender = 'Male';

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
    _firstNameController = TextEditingController(text: 'Priya');
    _lastNameController = TextEditingController(text: 'Agrawal');
    _emailController = TextEditingController(
      text: widget.user.email.isEmpty ? 'rahul@email.com' : widget.user.email,
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

    // SHORT-CIRCUIT: Show submitted screen when flag is true
    if (_applicationSubmitted) {
      return _buildSubmittedScreen(cs, tt);
    }

    final top = MediaQuery.of(context).padding.top;
    final isLastStep = _currentStep == _totalSteps;
    final submitDisabled = isLastStep && !_confirmAccuracy;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Stack(
        children: [
          _buildAmbientBackground(cs),
          SafeArea(
            bottom: false,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // App bar
                Padding(
                  padding: EdgeInsets.fromLTRB(16, top > 0 ? 4 : 8, 16, 0),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () {
                          if (_currentStep > 1) {
                            setState(() => _currentStep--);
                          } else {
                            Navigator.of(context).pop();
                          }
                        },
                        behavior: HitTestBehavior.opaque,
                        child: GlassContainer(
                          width: 40,
                          height: 40,
                          borderRadius: 12,
                          blur: 12,
                          borderWidth: 1,
                          borderColor: _cardBorder(cs),
                          backgroundColor: cs.onSurface.withOpacity(0.10),
                          padding: EdgeInsets.zero,
                          child: Center(
                            child: Icon(Icons.arrow_back_ios_new_rounded,
                                color: cs.onSurface, size: 18),
                          ),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Text(
                          'Apply as Referee',
                          style: GoogleFonts.spaceGrotesk(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: cs.onSurface,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),

                // Progress bar
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    children: List.generate(_totalSteps, (index) {
                      final done = index < _currentStep;
                      return Expanded(
                        child: Container(
                          height: 3,
                          margin: EdgeInsets.only(
                              right: index == _totalSteps - 1 ? 0 : 6),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(3),
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
                const SizedBox(height: 22),

                // Step content
                Expanded(
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 350),
                    switchInCurve: Curves.easeOutCubic,
                    switchOutCurve: Curves.easeInCubic,
                    transitionBuilder: (child, anim) =>
                        FadeTransition(opacity: anim, child: child),
                    child: SingleChildScrollView(
                      key: ValueKey<int>(_currentStep),
                      physics: const ClampingScrollPhysics(),
                      padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
                      child: _buildCurrentStepContent(cs, tt),
                    ),
                  ),
                ),

                // CTA
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
                  child: Center(
                    child: PrimaryButton(
                      label: isLastStep ? 'Submit Application' : 'Continue',
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
        const SizedBox(height: 4),
        Text('Gender',
            style: tt.bodyMedium
                ?.copyWith(color: cs.onSurfaceVariant, fontSize: 13)),
        const SizedBox(height: 12),
        Row(
          children: [
            _buildGenderPill('Male', Icons.male_rounded, cs, tt),
            const SizedBox(width: 12),
            _buildGenderPill('Female', Icons.female_rounded, cs, tt),
            const SizedBox(width: 12),
            _buildGenderPill('Others', null, cs, tt),
          ],
        ),
      ],
    );
  }

  Widget _buildGenderPill(
      String gender, IconData? icon, ColorScheme cs, TextTheme tt) {
    final isSelected = _selectedGender == gender;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedGender = gender),
        behavior: HitTestBehavior.opaque,
        child: GlassContainer(
          height: 48,
          borderRadius: 12,
          blur: 14,
          borderWidth: 1,
          borderColor:
              isSelected ? cs.tertiary.withOpacity(0.6) : _cardBorder(cs),
          backgroundColor:
              isSelected ? cs.tertiary.withOpacity(0.2) : _cardFill(cs),
          padding: EdgeInsets.zero,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (icon != null) ...[
                Icon(icon,
                    size: 18,
                    color: isSelected ? cs.tertiary : cs.onSurfaceVariant),
                const SizedBox(width: 6),
              ],
              Text(
                gender,
                style: tt.bodyLarge?.copyWith(
                  color: isSelected ? cs.onSurface : cs.onSurfaceVariant,
                  fontSize: 14,
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
    Widget tile = GlassContainer(
      width: wide ? null : 116,
      height: wide ? 56 : 116,
      borderRadius: 14,
      blur: 16,
      borderWidth: 1,
      borderColor: _cardBorder(cs),
      backgroundColor: cs.surfaceContainerHigh,
      padding: EdgeInsets.zero,
      child: Center(
        child: isUploaded
            ? Icon(Icons.check_rounded,
                color: cs.secondary, size: wide ? 26 : 30)
            : Text(
                'Upload',
                style: tt.bodyLarge?.copyWith(
                  color: cs.onSurfaceVariant,
                  fontSize: 15,
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
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: tt.bodyMedium
                  ?.copyWith(color: cs.onSurfaceVariant, fontSize: 13)),
          const SizedBox(height: 10),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              wide ? Expanded(child: tappableTile) : tappableTile,
              const SizedBox(width: 12),
              GestureDetector(
                onTap: isUploaded ? onClear : null,
                behavior: HitTestBehavior.opaque,
                child: Opacity(
                  opacity: isUploaded ? 1.0 : 0.55,
                  child: GlassContainer(
                    width: 40,
                    height: 40,
                    borderRadius: 10,
                    blur: 12,
                    borderWidth: 1,
                    borderColor: _cardBorder(cs),
                    backgroundColor: cs.onSurface.withOpacity(0.10),
                    padding: EdgeInsets.zero,
                    child: Center(
                      child: Icon(Icons.close_rounded,
                          color: cs.onSurfaceVariant, size: 18),
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
          child: _refCard(
            context: context,
            child: Row(
              children: [
                _RingCheck(done: docsUploaded),
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
          child: _refCard(
            context: context,
            child: Row(
              children: [
                _SquareCheck(checked: _confirmAccuracy),
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
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.spaceGrotesk(
              fontSize: 24,
              fontWeight: FontWeight.w600,
              color: cs.onSurface,
              letterSpacing: -0.3,
            ),
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 6),
            Text(
              subtitle,
              style: tt.bodyLarge?.copyWith(
                color: cs.onTertiary,
                fontSize: 14,
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
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: GlassContainer(
        borderRadius: 12,
        blur: 16,
        borderWidth: 1,
        borderColor: _cardBorder(cs),
        backgroundColor: _cardFill(cs),
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(label,
                style: tt.bodyMedium
                    ?.copyWith(color: cs.onSurfaceVariant, fontSize: 12)),
            const SizedBox(height: 4),
            TextField(
              controller: controller,
              keyboardType: keyboardType,
              inputFormatters: inputFormatters,
              textAlignVertical: TextAlignVertical.top,
              cursorColor: cs.tertiary,
              style: tt.bodyLarge?.copyWith(
                color: cs.onSurface,
                fontSize: 15,
                fontWeight: FontWeight.w500,
                height: 1.2,
              ),
              decoration: InputDecoration(
                isCollapsed: true,
                hintText: hint,
                hintStyle: tt.bodyLarge?.copyWith(
                  color: cs.onSurfaceVariant.withOpacity(0.55),
                  fontSize: 15,
                  height: 1.2,
                ),
                border: InputBorder.none,
                focusedBorder: InputBorder.none,
                enabledBorder: InputBorder.none,
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ],
        ),
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
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: _refCard(
          context: context,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              _SquareCheck(checked: isSelected),
              const SizedBox(width: 14),
              Text(
                label,
                style: tt.bodyLarge?.copyWith(
                  color: isSelected ? cs.onSurface : cs.onSurfaceVariant,
                  fontSize: 15,
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
    final top = MediaQuery.of(context).padding.top;
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Stack(
        children: [
          // _buildAmbientBackground(cs),
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
              padding: EdgeInsets.fromLTRB(20, top > 0 ? 8 : 16, 20, 28),
              child: Column(
                children: [
                  // Big card: 🎉 + heading + subtext
                  Expanded(
                    child: _refCard(
                      context: context,
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text('🎉', style: TextStyle(fontSize: 90)),
                          const SizedBox(height: 30),
                          Text(
                            'Application Submitted',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.spaceGrotesk(
                              fontSize: 22,
                              fontWeight: FontWeight.w600,
                              color: cs.onSurface,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            'Thank you for applying as a Sporto Referee.',
                            textAlign: TextAlign.center,
                            style: tt.bodyLarge?.copyWith(
                              color: cs.onSurfaceVariant,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Status note card
                  _refCard(
                    context: context,
                    child: Column(
                      children: [
                        Text(
                          'Your application has been sent for review.',
                          textAlign: TextAlign.center,
                          style: tt.bodyLarge?.copyWith(
                            color: cs.secondary,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Estimated Review 2–5 Working Days',
                          textAlign: TextAlign.center,
                          style: tt.bodyMedium?.copyWith(
                            color: cs.onSurfaceVariant,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
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
                  const SizedBox(height: 14),
                  _SecondaryButton(
                    label: 'Back to Login',
                    onPressed: () {
                      if (_pendingUser != null)
                        widget.onComplete(_pendingUser!);
                      if (widget.onBackToLogin != null) {
                        widget.onBackToLogin!();
                      } else {
                        Navigator.of(context).popUntil((r) => r.isFirst);
                      }
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
    final top = MediaQuery.of(context).padding.top;
    final progress = _stages.where((e) => e.value).length / _stages.length;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Stack(
        children: [
          _StatusAmbientBackground(),
          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // App bar
                Padding(
                  padding: EdgeInsets.fromLTRB(16, top > 0 ? 4 : 8, 16, 0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.of(context).pop(),
                        behavior: HitTestBehavior.opaque,
                        child: GlassContainer(
                          width: 40,
                          height: 40,
                          borderRadius: 12,
                          blur: 12,
                          borderWidth: 1,
                          borderColor: _cardBorder(cs),
                          backgroundColor: cs.onSurface.withOpacity(0.10),
                          padding: EdgeInsets.zero,
                          child: Center(
                            child: Icon(Icons.arrow_back_ios_new_rounded,
                                color: cs.onSurface, size: 18),
                          ),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Application Status',
                            style: GoogleFonts.spaceGrotesk(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: cs.onSurface,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '#$applicationRef',
                            style: tt.bodyMedium?.copyWith(
                              color: cs.onSurfaceVariant,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 22),
                Expanded(
                  child: SingleChildScrollView(
                    physics: const ClampingScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 28),
                    child: Column(
                      children: [
                        // Stage rows
                        ..._stages.map((s) => Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: _refCard(
                                context: context,
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 14),
                                child: Row(
                                  children: [
                                    _RingCheck(done: s.value),
                                    const SizedBox(width: 14),
                                    Text(
                                      s.key,
                                      style: tt.bodyLarge?.copyWith(
                                        color: s.value
                                            ? cs.onSurface
                                            : cs.onSurfaceVariant,
                                        fontSize: 15,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            )),
                        const SizedBox(height: 4),
                        // Review progress card
                        _refCard(
                          context: context,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Review Progress',
                                  style: tt.bodyMedium?.copyWith(
                                      color: cs.onSurfaceVariant,
                                      fontSize: 13)),
                              const SizedBox(height: 12),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(4),
                                child: LinearProgressIndicator(
                                  value: progress,
                                  minHeight: 6,
                                  backgroundColor: const Color(0xFF2A3346),
                                  valueColor:
                                      AlwaysStoppedAnimation<Color>(cs.primary),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        // Note card
                        _refCard(
                          context: context,
                          child: Column(
                            children: [
                              Text(
                                'Your application has been sent for review.',
                                textAlign: TextAlign.center,
                                style: tt.bodyLarge?.copyWith(
                                  color: cs.secondary,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                'Estimated Approval 2 Days Remaining',
                                textAlign: TextAlign.center,
                                style: tt.bodyMedium?.copyWith(
                                  color: cs.onSurfaceVariant,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 28),
                        Center(
                          child: PrimaryButton(
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

class _StatusAmbientBackground extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final base = Theme.of(context).scaffoldBackgroundColor;
    return IgnorePointer(
      child: Stack(children: [
        Container(color: base),
        Container(
          decoration: BoxDecoration(
            gradient: RadialGradient(
              center: const Alignment(0.9, -0.85),
              radius: 0.9,
              colors: [cs.primary.withOpacity(0.14), Colors.transparent],
            ),
          ),
        ),
      ]),
    );
  }
}
