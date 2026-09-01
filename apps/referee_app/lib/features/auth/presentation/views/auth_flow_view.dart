import 'package:core/core.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:referee_data/referee_data.dart';
import 'package:shared_domain/shared_domain.dart';
import 'package:ui_kit/ui_kit.dart';

import '../../../application/application/referee_application_cubit.dart';
import '../../../matches/presentation/screens/referee_shell_screen.dart';

/// Routes an authenticated referee using the server application state.
class AuthFlowView extends StatefulWidget {
  const AuthFlowView({super.key});

  @override
  State<AuthFlowView> createState() => _AuthFlowViewState();
}

class _AuthFlowViewState extends State<AuthFlowView> {
  bool _splashFinished = false;
  bool _onboardingCompleted = false;
  AuthState? _lastScreenState;

  @override
  void initState() {
    super.initState();
    _onboardingCompleted = HiveService.hasSeenOnboarding();
  }

  @override
  Widget build(BuildContext context) {
    if (!_splashFinished) {
      return SplashScreen(
        onFinish: () => setState(() => _splashFinished = true),
      );
    }

    if (!_onboardingCompleted) {
      return RefereeOnboardingScreen(
        onGetStarted: () async {
          await HiveService.setHasSeenOnboarding(true);
          if (mounted) setState(() => _onboardingCompleted = true);
        },
      );
    }

    return BlocConsumer<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthErrorState) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
          );
        }
      },
      builder: (context, state) {
        if (state is! AuthLoadingState) _lastScreenState = state;
        final screenState =
            state is AuthLoadingState ? (_lastScreenState ?? state) : state;
        final isSubmitting = state is AuthLoadingState;

        if (screenState is AuthenticatedState) {
          return _RefereeApplicationGate(
            key: ValueKey(screenState.user.id),
            user: screenState.user,
          );
        }
        if (screenState is NeedsOnboardingState) {
          return _RefereeApplicationGate(
            key: ValueKey(screenState.user.id),
            user: screenState.user,
          );
        }

        return PhoneLoginScreen(
          appRole: 'referee',
          initialMobileNumber:
              screenState is OtpSentState ? screenState.mobileNumber : null,
          isSubmitting: isSubmitting,
          onSendOtp: (mobileNumber) => context.read<AuthBloc>().add(
                SendOtpRequestedEvent(
                  mobileNumber: mobileNumber,
                  role: 'referee',
                ),
              ),
          onVerifyOtp: (mobileNumber, otpCode) => context.read<AuthBloc>().add(
                VerifyOtpRequestedEvent(
                  mobileNumber: mobileNumber,
                  otpCode: otpCode,
                  role: 'referee',
                ),
              ),
        );
      },
    );
  }
}

class _RefereeApplicationGate extends StatefulWidget {
  const _RefereeApplicationGate({super.key, required this.user});

  final UserEntity user;

  @override
  State<_RefereeApplicationGate> createState() =>
      _RefereeApplicationGateState();
}

class _RefereeApplicationGateState extends State<_RefereeApplicationGate> {
  final Set<int> _savedDocumentTypes = <int>{};
  late final CommonRemoteDataSource _commonRemoteDataSource =
      CommonRemoteDataSource(
    apiClient: SportoApiClient(tokenProvider: AuthSessionStore().getToken),
  );

  @override
  void initState() {
    super.initState();
    context.read<RefereeApplicationCubit>().load();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<RefereeApplicationCubit, RefereeApplicationState>(
      builder: (context, state) {
        if (state is RefereeApplicationInitial ||
            state is RefereeApplicationLoading) {
          return const _ApplicationLoadingScreen();
        }
        if (state is RefereeApplicationError) {
          return _ApplicationErrorScreen(
            message: state.message,
            onRetry: context.read<RefereeApplicationCubit>().load,
            onLogout: _logout,
          );
        }

        final loaded = state as RefereeApplicationLoaded;
        final application = loaded.application;
        _savedDocumentTypes.addAll(
          application?.documents.map((document) => document.type) ??
              const <int>[],
        );
        final status = loaded.status?.applicationStatus ??
            application?.applicationStatus ??
            1;

        if (status == 3) return const RefereeShellScreen();
        if (application != null && !application.isDraft) {
          return ApplicationStatusScreen(
            applicationRef: application.applicationNumber,
            onRefresh: context.read<RefereeApplicationCubit>().load,
          );
        }

        return AutomatedOnboardingWizard(
          user: _applicationUser(application),
          initialStep: _firstIncompleteStep(application),
          initialData: _initialData(application),
          onContinueStep: _saveStep,
          onSubmitOnboarding: _submit,
          onPickDocument: _pickDocument,
          onUploadDocumentFile: _uploadDocument,
          onUploadDocument: _pickAndUploadDocument,
          onComplete: (_) => context.read<RefereeApplicationCubit>().load(),
          onGoHome: _logout,
        );
      },
    );
  }

