import 'package:dio/dio.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/logging/app_logger.dart';
import '../../../../core/network/json_reader.dart';
import '../../../../core/result/result.dart';
import '../models/srs_card_dto.dart';

abstract interface class TatoebaRemoteDataSource {
  Future<Result<List<SrsCardDto>, Failure>> searchHebrewRussianSentences({
    required String query,
    int limit = 10,
  });
}

/// Fetches open-licensed Hebrew <-> Russian sentences and CC0/CC-BY audio from Tatoeba API v1.
final class DioTatoebaRemoteDataSource implements TatoebaRemoteDataSource {
  static const String _tag = 'DioTatoebaRemoteDataSource';
  static const String _tatoebaEndpoint =
      'https://api.tatoeba.org/v1/sentences';

  final Dio _dio;
  final AppLogger _logger;

  const DioTatoebaRemoteDataSource({
    required Dio dio,
    required AppLogger logger,
  })  : _dio = dio,
        _logger = logger;

  @override
  Future<Result<List<SrsCardDto>, Failure>> searchHebrewRussianSentences({
    required String query,
    int limit = 10,
  }) async {
    try {
      final response = await _dio.get<Object?>(
        _tatoebaEndpoint,
        queryParameters: <String, Object?>{
          'lang': 'heb',
          'q': query,
          'trans:lang': 'rus',
          'showtrans:lang': 'rus',
          'include': 'audios',
          'limit': limit,
        },
      );

      final body = response.data;
      final readerRes = switch (body) {
        final Map<Object?, Object?> rawMap => JsonReader.fromRawMap(rawMap),
        final String rawJson => JsonReader.parseObject(rawJson),
        _ => const Error<JsonReader, ParsingFailure>(
            ParsingFailure('Unexpected Tatoeba response payload type'),
          ),
      };

      switch (readerRes) {
        case Success(:final data):
          final dtoRes = TatoebaResponseParser.parseSearchResponse(data);
          return switch (dtoRes) {
            Success(data: final cards) =>
              Success<List<SrsCardDto>, Failure>(cards),
            Error(:final failure) => Error<List<SrsCardDto>, Failure>(failure),
          };
        case Error(:final failure):
          return Error<List<SrsCardDto>, Failure>(failure);
      }
    } on DioException catch (error, stackTrace) {
      _logger.warning(
        _tag,
        'Tatoeba API request failed (${error.type.name})',
      );
      return Error(_mapDioException(error, stackTrace));
    } on Object catch (error, stackTrace) {
      _logger.error(
        _tag,
        'Unexpected failure querying Tatoeba API',
        errorDetails: error.toString(),
        stackTrace: stackTrace,
      );
      return const Error(
        ServerFailure('Unable to import sentences from Tatoeba right now'),
      );
    }
  }

  Failure _mapDioException(DioException error, StackTrace stackTrace) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.transformTimeout:
      case DioExceptionType.connectionError:
      case DioExceptionType.cancel:
        return const NetworkFailure(
          'Нет соединения с сервером Tatoeba или превышен таймаут',
        );
      case DioExceptionType.badResponse:
        final status = error.response?.statusCode;
        return ServerFailure(
          'Tatoeba API error (${status ?? 'unknown'})',
          statusCode: status,
        );
      case DioExceptionType.badCertificate:
      case DioExceptionType.unknown:
        _logger.error(
          _tag,
          'Tatoeba transport error: ${error.message ?? 'unknown'}',
          stackTrace: stackTrace,
        );
        return const NetworkFailure('Ошибка защищённого соединения с Tatoeba');
    }
  }
}
