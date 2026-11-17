import 'package:dio/dio.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/logging/app_logger.dart';
import '../../../../core/network/json_reader.dart';
import '../../../../core/result/result.dart';
import '../../../../core/utils/hebrew_normalizer.dart';
import '../../../srs/data/models/srs_card_dto.dart';
import '../models/dictionary_entry_dto.dart';

abstract interface class DictionaryRemoteDataSource {
  /// Searches open-licensed bidirectional Hebrew<->Russian corpora online.
  Future<Result<List<DictionaryEntryDto>, Failure>> searchOnline({
    required String query,
    int limit = 12,
  });
}

/// Fetches open-licensed Hebrew <-> Russian entries from Tatoeba API v1.
final class OpenDictionaryRemoteDataSource
    implements DictionaryRemoteDataSource {
  static const String _tag = 'OpenDictionaryRemoteDataSource';
  static const String _tatoebaEndpoint =
      'https://api.tatoeba.org/v1/sentences';

  const OpenDictionaryRemoteDataSource({
    required Dio dio,
    required AppLogger logger,
  })  : _dio = dio,
        _logger = logger;

  final Dio _dio;
  final AppLogger _logger;

  @override
  Future<Result<List<DictionaryEntryDto>, Failure>> searchOnline({
    required String query,
    int limit = 12,
  }) async {
    final trimmed = query.trim();
    if (trimmed.isEmpty) {
      return const Success(<DictionaryEntryDto>[]);
    }

    final isHebrewQuery =
        HebrewNormalizer.extractHebrewLetters(trimmed).isNotEmpty;
    final sourceLang = isHebrewQuery ? 'heb' : 'rus';
    final targetLang = isHebrewQuery ? 'rus' : 'heb';

    try {
      final response = await _dio.get<Object?>(
        _tatoebaEndpoint,
        queryParameters: <String, Object?>{
          'lang': sourceLang,
          'q': trimmed,
          'trans:lang': targetLang,
          'showtrans:lang': targetLang,
          'sort': 'relevance',
          if (isHebrewQuery) 'include': 'audios',
          'limit': limit,
        },
      );

      final body = response.data;
      final readerRes = switch (body) {
        final Map<Object?, Object?> rawMap => JsonReader.fromRawMap(rawMap),
        final String rawJson => JsonReader.parseObject(rawJson),
        _ => const Error<JsonReader, ParsingFailure>(
            ParsingFailure('Неожиданный формат ответа Tatoeba API'),
          ),
      };

      switch (readerRes) {
        case Success(:final data):
          return TatoebaDictionaryParser.parseBidirectionalResponse(
            rootReader: data,
            sourceLang: sourceLang,
          );
        case Error(:final failure):
          return Error(failure);
      }
    } on DioException catch (error, stackTrace) {
      _logger.warning(
        _tag,
        'Online dictionary query failed (${error.type.name})',
      );
      return Error(_mapDioException(error, stackTrace));
    } on Object catch (error, stackTrace) {
      _logger.error(
        _tag,
        'Unexpected failure during online dictionary search',
        errorDetails: error.toString(),
        stackTrace: stackTrace,
      );
      return const Error(
        ServerFailure('Не удалось выполнить онлайн-поиск в Tatoeba'),
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
          'Нет связи с сервером Tatoeba или превышен таймаут',
        );
      case DioExceptionType.badResponse:
        final status = error.response?.statusCode;
        return ServerFailure(
          'Ошибка Tatoeba API (${status ?? 'unknown'})',
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

/// Parses Tatoeba API v1 responses in both `heb -> rus` and `rus -> heb` directions.
final class TatoebaDictionaryParser {
  TatoebaDictionaryParser._();

  static Result<List<DictionaryEntryDto>, ParsingFailure>
      parseBidirectionalResponse({
    required JsonReader rootReader,
    required String sourceLang,
  }) {
    final itemsRes =
        rootReader.firstPresentObjectList(const ['data', 'results']);
    if (itemsRes case Error(:final failure)) {
      return Error(failure);
    }

    final dtos = <DictionaryEntryDto>[];
    for (final item in itemsRes.getOrNull()!) {
      final parsed = _parseSentenceItem(item, sourceLang: sourceLang);
      switch (parsed) {
        case Error(:final failure):
          return Error(failure);
        case Success(:final data):
          if (data != null) {
            dtos.add(data);
          }
      }
    }

    return Success(List<DictionaryEntryDto>.unmodifiable(dtos));
  }

  static Result<DictionaryEntryDto?, ParsingFailure> _parseSentenceItem(
    JsonReader item, {
    required String sourceLang,
  }) {
    final idRes = item.requireInt('id');
    final textRes = item.requireNonEmptyString('text');
    if (idRes case Error(:final failure)) return Error(failure);
    if (textRes case Error(:final failure)) return Error(failure);

    final sentenceId = idRes.getOrNull()!;
    final sourceText = textRes.getOrNull()!;

    final translationsRes = item.optionalFlattenedObjectList('translations');
    if (translationsRes case Error(:final failure)) return Error(failure);

    final targetLang = sourceLang == 'heb' ? 'rus' : 'heb';
    String? translatedText;
    for (final tr in translationsRes.getOrNull()!) {
      final lang = tr.optionalNonEmptyString('lang').getOrNull();
      final text = tr.optionalNonEmptyString('text').getOrNull();
      if (lang == targetLang && text != null) {
        translatedText = text;
        break;
      }
    }
    if (translatedText == null) {
      return const Success(null);
    }

    final hebrewText = sourceLang == 'heb' ? sourceText : translatedText;
    final russianText = sourceLang == 'heb' ? translatedText : sourceText;

    if (HebrewNormalizer.extractHebrewLetters(hebrewText).isEmpty) {
      return const Success(null);
    }

    final textLicense = item.optionalNonEmptyString('textLicence').getOrNull() ??
        item.optionalNonEmptyString('license').getOrNull() ??
        'CC BY 2.0 FR';

    String? verifiedAudioUrl;
    String? audioAuthor;
    String? audioLicense;

    // Only accept audio recordings attached to Hebrew source sentences.
    if (sourceLang == 'heb') {
      final audiosRes = item.optionalObjectList('audios');
      if (audiosRes case Error(:final failure)) return Error(failure);
      for (final audioReader in audiosRes.getOrNull()!) {
        final license = audioReader.optionalNonEmptyString('license').getOrNull();
        if (license != null &&
            TatoebaResponseParser.isPermissiveAudioLicense(license)) {
          final rawUrl = audioReader.optionalNonEmptyString('url').getOrNull();
          verifiedAudioUrl = rawUrl ??
              'https://audio.tatoeba.org/sentences/heb/$sentenceId.mp3';
          audioAuthor =
              audioReader.optionalNonEmptyString('author').getOrNull();
          audioLicense = license;
          break;
        }
      }
    }

    final attributionParts = <String>[
      'Tatoeba #$sentenceId ($textLicense)',
      if (audioAuthor != null && audioLicense != null)
        'Audio by $audioAuthor ($audioLicense)',
    ];

    return Success(
      DictionaryEntryDto(
        id: 'tatoeba_dict_$sentenceId',
        hebrewVocalized: hebrewText,
        russianTranslation: russianText,
        category: 'phrase',
        audioUrl: verifiedAudioUrl,
        sourceName: 'Tatoeba.org',
        licenseName: audioLicense ?? textLicense,
        attributionText: attributionParts.join(' · '),
      ),
    );
  }
}
