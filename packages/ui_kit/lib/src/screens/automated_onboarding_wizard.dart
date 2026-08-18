import 'dart:io';
import 'package:confetti/confetti.dart';
import 'package:flutter/foundation.dart';
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

class InitialOnboardingData {
  final String? addressLine1;
  final String? addressLine2;
  final String? city;
  final String? state;
  final String? pincode;
  final String? country;
  final String? highestQualification;
  final String? presentOccupation;
  final List<String> sports;
  final int experienceYears;
  final Map<String, String> documents;

  const InitialOnboardingData({
    this.addressLine1,
    this.addressLine2,
    this.city,
    this.state,
    this.pincode,
    this.country,
    this.highestQualification,
    this.presentOccupation,
    this.sports = const [],
    this.experienceYears = 0,
    this.documents = const {},
  });
}

// ============================================================
// MAIN WIDGET
// ============================================================
class AutomatedOnboardingWizard extends StatefulWidget {
  final UserEntity user;
  final int initialStep;
  final InitialOnboardingData? initialData;
  final Function(UserEntity updatedUser) onComplete;
  final Future<void> Function(OnboardingSubmission submission)?
      onSubmitOnboarding;
  final Future<void> Function(
      OnboardingSubmission submission, int completedStep)? onContinueStep;
  final Future<String?> Function(OnboardingUploadType type)? onPickDocument;
  final Future<String?> Function(OnboardingUploadType type, String filePath)?
      onUploadDocumentFile;
  final Future<String?> Function(OnboardingUploadType type)? onUploadDocument;
  final VoidCallback? onTrackApplication;
  final VoidCallback? onGoHome;

  const AutomatedOnboardingWizard({
    super.key,
    required this.user,
    this.initialStep = 1,
    this.initialData,
    required this.onComplete,
    this.onSubmitOnboarding,
    this.onContinueStep,
    this.onPickDocument,
    this.onUploadDocumentFile,
    this.onUploadDocument,
    this.onTrackApplication,
    this.onGoHome,
  });

  @override
  State<AutomatedOnboardingWizard> createState() =>
      _AutomatedOnboardingWizardState();
}

class _AutomatedOnboardingWizardState extends State<AutomatedOnboardingWizard> {
  late int _currentStep;
  bool get _isReferee => widget.user.role == 'referee';
  int get _totalSteps => _isReferee ? 6 : 5;

  // Step 1
  late TextEditingController _firstNameController;
  late TextEditingController _lastNameController;
  late TextEditingController _emailController;
  late TextEditingController _dobController;
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
  final Set<String> _selectedSports = {};
  final _experienceController = TextEditingController();
  final _qualificationController = TextEditingController();
  final _occupationController = TextEditingController();

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
  final Set<String> _selectedDays = {};
  final _preferredCityController = TextEditingController();
  final _travelRadiusController = TextEditingController();
  final _emergencyContactController = TextEditingController();

  // Step 5
  bool _profilePhotoUploaded = false;
  bool _govIdUploaded = false;
  bool _sportsCertUploaded = false;
  bool _resumeUploaded = false;
  String? _profilePhotoPath;
  String? _governmentIdPath;
  String? _sportsCertificatePath;
  String? _resumePath;
  OnboardingUploadType? _uploadingDocumentType;

  // Step 6
  bool _confirmAccuracy = false;

  // Post-submit state
  UserEntity? _pendingUser;
  bool _applicationSubmitted = false;
  bool _isSubmittingOnboarding = false;
  String? _submissionError;
  final Map<String, String> _fieldErrors = {};
  late final ConfettiController _confettiController;
  @override
  void initState() {
    super.initState();
    _currentStep = widget.initialStep.clamp(1, _totalSteps);
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
    _dobController = TextEditingController(
      text: _normaliseDob(widget.user.dob),
    );
    if (widget.user.gender != null && widget.user.gender!.isNotEmpty) {
      _selectedGender = widget.user.gender;
    }

    final data = widget.initialData;
    if (data != null) {
      if (data.addressLine1 != null && data.addressLine1!.isNotEmpty) {
        _addressLineController.text = data.addressLine1!;
      }
      if (data.addressLine2 != null && data.addressLine2!.isNotEmpty) {
        // addressLine2 handled if needed
      }
      if (data.city != null && data.city!.isNotEmpty) {
        _cityController.text = data.city!;
      } else if (widget.user.city != null && widget.user.city!.isNotEmpty) {
        _cityController.text = widget.user.city!;
      }
      if (data.state != null && data.state!.isNotEmpty) {
        _stateController.text = data.state!;
      } else if (widget.user.state != null && widget.user.state!.isNotEmpty) {
        _stateController.text = widget.user.state!;
      }
      if (data.pincode != null && data.pincode!.isNotEmpty) {
        _pinCodeController.text = data.pincode!;
      }
      if (data.country != null && data.country!.isNotEmpty) {
        _countryController.text = data.country!;
      }

      if (data.highestQualification != null &&
          data.highestQualification!.isNotEmpty) {
        _qualificationController.text = data.highestQualification!;
      }
      if (data.presentOccupation != null && data.presentOccupation!.isNotEmpty) {
        _occupationController.text = data.presentOccupation!;
      }

      if (data.sports.isNotEmpty) {
        _selectedSports.addAll(data.sports);
      }
      if (data.experienceYears > 0) {
        _experienceController.text = data.experienceYears.toString();
      }

      if (data.documents.containsKey('profile_photo')) {
        _profilePhotoUploaded = true;
        _profilePhotoPath = data.documents['profile_photo'];
      }
      if (data.documents.containsKey('government_id')) {
        _govIdUploaded = true;
        _governmentIdPath = data.documents['government_id'];
      }
      if (data.documents.containsKey('sports_certificate')) {
        _sportsCertUploaded = true;
        _sportsCertificatePath = data.documents['sports_certificate'];
      }
      if (data.documents.containsKey('resume')) {
        _resumeUploaded = true;
        _resumePath = data.documents['resume'];
      }
    } else {
      if (widget.user.city != null && widget.user.city!.isNotEmpty) {
        _cityController.text = widget.user.city!;
      }
      if (widget.user.state != null && widget.user.state!.isNotEmpty) {
        _stateController.text = widget.user.state!;
      }
    }

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
    _occupationController.dispose();
    _preferredCityController.dispose();
    _travelRadiusController.dispose();
    _emergencyContactController.dispose();
    super.dispose();
  }

