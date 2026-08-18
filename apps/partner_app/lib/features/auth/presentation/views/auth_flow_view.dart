import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:core/core.dart';
import 'package:file_picker/file_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:partner_data/partner_data.dart';
import 'package:shared_domain/shared_domain.dart';
import 'package:ui_kit/ui_kit.dart';

import '../../../../features/tournaments/presentation/screens/partner_main_screen.dart';
import 'partner_permission_setup_screen.dart';

/// Handles splash + auth gate (login / onboarding / authenticated home).
class AuthFlowView extends StatefulWidget {
  final int initialTabIndex;

  const AuthFlowView({
    super.key,
    this.initialTabIndex = 0,
  });

  @override
  State<AuthFlowView> createState() => _AuthFlowViewState();
}

class _AuthFlowViewState extends State<AuthFlowView> {
  bool _splashFinished = false;
  Future<_ServerGateResult>? _serverGateFuture;
  String? _serverGateKey;
  late final PartnerRemoteDataSource _partnerRemoteDataSource =
      PartnerRemoteDataSource(
    apiClient: SportoApiClient(tokenProvider: AuthSessionStore().getToken),
  );
  late final CommonRemoteDataSource _commonRemoteDataSource =
      CommonRemoteDataSource(
    apiClient: SportoApiClient(tokenProvider: AuthSessionStore().getToken),
  );

  // Last non-loading auth state - keeps the current screen visible
  // (with an in-button spinner) while auth operations are in flight.
  AuthState? _lastScreenState;

  @override
  void initState() {
    super.initState();
    _serverGateFuture = _getServerGateFuture('startup');
  }

