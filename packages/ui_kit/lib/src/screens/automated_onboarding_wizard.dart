import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_domain/shared_domain.dart';

class AutomatedOnboardingWizard extends StatefulWidget {
  final UserEntity user;
  final Function(UserEntity updatedUser) onComplete;

  const AutomatedOnboardingWizard({
    super.key,
    required this.user,
    required this.onComplete,
  });

  @override
  State<AutomatedOnboardingWizard> createState() =>
      _AutomatedOnboardingWizardState();
}

class _AutomatedOnboardingWizardState extends State<AutomatedOnboardingWizard> {
  int _currentStep = 1;
  final int _totalSteps = 6;

  // Step 1: Personal Information
  late TextEditingController _firstNameController;
  late TextEditingController _lastNameController;
  late TextEditingController _emailController;
  final _dobController = TextEditingController();
  String _selectedGender = 'Male';

  // Step 2: Address Details
  final _addressLineController = TextEditingController();
  final _cityController = TextEditingController();
  final _stateController = TextEditingController();
  final _pinCodeController = TextEditingController();
  final _countryController = TextEditingController();

  // Step 3: Sports & Experience
  final List<String> _allSports = [
    'Cricket',
    'Football',
    'Basketball',
    'Volleyball',
    'Badminton'
  ];
  final Set<String> _selectedSports = {};
  final _experienceController = TextEditingController();
  final _qualificationController = TextEditingController();

  // Step 4: Availability
  final List<String> _allDays = [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday'
  ];
  final Set<String> _selectedDays = {};
  final _preferredCityController = TextEditingController();
  final _travelRadiusController = TextEditingController();
  final _emergencyContactController = TextEditingController();

  // Step 5: Identity Verification
  bool _profilePhotoUploaded = false;
  bool _govIdUploaded = false;
  bool _sportsCertUploaded = false;
  bool _resumeUploaded = false;

  // Step 6: Review
  bool _confirmAccuracy = false;

  @override
  void initState() {
    super.initState();
    _firstNameController = TextEditingController(text: 'Mohit');
    _lastNameController = TextEditingController(text: 'Ahuja');
    _emailController = TextEditingController(
        text:
            widget.user.email.isEmpty ? 'mohit@email.com' : widget.user.email);
  }

