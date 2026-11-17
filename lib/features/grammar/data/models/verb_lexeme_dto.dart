import 'dart:convert';

import 'package:equatable/equatable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/network/json_reader.dart';
import '../../../../core/result/result.dart';
import '../../../conversation/domain/entities/binyan.dart';
import '../../../conversation/domain/entities/hebrew_text.dart';
import '../../../srs/domain/entities/srs_card.dart';
import '../../domain/entities/verb_conjugation.dart';

/// Strict DTO for a single conjugated verb entry at the Data boundary.
final class ConjugatedFormDto extends Equatable {
  const ConjugatedFormDto({
    required this.tense,
    required this.person,
    required this.formVocalized,
    required this.transliteration,
  });

  final String tense;
  final String person;
  final String formVocalized;
  final String transliteration;

  /// Parses and validates a conjugated form object from [reader].
  static Result<ConjugatedFormDto, ParsingFailure> fromReader(
    JsonReader reader,
  ) {
    final tenseRes = reader.requireNonEmptyString('tense');
    if (tenseRes case Error(:final failure)) {
      return Error(failure);
    }

    final personRes = reader.requireNonEmptyString('person');
    if (personRes case Error(:final failure)) {
      return Error(failure);
    }

    final formRes = reader.requireNonEmptyString('form_vocalized');
    if (formRes case Error(:final failure)) {
      return Error(failure);
    }

    final translitRes = reader.requireNonEmptyString('transliteration');
    if (translitRes case Error(:final failure)) {
      return Error(failure);
    }

    return Success(
      ConjugatedFormDto(
        tense: tenseRes.getOrNull()!,
        person: personRes.getOrNull()!,
        formVocalized: formRes.getOrNull()!,
        transliteration: translitRes.getOrNull()!,
      ),
    );
  }

  /// Validates linguistic values and maps this DTO into [ConjugatedForm].
  Result<ConjugatedForm, Failure> toDomain() {
    final tenseRes = VerbTense.parseStrict(tense);
    if (tenseRes case Error(:final failure)) {
      return Error(failure);
    }

    final personRes = GrammaticalPerson.parseStrict(person);
    if (personRes case Error(:final failure)) {
      return Error(failure);
    }

    final hebrewRes = HebrewText.create(formVocalized);
    if (hebrewRes case Error(:final failure)) {
      return Error(failure);
    }

    return Success(
      ConjugatedForm(
        tense: tenseRes.getOrNull()!,
        person: personRes.getOrNull()!,
        form: hebrewRes.getOrNull()!,
        transliteration: transliteration,
      ),
    );
  }

  @override
  List<Object?> get props => [tense, person, formVocalized, transliteration];
}

/// Strict DTO for a Hebrew verb lexeme and its full conjugation table.
final class VerbLexemeDto extends Equatable {
  VerbLexemeDto({
    required this.id,
    required this.lemmaVocalized,
    required this.infinitiveVocalized,
    required this.root,
    required this.binyan,
    required this.russianMeaning,
    required this.grammarNotesRu,
    required List<ConjugatedFormDto> conjugations,
    required this.sourceName,
    required this.licenseName,
    this.attributionText,
  }) : conjugations = List<ConjugatedFormDto>.unmodifiable(conjugations);

  final String id;
  final String lemmaVocalized;
  final String? infinitiveVocalized;
  final String root;
  final String binyan;
  final String russianMeaning;
  final String grammarNotesRu;
  final List<ConjugatedFormDto> conjugations;
  final String sourceName;
  final String licenseName;
  final String? attributionText;

