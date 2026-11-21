import 'package:equatable/equatable.dart';

/// Morphological part of speech in Hebrew root word derivation.
enum ShoreshPartOfSpeech {
  verb(labelRu: 'Глагол', emoji: '🔨'),
  noun(labelRu: 'Существительное', emoji: '📦'),
  occupation(labelRu: 'Профессия / Деятель', emoji: '👤'),
  adjective(labelRu: 'Прилагательное', emoji: '🌟'),
  abstractConcept(labelRu: 'Процесс / Понятие', emoji: '📜'),
  adverb(labelRu: 'Наречие', emoji: '⚡');

  const ShoreshPartOfSpeech({
    required this.labelRu,
    required this.emoji,
  });

  final String labelRu;
  final String emoji;
}

/// A specific vocabulary word derived from a three-letter root.
final class ShoreshDerivative extends Equatable {
  const ShoreshDerivative({
    required this.id,
    required this.hebrewVocalized,
    required this.hebrewNormalized,
    required this.transliteration,
    required this.russianMeaning,
    required this.partOfSpeech,
    required this.patternOrBinyan,
    required this.exampleSentenceHebrew,
    required this.exampleSentenceRussian,
    this.audioPath,
  });

  final String id;
  final String hebrewVocalized;
  final String hebrewNormalized;
  final String transliteration;
  final String russianMeaning;
  final ShoreshPartOfSpeech partOfSpeech;
  final String patternOrBinyan;
  final String exampleSentenceHebrew;
  final String exampleSentenceRussian;
  final String? audioPath;

  @override
  List<Object?> get props => [
        id,
        hebrewVocalized,
        hebrewNormalized,
        transliteration,
        russianMeaning,
        partOfSpeech,
        patternOrBinyan,
        exampleSentenceHebrew,
        exampleSentenceRussian,
        audioPath,
      ];
}

/// A Hebrew root (Shoresh) and its morphological family of derived words.
final class ShoreshRoot extends Equatable {
  const ShoreshRoot({
    required this.id,
    required this.letters,
    required this.lettersDisplay,
    required this.primaryMeaningRu,
    required this.categoryRu,
    required this.culturalNoteRu,
    required this.derivatives,
  });

  final String id;
  final List<String> letters;
  final String lettersDisplay;
  final String primaryMeaningRu;
  final String categoryRu;
  final String culturalNoteRu;
  final List<ShoreshDerivative> derivatives;

  @override
  List<Object?> get props => [
        id,
        letters,
        lettersDisplay,
        primaryMeaningRu,
        categoryRu,
        culturalNoteRu,
        derivatives,
      ];
}

/// An interactive quiz challenge for the Root Detective simulator.
final class ShoreshQuizQuestion extends Equatable {
  const ShoreshQuizQuestion({
    required this.id,
    required this.wordVocalized,
    required this.wordNormalized,
    required this.wordTranslation,
    required this.correctRootLetters,
    required this.options,
    required this.correctIndex,
    required this.affixesExplanationRu,
  });

  final String id;
  final String wordVocalized;
  final String wordNormalized;
  final String wordTranslation;
  final List<String> correctRootLetters;
  final List<String> options;
  final int correctIndex;
  final String affixesExplanationRu;

  @override
  List<Object?> get props => [
        id,
        wordVocalized,
        wordNormalized,
        wordTranslation,
        correctRootLetters,
        options,
        correctIndex,
        affixesExplanationRu,
      ];
}
