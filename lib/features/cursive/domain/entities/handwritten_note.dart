import 'package:equatable/equatable.dart';

/// Categories of real-world everyday handwritten notes in Israel.
enum HandwrittenNoteCategory {
  buildingAndNeighbors(
    id: 'building',
    titleRu: 'Подъезд и Ваад Байт',
    emoji: '🏢',
    description: 'Объявления управдома, ремонт, отключение воды, лифт',
  ),
  shoppingAndKitchen(
    id: 'shopping',
    titleRu: 'Списки покупок и кухня',
    emoji: '🛒',
    description: 'Списки продуктов на рынок и записки на офисной кухне',
  ),
  healthAndClinic(
    id: 'health',
    titleRu: 'Врач и Поликлиника',
    emoji: '🩺',
    description: 'Рецепты, направления на анализы в Клалит и Маккаби',
  ),
  parkingAndStreet(
    id: 'parking',
    titleRu: 'Парковка и Улица',
    emoji: '🚗',
    description: 'Записки под дворниками, таблички на дверях магазинов',
  ),
  postcardAndWishes(
    id: 'wishes',
    titleRu: 'Открытки и Праздники',
    emoji: '🎉',
    description: 'Поздравления от руки на свадьбу, день рождения и Шаббат',
  );

  final String id;
  final String titleRu;
  final String emoji;
  final String description;

  const HandwrittenNoteCategory({
    required this.id,
    required this.titleRu,
    required this.emoji,
    required this.description,
  });
}

/// Comprehension question checking if the learner deciphered the note correctly.
final class NoteQuizQuestion extends Equatable {
  final String questionRu;
  final List<String> options;
  final int correctAnswerIndex;
  final String explanationRu;

  const NoteQuizQuestion({
    required this.questionRu,
    required this.options,
    required this.correctAnswerIndex,
    required this.explanationRu,
  });

  String get correctAnswer => options[correctAnswerIndex];

  @override
  List<Object?> get props => [questionRu, options, correctAnswerIndex, explanationRu];
}

/// An authentic handwritten note found in everyday Israeli life.
final class HandwrittenNote extends Equatable {
  final String id;
  final HandwrittenNoteCategory category;
  final String situationTitleRu;
  final String contextDescriptionRu;
  final String rawHebrew;
  final String hebrewWithNikkud;
  final String transcriptionRu;
  final String translationRu;
  final String trickyLettersTipRu;
  final List<String> keyVocabulary;
  final NoteQuizQuestion quiz;
  final String? audioPath;

  const HandwrittenNote({
    required this.id,
    required this.category,
    required this.situationTitleRu,
    required this.contextDescriptionRu,
    required this.rawHebrew,
    required this.hebrewWithNikkud,
    required this.transcriptionRu,
    required this.translationRu,
    required this.trickyLettersTipRu,
    required this.keyVocabulary,
    required this.quiz,
    this.audioPath,
  });

  @override
  List<Object?> get props => [
        id,
        category,
        situationTitleRu,
        contextDescriptionRu,
        rawHebrew,
        hebrewWithNikkud,
        transcriptionRu,
        translationRu,
        trickyLettersTipRu,
        keyVocabulary,
        quiz,
        audioPath,
      ];
}
