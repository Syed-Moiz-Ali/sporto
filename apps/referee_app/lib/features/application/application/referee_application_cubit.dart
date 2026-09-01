import 'package:core/core.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:referee_data/referee_data.dart';

sealed class RefereeApplicationState extends Equatable {
  const RefereeApplicationState();

  @override
  List<Object?> get props => const [];
}

class RefereeApplicationInitial extends RefereeApplicationState {
  const RefereeApplicationInitial();
}

class RefereeApplicationLoading extends RefereeApplicationState {
  const RefereeApplicationLoading();
}

class RefereeApplicationLoaded extends RefereeApplicationState {
  const RefereeApplicationLoaded({
    required this.application,
    required this.status,
  });

  final RefereeApplicationResponse? application;
  final RefereeApplicationStatusResponse? status;

  @override
  List<Object?> get props => [application, status];
}

class RefereeApplicationError extends RefereeApplicationState {
  const RefereeApplicationError(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}

class RefereeApplicationCubit extends Cubit<RefereeApplicationState> {
  RefereeApplicationCubit({required RefereeRemoteDataSource remoteDataSource})
      : _remoteDataSource = remoteDataSource,
        super(const RefereeApplicationInitial());

  final RefereeRemoteDataSource _remoteDataSource;

  Future<void> load() async {
    emit(const RefereeApplicationLoading());
    try {
      final application = await _remoteDataSource.getApplicationData();
      RefereeApplicationStatusResponse? status;
      if (application != null) {
        try {
          status = await _remoteDataSource.getApplicationStatus();
        } on SportoApiException catch (error) {
          if (error.statusCode != 404) rethrow;
        }
      }
      emit(RefereeApplicationLoaded(
        application: application,
        status: status,
      ));
    } catch (error) {
      emit(RefereeApplicationError(_readableError(error)));
    }
  }

  Future<void> savePersonal(RefereePersonalRequest request) =>
      _remoteDataSource.savePersonal(request);

  Future<void> saveAddress(RefereeAddressRequest request) =>
      _remoteDataSource.saveAddress(request);

  Future<void> saveSports(RefereeSportsRequest request) =>
      _remoteDataSource.saveSports(request);

  Future<void> saveAvailability(RefereeAvailabilityRequest request) =>
      _remoteDataSource.saveAvailability(request);

  Future<RefereeDocument> addDocument(RefereeDocumentRequest request) =>
      _remoteDataSource.addDocument(request);

  Future<void> deleteDocument(Object documentId) =>
      _remoteDataSource.deleteDocument(documentId);

  Future<void> submitApplication() async {
    await _remoteDataSource.reviewApplication();
    await _remoteDataSource.submitApplication();
    await load();
  }

  String _readableError(Object error) {
    if (error is SportoApiException) {
      final errors = error.errors;
      if (errors is Map) {
        for (final value in errors.values) {
          if (value is List && value.isNotEmpty) return value.first.toString();
          if (value != null) return value.toString();
        }
      }
      return error.message;
    }
    return error.toString();
  }
}
