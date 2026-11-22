import 'package:flutter_test/flutter_test.dart';
import 'package:nexus_hebrew_app/features/conversation/domain/entities/binyan.dart';
import 'package:nexus_hebrew_app/features/srs/domain/services/deck_import_service.dart';

void main() {
  const service = DeckImportService();

  group('DeckImportService', () {
    test('returns empty result for empty string', () {
      final res = service.parse('   ');
      expect(res.totalValid, equals(0));
      expect(res.totalSkipped, equals(0));
    });

    test('parses Anki TSV format with headers and sound tag', () {
      const input = '''
#separator:tab
#html:true
#tags column:7
Front\tBack\tTransliteration\tRoot\tBinyanOrCategory\tAudio\tTags
שָׁלוֹם\tПривет; Мир\tshalom\tש-ל-ם\tpaal\t[sound:shalom.mp3]\thebrew greeting
סְלִיחָה\tИзвините\tslicha\tס-ל-ח\tpaal\t\tpolite
''';

      final res = service.parse(input);
      expect(res.formatDetected, equals('Anki TSV'));
      expect(res.totalValid, equals(2));
      expect(res.totalSkipped, equals(0));

      final card1 = res.validCards[0];
      expect(card1.hebrewVocalized, equals('שָׁלוֹם'));
      expect(card1.hebrewNormalized, equals('שלום'));
      expect(card1.russianTranslation, equals('Привет; Мир'));
      expect(card1.transliteration, equals('shalom'));
      expect(card1.root?.compact, equals('שלם'));
      expect(card1.binyan, equals(Binyan.paal));
      expect(card1.audioUrl, equals('shalom.mp3'));
      expect(card1.tags, containsAll(['hebrew', 'greeting']));

      final card2 = res.validCards[1];
      expect(card2.hebrewVocalized, equals('סְלִיחָה'));
      expect(card2.russianTranslation, equals('Извините'));
    });

    test('parses JSON format with various field names', () {
      const input = '''
[
  {
    "hebrew": "בּוֹקֶר טוֹב",
    "russianTranslation": "Доброе утро",
    "transliteration": "boker tov",
    "tags": ["morning", "routine"]
  },
  {
    "front": "עֶרֶב טוֹב",
    "back": "Добрый вечер"
  }
]
''';

      final res = service.parse(input);
      expect(res.formatDetected, equals('JSON'));
      expect(res.totalValid, equals(2));

      expect(res.validCards[0].hebrewVocalized, equals('בּוֹקֶר טוֹב'));
      expect(res.validCards[0].russianTranslation, equals('Доброе утро'));
      expect(res.validCards[0].tags, containsAll(['morning', 'routine']));

      expect(res.validCards[1].hebrewVocalized, equals('עֶרֶב טוֹב'));
      expect(res.validCards[1].russianTranslation, equals('Добрый вечер'));
    });

    test('parses CSV format with quotes and commas in translation', () {
      const input = '''
Front,Back,Transliteration,Root
"שָׂפָה","Язык, речь","safa",
"סֵפֶר","Книга","sefer","ס-פ-ר"
''';

      final res = service.parse(input);
      expect(res.formatDetected, equals('CSV'));
      expect(res.totalValid, equals(2));

      expect(res.validCards[0].hebrewVocalized, equals('שָׂפָה'));
      expect(res.validCards[0].russianTranslation, equals('Язык, речь'));

      expect(res.validCards[1].hebrewVocalized, equals('סֵפֶר'));
      expect(res.validCards[1].root?.compact, equals('ספר'));
    });

    test('parses plain text delimited lines', () {
      const input = '''
תּוֹדָה רַבָּה - Большое спасибо
בְּבַקָּשָׁה — Пожалуйста
לְהִתְרָאוֹת : До свидания
''';

      final res = service.parse(input);
      expect(res.totalValid, equals(3));
      expect(res.validCards[0].hebrewVocalized, equals('תּוֹדָה רַבָּה'));
      expect(res.validCards[0].russianTranslation, equals('Большое спасибо'));
      expect(res.validCards[1].hebrewVocalized, equals('בְּבַקָּשָׁה'));
      expect(res.validCards[1].russianTranslation, equals('Пожалуйста'));
      expect(res.validCards[2].hebrewVocalized, equals('לְהִתְרָאוֹת'));
      expect(res.validCards[2].russianTranslation, equals('До свидания'));
    });

    test('automatically reverses columns if Russian is in first column and Hebrew in second', () {
      const input = '''
Спасибо\tתּוֹדָה
Пожалуйста\tבְּבַקָּשָׁה
''';

      final res = service.parse(input);
      expect(res.totalValid, equals(2));
      expect(res.validCards[0].hebrewVocalized, equals('תּוֹדָה'));
      expect(res.validCards[0].russianTranslation, equals('Спасибо'));
      expect(res.validCards[1].hebrewVocalized, equals('בְּבַקָּשָׁה'));
      expect(res.validCards[1].russianTranslation, equals('Пожалуйста'));
    });

    test('skips lines with no Hebrew letters without failing', () {
      const input = '''
English word\tРусский перевод
שָׁלוֹם\tПривет
12345\t67890
''';

      final res = service.parse(input);
      expect(res.totalValid, equals(1));
      expect(res.totalSkipped, equals(2));
      expect(res.validCards[0].hebrewVocalized, equals('שָׁלוֹם'));
    });
  });
}