  void _clearFieldError(String field) {
    if (!_fieldErrors.containsKey(field)) return;
    setState(() {
      _fieldErrors.remove(field);
      _submissionError = null;
    });
  }

  bool _validateCurrentStep() {
    final errors = <String, String>{};
    switch (_currentStep) {
      case 1:
        _validatePersonalInfo(errors);
      case 2:
        _validateAddress(errors);
      case 3:
        _validateSportsAndExperience(errors);
      case 4:
        if (_isReferee) {
          _validateAvailability(errors);
        } else {
          _validateDocuments(errors);
        }
      case 5:
        if (_isReferee) {
          _validateDocuments(errors);
        } else {
          _validateReview(errors);
        }
      case 6:
        _validateReview(errors);
    }

    setState(() {
      _fieldErrors
        ..clear()
        ..addAll(errors);
      _submissionError = errors.isEmpty ? null : errors.values.first;
    });
    return errors.isEmpty;
  }

  void _validatePersonalInfo(Map<String, String> errors) {
    _validateName(
        errors, 'firstName', _firstNameController.text.trim(), 'First name');
    _validateName(
        errors, 'lastName', _lastNameController.text.trim(), 'Last name');
    final email = _emailController.text.trim();
    if (email.isEmpty) {
      errors['email'] = 'Email address is required.';
    } else if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(email)) {
      errors['email'] = 'Enter a valid email address.';
    }
    final dob = _dobController.text.trim();
    if (dob.isEmpty) {
      errors['dateOfBirth'] = 'Date of birth is required.';
    } else if (!_isValidDob(dob)) {
      errors['dateOfBirth'] = 'Select a valid date of birth.';
    }
    if (_selectedGender == null) {
      errors['gender'] = 'Select gender.';
    }
  }

  void _validateAddress(Map<String, String> errors) {
    _validateRequiredMin(errors, 'addressLine1',
        _addressLineController.text.trim(), 'Address line', 3);
    _validateRequiredMin(
        errors, 'city', _cityController.text.trim(), 'City', 2);
    _validateRequiredMin(
        errors, 'state', _stateController.text.trim(), 'State', 2);
    final pincode = _pinCodeController.text.trim();
    if (pincode.isEmpty) {
      errors['pincode'] = 'PIN code is required.';
    } else if (!RegExp(r'^\d{6}$').hasMatch(pincode)) {
      errors['pincode'] = 'Enter a valid 6-digit PIN code.';
    }
    _validateRequiredMin(
        errors, 'country', _countryController.text.trim(), 'Country', 2);
  }

  void _validateSportsAndExperience(Map<String, String> errors) {
    if (_selectedSports.isEmpty) {
      errors['sports'] = _isReferee
          ? 'Select at least one sport you can officiate.'
          : 'Select at least one sport you organize.';
    }
    final experienceText = _experienceController.text.trim();
    final experience = int.tryParse(experienceText);
    if (experienceText.isEmpty) {
      errors['experienceYears'] = 'Years of experience is required.';
    } else if (experience == null || experience < 0 || experience > 60) {
      errors['experienceYears'] = 'Experience must be between 0 and 60 years.';
    }
    _validateRequiredMin(errors, 'highestQualification',
        _qualificationController.text.trim(), 'Highest qualification', 2);
    _validateRequiredMin(errors, 'presentOccupation',
        _occupationController.text.trim(), 'Present occupation', 2);
  }

  void _validateAvailability(Map<String, String> errors) {
    if (_selectedDays.isEmpty) {
      errors['availabilityDays'] = 'Select at least one available day.';
    }
    _validateRequiredMin(errors, 'preferredCity',
        _preferredCityController.text.trim(), 'Preferred city', 2);
    final radiusText = _travelRadiusController.text.trim();
    final radius = int.tryParse(radiusText);
    if (radiusText.isEmpty) {
      errors['travelRadius'] = 'Travel radius is required.';
    } else if (radius == null || radius <= 0 || radius > 500) {
      errors['travelRadius'] = 'Travel radius must be between 1 and 500 km.';
    }
    final emergency = _emergencyContactController.text.trim();
    if (emergency.isEmpty) {
      errors['emergencyContact'] = 'Emergency contact is required.';
    } else if (!RegExp(r'^\d{10}$').hasMatch(emergency)) {
      errors['emergencyContact'] = 'Enter a valid 10-digit mobile number.';
    }
  }

  void _validateDocuments(Map<String, String> errors) {
    if (!_govIdUploaded) {
      errors['governmentId'] = 'Government ID document is required.';
    }
  }

  void _validateReview(Map<String, String> errors) {
    if (!_confirmAccuracy) {
      errors['confirmAccuracy'] = 'Confirm that all information is accurate.';
    }
  }

  void _validateName(
      Map<String, String> errors, String key, String value, String label) {
    if (value.isEmpty) {
      errors[key] = '$label is required.';
    } else if (value.length < 2) {
      errors[key] = '$label must be at least 2 characters.';
    } else if (!RegExp(r"^[A-Za-z][A-Za-z\s'.-]*$").hasMatch(value)) {
      errors[key] = 'Enter a valid $label.';
    }
  }

  void _validateRequiredMin(Map<String, String> errors, String key,
      String value, String label, int minLength) {
    if (value.isEmpty) {
      errors[key] = '$label is required.';
    } else if (value.length < minLength) {
      errors[key] = '$label must be at least $minLength characters.';
    }
  }

  bool _isValidDob(String value) {
    final parsed = _parseApiDate(value);
    if (parsed == null) return false;
    final now = DateTime.now();
    final age = now.year -
        parsed.year -
        ((now.month < parsed.month ||
                (now.month == parsed.month && now.day < parsed.day))
            ? 1
            : 0);
    return age >= 13 && age <= 100;
  }

  DateTime? _parseApiDate(String value) {
    if (!RegExp(r'^\d{4}-\d{2}-\d{2}$').hasMatch(value)) return null;
    final parsed = DateTime.tryParse(value);
    if (parsed == null || value != _formatApiDate(parsed)) return null;
    return parsed;
  }

  String _normaliseDob(String? value) {
    if (value == null || value.trim().isEmpty) return '';
    final parsed = DateTime.tryParse(value.trim());
    return parsed == null ? '' : _formatApiDate(parsed);
  }

  String _formatApiDate(DateTime date) {
    return '${date.year.toString().padLeft(4, '0')}-'
        '${date.month.toString().padLeft(2, '0')}-'
        '${date.day.toString().padLeft(2, '0')}';
  }

  Future<void> _pickDateOfBirth() async {
    FocusScope.of(context).unfocus();
    final now = DateTime.now();
    final latestAllowed = DateTime(now.year - 13, now.month, now.day);
    final earliestAllowed = DateTime(now.year - 100, now.month, now.day);
    final existingDate = _parseApiDate(_dobController.text.trim());
    final initialDate = existingDate == null
        ? DateTime(now.year - 18, now.month, now.day)
        : existingDate.isBefore(earliestAllowed)
            ? earliestAllowed
            : existingDate.isAfter(latestAllowed)
                ? latestAllowed
                : existingDate;

    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: earliestAllowed,
      lastDate: latestAllowed,
      helpText: 'Select date of birth',
      cancelText: 'Cancel',
      confirmText: 'Done',
      builder: (context, child) {
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
          ),
          child: child ?? const SizedBox.shrink(),
        );
      },
    );

    if (picked == null || !mounted) return;
    setState(() {
      _dobController.text = _formatApiDate(picked);
      _fieldErrors.remove('dateOfBirth');
      _submissionError = null;
    });
  }

  bool _isLocalFile(String? path) {
    if (path == null || path.trim().isEmpty) return false;
    final trimmed = path.trim();
    if (trimmed.startsWith('http://') || trimmed.startsWith('https://')) return false;
    return true;
  }

  Future<void> _uploadPendingDocuments() async {
    if (_profilePhotoUploaded && _isLocalFile(_profilePhotoPath)) {
      final serverUrl = await _uploadSingleDocument(
        OnboardingUploadType.profilePhoto,
        _profilePhotoPath!,
      );
      if (serverUrl != null && serverUrl.isNotEmpty) {
        _profilePhotoPath = serverUrl;
      }
    }
    if (_govIdUploaded && _isLocalFile(_governmentIdPath)) {
      final serverUrl = await _uploadSingleDocument(
        OnboardingUploadType.governmentId,
        _governmentIdPath!,
      );
      if (serverUrl != null && serverUrl.isNotEmpty) {
        _governmentIdPath = serverUrl;
      }
    }
    if (_sportsCertUploaded && _isLocalFile(_sportsCertificatePath)) {
      final serverUrl = await _uploadSingleDocument(
        OnboardingUploadType.sportsCertificate,
        _sportsCertificatePath!,
      );
      if (serverUrl != null && serverUrl.isNotEmpty) {
        _sportsCertificatePath = serverUrl;
      }
    }
    if (_resumeUploaded && _isLocalFile(_resumePath)) {
      final serverUrl = await _uploadSingleDocument(
        OnboardingUploadType.resume,
        _resumePath!,
      );
      if (serverUrl != null && serverUrl.isNotEmpty) {
        _resumePath = serverUrl;
      }
    }
  }

  Future<String?> _uploadSingleDocument(
    OnboardingUploadType type,
    String localPath,
  ) async {
    if (widget.onUploadDocumentFile != null) {
      return await widget.onUploadDocumentFile!(type, localPath);
    }
    if (widget.onUploadDocument != null) {
      return await widget.onUploadDocument!(type);
    }
    return localPath;
  }

  Future<void> _finishOnboarding() async {
    if (!_confirmAccuracy || _isSubmittingOnboarding) return;
    if (!_validateCurrentStep()) return;

    setState(() {
      _isSubmittingOnboarding = true;
      _submissionError = null;
    });

    try {
      await _uploadPendingDocuments();

      final updatedUser = widget.user.copyWith(
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

      await widget.onSubmitOnboarding?.call(_buildSubmission(updatedUser));
      _pendingUser = updatedUser;
      if (!mounted) return;
      setState(() {
        _isSubmittingOnboarding = false;
        _applicationSubmitted = true;
      });
      _confettiController.play();
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _isSubmittingOnboarding = false;
        _submissionError = error.toString();
      });
    }
  }

  OnboardingSubmission _buildSubmission(UserEntity updatedUser) {
    return OnboardingSubmission(
      user: updatedUser,
      firstName: _firstNameController.text.trim(),
      lastName: _lastNameController.text.trim(),
      email: _emailController.text.trim(),
      dateOfBirth: _dobController.text.trim(),
      gender: _selectedGender?.toLowerCase() ?? '',
      addressLine1: _addressLineController.text.trim(),
      city: _cityController.text.trim(),
      state: _stateController.text.trim(),
      country: _countryController.text.trim(),
      pincode: _pinCodeController.text.trim(),
      selectedSports: _selectedSports.toList(),
      experienceYears: int.tryParse(_experienceController.text.trim()) ?? 0,
      highestQualification: _qualificationController.text.trim(),
      presentOccupation: _occupationController.text.trim(),
      hasProfilePhoto: _profilePhotoUploaded,
      hasGovernmentId: _govIdUploaded,
      hasSportsCertificate: _sportsCertUploaded,
      hasResume: _resumeUploaded,
      profilePhotoPath: _profilePhotoPath,
      governmentIdPath: _governmentIdPath,
      sportsCertificatePath: _sportsCertificatePath,
      resumePath: _resumePath,
      availableDays: _selectedDays.toList(),
      preferredCity: _preferredCityController.text.trim(),
      travelRadiusKm: int.tryParse(_travelRadiusController.text.trim()),
      emergencyContact: _emergencyContactController.text.trim(),
    );
  }

  Future<void> _uploadDocument(OnboardingUploadType type) async {
    if (_uploadingDocumentType != null) return;
    setState(() {
      _submissionError = null;
    });
    try {
      final localPath = widget.onPickDocument != null
          ? await widget.onPickDocument!.call(type)
          : await widget.onUploadDocument?.call(type);
      if (localPath == null || localPath.trim().isEmpty) return;
      if (!mounted) return;
      setState(() {
        switch (type) {
          case OnboardingUploadType.profilePhoto:
            _profilePhotoUploaded = true;
            _profilePhotoPath = localPath;
          case OnboardingUploadType.governmentId:
            _govIdUploaded = true;
            _governmentIdPath = localPath;
            _fieldErrors.remove('governmentId');
          case OnboardingUploadType.sportsCertificate:
            _sportsCertUploaded = true;
            _sportsCertificatePath = localPath;
          case OnboardingUploadType.resume:
            _resumeUploaded = true;
            _resumePath = localPath;
        }
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _submissionError = error.toString();
      });
    }
  }

  Future<bool> _onBackRequested() async {
    if (_currentStep > 1) {
      final confirm = await showDialog<bool>(
        context: context,
        builder: (context) {
          final theme = Theme.of(context);
          final cs = theme.colorScheme;
          final tt = theme.textTheme;
          final scale = context.sportoScale;
          return AlertDialog(
            backgroundColor: cs.surface,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18 * scale),
              side: BorderSide(color: cs.outlineVariant),
            ),
            title: Text(
              'Navigate Back?',
              style: tt.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
                color: cs.onSurface,
                fontSize: 18 * scale,
              ),
            ),
            content: Text(
              'Going back will allow you to view or edit previous steps. Are you sure you want to go back?',
              style: tt.bodyMedium?.copyWith(
                color: cs.onSurfaceVariant,
                fontSize: 14 * scale,
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: Text(
                  'Cancel',
                  style: TextStyle(color: cs.onSurfaceVariant),
                ),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: Text(
                  'Go Back',
                  style: TextStyle(
                    color: cs.tertiary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          );
        },
      );
      if (confirm == true) {
        setState(() => _currentStep--);
      }
      return false;
    } else {
      final confirm = await showDialog<bool>(
        context: context,
        builder: (context) {
          final theme = Theme.of(context);
          final cs = theme.colorScheme;
          final tt = theme.textTheme;
          final scale = context.sportoScale;
          return AlertDialog(
            backgroundColor: cs.surface,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18 * scale),
              side: BorderSide(color: cs.outlineVariant),
            ),
            title: Text(
              'Leave Onboarding?',
              style: tt.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
                color: cs.onSurface,
                fontSize: 18 * scale,
              ),
            ),
            content: Text(
              'Are you sure you want to exit the onboarding process?',
              style: tt.bodyMedium?.copyWith(
                color: cs.onSurfaceVariant,
                fontSize: 14 * scale,
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: Text(
                  'Cancel',
                  style: TextStyle(color: cs.onSurfaceVariant),
                ),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: Text(
                  'Exit',
                  style: TextStyle(
                    color: cs.error,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          );
        },
      );
      if (confirm == true) {
        widget.onGoHome?.call();
      }
      return false;
    }
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

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          _onBackRequested();
        }
      },
      child: Scaffold(
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
                          onTap: _onBackRequested,
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
                          _isReferee
                              ? 'Apply as Referee'
                              : 'Complete Partner Profile',
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
                            label: _isSubmittingOnboarding
                                ? 'Submitting...'
                                : isLastStep
                                    ? 'Submit Application'
                                    : 'Continue',
                            disabled: submitDisabled || _isSubmittingOnboarding,
                            onPressed: () async {
                              if (submitDisabled || _isSubmittingOnboarding)
                                return;
                              if (!_validateCurrentStep()) return;
                              if (_currentStep < _totalSteps) {
                                setState(() {
                                  _isSubmittingOnboarding = true;
                                  _submissionError = null;
                                });
                                try {
                                  await _uploadPendingDocuments();
                                  await widget.onContinueStep?.call(
                                    _buildSubmission(widget.user),
                                    _currentStep,
                                  );
                                } catch (error) {
                                  if (!mounted) return;
                                  setState(() {
                                    _isSubmittingOnboarding = false;
                                    _submissionError = error.toString();
                                  });
                                  return;
                                }
                                if (!mounted) return;
                                setState(() {
                                  _isSubmittingOnboarding = false;
                                  _currentStep++;
                                });
                              } else {
                                _finishOnboarding();
                              }
                            },
                          ),
                          if (_submissionError != null) ...[
                            SizedBox(height: scaled(12)),
                            Text(
                              _submissionError!,
                              textAlign: TextAlign.center,
                              style: tt.bodyMedium?.copyWith(
                                color: cs.error,
                                fontSize: scaled(12),
                              ),
                            ),
                          ],
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
        return _isReferee
            ? _buildStep4Availability(cs, tt)
            : _buildStep5Identity(cs, tt);
      case 5:
        return _isReferee
            ? _buildStep5Identity(cs, tt)
            : _buildStep6Review(cs, tt);
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
            fieldKey: 'firstName',
            label: 'First Name',
            controller: _firstNameController,
            hint: 'Enter your first name',
            cs: cs,
            tt: tt),
        _buildGlassInput(
            fieldKey: 'lastName',
            label: 'Last Name',
            controller: _lastNameController,
            hint: 'Enter your last name',
            cs: cs,
            tt: tt),
        _buildGlassInput(
            fieldKey: 'email',
            label: 'Email Address',
            controller: _emailController,
            hint: 'Enter your email address',
            keyboardType: TextInputType.emailAddress,
            cs: cs,
            tt: tt),
        _buildGlassInput(
            fieldKey: 'dateOfBirth',
            label: 'Date of Birth',
            controller: _dobController,
            hint: 'Select date of birth',
            readOnly: true,
            onTap: _pickDateOfBirth,
            suffixIcon: SportoAssetIcon(
              SportoAssets.calendarTick,
              color: cs.onSurfaceVariant,
              size: 18 * scale,
            ),
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
        _buildFieldError('gender', tt, cs),
      ],
    );
  }

  Widget _buildGenderPill(
      String gender, IconData? icon, ColorScheme cs, TextTheme tt) {
    final isSelected = _selectedGender == gender;
    final scale = context.sportoScale;
    final asset = switch (gender) {
      'Male' => SportoAssets.genderMale,
      'Female' => SportoAssets.genderFemale,
      _ => null,
    };
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() {
          _selectedGender = gender;
          _fieldErrors.remove('gender');
        }),
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
              if (asset != null || icon != null) ...[
                if (asset != null)
                  SportoAssetIcon(
                    asset,
                    size: 18 * scale,
                    color: isSelected ? cs.tertiary : cs.onSurfaceVariant,
                  )
                else
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
            fieldKey: 'addressLine1',
            label: 'Address Line',
            controller: _addressLineController,
            hint: 'Enter your address line',
            cs: cs,
            tt: tt),
        _buildGlassInput(
            fieldKey: 'city',
            label: 'City',
            controller: _cityController,
            hint: 'Enter your city name',
            cs: cs,
            tt: tt),
        _buildGlassInput(
            fieldKey: 'state',
            label: 'State',
            controller: _stateController,
            hint: 'Enter your state name',
            cs: cs,
            tt: tt),
        _buildGlassInput(
            fieldKey: 'pincode',
            label: 'PIN Code',
            controller: _pinCodeController,
            hint: 'Enter PIN code',
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            cs: cs,
            tt: tt),
        _buildGlassInput(
            fieldKey: 'country',
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
          'Sports & Experience',
          _isReferee ? 'Sports You Can Officiate' : 'Sports You Organize',
          cs,
          tt,
        ),
        ..._allSports.map((sport) => _buildCheckRow(
              label: sport,
              isSelected: _selectedSports.contains(sport),
              onTap: () => setState(() {
                _selectedSports.contains(sport)
                    ? _selectedSports.remove(sport)
                    : _selectedSports.add(sport);
                _fieldErrors.remove('sports');
              }),
              cs: cs,
              tt: tt,
            )),
        _buildFieldError('sports', tt, cs),
        const SizedBox(height: 28),
        _buildGlassInput(
            fieldKey: 'experienceYears',
            label: 'Years of Experience',
            controller: _experienceController,
            hint: 'Enter your years of experience',
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            cs: cs,
            tt: tt),
        _buildGlassInput(
            fieldKey: 'highestQualification',
            label: 'Highest Qualification',
            controller: _qualificationController,
            hint: 'Enter your highest qualification',
            cs: cs,
            tt: tt),
        _buildGlassInput(
            fieldKey: 'presentOccupation',
            label: 'Present Occupation',
            controller: _occupationController,
            hint: 'Enter your present occupation',
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
                _fieldErrors.remove('availabilityDays');
              }),
              cs: cs,
              tt: tt,
            )),
        _buildFieldError('availabilityDays', tt, cs),
        const SizedBox(height: 28),
        _buildGlassInput(
            fieldKey: 'preferredCity',
            label: 'Preferred City',
            controller: _preferredCityController,
            hint: 'Enter your preferred city',
            cs: cs,
            tt: tt),
        _buildGlassInput(
            fieldKey: 'travelRadius',
            label: 'Travel Radius (in kilometer)',
            controller: _travelRadiusController,
            hint: 'Ex. 20 km',
            keyboardType: TextInputType.number,
            cs: cs,
            tt: tt),
        _buildGlassInput(
            fieldKey: 'emergencyContact',
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
            uploadedPath: _profilePhotoPath,
            isUploading:
                _uploadingDocumentType == OnboardingUploadType.profilePhoto,
            onUpload: () => _uploadDocument(OnboardingUploadType.profilePhoto),
            onClear: () => setState(() {
                  _profilePhotoUploaded = false;
                  _profilePhotoPath = null;
                }),
            wide: false,
            cs: cs,
            tt: tt),
        _buildUploadTile(
            label: 'Government ID',
            isUploaded: _govIdUploaded,
            uploadedPath: _governmentIdPath,
            isUploading:
                _uploadingDocumentType == OnboardingUploadType.governmentId,
            onUpload: () => _uploadDocument(OnboardingUploadType.governmentId),
            onClear: () => setState(() {
                  _govIdUploaded = false;
                  _governmentIdPath = null;
                  _fieldErrors['governmentId'] =
                      'Government ID document is required.';
                }),
            wide: false,
            cs: cs,
            tt: tt),
        _buildFieldError('governmentId', tt, cs),
        _buildUploadTile(
            label: 'Sports Certificate (Optional)',
            isUploaded: _sportsCertUploaded,
            uploadedPath: _sportsCertificatePath,
            isUploading: _uploadingDocumentType ==
                OnboardingUploadType.sportsCertificate,
            onUpload: () =>
                _uploadDocument(OnboardingUploadType.sportsCertificate),
            onClear: () => setState(() {
                  _sportsCertUploaded = false;
                  _sportsCertificatePath = null;
                }),
            wide: false,
            cs: cs,
            tt: tt),
        _buildUploadTile(
            label: 'Resume (Optional)',
            isUploaded: _resumeUploaded,
            uploadedPath: _resumePath,
            isUploading: _uploadingDocumentType == OnboardingUploadType.resume,
            onUpload: () => _uploadDocument(OnboardingUploadType.resume),
            onClear: () => setState(() {
                  _resumeUploaded = false;
                  _resumePath = null;
                }),
            wide: true,
            cs: cs,
            tt: tt),
      ],
    );
  }

  Widget _buildUploadTile({
    required String label,
    required bool isUploaded,
    required bool isUploading,
    required VoidCallback onUpload,
    required VoidCallback onClear,
    required bool wide,
    required ColorScheme cs,
    required TextTheme tt,
    String? uploadedPath,
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
      borderColor: isUploaded ? cs.secondary : SportoCard.defaultBorder,
      backgroundColor: cs.onSurface.withValues(alpha: 0.12),
      padding: EdgeInsets.zero,
      child: Center(
        child: isUploading
            ? SizedBox(
                width: 22 * scale,
                height: 22 * scale,
                child: CircularProgressIndicator(
                  strokeWidth: 2 * scale,
                  color: cs.tertiary,
                ),
              )
            : isUploaded
                ? _buildFilePreviewTile(
                    uploadedPath: uploadedPath,
                    wide: wide,
                    cs: cs,
                    tt: tt,
                    scale: scale,
                  )
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
      onTap: isUploaded || isUploading ? null : onUpload,
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

  Widget _buildFilePreviewTile({
    required String? uploadedPath,
    required bool wide,
    required ColorScheme cs,
    required TextTheme tt,
    required double scale,
  }) {
    final path = uploadedPath?.trim() ?? '';
    final fileName = path.isEmpty ? 'Uploaded' : path.split(RegExp(r'[/\\]')).last;
    final lower = path.toLowerCase();
    final isImage = lower.endsWith('.png') ||
        lower.endsWith('.jpg') ||
        lower.endsWith('.jpeg') ||
        lower.endsWith('.webp') ||
        lower.endsWith('.gif') ||
        lower.endsWith('.heic') ||
        lower.startsWith('http') ||
        lower.contains('users/documents/') ||
        lower.contains('users/profile/');

    if (wide) {
      return Padding(
        padding: EdgeInsets.symmetric(horizontal: 12 * scale),
        child: Row(
          children: [
            Icon(
              isImage ? Icons.image_rounded : Icons.insert_drive_file_rounded,
              color: cs.secondary,
              size: 20 * scale,
            ),
            SizedBox(width: 8 * scale),
            Expanded(
              child: Text(
                fileName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: tt.bodyMedium?.copyWith(
                  color: cs.onSurface,
                  fontSize: 13 * scale,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            SizedBox(width: 6 * scale),
            Icon(
              Icons.check_circle_rounded,
              color: cs.secondary,
              size: 18 * scale,
            ),
          ],
        ),
      );
    }

    if (isImage && path.isNotEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(14 * scale),
        child: Stack(
          fit: StackFit.expand,
          children: [
            _buildImageWidget(path, cs, tt, scale, fileName),
            Positioned(
              top: 6 * scale,
              right: 6 * scale,
              child: Container(
                padding: EdgeInsets.all(2 * scale),
                decoration: const BoxDecoration(
                  color: Colors.black54,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.check_circle_rounded,
                  color: cs.secondary,
                  size: 18 * scale,
                ),
              ),
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: 6 * scale,
                  vertical: 4 * scale,
                ),
                color: Colors.black.withValues(alpha: 0.65),
                child: Text(
                  fileName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: tt.bodySmall?.copyWith(
                    color: Colors.white,
                    fontSize: 10 * scale,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }

    return Padding(
      padding: EdgeInsets.all(8 * scale),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.insert_drive_file_rounded,
                color: cs.secondary,
                size: 24 * scale,
              ),
              SizedBox(width: 4 * scale),
              Icon(
                Icons.check_circle_rounded,
                color: cs.secondary,
                size: 16 * scale,
              ),
            ],
          ),
          SizedBox(height: 6 * scale),
          Text(
            fileName,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: tt.bodySmall?.copyWith(
              color: cs.onSurface,
              fontSize: 11 * scale,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImageWidget(
    String path,
    ColorScheme cs,
    TextTheme tt,
    double scale,
    String fileName,
  ) {
    String resolvedUrl = path.trim();
    if (!resolvedUrl.startsWith('http://') &&
        !resolvedUrl.startsWith('https://') &&
        !resolvedUrl.startsWith('/') &&
        !resolvedUrl.contains(':\\')) {
      resolvedUrl =
          'https://pub-c94d45e28dfa4bf08b2cd5d22adb73e6.r2.dev/$resolvedUrl';
    }

    if (resolvedUrl.startsWith('http://') || resolvedUrl.startsWith('https://')) {
      return Image.network(
        resolvedUrl,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) =>
            _buildFallbackDocWidget(cs, tt, scale, fileName),
      );
    }
    if (kIsWeb) {
      return Image.network(
        resolvedUrl,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) =>
            _buildFallbackDocWidget(cs, tt, scale, fileName),
      );
    }
    final file = File(path);
    if (file.existsSync()) {
      return Image.file(
        file,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) =>
            _buildFallbackDocWidget(cs, tt, scale, fileName),
      );
    }
    return _buildFallbackDocWidget(cs, tt, scale, fileName);
  }

  Widget _buildFallbackDocWidget(
    ColorScheme cs,
    TextTheme tt,
    double scale,
    String fileName,
  ) {
    return Container(
      color: cs.onSurface.withValues(alpha: 0.15),
      child: Center(
        child: Icon(
          Icons.insert_drive_file_rounded,
          color: cs.secondary,
          size: 28 * scale,
        ),
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
    final displayMobile = widget.user.mobileNumber.trim().isNotEmpty
        ? widget.user.mobileNumber
        : (_emergencyContactController.text.trim().isNotEmpty
            ? _emergencyContactController.text.trim()
            : 'Not provided');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(
          _isReferee ? 'Review Application' : 'Review Profile',
          _isReferee ? 'Sports You Can Officiate' : 'Sports You Organize',
          cs,
          tt,
        ),

        // Card 1: name (white) + sports (blue), NO gray label
        _ReviewCard(value: fullName, sub: sports),

        // Labeled cards: gray label + blue value
        _ReviewCard(label: 'Mobile', value: displayMobile),
        _ReviewCard(label: 'Email', value: _emailController.text.trim()),
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
        _buildFieldError('confirmAccuracy', tt, cs),
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
    required String fieldKey,
    required String label,
    required TextEditingController controller,
    required String hint,
    required ColorScheme cs,
    required TextTheme tt,
    TextInputType keyboardType = TextInputType.text,
    List<TextInputFormatter>? inputFormatters,
    bool readOnly = false,
    VoidCallback? onTap,
    Widget? suffixIcon,
  }) {
    final scale = context.sportoScale;
    return Padding(
      padding: EdgeInsets.only(bottom: 18 * scale),
      child: SportoTextField(
        label: label,
        hint: hint,
        controller: controller,
        readOnly: readOnly,
        onTap: onTap,
        suffixIcon: suffixIcon,
        keyboardType: keyboardType,
        inputFormatters: inputFormatters,
        errorText: _fieldErrors[fieldKey],
        onChanged: (_) => _clearFieldError(fieldKey),
      ),
    );
  }

  Widget _buildFieldError(String fieldKey, TextTheme tt, ColorScheme cs) {
    final error = _fieldErrors[fieldKey];
    if (error == null) return const SizedBox.shrink();
    final scale = context.sportoScale;
    return Padding(
      padding: EdgeInsets.only(top: 6 * scale, bottom: 12 * scale),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          error,
          style: tt.bodySmall?.copyWith(
            color: cs.error,
            fontSize: 12 * scale,
            height: 1.25,
          ),
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
                            _isReferee
                                ? 'Thank you for applying as a Sporto Referee.'
                                : 'Your partner profile has been submitted.',
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
                              applicationRef: _pendingUser?.badgeId),
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
  final String? applicationRef;
  final VoidCallback? onRefresh;
  const ApplicationStatusScreen({
    super.key,
    this.applicationRef,
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
                          if (applicationRef != null &&
                              applicationRef!.trim().isNotEmpty) ...[
                            SizedBox(height: 2 * scale),
                            Text(
                              '#${applicationRef!.trim()}',
                              style: tt.bodyMedium?.copyWith(
                                color: cs.onSurfaceVariant,
                                fontSize: 12 * scale,
                              ),
                            ),
                          ],
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

class OnboardingSubmission {
  const OnboardingSubmission({
    required this.user,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.dateOfBirth,
    required this.gender,
    required this.addressLine1,
    required this.city,
    required this.state,
    required this.country,
    required this.pincode,
    required this.selectedSports,
    required this.experienceYears,
    required this.highestQualification,
    required this.presentOccupation,
    required this.hasProfilePhoto,
    required this.hasGovernmentId,
    required this.hasSportsCertificate,
    required this.hasResume,
    this.profilePhotoPath,
    this.governmentIdPath,
    this.sportsCertificatePath,
    this.resumePath,
    required this.availableDays,
    required this.preferredCity,
    required this.travelRadiusKm,
    required this.emergencyContact,
  });

  final UserEntity user;
  final String firstName;
  final String lastName;
  final String email;
  final String dateOfBirth;
  final String gender;
  final String addressLine1;
  final String city;
  final String state;
  final String country;
  final String pincode;
  final List<String> selectedSports;
  final int experienceYears;
  final String highestQualification;
  final String presentOccupation;
  final bool hasProfilePhoto;
  final bool hasGovernmentId;
  final bool hasSportsCertificate;
  final bool hasResume;
  final String? profilePhotoPath;
  final String? governmentIdPath;
  final String? sportsCertificatePath;
  final String? resumePath;
  final List<String> availableDays;
  final String preferredCity;
  final int? travelRadiusKm;
  final String emergencyContact;
}

enum OnboardingUploadType {
  profilePhoto,
  governmentId,
  sportsCertificate,
  resume,
}
