import 'package:dio/dio.dart';

import '../logging/app_logger.dart';
import '../result/result.dart';
import '../security/secure_token_storage.dart';

final class ApiEnvironmentConfig {
  static const String envBaseUrl = String.fromEnvironment('API_BASE_URL');

  final String baseUrl;
  final Duration connectTimeout;
  final Duration receiveTimeout;

  const ApiEnvironmentConfig({
    required this.baseUrl,
    this.connectTimeout = const Duration(seconds: 10),
    this.receiveTimeout = const Duration(seconds: 15),
  });

  factory ApiEnvironmentConfig.fromEnvironment() {
    return const ApiEnvironmentConfig(baseUrl: envBaseUrl);
  }

  bool get isRemoteEnabled => baseUrl.trim().isNotEmpty;
}

final class DioClientFactory {
  DioClientFactory._();

  static Dio create({
    required ApiEnvironmentConfig config,
    required SecureTokenStorage tokenStorage,
    required AppLogger logger,
  }) {
    final dio = Dio(
      BaseOptions(
        baseUrl: config.baseUrl,
        connectTimeout: config.connectTimeout,
        receiveTimeout: config.receiveTimeout,
        headers: const <String, String>{
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
      ),
    );

    dio.interceptors.add(
      _AuthAndLoggingInterceptor(
        tokenStorage: tokenStorage,
        logger: logger,
      ),
    );

    return dio;
  }
}

final class _AuthAndLoggingInterceptor extends Interceptor {
  static const String _tag = 'DioHttp';

  final SecureTokenStorage _tokenStorage;
  final AppLogger _logger;

  _AuthAndLoggingInterceptor({
    required SecureTokenStorage tokenStorage,
    required AppLogger logger,
  })  : _tokenStorage = tokenStorage,
        _logger = logger;

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final tokenResult = await _tokenStorage.readAccessToken();
    switch (tokenResult) {
      case Success(:final data):
        if (data != null && data.isNotEmpty) {
          options.headers['Authorization'] = 'Bearer $data';
        }
      case Error(:final failure):
        _logger.warning(
          _tag,
          'Proceeding without auth header due to secure storage error',
          failure: failure,
        );
    }

    _logger.debug(_tag, '--> ${options.method} ${options.path}');
    handler.next(options);
  }

  @override
  void onResponse(
    Response<Object?> response,
    ResponseInterceptorHandler handler,
  ) {
    _logger.debug(
      _tag,
      '<-- ${response.statusCode ?? 0} ${response.requestOptions.path}',
    );
    handler.next(response);
  }

  @override
  void onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) {
    _logger.warning(
      _tag,
      '<-- ERROR ${err.response?.statusCode ?? err.type.name} ${err.requestOptions.path}',
    );
    handler.next(err);
  }
}
