import 'package:equatable/equatable.dart';

/// Direction of prompt/response in audio drill.
enum AudioDrillDirection {
  /// Prompt in Hebrew -> Pause -> Russian translation.
  hebrewToRussian(
    id: 'he_to_ru',
    labelRu: 'Иврит ➔ Русский',
    description: 'Понимание беглой речи на слух',
    icon: '👂',
  ),

  /// Prompt in Russian -> Pause -> Hebrew response.
  russianToHebrew(
    id: 'ru_to_he',
    labelRu: 'Русский ➔ Иврит',
    description: 'Вспоминание и произношение вслух',
    icon: '🗣️',
  );

  const AudioDrillDirection({
    required this.id,
    required this.labelRu,
    required this.description,
    required this.icon,
  });

  final String id;
  final String labelRu;
  final String description;
  final String icon;
}

/// Filter determining which cards to include in the drill.
enum AudioDrillFilter {
  /// Only cards with stability < 3.0 days or lapses > 0.
  weakWordsOnly(
    id: 'weak',
    labelRu: 'Трудные слова FSRS',
    description: 'Слова со стабильностью < 3 дн. и срывами',
    icon: '🎯',
  ),

  /// Cards scheduled for review today.
  dueTodayOnly(
    id: 'due',
    labelRu: 'К повторению сегодня',
    description: 'Карточки, срок повторения которых настал',
    icon: '⏰',
  ),

  /// All cards in the user deck.
  allDeck(
    id: 'all',
    labelRu: 'Вся колода FSRS',
    description: 'Все сохраненные слова из памяти',
    icon: '📚',
  );

  const AudioDrillFilter({
    required this.id,
    required this.labelRu,
    required this.description,
    required this.icon,
  });

  final String id;
  final String labelRu;
  final String description;
  final String icon;
}

/// Phase within a single card audio drill cycle.
enum AudioDrillPhase {
  /// Playing prompt side (audio or text)
  prompt,

  /// Thinking pause countdown for saying answer aloud
  thinking,

  /// Playing correct answer side
  answer,

  /// Contextual example audio/text (optional)
  example,

  /// Brief buffer before advancing to next card
  transition,
}

/// Configuration settings for an audio drill session.
final class AudioDrillConfig extends Equatable {
  final AudioDrillDirection direction;
  final AudioDrillFilter filter;
  final double pauseSeconds;
  final bool includeExamples;
  final int repeatCount;
  final bool isLooping;

  const AudioDrillConfig({
    this.direction = AudioDrillDirection.hebrewToRussian,
    this.filter = AudioDrillFilter.weakWordsOnly,
    this.pauseSeconds = 3.0,
    this.includeExamples = false,
    this.repeatCount = 1,
    this.isLooping = true,
  });

  AudioDrillConfig copyWith({
    AudioDrillDirection? direction,
    AudioDrillFilter? filter,
    double? pauseSeconds,
    bool? includeExamples,
    int? repeatCount,
    bool? isLooping,
  }) {
    return AudioDrillConfig(
      direction: direction ?? this.direction,
      filter: filter ?? this.filter,
      pauseSeconds: pauseSeconds ?? this.pauseSeconds,
      includeExamples: includeExamples ?? this.includeExamples,
      repeatCount: repeatCount ?? this.repeatCount,
      isLooping: isLooping ?? this.isLooping,
    );
  }

  @override
  List<Object?> get props => [
        direction,
        filter,
        pauseSeconds,
        includeExamples,
        repeatCount,
        isLooping,
      ];
}