  /// Parses and validates a verb lexeme JSON object via [JsonReader].
  static Result<VerbLexemeDto, ParsingFailure> fromReader(JsonReader reader) {
    final idRes = reader.requireNonEmptyString('id');
    if (idRes case Error(:final failure)) {
      return Error(failure);
    }

    final lemmaRes = reader.requireNonEmptyString('lemma_vocalized');
    if (lemmaRes case Error(:final failure)) {
      return Error(failure);
    }

    final infinitiveRes = reader.optionalNonEmptyString('infinitive_vocalized');
    if (infinitiveRes case Error(:final failure)) {
      return Error(failure);
    }

    final rootRes = reader.requireNonEmptyString('root');
    if (rootRes case Error(:final failure)) {
      return Error(failure);
    }

    final binyanRes = reader.requireNonEmptyString('binyan');
    if (binyanRes case Error(:final failure)) {
      return Error(failure);
    }

    final meaningRes = reader.requireNonEmptyString('russian_meaning');
    if (meaningRes case Error(:final failure)) {
      return Error(failure);
    }

    final notesRes = reader.requireNonEmptyString('grammar_notes_ru');
    if (notesRes case Error(:final failure)) {
      return Error(failure);
    }

    final sourceRes = reader.requireNonEmptyString('source_name');
    if (sourceRes case Error(:final failure)) {
      return Error(failure);
    }

    final licenseRes = reader.requireNonEmptyString('license_name');
    if (licenseRes case Error(:final failure)) {
      return Error(failure);
    }

    final attributionRes = reader.optionalNonEmptyString('attribution_text');
    if (attributionRes case Error(:final failure)) {
      return Error(failure);
    }

    final conjListRes = reader.requireObjectList('conjugations');
    if (conjListRes case Error(:final failure)) {
      return Error(failure);
    }

    final conjReaders = conjListRes.getOrNull()!;
    if (conjReaders.isEmpty) {
      return Error(
        ParsingFailure(
          'Verb "${idRes.getOrNull()!}" must contain at least one conjugation',
        ),
      );
    }

    final parsedConjugations = <ConjugatedFormDto>[];
    for (final conjReader in conjReaders) {
      final conjDtoRes = ConjugatedFormDto.fromReader(conjReader);
      switch (conjDtoRes) {
        case Success(:final data):
          parsedConjugations.add(data);
        case Error(:final failure):
          return Error(failure);
      }
    }

    return Success(
      VerbLexemeDto(
        id: idRes.getOrNull()!,
        lemmaVocalized: lemmaRes.getOrNull()!,
        infinitiveVocalized: infinitiveRes.getOrNull(),
        root: rootRes.getOrNull()!,
        binyan: binyanRes.getOrNull()!,
        russianMeaning: meaningRes.getOrNull()!,
        grammarNotesRu: notesRes.getOrNull()!,
        conjugations: parsedConjugations,
        sourceName: sourceRes.getOrNull()!,
        licenseName: licenseRes.getOrNull()!,
        attributionText: attributionRes.getOrNull(),
      ),
    );
  }

  /// Validates Hebrew fields and converts this DTO to a domain [VerbLexeme].
  Result<VerbLexeme, Failure> toDomain() {
    final lemmaRes = HebrewText.create(lemmaVocalized);
    if (lemmaRes case Error(:final failure)) {
      return Error(failure);
    }

    HebrewText? infinitiveText;
    final rawInfinitive = infinitiveVocalized;
    if (rawInfinitive != null) {
      final infRes = HebrewText.create(rawInfinitive);
      switch (infRes) {
        case Success(:final data):
          infinitiveText = data;
        case Error(:final failure):
          return Error(failure);
      }
    }

    final shoreshRes = Shoresh.create(root);
    if (shoreshRes case Error(:final failure)) {
      return Error(failure);
    }

    final binyanRes = Binyan.parseStrict(binyan);
    if (binyanRes case Error(:final failure)) {
      return Error(failure);
    }

    final domainForms = <ConjugatedForm>[];
    for (final conjDto in conjugations) {
      final formRes = conjDto.toDomain();
      switch (formRes) {
        case Success(:final data):
          domainForms.add(data);
        case Error(:final failure):
          return Error(failure);
      }
    }

    return Success(
      VerbLexeme(
        id: id,
        lemma: lemmaRes.getOrNull()!,
        infinitive: infinitiveText,
        root: shoreshRes.getOrNull()!,
        binyan: binyanRes.getOrNull()!,
        russianMeaning: russianMeaning,
        grammarNotesRu: grammarNotesRu,
        conjugations: domainForms,
        attribution: ContentAttribution(
          sourceName: sourceName,
          licenseName: licenseName,
          attributionText: attributionText,
        ),
      ),
    );
  }

  /// Serializes domain [conjugations] to JSON for local Drift storage.
  static String encodeConjugationsJson(List<ConjugatedForm> conjugations) {
    final encoded = conjugations
        .map(
          (ConjugatedForm form) => <String, String>{
            'tense': form.tense.id,
            'person': form.person.id,
            'form_vocalized': form.form.vocalized,
            'transliteration': form.transliteration,
          },
        )
        .toList(growable: false);
    return jsonEncode(encoded);
  }

  /// Decodes and validates a stored JSON conjugation array into domain forms.
  static Result<List<ConjugatedForm>, Failure> decodeConjugationsJson(
    String rawJson,
  ) {
    final readersRes = JsonReader.parseObjectList(rawJson);
    if (readersRes case Error(:final failure)) {
      return Error(failure);
    }

    final forms = <ConjugatedForm>[];
    for (final reader in readersRes.getOrNull()!) {
      final dtoRes = ConjugatedFormDto.fromReader(reader);
      if (dtoRes case Error(:final failure)) {
        return Error(failure);
      }
      final domainRes = dtoRes.getOrNull()!.toDomain();
      switch (domainRes) {
        case Success(:final data):
          forms.add(data);
        case Error(:final failure):
          return Error(failure);
      }
    }
    return Success(List<ConjugatedForm>.unmodifiable(forms));
  }

  @override
  List<Object?> get props => [
        id,
        lemmaVocalized,
        infinitiveVocalized,
        root,
        binyan,
        russianMeaning,
        grammarNotesRu,
        conjugations,
        sourceName,
        licenseName,
        attributionText,
      ];
}
