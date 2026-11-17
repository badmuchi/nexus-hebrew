import 'package:equatable/equatable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/network/json_reader.dart';
import '../../../../core/result/result.dart';
import '../../../conversation/domain/entities/binyan.dart';
import '../../../conversation/domain/entities/hebrew_text.dart';
import '../../../srs/domain/entities/srs_card.dart';
import '../../domain/entities/dictionary_entry.dart';

/// Strict DTO for offline JSON seed & cached online dictionary entries.
final class DictionaryEntryDto extends Equatable {
  const DictionaryEntryDto({
    required this.id,
    required this.hebrewVocalized,
    required this.russianTranslation,
    required this.sourceName,
    required this.licenseName,
    this.transliteration,
    this.category = 'noun',
    this.root,
    this.binyan = 'none',
    this.formsSummary,
    this.exampleHebrew,
    this.exampleRussian,
    this.audioUrl,
    this.frequencyRank,
    this.attributionText,
  });

  final String id;
  final String hebrewVocalized;
  final String russianTranslation;
  final String? transliteration;
  final String category;
  final String? root;
  final String binyan;
  final String? formsSummary;
  final String? exampleHebrew;
  final String? exampleRussian;
  final String? audioUrl;
  final int? frequencyRank;
  final String sourceName;
  final String licenseName;
  final String? attributionText;

  static Result<DictionaryEntryDto, ParsingFailure> fromReader(
    JsonReader reader,
  ) {
    final idRes = reader.requireNonEmptyString('id');
    final hebRes = reader.requireNonEmptyString('hebrew_vocalized');
    final rusRes = reader.requireNonEmptyString('russian_translation');
    final translitRes = reader.optionalNonEmptyString('transliteration');
    final categoryRes = reader.optionalNonEmptyString('category');
    final rootRes = reader.optionalNonEmptyString('root');
    final binyanRes = reader.optionalNonEmptyString('binyan');
    final formsRes = reader.optionalNonEmptyString('forms_summary');
    final exHebRes = reader.optionalNonEmptyString('example_hebrew');
    final exRusRes = reader.optionalNonEmptyString('example_russian');
    final audioRes = reader.optionalNonEmptyString('audio_url');
    final rankRes = reader.optionalInt('frequency_rank');
    final sourceRes = reader.requireNonEmptyString('source_name');
    final licenseRes = reader.requireNonEmptyString('license_name');
    final attributionRes = reader.optionalNonEmptyString('attribution_text');

    if (idRes case Error(:final failure)) return Error(failure);
    if (hebRes case Error(:final failure)) return Error(failure);
    if (rusRes case Error(:final failure)) return Error(failure);
    if (translitRes case Error(:final failure)) return Error(failure);
    if (categoryRes case Error(:final failure)) return Error(failure);
    if (rootRes case Error(:final failure)) return Error(failure);
    if (binyanRes case Error(:final failure)) return Error(failure);
    if (formsRes case Error(:final failure)) return Error(failure);
    if (exHebRes case Error(:final failure)) return Error(failure);
    if (exRusRes case Error(:final failure)) return Error(failure);
    if (audioRes case Error(:final failure)) return Error(failure);
    if (rankRes case Error(:final failure)) return Error(failure);
    if (sourceRes case Error(:final failure)) return Error(failure);
    if (licenseRes case Error(:final failure)) return Error(failure);
    if (attributionRes case Error(:final failure)) return Error(failure);

    return Success(
      DictionaryEntryDto(
        id: idRes.getOrNull()!,
        hebrewVocalized: hebRes.getOrNull()!,
        russianTranslation: rusRes.getOrNull()!,
        transliteration: translitRes.getOrNull(),
        category: categoryRes.getOrNull() ?? 'noun',
        root: rootRes.getOrNull(),
        binyan: binyanRes.getOrNull() ?? 'none',
        formsSummary: formsRes.getOrNull(),
        exampleHebrew: exHebRes.getOrNull(),
        exampleRussian: exRusRes.getOrNull(),
        audioUrl: audioRes.getOrNull(),
        frequencyRank: rankRes.getOrNull(),
        sourceName: sourceRes.getOrNull()!,
        licenseName: licenseRes.getOrNull()!,
        attributionText: attributionRes.getOrNull(),
      ),
    );
  }

  Result<DictionaryEntry, Failure> toDomain({
    required DateTime createdAt,
    bool isUserAdded = false,
  }) {
    final hebrewRes = HebrewText.create(hebrewVocalized);
    if (hebrewRes case Error(:final failure)) {
      return Error(ParsingFailure('Dictionary "$id": ${failure.message}'));
    }

    final categoryRes = LexicalCategory.parseStrict(category);
    if (categoryRes case Error(:final failure)) {
      return Error(ParsingFailure('Dictionary "$id": ${failure.message}'));
    }

    final binyanRes = Binyan.parseStrict(binyan);
    if (binyanRes case Error(:final failure)) {
      return Error(ParsingFailure('Dictionary "$id": ${failure.message}'));
    }

    Shoresh? parsedRoot;
    if (root != null) {
      final rootRes = Shoresh.create(root!);
      switch (rootRes) {
        case Success(:final data):
          parsedRoot = data;
        case Error(:final failure):
          return Error(ParsingFailure('Dictionary "$id": ${failure.message}'));
      }
    }

    HebrewText? parsedExample;
    if (exampleHebrew != null) {
      final exRes = HebrewText.create(exampleHebrew!);
      switch (exRes) {
        case Success(:final data):
          parsedExample = data;
        case Error(:final failure):
          return Error(
            ParsingFailure('Dictionary "$id" example: ${failure.message}'),
          );
      }
    }

    return Success(
      DictionaryEntry(
        id: id,
        hebrew: hebrewRes.getOrNull()!,
        russianTranslation: russianTranslation,
        transliteration: transliteration,
        category: categoryRes.getOrNull()!,
        root: parsedRoot,
        binyan: binyanRes.getOrNull()!,
        formsSummary: formsSummary,
        exampleHebrew: parsedExample,
        exampleRussian: exampleRussian,
        audioUrl: audioUrl,
        frequencyRank: frequencyRank,
        attribution: ContentAttribution(
          sourceName: sourceName,
          licenseName: licenseName,
          attributionText: attributionText,
        ),
        isUserAdded: isUserAdded,
        createdAt: createdAt,
      ),
    );
  }

  @override
  List<Object?> get props => [
        id,
        hebrewVocalized,
        russianTranslation,
        transliteration,
        category,
        root,
        binyan,
        formsSummary,
        exampleHebrew,
        exampleRussian,
        audioUrl,
        frequencyRank,
        sourceName,
        licenseName,
        attributionText,
      ];
}
