import 'package:equatable/equatable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/network/json_reader.dart';
import '../../../../core/result/result.dart';
import '../../../conversation/domain/entities/binyan.dart';
import '../../../conversation/domain/entities/hebrew_text.dart';
import '../../domain/entities/fsrs_models.dart';
import '../../domain/entities/srs_card.dart';

final class SrsCardDto extends Equatable {
  final String id;
  final String hebrewVocalized;
  final String russianTranslation;
  final String? root;
  final String binyan;
  final String category;
  final String? exampleHebrew;
  final String? exampleRussian;
  final String? audioUrl;
  final String sourceName;
  final String licenseName;
  final String? attributionText;

  const SrsCardDto({
    required this.id,
    required this.hebrewVocalized,
    required this.russianTranslation,
    required this.sourceName,
    required this.licenseName,
    this.root,
    this.binyan = 'none',
    this.category = 'phrase',
    this.exampleHebrew,
    this.exampleRussian,
    this.audioUrl,
    this.attributionText,
  });

  static Result<SrsCardDto, ParsingFailure> fromReader(JsonReader reader) {
    final idRes = reader.requireNonEmptyString('id');
    final hebRes = reader.requireNonEmptyString('hebrew_vocalized');
    final rusRes = reader.requireNonEmptyString('russian_translation');
    final rootRes = reader.optionalNonEmptyString('root');
    final binyanRes = reader.optionalNonEmptyString('binyan');
    final categoryRes = reader.optionalNonEmptyString('category');
    final exHebRes = reader.optionalNonEmptyString('example_hebrew');
    final exRusRes = reader.optionalNonEmptyString('example_russian');
    final audioRes = reader.optionalNonEmptyString('audio_url');
    final sourceRes = reader.requireNonEmptyString('source_name');
    final licenseRes = reader.requireNonEmptyString('license_name');
    final attributionRes = reader.optionalNonEmptyString('attribution_text');

    if (idRes case Error(:final failure)) return Error(failure);
    if (hebRes case Error(:final failure)) return Error(failure);
    if (rusRes case Error(:final failure)) return Error(failure);
    if (rootRes case Error(:final failure)) return Error(failure);
    if (binyanRes case Error(:final failure)) return Error(failure);
    if (categoryRes case Error(:final failure)) return Error(failure);
    if (exHebRes case Error(:final failure)) return Error(failure);
    if (exRusRes case Error(:final failure)) return Error(failure);
    if (audioRes case Error(:final failure)) return Error(failure);
    if (sourceRes case Error(:final failure)) return Error(failure);
    if (licenseRes case Error(:final failure)) return Error(failure);
    if (attributionRes case Error(:final failure)) return Error(failure);

    return Success(
      SrsCardDto(
        id: idRes.getOrNull()!,
        hebrewVocalized: hebRes.getOrNull()!,
        russianTranslation: rusRes.getOrNull()!,
        root: rootRes.getOrNull(),
        binyan: binyanRes.getOrNull() ?? 'none',
        category: categoryRes.getOrNull() ?? 'phrase',
        exampleHebrew: exHebRes.getOrNull(),
        exampleRussian: exRusRes.getOrNull(),
        audioUrl: audioRes.getOrNull(),
        sourceName: sourceRes.getOrNull()!,
        licenseName: licenseRes.getOrNull()!,
        attributionText: attributionRes.getOrNull(),
      ),
    );
  }

  Result<SrsCard, Failure> toDomain({required FsrsMemoryState memory}) {
    final hebrewRes = HebrewText.create(hebrewVocalized);
    if (hebrewRes case Error(:final failure)) {
      return Error(ParsingFailure('Card "$id": ${failure.message}'));
    }

    final binyanRes = Binyan.parseStrict(binyan);
    if (binyanRes case Error(:final failure)) {
      return Error(ParsingFailure('Card "$id": ${failure.message}'));
    }

    final categoryRes = LexicalCategory.parseStrict(category);
    if (categoryRes case Error(:final failure)) {
      return Error(ParsingFailure('Card "$id": ${failure.message}'));
    }

    Shoresh? parsedRoot;
    if (root != null) {
      final rootRes = Shoresh.create(root!);
      switch (rootRes) {
        case Success(:final data):
          parsedRoot = data;
        case Error(:final failure):
          return Error(ParsingFailure('Card "$id": ${failure.message}'));
      }
    }

    HebrewText? parsedExample;
    if (exampleHebrew != null) {
      final exRes = HebrewText.create(exampleHebrew!);
      switch (exRes) {
        case Success(:final data):
          parsedExample = data;
        case Error(:final failure):
          return Error(ParsingFailure('Card "$id" example: ${failure.message}'));
      }
    }

    return Success(
      SrsCard(
        id: id,
        hebrew: hebrewRes.getOrNull()!,
        russianTranslation: russianTranslation,
        root: parsedRoot,
        binyan: binyanRes.getOrNull()!,
        category: categoryRes.getOrNull()!,
        exampleHebrew: parsedExample,
        exampleRussian: exampleRussian,
        audioUrl: audioUrl,
        attribution: ContentAttribution(
          sourceName: sourceName,
          licenseName: licenseName,
          attributionText: attributionText,
        ),
        memory: memory,
      ),
    );
  }

