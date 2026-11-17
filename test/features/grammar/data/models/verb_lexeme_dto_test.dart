import 'package:flutter_test/flutter_test.dart';
import 'package:nexus_hebrew_app/core/error/failures.dart';
import 'package:nexus_hebrew_app/core/network/json_reader.dart';
import 'package:nexus_hebrew_app/core/result/result.dart';
import 'package:nexus_hebrew_app/features/conversation/domain/entities/binyan.dart';
import 'package:nexus_hebrew_app/features/grammar/data/models/verb_lexeme_dto.dart';
import 'package:nexus_hebrew_app/features/grammar/domain/entities/verb_conjugation.dart';

void main() {
  group('VerbLexemeDto', () {
    test('parses active paal verb with infinitive and conjugations', () {
      const rawJson = '''
      {
        "id": "verb_paal_katav",
        "lemma_vocalized": "כָּתַב",
        "infinitive_vocalized": "לִכְתֹּב",
        "root": "כ-ת-ב",
        "binyan": "paal",
        "russian_meaning": "писать",
        "grammar_notes_ru": "Классический глагол Пааль",
        "source_name": "Kaikki / Wiktionary",
        "license_name": "CC BY-SA 4.0",
        "attribution_text": "CC BY-SA 4.0",
        "conjugations": [
          {
            "tense": "present",
            "person": "ms",
            "form_vocalized": "כּוֹתֵב",
            "transliteration": "kotev"
          }
        ]
      }
      ''';

      final readerRes = JsonReader.parseObject(rawJson);
      expect(readerRes.isSuccess, isTrue);

      final dtoRes = VerbLexemeDto.fromReader(readerRes.getOrNull()!);
      expect(dtoRes.isSuccess, isTrue);

      final domainRes = dtoRes.getOrNull()!.toDomain();
      expect(domainRes.isSuccess, isTrue);

      final verb = domainRes.getOrNull()!;
      expect(verb.binyan, Binyan.paal);
      expect(verb.root.hyphenated, 'כ-ת-ב');
      expect(verb.infinitive?.vocalized, 'לִכְתֹּב');
      expect(verb.infinitive?.normalized, 'לכתב');
      expect(verb.conjugations, hasLength(1));
      expect(verb.conjugations.first.tense, VerbTense.present);
      expect(verb.conjugations.first.person, GrammaticalPerson.masculineSingular);
    });

    test('parses passive pual verb with null infinitive and roundtrips JSON', () {
      const rawJson = '''
      {
        "id": "verb_pual_dubar",
        "lemma_vocalized": "דֻּבַּר",
        "infinitive_vocalized": null,
        "root": "ד-ב-ר",
        "binyan": "pual",
        "russian_meaning": "обсуждаться",
        "grammar_notes_ru": "Пассив к Пиэль",
        "source_name": "Kaikki / Wiktionary",
        "license_name": "CC BY-SA 4.0",
        "conjugations": [
          {
            "tense": "past",
            "person": "3ms",
            "form_vocalized": "דֻּבַּר",
            "transliteration": "dubar"
          }
        ]
      }
      ''';

      final reader = JsonReader.parseObject(rawJson).getOrNull()!;
      final verb = VerbLexemeDto.fromReader(reader)
          .getOrNull()!
          .toDomain()
          .getOrNull()!;

      expect(verb.infinitive, isNull);
      expect(verb.binyan, Binyan.pual);

      final encoded = VerbLexemeDto.encodeConjugationsJson(verb.conjugations);
      final decoded = VerbLexemeDto.decodeConjugationsJson(encoded);
      expect(decoded.isSuccess, isTrue);
      expect(decoded.getOrNull()!, equals(verb.conjugations));
    });

    test('returns ParsingFailure when conjugations array is empty', () {
      const rawJson = '''
      {
        "id": "verb_bad",
        "lemma_vocalized": "כָּתַב",
        "root": "כ-ת-ב",
        "binyan": "paal",
        "russian_meaning": "писать",
        "grammar_notes_ru": "Примечание",
        "source_name": "Kaikki",
        "license_name": "CC BY-SA 4.0",
        "conjugations": []
      }
      ''';

      final reader = JsonReader.parseObject(rawJson).getOrNull()!;
      final dtoRes = VerbLexemeDto.fromReader(reader);
      expect(dtoRes, isA<Error<VerbLexemeDto, ParsingFailure>>());
    });

    test('returns ParsingFailure on unknown binyan during domain conversion', () {
      const rawJson = '''
      {
        "id": "verb_bad_binyan",
        "lemma_vocalized": "כָּתַב",
        "root": "כ-ת-ב",
        "binyan": "unknown_binyan",
        "russian_meaning": "писать",
        "grammar_notes_ru": "Примечание",
        "source_name": "Kaikki",
        "license_name": "CC BY-SA 4.0",
        "conjugations": [
          {
            "tense": "present",
            "person": "ms",
            "form_vocalized": "כּוֹתֵב",
            "transliteration": "kotev"
          }
        ]
      }
      ''';

      final reader = JsonReader.parseObject(rawJson).getOrNull()!;
      final dto = VerbLexemeDto.fromReader(reader).getOrNull()!;
      final domainRes = dto.toDomain();
      expect(domainRes.isError, isTrue);
      expect(domainRes.failureOrNull(), isA<ParsingFailure>());
    });
  });
}
