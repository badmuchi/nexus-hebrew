import 'package:flutter_test/flutter_test.dart';
import 'package:nexus_hebrew_app/core/error/failures.dart';
import 'package:nexus_hebrew_app/core/network/json_reader.dart';
import 'package:nexus_hebrew_app/core/result/result.dart';
import 'package:nexus_hebrew_app/features/listening/data/models/listening_exercise_dto.dart';
import 'package:nexus_hebrew_app/features/listening/domain/entities/listening_exercise.dart';
import 'package:nexus_hebrew_app/features/srs/data/models/srs_card_dto.dart';

void main() {
  group('ListeningExerciseDto', () {
    test('parses seed JSON and converts to domain entity + focusWords roundtrip',
        () {
      const rawJson = '''
      {
        "id": "listen_beg_1",
        "transcript_vocalized": "אֲנִי רוֹצֶה קָפֶה",
        "russian_translation": "Я хочу кофе",
        "audio_url": null,
        "difficulty": "beginner",
        "focus_words": ["רוֹצֶה", "קָפֶה"],
        "source_name": "Nexus Curated Ulpan",
        "license_name": "CC0 1.0",
        "attribution_text": "CC0 1.0"
      }
      ''';

      final reader = JsonReader.parseObject(rawJson).getOrNull()!;
      final dtoRes = ListeningExerciseDto.fromReader(reader);
      expect(dtoRes.isSuccess, isTrue);

      final domainRes = dtoRes.getOrNull()!.toDomain();
      expect(domainRes.isSuccess, isTrue);

      final exercise = domainRes.getOrNull()!;
      expect(exercise.transcript.normalized, 'אני רוצה קפה');
      expect(exercise.difficulty, ListeningDifficulty.beginner);
      expect(exercise.focusWords, <String>['רוֹצֶה', 'קָפֶה']);

      final encoded =
          ListeningExerciseDto.encodeFocusWordsJson(exercise.focusWords);
      final decoded = ListeningExerciseDto.decodeFocusWordsJson(encoded);
      expect(decoded.getOrNull(), <String>['רוֹצֶה', 'קָפֶה']);
    });

    test('adapts Tatoeba SrsCardDto into ListeningExerciseDto with difficulty tier',
        () {
      const srsDto = SrsCardDto(
        id: 'tatoeba_42',
        hebrewVocalized: 'מָחָר בַּבֹּקֶר נִכָּנֵס לַפְּגִישָׁה בְּשָׁעָה תֵּשַׁע',
        russianTranslation: 'Завтра утром мы зайдём на встречу в девять.',
        audioUrl: 'https://audio.tatoeba.org/sentences/heb/42.mp3',
        sourceName: 'Tatoeba',
        licenseName: 'CC0 1.0',
      );

      final adapted = ListeningExerciseDto.fromTatoebaSrsDto(srsDto);
      expect(adapted.id, 'listen_tatoeba_42');
      expect(adapted.difficulty, 'intermediate');
      expect(adapted.audioUrl, srsDto.audioUrl);
      expect(adapted.focusWords, isNotEmpty);
    });

    test('returns ParsingFailure when required transcript_vocalized is missing',
        () {
      const rawJson = '''
      {
        "id": "bad_1",
        "russian_translation": "Нет транскрипта",
        "source_name": "Nexus",
        "license_name": "CC0 1.0"
      }
      ''';

      final reader = JsonReader.parseObject(rawJson).getOrNull()!;
      final dtoRes = ListeningExerciseDto.fromReader(reader);
      expect(dtoRes, isA<Error<ListeningExerciseDto, ParsingFailure>>());
    });

    test('returns ParsingFailure when difficulty tier is unknown', () {
      final dto = ListeningExerciseDto(
        id: 'bad_tier',
        transcriptVocalized: 'שָׁלוֹם',
        russianTranslation: 'Привет',
        difficulty: 'expert_ultra',
        sourceName: 'Nexus',
        licenseName: 'CC0 1.0',
      );

      final domainRes = dto.toDomain();
      expect(domainRes.isError, isTrue);
      expect(domainRes.failureOrNull(), isA<ParsingFailure>());
    });
  });
}