  @override
  void dispose() {
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

  void _finishOnboarding() {
    if (!_confirmAccuracy) return;

    final updated = widget.user.copyWith(
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

    widget.onComplete(updated);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded,
              color: colorScheme.onSurface, size: 20),
          onPressed: () {
            if (_currentStep > 1) {
              setState(() => _currentStep--);
            } else {
              Navigator.of(context).pop();
            }
          },
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
        ),
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Ultra-thin minimal progress bar
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 32.0, vertical: 8.0),
              child: Row(
                children: List.generate(
                  _totalSteps,
                  (index) => Expanded(
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      margin: EdgeInsets.only(
                          right: index == _totalSteps - 1 ? 0 : 8),
                      height: 2,
                      decoration: BoxDecoration(
                        color: index < _currentStep
                            ? colorScheme.primary
                            : colorScheme.outline.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 400),
                switchInCurve: Curves.easeOutExpo,
                switchOutCurve: Curves.easeInExpo,
                child: SingleChildScrollView(
                  key: ValueKey<int>(_currentStep),
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(32.0, 8.0, 32.0, 64.0),
                  child: _buildCurrentStepContent(colorScheme, textTheme),
                ),
              ),
            ),
            // Minimalist Block Button matching Login Screen
            Padding(
              padding: const EdgeInsets.fromLTRB(32.0, 16.0, 32.0, 32.0),
              child: SizedBox(
                width: double.infinity,
                height: 64,
                child: FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: _currentStep == 6 && !_confirmAccuracy
                        ? colorScheme.outline.withOpacity(0.3)
                        : colorScheme.primary, // Sporto primaryGold
                    foregroundColor: colorScheme.onPrimary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    elevation: 0,
                  ),
                  onPressed: () {
                    if (_currentStep == 6 && !_confirmAccuracy) return;

                    if (_currentStep < _totalSteps) {
                      setState(() => _currentStep++);
                    } else {
                      _finishOnboarding();
                    }
                  },
                  child: Text(
                    _currentStep == _totalSteps
                        ? 'Submit Application'
                        : 'Continue',
                    style: textTheme.titleLarge?.copyWith(
                      color: _currentStep == 6 && !_confirmAccuracy
                          ? colorScheme.onSurfaceVariant
                          : colorScheme.onPrimary,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.5,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCurrentStepContent(
      ColorScheme colorScheme, TextTheme textTheme) {
    switch (_currentStep) {
      case 1:
        return _buildStep1PersonalInfo(colorScheme, textTheme);
      case 2:
        return _buildStep2Address(colorScheme, textTheme);
      case 3:
        return _buildStep3Sports(colorScheme, textTheme);
      case 4:
        return _buildStep4Availability(colorScheme, textTheme);
      case 5:
        return _buildStep5Identity(colorScheme, textTheme);
      case 6:
        return _buildStep6Review(colorScheme, textTheme);
      default:
        return const SizedBox.shrink();
    }
  }

  // --- STEPS ---

  Widget _buildStep1PersonalInfo(ColorScheme colorScheme, TextTheme textTheme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('Personal', 'Information', colorScheme, textTheme),
        _buildUnderlineInput(
            label: 'First Name',
            controller: _firstNameController,
            hint: 'Mohit',
            colorScheme: colorScheme,
            textTheme: textTheme),
        _buildUnderlineInput(
            label: 'Last Name',
            controller: _lastNameController,
            hint: 'Ahuja',
            colorScheme: colorScheme,
            textTheme: textTheme),
        _buildUnderlineInput(
            label: 'Email',
            controller: _emailController,
            hint: 'you@email.com',
            keyboardType: TextInputType.emailAddress,
            colorScheme: colorScheme,
            textTheme: textTheme),
        _buildUnderlineInput(
            label: 'Date of Birth',
            controller: _dobController,
            hint: 'DD / MM / YYYY',
            colorScheme: colorScheme,
            textTheme: textTheme),
        const SizedBox(height: 32),
        Text('Gender',
            style: textTheme.labelLarge?.copyWith(
                color: colorScheme.onSurfaceVariant, letterSpacing: 1.2)),
        const SizedBox(height: 16),
        Row(
          children: ['Male', 'Female', 'Others'].map((gender) {
            final isSelected = _selectedGender == gender;
            return GestureDetector(
              onTap: () => setState(() => _selectedGender = gender),
              child: Padding(
                padding: const EdgeInsets.only(right: 24.0),
                child: Text(
                  gender,
                  style: textTheme.displaySmall?.copyWith(
                    color: isSelected
                        ? colorScheme.primary
                        : colorScheme.onSurfaceVariant.withOpacity(0.4),
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                    letterSpacing: -1.0,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildStep2Address(ColorScheme colorScheme, TextTheme textTheme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('Current', 'Address', colorScheme, textTheme),
        _buildUnderlineInput(
            label: 'Street Address',
            controller: _addressLineController,
            hint: '123 Main St',
            colorScheme: colorScheme,
            textTheme: textTheme),
        _buildUnderlineInput(
            label: 'City',
            controller: _cityController,
            hint: 'Hyderabad',
            colorScheme: colorScheme,
            textTheme: textTheme),
        _buildUnderlineInput(
            label: 'State',
            controller: _stateController,
            hint: 'Telangana',
            colorScheme: colorScheme,
            textTheme: textTheme),
        _buildUnderlineInput(
            label: 'PIN Code',
            controller: _pinCodeController,
            hint: '000000',
            keyboardType: TextInputType.number,
            colorScheme: colorScheme,
            textTheme: textTheme),
        _buildUnderlineInput(
            label: 'Country',
            controller: _countryController,
            hint: 'India',
            colorScheme: colorScheme,
            textTheme: textTheme),
      ],
    );
  }

  Widget _buildStep3Sports(ColorScheme colorScheme, TextTheme textTheme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('Sports &', 'Experience', colorScheme, textTheme),
        const SizedBox(height: 16),
        ..._allSports.map((sport) => _buildMinimalistToggle(
              label: sport,
              isSelected: _selectedSports.contains(sport),
              onTap: () => setState(() {
                _selectedSports.contains(sport)
                    ? _selectedSports.remove(sport)
                    : _selectedSports.add(sport);
              }),
              colorScheme: colorScheme,
              textTheme: textTheme,
            )),
        const SizedBox(height: 48),
        _buildUnderlineInput(
            label: 'Years of Experience',
            controller: _experienceController,
            hint: '0',
            keyboardType: TextInputType.number,
            colorScheme: colorScheme,
            textTheme: textTheme),
        _buildUnderlineInput(
            label: 'Highest Qualification',
            controller: _qualificationController,
            hint: 'e.g. Level 2 Umpire',
            colorScheme: colorScheme,
            textTheme: textTheme),
      ],
    );
  }

  Widget _buildStep4Availability(ColorScheme colorScheme, TextTheme textTheme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('Your', 'Availability', colorScheme, textTheme),
        const SizedBox(height: 16),
        ..._allDays.map((day) => _buildMinimalistToggle(
              label: day,
              isSelected: _selectedDays.contains(day),
              onTap: () => setState(() {
                _selectedDays.contains(day)
                    ? _selectedDays.remove(day)
                    : _selectedDays.add(day);
              }),
              colorScheme: colorScheme,
              textTheme: textTheme,
            )),
        const SizedBox(height: 48),
        _buildUnderlineInput(
            label: 'Preferred City',
            controller: _preferredCityController,
            hint: 'Hyderabad',
            colorScheme: colorScheme,
            textTheme: textTheme),
        _buildUnderlineInput(
            label: 'Travel Radius',
            controller: _travelRadiusController,
            hint: '20 km',
            keyboardType: TextInputType.number,
            colorScheme: colorScheme,
            textTheme: textTheme),
        _buildUnderlineInput(
            label: 'Emergency Contact',
            controller: _emergencyContactController,
            hint: '00000 00000',
            keyboardType: TextInputType.phone,
            colorScheme: colorScheme,
            textTheme: textTheme),
      ],
    );
  }

  Widget _buildStep5Identity(ColorScheme colorScheme, TextTheme textTheme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('Identity', 'Verification', colorScheme, textTheme),
        const SizedBox(height: 16),
        _buildTypographicUpload(
            label: 'Profile Photo',
            isUploaded: _profilePhotoUploaded,
            onUpload: () => setState(() => _profilePhotoUploaded = true),
            onClear: () => setState(() => _profilePhotoUploaded = false),
            colorScheme: colorScheme,
            textTheme: textTheme),
        _buildTypographicUpload(
            label: 'Government ID',
            isUploaded: _govIdUploaded,
            onUpload: () => setState(() => _govIdUploaded = true),
            onClear: () => setState(() => _govIdUploaded = false),
            colorScheme: colorScheme,
            textTheme: textTheme),
        _buildTypographicUpload(
            label: 'Sports Certificate',
            isUploaded: _sportsCertUploaded,
            onUpload: () => setState(() => _sportsCertUploaded = true),
            onClear: () => setState(() => _sportsCertUploaded = false),
            isOptional: true,
            colorScheme: colorScheme,
            textTheme: textTheme),
        _buildTypographicUpload(
            label: 'Resume',
            isUploaded: _resumeUploaded,
            onUpload: () => setState(() => _resumeUploaded = true),
            onClear: () => setState(() => _resumeUploaded = false),
            isOptional: true,
            colorScheme: colorScheme,
            textTheme: textTheme),
      ],
    );
  }

  Widget _buildStep6Review(ColorScheme colorScheme, TextTheme textTheme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('Review', 'Application', colorScheme, textTheme),
        const SizedBox(height: 16),
        _buildReviewItem(
            'Applicant',
            '${_firstNameController.text} ${_lastNameController.text}',
            colorScheme,
            textTheme),
        _buildReviewItem(
            'Email', _emailController.text, colorScheme, textTheme),
        _buildReviewItem(
            'Sports',
            _selectedSports.isEmpty
                ? 'None selected'
                : _selectedSports.join(', '),
            colorScheme,
            textTheme),
        _buildReviewItem(
            'Experience',
            '${_experienceController.text.isEmpty ? '0' : _experienceController.text} Years',
            colorScheme,
            textTheme),
        const SizedBox(height: 32),
        Row(
          children: [
            Icon(Icons.verified_user_rounded,
                color: colorScheme.primary, size: 24),
            const SizedBox(width: 12),
            Text(
              'Documents Attached',
              style: textTheme.headlineMedium?.copyWith(
                  color: colorScheme.onSurface,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.5),
            ),
          ],
        ),
        const SizedBox(height: 64),
        GestureDetector(
          onTap: () => setState(() => _confirmAccuracy = !_confirmAccuracy),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: _confirmAccuracy
                      ? colorScheme.primary
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: _confirmAccuracy
                        ? colorScheme.primary
                        : colorScheme.onSurfaceVariant,
                    width: 2,
                  ),
                ),
                child: _confirmAccuracy
                    ? Icon(Icons.check_rounded,
                        color: colorScheme.onPrimary, size: 20)
                    : null,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  'I confirm all information provided is accurate and authentic.',
                  style: textTheme.bodyLarge?.copyWith(
                    color: colorScheme.onSurface,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // --- REUSABLE MINIMALIST WIDGETS ---

  Widget _buildSectionHeader(String titleLine1, String titleLine2,
      ColorScheme colorScheme, TextTheme textTheme) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 48.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            titleLine1,
            style: textTheme.displayLarge?.copyWith(
              fontWeight: FontWeight.w900,
              color: colorScheme.onSurface,
              letterSpacing: -1.5,
              height: 1.1,
            ),
          ),
          Text(
            titleLine2,
            style: textTheme.displayLarge?.copyWith(
              fontWeight: FontWeight.w900,
              color: colorScheme.primary, // Pop of gold
              letterSpacing: -1.5,
              height: 1.1,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUnderlineInput({
    required String label,
    required TextEditingController controller,
    required String hint,
    required ColorScheme colorScheme,
    required TextTheme textTheme,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 32.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label.toUpperCase(),
              style: textTheme.labelSmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                  letterSpacing: 1.5,
                  fontWeight: FontWeight.bold)),
          TextField(
            controller: controller,
            keyboardType: keyboardType,
            cursorColor: colorScheme.primary,
            style: textTheme.headlineMedium?.copyWith(
              color: colorScheme.onSurface,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.5,
            ),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: textTheme.headlineMedium?.copyWith(
                color: colorScheme.onSurfaceVariant.withOpacity(0.3),
                fontWeight: FontWeight.w700,
                letterSpacing: -0.5,
              ),
              border: UnderlineInputBorder(
                borderSide: BorderSide(
                    color: colorScheme.outline.withOpacity(0.3), width: 1.5),
              ),
              enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(
                    color: colorScheme.outline.withOpacity(0.3), width: 1.5),
              ),
              focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: colorScheme.primary, width: 2),
              ),
              contentPadding: const EdgeInsets.symmetric(vertical: 8),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMinimalistToggle({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
    required ColorScheme colorScheme,
    required TextTheme textTheme,
  }) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
                color: colorScheme.outline.withOpacity(0.2), width: 1),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: textTheme.headlineMedium?.copyWith(
                color: isSelected
                    ? colorScheme.onSurface
                    : colorScheme.onSurfaceVariant.withOpacity(0.5),
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                letterSpacing: -0.5,
              ),
            ),
            if (isSelected)
              Icon(Icons.check_rounded, color: colorScheme.primary, size: 28),
          ],
        ),
      ),
    );
  }

  Widget _buildTypographicUpload({
    required String label,
    required bool isUploaded,
    required VoidCallback onUpload,
    required VoidCallback onClear,
    bool isOptional = false,
    required ColorScheme colorScheme,
    required TextTheme textTheme,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 32.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(label.toUpperCase(),
                  style: textTheme.labelSmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                      letterSpacing: 1.5,
                      fontWeight: FontWeight.bold)),
              if (isOptional)
                Text(' (OPTIONAL)',
                    style: textTheme.labelSmall?.copyWith(
                        color: colorScheme.onSurfaceVariant.withOpacity(0.5),
                        letterSpacing: 1.5)),
            ],
          ),
          const SizedBox(height: 8),
          GestureDetector(
            onTap: isUploaded ? onClear : onUpload,
            child: Row(
              children: [
                Icon(
                  isUploaded
                      ? Icons.check_circle_rounded
                      : Icons.add_circle_outline_rounded,
                  color:
                      isUploaded ? colorScheme.primary : colorScheme.onSurface,
                  size: 32,
                ),
                const SizedBox(width: 16),
                Text(
                  isUploaded ? 'Document Attached' : 'Tap to Upload',
                  style: textTheme.headlineMedium?.copyWith(
                    color: isUploaded
                        ? colorScheme.primary
                        : colorScheme.onSurface,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.5,
                  ),
                ),
                if (isUploaded) ...[
                  const Spacer(),
                  Icon(Icons.close_rounded,
                      color: colorScheme.onSurfaceVariant),
                ]
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReviewItem(String label, String value, ColorScheme colorScheme,
      TextTheme textTheme) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label.toUpperCase(),
              style: textTheme.labelSmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                  letterSpacing: 1.5,
                  fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(
            value,
            style: textTheme.headlineMedium?.copyWith(
              color: colorScheme.onSurface,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.5,
            ),
          ),
        ],
      ),
    );
  }
}
