import 'package:core/core.dart';

import '../models/referee_api_models.dart';

class RefereeRemoteDataSource {
  RefereeRemoteDataSource({SportoApiClient? apiClient})
      : _apiClient = apiClient ?? SportoApiClient();

  final SportoApiClient _apiClient;

  Future<RefereeApplicationResponse?> getApplicationData() async {
    final response = await _get(
      SportoApiEndpoints.refereeApplication.application,
    );
    return _applicationFromData(response.data);
  }

  Future<void> savePersonal(RefereePersonalRequest request) async {
    await _post(
      SportoApiEndpoints.refereeApplication.personal,
      request.toJson(),
    );
  }

  Future<void> saveAddress(RefereeAddressRequest request) async {
    await _put(
      SportoApiEndpoints.refereeApplication.address,
      request.toJson(),
    );
  }

  Future<void> saveSports(RefereeSportsRequest request) async {
    await _put(
      SportoApiEndpoints.refereeApplication.sports,
      request.toJson(),
    );
  }

  Future<void> saveAvailability(RefereeAvailabilityRequest request) async {
    await _put(
      SportoApiEndpoints.refereeApplication.availability,
      request.toJson(),
    );
  }

  Future<RefereeDocument> addDocument(RefereeDocumentRequest request) async {
    final response = await _post(
      SportoApiEndpoints.refereeApplication.documents,
      request.toJson(),
    );
    final data = response.data;
    if (data is! Map) {
      throw const SportoApiException('Document response data is invalid.');
    }
    final json = Map<String, dynamic>.from(data);
    return RefereeDocument.fromJson({
      ...json,
      'type': request.type,
    });
  }

  Future<void> deleteDocument(Object documentId) async {
    await _delete(
      SportoApiEndpoints.refereeApplication.document(documentId),
    );
  }

  Future<RefereeApplicationResponse?> reviewApplication() async {
    final response = await _get(
      SportoApiEndpoints.refereeApplication.review,
    );
    return _applicationFromData(response.data);
  }

  Future<void> submitApplication() async {
    await _post(
      SportoApiEndpoints.refereeApplication.submit,
      const {},
    );
  }

  Future<RefereeApplicationStatusResponse> getApplicationStatus() async {
    final response = await _get(
      SportoApiEndpoints.refereeApplication.status,
    );
    final data = response.data;
    if (data is! Map) {
      throw const SportoApiException(
        'Application status response data is invalid.',
      );
    }
    return RefereeApplicationStatusResponse.fromJson(
      Map<String, dynamic>.from(data),
    );
  }

  RefereeApplicationResponse? _applicationFromData(Object? data) {
    if (data == null) return null;
    if (data is! Map) {
      throw const SportoApiException(
        'Referee application response data is invalid.',
      );
    }
    return RefereeApplicationResponse.fromJson(
      Map<String, dynamic>.from(data),
    );
  }

  Future<SportoApiResponse> _get(String path) async {
    return SportoApiResponse.fromJson(await _apiClient.getJson(path));
  }

  Future<SportoApiResponse> _post(
    String path,
    Map<String, dynamic> body,
  ) async {
    return SportoApiResponse.fromJson(
      await _apiClient.postJson(path, body: body),
    );
  }

  Future<SportoApiResponse> _put(
    String path,
    Map<String, dynamic> body,
  ) async {
    return SportoApiResponse.fromJson(
      await _apiClient.putJson(path, body: body),
    );
  }

  Future<SportoApiResponse> _delete(String path) async {
    return SportoApiResponse.fromJson(await _apiClient.deleteJson(path));
  }
}
