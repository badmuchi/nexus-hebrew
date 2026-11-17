import 'package:equatable/equatable.dart';

import '../../../conversation/domain/entities/binyan.dart';
import '../../../conversation/domain/entities/hebrew_text.dart';

final class StoryWordToken extends Equatable {
  final String wordVocalized;
  final String wordNormalized;
  final String russianTranslation;
  final String? transliteration;
  final Shoresh? root;
  final Binyan? binyan;
  final String? category;

  const StoryWordToken({
    required this.wordVocalized,
    required this.wordNormalized,
    required this.russianTranslation,
    this.transliteration,
    this.root,
    this.binyan,
    this.category,
  });

  @override
  List<Object?> get props => [
        wordVocalized,
        wordNormalized,
        russianTranslation,
        transliteration,
        root,
        binyan,
        category,
      ];
}

final class StorySentence extends Equatable {
  final String id;
  final String hebrewVocalized;
  final String hebrewNormalized;
  final String russianTranslation;
  final String? audioUrl;
  final List<StoryWordToken> tokens;

  const StorySentence({
    required this.id,
    required this.hebrewVocalized,
    required this.hebrewNormalized,
    required this.russianTranslation,
    this.audioUrl,
    required this.tokens,
  });

  @override
  List<Object?> get props => [
        id,
        hebrewVocalized,
        hebrewNormalized,
        russianTranslation,
        audioUrl,
        tokens,
      ];
}

final class StoryParagraph extends Equatable {
  final String id;
  final List<StorySentence> sentences;

  const StoryParagraph({
    required this.id,
    required this.sentences,
  });

  @override
  List<Object?> get props => [id, sentences];
}

final class Story extends Equatable {
  final String id;
  final HebrewText titleHebrew;
  final String titleRussian;
  final String level;
  final int readingTimeMinutes;
  final String coverEmoji;
  final String summaryRussian;
  final List<StoryParagraph> paragraphs;

  const Story({
    required this.id,
    required this.titleHebrew,
    required this.titleRussian,
    required this.level,
    required this.readingTimeMinutes,
    required this.coverEmoji,
    required this.summaryRussian,
    required this.paragraphs,
  });

  int get wordCount => paragraphs.fold(
        0,
        (sum, p) =>
            sum +
            p.sentences.fold(
              0,
              (sSum, s) => sSum + s.tokens.length,
            ),
      );

  @override
  List<Object?> get props => [
        id,
        titleHebrew,
        titleRussian,
        level,
        readingTimeMinutes,
        coverEmoji,
        summaryRussian,
        paragraphs,
      ];
}
