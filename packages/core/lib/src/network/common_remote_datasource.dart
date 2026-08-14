import 'models/sporto_api_response.dart';
import 'sporto_api_client.dart';
import 'sporto_api_endpoints.dart';

class CommonRemoteDataSource {
  CommonRemoteDataSource({SportoApiClient? apiClient})
      : _apiClient = apiClient ?? SportoApiClient();

  final SportoApiClient _apiClient;

  Future<UploadFileResponseData> uploadFile({
    required String filePath,
    required String folder,
  }) async {
    final response = SportoApiResponse.fromJson(
      await _apiClient.uploadFile(
        path: SportoApiEndpoints.common.upload,
        filePath: filePath,
        folder: folder,
      ),
    );
    final data = response.data;
    if (data is Map) {
      return UploadFileResponseData.fromJson(Map<String, dynamic>.from(data));
    }
    throw const SportoApiException('Upload response data is invalid.');
  }
}
