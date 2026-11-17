import 'package:flutter_test/flutter_test.dart';
import 'package:nexus_hebrew_app/core/audio/tts_text_sanitizer.dart';

void main() {
  group('TtsTextSanitizer', () {
    test('сохраняет стандартные огласовки и убирает кантилляцию и макаф', () {
      const raw = 'שָׁלוֹם\u0591, אֶפְשָׁר\u05BEלְדַבֵּר (לְאַט) / בְּקֹול רָם — כֵּן!';
      final cleaned = TtsTextSanitizer.sanitizeForHebrewTts(raw);

      expect(cleaned, equals('שָׁלוֹם, אֶפְשָׁר לְדַבֵּר לְאַט , בְּקֹול רָם , כֵּן!'));
    });

    test('схлопывает лишние пробелы и обрезает края', () {
      const raw = '   [בְּבַקָּשָׁה]   קָפֶה   ';
      expect(
        TtsTextSanitizer.sanitizeForHebrewTts(raw),
        equals('בְּבַקָּשָׁה קָפֶה'),
      );
    });

    test('удаляет meteg, rafe, средние точки и невидимые bidi-маркеры', () {
      const raw = '\u200Fכֹּותֵ\u05BDב\u05BF · מִכְתָּב\u05C3';
      expect(
        TtsTextSanitizer.sanitizeForHebrewTts(raw),
        equals('כֹּותֵב , מִכְתָּב'),
      );
    });
  });
}
