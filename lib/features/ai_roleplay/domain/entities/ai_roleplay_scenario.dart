import 'package:equatable/equatable.dart';

import 'ai_roleplay_character.dart';

/// Quick interactive prompt suggestion that the user can tap to reply.
final class SuggestedPromptItem extends Equatable {
  final String hebrew;
  final String russian;

  const SuggestedPromptItem({
    required this.hebrew,
    required this.russian,
  });

  @override
  List<Object?> get props => [hebrew, russian];
}

/// A situational dialogue scenario with an interactive AI partner.
final class AiRoleplayScenario extends Equatable {
  final String id;
  final String titleRussian;
  final String category;
  final String level;
  final String badgeEmoji;
  final String descriptionRussian;
  final AiRoleplayCharacter character;
  final List<SuggestedPromptItem> suggestedPrompts;

  const AiRoleplayScenario({
    required this.id,
    required this.titleRussian,
    required this.category,
    required this.level,
    required this.badgeEmoji,
    required this.descriptionRussian,
    required this.character,
    required this.suggestedPrompts,
  });

  @override
  List<Object?> get props => [
        id,
        titleRussian,
        category,
        level,
        badgeEmoji,
        descriptionRussian,
        character,
        suggestedPrompts,
      ];
}