  @override
  Widget build(BuildContext context) {
    if (!_splashFinished) {
      return SplashScreen(
          onFinish: () => setState(() => _splashFinished = true));
    }

    return BlocConsumer<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthErrorState) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text(state.message),
                backgroundColor: Theme.of(context).colorScheme.error),
          );
        }
      },
      builder: (context, state) {
        if (state is! AuthLoadingState) {
          _lastScreenState = state;
        }

        final screenState =
            state is AuthLoadingState ? (_lastScreenState ?? state) : state;
        final isSubmitting = state is AuthLoadingState;
        final loginScreen = _buildLoginScreen(screenState, isSubmitting);

        if (screenState is AuthenticatedState) {
          return _buildServerTokenGate(
            loginScreen,
            gateKey: 'auth-${screenState.user.id}',
          );
        }

        if (screenState is NeedsOnboardingState) {
          return _buildServerTokenGate(
            loginScreen,
            gateKey: 'auth-${screenState.user.id}',
          );
        }

        return _buildServerTokenGate(loginScreen, gateKey: 'startup');
      },
    );
  }

  Widget _buildServerTokenGate(Widget loginScreen, {required String gateKey}) {
    return FutureBuilder<_ServerGateResult>(
      future: _getServerGateFuture(gateKey),
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const _PartnerGateLoadingScreen();
        }

        if (snapshot.hasError) {
          debugPrint('[SportoApi] AUTH_GATE error ${snapshot.error}');
        }

        final result = snapshot.data;
        if (result == null || !result.hasValidSession) {
          debugPrint('[SportoApi] AUTH_GATE routing to login');
          return loginScreen;
        }

        if (result.needsOnboarding) {
          debugPrint(
            '[SportoApi] AUTH_GATE routing to onboarding step '
            '${result.initialStep}',
          );
          return _buildOnboarding(
            result.user,
            initialStep: result.initialStep,
            initialData: result.initialData,
          );
        }

        if (result.showApplicationStatus) {
          debugPrint(
            '[SportoApi] AUTH_GATE routing to application status '
            '${result.applicationNumber ?? 'PARTNER'} '
            'status=${result.applicationStatusLabel ?? 'unknown'}',
          );
          return ApplicationStatusScreen(
            applicationRef: result.applicationNumber ?? 'PARTNER',
            onRefresh: _refreshServerGate,
          );
        }

        debugPrint(
          '[SportoApi] AUTH_GATE routing to permission setup gate '
          'status=${result.applicationStatusLabel ?? 'unknown'}',
        );
        return _buildPermissionSetupGate();
      },
    );
  }

  bool _permissionSetupBypassed = false;

  Widget _buildPermissionSetupGate() {
    if (_permissionSetupBypassed) {
      return PartnerMainScreen(initialIndex: widget.initialTabIndex);
    }

    return FutureBuilder<Map<String, bool>>(
      future: _checkPartnerPermissions(),
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const _PartnerGateLoadingScreen();
        }

        final permissions =
            snapshot.data ?? {'location': false, 'notification': false};
        final locationGranted = permissions['location'] ?? false;
        final notificationGranted = permissions['notification'] ?? false;

        // ONLY ROUTE TO MAIN SCREEN IF BOTH REAL SYSTEM PERMISSIONS ARE GRANTED
        if (locationGranted && notificationGranted) {
          return PartnerMainScreen(initialIndex: widget.initialTabIndex);
        }

        return PartnerPermissionSetupScreen(
          initialLocationGranted: locationGranted,
          initialNotificationGranted: notificationGranted,
          onPermissionsUpdated: () {
            if (!mounted) return;
            setState(() {
              _permissionSetupBypassed = true;
            });
          },
        );
      },
    );
  }

  Future<Map<String, bool>> _checkPartnerPermissions() async {
    try {
      final locationStatus = await Permission.location.status;
      final notificationStatus = await Permission.notification.status;

      final locationGranted =
          locationStatus.isGranted || locationStatus.isLimited;
      final notificationGranted =
          notificationStatus.isGranted || notificationStatus.isLimited;

      debugPrint(
        '[PermissionCheck] REAL OS STATUS: location=$locationStatus ($locationGranted), '
        'notification=$notificationStatus ($notificationGranted)',
      );

      return {
        'location': locationGranted,
        'notification': notificationGranted,
      };
    } catch (e) {
      debugPrint('[PermissionCheck] Error querying real OS permissions: $e');
      return {
        'location': false,
        'notification': false,
      };
    }
  }

  Future<_ServerGateResult> _getServerGateFuture(String gateKey) {
    if (_serverGateFuture == null || _serverGateKey != gateKey) {
      _serverGateKey = gateKey;
      _serverGateFuture = _checkServerTokenGate();
    }
    return _serverGateFuture!;
  }

  void _refreshServerGate() {
    setState(() {
      _serverGateKey = null;
      _serverGateFuture = null;
    });
  }

  Future<_ServerGateResult> _checkServerTokenGate() async {
    debugPrint('[SportoApi] SPLASH_GATE started partner profile check');
    final token = await AuthSessionStore().getToken();
    if (token == null || token.isEmpty) {
      debugPrint('[SportoApi] SPLASH_GATE no stored token, showing login');
      return _ServerGateResult.noSession();
    }

    try {
      debugPrint('[SportoApi] SPLASH_GATE stored token found, hitting profile');
      final profile = await _partnerRemoteDataSource.getProfileData();
      final application = await _tryGetApplicationForGate('SPLASH_GATE');
      final initialStep = application == null
          ? _firstIncompleteProfileStep(profile)
          : _firstIncompleteOnboardingStep(profile, application);
      final applicationStatus = application?.applicationStatus ??
          profile.application.applicationStatus;
      final workflowStatus =
          PartnerApplicationWorkflowStatus.fromValue(applicationStatus);
      final applicationNumber = application?.applicationNumber ??
          profile.application.applicationNumber;
      final personal = profile.personalInformation;
      final storedUser = await AuthRepositoryImpl().getCurrentUser();
      final mobileNumber = (personal.mobileNumber != null && personal.mobileNumber!.trim().isNotEmpty)
          ? personal.mobileNumber!
          : (storedUser?.mobileNumber ?? '');
      final user = UserEntity(
        id: storedUser?.id ?? 'server-partner',
        name: '${personal.firstName ?? ''} ${personal.lastName ?? ''}'.trim(),
        email: personal.email ?? '',
        mobileNumber: mobileNumber,
        role: 'partner',
        dob: personal.dateOfBirth,
        gender: personal.gender,
        city: profile.address.city,
        state: profile.address.state,
        isProfileComplete: initialStep == null,
      );
      final initialData = _buildInitialOnboardingData(profile, application);
      return _ServerGateResult(
        hasValidSession: true,
        needsOnboarding: initialStep != null,
        initialStep: initialStep ?? 1,
        showApplicationStatus:
            initialStep == null && !_shouldOpenDashboard(workflowStatus),
        applicationNumber: applicationNumber,
        applicationStatusLabel: workflowStatus.label,
        user: user,
        initialData: initialData,
      );
    } on SportoApiException catch (error) {
      debugPrint(
        '[SportoApi] SPLASH_GATE failed status=${error.statusCode} '
        'message=${error.message}',
      );
      if (error.statusCode == 401) {
        return _ServerGateResult.noSession();
      }
      final storedUser = await AuthRepositoryImpl().getCurrentUser();
      return _ServerGateResult(
        hasValidSession: true,
        needsOnboarding: true,
        initialStep: 1,
        showApplicationStatus: false,
        applicationNumber: null,
        applicationStatusLabel: null,
        user: UserEntity(
          id: storedUser?.id ?? 'server-partner',
          name: storedUser?.name ?? '',
          email: storedUser?.email ?? '',
          mobileNumber: storedUser?.mobileNumber ?? '',
          role: 'partner',
        ),
      );
    }
  }

  Future<PartnerApplicationStateResponse?> _tryGetApplicationForGate(
    String gateName,
  ) async {
    try {
      debugPrint(
        '[SportoApi] $gateName profile received, checking application',
      );
      return await _partnerRemoteDataSource.getApplicationData();
    } on SportoApiException catch (error) {
      debugPrint(
        '[SportoApi] $gateName application check skipped '
        'status=${error.statusCode} message=${error.message}',
      );
      return null;
    }
  }

  int? _firstIncompleteProfileStep(PartnerProfileResponseData profile) {
    final personal = profile.personalInformation;
    if (_missing(personal.firstName) ||
        _missing(personal.lastName) ||
        _missing(personal.email) ||
        _missing(personal.dateOfBirth) ||
        _missing(personal.gender)) {
      return 1;
    }

    final address = profile.address;
    if (_missing(address.addressLine1) ||
        _missing(address.city) ||
        _missing(address.state) ||
        _missing(address.country) ||
        _missing(address.pincode)) {
      return 2;
    }

    final professional = profile.professionalInformation;
    if (_missing(professional.highestQualification) ||
        _missing(professional.presentOccupation)) {
      return 3;
    }

    return null;
  }

  bool _shouldOpenDashboard(PartnerApplicationWorkflowStatus status) {
    return switch (status) {
      PartnerApplicationWorkflowStatus.published ||
      PartnerApplicationWorkflowStatus.registrationOpen ||
      PartnerApplicationWorkflowStatus.registrationClosed ||
      PartnerApplicationWorkflowStatus.checkIn ||
      PartnerApplicationWorkflowStatus.inProgress ||
      PartnerApplicationWorkflowStatus.completed =>
        true,
      PartnerApplicationWorkflowStatus.draft ||
      PartnerApplicationWorkflowStatus.cancelled ||
      PartnerApplicationWorkflowStatus.archived =>
        false,
    };
  }

  int? _firstIncompleteOnboardingStep(
    PartnerProfileResponseData profile,
    PartnerApplicationStateResponse application,
  ) {
    final profileStep = _firstIncompleteProfileStep(profile);
    if (profileStep != null) return profileStep;

    final professional = profile.professionalInformation;
    if (application.sports.isEmpty ||
        _missing(professional.highestQualification) ||
        _missing(professional.presentOccupation)) {
      return 3;
    }

    final hasGovernmentId = application.documents.any(
      (document) => document.documentType == 'government_id',
    );
    if (!hasGovernmentId) {
      return 4;
    }

    return null;
  }

  bool _missing(String? value) {
    final normalized = value?.trim().toLowerCase();
    return normalized == null ||
        normalized.isEmpty ||
        normalized == 'null' ||
        normalized == 'string' ||
        normalized == 'string null';
  }

  Widget _buildOnboarding(
    UserEntity user, {
    required int initialStep,
    InitialOnboardingData? initialData,
  }) {
    return AutomatedOnboardingWizard(
      user: user,
      initialStep: initialStep,
      initialData: initialData,
      onContinueStep: _continuePartnerOnboardingStep,
      onSubmitOnboarding: _submitPartnerOnboarding,
      onPickDocument: _pickOnboardingFile,
      onUploadDocumentFile: _uploadOnboardingFile,
      onUploadDocument: _pickAndUploadOnboardingFile,
      onComplete: (updatedUser) {
        _serverGateFuture = null;
        context
            .read<AuthBloc>()
            .add(CompleteProfileRequestedEvent(updatedUser));
      },
      onGoHome: () {
        _serverGateFuture = null;
        _serverGateKey = null;
        context.read<AuthBloc>().add(LogoutRequestedEvent());
      },
    );
  }

  Widget _buildLoginScreen(AuthState screenState, bool isSubmitting) {
    return PhoneLoginScreen(
      appRole: 'partner',
      initialMobileNumber:
          screenState is OtpSentState ? screenState.mobileNumber : null,
      isSubmitting: isSubmitting,
      onSendOtp: (mobileNumber) {
        context.read<AuthBloc>().add(SendOtpRequestedEvent(
              mobileNumber: mobileNumber,
              role: 'partner',
            ));
      },
      onVerifyOtp: (mobileNumber, otpCode) {
        context.read<AuthBloc>().add(VerifyOtpRequestedEvent(
              mobileNumber: mobileNumber,
              otpCode: otpCode,
              role: 'partner',
            ));
      },
    );
  }

  Future<void> _submitPartnerOnboarding(
    OnboardingSubmission submission,
  ) async {
    await _savePartnerProfile(submission);
    await _savePartnerSports(submission);
    await _saveGovernmentIdDocument(submission);

    await _partnerRemoteDataSource.submitApplicationData(
      const PartnerApplicationSubmitRequest(confirmation: true),
    );
  }

  Future<void> _continuePartnerOnboardingStep(
    OnboardingSubmission submission,
    int completedStep,
  ) async {
    switch (completedStep) {
      case 1:
        await _savePartnerPersonalInformation(submission);
      case 2:
        await _savePartnerAddress(submission);
      case 3:
        await _savePartnerProfessionalInformation(submission);
        await _savePartnerSports(submission);
      case 4:
        await _saveGovernmentIdDocument(submission);
    }
  }

  Future<void> _savePartnerProfile(OnboardingSubmission submission) {
    return _partnerRemoteDataSource.saveProfileData(
      PartnerProfileRequest(
        firstName: submission.firstName,
        lastName: submission.lastName,
        email: submission.email,
        dateOfBirth: _dateForBackend(submission.dateOfBirth),
        gender: submission.gender,
        addressLine1: submission.addressLine1,
        addressLine2: '',
        city: submission.city,
        state: submission.state,
        country: submission.country,
        pincode: submission.pincode,
        highestQualification: submission.highestQualification,
        presentOccupation: submission.presentOccupation,
      ),
    );
  }

  Future<void> _savePartnerPersonalInformation(
    OnboardingSubmission submission,
  ) {
    return _partnerRemoteDataSource.updateProfileData(
      PartnerProfileUpdateRequest(
        firstName: submission.firstName,
        lastName: submission.lastName,
        email: submission.email,
        dateOfBirth: _dateForBackend(submission.dateOfBirth),
        gender: submission.gender,
      ),
    );
  }

  Future<void> _savePartnerAddress(OnboardingSubmission submission) {
    return _partnerRemoteDataSource.updateProfileData(
      PartnerProfileUpdateRequest(
        addressLine1: submission.addressLine1,
        addressLine2: '',
        city: submission.city,
        state: submission.state,
        country: submission.country,
        pincode: submission.pincode,
      ),
    );
  }

  Future<void> _savePartnerProfessionalInformation(
    OnboardingSubmission submission,
  ) {
    return _partnerRemoteDataSource.updateProfileData(
      PartnerProfileUpdateRequest(
        highestQualification: submission.highestQualification,
        presentOccupation: submission.presentOccupation,
      ),
    );
  }

  Future<void> _savePartnerSports(OnboardingSubmission submission) async {
    final sportIds = submission.selectedSports
        .map(_sportIdForName)
        .whereType<int>()
        .toSet()
        .toList();
    if (sportIds.isNotEmpty) {
      try {
        await _partnerRemoteDataSource.addSportsData(
          PartnerAddSportsRequest(
            sportIds: sportIds,
            experienceYears: submission.experienceYears,
          ),
        );
      } on SportoApiException catch (error) {
        if (!error.message.toLowerCase().contains('already selected')) {
          rethrow;
        }
      }
    }
  }

  Future<void> _saveGovernmentIdDocument(
    OnboardingSubmission submission,
  ) async {
    if (submission.hasGovernmentId && submission.governmentIdPath != null) {
      await _partnerRemoteDataSource.addDocumentData(
        PartnerDocumentRequest(
          documentType: 'government_id',
          documentPath: submission.governmentIdPath!,
        ),
      );
    } else {
      throw const SportoApiException('Government ID document is required.');
    }
  }

  Future<String?> _pickOnboardingFile(
    OnboardingUploadType type,
  ) async {
    final picked = await FilePicker.platform.pickFiles(
      type: type == OnboardingUploadType.resume
          ? FileType.custom
          : FileType.image,
      allowedExtensions: type == OnboardingUploadType.resume
          ? const ['pdf', 'doc', 'docx']
          : null,
      allowMultiple: false,
      withData: false,
    );
    return picked?.files.single.path;
  }

  Future<String?> _uploadOnboardingFile(
    OnboardingUploadType type,
    String filePath,
  ) async {
    final upload = await _commonRemoteDataSource.uploadFile(
      filePath: filePath,
      folder: _folderForUploadType(type),
    );
    return upload.url.isNotEmpty
        ? upload.url
        : (upload.path.isNotEmpty ? upload.path : filePath);
  }

  Future<String?> _pickAndUploadOnboardingFile(
    OnboardingUploadType type,
  ) async {
    final filePath = await _pickOnboardingFile(type);
    if (filePath == null) return null;
    return _uploadOnboardingFile(type, filePath);
  }

  String _folderForUploadType(OnboardingUploadType type) {
    switch (type) {
      case OnboardingUploadType.profilePhoto:
        return 'users/profile';
      case OnboardingUploadType.governmentId:
        return 'users/documents';
      case OnboardingUploadType.sportsCertificate:
        return 'users/documents';
      case OnboardingUploadType.resume:
        return 'users/documents';
    }
  }

  String _dateForBackend(String value) {
    final trimmed = value.trim();
    final parts = trimmed.split('/');
    if (parts.length == 3) {
      return '${parts[2]}-${parts[1].padLeft(2, '0')}-${parts[0].padLeft(2, '0')}';
    }
    return trimmed;
  }

  InitialOnboardingData _buildInitialOnboardingData(
    PartnerProfileResponseData profile,
    PartnerApplicationStateResponse? application,
  ) {
    final docsMap = <String, String>{};
    if (application?.documents != null) {
      for (final doc in application!.documents) {
        if (doc.documentPath.isNotEmpty) {
          docsMap[doc.documentType] = doc.documentPath;
        }
      }
    }

    final sportsNames = <String>[];
    int expYears = 0;
    if (application?.sports != null && application!.sports.isNotEmpty) {
      for (final sport in application.sports) {
        if (sport.sportName != null && sport.sportName!.isNotEmpty) {
          sportsNames.add(sport.sportName!);
        }
      }
      expYears = application.sports.first.experienceYears;
    }

    return InitialOnboardingData(
      addressLine1: profile.address.addressLine1 ?? application?.address.addressLine1,
      addressLine2: profile.address.addressLine2 ?? application?.address.addressLine2,
      city: profile.address.city ?? application?.address.city,
      state: profile.address.state ?? application?.address.state,
      pincode: profile.address.pincode ?? application?.address.pincode,
      country: profile.address.country ?? application?.address.country,
      highestQualification: profile.professionalInformation.highestQualification ??
          application?.professionalInformation.highestQualification,
      presentOccupation: profile.professionalInformation.presentOccupation ??
          application?.professionalInformation.presentOccupation,
      sports: sportsNames,
      experienceYears: expYears,
      documents: docsMap,
    );
  }

  int? _sportIdForName(String sportName) {
    const ids = {
      'Cricket': 1,
      'Football': 2,
      'Basketball': 3,
      'Volleyball': 4,
      'Badminton': 5,
    };
    return ids[sportName];
  }
}

class _PartnerGateLoadingScreen extends StatelessWidget {
  const _PartnerGateLoadingScreen();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }
}

class _ServerGateResult {
  const _ServerGateResult({
    required this.hasValidSession,
    required this.needsOnboarding,
    required this.initialStep,
    required this.showApplicationStatus,
    required this.applicationNumber,
    required this.applicationStatusLabel,
    required this.user,
    this.initialData,
  });

  const _ServerGateResult.noSession()
      : hasValidSession = false,
        needsOnboarding = false,
        initialStep = 1,
        showApplicationStatus = false,
        applicationNumber = null,
        applicationStatusLabel = null,
        user = const UserEntity(
          id: 'server-partner',
          name: '',
          email: '',
          mobileNumber: '',
          role: 'partner',
        ),
        initialData = null;

  final bool hasValidSession;
  final bool needsOnboarding;
  final int initialStep;
  final bool showApplicationStatus;
  final String? applicationNumber;
  final String? applicationStatusLabel;
  final UserEntity user;
  final InitialOnboardingData? initialData;
}
