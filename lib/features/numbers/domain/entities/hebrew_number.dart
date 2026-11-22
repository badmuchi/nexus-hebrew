import 'package:equatable/equatable.dart';

/// Gender agreement of numbers in Hebrew.
///
/// CRITICAL GRAMMAR RULE: In Hebrew, cardinal numbers 1-10 have INVERTED endings!
/// Masculine numbers have the traditional feminine suffix ־ָה (e.g. שְׁלוֹשָׁה),
/// while feminine numbers have NO ending (e.g. שָׁלוֹשׁ).
enum HebrewNumberGender {
  masculine(labelRu: 'Мужской род', suffixNote: 'Окончание ־ָה (перевёртыш!)'),
  feminine(labelRu: 'Женский род', suffixNote: 'Без окончания');

  final String labelRu;
  final String suffixNote;

  const HebrewNumberGender({
    required this.labelRu,
    required this.suffixNote,
  });
}

/// Category of numbers and numerical phrases.
enum HebrewNumberCategory {
  cardinal1to10(titleRu: 'Числа 1-10 (Коварный род)'),
  cardinal11to100(titleRu: 'Числа 11-100'),
  shekels(titleRu: 'Цены и Шекели (שְׁקָלִים)'),
  clockTime(titleRu: 'Время на часах (שָׁעוֹת)'),
  cashierPhrases(titleRu: 'Фразы на кассе');

  final String titleRu;
  const HebrewNumberCategory({required this.titleRu});
}

/// An individual Hebrew number or money phrase entry.
final class HebrewNumberEntry extends Equatable {
  final int numberValue;
  final String hebrewWithNikkud;
  final String hebrewWithoutNikkud;
  final String transcriptionRu;
  final String translationRu;
  final HebrewNumberGender gender;
  final HebrewNumberCategory category;
  final String? ruleExplanationRu;
  final String? audioPath;

  const HebrewNumberEntry({
    required this.numberValue,
    required this.hebrewWithNikkud,
    required this.hebrewWithoutNikkud,
    required this.transcriptionRu,
    required this.translationRu,
    required this.gender,
    required this.category,
    this.ruleExplanationRu,
    this.audioPath,
  });

  @override
  List<Object?> get props => [
        numberValue,
        hebrewWithNikkud,
        hebrewWithoutNikkud,
        transcriptionRu,
        translationRu,
        gender,
        category,
        ruleExplanationRu,
        audioPath,
      ];
}
