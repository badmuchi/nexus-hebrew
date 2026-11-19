import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

import '../../../../core/utils/hebrew_normalizer.dart';

/// Semantic category of speech exercises for situational Hebrew drills.
enum SpeechCategory {
  cafe(
    labelRu: 'Кафе и еда',
    labelHe: 'קָפֶה וְאֹכֶל',
    icon: Icons.coffee_rounded,
    badgeColor: Color(0xFF795548),
  ),
  cityTaxi(
    labelRu: 'Город и такси',
    labelHe: 'עִיר וּמוֹנִית',
    icon: Icons.local_taxi_rounded,
    badgeColor: Color(0xFFF57C00),
  ),
  market(
    labelRu: 'Шук и покупки',
    labelHe: 'שׁוּק וּקְנִיּוֹת',
    icon: Icons.shopping_basket_rounded,
    badgeColor: Color(0xFF388E3C),
  ),
  slang(
    labelRu: 'Сленг и вайб',
    labelHe: 'סְלֶנְג וַאֲוִירָה',
    icon: Icons.local_fire_department_rounded,
    badgeColor: Color(0xFFD81B60),
  ),
  social(
    labelRu: 'Знакомство и этикет',
    labelHe: 'הֶכֵּרוּת וְנִימוּס',
    icon: Icons.handshake_rounded,
    badgeColor: Color(0xFF1976D2),
  ),
  custom(
    labelRu: 'Свой текст',
    labelHe: 'טֶקְסְט אִישִׁי',
    icon: Icons.edit_note_rounded,
    badgeColor: Color(0xFF7B1FA2),
  );

  final String labelRu;
  final String labelHe;
  final IconData icon;
  final Color badgeColor;

  const SpeechCategory({
    required this.labelRu,
    required this.labelHe,
    required this.icon,
    required this.badgeColor,
  });
}

/// A curated or user-defined Hebrew sentence for acoustic & pronunciation practice.
final class SpeechExercise extends Equatable {
  final String id;
  final String hebrewVocalized;
  final String hebrewNormalized;
  final String transcription;
  final String translationRu;
  final SpeechCategory category;
  final String phoneticTipRu;
  final String difficulty;
  final List<String> keyPhonemes;
  final String? audioPath;

  const SpeechExercise({
    required this.id,
    required this.hebrewVocalized,
    required this.hebrewNormalized,
    required this.transcription,
    required this.translationRu,
    required this.category,
    required this.phoneticTipRu,
    this.difficulty = 'A1',
    this.keyPhonemes = const [],
    this.audioPath,
  });

  /// Factory creating an ad-hoc custom exercise with automatic normalization.
  factory SpeechExercise.custom({
    required String rawHebrew,
    required String translationRu,
    String? transcription,
    String? phoneticTipRu,
  }) {
    final vocalized = rawHebrew.trim();
    final normalized = HebrewNormalizer.stripNikkud(vocalized);
    final id = 'custom_${DateTime.now().millisecondsSinceEpoch}';

    return SpeechExercise(
      id: id,
      hebrewVocalized: vocalized,
      hebrewNormalized: normalized,
      transcription: transcription ?? '',
      translationRu: translationRu.trim().isNotEmpty ? translationRu.trim() : 'Пользовательская фраза',
      category: SpeechCategory.custom,
      phoneticTipRu: phoneticTipRu ?? 'Тренируй плавность речи и чёткость огласовок.',
      difficulty: 'Custom',
      keyPhonemes: const [],
    );
  }

  @override
  List<Object?> get props => [
        id,
        hebrewVocalized,
        hebrewNormalized,
        transcription,
        translationRu,
        category,
        phoneticTipRu,
        difficulty,
        keyPhonemes,
        audioPath,
      ];
}
