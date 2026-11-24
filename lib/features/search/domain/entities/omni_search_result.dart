import 'package:equatable/equatable.dart';

/// Categories of items returned in the global Omni-Search.
enum OmniResultCategory {
  dictionary(id: 'dictionary', labelRu: 'Словарь'),
  shoresh(id: 'shoresh', labelRu: 'Корни'),
  army(id: 'army', labelRu: 'ЦАХАЛ / Армия'),
  news(id: 'news', labelRu: 'Новости'),
  chat(id: 'chat', labelRu: 'WhatsApp'),
  dialogue(id: 'dialogue', labelRu: 'Диалоги'),
  slang(id: 'slang', labelRu: 'Сленг'),
  grammar(id: 'grammar', labelRu: 'Грамматика'),
  alphabet(id: 'alphabet', labelRu: 'Алфавит'),
  preposition(id: 'preposition', labelRu: 'Предлоги');

  const OmniResultCategory({required this.id, required this.labelRu});

  final String id;
  final String labelRu;
}

/// A unified search result entry across all app domains.
final class OmniSearchResult extends Equatable {
  const OmniSearchResult({
    required this.id,
    required this.category,
    required this.hebrewWithNikkud,
    required this.hebrewWithoutNikkud,
    required this.translationRu,
    this.transliteration,
    this.root,
    this.details,
    this.audioText,
    this.originalObject,
  });

  final String id;
  final OmniResultCategory category;
  final String hebrewWithNikkud;
  final String hebrewWithoutNikkud;
  final String translationRu;
  final String? transliteration;
  final String? root;
  final String? details;
  final String? audioText;
  final Object? originalObject;

  /// Returns the text best suited for TTS speech synthesis.
  String get effectiveAudioText =>
      (audioText != null && audioText!.isNotEmpty) ? audioText! : hebrewWithNikkud;

  @override
  List<Object?> get props => [
        id,
        category,
        hebrewWithNikkud,
        hebrewWithoutNikkud,
        translationRu,
        transliteration,
        root,
        details,
        audioText,
      ];
}
