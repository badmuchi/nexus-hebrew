import 'package:equatable/equatable.dart';

/// Categories of authentic Israeli life scenes.
enum SceneType {
  supermarket(
    id: 'supermarket',
    titleRu: 'Супермаркет и покупки',
    emoji: '🛒',
  ),
  transport(
    id: 'transport',
    titleRu: 'Автобус, поезд и Рав-Кав',
    emoji: '🚌',
  ),
  clinic(
    id: 'clinic',
    titleRu: 'Поликлиника и аптека',
    emoji: '🏥',
  ),
  cafe(
    id: 'cafe',
    titleRu: 'Кафе и ресторан',
    emoji: '☕',
  ),
  rental(
    id: 'rental',
    titleRu: 'Аренда жилья и коммуналка',
    emoji: '🔑',
  ),
  bureaucracy(
    id: 'bureaucracy',
    titleRu: 'МВД и почта',
    emoji: '📮',
  );

  const SceneType({
    required this.id,
    required this.titleRu,
    required this.emoji,
  });

  final String id;
  final String titleRu;
  final String emoji;
}

/// A specific vocabulary item / object encountered in a scene.
final class SceneWord extends Equatable {
  const SceneWord({
    required this.id,
    required this.hebrewVocalized,
    required this.hebrewNormalized,
    required this.transliteration,
    required this.russianMeaning,
    this.contextNote,
    this.root,
    this.audioPath,
  });

  final String id;
  final String hebrewVocalized;
  final String hebrewNormalized;
  final String transliteration;
  final String russianMeaning;
  final String? contextNote;
  final String? root;
  final String? audioPath;

  @override
  List<Object?> get props => [
        id,
        hebrewVocalized,
        hebrewNormalized,
        transliteration,
        russianMeaning,
        contextNote,
        root,
        audioPath,
      ];
}

/// Direction of spoken communication in real life.
enum PhraseRole {
  theySay(labelRu: 'Вам скажут 👂', isIncoming: true),
  youSay(labelRu: 'Вы ответите 🗣️', isIncoming: false);

  const PhraseRole({required this.labelRu, required this.isIncoming});
  final String labelRu;
  final bool isIncoming;
}

/// A situational dialogue phrase used in a real Israeli scenario.
final class ScenePhrase extends Equatable {
  const ScenePhrase({
    required this.id,
    required this.role,
    required this.hebrewVocalized,
    required this.hebrewNormalized,
    required this.transliteration,
    required this.russianTranslation,
    this.culturalTip,
    this.audioPath,
  });

  final String id;
  final PhraseRole role;
  final String hebrewVocalized;
  final String hebrewNormalized;
  final String transliteration;
  final String russianTranslation;
  final String? culturalTip;
  final String? audioPath;

  @override
  List<Object?> get props => [
        id,
        role,
        hebrewVocalized,
        hebrewNormalized,
        transliteration,
        russianTranslation,
        culturalTip,
        audioPath,
      ];
}

/// An interactive mini-challenge / roleplay decision question.
final class SceneChallenge extends Equatable {
  const SceneChallenge({
    required this.id,
    required this.situationRu,
    this.promptHebrew,
    required this.options,
    required this.correctIndex,
    required this.explanationRu,
    this.keyWord,
  });

  final String id;
  final String situationRu;
  final String? promptHebrew;
  final List<String> options;
  final int correctIndex;
  final String explanationRu;
  final String? keyWord;

  @override
  List<Object?> get props => [
        id,
        situationRu,
        promptHebrew,
        options,
        correctIndex,
        explanationRu,
        keyWord,
      ];
}

/// Complete interactive Israeli life scene model.
final class IsraeliLifeScene extends Equatable {
  const IsraeliLifeScene({
    required this.id,
    required this.type,
    required this.titleHebrew,
    required this.titleRussian,
    required this.description,
    required this.emoji,
    required this.cefrLevel,
    required this.cultureLifehack,
    required this.words,
    required this.phrases,
    required this.challenges,
  });

  final String id;
  final SceneType type;
  final String titleHebrew;
  final String titleRussian;
  final String description;
  final String emoji;
  final String cefrLevel;
  final String cultureLifehack;
  final List<SceneWord> words;
  final List<ScenePhrase> phrases;
  final List<SceneChallenge> challenges;

  @override
  List<Object?> get props => [
        id,
        type,
        titleHebrew,
        titleRussian,
        description,
        emoji,
        cefrLevel,
        cultureLifehack,
        words,
        phrases,
        challenges,
      ];
}
