import 'package:equatable/equatable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/result/result.dart';
import '../../../../core/utils/hebrew_normalizer.dart';
import '../../../conversation/domain/entities/binyan.dart';
import '../../../conversation/domain/entities/hebrew_text.dart';
import '../../../srs/domain/entities/srs_card.dart';
import '../entities/dictionary_entry.dart';
import '../repositories/dictionary_repository.dart';

typedef DictionaryClockUtc = DateTime Function();

/// Input payload for creating a custom user word entry in the dictionary.
final class AddCustomDictionaryEntryParams extends Equatable {
  const AddCustomDictionaryEntryParams({
    required this.hebrewVocalized,
    required this.russianTranslation,
    this.transliteration,
    this.category = LexicalCategory.noun,
    this.rawRoot,
    this.binyan = Binyan.none,
    this.formsSummary,
    this.exampleHebrewVocalized,
    this.exampleRussian,
  });

  final String hebrewVocalized;
  final String russianTranslation;
  final String? transliteration;
  final LexicalCategory category;
  final String? rawRoot;
  final Binyan binyan;
  final String? formsSummary;
  final String? exampleHebrewVocalized;
  final String? exampleRussian;

  @override
  List<Object?> get props => [
        hebrewVocalized,
        russianTranslation,
        transliteration,
        category,
        rawRoot,
        binyan,
        formsSummary,
        exampleHebrewVocalized,
        exampleRussian,
      ];
}

/// Validates and saves a learner-authored word into the local dictionary.
class AddCustomDictionaryEntryUseCase {
  AddCustomDictionaryEntryUseCase({
    required DictionaryRepository repository,
    DictionaryClockUtc? clock,
  })  : _repository = repository,
        _clock = clock ?? (() => DateTime.now().toUtc());

  final DictionaryRepository _repository;
  final DictionaryClockUtc _clock;

  Future<Result<DictionaryEntry, Failure>> call(
    AddCustomDictionaryEntryParams params,
  ) async {
    final hebrewRes = HebrewText.create(params.hebrewVocalized);
    if (hebrewRes case Error(:final failure)) {
      return Error(failure);
    }
    final hebrew = hebrewRes.getOrNull()!;
    if (HebrewNormalizer.extractHebrewLetters(hebrew.normalized).isEmpty) {
      return const Error(
        ValidationFailure('Слово должно содержать хотя бы одну букву иврита.'),
      );
    }

    final translation = params.russianTranslation.trim();
    if (translation.isEmpty) {
      return const Error(
        ValidationFailure('Перевод слова не может быть пустым.'),
      );
    }

    Shoresh? parsedRoot;
    final rawRoot = params.rawRoot?.trim();
    if (rawRoot != null && rawRoot.isNotEmpty) {
      final rootRes = Shoresh.create(rawRoot);
      switch (rootRes) {
        case Success(:final data):
          parsedRoot = data;
        case Error(:final failure):
          return Error(failure);
      }
    }

    HebrewText? exampleHeb;
    final rawEx = params.exampleHebrewVocalized?.trim();
    if (rawEx != null && rawEx.isNotEmpty) {
      final exRes = HebrewText.create(rawEx);
      switch (exRes) {
        case Success(:final data):
          exampleHeb = data;
        case Error(:final failure):
          return Error(failure);
      }
    }

    final now = _clock();
    final safeSlug = HebrewNormalizer.extractHebrewLetters(hebrew.normalized);
    final entry = DictionaryEntry(
      id: 'user_${safeSlug}_${now.microsecondsSinceEpoch}',
      hebrew: hebrew,
      russianTranslation: translation,
      transliteration: _trimOrNull(params.transliteration),
      category: params.category,
      root: parsedRoot,
      binyan: params.binyan,
      formsSummary: _trimOrNull(params.formsSummary),
      exampleHebrew: exampleHeb,
      exampleRussian: _trimOrNull(params.exampleRussian),
      attribution: const ContentAttribution(
        sourceName: 'Личный словарь',
        licenseName: 'User Content',
      ),
      isUserAdded: true,
      createdAt: now,
    );

    return _repository.saveCustomEntry(entry);
  }

  static String? _trimOrNull(String? value) {
    final trimmed = value?.trim();
    return (trimmed == null || trimmed.isEmpty) ? null : trimmed;
  }
}
