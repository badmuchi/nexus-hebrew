import 'package:flutter_test/flutter_test.dart';
import 'package:nexus_hebrew_app/core/speech/pronunciation_accuracy_evaluator.dart';

void main() {
  const evaluator = PronunciationAccuracyEvaluator();

  group('PronunciationAccuracyEvaluator', () {
    test('точное совпадение с огласовками и без них даёт perfect 100%', () {
      final res = evaluator.evaluate(
        targetVocalized: 'שָׁלוֹם, מַה נִּשְׁמַע?',
        spokenRaw: 'שלום מה נשמע',
      );

      expect(res.grade, PronunciationGrade.perfect);
      expect(res.accuracyScore, greaterThanOrEqualTo(0.95));
      expect(res.xpEarned, 15);
      expect(res.hebrewFeedback, '!מוּשְׁלָם');
      expect(res.wordMatches.every((w) => w.isMatched), isTrue);
    });

    test('небольшая опечатка в одном слове даёт good результат', () {
      final res = evaluator.evaluate(
        targetVocalized: 'בֹּקֶר טוֹב לְכֻלָּם',
        spokenRaw: 'בוקר טוב לכולנו',
      );

      expect(res.grade, isIn([PronunciationGrade.good, PronunciationGrade.perfect]));
      expect(res.accuracyPercentage, greaterThanOrEqualTo(65));
      expect(res.xpEarned, greaterThanOrEqualTo(10));
    });

    test('совсем другие слова дают retry с подсказкой', () {
      final res = evaluator.evaluate(
        targetVocalized: 'אֲנִי רוֹצֶה לִשְׁתּוֹת מַיִם',
        spokenRaw: 'להתראות מחר בערב',
      );

      expect(res.grade, PronunciationGrade.retry);
      expect(res.accuracyPercentage, lessThan(60));
      expect(res.hebrewFeedback, '!נַסֵּה שׁוּב');
    });

    test('пустой ввод даёт 0% и retry', () {
      final res = evaluator.evaluate(
        targetVocalized: 'שָׁלוֹם',
        spokenRaw: '',
      );

      expect(res.grade, PronunciationGrade.retry);
      expect(res.accuracyScore, 0.0);
      expect(res.wordMatches.first.isMatched, isFalse);
    });
  });
}
