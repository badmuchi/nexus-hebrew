import 'package:flutter_test/flutter_test.dart';
import 'package:nexus_hebrew_app/core/error/failures.dart';
import 'package:nexus_hebrew_app/core/network/json_reader.dart';
import 'package:nexus_hebrew_app/core/result/result.dart';
import 'package:nexus_hebrew_app/features/conversation/domain/entities/binyan.dart';
import 'package:nexus_hebrew_app/features/dictionary/data/datasources/dictionary_remote_datasource.dart';
import 'package:nexus_hebrew_app/features/dictionary/data/models/dictionary_entry_dto.dart';
import 'package:nexus_hebrew_app/features/dictionary/domain/entities/dictionary_entry.dart';
import 'package:nexus_hebrew_app/features/srs/domain/entities/srs_card.dart';

void main() {
  final fixedNow = DateTime.utc(2026, 11, 12);

  group('DictionaryEntryDto & TatoebaDictionaryParser', () {
    test('маппит валидный JSON-объект DictionaryEntryDto в Domain DictionaryEntry', () {
      const payload = '''
      {
        "id": "dict_ledaber",
        "hebrew_vocalized": "לְדַבֵּר",
        "russian_translation": "говорить, разговаривать",
        "transliteration": "ledaber",
        "category": "verb",
        "root": "ד-ב-ר",
        "binyan": "piel",
        "forms_summary": "מְדַבֵּר · דִּבֵּר · יְדַבֵּר",
        "example_hebrew": "אֲנִי מְדַבֵּר עִבְרִית.",
        "example_russian": "Я говорю на иврите.",
        "audio_url": "assets/audio/dictionary/dict_ledaber.mp3",
        "frequency_rank": 18,
        "source_name": "Kaikki / Open Frequency",
        "license_name": "CC BY-SA 4.0",
        "attribution_text": "Open Hebrew Pack"
      }
      ''';

      final reader = JsonReader.parseObject(payload).getOrNull()!;
      final dtoRes = DictionaryEntryDto.fromReader(reader);
      expect(dtoRes, isA<Success<DictionaryEntryDto, ParsingFailure>>());

      final domainRes = dtoRes.getOrNull()!.toDomain(createdAt: fixedNow);
      expect(domainRes, isA<Success<DictionaryEntry, Failure>>());

      final entry = domainRes.getOrNull()!;
      expect(entry.hebrew.normalized, equals('לדבר'));
      expect(entry.root?.hyphenated, equals('ד-ב-ר'));
      expect(entry.binyan, equals(Binyan.piel));
      expect(entry.category, equals(LexicalCategory.verb));
      expect(entry.frequencyRank, equals(18));
      expect(entry.audioUrl, equals('assets/audio/dictionary/dict_ledaber.mp3'));
    });

    test('отклоняет невалидный category и некорректный frequency_rank', () {
      const badJson = '''
      {
        "id": "dict_bad",
        "hebrew_vocalized": "שָׁלוֹם",
        "russian_translation": "мир",
        "frequency_rank": "top10",
        "source_name": "Kaikki",
        "license_name": "CC BY-SA 4.0"
      }
      ''';
      final reader = JsonReader.parseObject(badJson).getOrNull()!;
      expect(
        DictionaryEntryDto.fromReader(reader),
        isA<Error<DictionaryEntryDto, ParsingFailure>>(),
      );
    });

    test('TatoebaDictionaryParser парсит heb->rus (с фильтрацией NC-аудио) и rus->heb', () {
      const hebToRusJson = '''
      {
        "data": [
          {
            "id": 9001,
            "text": "תּוֹדָה רַבָּה.",
            "textLicence": "CC BY 2.0 FR",
            "translations": [
              {"lang": "eng", "text": "Thank you very much."},
              {"lang": "rus", "text": "Большое спасибо."}
            ],
            "audios": [
              {"license": "CC BY-NC 4.0", "author": "nc_user", "url": "https://example.com/nc.mp3"},
              {"license": "CC0 1.0", "author": "ok_user", "url": "https://example.com/ok.mp3"}
            ]
          }
        ]
      }
      ''';

      final hebReader = JsonReader.parseObject(hebToRusJson).getOrNull()!;
      final hebDtos = TatoebaDictionaryParser.parseBidirectionalResponse(
        rootReader: hebReader,
        sourceLang: 'heb',
      ).getOrNull()!;

      expect(hebDtos.length, equals(1));
      expect(hebDtos.single.hebrewVocalized, equals('תּוֹדָה רַבָּה.'));
      expect(hebDtos.single.russianTranslation, equals('Большое спасибо.'));
      expect(hebDtos.single.audioUrl, equals('https://example.com/ok.mp3'));
      expect(hebDtos.single.attributionText, contains('Audio by ok_user'));

      const rusToHebJson = '''
      {
        "results": [
          {
            "id": 9002,
            "text": "Доброе утро!",
            "license": "CC BY 2.0 FR",
            "translations": [
              [
                {"lang": "heb", "text": "בֹּקֶר טוֹב!"}
              ]
            ]
          }
        ]
      }
      ''';

      final rusReader = JsonReader.parseObject(rusToHebJson).getOrNull()!;
      final rusDtos = TatoebaDictionaryParser.parseBidirectionalResponse(
        rootReader: rusReader,
        sourceLang: 'rus',
      ).getOrNull()!;

      expect(rusDtos.length, equals(1));
      expect(rusDtos.single.id, equals('tatoeba_dict_9002'));
      expect(rusDtos.single.hebrewVocalized, equals('בֹּקֶר טוֹב!'));
      expect(rusDtos.single.russianTranslation, equals('Доброе утро!'));
      expect(rusDtos.single.audioUrl, isNull);
    });
  });
}