  Future<void> _saveStep(
    OnboardingSubmission submission,
    int completedStep,
  ) async {
    final cubit = context.read<RefereeApplicationCubit>();
    switch (completedStep) {
      case 1:
        await cubit.savePersonal(_personalRequest(submission));
      case 2:
        await cubit.saveAddress(_addressRequest(submission));
      case 3:
        await cubit.saveSports(_sportsRequest(submission));
      case 4:
        await cubit.saveAvailability(_availabilityRequest(submission));
      case 5:
        await _saveDocuments(submission);
    }
  }

  Future<void> _submit(OnboardingSubmission submission) async {
    final cubit = context.read<RefereeApplicationCubit>();
    await cubit.savePersonal(_personalRequest(submission));
    await cubit.saveAddress(_addressRequest(submission));
    await cubit.saveSports(_sportsRequest(submission));
    await cubit.saveAvailability(_availabilityRequest(submission));
    await _saveDocuments(submission);
    await cubit.submitApplication();
  }

  RefereePersonalRequest _personalRequest(OnboardingSubmission submission) =>
      RefereePersonalRequest(
        firstName: submission.firstName,
        lastName: submission.lastName,
        email: submission.email,
        dateOfBirth: _dateForBackend(submission.dateOfBirth),
        gender: submission.gender,
      );

  RefereeAddressRequest _addressRequest(OnboardingSubmission submission) =>
      RefereeAddressRequest(
        addressLine1: submission.addressLine1,
        city: submission.city,
        state: submission.state,
        pincode: submission.pincode,
        country: submission.country,
      );

  RefereeSportsRequest _sportsRequest(OnboardingSubmission submission) =>
      RefereeSportsRequest(
        sportIds: submission.selectedSports
            .map(_sportIdForName)
            .whereType<int>()
            .toSet()
            .toList(),
        experienceYears: submission.experienceYears,
        highestQualification: submission.highestQualification,
      );

  RefereeAvailabilityRequest _availabilityRequest(
    OnboardingSubmission submission,
  ) =>
      RefereeAvailabilityRequest(
        availability:
            submission.availableDays.map((day) => day.toLowerCase()).toList(),
        preferredCity: submission.preferredCity,
        travelRadius: submission.travelRadiusKm ?? 0,
        emergencyContactName: submission.emergencyContactName,
        emergencyContactNumber: submission.emergencyContact,
      );

  Future<void> _saveDocuments(OnboardingSubmission submission) async {
    final cubit = context.read<RefereeApplicationCubit>();
    final documents = <int, String?>{
      1: submission.profilePhotoPath,
      2: submission.governmentIdPath,
      3: submission.sportsCertificatePath,
      4: submission.resumePath,
    };
    if (!submission.hasGovernmentId ||
        submission.governmentIdPath == null ||
        submission.governmentIdPath!.isEmpty) {
      throw const SportoApiException('Government ID document is required.');
    }
    for (final entry in documents.entries) {
      if (entry.value?.isNotEmpty == true &&
          !_savedDocumentTypes.contains(entry.key)) {
        await cubit.addDocument(
          RefereeDocumentRequest(type: entry.key, filePath: entry.value!),
        );
        _savedDocumentTypes.add(entry.key);
      }
    }
  }

  Future<String?> _pickDocument(OnboardingUploadType type) async {
    final resume = type == OnboardingUploadType.resume;
    final result = await FilePicker.platform.pickFiles(
      type: resume ? FileType.custom : FileType.image,
      allowedExtensions: resume ? const ['pdf', 'doc', 'docx'] : null,
      allowMultiple: false,
      withData: false,
    );
    return result?.files.single.path;
  }

  Future<String?> _uploadDocument(
    OnboardingUploadType type,
    String filePath,
  ) async {
    final upload = await _commonRemoteDataSource.uploadFile(
      filePath: filePath,
      folder: 'referee/documents',
    );
    if (upload.path.isNotEmpty) return upload.path;
    if (upload.url.isNotEmpty) return upload.url;
    throw const SportoApiException('The uploaded file path is missing.');
  }

  Future<String?> _pickAndUploadDocument(OnboardingUploadType type) async {
    final path = await _pickDocument(type);
    return path == null ? null : _uploadDocument(type, path);
  }

