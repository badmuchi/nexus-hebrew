import 'package:flutter_test/flutter_test.dart';
import 'package:nexus_hebrew_app/features/shoresh/domain/entities/shoresh_entity.dart';

void main() {
  group('Shoresh Entities', () {
    test('ShoreshPartOfSpeech enum properties are valid', () {
      expect(ShoreshPartOfSpeech.verb.labelRu, 'Глагол');
      expect(ShoreshPartOfSpeech.verb.emoji, '🔨');

      expect(ShoreshPartOfSpeech.noun.labelRu, 'Существительное');
      expect(ShoreshPartOfSpeech.noun.emoji, '📦');

      expect(ShoreshPartOfSpeech.occupation.labelRu, 'Профессия / Деятель');
      expect(ShoreshPartOfSpeech.occupation.emoji, '👤');

      expect(ShoreshPartOfSpeech.adjective.labelRu, 'Прилагательное');
      expect(ShoreshPartOfSpeech.abstractConcept.labelRu, 'Процесс / Понятие');
      expect(ShoreshPartOfSpeech.adverb.labelRu, 'Наречие');
    });

    test('ShoreshDerivative props and equality work correctly', () {
      const d1 = ShoreshDerivative(
        id: 'd1',
        hebrewVocalized: 'מִכְתָּב',
        hebrewNormalized: 'מכתב',
        transliteration: 'mikhtav',
        russianMeaning: 'письмо',
        partOfSpeech: ShoreshPartOfSpeech.noun,
        patternOrBinyan: 'мишкаль микталь',
        exampleSentenceHebrew: 'שָׁלַחְתִּי מִכְתָּב.',
        exampleSentenceRussian: 'Я отправил письмо.',
      );

      const d2 = ShoreshDerivative(
        id: 'd1',
        hebrewVocalized: 'מִכְתָּב',
        hebrewNormalized: 'מכתב',
        transliteration: 'mikhtav',
        russianMeaning: 'письмо',
        partOfSpeech: ShoreshPartOfSpeech.noun,
        patternOrBinyan: 'мишкаль микталь',
        exampleSentenceHebrew: 'שָׁלַחְתִּי מִכְתָּב.',
        exampleSentenceRussian: 'Я отправил письмо.',
      );

      const dOther = ShoreshDerivative(
        id: 'd2',
        hebrewVocalized: 'כַּתָּב',
        hebrewNormalized: 'כתב',
        transliteration: 'katav',
        russianMeaning: 'корреспондент',
        partOfSpeech: ShoreshPartOfSpeech.occupation,
        patternOrBinyan: 'мишкаль какаль',
        exampleSentenceHebrew: 'הוּא כַּתָּב חֲדָשׁוֹת.',
        exampleSentenceRussian: 'Он новостной корреспондент.',
      );

      expect(d1, equals(d2));
      expect(d1 == dOther, isFalse);
    });

    test('ShoreshRoot props and equality work correctly', () {
      const root1 = ShoreshRoot(
        id: 'root_ktv',
        letters: ['כ', 'ת', 'ב'],
        lettersDisplay: 'כ-ת-ב',
        primaryMeaningRu: 'Письмо',
        categoryRu: 'Культура',
        culturalNoteRu: 'Базовый корень',
        derivatives: [],
      );

      const root2 = ShoreshRoot(
        id: 'root_ktv',
        letters: ['כ', 'ת', 'ב'],
        lettersDisplay: 'כ-ת-ב',
        primaryMeaningRu: 'Письмо',
        categoryRu: 'Культура',
        culturalNoteRu: 'Базовый корень',
        derivatives: [],
      );

      const rootOther = ShoreshRoot(
        id: 'root_lmd',
        letters: ['ל', 'מ', 'ד'],
        lettersDisplay: 'ל-מ-ד',
        primaryMeaningRu: 'Учёба',
        categoryRu: 'Образование',
        culturalNoteRu: 'Связан с талмудом',
        derivatives: [],
      );

      expect(root1, equals(root2));
      expect(root1 == rootOther, isFalse);
    });

    test('ShoreshQuizQuestion props and equality work correctly', () {
      const q1 = ShoreshQuizQuestion(
        id: 'q1',
        wordVocalized: 'מַדְרִיךְ',
        wordNormalized: 'מדריך',
        wordTranslation: 'инструктор',
        correctRootLetters: ['ד', 'ר', 'ך'],
        options: ['ד-ר-ך', 'ד-ר-ש', 'ר-כ-ב'],
        correctIndex: 0,
        affixesExplanationRu: 'Приставка מַ',
      );

      const q2 = ShoreshQuizQuestion(
        id: 'q1',
        wordVocalized: 'מַדְרִיךְ',
        wordNormalized: 'מדריך',
        wordTranslation: 'инструктор',
        correctRootLetters: ['ד', 'ר', 'ך'],
        options: ['ד-ר-ך', 'ד-ר-ש', 'ר-כ-ב'],
        correctIndex: 0,
        affixesExplanationRu: 'Приставка מַ',
      );

      expect(q1, equals(q2));
    });
  });
}
