import 'package:flutter_test/flutter_test.dart';
import 'package:nexus_hebrew_app/core/error/failures.dart';
import 'package:nexus_hebrew_app/core/network/json_reader.dart';
import 'package:nexus_hebrew_app/core/result/result.dart';
import 'package:nexus_hebrew_app/features/conversation/domain/entities/binyan.dart';
import 'package:nexus_hebrew_app/features/srs/data/models/srs_card_dto.dart';
import 'package:nexus_hebrew_app/features/srs/domain/entities/fsrs_models.dart';
import 'package:nexus_hebrew_app/features/srs/domain/entities/srs_card.dart';

void main() {
  final now = DateTime.utc(2026, 11, 11);

  group('SrsCardDto & TatoebaResponseParser', () {
    test('маппит валидный SrsCardDto с корнем и биньяном в Domain SrsCard', () {
      const jsonPayload = '''
      {
        "id": "srs_ledaber",
        "hebrew_vocalized": "לְדַבֵּר",
        "russian_translation": "Говорить",
        "root": "ד-ב-ר",
        "binyan": "piel",
        "category": "verb",
        "example_hebrew": "אֲנִי מְדַבֵּר עִבְרִית.",
        "example_russian": "Я говорю на иврите.",
        "audio_url": null,
        "source_name": "Wiktionary / Kaikki Hebrew",
        "license_name": "CC BY-SA 4.0"
      }
      ''';

      final reader = JsonReader.parseObject(jsonPayload).getOrNull()!;
      final dto = SrsCardDto.fromReader(reader).getOrNull()!;
      final cardRes = dto.toDomain(memory: FsrsMemoryState.initial(now: now));

      expect(cardRes, isA<Success<SrsCard, Failure>>());
      final card = cardRes.getOrNull()!;
      expect(card.hebrew.normalized, equals('לדבר'));
      expect(card.root?.hyphenated, equals('ד-ב-ר'));
      expect(card.binyan, equals(Binyan.piel));
      expect(card.category, equals(LexicalCategory.verb));
    });

    test('TatoebaResponseParser отбрасывает NC-аудио и берёт только CC0/CC-BY', () {
      const tatoebaPayload = '''
      {
        "data": [
          {
            "id": 4455,
            "text": "אֲנִי אוֹהֵב קָפֶה.",
            "textLicence": "CC BY 2.0 FR",
            "audios": [
              {
                "id": 1,
                "author": "user_nc",
                "license": "CC BY-NC 4.0",
                "url": "https://audio.tatoeba.org/sentences/heb/4455_nc.mp3"
              },
              {
                "id": 2,
                "author": "native_heb",
                "license": "CC BY 4.0",
                "url": "https://audio.tatoeba.org/sentences/heb/4455.mp3"
              }
            ],
            "translations": [
              [{"id": 999, "lang": "rus", "text": "Я люблю кофе."}]
            ]
          },
          {
            "id": 4456,
            "text": "שָׁלוֹם",
            "translations": [
              [{"id": 1000, "lang": "eng", "text": "Hello"}]
            ]
          }
        ]
      }
      ''';

      final reader = JsonReader.parseObject(tatoebaPayload).getOrNull()!;
      final parsedRes = TatoebaResponseParser.parseSearchResponse(reader);

      expect(parsedRes, isA<Success<List<SrsCardDto>, ParsingFailure>>());
      final cards = parsedRes.getOrNull()!;
      expect(cards.length, equals(1));
      expect(cards.first.id, equals('tatoeba_4455'));
      expect(cards.first.russianTranslation, equals('Я люблю кофе.'));
      expect(
        cards.first.audioUrl,
        equals('https://audio.tatoeba.org/sentences/heb/4455.mp3'),
      );
      expect(cards.first.licenseName, equals('CC BY 4.0'));
    });

    test('отбрасывает аудио с No license и оставляет audioUrl == null', () {
      expect(TatoebaResponseParser.isPermissiveAudioLicense('CC0 1.0'), isTrue);
      expect(TatoebaResponseParser.isPermissiveAudioLicense('CC-BY 4.0'), isTrue);
      expect(TatoebaResponseParser.isPermissiveAudioLicense('CC BY-NC-SA 4.0'), isFalse);
      expect(TatoebaResponseParser.isPermissiveAudioLicense('No license'), isFalse);
    });
  });
}
