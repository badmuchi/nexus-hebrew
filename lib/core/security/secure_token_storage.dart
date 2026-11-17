import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../error/failures.dart';
import '../logging/app_logger.dart';
import '../result/result.dart';

abstract interface class SecureTokenStorage {
  Future<Result<String?, Failure>> readAccessToken();
  Future<Result<void, Failure>> writeAccessToken(String token);
  Future<Result<void, Failure>> clearAccessToken();
}

final class FlutterSecureTokenStorage implements SecureTokenStorage {
  static const String _tag = 'SecureTokenStorage';
  static const String _accessTokenKey = 'nexus_hebrew_access_token';

  final FlutterSecureStorage _storage;
  final AppLogger _logger;

  const FlutterSecureTokenStorage({
    required FlutterSecureStorage storage,
    required AppLogger logger,
  })  : _storage = storage,
        _logger = logger;

  factory FlutterSecureTokenStorage.withDefaultOptions({
    required AppLogger logger,
  }) {
    const storage = FlutterSecureStorage(
      aOptions: AndroidOptions(resetOnError: true),
      iOptions: IOSOptions(
        accessibility: KeychainAccessibility.first_unlock,
      ),
    );
    return FlutterSecureTokenStorage(storage: storage, logger: logger);
  }

  @override
  Future<Result<String?, Failure>> readAccessToken() async {
    try {
      final token = await _storage.read(key: _accessTokenKey);
      return Success(token);
    } on Object catch (error, stackTrace) {
      _logger.error(
        _tag,
        'Failed to read access token from secure storage',
        errorDetails: error.toString(),
        stackTrace: stackTrace,
      );
      return const Error(
        CacheFailure('Unable to read secure credentials'),
      );
    }
  }

  @override
  Future<Result<void, Failure>> writeAccessToken(String token) async {
    final trimmed = token.trim();
    if (trimmed.isEmpty) {
      return const Error(
        ValidationFailure('Access token cannot be empty'),
      );
    }
    try {
      await _storage.write(key: _accessTokenKey, value: trimmed);
      return const Success(null);
    } on Object catch (error, stackTrace) {
      _logger.error(
        _tag,
        'Failed to persist access token to secure storage',
        errorDetails: error.toString(),
        stackTrace: stackTrace,
      );
      return const Error(
        CacheFailure('Unable to persist secure credentials'),
      );
    }
  }

  @override
  Future<Result<void, Failure>> clearAccessToken() async {
    try {
      await _storage.delete(key: _accessTokenKey);
      return const Success(null);
    } on Object catch (error, stackTrace) {
      _logger.error(
        _tag,
        'Failed to delete access token from secure storage',
        errorDetails: error.toString(),
        stackTrace: stackTrace,
      );
      return const Error(
        CacheFailure('Unable to clear secure credentials'),
      );
    }
  }
}
