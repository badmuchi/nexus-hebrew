import 'package:flutter/foundation.dart';

/// Categories for adapted easy Hebrew news stories.
enum NewsCategory {
  hightech(
    id: 'hightech',
    titleHebrew: 'הַיְי-טֶק וּמַדָּע',
    titleRu: 'Хайтек и наука',
    iconEmoji: '🚀',
  ),
  culture(
    id: 'culture',
    titleHebrew: 'תַּרְבּוּת וְאָמָּנוּת',
    titleRu: 'Культура и искусство',
    iconEmoji: '🎨',
  ),
  weather(
    id: 'weather',
    titleHebrew: 'מֶזֶג אֲוִיר וְטֶבַע',
    titleRu: 'Погода и природа',
    iconEmoji: '🌧️',
  ),
  society(
    id: 'society',
    titleHebrew: 'חֶבְרָה וּתְחְבּוּרָה',
    titleRu: 'Общество и транспорт',
    iconEmoji: '🚆',
  );

  final String id;
  final String titleHebrew;
  final String titleRu;
  final String iconEmoji;

  const NewsCategory({
    required this.id,
    required this.titleHebrew,
    required this.titleRu,
    required this.iconEmoji,
  });
}

/// A paragraph in an adapted news article with audio segment tracking.
@immutable
class NewsParagraph {
  final int index;
  final String hebrewWithNikkud;
  final String hebrewNormalized;
  final String translationRu;
  final String? audioPath;

  const NewsParagraph({
    required this.index,
    required this.hebrewWithNikkud,
    required this.hebrewNormalized,
    required this.translationRu,
    this.audioPath,
  });
}

/// Key vocabulary item within a news article.
@immutable
class NewsWordVocabulary {
  final String hebrewWithNikkud;
  final String hebrewNormalized;
  final String translationRu;
  final String? root;

  const NewsWordVocabulary({
    required this.hebrewWithNikkud,
    required this.hebrewNormalized,
    required this.translationRu,
    this.root,
  });
}

/// An adapted news article designed for Ulpan learners (A2 - B1).
@immutable
class EasyHebrewArticle {
  final String id;
  final String titleHebrewWithNikkud;
  final String titleHebrewNormalized;
  final String titleRu;
  final NewsCategory category;
  final String readingLevelRu;
  final String dateString;
  final int readingMinutes;
  final String summaryRu;
  final List<NewsParagraph> paragraphs;
  final List<NewsWordVocabulary> vocabulary;

  const EasyHebrewArticle({
    required this.id,
    required this.titleHebrewWithNikkud,
    required this.titleHebrewNormalized,
    required this.titleRu,
    required this.category,
    required this.readingLevelRu,
    required this.dateString,
    required this.readingMinutes,
    required this.summaryRu,
    required this.paragraphs,
    required this.vocabulary,
  });
}
