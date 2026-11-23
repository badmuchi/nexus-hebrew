import 'package:equatable/equatable.dart';

/// Season of the Jewish and Israeli calendar year.
enum HolidaySeason {
  autumn(
    id: 'autumn',
    titleRu: 'Осенние праздники (חגי תשרי)',
    emoji: '🍂',
  ),
  winter(
    id: 'winter',
    titleRu: 'Зимние праздники',
    emoji: '🕎',
  ),
  spring(
    id: 'spring',
    titleRu: 'Весенние праздники и Песах',
    emoji: '🌸',
  ),
  nationalDays(
    id: 'national',
    titleRu: 'Государственные дни Израиля',
    emoji: '🇮🇱',
  );

  final String id;
  final String titleRu;
  final String emoji;

  const HolidaySeason({
    required this.id,
    required this.titleRu,
    required this.emoji,
  });
}

/// A Jewish or Israeli national holiday with customs, greetings, and modern lifestyle impact.
final class JewishHoliday extends Equatable {
  final String id;
  final HolidaySeason season;
  final String hebrewNameWithNikkud;
  final String hebrewNamePlain;
  final String transcriptionRu;
  final String russianTitle;
  final String monthHebrew;
  final String greetingHebrewWithNikkud;
  final String greetingTranscriptionRu;
  final String greetingRussian;
  final String customsAndFoodRu;
  final String modernIsraeliRealityRu;
  final String iconEmoji;

  const JewishHoliday({
    required this.id,
    required this.season,
    required this.hebrewNameWithNikkud,
    required this.hebrewNamePlain,
    required this.transcriptionRu,
    required this.russianTitle,
    required this.monthHebrew,
    required this.greetingHebrewWithNikkud,
    required this.greetingTranscriptionRu,
    required this.greetingRussian,
    required this.customsAndFoodRu,
    required this.modernIsraeliRealityRu,
    required this.iconEmoji,
  });

  @override
  List<Object?> get props => [
        id,
        season,
        hebrewNameWithNikkud,
        hebrewNamePlain,
        transcriptionRu,
        russianTitle,
        monthHebrew,
        greetingHebrewWithNikkud,
        greetingTranscriptionRu,
        greetingRussian,
        customsAndFoodRu,
        modernIsraeliRealityRu,
        iconEmoji,
      ];
}