  @override
  List<Object?> get props => [
        id,
        hebrewVocalized,
        russianTranslation,
        root,
        binyan,
        category,
        exampleHebrew,
        exampleRussian,
        audioUrl,
        sourceName,
        licenseName,
        attributionText,
      ];
}

final class TatoebaResponseParser {
  TatoebaResponseParser._();

  static Result<List<SrsCardDto>, ParsingFailure> parseSearchResponse(
    JsonReader rootReader,
  ) {
    final itemsRes =
        rootReader.firstPresentObjectList(const ['data', 'results']);
    if (itemsRes case Error(:final failure)) {
      return Error(failure);
    }

    final cards = <SrsCardDto>[];
    for (final sentenceReader in itemsRes.getOrNull()!) {
      final cardOpt = _parseSentenceItem(sentenceReader);
      switch (cardOpt) {
        case Error(:final failure):
          return Error(failure);
        case Success(:final data):
          if (data != null) {
            cards.add(data);
          }
      }
    }

    return Success(List<SrsCardDto>.unmodifiable(cards));
  }

  static Result<SrsCardDto?, ParsingFailure> _parseSentenceItem(
    JsonReader sentenceReader,
  ) {
    final idRes = sentenceReader.requireInt('id');
    final textRes = sentenceReader.requireNonEmptyString('text');
    if (idRes case Error(:final failure)) return Error(failure);
    if (textRes case Error(:final failure)) return Error(failure);

    final translationsRes =
        sentenceReader.optionalFlattenedObjectList('translations');
    if (translationsRes case Error(:final failure)) return Error(failure);

    String? russianTranslation;
    for (final tr in translationsRes.getOrNull()!) {
      final langRes = tr.optionalNonEmptyString('lang');
      final trTextRes = tr.optionalNonEmptyString('text');
      if (langRes case Success(:final data) when data == 'rus') {
        if (trTextRes case Success(:final data) when data != null) {
          russianTranslation = data;
          break;
        }
      }
    }

    if (russianTranslation == null) {
      return const Success(null);
    }

    final textLicenseRes =
        sentenceReader.optionalNonEmptyString('textLicence');
    final fallbackLicenseRes = sentenceReader.optionalNonEmptyString('license');
    final textLicense = textLicenseRes.getOrNull() ??
        fallbackLicenseRes.getOrNull() ??
        'CC BY 2.0 FR';

    final audiosRes = sentenceReader.optionalObjectList('audios');
    if (audiosRes case Error(:final failure)) return Error(failure);

    String? verifiedAudioUrl;
    String? audioAuthor;
    String? audioLicense;

    final sentenceId = idRes.getOrNull()!;
    for (final audioReader in audiosRes.getOrNull()!) {
      final licRes = audioReader.optionalNonEmptyString('license');
      final license = licRes.getOrNull();
      if (license != null && isPermissiveAudioLicense(license)) {
        final rawUrl = audioReader.optionalNonEmptyString('url').getOrNull();
        verifiedAudioUrl = rawUrl ??
            'https://audio.tatoeba.org/sentences/heb/$sentenceId.mp3';
        audioAuthor = audioReader.optionalNonEmptyString('author').getOrNull();
        audioLicense = license;
        break;
      }
    }

    final attributionParts = <String>[
      'Tatoeba #$sentenceId ($textLicense)',
      if (audioAuthor != null && audioLicense != null)
        'Audio by $audioAuthor ($audioLicense)',
    ];

    return Success(
      SrsCardDto(
        id: 'tatoeba_$sentenceId',
        hebrewVocalized: textRes.getOrNull()!,
        russianTranslation: russianTranslation,
        category: 'phrase',
        audioUrl: verifiedAudioUrl,
        sourceName: 'Tatoeba',
        licenseName: audioLicense ?? textLicense,
        attributionText: attributionParts.join(' · '),
      ),
    );
  }

  /// Accepts only CC0 or CC-BY licenses (rejecting NC / ND / no-offsite-license).
  static bool isPermissiveAudioLicense(String rawLicense) {
    final normalized = rawLicense.trim().toUpperCase();
    if (normalized.isEmpty) {
      return false;
    }
    if (normalized.contains('NC') ||
        normalized.contains('ND') ||
        normalized.contains('NO LICENSE') ||
        normalized.contains('RESTRICTED')) {
      return false;
    }
    return normalized.contains('CC0') ||
        normalized.contains('CC BY') ||
        normalized.contains('CC-BY');
  }
}
