import 'package:dio/dio.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/logging/app_logger.dart';
import '../../../../core/network/dio_client_factory.dart';
import '../../../../core/network/json_reader.dart';
import '../../../../core/result/result.dart';
import '../models/dialogue_node_dto.dart';
import 'dialogue_local_datasource.dart';

abstract interface class DialogueRemoteDataSource {
  bool get isRemoteEnabled;
  Future<Result<DialogueNodeDto, Failure>> fetchNode(String id);
  Future<Result<void, Failure>> pushHistory(
    List<DialogueHistoryRecord> entries,
  );
}

final class DioDialogueRemoteDataSource implements DialogueRemoteDataSource {
  static const String _tag = 'DioDialogueRemoteDataSource';

  final Dio _dio;
  final ApiEnvironmentConfig _config;
  final AppLogger _logger;

  const DioDialogueRemoteDataSource({
    required Dio dio,
    required ApiEnvironmentConfig config,
    required AppLogger logger,
  })  : _dio = dio,
        _config = config,
        _logger = logger;

  @override
  bool get isRemoteEnabled => _config.isRemoteEnabled;

  @override
  Future<Result<DialogueNodeDto, Failure>> fetchNode(String id) async {
    if (!isRemoteEnabled) {
      return const Error(
        NetworkFailure('Remote API base URL is not configured (offline mode)'),
      );
    }

    try {
      final response = await _dio.get<Object?>('/v1/dialogues/nodes/$id');
      final body = response.data;
      final readerRes = switch (body) {
        final Map<Object?, Object?> rawMap => JsonReader.fromRawMap(rawMap),
        final String rawJson => JsonReader.parseObject(rawJson),
        _ => const Error<JsonReader, ParsingFailure>(
            ParsingFailure('Unexpected response body type for dialogue node'),
          ),
      };

      switch (readerRes) {
        case Success(:final data):
          final dtoRes = DialogueNodeDto.fromReader(data);
          return switch (dtoRes) {
            Success(data: final dto) => Success<DialogueNodeDto, Failure>(dto),
            Error(:final failure) => Error<DialogueNodeDto, Failure>(failure),
          };
        case Error(:final failure):
          return Error<DialogueNodeDto, Failure>(failure);
      }
    } on DioException catch (error, stackTrace) {
      return Error(_mapDioException(error, stackTrace));
    } on Object catch (error, stackTrace) {
      _logger.error(
        _tag,
        'Unexpected error fetching remote node "$id"',
        errorDetails: error.toString(),
        stackTrace: stackTrace,
      );
      return const Error(
        ServerFailure('Unexpected error communicating with server'),
      );
    }
  }

  @override
  Future<Result<void, Failure>> pushHistory(
    List<DialogueHistoryRecord> entries,
  ) async {
    if (!isRemoteEnabled) {
      return const Error(
        NetworkFailure('Remote API base URL is not configured (offline mode)'),
      );
    }
    if (entries.isEmpty) {
      return const Success(null);
    }

    final payload = <String, Object?>{
      'entries': entries
          .map(
            (entry) => <String, Object?>{
              'node_id': entry.nodeId,
              'option_id': entry.selectedOptionId,
              'answered_at': entry.answeredAt.toUtc().toIso8601String(),
            },
          )
          .toList(growable: false),
    };

    try {
      await _dio.post<Object?>('/v1/dialogues/history', data: payload);
      return const Success(null);
    } on DioException catch (error, stackTrace) {
      return Error(_mapDioException(error, stackTrace));
    } on Object catch (error, stackTrace) {
      _logger.error(
        _tag,
        'Unexpected error pushing dialogue history',
        errorDetails: error.toString(),
        stackTrace: stackTrace,
      );
      return const Error(
        ServerFailure('Unexpected error syncing dialogue history'),
      );
    }
  }

  Failure _mapDioException(DioException error, StackTrace stackTrace) {
    _logger.warning(
      _tag,
      'Dio failure (${error.type.name}) at ${error.requestOptions.path}',
    );
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.transformTimeout:
      case DioExceptionType.connectionError:
        return const NetworkFailure(
          'Network connection unavailable or timed out',
        );
      case DioExceptionType.badResponse:
        final statusCode = error.response?.statusCode;
        return ServerFailure(
          'Server returned error status ${statusCode ?? 'unknown'}',
          statusCode: statusCode,
        );
      case DioExceptionType.cancel:
        return const NetworkFailure('Network request was cancelled');
      case DioExceptionType.badCertificate:
      case DioExceptionType.unknown:
        _logger.error(
          _tag,
          'Transport error: ${error.message ?? 'unknown'}',
          stackTrace: stackTrace,
        );
        return const NetworkFailure('Secure network transport failed');
    }
  }
}