  UserEntity _applicationUser(RefereeApplicationResponse? application) {
    final personal = application?.personalInformation;
    final name =
        '${personal?.firstName ?? ''} ${personal?.lastName ?? ''}'.trim();
    return UserEntity(
      id: widget.user.id,
      name: name.isEmpty ? widget.user.name : name,
      email: personal?.email ?? widget.user.email,
      mobileNumber: personal?.mobileNumber ?? widget.user.mobileNumber,
      role: 'referee',
      dob: personal?.dateOfBirth ?? widget.user.dob,
      gender: personal?.gender ?? widget.user.gender,
      city: application?.address.city ?? widget.user.city,
      state: application?.address.state ?? widget.user.state,
      isProfileComplete: false,
    );
  }

  InitialOnboardingData? _initialData(RefereeApplicationResponse? application) {
    if (application == null) return null;
    const documentKeys = <int, String>{
      1: 'profile_photo',
      2: 'government_id',
      3: 'sports_certificate',
      4: 'resume',
    };
    return InitialOnboardingData(
      addressLine1: application.address.addressLine1,
      addressLine2: application.address.addressLine2,
      city: application.address.city,
      state: application.address.state,
      pincode: application.address.pincode,
      country: application.address.country,
      highestQualification: application.sports.highestQualification,
      sports: application.sports.sportIds
          .map(_sportNameForId)
          .whereType<String>()
          .toList(),
      experienceYears: application.sports.experienceYears,
      availableDays: application.availability.days,
      preferredCity: application.availability.preferredCity,
      travelRadiusKm: application.availability.travelRadius,
      emergencyContactName: application.availability.emergencyContactName,
      emergencyContact: application.availability.emergencyContactNumber,
      documents: {
        for (final document in application.documents)
          if (documentKeys[document.type] != null)
            documentKeys[document.type]!: document.fileUrl,
      },
    );
  }

  int _firstIncompleteStep(RefereeApplicationResponse? application) {
    if (application == null) return 1;
    final personal = application.personalInformation;
    if (_missing(personal.firstName) ||
        _missing(personal.lastName) ||
        _missing(personal.email) ||
        _missing(personal.dateOfBirth) ||
        _missing(personal.gender)) return 1;
    final address = application.address;
    if (_missing(address.addressLine1) ||
        _missing(address.city) ||
        _missing(address.state) ||
        _missing(address.pincode) ||
        _missing(address.country)) return 2;
    if (application.sports.sportIds.isEmpty ||
        _missing(application.sports.highestQualification)) return 3;
    if (application.availability.days.isEmpty ||
        _missing(application.availability.preferredCity) ||
        _missing(application.availability.emergencyContactName) ||
        _missing(application.availability.emergencyContactNumber)) return 4;
    if (!application.documents.any((document) => document.type == 2)) return 5;
    return 6;
  }

  bool _missing(String? value) => value == null || value.trim().isEmpty;

  String _dateForBackend(String value) {
    final parts = value.trim().split('/');
    return parts.length == 3
        ? '${parts[2]}-${parts[1].padLeft(2, '0')}-${parts[0].padLeft(2, '0')}'
        : value.trim();
  }

  int? _sportIdForName(String name) => const {
        'Cricket': 1,
        'Football': 2,
        'Basketball': 3,
        'Volleyball': 4,
        'Badminton': 5,
      }[name];

  String? _sportNameForId(int id) => const {
        1: 'Cricket',
        2: 'Football',
        3: 'Basketball',
        4: 'Volleyball',
        5: 'Badminton',
      }[id];

  void _logout() => context.read<AuthBloc>().add(LogoutRequestedEvent());
}

class _ApplicationLoadingScreen extends StatelessWidget {
  const _ApplicationLoadingScreen();

  @override
  Widget build(BuildContext context) => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
}

class _ApplicationErrorScreen extends StatelessWidget {
  const _ApplicationErrorScreen({
    required this.message,
    required this.onRetry,
    required this.onLogout,
  });

  final String message;
  final VoidCallback onRetry;
  final VoidCallback onLogout;

  @override
  Widget build(BuildContext context) => Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.error_outline_rounded, size: 48),
                const SizedBox(height: 16),
                Text(message, textAlign: TextAlign.center),
                const SizedBox(height: 20),
                PrimaryButton(label: 'Try Again', onPressed: onRetry),
                TextButton(onPressed: onLogout, child: const Text('Log out')),
              ],
            ),
          ),
        ),
      );
}
