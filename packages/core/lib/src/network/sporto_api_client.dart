import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import 'sporto_api_endpoints.dart';

class SportoApiException implements Exception {
  const SportoApiException(this.message, {this.statusCode, this.errors});

  final String message;
  final int? statusCode;
  final Object? errors;

  @override
  String toString() =>
      statusCode == null ? message : '$message (HTTP $statusCode)';
}

class SportoApiClient {
  SportoApiClient({
    Dio? dio,
    String? baseUrl,
    Future<String?> Function()? tokenProvider,
  })  : _tokenProvider = tokenProvider,
        dio = dio ??
            Dio(BaseOptions(
              baseUrl: baseUrl ?? defaultBaseUrl,
              connectTimeout: const Duration(seconds: 20),
              receiveTimeout: const Duration(seconds: 30),
              sendTimeout: const Duration(seconds: 20),
              headers: const {
                'Accept': 'application/json',
                'Content-Type': 'application/json',
              },
            )) {
    this.dio.interceptors.add(_SportoDioLogInterceptor());
    this.dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final token = await _tokenProvider?.call();
        if (token != null && token.isNotEmpty) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        handler.next(options);
      },
    ));
  }

  static const defaultBaseUrl = SportoApiEndpoints.apiBaseUrl;

  final Dio dio;
  final Future<String?> Function()? _tokenProvider;

  Future<Map<String, dynamic>> getJson(
    String path, {
    Map<String, dynamic>? queryParameters,
  }) async {
    return _request(() => dio.get<Object?>(
          path,
          queryParameters: queryParameters,
        ));
  }

  Future<Map<String, dynamic>> postJson(
    String path, {
    Map<String, dynamic>? body,
  }) async {
    return _request(() => dio.post<Object?>(path, data: body));
  }

  Future<Map<String, dynamic>> putJson(
    String path, {
    Map<String, dynamic>? body,
  }) async {
    return _request(() => dio.put<Object?>(path, data: body));
  }

  Future<Map<String, dynamic>> deleteJson(String path) async {
    return _request(() => dio.delete<Object?>(path));
  }

  Future<Map<String, dynamic>> uploadFile({
    required String path,
    required String filePath,
    required String folder,
  }) async {
    final formData = FormData.fromMap({
      'file': await MultipartFile.fromFile(filePath),
      'folder': folder,
    });
    return _request(() => dio.post<Object?>(path, data: formData));
  }

  Future<Map<String, dynamic>> _request(
    Future<Response<Object?>> Function() send,
  ) async {
    try {
      final response = await send();
      return _asMap(response.data);
    } on DioException catch (error) {
      final data = _asMap(error.response?.data);
      throw SportoApiException(
        (data['message'] ?? error.message ?? 'Request failed').toString(),
        statusCode: error.response?.statusCode,
        errors: data['errors'],
      );
    }
  }

  Map<String, dynamic> _asMap(Object? data) {
    if (data is Map) return Map<String, dynamic>.from(data);
    return <String, dynamic>{'data': data};
  }
}

class _SportoDioLogInterceptor extends Interceptor {
  static const _startedAtKey = 'sporto_started_at';

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    options.extra[_startedAtKey] = DateTime.now();
    _log(
      'REQUEST ${options.method} ${options.uri}\n'
      'headers=${_redact(options.headers)}\n'
      'body=${_redact(options.data)}',
    );
    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    _log(
      'RESPONSE ${response.statusCode} ${response.requestOptions.method} '
      '${response.requestOptions.uri} (${_elapsed(response.requestOptions)})\n'
      'body=${_redact(response.data)}',
    );
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    _log(
      'ERROR ${err.response?.statusCode ?? '-'} '
      '${err.requestOptions.method} ${err.requestOptions.uri} '
      '(${_elapsed(err.requestOptions)})\n'
      'message=${err.message}\n'
      'requestBody=${_redact(err.requestOptions.data)}\n'
      'responseBody=${_redact(err.response?.data)}',
    );
    handler.next(err);
  }

  static String _elapsed(RequestOptions options) {
    final startedAt = options.extra[_startedAtKey];
    if (startedAt is! DateTime) return 'unknown';
    return '${DateTime.now().difference(startedAt).inMilliseconds}ms';
  }

  static Object? _redact(Object? value) {
    if (value is Map) {
      return value.map((key, val) {
        final keyText = key.toString().toLowerCase();
        if (keyText == 'authorization' ||
            keyText.contains('token') ||
            keyText.contains('otp')) {
          return MapEntry(key, '<redacted>');
        }
        return MapEntry(key, _redact(val));
      });
    }
    if (value is List) return value.map(_redact).toList();
    return value;
  }

  static void _log(String message) {
    if (kDebugMode) {
      debugPrint('[SportoApi] $message');
    }
  }
}
