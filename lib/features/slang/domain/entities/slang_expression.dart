import 'package:equatable/equatable.dart';

import '../../../conversation/domain/entities/hebrew_text.dart';

enum SlangCategory {
  all(id: 'all', titleRu: 'Все выражения'),
  street(id: 'street', titleRu: 'Улица и общение'),
  emotions(id: 'emotions', titleRu: 'Эмоции и реакция'),
  cafe(id: 'cafe', titleRu: 'Кафе и этикет');

  const SlangCategory({required this.id, required this.titleRu});

  final String id;
  final String titleRu;

  static SlangCategory fromId(String id) {
    for (final cat in SlangCategory.values) {
      if (cat.id == id) return cat;
    }
    return SlangCategory.street;
  }
}

/// An authentic Israeli street Hebrew expression with cultural context and usage examples.
final class SlangExpression extends Equatable {
  const SlangExpression({
    required this.id,
    required this.hebrew,
    required this.transliteration,
    required this.translationRu,
    required this.literalTranslationRu,
    required this.culturalNoteRu,
    required this.category,
    required this.exampleHebrew,
    required this.exampleTranslationRu,
    this.audioUrl,
  });

  final String id;
  final HebrewText hebrew;
  final String transliteration;
  final String translationRu;
  final String literalTranslationRu;
  final String culturalNoteRu;
  final SlangCategory category;
  final String exampleHebrew;
  final String exampleTranslationRu;
  final String? audioUrl;

  @override
  List<Object?> get props => [
        id,
        hebrew,
        transliteration,
        translationRu,
        literalTranslationRu,
        culturalNoteRu,
        category,
        exampleHebrew,
        exampleTranslationRu,
        audioUrl,
      ];
}
